





data = data.frame("Method" = c(rep("C4.5", 7), rep("RF", 7), rep("xgBoost", 7),
                               rep("svmRadial", 7), rep("avNNet", 7)),
                  "G_Mean" =     c(0.42, 0.52, 0.57, 0.48, 0.59, 0.61, 0.58, 
                                   0.53, 0.56, 0.64, 0.60, 0.62, 0.69, 0.67, 
                                   0.48, 0.56, 0.62, 0.60, 0.61, 0.64, 0.63, 
                                   0.44, 0.43, 0.55, 0.54, 0.46, 0.50, 0.47, 
                                   0.55, 0.38, 0.09, 0.08, 0.17, 0.335, 0.31
                                   ), 
                  "Combination" = c(rep(paste(c("Gen", "Epi", "Clin", 
                                                "Gen+Epi", "Gen+Clin", 
                                                "Epi+Clin", "All"), sep="_"), 5)), 
                  "Sensivity" =  c(0.43, 0.50, 0.60, 0.48, 0.62, 0.67, 0.61, 
                                   0.51, 0.57, 0.78, 0.62, 0.70, 0.73, 0.71, 
                                   0.48, 0.61, 0.71, 0.61, 0.70, 0.71, 0.67, 
                                   0.55, 0.51, 0.70, 0.56, 0.57, 0.59, 0.59, 
                                   0.56, 0.78, 0.80, 0.06, 0.58, 0.37, 0.33
                                   ),
                  "Specificity"= c(0.51, 0.58, 0.58, 0.55, 0.57, 0.59, 0.57, 
                                   0.56, 0.57, 0.54, 0.60, 0.58, 0.69, 0.66, 
                                   0.53, 0.55, 0.57, 0.62, 0.58, 0.61, 0.62, 
                                   0.45, 0.50, 0.46, 0.55, 0.45, 0.49, 0.45, 
                                   0.59, 0.46, 0.21, 0.93, 0.39, 0.64, 0.68
                                   ))

data$Method = as.factor(data$Method)
data$Method = ordered(data$Method, levels = c("C4.5", "RF", "xgBoost",  "svmRadial", "avNNet"))

# http://www.sthda.com/english/wiki/ggplot2-point-shapes
library(tidyverse)
library(ggrepel)
library(RColorBrewer)
data = data %>% mutate(Label = paste(Sensivity, Specificity, sep = ","), 
                       Legend = paste(Method, Combination))
data$Legend = as.factor(data$Legend)
data$Legend = ordered(data$Legend, levels = c(data$Legend))
# https://stackoverflow.com/questions/12410908/combine-legends-for-color-and-shape-into-a-single-legend
# https://stackoverflow.com/questions/18337653/remove-a-from-legend-when-using-aesthetics-and-geom-text
# show.guide = FALSE (geom_point)
# ggplot(data, aes(Method, G_Mean, color = Legend, shape = Legend)) +
#   geom_point(size = 3) + geom_label_repel( aes(label=Label), hjust = 0.05, nudge_x = 0.3,
#                                    nudge_y = 0.05,
#                                    label.size = 0.05, show.legend = FALSE, force = 1.5, size=4) + 
#   scale_colour_manual(name = "Method & Combination", #labels = Legend, 
#                       values = c(rep("#1B9E77", 7), 
#                                  rep("#D95F02", 7), 
#                                  rep("#7570B3", 7), 
#                                  rep("#E7298A", 7),
#                                  rep("#66A61E", 7)
#                         )) + 
#   scale_shape_manual(name = "Method & Combination", #labels = Legend,
#     values=rep(c(0, 1, 2, 5, 6, 8, 7), 5) ) + 
#   theme_light() 
  

# brewer.pal(n = 5, "Dark2")
# [1] "#1B9E77" "#D95F02" "#7570B3" "#E7298A" "#66A61E" "#E6AB02" "#A6761D"

library(tidyverse)
library(ggrepel)
# library(khroma)
data = data %>% mutate(Label = paste(Sensivity, Specificity, sep = ","), 
                       Legend = paste(Method, Combination))
data$Legend = as.factor(data$Legend)
data$Legend = ordered(data$Legend, levels = c(data$Legend))
data$Combination = as.factor(data$Combination)
data$Combination = ordered(data$Combination, levels = c("Gen", "Epi", "Clin", 
                                                        "Gen+Epi",
                                                        "Gen+Clin", 
                                                        "Epi+Clin", 
                                                        "All"))
# https://cran.r-project.org/web/packages/khroma/vignettes/tol.html
# highcontrast <- colour("high contrast")
# plot_scheme(highcontrast(3), colours = TRUE, names = TRUE, size = 0.9)
# plot_scheme(rainbow(7), colours = TRUE, names = TRUE, size = 0.9)
# color = rainbow(7)[-c(4)]
# color = c("black", color)


ggplot(data, aes(Method, G_Mean, color = Combination, shape = Combination)) +
  geom_point(size = 3.75) + geom_label_repel( aes(label=Label),  
                                              nudge_x = -0.01,
                                              nudge_y = -0.01,
                                              label.size = 0.05, show.legend = FALSE, 
                                              force = 1.5, size=4.5) + 
  labs(y = "G-mean") + 
  scale_colour_manual(name = "Combination", #labels = Legend, 
                      values = c("darkblue", "firebrick", "yellow3", 
                                 "darkorchid4", "darkgreen", "darkorange3",
                                 "black")) + 
  scale_shape_manual(name = "Combination", #labels = Legend,
                     values=c(0, 1, 2, 5, 6, 8, 7)) + 
  theme_light() + theme(legend.position = c(0.4, 0.3),
                        legend.direction = "horizontal", 
                        legend.key.height= unit(1.2, 'cm'),
                        legend.key.width= unit(2, 'cm'), 
                        legend.background = element_rect(color = "gray20"), 
                        axis.text.x = element_text(size = 19), 
                        axis.text.y = element_text(size = 19), 
                        axis.title.x = element_text(size = 20),
                        axis.title.y = element_text(size = 20), 
                        legend.title=element_text(size=10), 
                        legend.text=element_text(size=10)
                        )

# NEW PLOT 





