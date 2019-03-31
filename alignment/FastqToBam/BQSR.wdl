workflow align{
	
	File gatk
	File gatk_jar
	File Input
	Array[Array[File]] Samples = read_tsv(Input)
	File refFasta
	File refIndex
	File refDict
	File hgp
	File mills
	File hgp_idx
        File mills_idx
	

	scatter (sample in Samples) {
		
		call BQSR_CV {

			input: GATK=gatk,
                        GATK_jar=gatk_jar,
                        BamInput=SamToBam.Bam,
                        RefFasta=refFasta,
			RefIndex=refIndex,
                        RefDict=refDict,
                        Mills=mills,
                        HGP=hgp,
                        Mills_idx=mills_idx,
                        HGP_idx=hgp_idx
                        
		}

		call Apply_QS {
			input: 
			GATK=gatk,
			GATK_jar=gatk_jar,
			BamInput=SamToBam.Bam,
                        RefFasta=refFasta,
			RefIndex=refIndex,
                        RefDict=refDict,
                        Table=BQSR_CV.table,
                        Sample=sample[0]
		}

	}
}


task BQSR_CV {
	
	File GATK
	File GATK_jar
	File BamInput
	File RefFasta
	File RefIndex
        File RefDict
	File Mills
	File HGP
	File Mills_idx
        File HGP_idx

	command {
		${GATK} --java-options "-Xmx7g"  BaseRecalibrator \
		-I ${BamInput} \
                -R ${RefFasta} \
                --known-sites ${Mills} \
                --known-sites ${HGP} \
		-O recal_data.table
	}

	output {
	File table = "recal_data.table"
	}
}

task Apply_QS {

	File GATK
	File GATK_jar
	File RefFasta
	File RefIndex
	File RefDict
	File BamInput
	File Table
	String Sample

	command{
	 ${GATK} ApplyBQSR \
		-R ${RefFasta} \
		-I ${BamInput} \
		--bqsr-recal-file ${Table} \
                -O ${Sample}_final_QC.bam
	}
	
	output{
	File Final_bam = "${Sample}_final_QC.bam"	
	}
}



