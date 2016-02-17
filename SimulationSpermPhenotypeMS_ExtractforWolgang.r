#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#	 Malika IHLE
#	 Breeding 2012 - 2013 Combined !       >>>>>>   EXTRACT
#	 Stats on breeding in aviaries
#	 Start : 10/01/2014
#	 last modif : 22/12/2015 simulations MS sperm-phenotype
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
rm(list = ls(all = TRUE))
library(rmeta)


raw353 <- read.table("R_raw353withDisplay.txt", header=TRUE, sep='\t')
head(raw353)

{# simulation expected correlation in inbred/outbred groups, with real sample size, published cohens d, metanalyse of 18 correlations, run a 1000 times

head(raw353)	# write.table(raw353, file = "R_raw353withDisplay.xls", sep="\t", col.names=TRUE)

{# sample sizes Sanja and Johannes for each phenotypic trait - sperm trait correlations (N=18)
NSanjaBeakMunselAbnIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 1,])
NSanjaBeakMunselAbnOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 0,])
NSanjaBeakMunselVelocityIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 1,])
NSanjaBeakMunselVelocityOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 0,])
NSanjaBeakMunselSlengthIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 1,])
NSanjaBeakMunselSlengthOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 0,])

NSanjaDisplayAbnIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 1,])
NSanjaDisplayAbnOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 0,])
NSanjaDisplayVelocityIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 1,])
NSanjaDisplayVelocityOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 0,])
NSanjaDisplaySlengthIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 1,])
NSanjaDisplaySlengthOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 0,])

NSanjaTarsusAbnIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 1,])
NSanjaTarsusAbnOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 0,])
NSanjaTarsusVelocityIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 1,])
NSanjaTarsusVelocityOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 0,])
NSanjaTarsusSlengthIn <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 1,])
NSanjaTarsusSlengthOut <- nrow(raw353[raw353$Exp == 3 & !(is.na(raw353$Slength)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 0,])


NJohannesBeakMunselAbnIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 1,])
NJohannesBeakMunselAbnOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 0,])
NJohannesBeakMunselVelocityIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 1,])
NJohannesBeakMunselVelocityOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 0,])
NJohannesBeakMunselSlengthIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 1,])
NJohannesBeakMunselSlengthOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$BeakColourScore)) & raw353$InbredYN == 0,])

NJohannesDisplayAbnIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 1,])
NJohannesDisplayAbnOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 0,])
NJohannesDisplayVelocityIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 1,])
NJohannesDisplayVelocityOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 0,])
NJohannesDisplaySlengthIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 1,])
NJohannesDisplaySlengthOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$sqrtSumAllDisplaySecRate)) & raw353$InbredYN == 0,])

NJohannesTarsusAbnIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 1,])
NJohannesTarsusAbnOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$logAbnormal)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 0,])
NJohannesTarsusVelocityIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 1,])
NJohannesTarsusVelocityOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$VCL0s)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 0,])
NJohannesTarsusSlengthIn <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 1,])
NJohannesTarsusSlengthOut <- nrow(raw353[raw353$Exp == 1 & !(is.na(raw353$Slength)) & !(is.na(raw353$Tarsus)) & raw353$InbredYN == 0,])

}

{# 18 correlations in a data frame

metaSimlist <- list()

for (j in 1:1000){

{# beak - Abnormal Sanja
	
SanjaBeakMunselAbnOutX <- rnorm(NSanjaBeakMunselAbnOut,0,1)
SanjaBeakMunselAbnInX <-rnorm(NSanjaBeakMunselAbnIn,-1.04,1)	# Bolund
SanjaBeakMunselAbnallX <- c(SanjaBeakMunselAbnOutX,SanjaBeakMunselAbnInX)

SanjaAbnBeakMunselOutY <- rnorm(NSanjaBeakMunselAbnOut,0,1)
SanjaAbnBeakMunselInY <- rnorm(NSanjaBeakMunselAbnIn,-1.40,1) # Opatova !! reverse
SanjaAbnBeakMunselallY <- c(SanjaAbnBeakMunselOutY,SanjaAbnBeakMunselInY)

corSanjaBeakMunselAbn <- cor.test(SanjaAbnBeakMunselallY,SanjaBeakMunselAbnallX) #
seSanjaBeakMunselAbnLower <- abs((corSanjaBeakMunselAbn$conf.int[1]-corSanjaBeakMunselAbn$estimate)/1.96)
seSanjaBeakMunselAbnUpper <- abs((corSanjaBeakMunselAbn$conf.int[2]-corSanjaBeakMunselAbn$estimate)/-1.96)
seSanjaBeakMunselAbn <- mean(seSanjaBeakMunselAbnLower,seSanjaBeakMunselAbnUpper)

}

{# beak - velocity Sanja

SanjaBeakMunselVelocityOutX <- rnorm(NSanjaBeakMunselVelocityOut,0,1)
SanjaBeakMunselVelocityInX <-rnorm(NSanjaBeakMunselVelocityIn,-1.04,1)	# Bolund
SanjaBeakMunselVelocityallX <- c(SanjaBeakMunselVelocityOutX,SanjaBeakMunselVelocityInX)

SanjaVelocityBeakMunselOutY <- rnorm(NSanjaBeakMunselVelocityOut,0,1)
SanjaVelocityBeakMunselInY <- rnorm(NSanjaBeakMunselVelocityIn,-0.74,1) # Opatova
SanjaVelocityBeakMunselallY <- c(SanjaVelocityBeakMunselOutY,SanjaVelocityBeakMunselInY)

corSanjaBeakMunselVelocity <- cor.test(SanjaVelocityBeakMunselallY,SanjaBeakMunselVelocityallX) # 
seSanjaBeakMunselVelocityLower <- abs((corSanjaBeakMunselVelocity$conf.int[1]-corSanjaBeakMunselVelocity$estimate)/1.96)
seSanjaBeakMunselVelocityUpper <- abs((corSanjaBeakMunselVelocity$conf.int[2]-corSanjaBeakMunselVelocity$estimate)/-1.96)
seSanjaBeakMunselVelocity <- mean(seSanjaBeakMunselVelocityLower,seSanjaBeakMunselVelocityUpper)

}

{# beak - Slength Sanja

SanjaBeakMunselSlengthOutX <- rnorm(NSanjaBeakMunselSlengthOut,0,1)
SanjaBeakMunselSlengthInX <-rnorm(NSanjaBeakMunselSlengthIn,-1.04,1)	# Bolund
SanjaBeakMunselSlengthallX <- c(SanjaBeakMunselSlengthOutX,SanjaBeakMunselSlengthInX)

SanjaSlengthBeakMunselOutY <- rnorm(NSanjaBeakMunselSlengthOut,0,1)
SanjaSlengthBeakMunselInY <- rnorm(NSanjaBeakMunselSlengthIn,-0.55,1) # Opatova
SanjaSlengthBeakMunselallY <- c(SanjaSlengthBeakMunselOutY,SanjaSlengthBeakMunselInY)

corSanjaBeakMunselSlength <- cor.test(SanjaSlengthBeakMunselallY,SanjaBeakMunselSlengthallX) # 
seSanjaBeakMunselSlengthLower <- abs((corSanjaBeakMunselSlength$conf.int[1]-corSanjaBeakMunselSlength$estimate)/1.96)
seSanjaBeakMunselSlengthUpper <- abs((corSanjaBeakMunselSlength$conf.int[2]-corSanjaBeakMunselSlength$estimate)/-1.96)
seSanjaBeakMunselSlength <- mean(seSanjaBeakMunselSlengthLower,seSanjaBeakMunselSlengthUpper)


}

{# courtship - Abnormal Sanja

SanjaDisplayAbnOutX <- rnorm(NSanjaDisplayAbnOut,0,1)
SanjaDisplayAbnInX <-rnorm(NSanjaDisplayAbnIn,-1.18,1)	# Bolund
SanjaDisplayAbnallX <- c(SanjaDisplayAbnOutX,SanjaDisplayAbnInX)

SanjaAbnDisplayOutY <- rnorm(NSanjaDisplayAbnOut,0,1)
SanjaAbnDisplayInY <- rnorm(NSanjaDisplayAbnIn,-1.40,1) # Opatova !! reverse
SanjaAbnDisplayallY <- c(SanjaAbnDisplayOutY,SanjaAbnDisplayInY)

corSanjaDisplayAbn <- cor.test(SanjaAbnDisplayallY,SanjaDisplayAbnallX) #
seSanjaDisplayAbnLower <- abs((corSanjaDisplayAbn$conf.int[1]-corSanjaDisplayAbn$estimate)/1.96)
seSanjaDisplayAbnUpper <- abs((corSanjaDisplayAbn$conf.int[2]-corSanjaDisplayAbn$estimate)/-1.96)
seSanjaDisplayAbn <- mean(seSanjaDisplayAbnLower,seSanjaDisplayAbnUpper)

}

{# courtship - velocity Sanja

SanjaDisplayVelocityOutX <- rnorm(NSanjaDisplayVelocityOut,0,1)
SanjaDisplayVelocityInX <-rnorm(NSanjaDisplayVelocityIn,-1.18,1)	# Bolund
SanjaDisplayVelocityallX <- c(SanjaDisplayVelocityOutX,SanjaDisplayVelocityInX)

SanjaVelocityDisplayOutY <- rnorm(NSanjaDisplayVelocityOut,0,1)
SanjaVelocityDisplayInY <- rnorm(NSanjaDisplayVelocityIn,-0.74,1) # Opatova
SanjaVelocityDisplayallY <- c(SanjaVelocityDisplayOutY,SanjaVelocityDisplayInY)

corSanjaDisplayVelocity <- cor.test(SanjaVelocityDisplayallY,SanjaDisplayVelocityallX) #
seSanjaDisplayVelocityLower <- abs((corSanjaDisplayVelocity$conf.int[1]-corSanjaDisplayVelocity$estimate)/1.96)
seSanjaDisplayVelocityUpper <- abs((corSanjaDisplayVelocity$conf.int[2]-corSanjaDisplayVelocity$estimate)/-1.96)
seSanjaDisplayVelocity <- mean(seSanjaDisplayVelocityLower,seSanjaDisplayVelocityUpper)

}

{# courtship - Slength Sanja

SanjaDisplaySlengthOutX <- rnorm(NSanjaDisplaySlengthOut,0,1)
SanjaDisplaySlengthInX <-rnorm(NSanjaDisplaySlengthIn,-1.18,1)	# Bolund
SanjaDisplaySlengthallX <- c(SanjaDisplaySlengthOutX,SanjaDisplaySlengthInX)

SanjaSlengthDisplayOutY <- rnorm(NSanjaDisplaySlengthOut,0,1)
SanjaSlengthDisplayInY <- rnorm(NSanjaDisplaySlengthIn,-0.55,1) # Opatova
SanjaSlengthDisplayallY <- c(SanjaSlengthDisplayOutY,SanjaSlengthDisplayInY)

corSanjaDisplaySlength <- cor.test(SanjaSlengthDisplayallY,SanjaDisplaySlengthallX) #
seSanjaDisplaySlengthLower <- abs((corSanjaDisplaySlength$conf.int[1]-corSanjaDisplaySlength$estimate)/1.96)
seSanjaDisplaySlengthUpper <- abs((corSanjaDisplaySlength$conf.int[2]-corSanjaDisplaySlength$estimate)/-1.96)
seSanjaDisplaySlength <- mean(seSanjaDisplaySlengthLower,seSanjaDisplaySlengthUpper)

}

{# tarsus - Abnormal Sanja

SanjaTarsusAbnOutX <- rnorm(NSanjaTarsusAbnOut,0,1)
SanjaTarsusAbnInX <-rnorm(NSanjaTarsusAbnIn,-0.90,1)	# Bolund
SanjaTarsusAbnallX <- c(SanjaTarsusAbnOutX,SanjaTarsusAbnInX)

SanjaAbnTarsusOutY <- rnorm(NSanjaTarsusAbnOut,0,1)
SanjaAbnTarsusInY <- rnorm(NSanjaTarsusAbnIn,-1.40,1) # Opatova !! reverse !!
SanjaAbnTarsusallY <- c(SanjaAbnTarsusOutY,SanjaAbnTarsusInY)

corSanjaTarsusAbn <- cor.test(SanjaAbnTarsusallY,SanjaTarsusAbnallX) #
seSanjaTarsusAbnLower <- abs((corSanjaTarsusAbn$conf.int[1]-corSanjaTarsusAbn$estimate)/1.96)
seSanjaTarsusAbnUpper <- abs((corSanjaTarsusAbn$conf.int[2]-corSanjaTarsusAbn$estimate)/-1.96)
seSanjaTarsusAbn <- mean(seSanjaTarsusAbnLower,seSanjaTarsusAbnUpper)

}

{# tarsus - velocity Sanja

SanjaTarsusVelocityOutX <- rnorm(NSanjaTarsusVelocityOut,0,1)
SanjaTarsusVelocityInX <-rnorm(NSanjaTarsusVelocityIn,-0.90,1)	# Bolund
SanjaTarsusVelocityallX <- c(SanjaTarsusVelocityOutX,SanjaTarsusVelocityInX)

SanjaVelocityTarsusOutY <- rnorm(NSanjaTarsusVelocityOut,0,1)
SanjaVelocityTarsusInY <- rnorm(NSanjaTarsusVelocityIn,-0.74,1) # Opatova
SanjaVelocityTarsusallY <- c(SanjaVelocityTarsusOutY,SanjaVelocityTarsusInY)

corSanjaTarsusVelocity <- cor.test(SanjaVelocityTarsusallY,SanjaTarsusVelocityallX) #
seSanjaTarsusVelocityLower <- abs((corSanjaTarsusVelocity$conf.int[1]-corSanjaTarsusVelocity$estimate)/1.96)
seSanjaTarsusVelocityUpper <- abs((corSanjaTarsusVelocity$conf.int[2]-corSanjaTarsusVelocity$estimate)/-1.96)
seSanjaTarsusVelocity <- mean(seSanjaTarsusVelocityLower,seSanjaTarsusVelocityUpper)
	
}

{# tarsus - Slength Sanja

SanjaTarsusSlengthOutX <- rnorm(NSanjaTarsusSlengthOut,0,1)
SanjaTarsusSlengthInX <-rnorm(NSanjaTarsusSlengthIn,-0.90,1)	# Bolund
SanjaTarsusSlengthallX <- c(SanjaTarsusSlengthOutX,SanjaTarsusSlengthInX)

SanjaSlengthTarsusOutY <- rnorm(NSanjaTarsusSlengthOut,0,1)
SanjaSlengthTarsusInY <- rnorm(NSanjaTarsusSlengthIn,-0.55,1) # Opatova
SanjaSlengthTarsusallY <- c(SanjaSlengthTarsusOutY,SanjaSlengthTarsusInY)

corSanjaTarsusSlength <- cor.test(SanjaSlengthTarsusallY,SanjaTarsusSlengthallX) #
seSanjaTarsusSlengthLower <- abs((corSanjaTarsusSlength$conf.int[1]-corSanjaTarsusSlength$estimate)/1.96)
seSanjaTarsusSlengthUpper <- abs((corSanjaTarsusSlength$conf.int[2]-corSanjaTarsusSlength$estimate)/-1.96)
seSanjaTarsusSlength <- mean(seSanjaTarsusSlengthLower,seSanjaTarsusSlengthUpper)
	
}


{# beak - Abnormal Johannes
	
JohannesBeakMunselAbnOutX <- rnorm(NJohannesBeakMunselAbnOut,0,1)
JohannesBeakMunselAbnInX <-rnorm(NJohannesBeakMunselAbnIn,-1.04,1)	# Bolund
JohannesBeakMunselAbnallX <- c(JohannesBeakMunselAbnOutX,JohannesBeakMunselAbnInX)

JohannesAbnBeakMunselOutY <- rnorm(NJohannesBeakMunselAbnOut,0,1)
JohannesAbnBeakMunselInY <- rnorm(NJohannesBeakMunselAbnIn,-1.40,1) # Opatova !! reverse !!
JohannesAbnBeakMunselallY <- c(JohannesAbnBeakMunselOutY,JohannesAbnBeakMunselInY)

corJohannesBeakMunselAbn <- cor.test(JohannesAbnBeakMunselallY,JohannesBeakMunselAbnallX) #
seJohannesBeakMunselAbnLower <- abs((corJohannesBeakMunselAbn$conf.int[1]-corJohannesBeakMunselAbn$estimate)/1.96)
seJohannesBeakMunselAbnUpper <- abs((corJohannesBeakMunselAbn$conf.int[2]-corJohannesBeakMunselAbn$estimate)/-1.96)
seJohannesBeakMunselAbn <- mean(seJohannesBeakMunselAbnLower,seJohannesBeakMunselAbnUpper)

}

{# beak - velocity Johannes

JohannesBeakMunselVelocityOutX <- rnorm(NJohannesBeakMunselVelocityOut,0,1)
JohannesBeakMunselVelocityInX <-rnorm(NJohannesBeakMunselVelocityIn,-1.04,1)	# Bolund
JohannesBeakMunselVelocityallX <- c(JohannesBeakMunselVelocityOutX,JohannesBeakMunselVelocityInX)

JohannesVelocityBeakMunselOutY <- rnorm(NJohannesBeakMunselVelocityOut,0,1)
JohannesVelocityBeakMunselInY <- rnorm(NJohannesBeakMunselVelocityIn,-0.74,1) # Opatova
JohannesVelocityBeakMunselallY <- c(JohannesVelocityBeakMunselOutY,JohannesVelocityBeakMunselInY)

corJohannesBeakMunselVelocity <- cor.test(JohannesVelocityBeakMunselallY,JohannesBeakMunselVelocityallX) # 
seJohannesBeakMunselVelocityLower <- abs((corJohannesBeakMunselVelocity$conf.int[1]-corJohannesBeakMunselVelocity$estimate)/1.96)
seJohannesBeakMunselVelocityUpper <- abs((corJohannesBeakMunselVelocity$conf.int[2]-corJohannesBeakMunselVelocity$estimate)/-1.96)
seJohannesBeakMunselVelocity <- mean(seJohannesBeakMunselVelocityLower,seJohannesBeakMunselVelocityUpper)

}

{# beak - Slength Johannes

JohannesBeakMunselSlengthOutX <- rnorm(NJohannesBeakMunselSlengthOut,0,1)
JohannesBeakMunselSlengthInX <-rnorm(NJohannesBeakMunselSlengthIn,-1.04,1)	# Bolund
JohannesBeakMunselSlengthallX <- c(JohannesBeakMunselSlengthOutX,JohannesBeakMunselSlengthInX)

JohannesSlengthBeakMunselOutY <- rnorm(NJohannesBeakMunselSlengthOut,0,1)
JohannesSlengthBeakMunselInY <- rnorm(NJohannesBeakMunselSlengthIn,-0.55,1) # Opatova
JohannesSlengthBeakMunselallY <- c(JohannesSlengthBeakMunselOutY,JohannesSlengthBeakMunselInY)

corJohannesBeakMunselSlength <- cor.test(JohannesSlengthBeakMunselallY,JohannesBeakMunselSlengthallX) # 
seJohannesBeakMunselSlengthLower <- abs((corJohannesBeakMunselSlength$conf.int[1]-corJohannesBeakMunselSlength$estimate)/1.96)
seJohannesBeakMunselSlengthUpper <- abs((corJohannesBeakMunselSlength$conf.int[2]-corJohannesBeakMunselSlength$estimate)/-1.96)
seJohannesBeakMunselSlength <- mean(seJohannesBeakMunselSlengthLower,seJohannesBeakMunselSlengthUpper)


}

{# courtship - Abnormal Johannes

JohannesDisplayAbnOutX <- rnorm(NJohannesDisplayAbnOut,0,1)
JohannesDisplayAbnInX <-rnorm(NJohannesDisplayAbnIn,-1.18,1)	# Bolund
JohannesDisplayAbnallX <- c(JohannesDisplayAbnOutX,JohannesDisplayAbnInX)

JohannesAbnDisplayOutY <- rnorm(NJohannesDisplayAbnOut,0,1)
JohannesAbnDisplayInY <- rnorm(NJohannesDisplayAbnIn,-1.40,1) # Opatova !! reverse !!
JohannesAbnDisplayallY <- c(JohannesAbnDisplayOutY,JohannesAbnDisplayInY)

corJohannesDisplayAbn <- cor.test(JohannesAbnDisplayallY,JohannesDisplayAbnallX) #
seJohannesDisplayAbnLower <- abs((corJohannesDisplayAbn$conf.int[1]-corJohannesDisplayAbn$estimate)/1.96)
seJohannesDisplayAbnUpper <- abs((corJohannesDisplayAbn$conf.int[2]-corJohannesDisplayAbn$estimate)/-1.96)
seJohannesDisplayAbn <- mean(seJohannesDisplayAbnLower,seJohannesDisplayAbnUpper)

}

{# courtship - velocity Johannes

JohannesDisplayVelocityOutX <- rnorm(NJohannesDisplayVelocityOut,0,1)
JohannesDisplayVelocityInX <-rnorm(NJohannesDisplayVelocityIn,-1.18,1)	# Bolund
JohannesDisplayVelocityallX <- c(JohannesDisplayVelocityOutX,JohannesDisplayVelocityInX)

JohannesVelocityDisplayOutY <- rnorm(NJohannesDisplayVelocityOut,0,1)
JohannesVelocityDisplayInY <- rnorm(NJohannesDisplayVelocityIn,-0.74,1) # Opatova
JohannesVelocityDisplayallY <- c(JohannesVelocityDisplayOutY,JohannesVelocityDisplayInY)

corJohannesDisplayVelocity <- cor.test(JohannesVelocityDisplayallY,JohannesDisplayVelocityallX) #
seJohannesDisplayVelocityLower <- abs((corJohannesDisplayVelocity$conf.int[1]-corJohannesDisplayVelocity$estimate)/1.96)
seJohannesDisplayVelocityUpper <- abs((corJohannesDisplayVelocity$conf.int[2]-corJohannesDisplayVelocity$estimate)/-1.96)
seJohannesDisplayVelocity <- mean(seJohannesDisplayVelocityLower,seJohannesDisplayVelocityUpper)

}

{# courtship - Slength Johannes

JohannesDisplaySlengthOutX <- rnorm(NJohannesDisplaySlengthOut,0,1)
JohannesDisplaySlengthInX <-rnorm(NJohannesDisplaySlengthIn,-1.18,1)	# Bolund
JohannesDisplaySlengthallX <- c(JohannesDisplaySlengthOutX,JohannesDisplaySlengthInX)

JohannesSlengthDisplayOutY <- rnorm(NJohannesDisplaySlengthOut,0,1)
JohannesSlengthDisplayInY <- rnorm(NJohannesDisplaySlengthIn,-0.55,1) # Opatova
JohannesSlengthDisplayallY <- c(JohannesSlengthDisplayOutY,JohannesSlengthDisplayInY)

corJohannesDisplaySlength <- cor.test(JohannesSlengthDisplayallY,JohannesDisplaySlengthallX) #
seJohannesDisplaySlengthLower <- abs((corJohannesDisplaySlength$conf.int[1]-corJohannesDisplaySlength$estimate)/1.96)
seJohannesDisplaySlengthUpper <- abs((corJohannesDisplaySlength$conf.int[2]-corJohannesDisplaySlength$estimate)/-1.96)
seJohannesDisplaySlength <- mean(seJohannesDisplaySlengthLower,seJohannesDisplaySlengthUpper)

}

{# tarsus - Abnormal Johannes

JohannesTarsusAbnOutX <- rnorm(NJohannesTarsusAbnOut,0,1)
JohannesTarsusAbnInX <-rnorm(NJohannesTarsusAbnIn,-0.90,1)	# Bolund
JohannesTarsusAbnallX <- c(JohannesTarsusAbnOutX,JohannesTarsusAbnInX)

JohannesAbnTarsusOutY <- rnorm(NJohannesTarsusAbnOut,0,1)
JohannesAbnTarsusInY <- rnorm(NJohannesTarsusAbnIn,-1.40,1) # Opatova !! reverse !!
JohannesAbnTarsusallY <- c(JohannesAbnTarsusOutY,JohannesAbnTarsusInY)

corJohannesTarsusAbn <- cor.test(JohannesAbnTarsusallY,JohannesTarsusAbnallX) #
seJohannesTarsusAbnLower <- abs((corJohannesTarsusAbn$conf.int[1]-corJohannesTarsusAbn$estimate)/1.96)
seJohannesTarsusAbnUpper <- abs((corJohannesTarsusAbn$conf.int[2]-corJohannesTarsusAbn$estimate)/-1.96)
seJohannesTarsusAbn <- mean(seJohannesTarsusAbnLower,seJohannesTarsusAbnUpper)

}

{# tarsus - velocity Johannes

JohannesTarsusVelocityOutX <- rnorm(NJohannesTarsusVelocityOut,0,1)
JohannesTarsusVelocityInX <-rnorm(NJohannesTarsusVelocityIn,-0.90,1)	# Bolund
JohannesTarsusVelocityallX <- c(JohannesTarsusVelocityOutX,JohannesTarsusVelocityInX)

JohannesVelocityTarsusOutY <- rnorm(NJohannesTarsusVelocityOut,0,1)
JohannesVelocityTarsusInY <- rnorm(NJohannesTarsusVelocityIn,-0.74,1) # Opatova
JohannesVelocityTarsusallY <- c(JohannesVelocityTarsusOutY,JohannesVelocityTarsusInY)

corJohannesTarsusVelocity <- cor.test(JohannesVelocityTarsusallY,JohannesTarsusVelocityallX) #
seJohannesTarsusVelocityLower <- abs((corJohannesTarsusVelocity$conf.int[1]-corJohannesTarsusVelocity$estimate)/1.96)
seJohannesTarsusVelocityUpper <- abs((corJohannesTarsusVelocity$conf.int[2]-corJohannesTarsusVelocity$estimate)/-1.96)
seJohannesTarsusVelocity <- mean(seJohannesTarsusVelocityLower,seJohannesTarsusVelocityUpper)
	
}

{# tarsus - Slength Johannes

JohannesTarsusSlengthOutX <- rnorm(NJohannesTarsusSlengthOut,0,1)
JohannesTarsusSlengthInX <-rnorm(NJohannesTarsusSlengthIn,-0.90,1)	# Bolund
JohannesTarsusSlengthallX <- c(JohannesTarsusSlengthOutX,JohannesTarsusSlengthInX)

JohannesSlengthTarsusOutY <- rnorm(NJohannesTarsusSlengthOut,0,1)
JohannesSlengthTarsusInY <- rnorm(NJohannesTarsusSlengthIn,-0.55,1) # Opatova
JohannesSlengthTarsusallY <- c(JohannesSlengthTarsusOutY,JohannesSlengthTarsusInY)

corJohannesTarsusSlength <- cor.test(JohannesSlengthTarsusallY,JohannesTarsusSlengthallX) #
seJohannesTarsusSlengthLower <- abs((corJohannesTarsusSlength$conf.int[1]-corJohannesTarsusSlength$estimate)/1.96)
seJohannesTarsusSlengthUpper <- abs((corJohannesTarsusSlength$conf.int[2]-corJohannesTarsusSlength$estimate)/-1.96)
seJohannesTarsusSlength <- mean(seJohannesTarsusSlengthLower,seJohannesTarsusSlengthUpper)
	
}


metaSimcorr <- c(corSanjaBeakMunselAbn$estimate, corSanjaBeakMunselVelocity$estimate, corSanjaBeakMunselSlength$estimate,
				 corSanjaDisplayAbn$estimate, corSanjaDisplayVelocity$estimate, corSanjaDisplaySlength$estimate,
				 corSanjaTarsusAbn$estimate, corSanjaTarsusVelocity$estimate, corSanjaTarsusSlength$estimate,
				 
				 corJohannesBeakMunselAbn$estimate, corJohannesBeakMunselVelocity$estimate, corJohannesBeakMunselSlength$estimate,
				 corJohannesDisplayAbn$estimate, corJohannesDisplayVelocity$estimate, corJohannesDisplaySlength$estimate,
				 corJohannesTarsusAbn$estimate, corJohannesTarsusVelocity$estimate, corJohannesTarsusSlength$estimate)
				 
metaSimse <- c(seSanjaBeakMunselAbn, seSanjaBeakMunselVelocity, seSanjaBeakMunselSlength,
				 seSanjaDisplayAbn, seSanjaDisplayVelocity, seSanjaDisplaySlength,
				 seSanjaTarsusAbn, seSanjaTarsusVelocity, seSanjaTarsusSlength,
				 
				 seJohannesBeakMunselAbn, seJohannesBeakMunselVelocity, seJohannesBeakMunselSlength,
				 seJohannesDisplayAbn, seJohannesDisplayVelocity, seJohannesDisplaySlength,
				 seJohannesTarsusAbn, seJohannesTarsusVelocity, seJohannesTarsusSlength)

summarymetaSim <- meta.summaries(metaSimcorr, metaSimse, method="random")

rmetaSim <- summarymetaSim$summary
lowermetaSimlist <- summarymetaSim$summary-1.96*summarymetaSim$se
metaSimlist[[j]] <- c(rmetaSim,lowermetaSimlist)


}

bindmetaSimList <- do.call(rbind,metaSimlist)
head(bindmetaSimList)
hist(bindmetaSimList[,1], breaks = 20)
hist(bindmetaSimList[,2], breaks = 20)
min(bindmetaSimList)



}
}


