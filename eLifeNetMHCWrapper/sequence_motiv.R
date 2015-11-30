######## FUNCTIONS #########
# Fit peptide sequence to maximum length
fitToLength <- function(peptide, maxLength, blank) {
	pep_len = nchar(peptide)
	difference = maxLength - pep_len
	if (difference < 1) { return(peptide) 
	} else { 
		characters =  as.vector(unlist(strsplit(peptide,"")))
		part_1 = characters[1:(ceiling(pep_len/2))]
		blanks = rep(blank, difference)
		part_2 = characters[(ceiling(pep_len/2)+1):pep_len]
		characters = c(part_1, blanks, part_2)
		return(paste(characters, sep = "", collapse = ""))
	}
}
# Obtain the individual peptide matrix
getPeptideMatrix <- function(peptide, peptideMatrix, maxLength, fitLength = FALSE) {
	blank = '_'
	if ((nchar(peptide)<maxLength)&(fitLength)) {
		peptide = fitToLength(peptide, maxLength, blank) 
	}
	characters =  as.vector(unlist(strsplit(peptide,"")))
	
	# WITO : actually it is just a loop...
	update_matrix = sapply(c(1:length(characters)), function(pos) { if (characters[pos] != blank){ 
																	peptideMatrix[characters[pos],pos] <<- 1 } })
	return(peptideMatrix)
}

getMotifMatrix <- function (peptides, fitLength = FALSE, forceLength = 0 ) {
	# create blank probability matrix
	aminoacids =  c('A','C','D','E','F','G','H','I','K','L','M','N','P','Q','R','S','T','V','W','Y')
	if (forceLength == 0) {
	  pos_max = max(unlist(lapply(peptides, nchar)))
	}else {pos_max = forceLength}
	
	probability_matrix = data.frame(matrix(0,nrow=length(aminoacids), ncol=pos_max))
	rownames(probability_matrix) = aminoacids
	colnames(probability_matrix) = c(1:pos_max)
			
	if (length(peptides)<1){
		return(probability_matrix)
	} else {																
		pep_matrix_list = lapply (peptides, getPeptideMatrix, peptideMatrix = probability_matrix, maxLength = pos_max, fitLength = fitLength)
		sum_all = sapply(c(1:length(pep_matrix_list)), function(x) { probability_matrix <<- probability_matrix + pep_matrix_list[[x]] })
	
		#if (fit_length) {
		motif_matrix = data.frame(apply(probability_matrix, 2, function(x) { round(10*x/length(peptides),2) }))
		#} else {	
		#	motif_matrix = data.frame(apply(probability_matrix, 2, function(x) { round(10*x/sum(x),2) }))
		#}
		colnames(motif_matrix) = c(1:dim(motif_matrix)[2])
		return(motif_matrix)
	}
}

getMotifMatrixOptimized <- function (peptides, fitLength = FALSE, forceLength = 0 ) {
	# create blank probability matrix
	aminoacids =  c('A','C','D','E','F','G','H','I','K','L','M','N','P','Q','R','S','T','V','W','Y')
	if (forceLength == 0) {pos_max = max(unlist(lapply(peptides, nchar)))}
	else {pos_max = forceLength}
	
	probability_matrix = data.frame(matrix(0,nrow=length(aminoacids), ncol=pos_max))
	rownames(probability_matrix) = aminoacids
	colnames(probability_matrix) = c(1:pos_max)
	peptide_matrix = probability_matrix
	
	pep_matrix_list = sapply (peptides, function(peptide, peptideMatrix, maxLength, fitLength) {
																blank = '_'
																if ((nchar(peptide)<maxLength)&(fitLength)) { peptide = fitToLength(peptide, maxLength, blank) }
																characters =  as.vector(unlist(strsplit(peptide,"")))
																update_matrix = sapply(c(1:length(characters)), function(pos) { if (characters[pos] != blank){ 
																															           peptideMatrix[characters[pos],pos] <<- 1 } })
																probability_matrix <<- probability_matrix + peptideMatrix
																return(0)
							}, peptideMatrix = peptide_matrix, maxLength = pos_max, fitLength = fitLength)	
	
	
	
	#sum_all = sapply(c(1:length(pep_matrix_list)), function(x) { probability_matrix <<- probability_matrix + pep_matrix_list[[x]] })
	
	#if (fit_length) {
	motif_matrix = data.frame(apply(probability_matrix, 2, function(x) { round(10*x/length(peptides),2) }))
	#} else {	
	#	motif_matrix = data.frame(apply(probability_matrix, 2, function(x) { round(10*x/sum(x),2) }))
	#}
	colnames(motif_matrix) = c(1:dim(motif_matrix)[2])
	return(motif_matrix)
}

plotMotifElement <- function(values, allLetters, probabilityTh, font = 1, fontSizeMax = 10) {
	# The colors of the amino acids correspond to their chemical properties; 
	# - polar amino acids (G, S, T, Y, C, Q, and N) are shown in green
	# - basic amino acids (K, R, and H) are shown in blue
	# - acidic amino acids (D and E) are shown in red
	# - hydrophobic amino acids (A, V, L, I, P, W, F, and M) are shown in black. 
	colors_table = data.frame(letters = c("D","E", "N","Q","S","G","T","Y", "R","K","H"), 
							colors = c("red","red","green","green","green","green","green","green","blue","blue","blue"))
	rownames(colors_table) = colors_table[,"letters"]
	default_color = "black"
	
	# plot all aminoacids
	position = as.integer(colnames(values)[1])
	last_y <- 0
	apply(values, 1, function(x, y) {
		aminoacid = x["letter"]
		probability = as.numeric(x[colnames(values)[1]])
		
		color = default_color
		if (max((rownames(colors_table)==aminoacid)*1)>0) {color = as.character(colors_table[aminoacid,"colors"])}

		font_size_min = 0.1 							
		font_size = max(fontSizeMax * (probability/10), font_size_min)
		
		ytop = last_y + strheight(aminoacid, font = font, cex = font_size) + probabilityTh/4
		pos_y = last_y + strheight(aminoacid, font = font, cex = font_size)/2 + probabilityTh/8
				
		text(x = position, y = pos_y, aminoacid, col = color, font = font, cex = font_size)

		last_y <<- ytop

	}, y = allLetters)
	return(0)
}
	
plotMotifMatrix <- function(motifMatrixList, probabilityTh = 1.0, plotWidth = 15, plotHeight = 10, plotTitle = "Motif Plot", subtitles = "subplot", fontSizeMax = 10, mfrow = FALSE, pdfFile="") {
	# get list of matrices and subtitles
	if (class(motifMatrixList)!= "list") { motifMatrixList = list(motifMatrixList) }
	nplots = length(motifMatrixList)
	if (class(subtitles) != "list") { subtitles = rep(subtitles, nplots) }
	
	# Main plotting
	if (nchar(pdfFile)>1){				
		pdf(pdfFile, width=plotWidth, height=plotHeight)
	} 
	else {
			dev.new(width=plotWidth, height=plotHeight)
			plot.new()
	}
	
	if (mfrow == FALSE) {mfrow = n2mfrow(nplots)}
	par(mfrow = mfrow)
	par(oma=c(0,0,3,0))
	par(font.main=1)
	
	#plot matrices in input list
	index = 1
	doPlot = lapply(motifMatrixList, function(motif_matrix, subtitles) {
		# get limits
		pos_max = dim(motif_matrix)[2]
		# subplot setup
		plot( c(1-0.5,pos_max+0.5), c(0,plotHeight), xlab="aminoacid position", ylab="", xaxt = "n", yaxt = "n", col = "white", main = subtitles[index])
		axis(1, at = c(1:pos_max))
		
		#plot elements
		plot_motif = sapply(colnames(motif_matrix),function(x,y) {
				column = y[x]
				letter = rownames(y)
				values = cbind(column,letter)
				values = values[values[x]>=probabilityTh,]
				values = values[order(values[x]), ]
				if (dim(values)[1]>0) {
					plotMotifElement(values, as.vector(rownames(y)), probabilityTh, fontSizeMax = round(fontSizeMax/mfrow[2]))
				}
				return (0)
			}, y = motif_matrix )
		index <<- index + 1
	}, subtitles = subtitles)

	#set main title
	title(main = plotTitle, outer = T)
	
	if (nchar(pdfFile)>1){dev.off()}	
						
	return (0)
}

