workflow varaint_calling {
  call haplotypeCaller
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
             -O ${sample}.g.vcf.gz \
             -ERC GVCF
  }
  output {
    File rawVCF = "${sample}.g.vcf.gz"
  }
}


