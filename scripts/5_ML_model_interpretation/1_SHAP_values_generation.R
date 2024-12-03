
# DESCARGAR MINICONDA3 Y CONFIGURAR ESTO 

# Could not import shap libary. Try installing python dependencies: reticulate::py_install(c('numpy', 'pandas')).
# Check if the python-tk package is installed

# bash which python 
# /home/usuario/miniconda3/bin/python

# R: usethis::edit_r_profile()
# Sys.setenv(RETICULATE_PYTHON = "/home/usuario/miniconda3/bin/python")

# done 
# shapper::install_shap(envname = "/home/usuario/miniconda3/bin/python")



# our example 
library(randomForest)
load("2022_06_28_randomforest_parRF_modelodef.RData")
load("2022_07_25_undersampling_examples_with_ID.RData")
predict(parRF_finalmodel, undersampling_ID, type = "prob")
library("DALEX")
exp_rf = explain(parRF_finalmodel, data = undersampling_ID[, -c(1, 303)])


library("shapper")
# method	
# an estimation method of SHAP values. Currently the only availible is 'KernelSHAP'.
ive_rf <- shap(exp_rf, new_observation = undersampling_ID[1, -c(1, 303)])
colnames(ive_rf)[301:309]
# [1] "tPAI1__ug_l__T1" "_id_"            "_ylevel_"        "_yhat_"          "_yhat_mean_"     "_vname_"        
# [7] "_attribution_"   "_sign_"          "_label_" 

row.names(undersampling_ID) = undersampling_ID$Code


shap_values = function(model, data, column_names, n_samples=52){
  library("shapper")
  library("DALEX")
  for(i in 1:n_samples){    
    if (i==1){
      i = as.numeric(i)
      explainer = shap(model, new_observation = data[i, ])
      shap_cont = explainer[, 307]
      dataframe = as.data.frame(matrix(shap_cont, 
                                       nrow=1, 301))
      colnames(dataframe) = column_names
    }
    else{
       explainer = shap(model, new_observation = data[i, ])
       shap_cont = explainer[, 307]
       dataframe = rbind(dataframe, shap_cont)
    }
  }
  return(dataframe)
}

shap_values_matrix = shap_values(model = exp_rf, data = undersampling_ID[, -c(1, 303)], 
            column_names = colnames(undersampling_ID[, -c(1, 303)]), n=52)

row.names(shap_values_matrix) = undersampling_ID$Code

write.csv(shap_values_matrix, "./2022_08_07_shap_values_matrix_ids.csv")
undersampling_ID$Class = ifelse(undersampling_ID$Class == "Yes_IR", 1, 0)
write.csv(undersampling_ID, "./2022_08_07_BD.csv")
# TO PYTHON script 

# divide the shap values alberto in Yes_IR and No_IR 

load("./2022_07_27_new_colnames_subsets_by_group_and_undersampling_BD.RData")

# SEPARAR EN YESIR AND NOIR 
shap_values_YesIR = rbind(G4_OBOW_non_IR_to_IR, G5_OBOW_IR_no_change)
shap_values_NoIR = rbind(G1_NW_non_IR_no_change, G2_OBOW_non_IR_no_change, G3_OBOW_IR_to_non_IR)

row.names(shap_values_NoIR) = NULL
row.names(shap_values_YesIR) = NULL

write.csv()

undersampling_YesIR = rbind(undersamplin_ID_G4, undersamplin_ID_G5)
undersampling_NoIR  = rbind(undersamplin_ID_G1, undersamplin_ID_G2, undersamplin_ID_G3)
undersampling_YesIR$Class = ifelse(undersampling_YesIR$Class == "Yes_IR", 1, 0)
undersampling_NoIR$Class = ifelse(undersampling_NoIR$Class == "Yes_IR", 1, 0)

write.csv(shap_values_YesIR, "./2022_08_11_shap_values_matrix_alberto_YesIR.csv")
write.csv(shap_values_NoIR, "./2022_08_11_shap_values_matrix_alberto_NoIR.csv")

write.csv(undersampling_YesIR, "./2022_08_11_BD_YesIR.csv")
write.csv(undersampling_NoIR, "./2022_08_11_BD_NoIR.csv")

# SEPARAMOS POR SEXO 

undersampling_ID_boys = subset(undersampling_ID, Sex == 1)
undersampling_ID_girls = subset(undersampling_ID, Sex == 2)

shap_matrix_boys = shap_matrix[row.names(shap_matrix) %in% row.names(undersampling_ID_boys), ]
shap_matrix_girls = shap_matrix[row.names(shap_matrix) %in% row.names(undersampling_ID_girls), ]

rm(undersamplin_ID_G1)
rm(undersamplin_ID_G2)
rm(undersamplin_ID_G3)
rm(undersamplin_ID_G4)
rm(undersamplin_ID_G5)

rm(G1_NW_non_IR_no_change)
rm(G2_OBOW_non_IR_no_change)
rm(G3_OBOW_IR_to_non_IR)
rm(G4_OBOW_non_IR_to_IR)
rm(G5_OBOW_IR_no_change)



# SEPARAR POR SEXO e IR Status 

undersampling_ID_boys_IR = subset(undersampling_ID_boys, Class == "Yes_IR")
undersampling_ID_boys_nonIR = subset(undersampling_ID_boys, Class == "No_IR")

undersampling_ID_girls_IR = subset(undersampling_ID_girls, Class == "Yes_IR")
undersampling_ID_girls_nonIR = subset(undersampling_ID_girls, Class == "No_IR")


shap_matrix_boys_IR = shap_matrix[row.names(shap_matrix) %in% row.names(undersampling_ID_boys_IR), ]
shap_matrix_boys_nonIR = shap_matrix[row.names(shap_matrix) %in% row.names(undersampling_ID_boys_nonIR), ]

shap_matrix_girls_IR = shap_matrix[row.names(shap_matrix) %in% row.names(undersampling_ID_girls_IR), ]
shap_matrix_girls_nonIR = shap_matrix[row.names(shap_matrix) %in% row.names(undersampling_ID_girls_nonIR), ]

rm(shap_matrix)
rm(undersampling_ID)

save.image("2022_10_18_BD_shap_values_by_sex_and_IRstatus.RData")
