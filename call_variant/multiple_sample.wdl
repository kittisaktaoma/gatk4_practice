import "../alignment/FastqToBam/alignment.wdl" as aln

workflow joinGenotype {
 
  File inputSamplesFile
  Array[Array[File]] Samples = read_tsv(inputSamplesFile)
  File gatk
  File picard
  File gatk_jar
  File refFasta
  File refIndex
  File refDict
  File mapping
  File bam_RG

  scatter (sample in Samples) {

  call aln.bwa {
	input: 
	Sample=sample[0],
	RefFasta=refFasta,
	F=sample[1],
	R=sample[2],
        MAP=mapping,
	Bam=bam_RG
	}

  call aln.SortSam {
	input:
	PIC=picard,
	Sam=bwa.sam,
	Sample=sample[0]
	}

  call aln.dedup {
	input:
	PIC=picard,
	SamInput=SortSam.sortsam,
	Sample=sample[0]
	}

  call aln.SamToBam {
	input:
	PIC=picard,
        SamInput=dedup.DedupSam,
        Sample=sample[0]
	}

  call aln.IndexBam {
       input:
	PIC=picard, 
	bam=SamToBam.Bam,
        Sample=sample[0]
      }

  
  call HaplotypeCallerERC {
        input: GATK=gatk,
        GATK_jar=gatk_jar, 
        RefFasta=refFasta, 
        RefIndex=refIndex, 
        RefDict=refDict, 
        Sample=sample[0],
        BamFile=SamToBam.Bam, 
        BamIndex=IndexBam.BamIndex
  }
  

  call CombineGVCFs {  
      input: GATK=gatk,
      GATK_jar=gatk_jar, 
      RefFasta=refFasta, 
      RefIndex=refIndex,
      RefDict=refDict, 
      Sample=sample[0], 
      GVCFs=HaplotypeCallerERC.GVCF
}

 call GenotypeGVCFs{
      input: GATK=gatk,
      GATK_jar=gatk_jar,
      RefFasta=refFasta,
      RefIndex=refIndex,
      RefDict=refDict,
      Sample=sample[0],
      cGVCFs=CombineGVCFs.CombineGVCFs
}

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
