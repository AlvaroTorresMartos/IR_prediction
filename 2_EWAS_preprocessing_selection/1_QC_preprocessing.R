#######################################
## PUBMEP PROJECT --> EWAS ANALYSIS 
#######################################

### INDEX

# 0) WORKING WITH WORKSPACE (.RData) and RMOTE
# 1) Read and import the files with the correct directory path 
# 2) Normalization (preprocess) and quality of control 


### 2.1) Detection p-values --> Barplot 
### 2.2) Preprocess raw, quantile and BMIQ ---> densityplot by Sample Group 
### and probes
### 2.3) Comparaison between different normalization methods (Funnorm, Noob, 
# Illumina, SWAN). 

# 3) PCA and plots 
# 4) Filter of probes and others filters 

# 5) Get the M and Beta Values from Quantile and BMIQ filtered data and export

# 6) Factor analysis about the main covariables 


#### 0) To work with workspace in R and rmote yo should know: 


# rmote::start_rmote()
# http://127.0.0.1:4321


#### 1) Read the raw intensity files into R



## 1.1) Path or directory 

# The working directory
# "/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/TFM_alvaro/ewas_pubmep2"

# You can write it or
setwd("/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/TFM_alvaro/2.2_ewas_pubmep")
setwd("/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/files")

"/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/files/ewas_pubmep.RData"

directory  = "/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/TFM_alvaro/2.2_ewas_pubmep"
# you can get it automatically
directory = getwd() 

# List of files in this directory 
list.files(directory)
# List of files in this directory and lower directories
list.files(directory, recursive=TRUE)

## 1.2) Import the files

# load the minfi package
library(minfi) 

# read.metharray.sheet (minfi) to read an Illumina methylation sample sheet, 
# containing pheno-data information for the samples
targets <- read.metharray.sheet(directory,  
                                pattern="MethylationEPIC_Sample_Sheet_ConcepcionAguilera_ALL_SAMPLES_to_1_1_2020.csv")
dim(targets)
# [1] 240  10


# we can see how is the targets object
targets 
colnames(targets)
#[1] "Sample_Name"   "Sample_Well"   "Sample_Plate"  "Sample_Group" 
#[5] "Pool_ID"       "Sample_Time"   "Sample_Center" "Array"        
#[9] "Slide"         "Basename"      "Group" 

# Group is important to be like a character 
targets$Group = as.character(targets$Sample_Group)

# Now that we have imported the information about the samples and where 
# the data is located, we can read the raw intensity signals into R from the 
# IDAT files using the read.metharray.exp (minfi)
rgset <- read.metharray.exp(targets=targets)
rgset
colnames(rgset)

dim(rgset)
#[1] 1051815     240


#### 2) Quality control, normalization and processing 


## 2.1) Detecting p-values which is representative of quality of samples)
# Loading this package it is required to use detectionP (minfi)
library(IlluminaHumanMethylationEPICmanifest) 
detP <- detectionP(rgset)

dim(detP)
#[1] 866091    240



## 2.2) Plotting theses p-values to check 
# palette of colours
library(RColorBrewer)
pal <- RColorBrewer::brewer.pal(8,"OrRd")



# BARPLOT of p-values, huge p-values indicate poor quality (>0.01)
# if we have less of 0.01 better quality of data 

# Barplot 1 

barplot(colMeans(detP), col=pal[factor(targets$Group)], las=2,
        cex.names=0.01, ylim = c(0,0.02), ylab="Mean detection p-values", 
        cex.lab=0.75,cex.axis=0.75, xlab="Samples",
        main="Barplot detection p-values")
legend("topleft", legend=levels(factor(targets$Group)), fill=pal, 
       bg="white")
abline(h=0.01,col="red")
# Barplot 2 (the same plot but extended)
legend("topleft", legend=levels(factor(targets$Group)), fill=pal, 
       bg="white")
barplot(colMeans(detP), col=pal[factor(targets$Group)], las=2,
        cex.names=0.01, ylim = c(0,0.001), ylab="Mean detection p-values", 
        cex.lab=0.75,cex.axis=0.75, xlab="Samples",
        main="Barplot detection p-values")

## 2,3) The samples with p-values, which are so high, should be removed. 
# In this case, the samples have a great quality. 

# Remove theses samples from rgset, detP and targets

keep <- colMeans(detP) < 0.01 # mean from every column < 0.01
dim(rgset)
#[1] 1051815     240

# 1) rgset 
rgset <- rgset[,keep]
# No lose any sample because everyone has good quality 
dim(rgset) 
#[1] 1051815     240


# 2) detP
detP <- detP[,keep]
dim(detP)
#[1] 866091    240


# 3) targets
targets = targets[keep, ]
dim(targets)
#[1] 240  11



## 2.4) Normalization of the different ways BMIQ and Quantiles 

# 1) raw (minfi) --> 
rgset_raw = preprocessRaw(rgset)
anotation850k = getAnnotation(rgset_raw)
dim(anotation850k)
# [1] 865859     46


# 2) BMIQ (wateRmelon) --> 

# GET EACH TYPE OF PROBES:
manifest <- IlluminaHumanMethylationEPICmanifest

probeTypes <- rbind(data.frame(getProbeInfo(manifest, type = "I")[, c("Name", "nCpG")], Type="I"),
                    data.frame(getProbeInfo(manifest, type = "II")[, c("Name", "nCpG")], Type="II"))
PROBES <- rep(NA, length(rownames(rgset_raw)))
PROBES[rownames(rgset_raw) %in% probeTypes$Name[probeTypes$Type=="I"]] <- 1
PROBES[rownames(rgset_raw) %in% probeTypes$Name[probeTypes$Type=="II"]] <- 2

# BMIQ (wateRmelon)
#rgset_raw2 = fixMethOutliers(rgset_raw, verbose=TRUE) # para cuando haya ejemplos
# con intensidades de metilacion muy muy bajas

#[.fixMethOutliers] for sample 1, fixing 32411 outliers with 2^cutoff=291
#[.fixMethOutliers] for sample 2, fixing 432 outliers with 2^cutoff=79
# .......................................................................
#[.fixMethOutliers] for sample 96, fixing 3008 outliers with 2^cutoff=182

rgset_BMIQ <- wateRmelon::BMIQ(rgset_raw, design.v = PROBES)
dim(rgset_BMIQ)
#[1] 866091    240 --> no cambian las dimensiones con rgset_raw2

# 3) preprocessQuantile (minfi)
# normalize the data; this results in a GenomicRatioSet object

rgset_quantile <- preprocessQuantile(rgset)
#[preprocessQuantile] Mapping to genome.
#[preprocessQuantile] Fixing outliers.
#[preprocessQuantile] Quantile normalizing.

dim(rgset_quantile)
#[1] 865859    240



## COMPARACION CON OTROS MÉTODOS DE NORMALIZACION

# preprocessFunnorm

rgset_funnorm = preprocessFunnorm(rgset)
dim(rgset_funnorm)
#[preprocessFunnorm] Mapping to genome
#[preprocessFunnorm] Quantile extraction
#[preprocessFunnorm] Normalization
#[1] 865859     96


# preprocessIllumina 

rgset_illu = preprocessIllumina(rgset)
dim(rgset_illu)
#[1] 866238     96

# preprocessNoob

rgset_noob = preprocessNoob(rgset)
dim(rgset_noob)
#[1] 866238     96


# preprocessSWAN

rgset_SWAN = preprocessSWAN(rgset, mSet=rgset_raw2)
dim(rgset_SWAN)
#[1] 866238     96

# 2.5) Quality control

# getQC (minfi) and plotQC (minfi) --> pdf outputs 
quality_control = getQC(rgset_raw) 
quality_plot = plotQC(quality_control)

# DENSITY PLOTS by Sample Group
targets$Group <- as.factor(targets$Group)

par(mfrow=c(1,3))
densityPlot(rgset_raw, sampGroups=targets$Group,main="Raw", legend=TRUE) #pal=brewer.pal(8,"OrRd"))
#legend("top", legend = levels(targets$Group))
       #text.col=brewer.pal(8,"OrRd"))
densityPlot(rgset_raw2, sampGroups=targets$Group,main="Raw", legend=TRUE)

densityPlot(getBeta(rgset_quantile), sampGroups=targets$Group,
            main="Quantile Normalized (Touleimat & Tost, 2012)", legend=TRUE)#,pal=brewer.pal(8,"OrRd"))
#legend("top", legend = levels(targets$Group),
       #text.col=brewer.pal(8,"OrRd"))
densityPlot(rgset_BMIQ, sampGroups=targets$Group,
            main="BMIQ Normalized (Teschendorff et al, 2013)", legend=TRUE)#,pal=brewer.pal(8,"OrRd"))
#legend("top", legend = levels(targets$Group),
       #text.col=brewer.pal(8,"OrRd"))




#### COMPARACION

densityPlot(getBeta(rgset_funnorm), sampGroups=targets$Group,
            main="Funnorm method (JP Fortin et al 2014)", legend=TRUE) 
#pal=brewer.pal(8,"OrRd"))
#legend("top", legend = levels(targets$Group))
#text.col=brewer.pal(8,"OrRd"))
densityPlot(getBeta(rgset_illu), sampGroups=targets$Group,
            main="Illumina method", legend=TRUE)

densityPlot(getBeta(rgset_noob), sampGroups=targets$Group,
            main="Noob method (TJ Triche et al 2013)", legend=TRUE)#,pal=brewer.pal(8,"OrRd"))
#legend("top", legend = levels(targets$Group),
#text.col=brewer.pal(8,"OrRd"))
densityPlot(getBeta(rgset_SWAN), sampGroups=targets$Group,
            main="SWAN method (J Maksimovic et al 2012)", legend=TRUE)#,pal=brewer.pal(8,"OrRd"))
#legend("top", legend = levels(targets$Group),
#text.col=brewer.pal(8,"OrRd"))



# DENSITY PLOTS by Probes types

## Type 1 probe 

# Interesting link: 
# https://www.marsja.se/how-to-use-in-in-r/

# raw
betas_raw_1 = rgset_raw[rownames(rgset_raw) %in% probeTypes$Name[probeTypes$Type=="I"]]
dim(betas_raw_1)
#[1] 142181    240


# quantile 
betas_quantile_1 = getBeta(rgset_quantile[rownames(rgset_quantile) %in% probeTypes$Name[probeTypes$Type=="I"],])
dim(betas_quantile_1)
#[1] 142137     240

# BMIQ
betas_BMIQ_1 = rgset_BMIQ
betas_BMIQ_1 <- betas_BMIQ_1[rownames(betas_BMIQ_1) %in% probeTypes$Name[probeTypes$Type=="I"],]
dim(betas_BMIQ_1)
#[1] 142181    240



## Type 2 probe 

# raw
betas_raw_2 = rgset_raw[rownames(rgset_raw) %in% probeTypes$Name[probeTypes$Type=="II"], ]
dim(betas_raw_2)
#[1] 723910    240


# quantile 
betas_quantile_2 = getBeta(rgset_quantile[rownames(rgset_quantile) %in% probeTypes$Name[probeTypes$Type=="II"],])
dim(betas_quantile_2)
#[1] 723722     240

# BMIQ
betas_BMIQ_2 = rgset_BMIQ
betas_BMIQ_2 <- betas_BMIQ_2[rownames(betas_BMIQ_2) %in% probeTypes$Name[probeTypes$Type=="II"],]
dim(betas_BMIQ_2)
#[1] 723910    240


## Histograma de los valores Beta

#pdf("/home/augusto/Descargas/ALL_EPIC_ARRAY_DATA_PUBMEP/PRIMER_ANALISIS/plot_qc/Densityplot_Bvalue_per_sample_TYPE1_and_2_probes_all.pdf", width=50/2.54, height=18/2.54)
par(mfrow=c(2,3))
# type I
densityPlot(betas_raw_1, sampGroups=targets$Group,main="TYPE I Raw", legend=FALSE,pal=brewer.pal(8,"Reds"))
densityPlot(betas_quantile_1, sampGroups=targets$Group,
            main="TYPE I Quantile Normalized (Touleimat & Tost, 2012)", legend=FALSE,pal=brewer.pal(8,"Reds"))
densityPlot(betas_BMIQ_1, sampGroups=targets$Group,
            main="TYPE I BMIQ Normalized (Teschendorff et al, 2013)", legend=FALSE,pal=brewer.pal(8,"Reds"))

# type II 
densityPlot(betas_raw_2, sampGroups=targets$Group,main="TYPE II Raw", legend=FALSE,pal=brewer.pal(8,"Greens"))

densityPlot(betas_quantile_2, sampGroups=targets$Group,
            main="TYPE II Quantile Normalized (Touleimat & Tost, 2012)", legend=FALSE,pal=brewer.pal(8,"Greens"))
densityPlot(betas_BMIQ_2, sampGroups=targets$Group,
            main="TYPE II BMIQ Normalized (Teschendorff et al, 2013)", legend=FALSE,pal=brewer.pal(8,"Greens")) #,ylim=c(0,6)




#### COMPARACION

## Type 1 probe 

# funnorm
betas_funnorm_1 = getBeta(rgset_funnorm[rownames(rgset_funnorm) %in% probeTypes$Name[probeTypes$Type=="I"],])
dim(betas_funnorm_1)
#[1] 142137     96


# illumina
betas_illu_1 = getBeta(rgset_illu[rownames(rgset_illu) %in% probeTypes$Name[probeTypes$Type=="I"],])
dim(betas_illu_1)
#[1] 142162     96


# noob
betas_noob_1 = getBeta(rgset_noob[rownames(rgset_noob) %in% probeTypes$Name[probeTypes$Type=="I"],])
dim(betas_noob_1)
#[1] 142162     96

# SWAN
betas_SWAN_1 = getBeta(rgset_SWAN[rownames(rgset_SWAN) %in% probeTypes$Name[probeTypes$Type=="I"],])
dim(betas_SWAN_1)
#[1] 142162     96

## Type 2 probe 

# funnorm
betas_funnorm_2 = getBeta(rgset_funnorm[rownames(rgset_funnorm) %in% probeTypes$Name[probeTypes$Type=="II"],])
dim(betas_funnorm_1)
#[1] 142137     96


# illumina
betas_illu_2 = getBeta(rgset_illu[rownames(rgset_illu) %in% probeTypes$Name[probeTypes$Type=="II"],])
dim(betas_illu_1)
#[1] 142162     96


# noob
betas_noob_2 = getBeta(rgset_noob[rownames(rgset_noob) %in% probeTypes$Name[probeTypes$Type=="II"],])
dim(betas_noob_1)
#[1] 142162     96

# SWAN
betas_SWAN_2 = getBeta(rgset_SWAN[rownames(rgset_SWAN) %in% probeTypes$Name[probeTypes$Type=="II"],])
dim(betas_SWAN_1)
#[1] 142162     96

## TYPE I 

densityPlot(betas_funnorm_1, sampGroups=targets$Group,
            main="Type I Funnorm method (JP Fortin et al 2014)", legend=TRUE, 
            pal=brewer.pal(8,"Reds")) 
densityPlot(betas_illu_1, sampGroups=targets$Group,
            main="Type I Illumina method", legend=TRUE, 
            pal=brewer.pal(8,"Reds"))

densityPlot(betas_noob_1, sampGroups=targets$Group,
            main="Type I Noob method (TJ Triche et al 2013)", legend=TRUE, 
            pal=brewer.pal(8,"Reds"))

densityPlot(betas_SWAN_1, sampGroups=targets$Group,
            main="Type I SWAN method (J Maksimovic et al 2012)", legend=TRUE, 
            pal=brewer.pal(8,"Reds"))

### TYPE II

densityPlot(betas_funnorm_2, sampGroups=targets$Group,
            main="Type II Funnorm method (JP Fortin et al 2014)", legend=TRUE, 
            pal=brewer.pal(8,"Greens")) 
densityPlot(betas_illu_2, sampGroups=targets$Group,
            main="Type II Illumina method", legend=TRUE, 
            pal=brewer.pal(8,"Greens"))

densityPlot(betas_noob_2, sampGroups=targets$Group,
            main="Type II Noob method (TJ Triche et al 2013)", legend=TRUE, 
            pal=brewer.pal(8,"Greens"))

densityPlot(betas_SWAN_2, sampGroups=targets$Group,
            main="Type II SWAN method (J Maksimovic et al 2012)", legend=TRUE, 
            pal=brewer.pal(8,"Greens"))



### Valores M 

# funnorm
M_funnorm = getM(rgset_funnorm)


# illumina
M_illu = getM(rgset_illu)

# noob
M_noob = getM(rgset_noob)


# SWAN
M_SWAN = getM(rgset_SWAN)


densityPlot(M_funnorm, sampGroups=targets$Group,
            main="Type II Funnorm method (JP Fortin et al 2014)", legend=TRUE) 
densityPlot(M_illu, sampGroups=targets$Group,
            main="Type II Illumina method", legend=TRUE)

densityPlot(M_noob, sampGroups=targets$Group,
            main="Type II Noob method (TJ Triche et al 2013)", legend=TRUE)

densityPlot(M_SWAN, sampGroups=targets$Group,
            main="Type II SWAN method (J Maksimovic et al 2012)", legend=TRUE)



### PCA (Principal Component Analysis) 

# PCA is a multivariate method to analyze  high dimensional data. 
# It is based on linear combination to create new variables which can explain 
# the total variance. New variables are called PCA1, PCA2, etc 
# you choose the number of PCA that you can select. 

## PCA with Quantiles normalization data 
library(limma) # --> plotMDS

# par(mfrow=c(1,3))

colnames(targets)


# PCA by Sample Group 
pal <- brewer.pal(n=6,"Set2")
plotMDS(getM(rgset_quantile), top=1000, gene.selection="common",
        col=pal[factor(targets$Sample_Group)])
legend("top", legend=levels(factor(targets$Sample_Group)), text.col=pal,
       bg="white", cex=0.7,title="Sample Group",title.col="black")

# PCA by Experimental Time 
plotMDS(getM(rgset_quantile), top=1000, gene.selection="common",
        col=pal[factor(targets$Group)])
legend("top", legend=levels(factor(targets$Group)), text.col=pal,
       bg="white", cex=0.7,title="Group",title.col="black")


plotMDS(getM(rgset_quantile), top=1000, gene.selection="common",
        col=pal[factor(targets$Group)])
legend("top", legend=levels(factor(targets$Group)), text.col=pal,
       bg="white", cex=0.7,title="Group",title.col="black")

# explore others PCAs (only We have seen the PCA1 vs PCA2) Sex is the variable
# which can be more interested to study 

pal <- brewer.pal(n=3,"Set2") # 3 colours are the lower number 
plotMDS(getM(rgset_quantile), top=1000, gene.selection="common",
        col=pal[factor(targets$Sex)], dim=c(1,3))
legend("top", legend=levels(factor(targets$Sex)), text.col=pal,
       bg="white", cex=0.7,title="Sex",title.col="black")


plotMDS(getM(rgset_quantile), top=1000, gene.selection="common",
        col=pal[factor(targets$Sex)], dim=c(2,3))
legend("top", legend=levels(factor(targets$Sex)), text.col=pal,
       bg="white", cex=0.7,title="Sex",title.col="black")


## PCA with BMIQ normalization data 
library(limma) # --> plotMDS

# Get the M value from BMIQ data to do PCA 
# getM (minfi) can not be used with rgset_BMIQ, we can use 
# beta2m (lumi)

BMIQ_M =  lumi::beta2m(rgset_BMIQ)



# explore others PCAs (only We have seen the PCA1 vs PCA2) Sex is the variable
# which can be more interested to study 


plotMDS(BMIQ_M, top=1000, gene.selection="common",
        col=pal[factor(targets$Sex)], dim=c(1,3))
legend("top", legend=levels(factor(targets$Sex)), text.col=pal,
       bg="white", cex=0.7,title="Sex",title.col="black")


plotMDS(BMIQ_M, top=1000, gene.selection="common",
        col=pal[factor(targets$Sex)], dim=c(2,3))
legend("top", legend=levels(factor(targets$Sex)), text.col=pal,
       bg="white", cex=0.7,title="Sex",title.col="black")




#### Filter by probes for quantile and BMIQ data 

dim(rgset_quantile)
# [1] 865859     240

### 1 -->> Quantile 
# ensure probes are in the same order in the mSetSq and detP objects
detP <- detP[match(featureNames(rgset_quantile),rownames(detP)),]
# remove any probes that have failed more than 10% of individuals
keep <- rowSums(detP < 0.01) > 0.1*(ncol(rgset_quantile))
table(keep)
# FALSE   TRUE
# 7 865852

# 1) 
quantile_filter <- rgset_quantile[keep,]
dim(quantile_filter)
#[1] 865852    240


# This is important for the BMIQ data 
probes_SNPs <- rownames(quantile_filter)[which(!(rownames(quantile_filter) %in% 
                                                         rownames(dropLociWithSnps(quantile_filter))))]

# 2) remove probes with SNPs at CpG site
# dropLociWithSnps --> minfi 
quantile_filter <- dropLociWithSnps(quantile_filter)

dim(quantile_filter)
#> dim(quantile_filter)
# [1] 835420    240



# exclude cross reactive probes
xReactiveProbes <- read.csv(file="48639-non-specific-probes-Illumina450k.csv"
                            , stringsAsFactors=FALSE, sep="\t") 

#> colnames(xReactiveProbes)
# [1] "TargetID" "X47"      "X48"      "X49"      "X50"

keep <- !(featureNames(quantile_filter) %in% xReactiveProbes$TargetID)
table(keep)
#TRUE 
#835420 

quantile_filter <- quantile_filter[keep,]
dim(quantile_filter)
#[1] 835420    240


table(anotation850k$chr)
#chr1 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19  chr2 chr20 chr21 chr22 
#82013 42126 48894 44623 21040 29550 28741 37939 44435 14899 38550 64828 22960 10300 18367 
#chr3  chr4  chr5  chr6  chr7  chr8  chr9  chrX  chrY 
#48896 36771 44720 54401 47560 38452 26167 19090   537 


# Remove probes on the Y sex chromosome
keep <- !(featureNames(quantile_filter) %in% anotation850k$Name[anotation850k$chr %in%
                                                            c("chrY")])
table(keep)
#FALSE   TRUE 
#537 834883 


quantile_filter <- quantile_filter[keep,]
#> dim(quantile_filter)
#[1] 834851     96


# PCA again 

# PCA1 vs PCA2 
plotMDS(getM(quantile_filter), top=1000, gene.selection="common",
        col=pal[factor(targets$Sex)], dim=c(1,2))
legend("top", legend=levels(factor(targets$Sex)), text.col=pal,
       bg="white", cex=0.7,title="Sex",title.col="black")

# PCA1 vs PCA3 
plotMDS(getM(quantile_filter), top=1000, gene.selection="common",
        col=pal[factor(targets$Sex)], dim=c(1,3))
legend("top", legend=levels(factor(targets$Sex)), text.col=pal,
       bg="white", cex=0.7,title="Sex",title.col="black")


### 2 -->> BMIQ
# detectionP --> IlluminaHumanMethylationEPICmanifest
library("IlluminaHumanMethylationEPICmanifest")
# ensure probes are in the same order in the mSetSq and detP objects
detP <- detP[match(rownames(rgset_BMIQ),rownames(detP)),]
# remove any probes that have failed more than 10% of individuals
keep <- rowSums(detP < 0.01) > 0.1*(ncol(rgset_BMIQ))
table(keep)
# keep
# FALSE   TRUE 
# 7 865852 


# > summary(rownames(detP)[keep])
# Length     Class      Mode 
# 866196 character character 


BMIQ_filter <- rgset_BMIQ[(rownames(rgset_BMIQ) %in% rownames(detP)[keep]),]
dim(BMIQ_filter)
#[1] 865852    240





# remove probes with SNPs at CpG site 
# I have thought to apply: 
# BMIQ_filter <- dropLociWithSnps(BMIQ_filter)
# but I found this error:
# Error in .isGenomicOrStop(object) : 
#  object is of class 'matrixarray', 
#       but needs to be of class 'GenomicMethylSet' or 'GenomicRatioSet'
# dropLociWithSnps only can be applied with a GenomicMethylSet or GenomicRatioSet 

BMIQ_filter <- BMIQ_filter[ !(rownames(BMIQ_filter) %in% probes_SNPs) , ]
dim(BMIQ_filter)
#[1] 834907    240


# exclude cross reactive probes


keep <- !(rownames(BMIQ_filter) %in% xReactiveProbes$TargetID)
table(keep)
#TRUE 
#834907 



BMIQ_filter <- BMIQ_filter[keep,]
dim(BMIQ_filter)
#[1] 834907    240



# Remove probes on the Y sex chromosome
keep <- !(rownames(BMIQ_filter) %in% anotation850k$Name[anotation850k$chr %in%
                                                           c("chrY")])
table(keep)
#FALSE   TRUE 
#536 834371 



BMIQ_filter <- BMIQ_filter[keep,]
dim(BMIQ_filter)
#[1] 834371    240







###### 5) M and Beta values from Quantile and BMIQ filtered data and export

### 1) Quantile 

# calculate Beta and M-values for statistical analysis
quantile_mvals <- getM(quantile_filter)
quantile_bvals <- getBeta(quantile_filter)

# plot 
pal <- RColorBrewer::brewer.pal(8,"Set2")
densityPlot(quantile_bvals, sampGroups=targets$Group, main="Beta values (quantile)",
            legend=FALSE,pal=pal, xlab="Quantile beta values")


densityPlot(quantile_mvals, sampGroups=targets$Group, main="M-values (quantile)",
            legend=FALSE,pal=pal, xlab="Quantile m values")


### 2) BMIQ

# calculate Beta and M-values for statistical analysis

bmiq_mvals <- lumi::beta2m(BMIQ_filter)

bmiq_bvals <- BMIQ_filter


# plot 


densityPlot(bmiq_bvals, sampGroups=targets$Group, main="Beta values (BMIQ)",
            legend=FALSE,pal=pal, xlab="BMIQ beta values")

densityPlot(bmiq_mvals, sampGroups=targets$Group, main="M-values (BMIQ)",
            legend=FALSE,pal=pal, xlab="BMIQ m values")



## 3) Export files in csv 

#"/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/EWAS_ACTIBATE/Concepcion_Aguilera_MethylationEPIC_2021_06 08 2021"


## IMPRESCINDIBLE PARA LOS CÓDIGOS 
Slide_array = paste(targets$Slide, targets$Array)
#Slide_array2 = stringr::str_replace(Slide_array, " ", "_")
Slide_array2 = gsub(" ", "_", Slide_array)

targets = cbind(targets, Slide_array2)

colnames(quantile_bvals) = targets$Sample_Name[targets$Slide_array2 %in% colnames(quantile_bvals)]
colnames(quantile_mvals) = targets$Sample_Name[targets$Slide_array2 %in% colnames(quantile_mvals)]

colnames(bmiq_bvals) = targets$Sample_Name[targets$Slide_array2 %in% colnames(bmiq_bvals)]
colnames(bmiq_mvals) = targets$Sample_Name[targets$Slide_array2 %in% colnames(bmiq_mvals)]

dim(quantile_bvals)
dim(quantile_mvals)
dim(bmiq_bvals)
dim(bmiq_mvals)
# [1] 834371    240
# TODOS --> [1] 809381    240 (con el fix)


## Quantile 

write.csv(quantile_mvals, file="MValues_Quantile.csv", 
          row.names = TRUE)

write.csv(quantile_bvals, file="BValues_Quantile.csv", 
          row.names = TRUE)

## BMIQ 

write.csv(bmiq_mvals, file="MValues_BMIQ_nofix.csv", 
          row.names = TRUE)

write.csv(bmiq_bvals, file="BValues_BMIQ.csv", 
          row.names = TRUE)


setwd("/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/TFM_alvaro/ewas_pubmep2")
setwd("/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/files")




### 6) Factor analysis about the main covariables 

#"FACTOR ANALYSIS SOBRE COVARIABLES PRINCIPALES"

####################################################################################################################################################################################################################################################################################################################

install.packages("swamp")
library(swamp)
library(stringr)
Code = paste(targets$Slide, targets$Array)
Code = str_replace(Code, pattern=" ", replacement = "_")
Code == colnames(quantile_mvals)
#[1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
#[16] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
#[31] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
#[46] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
#[61] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
#[76] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
#[91] TRUE TRUE TRUE TRUE TRUE TRUE
targets = cbind(targets, Code)


targets$Age = as.factor(targets$Age)
targets$Group = as.factor(targets$Group)
targets$Sex = as.factor(targets$Sex)

covariables = targets[, c(2, 4, 5, 6)]
rownames(covariables) = targets$Code

heatmap = prince(as.matrix(quantile_mvals[, which(colnames(quantile_mvals)  %in% targets$Code)]),
                 covariables, top = 10, imputeknn = T, center = T, permute = F)

prince.plot(heatmap, note=T, Rsquared=T, cexRow=0.6)



