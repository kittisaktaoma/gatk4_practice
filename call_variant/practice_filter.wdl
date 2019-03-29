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


   call hardFilterSNP {
    input: sample=name, 
      RefFasta=reffasta, 
      GATK=gatk,
      GATK_jar=gatk_local_jar, 
      RefIndex=refindex, 
      RefDict=refdict, 
      rawSNPs=selectSNPs.rawSubset
  }
  call hardFilterIndel {
    input: sample=name, 
      RefFasta=reffasta, 
      GATK=gatk,
      GATK_jar=gatk_local_jar, 
      RefIndex=refindex, 
      RefDict=refdict, 
      rawIndels=selectIndels.rawSubset
  }
  call combine {
    input: sample=name,
      RefFasta=reffasta,
      GATK=gatk,
      GATK_jar=gatk_local_jar,
      RefIndex=refindex, 
      filteredSNPs=hardFilterSNP.filteredSNPs, 
      filteredIndels=hardFilterIndel.filteredIndels
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


task hardFilterSNP {
  File GATK
  File GATK_jar
  File RefFasta
  File RefIndex
  File RefDict
  String sample
  File rawSNPs

  command {
    ${GATK} VariantFiltration \
      -R ${RefFasta} \
      -V ${rawSNPs} \
      -O ${sample}.filtered.snps.vcf \
      --filter-name "filter_SNPs" \
      --filter-expression "QUAL > 30.0 && DP == 10"
  }
  output {
    File filteredSNPs = "${sample}.filtered.snps.vcf"
  }
}


task hardFilterIndel {
  File GATK
  File GATK_jar
  File RefFasta
  File RefIndex
  File RefDict
  String sample
  File rawIndels

  command {
    ${GATK} VariantFiltration \
      -R ${RefFasta} \
      -V ${rawIndels} \
      -O ${sample}.filtered.indels.vcf \
      --filter-name "indel_filter" \
      --filter-expression "QUAL > 30.0 && DP == 10"
  }
  output {
    File filteredIndels = "${sample}.filtered.indels.vcf"
  }
}


task combine {
  File GATK
  File GATK_jar
  File RefFasta
  File RefIndex
  String sample
  File filteredSNPs
  File filteredIndels

  command {
	${GATK} CombineGVCFs \
        -R ${RefFasta} \
        --variant ${filteredSNPs} \
        --variant ${filteredIndels} \
        -O ${sample}.filtered.snps.indels.vcf
  }
  output {
    File filteredVCF = "${sample}.filtered.snps.indels.vcf"
  }
}
