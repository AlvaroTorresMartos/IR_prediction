
# Multiomics and eXplainable artificial intelligence for decision support in insulin resistance early diagnosis: A pediatric population-based longitudinal study

## Authors
by 
Álvaro Torres-Martos,
Augusto Anguita-Ruiz,
Mireia Bustos Aibar, 
Alberto Ramírez Mena, 
María Arteaga, 
Gloria Bueno, 
Rosaura Leis, 
Concepción M. Aguilera, 
Rafael Alcalá, 
Jesús Alcalá-Fdez

> This is an online repository gathering all codes employed for the analyses presented in the paper (Torres-Martos Á *et al*. Multiomics and eXplainable Artificial Intelligence for decision support in insulin resistance early diagnosis: A pediatric population-based longitudinal study". *Artificial Intelligence in Medicine*. 2024.;156:102962. doi:10.1016/j.artmed.2024.102962). The purpose of this repository is to allow researchers to reproduce the Machine Learning pipeline presented in the paper, as well as to adapt provided codes for the analyses of their own datasets.

> In the current paper, we propose a Machine Learning pipeline integrating multiomics data and eXplainable Artificial Intelligence (XAI) to predict insulin resistance during puberty using only pre-pubertal information. The methodology, including the combination of data layers, algorithms, and resampling techniques, is summarized in the following figure:

![](images/fig1.png)
*Figure. Summary of the experimental design. The longitudinal study consisted of pre-pubertal children who were followed into puberty three years later. The pre-pubertal information was used as input to generate the classifiers and the output was the pubertal IR status. The analysis plan utilizes genomic (Gen), epigenomic (Epi), and clinical (Clin) data from pre-pubertal children. The chosen data combination, algorithm, and resampling method are highlighted in red. Subsequently, we made pubertal predictions and analyzed the final classifier’s behavior using post-hoc explainer.*


All source code used to generate results in the paper are organized in folder listed. For a detailed description, please read the paper extensively.


## Getting the code

You can download a copy of all the files in this repository by cloning the
[git](https://git-scm.com/) repository:

    git clone https://github.com/AlvaroTorresMartos/IR_prediction

or [download a zip archive](https://github.com/AlvaroTorresMartos/IR_prediction/archive/refs/heads/main.zip).


## Dependencies

A `R/Python` environment is required to execute the code. The required libraries for each analysis are specified in each script. Several command line tools have been utilized through the shell, including `vcftools`, `bcftools`, and `PLINK`.


## License

All source code is made available under a BSD 3-clause license. You can freely use and modify the code, without warranty, so long as you provide attribution to the authors. See `LICENSE.md` for the full license text.

The manuscript text is not open source. The authors reserve the rights to the article content, which is currently submitted for publication in the *Artificial Intelligence in Medicine*.
