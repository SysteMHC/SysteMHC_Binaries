

asNumericAffinity <- function(inputDF) {
    numeric_df = subset(inputDF, select = -c(Alleles,Sample,Peptide))
    # optional column 'Peptide_mod_ion'
    if ('Peptide_mod_ion' %in% colnames(inputDF)){
        numeric_df = subset(inputDF, select = -c(Alleles,Sample,Peptide,Peptide_mod_ion))
        }
    
    colnames_bck = colnames(numeric_df)
    numeric_df <- t(apply(numeric_df, 1, as.numeric))
    numeric_df <- data.frame(numeric_df)
    colnames(numeric_df) = colnames_bck 
    numeric_df[,"Peptide"] = inputDF[,"Peptide"]
    numeric_df[,"Alleles"] = inputDF[,"Alleles"]
    numeric_df[,"Sample"] = inputDF[,"Sample"]
    if ('Peptide_mod_ion' %in% colnames(inputDF)){numeric_df[,"Peptide_mod_ion"] = inputDF[,"Peptide_mod_ion"]}
    return(numeric_df)
}


getThresholdsDF <- function(highConfidenceDF, highConfidenceAlleles, factorMin, percentile, WBCutoff, doPlot = TRUE, pdfFile = "") {
    
    thresholds_df = data.frame(sapply(highConfidenceAlleles, function(x,y) {max(y[y[,"best"] == x,"min1"])}, y = highConfidenceDF))
    colnames(thresholds_df) = c(paste("Cutoff_Factor", factorMin, sep="_"))
    thresholds_df[,"Allele"] = rownames(thresholds_df)
    # reorder columns
    col_idx <- grep("Allele", colnames(thresholds_df))
    thresholds_df <- thresholds_df[, c(col_idx, (1:ncol(thresholds_df))[-col_idx])]  
    
    colname_th = paste("Cutoff_Factor", factorMin, "%", round(percentile*100), sep="_")
    thresholds_df[, colname_th] = getCutoffPercentile (thresholds_df, highConfidenceDF, factorMin, percentile, doPlot = doPlot, pdfFile = dist_pdf_file, WBCutoff = WBCutoff)

    thresholds_df[,"num_peps"] = (apply(thresholds_df, 1, function(x) {
                                                    values = highConfidenceDF[highConfidenceDF[,"best"]==(x["Allele"]), x["Allele"]]
                                                    length(values[!is.na(values)])
                                                }))
    return(thresholds_df)                                                          
}

computeFactorColums <- function(inputDF, valueSep = ";") {
                                    
    affinity_df <- asNumericAffinity(subset(inputDF, select = -c(Accession)))
    alleles_columns = colnames(subset(affinity_df, select = -c(Alleles,Sample,Peptide)))
    if ('Peptide_mod_ion' %in% colnames(affinity_df)){
        alleles_columns = colnames(subset(affinity_df, select = -c(Alleles,Sample,Peptide,Peptide_mod_ion)))
        }
    getMinimum <- function(row, columns, rank = 1){
        predictions = as.numeric(as.vector(row[columns]))
        row_no_na = predictions[!is.na(predictions)]        
        num_values <- length(row_no_na)
        if(num_values<rank) { NA }
        else{ return(sort(row_no_na)[rank]) }
    }

    min1 = apply(affinity_df, 1, getMinimum, columns=alleles_columns, rank = 1)
    min2 = apply(affinity_df, 1, getMinimum, columns=alleles_columns, rank = 2)
    diff_mins = min2 - min1
    factor = round(min2/min1, 3)
    
    best = apply(affinity_df, 1,
            function(row, columns){
                predictions = row[columns]
                row_no_na = as.numeric(predictions[!is.na(predictions)])
                min_1 = min(row_no_na, na.rm=TRUE)
                best_cols = (columns[which(as.numeric(predictions) == min_1)])
                paste(best_cols, collapse = valueSep, sep = valueSep)
            }, columns=alleles_columns)
    
    factor_df = merge(affinity_df, data.frame(min1, min2, diff_mins, factor, best), by=0, all=TRUE)
    factor_df[,"best"] = as.character(factor_df[,"best"])
    rownames(factor_df) = as.vector(factor_df[,"Row.names"])
    return(subset(factor_df, select = -c(Row.names)))
    
}

getAlleleCutoff <- function(threshold, valuesDF, percentile, doPlot = TRUE, WBCutoff = 500) {
    # get input values
    allele = threshold["Allele"]
    values = valuesDF[valuesDF[,"best"]==allele, allele]
    values = sort(values[!is.na(values)])
    
    scores_scale = c(0:max(values))
    peptide_count = sapply(scores_scale, function(c) {length(values[values <= c])})
    
    if(max(peptide_count)<1) {
        print(paste("* WARNING: Not enough peptides for ", allele, " (", max(peptide_count), "), setting percentile to 100%", sep = ''))    
        percentile = 1
    } 
                                                                                                 
    cutoff_perc_x = min(peptide_count[peptide_count>=(max(peptide_count) * percentile)])
    cutoff_perc_y = scores_scale[match(cutoff_perc_x, peptide_count)]
  
    allele_ylim = rev(range(scores_scale))
    
    if (doPlot) {
        # plot histogram
        plot(peptide_count, scores_scale, ylim = allele_ylim, type='l', main=allele, 
                sub=paste("Max =", max(values), ", cutoff(", round(percentile*100) ,"%) = ", as.character(cutoff_perc_y)), 
                xlab="# peptides", ylab="netMHC cutoff", col="blue")
    
        # plot default cutoff WB
        abline(h = WBCutoff, v = NULL, col = "gray")
        text(x = max(peptide_count)/10, y = (WBCutoff) + (max(scores_scale)/20), paste("WB=", round(WBCutoff), sep=""), col = "dark gray")
        
        # plot new cutoff        
        if (WBCutoff>cutoff_perc_y) { color_th = "red" } else { color_th = "dark green" }
        points(cutoff_perc_x, cutoff_perc_y, col = color_th)
        abline(h = cutoff_perc_y, v = cutoff_perc_x, col = color_th)
        text(x = max(peptide_count)/5, y = (cutoff_perc_y) - (max(scores_scale)/20), paste("Score ",round(percentile*100),"% =", as.character(cutoff_perc_y), sep=""), col = color_th)
 
    }
                                                                                                  
    return(cutoff_perc_y)    
    
}

getCutoffPercentile <- function (thresholdsDF, valuesDF, factorMin, percentile, doPlot = TRUE, pdfFile = "", WBCutoff = 500) {

    if (doPlot) {
        mfrow = rev(n2mfrow(length(unique(thresholdsDF[,"Allele"]))))
        plot_width_max = 20
        plot_height_max = 14

        plot_height = min(plot_height_max, mfrow[1] * (plot_width_max/mfrow[2]) * 0.8)
        plot_width = min(plot_width_max, mfrow[2] * (plot_height/mfrow[1])*1.2)
        
        if (nchar(pdfFile)>1){
            pdf(pdfFile, width=plot_width, height=plot_height)
        }
        else {
            dev.new(width=plot_width, height=plot_height)
        }    
        par(mfrow = mfrow)
        par(oma=c(0,0,4,0))
    }
    
    cutoff = (apply(thresholdsDF,1, getAlleleCutoff, valuesDF, percentile, doPlot, WBCutoff))
    
    if (doPlot) {    
        title(main=paste("Histograms '", unique(valuesDF[,"Sample"])[1], "'\n Min factor (min2/min1) =", factorMin, sep=""),outer=T)    
        if (nchar(pdfFile)>1) {dev.off()}
    }
    
    return (cutoff)
}
