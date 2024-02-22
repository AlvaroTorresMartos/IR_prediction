

## Cargamos datos de las bases de datos

BdWide <- read.csv2("/home/augusto/Escritorio/BBDD_PUBMEP/BBDD_PubmeP_RESULTADO/BASES_METILACION/BASE_PUBMEP_LONGI_WIDEformat_NIÑAS_Y_NIÑOS_213inds_19_04_2021_EPIC.csv", header=TRUE, sep=";", stringsAsFactors=F, dec=",", na.strings=c(""," ","NaN","NA")) 


lista90inds <- read.csv2("/home/augusto/Descargas/RESUMEN_RESULTS_EPIGENETICA_2021/2021/LISTAS_OMICAS/lista_LONGI_epicarray.csv", header=TRUE, sep=",", stringsAsFactors=F, dec=",", na.strings=c(""," ","NaN","NA")) #Datos input en formato wide

lista90inds[,2]


pheno_data  <- BdWide[which(BdWide$Code_new_T2 %in% lista90inds[,2]),]
pheno_data  <- pheno_data[order(pheno_data$Code_new_T2),]
pheno_data$Code
rownames(pheno_data) <- pheno_data$Code
rownames(pheno_data) <- paste("sample_",rownames(pheno_data),sep="")
pheno_data$ids <- rownames(pheno_data)
dim(pheno_data)
pheno_data <- pheno_data[,c(3949,1:3948)]
pheno_data
#pheno_data$Cole_T2[which(pheno_data$Cole_T2 == "Obeso_T2")] <- "Sobrepeso_T2"
class(pheno_data$Cole_T2)
pheno_data$Cole_T2 <- as.character(pheno_data$Cole_T2)
pheno_data$Sex_T2 <- as.character(pheno_data$Sex_T2)
pheno_data$Origen_T1 <- as.character(pheno_data$Origen_T1)



# Carga de datos de Epigenetica:

library(IlluminaHumanMethylationEPICanno.ilm10b4.hg19) #Specific for the 850k

mVals_BMIQ <- read.csv2("/home/augusto/Descargas/ALL_EPIC_ARRAY_DATA_PUBMEP/PRIMER_ANALISIS/BASES_DATOS_METILACION_GENERADAS_PREPROCESADAS/mVals_BMIQ_NEW.csv", header=TRUE, sep=";", stringsAsFactors=F, dec=",", na.strings=c(""," ","NaN","NA"),row.names=1)

ann850k = getAnnotation(IlluminaHumanMethylationEPICanno.ilm10b4.hg19)
head(ann850k)
dim(ann850k)

ann850k = ann850k[rownames(mVals_BMIQ),]

EPIGENETICA_Array <- mVals_BMIQ[rownames(ann850k),gsub("-",".",pheno_data$Code)]

table(rownames(ann850k) == rownames(EPIGENETICA_Array))

lista_validacion <- read.csv2("/home/augusto/Descargas/RESUMEN_RESULTS_EPIGENETICA_2021/2021/VALIDACION_LISTA_2021/LISTA1.csv", header=T, sep=";", stringsAsFactors=F, dec=",", na.strings=c(""," ","NaN","NA"))

lista_validacion <- lista_validacion[,2:7]
lista_validacion[,2]

table(unique(lista_validacion[,1]) %in% rownames(EPIGENETICA_Array))


VALIDACION_EPIGENETICA_Array_MatrixEQTL <- EPIGENETICA_Array[unique(lista_validacion[,1]),]

dim(VALIDACION_EPIGENETICA_Array_MatrixEQTL)

colnames(VALIDACION_EPIGENETICA_Array_MatrixEQTL) == gsub("-",".",pheno_data$Code)

VALIDACION_EPIGENETICA_Array_MatrixEQTL[nrow(VALIDACION_EPIGENETICA_Array_MatrixEQTL)+1,] <- pheno_data$HOMA_0_AUG_T2

rownames(VALIDACION_EPIGENETICA_Array_MatrixEQTL)[nrow(VALIDACION_EPIGENETICA_Array_MatrixEQTL)+1] <- "IR_CLASS_PUBER"


write.csv2(VALIDACION_EPIGENETICA_Array_MatrixEQTL,"/home/augusto/Descargas/ALVARO_ML_PUBMEP/DATASETS/EPIGENETICS_DATASET_mvalues.csv")


ann850k_final = ann850k[rownames(VALIDACION_EPIGENETICA_Array_MatrixEQTL)[-nrow(VALIDACION_EPIGENETICA_Array_MatrixEQTL)],]

dim(ann850k_final)


write.csv2(ann850k_final,"/home/augusto/Descargas/ALVARO_ML_PUBMEP/DATASETS/EPIGENETICS_DATASET_ANNOT.csv")





