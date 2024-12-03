
## Organization of software in the repository

All scripts employed for the generation of manuscript results for the paper **"Multiomics and eXplainable Artificial Intelligence for decision support in insulin resistance early diagnosis: A pediatric population-based longitudinal study"** are organized as follows:

---

### **Directory: `scripts`**
This directory contains all the scripts used in the study, which are further divided into the following subdirectories based on their respective tasks:

- **`1_GWAS_imputation_selection`**  
  - **Purpose**: Scripts for preprocessing, quality control, and imputation of genomic data.  
  - **Contents**:  
    - `1_runImputation.sh`: Automates the GWAS imputation process.  
    - `2_runPostImputation.sh`: Executes post-imputation checks and quality assessments.  
    - `3_generateStatistics.sh`: Generates summary statistics for the imputed genomic data.  
    - `4_subset_SNPs.sh`: Filters and subsets SNPs for downstream analysis.

- **`2_EWAS_preprocessing_selection`**  
  - **Purpose**: Handles preprocessing and feature selection for epigenomic data.  
  - **Contents**:  
    - `1_QC_preprocessing.R`: Performs quality control and data normalization for CpG methylation sites.  
    - `2_selection.R`: Implements feature selection techniques for epigenomic markers.  

- **`3_clinicaldata_preprocessing`**  
  - **Purpose**: Manages preprocessing of anthropometric, biochemical, and clinical data.  
  - **Contents**:  
    - `1_clinicaldata_exploratory_data_analysis.R`: Conducts exploratory data analysis on clinical datasets.  
    - `2_imputation.R`: Handles missing data imputation for clinical variables.  

- **`4_ML_construction`**  
  - **Purpose**: Scripts for machine learning model development and evaluation.  
  - **Contents**:  
    - `0_ml_functions.R`: Contains reusable ML functions utilized across the pipeline.  
    - `1_machine_learning_models.R`: Trains and evaluates various machine learning models.  
    - `3_data_visualizations_fig2.R`: Generates visualizations for Figure 2 in the manuscript.  
    - `4_final_classifier_RF.R`: Builds the final Random Forest classifier for the study.  

- **`5_ML_model_interpretation`**  
  - **Purpose**: Scripts to interpret and explain machine learning models using SHAP values.  
  - **Contents**:  
    - `1_SHAP_values_generation.R`: Calculates SHAP values for model predictions.  
    - `2_SHAP_visualizations_fig3_7.py`: Creates visualizations of SHAP values (e.g., dot plots, force plots, etc).  
    - `3_SHAP_clustering_fig4_5_6.R`: Performs clustering analysis based on SHAP value distributions.  

---

### **General Notes**
- The scripts are organized to replicate the analysis pipeline step-by-step, allowing users to reproduce the study findings or adapt the methodology to other datasets.
