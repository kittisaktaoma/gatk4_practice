## Summary Step of Gatk4_Practice
1. Preparing Docker container used in our method &#x2611;
2. Creating Workflow Description Language (WDL) workflow that references the tool’s Docker image. &#x2611;
3. Use Cromwell to test the WDL and dockerized tool locally. &#x2611;
4. Create a method in FireCloud using the WDL workflow you just tested. (**Not Done Yet**)
## Software
**Alignment and Varaint Calling**  <br>
I have modified and updated software version within  [Genomes-in-the-cloud](https://hub.docker.com/r/broadinstitute/genomes-in-the-cloud/) image as shown in the lists below <br>
1. Picard-2.19.0
2. Gatk 4.1.1.0
3. Samtools 1.9
4. Bwa 0.7.15-r1140
5. Vcftools v0.1.12

**Script Format**
1. WDL <br>

## Resource Bundle 
  **Paired-end alignment Dataset** <br> 
  [One sample dataset](https://drive.google.com/drive/folders/1aBcbV_Hlyg0wOOmZDDSBeIc0uw1r3f_w)  <br>
  **Varaint Calling (GVCF mode)** <br> 
  Dataset with three samples retrieved from [this tutorial](https://software.broadinstitute.org/wdl/documentation/article?id=7614)  <br>
  **Varaint Calling (raw VCF mode)** <br>
  Dataset with one sample retrieved from [this tutorial](https://software.broadinstitute.org/wdl/documentation/article?id=7158) <br>
  **Variant Site** <br>
  Varint sites for base and variant recalibration are used from ftp://ftp.broadinstitute.org/bundle/b37/
  

## Phase I: NGS Processing (`PE_aln.wdl`)
  1. **Sequence alignemnt** <br>
     1.1 Paired-end alignment is aligned by BWA in `PE_aln.wdl` script <br>
     1.2 Read Group tag is not implemented in `bwa task` yet, Thus `PE_aln.wdl` scritp is still not compatible with varaint calling in paired end sample in GATK.
     
  2. **Remove duplicate read** <br>
    2.1 Using Picard 
    
  3. **Local realignment** <br> 
    3.1 This step will not done here in my pipeline <br>
    3.2 Haplotypecaller in the gatk4 is already call indel accurately 
    
  4. **Base Recalibration** <br>
    4.1 Varint sites are used from this bundle ftp://ftp.broadinstitute.org/bundle/b37/ <br>
       4.1.1 using `gatk IndexFeatureFile -F cohort.vcf.gz` for creating index <br>
       4.1.2 ***Script is already prepared but not imported into main script yet.*** <br>
  
    
## Phase II: Variant Calling  

  1. **GVCF workflow: multi-sample ('`multiple_sample.wdl`')** <br>
     1.1 Call Variant using Haplotypecaller with `GVCF flag` <br> 
     1.2 CombineGVCF <br> 
     1.3 GenotypeGVCF (***estimation of cohort genotype, raw VCF will be output here***)
     
  2. **RawVCF workflow: one sample ('`one_sample.wdl`')** <br>
     2.1 Call Varint using Haplotype caller without `GVCF flag` <br>
     2.2 Separated Indel and Snps for hard filtering <br>
     2.3 combine SNP and indel VCF files using `vcf-merge`
     
  3. **Variant Manipulation (Part 3 not done yet)** <br>
    3.1 **Varaint Quality Control** <br>
    Hard filtering in ***2.2*** is used instead of building model <br>
    3.2 **Haplotype Phasing** <br>
    Because GATK4 dont have `ReadBackedPhasing` function, Shapeit or Eagles will beused instead. <br>
    3.3 **Variant Annotation** <br>
    Functional Annotation will be annotated by annovar or snpeff
