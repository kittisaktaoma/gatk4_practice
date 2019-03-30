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
                        sample=sample[0]
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
	String sample
	
	command {
	java -jar ${PIC} SortSam \
	      I=${Sam} \
              O=${sample}_sorted.bam \
	      SORT_ORDER=coordinate
	}

	output {
	File sortsam = "${sample}_sorted.bam"
        }
}

