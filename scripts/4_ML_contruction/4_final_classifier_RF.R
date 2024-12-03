



epigenetics = read.csv("./repeated_k_fold_cross_validation_nearmiss/2_dataproc/EPIGENETICS.csv", header=TRUE, 
                                      row.names = 1)
epigenetics = epigenetics[, -c(269)]
biochemistry = read.csv("./repeated_k_fold_cross_validation_nearmiss/2_dataproc/BIOCHEMISTRY.csv", row.names = 1, 
                      stringsAsFactors = TRUE)

# datos_def2 = cbind(epigenetics[, 1:267], biochemistry)
datos_def2 = merge(epigenetics, biochemistry, by="Code")
row.names(datos_def2) = datos_def2$Code
datos_def2 = datos_def2[, -c(1)]

colnames(datos_def2)[302] = "Class"
datos_def2$Class = as.factor(datos_def2$Class)
datos_def2$Class = factor(datos_def2$Class, levels=c("0","1"), labels=c("No_IR", "Yes_IR"))

datos_def2$Sex_T1 = as.factor(datos_def2$Sex_T1) # 0,1,2
datos_def2$Sex_T1 = factor(datos_def2$Sex_T1, levels=c("Niña_T1", "Varon_T1"), labels(1, 2))
datos_def2$Sex_T1 = as.numeric(datos_def2$Sex_T1)


# UNDERSAMPLING 
library(caret)
library(tidymodels)
library(themis)
set.seed(123456789)
under = recipe(Class ~ ., data=datos_def2) %>%
  step_nearmiss(Class, under_ratio = 1, neighbors = 8, id=row.names(datos_def2))
rec = prep(under, training=datos_def2)
undersampling = as.data.frame(rec$template)
undersampling$Class = factor(undersampling$Class, levels=c("No_IR", "Yes_IR"), labels=c("No_IR", "Yes_IR"))

# save(undersampling, file = "./2022_06_28_BD_modelodef.RData")

# load("./repeated_k_fold_cross_validation_nearmiss/modelos_def/2022_06_28_BD_modelodef.RData")

# 1) rf
# se entrena al algoritmo trainControl y train
set.seed(1234556789) # se fija la semilla
control = trainControl(method="none", returnData=TRUE, classProbs = TRUE, 
                       summaryFunction = twoClassSummary)
parRF = train(Class ~ ., data=undersampling, method="parRF", 
           trControl=control, tuneGrid=NULL,
           metric ="Sens", maximize = TRUE)  


save.image("./2022_06_28_randomforest_parRF_modelodef.RData")




