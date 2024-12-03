#'#################################################################################
#'#################################################################################
#' Process imputed results from PUBMEP_hg19
#'#################################################################################
#'#################################################################################
ini=/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/MIREIA/GWAS_IMPUTATION/GWAS_GRANADA/1_GWAS_GR_HELIX_protocol/GWAS_PROCESSING
mis=/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/MIREIA/GWAS_IMPUTATION/GWAS_GRANADA/1_GWAS_GR_HELIX_protocol/GWAS_PROCESSING/2.3_MIS_Outputs

qc=/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/MIREIA/GWAS_IMPUTATION/GWAS_GRANADA/1_GWAS_GR_HELIX_protocol/GWAS_PROCESSING/2.4_postImputation_Outputs
a=/mnt/9e33c15a-acae-4445-96c2-5ebe80a1c36a/MIREIA/GWAS_IMPUTATION/GWAS_GRANADA/1_GWAS_GR_HELIX_protocol/GWAS_PROCESSING/2.4_postImputation_Outputs/2.4.3_ImpCDV_nohff_QC_goodX

#pre=/media/mireia/HardDiskHDD/Documentos/Universidad/Master_Bioinformatica_UOC/Curso_21_22/SEMESTRE_2/TFM/PEC3/GWAS_IMPUTATION/GWAS_GRANADA/1_GWAS_GR_HELIX_protocol/GWAS_PROCESSING/

## Decompress results (run in runImputation folder)
for i in `ls *.zip`
do
  unzip -P 1eSVtriJx0QC/F $i
done


# Filter samples
## Filter R2
for i in {1..22}
do
  bcftools filter -i 'R2>0.9' $mis/chr$i.dose.vcf.gz -o $qc/chr$i.R2.vcf.gz -O z
done
bcftools filter -i 'R2>0.9' $mis/chrX.dose.vcf.gz  -o $qc/chrX.R2.vcf.gz -O z

## Filter MAF
for i in {1..22}
do
  bcftools filter -i 'MAF>0.01' $qc/chr$i.R2.vcf.gz -o $qc/chr$i.R2.MAF.vcf.gz -O z
done
bcftools filter -i 'MAF>0.01' $qc/chrX.R2.vcf.gz -o $qc/chrX.R2.MAF.vcf.gz -O z

## Filter HW
for i in {1..22}
do
  vcftools --gzvcf  $qc/chr$i.R2.MAF.vcf.gz --hwe 1e-6 --recode --stdout | bgzip -c >  $qc/chr$i.R2.MAF.HWE.vcf.gz
done

## Include sex to filter chrX
plink1.9 --vcf $qc/chrX.R2.MAF.vcf.gz --make-bed --const-fid --out $qc/chrX.R2.MAF
plink1.9 -bfile $qc/chrX.R2.MAF --fam $ini/2.2_runImputation_Outputs/2.2.3_binaries_updated/GWAS_PUBMEP_hg19_binary-updated.fam --hwe 1e-6 --make-bed --out $qc/chrX.R2.MAF.HWE

## Merge datasets
for i in {1..22}
do
  plink1.9 --vcf $qc/chr$i.R2.MAF.HWE.vcf.gz --const-fid --make-bed --out $qc/chr$i.R2.MAF.HWE
  echo $qc/chr$i.R2.MAF.HWE >> $qc/merge.list
done
plink1.9 --bfile $qc/chrX.R2.MAF.HWE --fam $qc/chr1.R*.MAF.HWE.fam --merge-list $qc/merge.list --make-bed --out $qc/PUBMEP_HRC.merged

## Update sex and ids
paste $qc/PUBMEP_HRC.merged.fam $qc/chrX.R2.MAF.HWE.fam | awk '{print $1, $8, $7, $8}' > $qc/newids.tab
plink1.9 --bfile $qc/PUBMEP_HRC.merged --update-ids $qc/newids.tab --make-bed --out $qc/PUBMEP_HRC.merged.ids
plink1.9 --bfile $qc/PUBMEP_HRC.merged.ids --update-sex $qc/chrX.R2.MAF.HWE.fam 3 --split-x hg19 no-fail --make-bed --out $qc/2.4.1_ImpPLINK_QC/PUBMEP_HRC.merged.sex
plink1.9 --bfile $qc/2.4.1_ImpPLINK_QC/PUBMEP_HRC.merged.sex --make-bed --set-hh-missing --out $qc/2.4.1_ImpPLINK_QC/PUBMEP_HRC.merged.sex.nohh


### Annotate to rs
plink1.9 --bfile $qc/2.4.1_ImpPLINK_QC/PUBMEP_HRC.merged.sex.nohh --recode vcf bgz --out $qc/PUBMEP_HRC.merged.sex.nohh
tabix -p vcf $a/PUBMEP_HRC.merged.sex.nohh.vcf.gz

#bcftools index $ini/All_20180418.vcf.gz
bcftools annotate --annotations $ini/All_20180418.vcf.gz \
  --columns ID --output-type z\
  --output $qc/2.4.2_ImpVCF_QC/PUBMEP_HRC.merged.sex.nohh.vcf.gz $a/PUBMEP_HRC.merged.sex.nohh.vcf.gz

plink1.9 --vcf $qc/2.4.2_ImpVCF_QC/PUBMEP_HRC.merged.sex.nohh.vcf.gz --const-fid --make-bed --out $a/PUBMEP_HRC.merged.sex.nohh.rs

## Keep correct .fam
cp $qc/2.4.1_ImpPLINK_QC/PUBMEP_HRC.merged.sex.nohh.fam $a/PUBMEP_HRC.merged.sex.nohh.rs.fam
