workflow varaint_select {
  File refindex
  File refdict
  File bamindex
  File inputbam
  File gatk_local_jar
  File gatk
  File reffasta
  String name
 
  call haplotypeCaller {
    input:
       RefIndex=refindex, 
       RefDict=refdict,
       bamIndex=bamindex,
       GATK_jar=gatk_local_jar,
       GATK=gatk,
       RefFasta=reffasta,
       sample=name,
       inputBAM=inputbam
  }

  call select as selectSNPs {
    input: 
      sample=name, 
      RefFasta=reffasta, 
      GATK=gatk,
      GATK_jar=gatk_local_jar, 
      RefIndex=refindex, 
      RefDict=refdict, 
      type="SNP",
      rawVCF=haplotypeCaller.rawVCF
  }
  call select as selectIndels {
    input: 
      sample=name, 
      RefFasta=reffasta, 
      GATK=gatk,
      GATK_jar=gatk_local_jar, 
      RefIndex=refindex, 
      RefDict=refdict, 
      type="INDEL", 
      rawVCF=haplotypeCaller.rawVCF
  } 
}


task haplotypeCaller {
  
  File RefIndex
  File RefDict
  File bamIndex
  File GATK_jar
  File GATK
  File RefFasta
  String sample
  File inputBAM

  command {
    ${GATK} --java-options "-Xmx4g" HaplotypeCaller \
             -R ${RefFasta} \
             -I ${inputBAM} \
             -O ${sample}.g.vcf \
  }
  output {
    File rawVCF = "${sample}.g.vcf"
  }
}


task select {
  File GATK
  File GATK_jar
  File RefFasta
  File RefIndex
  File RefDict
  String sample
  String type
  File rawVCF

  command {
    ${GATK} SelectVariants \
      -R ${RefFasta} \
      -V ${rawVCF} \
      --select-type-to-include ${type} \
      -O ${sample}_raw.${type}.vcf
  }
  output {
    File rawSubset = "${sample}_raw.${type}.vcf"
  }
}
