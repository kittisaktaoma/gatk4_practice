workflow combinegvcf {

	File inputSamplesFile
	Array[Array[File]] Samples = read_tsv(inputSamplesFile)
	File refFasta
	File refIndex
	File refDict

	scatter (sample in Samples) {
		call HaplotypeCallerERC {
		input:
			RefFasta=refFasta,
			RefIndex=refIndex,
			RefDict=refDict,
			Sample=sample[0],
			BamFile=sample[1],
			BamIndex=sample[2]
			}
	}
  call CombineGVCFs {
		input:
			RefFasta=refFasta,
			RefIndex=refIndex,
			RefDict=refDict,
			Sample="Tutorial",
			GVCFs=HaplotypeCallerERC.GVCF
			}

 	call GenotypeGVCFs{
		input:
    	RefFasta=refFasta,
      RefIndex=refIndex,
      RefDict=refDict,
      Sample="CHS",
      cGVCFs=CombineGVCFs.CombineGVCFs
			}

}

  task HaplotypeCallerERC {
    File RefFasta
    File RefIndex
    File RefDict
    String Sample
    File BamFile
    File BamIndex

   command {
    /gatk/gatk  HaplotypeCaller \
                -ERC GVCF \
                -R ${RefFasta} \
                -I ${BamFile} \
                -O ${Sample}.g.vcf
  }

  runtime {
  	docker: "broadinstitute/gatk:4.1.0.0"
  }

  output {
   File  GVCF = "${Sample}.g.vcf"
  }
}

  task CombineGVCFs {
    File RefFasta
    File RefIndex
    File RefDict
    String Sample
    Array[File] GVCFs

  command {
    /gatk/gatk CombineGVCFs \
        -R ${RefFasta} \
        --variant ${sep=" -V " GVCFs} \
        -O ${Sample}.g.vcf
  }

   runtime {
   	docker: "broadinstitute/gatk:4.1.0.0"
  }

  output {
    File CombineGVCFs = "${Sample}.g.vcf"
  }
}


 task GenotypeGVCFs {
    File RefFasta
    File RefIndex
    File RefDict
    File cGVCFs
    String Sample

  command {
   /gatk/gatk  --java-options "-Xmx4g" GenotypeGVCFs \
   -R ${RefFasta} \
   -V ${cGVCFs} \
   -O ${Sample}.vcf
  }

   runtime {
   docker: "broadinstitute/gatk:4.1.0.0"
  }

   output {
    File RawVCF = "${Sample}.vcf"
  }
}
