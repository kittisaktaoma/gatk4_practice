# gatk4_practice

## Software

**Script Format**
1. WDL <br>

**Varaint Calling** 
1. Gatk4
2. Picard
3. BWA
4. Samtools

## Resource Bundle 
  **Fastq (only Fastq and Bam available):** <br> 
  https://drive.google.com/drive/folders/1K7gpIDP5uTYPbOutnPwXOmT92vAW5AGn  <br>
  This file contain read groups that is necessary for calling varaint in Haplotype caller <br> 
  **RefFasta (retrieved from NCBI based on Fastq):** <br>
  NG_008385.2 Homo sapiens cytochrome P450 family 2 subfamily C member 9 (CYP2C9), RefSeqGene (LRG_1195) on chromosome 10
  
## Phase I: NGS Processing 
  1. **Sequence alignemnt** <br>
     1.1 In ` mapping_RG.sh` , Paired-end alignment is aligned by BWA and Read Group is prepared for varaint calling in by gatk4 
  2. **Remove duplicate read** <br>
    2.1 Using Picard 
  3. **Local realignment** <br> 
    3.1 This step will not done here in my pipeline
    3.2 Haplotype caller is already updated to call indel accurately
  4. **Base Recalibration** <br>
    4.1 Varint sites are used from this bundle ftp://ftp.broadinstitute.org/bundle/b37/ <br>
       4.1.1 using `gatk IndexFeatureFile -F cohort.vcf.gz` for creating index <br>
       4.1.2 ***Script is already prepared but not imported into main script yet.*** <br>
  
    
## Phase II: Variant Calling 

  1. **GVCF workflow: multi-sample** <br>
     1.1 Call Variant using Haplotypecaller with `GVCF flag`
         IndexBam file is already provided but it still but with this error massage <br>
         ***A USER ERROR has occurred: Traversal by intervals was requested but some input files are not indexed. Please index all input files:***
     1.2 CombineGVCF 
     1.3 GenotypeGVCF (estimated cohort genotype)
  2. **RawVCF workflow: one sample** <br>
     2.1 Call Varint using Haplotype caller without `GVCF flag`
     2.2 Separated Indel and Snps for hard filtering
     2.3 combine SNP and indel VCF files using `vcf-merge`
    
  3. **Variant Manipulation** <br>
    3.1 **Varaint Quality Control** <br>
    Hard filtering in ***2.2*** is used instead of building model <br>
    
    ### 3.2 and 3.3 are not performed yet
    3.2 **Haplotype Phasing** <br>
    Because GATK4 dont have `ReadBackedPhasing` function, Shapeit or Eagles will beused instead. <br>
    3.3 **Variant Annotation** <br>
    Functional Annotation will be annotated by annovar or snpeff
