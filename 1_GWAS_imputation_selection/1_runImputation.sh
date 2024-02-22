#'#################################################################################
#'#################################################################################
#' Impute PUBMEP data including chromosome X
#'#################################################################################
#'#################################################################################

#pre=/media/mireia/HardDiskHDD/Documentos/Universidad/Master_Bioinformatica_UOC/Curso_21_22/SEMESTRE_2/TFM/PEC3/GWAS_IMPUTATION/GWAS_GRANADA/1_GWAS_GR_HELIX_protocol/GWAS_PROCESSING/
pre=/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/MIREIA/GWAS_IMPUTATION/GWAS_GRANADA/1_GWAS_GR_HELIX_protocol/GWAS_PROCESSING

ln -s $pre/2_Outputs/GWAS_PUBMEP_hg19_binary.bed
ln -s $pre/2_Outputs/GWAS_PUBMEP_hg19_binary.fam
ln -s $pre/2_Outputs/GWAS_PUBMEP_hg19_binary.bim

## Run preparation script
plink1.9 -bfile $pre/1_Binary_Plink_files_and_freq/GWAS_PUBMEP_hg19_binary --make-bed --merge-x --out $pre/2_Outputs/runImputation/GWAS_PUBMEP_hg19_binary
plink1.9 -bfile $pre/2_Outputs/GWAS_PUBMEP_hg19_binary --freq --out $pre/2_Outputs/runImputation/GWAS_PUBMEP_hg19_binary


#perl HRC-1000G-check-bim.pl -b <bim file> -f <freq-file> -r HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h
#sh Run-plink.sh

#Locating ReadKey to solve the problem:
# locate Term/ReadKey.pm;
### INCLUDE IN "HRC-1000G-check-bim.pl" script where is the path to find the ReadKey, being "path/to" the path to "path/to/Term/ReadKey.pm":
# use lib '/path/to';
# use Term::ReadKey;
sudo perl $pre/1_Binary_Plink_files_and_freq/reference_panels_HRC_r1/HRC-1000G-check-bim.pl -b $pre/1_Binary_Plink_files_and_freq/GWAS_PUBMEP_hg19_binary.bim -f $pre/1_Binary_Plink_files_and_freq/GWAS_PUBMEP_hg19_binary.frq -r $pre/1_Binary_Plink_files_and_freq/reference_panels_HRC_r1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h

# In this place I had to install the Term/ReadKey.pm due to a location problem:

# Can't locate Term/ReadKey.pm in @INC (you may need to install the Term::ReadKey module) (@INC contains: /home/augusto/anaconda3/lib/site_perl/5.26.2/x86_64-linux-thread-multi /home/augusto/anaconda3/lib/site_perl/5.26.2 /home/augusto/anaconda3/lib/5.26.2/x86_64-linux-thread-multi /home/augusto/anaconda3/lib/5.26.2 .) at /mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/MIREIA/GWAS_IMPUTATION/GWAS_GRANADA/1_GWAS_GR_HELIX_protocol/GWAS_PROCESSING/1_Binary_Plink_files_and_freq/HRC-1000G-check-bim.pl line 58.
# BEGIN failed--compilation aborted at /mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/MIREIA/GWAS_IMPUTATION/GWAS_GRANADA/1_GWAS_GR_HELIX_protocol/GWAS_PROCESSING/1_Binary_Plink_files_and_freq/HRC-1000G-check-bim.pl line 58.

## Run preprocessing steps from Run_plink.sh (edit code to not run all)
#sh Run-plink.sh
plink1.9 --bfile $pre/1_Binary_Plink_files_and_freq/GWAS_PUBMEP_hg19_binary --exclude $pre/2.2_runImputation_Outputs/2.2.1_perl_outputs/Exclude-GWAS_PUBMEP_hg19_binary-HRC.txt --make-bed --out $pre/2.2_runImputation_Outputs/2.2.2_runPlink_outputs/TEMP1
plink1.9 --bfile $pre/2.2_runImputation_Outputs/2.2.2_runPlink_outputs/TEMP1 --update-map $pre/2.2_runImputation_Outputs/2.2.1_perl_outputs/Chromosome-GWAS_PUBMEP_hg19_binary-HRC.txt --update-chr --make-bed --out $pre/2.2_runImputation_Outputs/2.2.2_runPlink_outputs/TEMP2
plink1.9 --bfile $pre/2.2_runImputation_Outputs/2.2.2_runPlink_outputs/TEMP2 --update-map $pre/2.2_runImputation_Outputs/2.2.1_perl_outputs/Position-GWAS_PUBMEP_hg19_binary-HRC.txt --make-bed --out $pre/2.2_runImputation_Outputs/2.2.2_runPlink_outputs/TEMP3
plink1.9 --bfile $pre/2.2_runImputation_Outputs/2.2.2_runPlink_outputs/TEMP3 --flip $pre/2.2_runImputation_Outputs/2.2.1_perl_outputs/Strand-Flip-GWAS_PUBMEP_hg19_binary-HRC.txt --make-bed --out $pre/2.2_runImputation_Outputs/2.2.2_runPlink_outputs/TEMP4
plink1.9 --bfile $pre/2.2_runImputation_Outputs/2.2.2_runPlink_outputs/TEMP4 --reference-allele $pre/2.2_runImputation_Outputs/2.2.1_perl_outputs/Force-Allele1-GWAS_PUBMEP_hg19_binary-HRC.txt --make-bed --out $pre/2.2_runImputation_Outputs/2.2.2_runPlink_outputs/GWAS_PUBMEP_hg19_binary-updated


## Prepare chromosome for imputation
for i in {1..23}
do
  plink1.9 --bfile $pre/2.2_runImputation_Outputs/2.2.3_binaries_updated/GWAS_PUBMEP_hg19_binary-updated --recode vcf-iid --chr $i --output-chr MT --out $pre/2.2_runImputation_Outputs/2.2.4_preparing_chr/GWAS_PUBMEP_hg19_chr$i
  vcf-sort $pre/2.2_runImputation_Outputs/2.2.4_preparing_chr/GWAS_PUBMEP_hg19_chr$i.vcf  | bgzip -c > $pre/2.2_runImputation_Outputs/2.2.4_preparing_chr/GWAS_PUBMEP_hg19_chr$i.vcf.gz
done

## Remove temporary files
rm $pre/TEMP*
rm results/preImpQC/*.vcf

## Upload file to michigan
# Parameters:
# •	Version: Genotype Imputation (Minimac4) 1.6.6
# •	Reference panel: HRC r1.1 2016
# •	rsq filter: off
# •	Build: GRCh37/hg19
# •	Phasing: Eagle v2.4
# •	Population: EUR
# •	Mode: Quality control & imputation
