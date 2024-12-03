

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



bioquimica <- pheno_data[,c("Code","Origen_T1","Sex_T1","Age_T1","BMIz__Orbegozo__T1",names(pheno_data)[c(46:48,50:56,58:63,68:78,93:109)],"HOMA_0_AUG_T2")]

names(bioquimica)[ncol(bioquimica)] <- "IR_CLASS_PUBER"

bioquimica$Code <- gsub("-",".",bioquimica$Code)

rownames(bioquimica) <- bioquimica$Code

names(which(sapply(bioquimica, function(x) sum(is.na(x))) < 5 ))
[1] "Code"                  "Origen_T1"             "Sex_T1"               
 [4] "Age_T1"                "BMIz__Orbegozo__T1"    "SBP_T1"               
 [7] "DBP_T1"                "WC_T1"                 "WC_Height_T1"         
[10] "Glucose__mg_dl__T1"    "Insulin__mU_l__T1"     "QUICKI_T1"            
[13] "HOMA_T1"               "Adipo_Lept_T1"         "CHOL__mg_dl__T1"      
[16] "TAG__mg_dl__T1"        "HDLc__mg_dl__T1"       "LDLc__mg_dl__T1"      
[19] "Urea__mg_dl__T1"       "Creatinine__mg_dl__T1" "Uric_acid__mg_dl__T1" 
[22] "Protein__g_dl__T1"     "Iron__ug_dl__T1"       "Ferritin__ng_ml__T1"  
[25] "GGT_U_l__T1"           "Alkaline_phos_U_l__T1" "Adiponectin__mg_l__T1"
[28] "Resistin__ug_l__T1"    "IL8_ng_l__T1"          "Leptin__ug_l__T1"     
[31] "MCP1_ng_l__T1"         "TNF_ng_l__T1"          "MPO_ug_l__T1"         
[34] "sICAM1__mg_l__T1"      "tPAI1__ug_l__T1"       "IR_CLASS_PUBER" 
     
names(which(sapply(bioquimica, function(x) sum(is.na(x))) == 0 ))
 [1] "Code"                  "Origen_T1"             "Sex_T1"               
 [4] "Age_T1"                "BMIz__Orbegozo__T1"    "Glucose__mg_dl__T1"   
 [7] "Insulin__mU_l__T1"     "HOMA_T1"               "CHOL__mg_dl__T1"      
[10] "TAG__mg_dl__T1"        "Creatinine__mg_dl__T1" "Uric_acid__mg_dl__T1" 
[13] "Protein__g_dl__T1"     "Leptin__ug_l__T1"      "MCP1_ng_l__T1"        
[16] "MPO_ug_l__T1"          "sICAM1__mg_l__T1"      "tPAI1__ug_l__T1"      
[19] "IR_CLASS_PUBER" 

#VARIABLES CATEGORICAS:
$ Origen_T1            : chr  "0" "0" "0" "0" ...
 $ Sex_T1               : chr  "Varon_T1" "Varon_T1" "Niña_T1" "Varon_T1" ...



write.csv2(bioquimica,"/home/augusto/Descargas/ALVARO_ML_PUBMEP/DATASETS/BIOCHEMISTRY_and_CLINICAL_DATASET_raw.csv")











