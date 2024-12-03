## ml package 

# functions to run algorithms and obtain models:
# - rep_kfold_cv_caret
# - rep_kfold_cv_keel

# functions to extract the metrics:
# - metrics
# - process_NA (para cuando TP o TN son igual a 0, el F1 score es NaN y 
#para hacer la media es mejor sustituir entre 0). 
# - summary_table para presentar la media de los resultados 


## FUNCIONES METODOLOGICAS PARA REPEATED K FOLD CROSS VALIDATION 
## CARET y RKEEL
###############################################################################
rep_kfold_cv_caret = function(datos, algoritmo, indices_kfold, 
                                   n_columnaclase, pos, parametros=NULL){
  # INPUTS:
  # datos dataset completo (la clase tiene que ser factor y llamarse Class)
  # algoritmo string que representa un algoritmo en caret
  # indices_kfold número de instancia que forman los folds (caret::createFolds)
  # n_columnaclase = número de columna de la clase
  # pos string de la clase positiva (en nuestro caso "Yes_IR", 1)
  # parametros objeto creado con expand.grid que varía en función del algoritmo
  
  # OUTPUTs:
  # una lista con 3 componentes:
  # - modelos (objeto train)
  # - resultados del train (objeto Confussionmatrix de caret)
  # - resultados del test (objeto Confussionmatrix de caret)
  
  library(caret) # cargamos 
  library(tidymodels)
  library(themis)
  # 3 compornentes de la lista 
  modelos_kfold = list()
  result_train_kfold = list()
  result_test_kfold =  list()
  for (i in 1:length(indices_kfold)){ # bucle para iterar los distintos folds
    test = datos[c(indices_kfold[[i]]), ] # 1 fold test
    train1 = datos[-c(indices_kfold[[i]]), ] # el resto train
    set.seed(1234556789) # se fija la semilla
    under = recipe(Class ~ ., data=train1) %>%
      step_nearmiss(Class, under_ratio=1, neighbors = 8)
    rec = prep(under, training=train1)
    train2 = as.data.frame(rec$template)
    train2$Class = factor(train2$Class, levels=c("No_IR", "Yes_IR"), labels=c("No_IR", "Yes_IR"))
    # se entrena al algoritmo trainControl y train
    set.seed(1234556789) # se fija la semilla
    control = trainControl(method="none", returnData=TRUE, classProbs = TRUE, 
                           summaryFunction = twoClassSummary)
    modelo = train(Class ~ ., data=train2, method=algoritmo, 
                   trControl=control, tuneGrid=parametros,
                   metric ="Sens", 
                   maximize = TRUE)
    training = predict(modelo, train1) # result train
    testing = predict(modelo, test) # result test
    # matriz de confusion train y test 
    tabla1 = confusionMatrix(training, train1[, n_columnaclase], positive = pos)
    tabla2 = confusionMatrix(testing, test[, n_columnaclase], positive = pos)
    nombre = paste("modelo", i) # se crea un nombre acorde con la iteracion
    # se llenan las listas
    modelos_kfold[[nombre]] = modelo
    result_train_kfold[[nombre]] = tabla1
    result_test_kfold[[nombre]] = tabla2
  }
  # se forma la lista del OUTPUT
  listadef = list(Models = modelos_kfold, Train = result_train_kfold, 
                  Test = result_test_kfold)
  return(listadef)
}
# FUNCION EQUIVALENTE EN KEEL
rep_kfold_cv_keel = function(datos, algoritmo, indices_kfold, pos, 
                             mistake=FALSE){
  # INPUTS:
  # datos dataset completo (la clase tiene que ser factor y llamarse Class)
  # algoritmo 0 o 1 que representa 0=FURIA y 1=FARCHD
  # indices_kfold número de instancia que forman los folds (caret::createFolds)
  # pos string de la clase positiva (en nuestro caso "Yes_IR", 1)
  # mistake = TRUE, evita que si solo predice No_IR haya un warning o se pare 
  
  # OUTPUTs:
  # una lista con 3 componentes:
  # - modelos (objeto RKEEL)
  # - resultados del train (objeto Confussionmatrix de caret)
  # - resultados del test (objeto Confussionmatrix de caret)
  library(RKEEL)
  library(caret)
  library(stringr)
  library(tidymodels)
  library(themis)
  # 3 componentes
  set.seed(123456789)
  modelos_kfold = list()
  result_train_kfold = list()
  result_test_kfold =  list()
  n = ncol(datos)
  for (i in 1:length(indices_kfold)){
    test = datos[c(indices_kfold[[i]]), ] 
    train1 = datos[-c(indices_kfold[[i]]), ]
    set.seed(123456789)
    under = recipe(Class ~ ., data=train1) %>%
      step_nearmiss(Class, under_ratio=1, neighbors = 8)
    rec = prep(under, training=train1)
    train2 = as.data.frame(rec$template)
    train2$Class = factor(train2$Class, levels=c("No_IR", "Yes_IR"), labels=c("No_IR", "Yes_IR"))
    # FURIA O FARCHD
    if (str_detect(algoritmo, "FURIA")==TRUE){
      algorithm = FURIA_C(train2, test, seed=123456789)
    }
    if (str_detect(algoritmo, "FARCHD")==TRUE){
      algorithm = FuzzyFARCHD_C(train2, test, seed=123456789)
    }
    algorithm$run() # se ejecuta el algoritmo
    # resultados training
    train = algorithm$trainPredictions[1] # se obtienen los datos reales
    training = algorithm$trainPredictions[2] # se obtienen las predicciones
    train = as.factor(train$Real) # se transforma a factor (porque RKEEL devuelve string)
    training = as.factor(training$Predicted) # se transforma a factor
    if (mistake==TRUE){ # para evitar que solo haya un level
      training = factor(training, levels=c("No_IR", "Yes_IR"), 
                        labels=c("No_IR", "Yes_IR"))
      train = factor(train, levels=c("No_IR", "Yes_IR"), 
                        labels=c("No_IR", "Yes_IR"))
    }
    tabla1 = confusionMatrix(training, train, positive = pos) # matriz de confusion del train
    # resultados test
    test = algorithm$testPredictions[1]
    testing = algorithm$testPredictions[2]
    test = as.factor(test$Real)
    testing = as.factor(testing$Predicted)
    if (mistake==TRUE){ # para evitar que solo haya un level
      testing = factor(testing, levels=c("No_IR", "Yes_IR"), 
                       labels=c("No_IR","Yes_IR"))
    }
    tabla2 = confusionMatrix(testing, test, positive = pos) # matriz de confusion del test
    nombre = paste("modelo", i) # se crea nombre acorde a la iteracion
    # 3 componentes del OUTPUT
    modelos_kfold[[nombre]] = algorithm 
    result_train_kfold[[nombre]] = tabla1
    result_test_kfold[[nombre]] = tabla2
  }
  # la lista del OUTPUT
  listadef = list(Models = modelos_kfold, Train = result_train_kfold, 
                  Test = result_test_kfold)
  return(listadef)
}

# FUNCION PARA EXTRAER LAS MÉTRICAS del TEST Y TRAIN de la lista obtenida
# por las funciones anteriores
metricas = function(objetokfold, option=TRUE, is=25){
  # INPUTS:
  # - objetokfold es una lista creada por rep_kfold_cv_caret ó keel
  # - option es para diferenciar resultados del test (TRUE) con respecto a los resultados del training (FALSE)
  # - is es el número de modelos que tienen (en este caso k=5, times=5, son 25 modelos por defecto)
  if(option==TRUE){
    test_cv = objetokfold$Test
  }
  if(option==FALSE){
    test_cv = objetokfold$Train
  }
  # se crean vectores vacios para las métricas
  Accuracy = c()
  Kappa = c()
  Sensitivity = c()
  Specificity = c()
  F1 = c()
  PPV = c()
  NPV = c()
  for (i in 1:is){ # iterar los diferentes modelos para obtener las métricas
    # se accede a la matriz de confusión en cuestión y se obtienen todas las metricas
    modelo = test_cv[[i]]
    Accuracy = c(Accuracy, as.numeric(c(modelo$overall[1])))
    Kappa = c(Kappa, as.numeric(c(modelo$overall[2])))
    Sensitivity = c(Sensitivity, as.numeric(c(modelo$byClass[1])))
    Specificity = c(Specificity, as.numeric(c(modelo$byClass[2])))
    F1 = c(F1, as.numeric(c(modelo$byClass[7])))
    PPV = c(PPV, as.numeric(c(modelo$byClass[4])))
    NPV = c(NPV, as.numeric(c(modelo$byClass[5])))
  }
  # metricas no proporcionadas por caret
  # se crean funciones para calcular metricas que caret no calcula
  AUC = function(sens, spe){
    auc = (1 + sens - (1-spe))/2
    return(auc)
  }

  Gmean = function(sens, spe){
    g = sqrt(sens * spe)
    return(g)
  }

  Gmeasure = function(PPV, Sens){
    g = sqrt(PPV*Sens)
    return(g)
  }
  # se emplean 
  AUC = AUC(Sensitivity, Specificity)
  G_mean = Gmean(Sensitivity, Specificity)
  G_measure = Gmeasure(PPV, Sensitivity)
  # se crea un vector llamado Folds de 1 a 25 
  Folds = as.numeric(c(seq(1,is,1)))
  # Se agrupa todo en un dataframe 
  Tabla = data.frame(cbind(Folds, Accuracy, Sensitivity, Specificity, Kappa, PPV, NPV,
                           AUC, F1, G_mean, G_measure))
  return(Tabla)
}
process_NA = function(dataframe){
  library(purrr)
  library(dplyr)
  # se reemplazan todos los NAs por 0 
  new <- mutate_all(dataframe, ~replace(., is.na(.), 0))
  return(new)
}
# FUNCION PARA MOSTRAR METRICAS PROMEDIO DE MUCHOS ALGORITMOS 
summary_table = function(listadelistas, nombres, opt=TRUE){
  # INPUTS:
  # - listadelistas es una lista con todas las listas de los algorimtos ejecutados mediante las funciones rep_kfold_cv_caret ó keel
  # - nombres es un vector con los strings de los nombres ordenados de los diferentes algoritmos que componen la lista 
  # - opt es para darle un valor a options de metrics, y así acceder a test o train de la función metrics 
  
  vector = c()
  for (i in listadelistas){ # iterar la lista para acceder a los diferentes resultados 
    # calcular la media de todas las métricas en las distintas iteraciones de 1 algoritmo (para ello se emplea process_NA y metrics)
    mean = round(apply(process_NA(metricas(i, option=opt, is=25)[2:11]), 
                       MARGIN=2, FUN=mean), 2)
    # también se calcula la desviación estándar 
    sd = round(apply(process_NA(metricas(i, option=opt, is=25)[2:11]), 
                     MARGIN=2, FUN=sd), 2)
    # dataframe (1 fila) con las medias y las sd entre parentesis
    medidas = data.frame(paste(mean, "(", sd,")"))
    # se añade al vector vacio
    vector = c(vector, medidas)
  }
  # este vector lleno se transforma a dataframe 
  datos = as.data.frame(vector)
  # se le ponen los nombres del parametro nombres 
  colnames(datos) = nombres
  # y se le pone el nombre a las filas de las distintas métricas 
  row.names(datos) = c("Accuracy", "Sensitivity", "Specificity", "Kappa", 
                       "PPV", "NPV", "AUC", "F1", "G_mean", "G_measure")
  return(datos)
}
## funcion para generar las particiones
# FUNCION EQUIVALENTE EN KEEL
particiones = function(datos, indices_kfold){
  # INPUTS:
  # datos dataset completo (la clase tiene que ser factor y llamarse Class)
  # indices_kfold número de instancia que forman los folds (caret::createFolds)
  
  # OUTPUTs:
  # una lista con 2 componentes:
  # training folds (con undersampling) y test folds
  library(tidymodels)
  library(themis)
  train_fold = list()
  test_fold = list()
  # 3 componentes
  for (i in 1:length(indices_kfold)){
    test = datos[c(indices_kfold[[i]]), ] 
    train1 = datos[-c(indices_kfold[[i]]), ]
    set.seed(12345678)
    under = recipe(Class ~ ., data=train1) %>%
      step_nearmiss(Class, under_ratio=1, neighbors = 8)
    rec = prep(under, training=train1)
    train2 = as.data.frame(rec$template)
    train2$Class = factor(train2$Class, levels=c("No_IR", "Yes_IR"), labels=c("No_IR", "Yes_IR"))
    nombre = paste("Fold", i) # se crea nombre acorde a la iteracion]
    train_fold[[nombre]] = train2
    test_fold[[nombre]] = test
  }
  list_particiones = list(Train = train_fold, Test = test_fold)
  return(list_particiones)
}
export_keel = function(particiones, numero=25, directorio){
  for (i in 1:numero){
    nombre_train = gsub(" ", "", paste(i, "train.dat"))
    nombre_test = gsub(" ", "", paste(i, "test.dat"))
    setwd(directorio)
    RKEEL::writeDatFromDataframes(particiones$Train[[i]], 
                                  particiones$Test[[i]], 
                                  nombre_train, 
                                  nombre_test)
  }
  setwd("/home/msi/Escritorio/TFM/3_repeated_k_fold_cross_validation")
}