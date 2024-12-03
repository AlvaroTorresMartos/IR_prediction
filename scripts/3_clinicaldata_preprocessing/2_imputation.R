

# GENETIC DATA 
genetic = read.csv("GENETICS.csv", header=TRUE, row.names = 1)
# NAs totales 
sum(is.na(genetic))
# se puede observar su procedencia (cuando son pocos)
apply(is.na(genetic), MARGIN=2, FUN=which)



# EPIGENETIC DATA 
epigenetic = as.data.frame(t(read.csv("EPIGENETICS.csv", header=TRUE, 
                                       row.names = 1)))
# NAs totales (PERFECT)
sum(is.na(epigenetic))



# BIOCHEMISTRY DATA 
biochemistry = read.csv("BIOCHEMISTRY.csv", header=TRUE, row.names = 2)
biochemistry = biochemistry[-c(1)]
# NAs totales 
sum(is.na(biochemistry))
# Como hay muchos NAs se observará la distribución de estos por las variables
library(naniar)
library(ggplot2)
# Distribucion de los NAS por las distintas columnas y filas
vis_miss(biochemistry)
# Ver NAs por variables 
gg_miss_var(biochemistry) + labs(y = "Look at all the missing ones")
# este grafico te dice los NAs coincidentes 
#gg_miss_upset(biochemistry, nsets=15)


# https://cran.r-project.org/web/packages/naniar/vignettes/naniar-visualisation.html


biochemistry_IR = biochemistry[biochemistry$IR_CLASS_PUBER==1, ]
vis_miss(biochemistry_IR)
# Ver NAs por variables 
gg_miss_var(biochemistry_IR) + labs(y = "Look at all the missing ones")








library(tidyverse)
variables_missing_IR = map(biochemistry_IR, ~sum(is.na(.)))
variables_missing_IR



# dataframes de valores pérdidos por variable
missing_var = as.data.frame(variables_missing_IR)
# variables a quitar (+=5 missing values by column) 
quit = which(missing_var[1, ]>=5) 
# quitamos esas columnas
no_missing = missing_var[, -c(quit)]
# nos quedamos con los nombres de las columnas que pasan el filtro
variables_def = colnames(no_missing)



# dataframe con las variables def 
biochemistry2 = biochemistry[, variables_def]
variables_missing2 = map(biochemistry2, ~sum(is.na(.)))
missing_var2 = as.data.frame(variables_missing2)
# variables que no afectan a la clase minoritaria y tienen 
# pocos valores pérdidos
pander::pander(variables_missing2)

vis_miss(biochemistry2)
# Ver NAs por variables 
gg_miss_var(biochemistry2) + labs(y = "Look at all the missing ones")



# variables a quitar (+=10 missing values by column) 
quit2 = which(missing_var2[1, ]>=10) 
# quitamos esas columnas
no_missing2 = missing_var2[, -c(quit2)]
# nos quedamos con los nombres de las columnas que pasan el filtro
variables_def2 = colnames(no_missing2)




# variables definitivas 
biochemistry3 = biochemistry2[, variables_def2]
# Gráficos
vis_miss(biochemistry3)
# Ver NAs por variables 
gg_miss_var(biochemistry3) + labs(y = "Look at all the missing ones")





library(recipes)
library(tidymodels)
biochemistry3$IR_CLASS_PUBER = as.factor(biochemistry3$IR_CLASS_PUBER)
biochemistry3$Sex_T1 = as.factor(biochemistry3$Sex_T1)
biochemistry3$Origen_T1 = as.factor(biochemistry3$Origen_T1)
rec = recipe(IR_CLASS_PUBER ~ . , data=biochemistry3)




# mediana 
median = rec %>% step_impute_median(all_numeric_predictors())
median2 = prep(median)
median3 = bake(median2, biochemistry3)




# knn 
knn = rec %>% step_impute_knn(all_numeric_predictors())
knn2 = prep(knn)
knn3 = bake(knn2, biochemistry3)



# bagged trees
bag = rec %>% step_impute_bag(all_numeric_predictors())
bag2 = prep(bag)
bag3 = bake(bag2, biochemistry3)



# EL MEJOR MÉTODO PARA IMPUTAR DE FORMA SENCILLA
set.seed(12345)
library(missForest)
forest = missForest(biochemistry3)
biochemistrydef = forest$ximp







# SBP
library(ggplot2)
library(patchwork)
uno = ggplot(biochemistry3, aes(y=SBP_T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="Raw")
dos = ggplot(biochemistrydef, aes(y=SBP_T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="missForest")
(uno | dos)



# DBP
library(ggplot2)
library(patchwork)
uno = ggplot(biochemistry3, aes(y=DBP_T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="Raw")
dos = ggplot(biochemistrydef, aes(y=DBP_T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="missForest")
(uno | dos)



# WC
library(ggplot2)
library(patchwork)
uno = ggplot(biochemistry3, aes(y=WC_T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="Raw")
dos = ggplot(biochemistrydef, aes(y=WC_T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="missForest")
(uno | dos)



# WC
library(ggplot2)
library(patchwork)
uno = ggplot(biochemistry3, aes(y=WC_Height_T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="Raw")
dos = ggplot(biochemistrydef, aes(y=WC_Height_T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="missForest")
(uno | dos)




# Urea
library(ggplot2)
library(patchwork)
uno = ggplot(biochemistry3, aes(y=biochemistry3$Urea__mg_dl__T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="Raw")
dos = ggplot(biochemistrydef, aes(y=biochemistrydef$Urea__mg_dl__T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="missForest")
(uno | dos)




# LDL
library(ggplot2)
library(patchwork)
uno = ggplot(biochemistry3, aes(y=biochemistry3$LDLc__mg_dl__T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="Raw")
dos = ggplot(biochemistrydef, aes(y=biochemistrydef$LDLc__mg_dl__T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="missForest")
(uno | dos)




# HDL
library(ggplot2)
library(patchwork)
uno = ggplot(biochemistry3, aes(y=biochemistry3$HDLc__mg_dl__T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="Raw")
dos = ggplot(biochemistrydef, aes(y=biochemistrydef$HDLc__mg_dl__T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="missForest")
(uno | dos)



# Urea
library(ggplot2)
library(patchwork)
uno = ggplot(biochemistry3, aes(y=biochemistry3$Iron__ug_dl__T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="Raw")
dos = ggplot(biochemistrydef, aes(y=biochemistrydef$Iron__ug_dl__T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="missForest")
(uno | dos)


# fosfatasa alcalina
library(ggplot2)
library(patchwork)
uno = ggplot(biochemistry3, aes(y=biochemistry3$Alkaline_phos_U_l__T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="Raw")
dos = ggplot(biochemistrydef, aes(y=biochemistrydef$Alkaline_phos_U_l__T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="missForest")
(uno | dos)




# Urea
library(ggplot2)
library(patchwork)
uno = ggplot(biochemistry3, aes(y=biochemistry3$Adipo_Lept_T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="Raw")
dos = ggplot(biochemistrydef, aes(y=biochemistrydef$Adipo_Lept_T1, color=IR_CLASS_PUBER)) + geom_boxplot() + ggtitle(label="missForest")
(uno | dos)





colnames(epigenetic)[268] = "IR_CLASS_PUBER"
write.csv(epigenetic, "2_dataframes_definitives/EPIGENETICS.csv")
write.csv(biochemistrydef, "2_dataframes_definitives/BIOCHEMISTRY.csv")





