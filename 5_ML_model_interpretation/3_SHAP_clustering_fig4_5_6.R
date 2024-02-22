
# HEATMAP 1 con todos los ejemplos entrenados -----
library(dplyr)



pubmep = read.csv2("/home/usuario/Escritorio/CIBM/BASES_IBEROMICS/OMICS/OMICS_BD/genobox_pubmep/BASE_PUBMEP_LONGI_WIDEformat_NIÑAS_Y_NIÑOS_213inds_31_01_2022_EPIC.csv")

pubmep2 = pubmep  %>%
  dplyr::mutate(Grupos_interes = dplyr::coalesce(GRUPOS_exp_interes_NIÑAS, GRUPOS_exp_interes_NIÑOS)) %>%
  dplyr::select(Code, BMIz__Orbegozo__T1, BMIz__Orbegozo__T2, HOMA_T1, HOMA_IR_T2,
                Grupos_interes, Cole_T1, Sex_T1, Origen_T1, HOMA_0_AUG_T2
                )



shap = read.csv("./2022_09_26_shap_matrix_colnames.csv")
shap$X = gsub("_", "-", shap$X)
codes = shap$X

pubmep3 = pubmep2[pubmep2$Code %in% codes, ]


pubmep3$Grupos_interes = gsub("NIÑO_", "", pubmep3$Grupos_interes)
pubmep3$Grupos_interes = gsub("NIÑA_", "", pubmep3$Grupos_interes)

pubmep3 = pubmep3 %>% dplyr::select(Code, HOMA_0_AUG_T2)
shap = shap %>% #merge(data, by = "X") %>% 
  merge(pubmep3, by.x = "X", by.y = "Code") %>% 
  tibble::column_to_rownames(var = "X")




shap = shap %>% dplyr::select(cg11762807_HDAC4, cg04976245_PTPRN2, 
                              cg07792979_MATN2, cg27147114_RASGRF1, 
                              Adiponectin_leptin_ratio, cg03516256_EBF1, 
                              cg19194924, BMI_zscore, 
                              cg10987850_HMCN1,
                              cg02818143_PTPRN2, cg16486501_PTPRN2, 
                              Iron_.ug.dl. , 
                              Leptin_.ug.l., 
                              cg14299905_MAP4, 
                              Blood_proteins_.g.dl.,
                              302
                              )



annot = shap %>% dplyr::select(16) %>% 
  dplyr::rename(IR_status = HOMA_0_AUG_T2 
                ) %>% 
  dplyr::mutate(IR_status = factor(IR_status, levels = c(0, 1), labels = c("noIR", "IR")),
                IR_prediction = IR_status
                
                ) 


colnames(shap)[5] = "Leptin_adiponectin_ratio"

row.names(shap) = paste("Child", seq(1, 52), sep = "_")
row.names(annot) = paste("Child", seq(1, 52), sep = "_")



library(RColorBrewer)
# par(mar=c(3,4,2,2))
# display.brewer.all()
col <- colorRampPalette(rev(RColorBrewer::brewer.pal(n = 10, name = "Spectral")))(100)
ann_colors = list(
  Pubertal_status = c(noIR = "#B7D78E", IR = "#A94646"),
  Pubertal_prediction = c(noIR = "#2e90e0", IR =  "#fc1c60")
)
annot = annot %>% dplyr::relocate(IR_prediction, .before = IR_status) %>% 
  dplyr::rename(Pubertal_status = IR_status, 
                Pubertal_prediction = IR_prediction
                )
pheatmap::pheatmap(shap[, 1:15],  
         main = "", annotation_row = annot, 
         annotation_colors = ann_colors,
         color = col, cutree_rows = 4, cutree_cols = 4)




# HEATMAP 2 con los ejemplos del undersampling -----

predicted = readRDS("/home/usuario/Escritorio/Master/TFM_2/2024_01_15_predicted_Class.RDS")
undersampling = readRDS("./shap_matrix_samples_eliminados_downsampling.Rds") %>% 
  tibble::rownames_to_column(var = "X")
shap = read.csv("./2022_09_26_shap_matrix_colnames.csv")

colnames(undersampling) = colnames(shap)
rm(shap)

pubmep = read.csv2("/home/usuario/Escritorio/CIBM/BASES_IBEROMICS/OMICS/OMICS_BD/genobox_pubmep/BASE_PUBMEP_LONGI_WIDEformat_NIÑAS_Y_NIÑOS_213inds_31_01_2022_EPIC.csv")

pubmep2 = pubmep  %>%
  dplyr::mutate(Grupos_interes = dplyr::coalesce(GRUPOS_exp_interes_NIÑAS, GRUPOS_exp_interes_NIÑOS)) %>%
  dplyr::select(Code, BMIz__Orbegozo__T1, BMIz__Orbegozo__T2, HOMA_T1, HOMA_IR_T2,
                Grupos_interes, Cole_T1, Sex_T1, Origen_T1, HOMA_0_AUG_T2
  )

shap = merge(undersampling, predicted, by = "X")
shap$X = gsub("_", "-", shap$X)
codes = shap$X

pubmep3 = pubmep2[pubmep2$Code %in% codes, ]


pubmep3$Grupos_interes = gsub("NIÑO_", "", pubmep3$Grupos_interes)
pubmep3$Grupos_interes = gsub("NIÑA_", "", pubmep3$Grupos_interes)



shap = shap %>% #merge(data, by = "X") %>% 
  merge(pubmep3, by.x = "X", by.y = "Code") %>% 
  tibble::column_to_rownames(var = "X")

# write.csv(shap[, 1:301], "./2024_01_15_shap_values_examples_excluided_by_undersampling.csv")

shap = shap %>% dplyr::select(cg11762807_HDAC4, cg04976245_PTPRN2, 
                              cg07792979_MATN2, cg27147114_RASGRF1, 
                              Adiponectin_leptin_ratio, cg03516256_EBF1, 
                              cg19194924, BMI_zscore, 
                              cg10987850_HMCN1,
                              cg02818143_PTPRN2, cg16486501_PTPRN2, 
                              Iron_.ug.dl. , 
                              Leptin_.ug.l., 
                              cg14299905_MAP4, 
                              Blood_proteins_.g.dl.,
                              302:303
)



annot = shap %>% dplyr::select(16:17) %>% 
  dplyr::rename(IR_status = HOMA_0_AUG_T2, 
                IR_prediction = Predicted
  ) %>% 
  dplyr::mutate(IR_status = factor(IR_status, levels = c(0, 1), labels = c("noIR", "IR")),
                IR_prediction = factor(IR_prediction, levels = c("No_IR", "Yes_IR"), labels = c("noIR", "IR"))
  )



colnames(shap)[5] = "Leptin_adiponectin_ratio"

row.names(shap) = paste("Child", seq(53, 90), sep = "_")
row.names(annot) = paste("Child", seq(53, 90), sep = "_")

library(RColorBrewer)


col <- colorRampPalette(rev(RColorBrewer::brewer.pal(n = 10, name = "Spectral")))(100)
ann_colors = list(
  Pubertal_status = c(noIR = "#B7D78E", IR = "#A94646"),
  Pubertal_prediction = c(noIR = "#2e90e0", IR =  "#fc1c60")
)
annot = annot %>% dplyr::relocate(IR_prediction, .before = IR_status) %>% 
  dplyr::rename(Pubertal_status = IR_status, 
                Pubertal_prediction = IR_prediction
  )
pheatmap::pheatmap(shap[, 1:15],  
                   main = "", annotation_row = annot, 
                   annotation_colors = ann_colors,
                   color = col, cutree_rows = 3, cutree_cols = 3)

# Plots with HOMA-IR and BMI z-scores -----
library(dplyr)
predicted = readRDS("/home/usuario/Escritorio/Master/TFM_2/2024_01_15_predicted_Class.RDS")
undersampling = readRDS("./shap_matrix_samples_eliminados_downsampling.Rds") %>% 
  tibble::rownames_to_column(var = "X")

predicted = predicted %>% 
  dplyr::filter(X %in% undersampling$X) %>% 
  dplyr::mutate(X = gsub("_", "-", X))
  
rm(undersampling)

pubmep = read.csv2("/home/usuario/Escritorio/CIBM/BASES_IBEROMICS/OMICS/OMICS_BD/genobox_pubmep/BASE_PUBMEP_LONGI_WIDEformat_NIÑAS_Y_NIÑOS_213inds_31_01_2022_EPIC.csv")

pubmep2 = pubmep  %>%
  merge(predicted, by.x = "Code", by.y = "X") %>% 
  dplyr::mutate(Grupos_interes = dplyr::coalesce(GRUPOS_exp_interes_NIÑAS, GRUPOS_exp_interes_NIÑOS)) %>%
  dplyr::select(Code, Sex_T1, Age_T1, Age_T2, 
                BMIz__Orbegozo__T1, BMIz__Orbegozo__T2, 
                HOMA_T1, HOMA_IR_T2, HDLc__mg_dl__T1, HDLc_mgdl_T2, 
                Insulin__mU_l__T1, Insulin_mUl_T2, #pubmep$
                Adipo_Lept_T1, Adiponectin__mg_l__T1, Adiponectin__mg_l__T2, 
                Leptin__ug_l__T1, Leptin__ug_l__T2,
                Grupos_interes, Cole_T1, Origen_T1, HOMA_0_AUG_T2, Predicted
  ) %>% 
  mutate(Leptin_adiponectin_T1 = Leptin__ug_l__T1/Adiponectin__mg_l__T1, 
         Leptin_adiponectin_T2 = Leptin__ug_l__T2/Adiponectin__mg_l__T2, 
         Predicted = ifelse(Predicted == "No_IR", "Non-IR", "IR"), 
         Predicted = factor(Predicted, levels = c("Non-IR", "IR"))
         )





library(ggplot2)
library(ggrain)
library(patchwork)
library(ggpubr)



a = ggplot(pubmep2, aes(x = Predicted , y = BMIz__Orbegozo__T1,  fill = Predicted)) +
  geom_hline(yintercept=3.564, linetype="dashed", color = "#fc1c60", alpha = 0.8) +
  geom_hline(yintercept=0.3056, linetype="dashed", color = "#2e90e0", alpha = 0.8) +
  geom_violin(trim = FALSE, alpha = 0.1) + 
  geom_boxplot(width=0.1) + 
  geom_jitter(shape=16, position=position_jitter(0.1)) + 
  labs( x = "Pubertal prediction", y=  "Prepubertal BMI z-score") + 
  theme_minimal() + theme(legend.position = "none") + 
  scale_y_continuous(limits = c(-2, 6)) + 
  scale_fill_manual(values = c( "#85bef1", "#ff7da5")) + 
  coord_flip() 

b = ggplot(pubmep2, aes(x = Predicted , y = BMIz__Orbegozo__T2,  fill = Predicted)) + 
  geom_hline(yintercept=2.3152, linetype="dashed", color = "#fc1c60",  alpha = 0.8) +
  geom_hline(yintercept=0.5329, linetype="dashed", color = "#2e90e0", alpha = 0.8) +
  geom_violin(trim = FALSE, alpha = 0.1) + 
  geom_boxplot(width=0.1) + 
  geom_jitter(shape=16, position=position_jitter(0.1)) + 
  labs( x = "Pubertal prediction", y=  "Pubertal BMI z-score") + 
  theme_minimal() + theme(legend.position = "none") + 
  scale_y_continuous(limits = c(-2, 6)) + 
  scale_fill_manual(values = c( "#85bef1", "#ff7da5")) + 
  coord_flip() 
  
  
  
patchwork = a/b
patchwork + plot_annotation(tag_levels = 'A')


a = ggplot(pubmep2, aes(x = Predicted , y = Leptin_adiponectin_T1,  fill = Predicted)) + 
  geom_rain() + labs( x = "Pubertal prediction", y=  "Prepubertal Leptin/Adiponectin ratio") + 
  theme_minimal() + theme(legend.position = "none") + 
  scale_y_continuous(limits = c(0, 7)) + 
  scale_fill_manual(values = c( "#2e90e0", "#fc1c60")) + 
  geom_hline(yintercept=1.0439, linetype="dashed", color = "#fc1c60") +
  geom_hline(yintercept=0.39388, linetype="dashed", color = "#2e90e0") +
  coord_flip() 


b = ggplot(pubmep2, aes(x = Predicted , y = Leptin_adiponectin_T2,  fill = Predicted)) + 
  geom_rain() + labs( x = "Pubertal prediction", y=  "Pubertal Leptin/Adiponectin ratio") + 
  theme_minimal() + theme(legend.position = "none") + 
  scale_y_continuous(limits = c(0, 7)) + 
  scale_fill_manual(values = c( "#2e90e0", "#fc1c60")) + 
  geom_hline(yintercept=0.8123, linetype="dashed", color = "#fc1c60") +
  geom_hline(yintercept=0.59464, linetype="dashed", color = "#2e90e0") +
  coord_flip() 


patchwork = a/b
patchwork + plot_annotation(tag_levels = 'A')


a = ggplot(pubmep2, aes(x = Predicted , y = HOMA_T1,  fill = Predicted)) + 
  geom_rain() + labs( x = "Pubertal prediction", y=  "Prepubertal HOMA-IR index") + 
  theme_minimal() + theme(legend.position = "none") + 
  scale_y_continuous(limits = c(0, 8)) + 
  scale_fill_manual(values = c( "#2e90e0", "#fc1c60")) + 
  geom_hline(yintercept=1.06, linetype="dashed", color = "#fc1c60") +
  geom_hline(yintercept=0.95, linetype="dashed", color = "#2e90e0") +
  coord_flip() 



b = ggplot(pubmep2, aes(x = Predicted , y = HOMA_IR_T2,  fill = Predicted)) + 
  geom_rain() + labs( x = "Pubertal prediction", y=  "Pubertal HOMA-IR index") + 
  theme_minimal() + theme(legend.position = "none") + 
  scale_y_continuous(limits = c(0, 8)) + 
  scale_fill_manual(values = c( "#2e90e0", "#fc1c60")) + 
  geom_hline(yintercept=2.47, linetype="dashed", color = "#fc1c60") +
  geom_hline(yintercept=1.97, linetype="dashed", color = "#2e90e0") +
  coord_flip() 


patchwork = a/b
patchwork + plot_annotation(tag_levels = 'A')

a = ggplot(pubmep2, aes(x = Predicted , y = Leptin__ug_l__T1,  fill = Predicted)) + 
  geom_rain() + labs( x = "Pubertal prediction", y=  "Prepubertal levels of leptin (ug/L)") + 
  theme_minimal() + theme(legend.position = "none") + 
  scale_y_continuous(limits = c(0, 80)) + 
  scale_fill_manual(values = c( "#2e90e0", "#fc1c60")) + 
  geom_hline(yintercept=17.34, linetype="dashed", color = "#fc1c60") +
  geom_hline(yintercept=4.210, linetype="dashed", color = "#2e90e0") +
  coord_flip() 




b = ggplot(pubmep2, aes(x = Predicted , y = Leptin__ug_l__T2,  fill = Predicted)) + 
  geom_rain() + labs( x = "Pubertal prediction", y=  "Pubertal levels of leptin (ug/L)") + 
  theme_minimal() + theme(legend.position = "none") + 
  scale_y_continuous(limits = c(0, 80)) + 
  scale_fill_manual(values = c( "#2e90e0", "#fc1c60")) + 
  geom_hline(yintercept=14.12, linetype="dashed", color = "#fc1c60") +
  geom_hline(yintercept=5.61, linetype="dashed", color = "#2e90e0") +
  coord_flip() 


patchwork = a/b
patchwork + plot_annotation(tag_levels = 'A')

patchwork = a/b
patchwork + plot_annotation(tag_levels = 'A')

a = ggplot(pubmep2, aes(x = Predicted , y = Insulin__mU_l__T1,  fill = Predicted)) + 
  geom_rain() + labs( x = "Pubertal prediction", y=  "Prepubertal levels of insulin (uU/L)") + 
  theme_minimal() + #theme(legend.position = "none") + 
  scale_y_continuous(limits = c(0, 30)) + 
  scale_fill_manual(values = c( "#2e90e0", "#fc1c60")) + 
  geom_hline(yintercept=1.06, linetype="dashed", color = "#fc1c60") +
  geom_hline(yintercept=0.95, linetype="dashed", color = "#2e90e0") +
  coord_flip() 



b = ggplot(pubmep2, aes(x = Predicted , y = Insulin_mUl_T2,  fill = Predicted)) + 
  geom_rain() + labs( x = "Pubertal prediction", y=  "Pubertal levels of insulin (uU/L)") + 
  theme_minimal() + theme(legend.position = "none") + 
  scale_y_continuous(limits = c(0, 30)) + 
  scale_fill_manual(values = c( "#2e90e0", "#fc1c60")) + 
  geom_hline(yintercept=2.47, linetype="dashed", color = "#fc1c60") +
  geom_hline(yintercept=1.97, linetype="dashed", color = "#2e90e0") +
  coord_flip() 


patchwork = a/b
patchwork + plot_annotation(tag_levels = 'A')

a = ggplot(pubmep2, aes(x = Predicted , y = HDLc__mg_dl__T1,  fill = Predicted)) + 
  geom_rain() + labs( x = "Pubertal prediction", y=  "Prepubertal levels of HDL (mg/dL)") + 
  theme_minimal() + theme(legend.position = "none") + 
  scale_y_continuous(limits = c(30, 110)) + 
  scale_fill_manual(values = c( "#2e90e0", "#fc1c60")) + 
  geom_hline(yintercept=45.00, linetype="dashed", color = "#fc1c60") +
  geom_hline(yintercept=62.00, linetype="dashed", color = "#2e90e0") +
  coord_flip() 



b = ggplot(pubmep2, aes(x = Predicted , y = HDLc_mgdl_T2,  fill = Predicted)) + 
  geom_rain() + labs( x = "Pubertal prediction", y=  "Pubertal levels of HDL (mg/dL)") + 
  theme_minimal() + theme(legend.position = "none") + 
  scale_y_continuous(limits = c(30, 110)) + 
  scale_fill_manual(values = c( "#2e90e0", "#fc1c60")) + 
  geom_hline(yintercept=39.00, linetype="dashed", color = "#fc1c60") +
  geom_hline(yintercept=52.00, linetype="dashed", color = "#2e90e0") +
  coord_flip() 


patchwork = a/b
patchwork + plot_annotation(tag_levels = 'A')


