# gatk4_practice
# SNPs and Indels Calling
## Phase I: NGS Provessing 
  1. **Sequence Alignemnt** <br>
     1.1 Fastq data are derived from https://drive.google.com/drive/folders/1aBcbV_Hlyg0wOOmZDDSBeIc0uw1r3f_w
  2. **Remove Duplicate** <br>
    2.1 Using Picard
  3. **Local Realignment** <br>
    3.1 Haplotype caller is already updated to call indel accurately
  4. **Base Recalibration** <br>
    4.1 Varint sites are used from this bundle ftp://ftp.broadinstitute.org/bundle/b37/ <br>
      4.2 using `gatk IndexFeatureFile -F cohort.vcf.gz` for creating index
 
## Phase II: Variant Calling 
  1. **GVCF workflow <br>
  
  2. **RawVCF workflow** <br>
  
  3. **Variant Manipulation** <br>
    3.1 **Varaint Quality Control** <br>
    Hard filtering is used instead of building model <br>
    3.2 **Haplotype Phasing** <br>
    Because GATK4 dont have `ReadBackedPhasing` function, Shapeit or Eagles will beused instead. <br>
    3.3 **Variant Annotation** <br>
     **Functional Annotation** will be annotated by annovar or snpeff
