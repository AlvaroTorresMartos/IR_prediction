## EPIGENETIC + BIOCHEMISTRY 

## IMPORTAR 

epigenetics = read.csv("2_dataproc/EPIGENETICS.csv", header=TRUE, 
                                      row.names = 1)
epigenetics = epigenetics[, -c(269)]
biochemistry = read.csv("2_dataproc/BIOCHEMISTRY.csv", row.names = 1, 
                      stringsAsFactors = TRUE)

# datos_def2 = cbind(epigenetics[, 1:267], biochemistry)
datos_def2 = merge(epigenetics, biochemistry, by="Code")
datos_def2 = datos_def2[, -c(1)]

colnames(datos_def2)[302] = "Class"
datos_def2$Class = as.factor(datos_def2$Class)
datos_def2$Class = factor(datos_def2$Class, levels=c("0","1"), labels=c("No_IR", "Yes_IR"))

datos_def2$Sex_T1 = as.factor(datos_def2$Sex_T1) # 0,1,2
datos_def2$Sex_T1 = factor(datos_def2$Sex_T1, levels=c("Niña_T1", "Varon_T1"), labels(1, 2))
datos_def2$Sex_T1 = as.numeric(datos_def2$Sex_T1)



# subset2 

## CREATE THE FOLDS 


library(caret)
# se crea particiones para una repeated kfold cv (k=5, times=5)
set.seed(12345678)
indices1 = createFolds(datos_def2$Class, k=5, list=TRUE, returnTrain = FALSE)
indices2 = createFolds(datos_def2$Class, k=5, list=TRUE, returnTrain = FALSE)
indices3 = createFolds(datos_def2$Class, k=5, list=TRUE, returnTrain = FALSE)
indices4 = createFolds(datos_def2$Class, k=5, list=TRUE, returnTrain = FALSE)
indices5 = createFolds(datos_def2$Class, k=5, list=TRUE, returnTrain = FALSE)
indices = c(indices1, indices2, indices3, indices4, indices5)


## IMPORT THE CREATED FUNCTIONS 

import::from(ml_functions.R, kfold_caret = rep_kfold_cv_caret, 
             kfold_keel = rep_kfold_cv_keel, 
             metricas, process_NA, summary_table, export_keel, particiones)


# Algoritmos basados en árboles 

## J48 


J48 = kfold_caret(datos = datos_def2, algoritmo = "J48", 
                  indices_kfold = indices, 
                  n_columnaclase = 302, pos="Yes_IR")



# Ensembles 

## Random Forest (parRF)



parRF = kfold_caret(datos = datos_def2, algoritmo = "parRF", 
                    indices_kfold = indices, 
                    n_columnaclase = 302, pos="Yes_IR")







# Paramters default 
# https://xgboost.readthedocs.io/en/latest/parameter.html

# xgbDART (xgBoost)
xgb = expand.grid(nrounds = 100, max_depth = 6, eta = 0.3, rate_drop = 0,
                  skip_drop = 0, colsample_bytree = 1, min_child_weight = 1,
                  subsample = 1, gamma = 0)

xgbDART = kfold_caret(datos = datos_def2, algoritmo = "xgbDART", 
                      indices_kfold = indices, 
                      n_columnaclase = 302, pos="Yes_IR", 
                      parametros = xgb)



# NeuralNetworks

avNNet = kfold_caret(datos = datos_def2, algoritmo = "avNNet", 
                     indices_kfold = indices, 
                     n_columnaclase = 302, pos="Yes_IR")



# resultados test
summary_test = data.frame(t(summary_table(lista = list(J48, parRF,  
                                                       xgbDART,
                                                       avNNet), 
                                          nombres=c("J48","parRF", 
                                                  "xgbDART", 
                                                   "avNNet"), 
                                          opt=TRUE )))
# resultados train

summary_train= data.frame(t(summary_table(lista = list(J48, parRF,  
                                                       xgbDART,
                                                       avNNet), 
                                          nombres=c("J48","parRF", 
                                                  "xgbDART", 
                                                   "avNNet"), 
                                          opt=FALSE )))


## CREATING A EXCEL WITH THE AVERAGE RESULT 


library(openxlsx)
results = createWorkbook()
addWorksheet(results, sheetName = "CV_test")
addWorksheet(results, sheetName = "CV_train")
writeData(results, sheet = "CV_test", summary_test, rowNames = TRUE)
writeData(results, sheet = "CV_train", summary_train, rowNames = TRUE)
saveWorkbook(results,file= "results_EWAS_clinical_data.xlsx", overwrite = TRUE)

save.image("results_EWAS_clinical_data.RData")



