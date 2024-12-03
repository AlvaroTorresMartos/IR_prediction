

plink1.9 --bfile PUBMEP_HRC.merged.sex.nohh.rs  --recode vcf --out vcf/vcf_imputado

vcftools --vcf ./vcf_imputado/vcf_imputado.vcf --snps snps.txt --recode --recode-INFO-all --out vcf_snpsdef


