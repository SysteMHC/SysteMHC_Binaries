#!/usr/bin/python

import sys
import os
import shutil
import string
import shlex, subprocess
import time
# Defines
SEP = "\t"

IN_HEADER = ["Peptide", "Accession"]
OUT_HEADER = ["Sample", "Alleles", "Peptide", "Accession"]
PEPTIDE_COLUMN = "Peptide"
OPTIONAL_COLUMNS = ["Peptide_mod_ion"]

MIN_PEP_LENGTH = 8
MAX_PEP_LENGTH = 12

ALLELES_LIST_AVAIL = ['A0201', 'A0101', 'A0301', 'A1101', 'A2301', 'A2402', 'A2501', 'A2601', 'A2902', 'A3001', 
                'A3101', 'A3201', 'A3301', 'A6801', 'B0702', 'B0801', 'B1402', 'B2705', 'B3501', 'B3801',
                'B3901', 'B4002', 'B4402', 'B4501', 'B5101', 'B5701', 'C0701',
                'H2Db', 'H2Dd', 'H2Kb', 'H2Kd', 'H2Kk', 'H2Ld']

AMINOACIDS = ['A', 'R', 'N', 'D', 'C', 'E', 'Q', 'G', 'H', 'I', 'L', 'K', 'M', 'F', 'P', 'S', 'T', 'W', 'Y', 'V']

NETMHC_PATH = "netMHC-3.4_fix" #/IMSB/ra/lespona/html/bin/mhc_i/method/netMHC-3.4/netMHC-3.4_fix

NETMHC_HEADER = ['pos', 'peptide', 'score/logscore', 'affinity(nM)', 'Bind Level', 'Protein Name', 'Allele', 'Method','SB Threshold', 'WB Threshold']

DATETIME = str(time.time()).split('.')[0]
############## METHODS ################

def getRowDict(header, line, row_columns = IN_HEADER, sep = SEP):
    dict = {}
    header_list = header.split(sep)
    line_list = line.split(sep)
    for key in row_columns:
        dict[key] = line_list[header_list.index(key)]
    return dict

def mergeRows(row_old, row_new, columns = [], sep = ";"):
    merged_row = {}
    for key in row_old.keys():
        if key not in columns:
            merged_row[key] = row_old[key]
        else:
            old_value = row_old[key].split(sep)
            new_value = row_new[key].split(sep)
            merged_row[key] = sep.join(sorted(list(set(old_value+new_value))))
    return merged_row

def checkLength(row, min = MIN_PEP_LENGTH, max = MAX_PEP_LENGTH, peptide_column = PEPTIDE_COLUMN):
    if (len(row[peptide_column])>=min) & (len(row[peptide_column])<=max):
        return True
    else:
        return False

def removePTMs(row, peptide_column = PEPTIDE_COLUMN):
    dict = {}
    for key in row.keys():
        if key != peptide_column:
            dict[key] = row[key]
        else:
            dict[key] = ""
            sequence = row[key]
            for aminoacid in sequence:
                if aminoacid.upper() in AMINOACIDS:
                    dict[key] += aminoacid.upper()
    return dict

def netMHC(peptide, pep_dict, alleles, netMHC_path = NETMHC_PATH):
    pep_len = str(len(peptide))
    tmp_file = "current_prot_" + peptide + "_" + str(time.time()).split('.')[0] + ".tmp"
    with open(tmp_file, "w") as sink:
        sink.write(">Prot_" + peptide + '_' + pep_dict["Alleles"] + "\n")
        sink.write(peptide + "\n")
    arguments = ["-a", ",".join(alleles), "-l", str(len(peptide)), tmp_file]
    #TODO: add datetime to log file name
    logfile = "netMHC_matrix_" + DATETIME + ".log"
    exit_code, result = run_generic_tool(netMHC_path, peptide, arguments, log=logfile, offset="\t\t\t * ")
    scores, thresholds = parseNetMHCResult(peptide, result, exit_code, alleles)
    os.remove(tmp_file)
    return scores, thresholds
    
def parseNetMHCResult(peptide, result, exit_code, alleles):
    scores = {}
    thresholds = {'SB Threshold':{}, 'WB Threshold':{}}    
    if exit_code<0:
        for allele in alleles:
                scores[allele] = str(-1)
    else:    
        #print '\n'.join(result)
        bind_dict = {'WB':500,'SB':50,'NA':1000 }
        rows = 0
        isHeader = True
        header = ""
        for line in result:
            if len(line)>1:
                if isHeader:
                    header = line.strip()
                    isHeader = False
                else:
                    rows += 1
                    row = getRowDict(header, line.strip(), sep = '\t', row_columns = NETMHC_HEADER)  
                    if row['affinity(nM)'] == 'NA':
                        scores[row['Allele']] = str(row['score/logscore'])
                    else:
                        scores[row['Allele']] = str(row['affinity(nM)'])
                    thresholds['SB Threshold'][row['Allele']] = str(row['SB Threshold'])
                    thresholds['WB Threshold'][row['Allele']] = str(row['WB Threshold'])
                    #scores[row['Allele']] = str(bind_dict[row['Bind Level']])
    return scores, thresholds
    
    
def run_generic_tool(tool, in_, args=[], log=".log", log_dir="",
                         log_opts={"ERROR_STOP":[], "ERROR_IGNORE":[], "STD_STOP":[], "STD_IGNORE":[] }, 
                         stdout_file="", verbose = False, offset = ""):
    tool_name = os.path.splitext(os.path.split(tool)[1])[0]
    command = tool + " " + " ".join(args)
    exit_code = -1
    if verbose:
        print ("running tool " + tool_name + " : " + command)
    if log == ".log":
        # need to include output filename so multiple tools running in
        # parallel produce different logfiles:
        log = tool_name + "_" + os.path.splitext(os.path.basename(in_))[0] + log
    
    cmd_line = shlex.split(command)
    process = subprocess.Popen(cmd_line, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output = process.communicate()
    std_output_txt = output[0]
    error_output_txt = output[1]
    exit_code = 0
    
    if verbose:
        lines_to_log = ["Command executed: " + command]
    else:
        lines_to_log = []
    std_output = []
    error_output = []
    
    if std_output_txt:
        std_output = std_output_txt.splitlines()

    if stdout_file:
        with open(stdout_file, "w") as sink:
            sink.write(std_output_txt) 

    if error_output_txt:
        print(offset + "ERROR " + " ".join(cmd_line))
        error_output=error_output_txt.splitlines()
        for line in error_output:
            error_line_ignored = False
            if log_opts["ERROR_STOP"]:
                for log_tag in log_opts["ERROR_STOP"]:
                    if (line.find(log_tag) != -1):
                        exit_code = -1
            if log_opts["ERROR_IGNORE"]:
                for log_tag in log_opts["ERROR_IGNORE"]:
                    if (line.find(log_tag) != -1):
                        error_line_ignored = True
                        std_output.append(line)
            if not error_line_ignored:           
                if (len(line)>2):
                    print("\t" + offset + "ERROR: " + line)
                    lines_to_log.append(line)
                    exit_code = -1

    if std_output:
        for line in std_output:
            lines_to_log.append(line)
            std_line_ignored = False
            if log_opts["STD_STOP"]:
                for log_tag in log_opts["STD_STOP"]:
                    if (line.find(log_tag) != -1):
                        exit_code = -1
                        print(offset + "ERROR: " + line)
                        lines_to_log.append(line)
            if log_opts["STD_IGNORE"]:
                for log_tag in log_opts["STD_IGNORE"]:
                    if (line.find(log_tag) != -1):
                        std_line_ignored = True
            if (len(line) < 2):
                std_line_ignored = True
            if not std_line_ignored and verbose:
                print("\t   "+line)
                
    if log:
        if(len(lines_to_log)>0):
            with open(log, "a") as sink:
                sink.write("\n".join(lines_to_log))
                sink.write("\n")
            
    return exit_code,lines_to_log

def getNetMHCAlleles(sample_alleles, alleles_list):
    predictors = []
    for allele in sample_alleles:
        matched = False
        for predictor in alleles_list:
            if(allele == predictor[0:len(allele)]):
                matched = True
                if predictor not in predictors:
                    predictors += [predictor]
    return (predictors)


def getAdditionalColumns(header, input_columns, extra_columns = [], sep = SEP):
    columns = header.split(sep)
    additional_columns = []
    for column in columns:
        if (column in extra_columns) or ((extra_columns==[]) and (column not in input_columns)):
            additional_columns += [column]
    if additional_columns:
        print("\t\t - Found " + str(len(additional_columns)) + " additional column(s): " + " ,".join(additional_columns)) 
    return additional_columns


def match_alleles_list(alleles_list_str):

        if alleles_list_str:
            alleles_list = []
            for allele_str in alleles_list_str.split(","):
                if allele_str in ALLELES_LIST_AVAIL:
                    alleles_list += [allele_str]
                else:
                    available = False
                    for allele_avail in ALLELES_LIST_AVAIL:
                        if allele_avail[0:len(allele_str)] == allele_str:
                            available = True
                            alleles_list += [allele_avail]
                            break
                    if not available:
                        print " * WARNING: Allele '" + allele_str + "' does not match any of the available alleles, skipping..."
            return(alleles_list)
        else:
            alleles_list = ALLELES_LIST_AVAIL
            return(alleles_list)


############## SCRIPT STARTS ###########
# Get Input
if __name__ == '__main__':

    alleles_list_str = ""
    input_path = ""
    ALLELES_LIST_AVAIL.sort()

    if len(sys.argv) > 1:
        input_path = sys.argv[1]
        if len(sys.argv) > 2:
            alleles_list_str = sys.argv[2]
    else:
        print("\n ERROR: No input files specified \n")
        print(" Usage: matrix_netMHC_MHCI.py peptide_table.txt [allele_1,allele_2,...,allele_n]\n")
        print(" Available alleles (" + str(len(ALLELES_LIST_AVAIL))+"): " + ",".join(ALLELES_LIST_AVAIL))
        print(" Help: Contact Lucia (espona@imsb.biol.ethz.ch).\n")
        exit(-1)

    print ("0. Parameters, input files and format handling: " )
    current_dir = os.environ['PWD']
    print ("\t - Input file: " + input_path)
    output_name = os.path.splitext(os.path.basename(input_path))[0] + "_matrix_netMHC.txt"
    output_path = os.path.join(current_dir, output_name)
    print ("\t - Output file: " + output_path)

    # ensure ends of line are compatible
    print ("\n\t - Fixing input file to ensure linux end of lines")
    command = "perl -pi -e 's/\\r\\n/\\n/g' " + input_path
    print ("\t\t - Executing: " + command)
    os.system(command)
    command = "perl -pi -e 's/\\r/\\n/g' " + input_path
    print ("\t\t - Executing: " + command)
    os.system(command)

    print("\n1. Match the given alleles to the netMHC available ones ...")
    alleles_list = match_alleles_list(alleles_list_str)

    alleles_list = list(set(alleles_list))
    alleles_list.sort()

    if alleles_list_str:
        print ("\t - Alleles to predict selected (" + str(len(alleles_list)) +"): " + ",".join(alleles_list))
    else:
        print ("\t - No selection, predicting for all netMHC alleles (" + str(len(alleles_list)) +"): " + ",".join(alleles_list))

    print("  ...DONE!")

    # 2. Process input files
    print("\n2. Parsing the input table ...")
    print("\t - Peptide length allowed: [" + str(MIN_PEP_LENGTH) + " - " + str(MAX_PEP_LENGTH) + "]")

    results_dict = {}
    rows = 0
    duplicates = 0
    isHeader = True
    header = ""
    additional_columns = []

    with open(input_path, 'r') as source:
        for line in source:
            line = line.strip()
            if len(line)>0:
                if isHeader:
                    header = line
                    isHeader = False
                    additional_columns = getAdditionalColumns(header, IN_HEADER, OPTIONAL_COLUMNS, SEP)
                else:
                    rows += 1
                    row = getRowDict(header, line, IN_HEADER + additional_columns, sep = SEP)
                    row = removePTMs(row)
                    row['Alleles'] = ";".join(alleles_list)
                    row["Sample"] = os.path.splitext(os.path.basename(input_path))[0]
                    if checkLength(row):
                        if row["Peptide"] not in results_dict.keys():
                            results_dict[row["Peptide"]] = row
                        else:
                            duplicates += 1
                            results_dict[row["Peptide"]] = mergeRows(results_dict[row["Peptide"]], row, ["Accession"], ";")

    print("\t\t - Read " + str(rows) + " input lines, including " + str(duplicates) + " duplicates")
    print("\t - Found " + str(len(results_dict.keys())) + " unique peptides: " + ", ".join(results_dict.keys()[0:3]) + "... " + results_dict.keys()[-1])
    print("  ...DONE!")

    # define output table columns
    output_header_columns = OUT_HEADER + additional_columns + alleles_list

    # 3. netMHC analysis
    print("\n3. Processing peptides with netMHC...")

    count = 0

    # Create an empty dictionary structure
    thresholds_dict = {'SB Threshold':{},'WB Threshold':{}}
    for threshold  in thresholds_dict:
        for column in  output_header_columns:
            thresholds_dict[threshold][column] = threshold

    first = True
    for peptide in results_dict.keys():
        netMHC_result, netMHC_threshold = netMHC(peptide, results_dict[peptide], alleles = alleles_list)
        if first: # get Thresholds
            first = False
            thresholds_dict['SB Threshold'] = dict(thresholds_dict['SB Threshold'].items() + netMHC_threshold['SB Threshold'].items())
            thresholds_dict['WB Threshold'] = dict(thresholds_dict['WB Threshold'].items() + netMHC_threshold['WB Threshold'].items())
        results_dict[peptide] = dict(results_dict[peptide].items() + netMHC_result.items())
        count += 1
        if count % 500 == 0:
            print ("\t - Processed " + str(100*count/len(results_dict.keys())) + '% of peptides...')
    print("  ...DONE!")

    # 4. Write file
    print("\n4. Write output file...")
    rows = 0
    with open(output_path, "w") as sink:

        sink.write(SEP.join(output_header_columns) + "\n")
        for peptide in results_dict:
            line_list = []
            for column in (output_header_columns):
                if type(results_dict[peptide][column]) is not str:
                    results_dict[peptide][column] = ";".join(results_dict[peptide][column])
                line_list += [results_dict[peptide][column].strip('"')]
            sink.write(SEP.join(line_list) + '\n')
            rows += 1
        print("\t - Written " + str(rows) + " peptide rows to " + output_path)
        rows = 0
        for threshold in thresholds_dict:
            line_list = []
            for column in output_header_columns:
                line_list += [thresholds_dict[threshold][column].strip('"') ]
            sink.write(SEP.join(line_list) + '\n')
            rows += 1
        print("\t - Done, added " + str(rows) + " threshold rows to " + output_path)
    print("  ...DONE!")




