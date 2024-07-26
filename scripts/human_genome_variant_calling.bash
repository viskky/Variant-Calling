#!/bin/bash

#Call germline variants in a human WGS paired end reads 2 X 100bp
#This script is for practicing only

#download paired end reads
wget ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/phase3/data/HG00096/sequence_read/SRR062634_1.filt.fastq.gz
wget ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/phase3/data/HG00096/sequence_read/SRR062634_2.filt.fastq.gz

#download reference fasta file
wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz

#extract file
gunzip hg38.fa.gz

#Run fastqc - Quality Control
fastqc SRR062634_1.filt.fastq.gz
fastqc SRR062634_2.filt.fastq.gz

#Check fastqc results. Result on html shows no trimming required


#Index the reference file
bwa index hg38.fa

#BWA alignment of the paired end reads
bwa mem -t 4 -R "@RG\tID:SRR062634\tPL:ILLUMINA\tSM:SRR062634" hg38.fa SRR062634_1.filt.fastq.gz SRR062634_2.filt.fastq.gz > output.sam

#Convert the sam file to bam file to reduce the size
samtools view -S -b output.sam > output.bam

#Sort the bam file using samtools
samtools sort -o output.sorted.bam output.bam

#Index the BAM file for IGV viewer or tablet software
samtools index output.sorted.bam

#Get the mapping statistics of the BAM file
samtools flagstat output.sorted.bam

#mpileup and filter the mapping quality
bcftools mpileup -o b -o raw.bcf -f hg38.fa --threads 8 -q 20 -Q 30 output.sorted.bam

#variant calling
bcftools call -m -v -o variants.raw.vcf raw.bcf

#Count number of SNPs
bcftools view -v snps variants.raw.vcf | grep -v -c '^#' variants.raw.vcf

#Count number of INDELs
bcftools view -v indels variants.raw.vcf | grep -v -c '^#' variants.raw.vcf

#Filter variants using qualitycriteria >=30
bcftools filter -i 'QUAL>=30' variants.raw.vcf | grep -v -c '^#' 


bcftools filter -i 'QUAL>=30' variants.raw.vcf | sort | head -n 100
