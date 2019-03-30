workflow align{
	
	File Input
	Array[Array[File]] Samples = read_tsv(Input)
	File refFasta
        File pic
	

	scatter (sample in Samples) {
		
		call bwa {
			input: RefFasta=refFasta,
			Sample=sample[0],
			F=sample[1],
			R=sample[2]
		}

		call SortSam {
			input: PIC=pic,
                        Sam=bwa.sam,
                        Sample=sample[0]
		}

		call dedup {
			input: PIC=pic,
                        SamInput=SortSam.sortsam,
                        Sample=sample[0]
		}
		
		call SamToBam {
			input: PIC=pic,
                        SamInput=dedup.DedupSam,
                        Sample=sample[0]
		}
	}
}


task bwa {

	File RefFasta
	String Sample
	File F
	File R

	command{
		bwa index \
		    ${RefFasta}
		bwa aln \
		    ${RefFasta} \
		    ${F} \
		    > ${Sample}_F.sai
		bwa aln \
		    ${RefFasta} \
		    ${R} \
		    > ${Sample}_R.sai
		bwa sampe \
		    ${RefFasta} \
		    ${Sample}_F.sai \
		    ${Sample}_R.sai \
                    ${F} \
		    ${R} \
                    > ${Sample}.sam
	}
	output{
		File sam = "${Sample}.sam"
		String name = "${Sample}"
	} 
}	


task SortSam {

	File PIC
	File Sam
	String Sample
	
	command {
	java -jar ${PIC} SortSam \
		I=${Sam} \
                O=${Sample}_sorted.bam \
	        SORT_ORDER=coordinate
	}

	output {
	File sortsam = "${Sample}_sorted.sam"
        }
}



task dedup {

	File PIC
	File SamInput
	String Sample

	command {
	java -jar ${PIC} MarkDuplicates \
		I=${SamInput} \
		O=${Sample}_NoDuplicates.sam \
		--REMOVE_DUPLICATE=TRUE \
		--REMOVE_SEQUENCING_DUPLICATES=TRUE
	}
	 
	output {
	File DedupSam = "${Sample}_NoDuplicates.sam"
	}
}


task SamToBam {

	File PIC
	File SamInput
	File Sample

	command {
	java -jar ${PIC} SamFormatConverter \
		I=${SamInput} \
		O=${Sample}.bam
	}
	
	output {
	File Bam = "${Sample}.bam"
	}
}
