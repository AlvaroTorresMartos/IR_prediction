#'#################################################################################
#'#################################################################################
#' Generate statistics for report
#'#################################################################################
#'#################################################################################
ini=/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/MIREIA/GWAS_IMPUTATION/GWAS_GRANADA/1_GWAS_GR_HELIX_protocol/GWAS_PROCESSING
mis=/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/MIREIA/GWAS_IMPUTATION/GWAS_GRANADA/1_GWAS_GR_HELIX_protocol/GWAS_PROCESSING/2.3_MIS_Outputs
pim=/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/MIREIA/GWAS_IMPUTATION/GWAS_GRANADA/1_GWAS_GR_HELIX_protocol/GWAS_PROCESSING/2.4_postImputation_Outputs

qc=/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/MIREIA/GWAS_IMPUTATION/GWAS_GRANADA/1_GWAS_GR_HELIX_protocol/GWAS_PROCESSING/2.5_Postimp_QC_generateStatistics


## Count variants
### All imputed
for i in {1..22}
do
  plink1.9 --vcf $mis/chr$i.dose.vcf.gz --const-fid --make-just-bim --out $qc/chr$i.dose
done
plink1.9 --vcf $mis/chrX.dose.vcf.gz --const-fid --make-just-bim --out $qc/chr23.dose

for i in {1..23}
do
  cat $qc/chr$i.dose.bim >> $qc/all.dose.txt
done

### R2 filtered
for i in {1..22}
do
  plink1.9 --vcf $pim/chr$i.R2.vcf.gz --const-fid --make-just-bim --out $qc/chr$i.R2
done
plink1.9 --vcf $pim/chrX.R2.vcf.gz --const-fid --make-just-bim --out $qc/chr23.R2

for i in {1..23}
do
  cat $qc/chr$i.R2.bim >> $qc/all.R2.txt
done

### MAF filtered
for i in {1..22}
do
  plink1.9 --vcf $pim/chr$i.R2.MAF.vcf.gz --const-fid --make-just-bim --out $qc/chr$i.MAF
done
plink1.9 --vcf  $pim/chrX.R2.MAF.vcf.gz --const-fid --make-just-bim --out $qc/chr23.MAF

for i in {1..23}
do
  cat $qc/chr$i.MAF.bim >> $qc/all.MAF.txt
done


### HWE filtered
for i in {1..22}
do
  plink1.9 --vcf $pim/chr$i.R2.MAF.HWE.vcf.gz --const-fid --make-just-bim --out $qc/chr$i.HWE
done
plink1.9 --vcf  $pim/chrX.R2.MAF.HWE.vcf.gz --const-fid --make-just-bim --out $qc/chr23.HWE

for i in {1..23}
do
  cat $qc/chr$i.HWE.bim >> $qc/all.HWE.txt
done
