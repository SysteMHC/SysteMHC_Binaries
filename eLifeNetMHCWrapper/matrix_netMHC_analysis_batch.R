# load libraries
library(gplots)

r_scripts_path = Sys.getenv(c("R_MHCI_SCRIPTS"))
source(paste(r_scripts_path, "allele_distributions.R", sep="/"))
source(paste(r_scripts_path, "sequence_motiv.R", sep="/"))

###############################################
################# MAIN ########################
###############################################

# To run interactively:
# Start R session
# argv = c('input_file.txt','output_file')
# source("matrix_netMHC_analysis_batch.R")

# To run in command line
# Rscript matrix_netMHC_analysis_batch.R "input_file=\"peptides_list_matrix_netMHC.txt\"" "output_file=\"peptides_list_matrix_netMHC_factor.tsv\""
	
## read in the arguments listed at the command line
args=(commandArgs(TRUE))
extra_tag=""

print(args)
print(length(args))

if(length(args)<2){
	write("ERROR: Invalid arguments supplied.\n Usage: '--args input_file=\"input_file.txt\" output_file=\"output_file.txt\"'", stderr())
	stop("No arguments supplied.")
} else {
    for(i in 1:length(args)){
		eval(parse(text=args[[i]]))
    }
}

print(paste(" - Parameters: * input_file: '", input_file, "'", sep = ""))
print(paste("               * output_file: '", output_file, "'", sep = ""))
out_dir = dirname(output_file)

# Constants
# Input file column separator
COLUMN_SEP = "\t"

# Separator between values in the same column (specially alleles)
VALUE_SEP = ";"

DEFAULT_WB_CUTOFF =  500

# Minimum fold change between first and second minimum affinity (factor) for a peptide to be assigned to an allele.
# Lower values of this factor will make a peptide to be considered as "UNCLASSIFIED"
FACTOR_TH_MIN = 3

# Percentile of the peptides assigned to one allele to estimate the new cutoff
PERCENTILE = 0.95

# Print Motifs to pdf
DO_MOTIFS = TRUE

# Minimum 
PROBABILTY_TH = 1

#################################################
#                                               #
#   1. CALCULATE FACTOR AND CLASSIFY PEPTIDES   #
#                                               #
#################################################

# read the input files
input_df <- read.table(input_file, header = T, sep = COLUMN_SEP, stringsAsFactor=FALSE)
sample_name = unique(input_df[,"Sample"])[1]

# get the cutoff and remove extra rows
wb_cutoff =  input_df[input_df["Peptide"]=="WB Threshold", ncol(input_df)]
if(length(wb_cutoff)==0L) {wb_cutoff = DEFAULT_WB_CUTOFF} 
print(paste(" - Weak Binder Threshold:", wb_cutoff))

input_df <- input_df[!input_df$Peptide == "WB Threshold", ]
input_df <- input_df[!input_df$Peptide == "SB Threshold", ]

# Calculate the ratio between minimum and second minimum (factor)
print(" - Calculating minimum and factors...")
factor_df = computeFactorColums(input_df)

# Write file
factor_df_print = factor_df[ order(factor_df[,"Sample"], -factor_df[,"factor"]), ]
print(paste("    * Writing factor to output file: '", output_file, "'", sep = ""))
write.table(factor_df_print, file=output_file, col.names=T, row.names=F, quote=F, append=F, sep=COLUMN_SEP)

############################################################
#                                                          #
#   2. ESTIMATE NEW NETMHC CUTOFFS AND SHOW DISTRIBUTION   #
#                                                          #
############################################################

print(paste (" - Calculating new affinity cutoffs (", PERCENTILE*100,"%)...", sep=""))
print(paste ("    * Minimum factor:", FACTOR_TH_MIN))

# Calculate and print the distributions
dist_pdf_file = paste(out_dir,"/", sample_name, "_allele_distributions.pdf", sep = "")
print(paste("    * Printing distributions to PDF file: '", dist_pdf_file, "'", sep = ""))

# Filter out the ones with a too low factor
high_confidence_df = factor_df[(factor_df[,"factor"]>FACTOR_TH_MIN),]
high_confidence_alleles = sort(unique(high_confidence_df[,"best"]))

# Displaying distributions histograms and new cutoff for selected percentile
thresholds_df = getThresholdsDF(high_confidence_df, high_confidence_alleles, FACTOR_TH_MIN, PERCENTILE, wb_cutoff, doPlot = TRUE, pdfFile = dist_pdf_file)

# print the thresholds
print(thresholds_df)

# Write file
thresholds_df_file = paste(out_dir, paste(sample_name, "_new_netMHC_cutoff_",FACTOR_TH_MIN,".tsv", sep=""), sep="/")
print(paste("    * Output: factor_df_file: '", thresholds_df_file, "'", sep = ""))
write.table(thresholds_df, file=thresholds_df_file, col.names=T, row.names=F, quote=F, append=F, sep=COLUMN_SEP)

###################################################
#                                                 #
#   3. PRINTOUT MOTIFS FOR WB AND NEW THRESHOLD   #
#                                                 #
###################################################
if (DO_MOTIFS) {
	print(" - Displaying motifs...")
	# get the peptide lists per allele 
	threshold_column = dim(thresholds_df)[2]-1
	peptide_lists = lapply(high_confidence_alleles, function(allele, high_confidence_df, thresholds_df) {
						peps_list_WB <- as.vector(t(high_confidence_df[(high_confidence_df[,"best"]==allele)&(high_confidence_df[,allele]<=wb_cutoff), "Peptide"]))
						peps_list_newTH <- as.vector(t(high_confidence_df[(high_confidence_df[,"best"]==allele)&(high_confidence_df[,allele]<=thresholds_df[allele,threshold_column]), "Peptide"]))
						return(list(allele,peps_list_WB,peps_list_newTH))
					},  high_confidence_df=high_confidence_df, thresholds_df=thresholds_df)
	
	# get the motif matrices per allele 	
	max_pep_length = max(sapply(high_confidence_df[,"Peptide"],nchar))
	motif_matrices = sapply(peptide_lists, function(element) { 
												motif_matrix_WB = getMotifMatrix (element[[2]], fitLength = TRUE, forceLength = max_pep_length)
												motif_matrix_newTH = getMotifMatrix (element[[3]], fitLength = TRUE, forceLength = max_pep_length)
												return(list(motif_matrix_WB, motif_matrix_newTH))
												})
	motif_matrices = lapply(seq_len(length(motif_matrices)), function(i) motif_matrices[[i]])									
	
	# get the motif sutitles per allele 	
	motif_titles = sapply(peptide_lists, function(element) { 
				motif_title_WB = paste(element[[1]], " (", length(element[[2]]), " peptides)", " WB ", wb_cutoff, sep="")
				motif_title_newTH = paste(element[[1]], " (", length(element[[3]]), " peptides)", " newTH ", thresholds_df[element[[1]],threshold_column], sep="")
				return(list(motif_title_WB, motif_title_newTH))
			})
	motif_titles = sapply(seq_len(length(motif_titles)), function(i) motif_titles[[i]])									
	
	# plot all length motifs
	motifs_all_pdf_file = paste(out_dir, "/", sample_name, "_motifs_all_lengths.pdf", sep = "")
	print(paste("    * Printing all length motifs to PDF file: '", motifs_all_pdf_file, "'", sep = ""))
	
	do_plot_all = plotMotifMatrix(motif_matrices, probabilityTh = PROBABILTY_TH, 
						plotTitle = paste("Peptides all lengths '",sample_name,"'", sep=""), 
						subtitles = motif_titles, 
						fontSizeMax = 25, plotWidth = 19, plotHeight = 11,
						pdfFile = motifs_all_pdf_file)
	
	###############
	# length 9
	motifs_len9_pdf_file = paste(out_dir, "/", sample_name, "_motifs_9ers.pdf", sep = "")
	print(paste("    * Printing length 9 motifs to PDF file: '", motifs_len9_pdf_file, "'", sep = ""))
	
	peptide_lists_len9 = lapply(high_confidence_alleles, function(allele, high_confidence_df, thresholds_df) {
						peps_list_WB <- as.vector(t(high_confidence_df[(high_confidence_df[,"best"]==allele)&(high_confidence_df[,allele]<=wb_cutoff), "Peptide"]))
						peps_list_WB <- peps_list_WB[nchar(peps_list_WB)==9]
						peps_list_newTH <- as.vector(t(high_confidence_df[(high_confidence_df[,"best"]==allele)&(high_confidence_df[,allele]<=thresholds_df[allele,threshold_column]), "Peptide"]))
						peps_list_newTH <- peps_list_newTH[nchar(peps_list_newTH)==9]
						return(list(allele,peps_list_WB,peps_list_newTH))
					},  high_confidence_df=high_confidence_df, thresholds_df=thresholds_df)
					
	motif_titles_len9 = sapply(peptide_lists_len9, function(element) { 
				motif_title_WB = paste(element[[1]], " (", length(element[[2]]), " peptides)", " WB ", wb_cutoff, sep="")
				motif_title_newTH = paste(element[[1]], " (", length(element[[3]]), " peptides)", " newTH ", thresholds_df[element[[1]],threshold_column], sep="")
				return(list(motif_title_WB, motif_title_newTH))
			})
	motif_titles_len9 = sapply(seq_len(length(motif_titles_len9)), function(i) motif_titles_len9[[i]])									
	
	motif_matrices_len9 = sapply(peptide_lists_len9, function(element) { 
												motif_matrix_WB = getMotifMatrix (element[[2]], fitLength = TRUE, forceLength = 9)
												motif_matrix_newTH = getMotifMatrix (element[[3]], fitLength = TRUE, forceLength = 9)
												return(list(motif_matrix_WB, motif_matrix_newTH))
												})
	motif_matrices_len9 = lapply(seq_len(length(motif_matrices_len9)), function(i) motif_matrices_len9[[i]])									
	
	
	do_plot_len9 = plotMotifMatrix(motif_matrices_len9, probabilityTh = PROBABILTY_TH, 
						plotTitle = paste("Peptides length 9 '",sample_name,"'", sep=""),
						subtitles = motif_titles_len9, 
						fontSizeMax = 25, plotWidth = 19, plotHeight = 11,
						pdfFile = motifs_len9_pdf_file)	
}

###########################################
#                                         #
#   4. CREATE HEATMAP TABLE AND DISPLAY   #
#                                         #
###########################################

print(" - Creating heatmap...")

# Data frame containing the peptide-protein association
prot_df = input_df[,c("Accession", "Peptide")]
rownames(prot_df) = prot_df$Peptide

heatmap_df <- factor_df[,colSums(is.na(factor_df))<nrow(factor_df)]
heatmap_df[heatmap_df[,"factor"] <= FACTOR_TH_MIN, "best"] = "UNCLASSIFIED"

# remove non present alleles:
#non_allele_columns = c("Peptide","Alleles","Sample","min1","min2","diff_mins","factor","best")
#heatmap_df = heatmap_df[,c(high_confidence_alleles,non_allele_columns)]

# sort heatmap
heatmap_df = heatmap_df[order(heatmap_df[,"best"],-heatmap_df[,"factor"]),] 
num_alleles = length(unlist(strsplit(heatmap_df[1,"Alleles"],VALUE_SEP)))
#num_alleles = length(high_confidence_alleles)
	
heatmap_table_file = paste(out_dir, "/", sample_name, "_heatmap_table.tsv", sep="")
print(paste("    * Writing heatmap table to file: '", heatmap_table_file, "'", sep = ""))

heatmap_df_print = subset(heatmap_df, select = -c(Alleles,min1, min2, diff_mins, Sample))
heatmap_df_print$Length = nchar(heatmap_df_print$Peptide)
colnames(heatmap_df_print)[which(colnames(heatmap_df_print) == "best")] = "Allele"
heatmap_df_print$Protein = as.vector(sapply(heatmap_df_print$Peptide, function(sample_name,ref){return(ref[sample_name, "Accession"])}, prot_df))	
write.table(heatmap_df_print, file=heatmap_table_file, col.names=T, row.names=F, quote=F, append=F, sep=COLUMN_SEP)

# Printing heatmap graph
heatmap_pdf_file = paste(out_dir, "/", sample_name, "_heatmap_Rplot.pdf", sep="")
print(paste("    * Printing heatmap to PDF file: '", heatmap_pdf_file, "'", sep = ""))

heatmap_matrix = log(matrix(unlist(heatmap_df[,c(1:num_alleles)]), ncol = num_alleles))
heatmap_matrix[heatmap_df[,"factor"] <= FACTOR_TH_MIN, c(1:num_alleles)] = heatmap_matrix[heatmap_df[,"factor"] <= FACTOR_TH_MIN, c(1:num_alleles)] + 1

burn_col = colorRampPalette(c("red","dark red", "dark green", "gray20", "black"))(max(heatmap_matrix)*10)
nc = dim(heatmap_matrix)[2]
nr = dim(heatmap_matrix)[1]

colnames(heatmap_matrix) = sapply(colnames(heatmap_df[,c(1:num_alleles)]), function(sample_name) {strsplit(sample_name,"_")[[1]][1]})
heatmap_matrix = heatmap_matrix[,sort(colnames(heatmap_matrix))]

pdf(heatmap_pdf_file, width=5*dim(heatmap_matrix)[2], height=5*dim(heatmap_matrix)[2])
par(oma=c(6,0,3,0))
heatmap.2(heatmap_matrix, Rowv=NULL, Colv=NULL, trace="none", dendrogram="none", keysize = 0.8, cexCol = 1.5, 
           col=burn_col, scale="none", margins=c(3, 3), labRow=NA, key = T, rowsep=c(), colsep=c(), sepwidth=c(0,0),
           density.info='none')

classif_count_str = paste(as.vector(sapply(unique(heatmap_df[,"best"]), function(x, y){count = dim(heatmap_df[heatmap_df["best"]==x,])[1]
												return(paste(x, "(", count, ")", sep=""))})), collapse = ", ")
print(paste("    * Classification of the peptides: ", classif_count_str, sep = ""))

title(main=paste("Heatmap Allele Classification\n'", sample_name, "'\n", classif_count_str,sep=""),outer=T)	
dev.off()

