workflow align{ }


task bwa {

	File RefFasta
	String Sample
	File F
	File R
	File MAP
	File Bam
	

	command <<<

		${MAP} ${RefFasta} ${Sample} ${F} ${R} ${Bam}

	>>>

	output{
		File sam = "${Sample}.sam"
	} 
}


task SortSam {

	File PIC
	File Sam
	String Sample
	
	command {
	java -jar ${PIC} SortSam \
		I=${Sam} \
                O=${Sample}_sorted.sam \
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
		M=Mark_duplicate.txt \
		O=${Sample}_NoDuplicates.sam \
		REMOVE_DUPLICATES=TRUE \
		REMOVE_SEQUENCING_DUPLICATES=TRUE
	}
	 
	output {
	File DedupSam = "${Sample}_NoDuplicates.sam"
	}
}


task SamToBam {

	File PIC
	File SamInput
	String Sample

	command {
	java -jar ${PIC} SamFormatConverter \
		I=${SamInput} \
		O=${Sample}.bam
	}
	
	output {
	File Bam = "${Sample}.bam"
	}
}


task IndexBam {
	File PIC
	File bam
	String Sample

	command {
	java -jar ${PIC} BuildBamIndex \
	I=${bam} \
	O=${Sample}.bam.bai
	}

	output {
	File BamIndex = "${Sample}.bam.bai"
	}
		
}
