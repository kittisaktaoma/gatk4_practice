workflow joinGenotype {
 
  File inputSamplesFile
  Array[Array[File]] inputSamples = read_tsv(inputSamplesFile)
  File gatk
  File gatk_jar
  File refFasta
  File refIndex
  File refDict

  scatter (sample in inputSamples) {
    call HaplotypeCallerERC {
        input: GATK=gatk,
        GATK_jar=gatk_jar, 
        RefFasta=refFasta, 
        RefIndex=refIndex, 
        RefDict=refDict, 
        Sample=sample[0],
        BamFile=sample[1], 
        BamIndex=sample[2]
  }
  }

  call CombineGVCFs {  
      input: GATK=gatk,
      GATK_jar=gatk_jar, 
      RefFasta=refFasta, 
      RefIndex=refIndex, 
      RefDict=refDict, 
      Sample="CEUtrio", 
      GVCFs=HaplotypeCallerERC.GVCF
}

 call GenotypeGVCFs{
      input: GATK=gatk,
      GATK_jar=gatk_jar,
      RefFasta=refFasta,
      RefIndex=refIndex,
      RefDict=refDict,
      Sample="raw_varaint",
      cGVCFs=CombineGVCFs.CombineGVCFs
}


}


  task HaplotypeCallerERC {
    File GATK
    File GATK_jar
    File RefFasta
    File RefIndex
    File RefDict
    String Sample
    File BamFile
    File BamIndex

  command {
    ${GATK} --java-options "-Xmx4g" HaplotypeCaller \
             -ERC GVCF \
             -R ${RefFasta} \
             -I ${BamFile} \
             -O ${Sample}.g.vcf 
  }
  output {
    File GVCF = "${Sample}.g.vcf"
  }

  }

  task CombineGVCFs {
    File GATK
    File GATK_jar
    File RefFasta
    File RefIndex
    File RefDict
    String Sample
    Array[File] GVCFs

  command {
    ${GATK} CombineGVCFs \
        -R ${RefFasta} \
        --variant ${sep=" -V " GVCFs} \
        -O ${Sample}.g.vcf
  }
  output {
    File CombineGVCFs = "${Sample}.g.vcf"
  }
}


 task GenotypeGVCFs {

    File GATK
    File GATK_jar
    File RefFasta
    File RefIndex
    File RefDict
    File cGVCFs
    String Sample

  command {
   ${GATK} --java-options "-Xmx4g" GenotypeGVCFs \
   -R ${RefFasta} \
   -V ${cGVCFs} \
   -O ${Sample}.vcf
  }
   output {
    File RawVCF = "${Sample}.vcf"
  }
}
