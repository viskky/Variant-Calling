#Count number of SNPs
bcftools view -v snps variants.raw.vcf | grep -v -c '^#' variants.raw.vcf

#Count number of INDELs
bcftools view -v indels variants.raw.vcf | grep -v -c '^#' variants.raw.vcf

#Filter variants using qualitycriteria >=30
bcftools filter -i 'QUAL>=30' variants.raw.vcf | grep -v -c '^#' 


bcftools filter -i 'QUAL>=30' variants.raw.vcf | sort | head -n 100
