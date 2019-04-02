
workflow align{

	File inputSamplesFile
        Array[Array[File]] Samples = read_tsv(inputSamplesFile)
        File refFasta

	scatter (sample in Samples){
	call bwa {input: RefFasta=refFasta,Sample=sample[0],F=sample[1],R=sample[2]}
	call SortSam {input: Sam=bwa.sam,Sample=sample[0]}
	call dedup {input: SamInput=SortSam.sortsam , Sample=sample[0]}
	call SamToBam {input: SamInput=dedup.DedupSam,Sample=sample[0]}
	call IndexBam {input: bam=SamToBam.Bam, Sample= sample[0]}

	}
 }


task bwa {

	File RefFasta
	String Sample
	File F
	File R

	command {
	
	bwa index ${RefFasta}
	bwa mem \
                -M \
                ${RefFasta} \
                ${F} \
                ${R} \
                > ${Sample}.sam

	}
 
	runtime {
	docker: "kittisak1803/mygenetools"
	}

	output{
		File sam = "${Sample}.sam"
	} 
}


task SortSam {

        File Sam
        String Sample

        command {
        java -jar /usr/gitc/picard.jar SortSam \
                I=${Sam} \
                O=${Sample}_sorted.sam \
                SORT_ORDER=coordinate
        }

	runtime {
        docker: "kittisak1803/mygenetools"
        }

        output {
        File sortsam = "${Sample}_sorted.sam"
        }
}


task dedup {

        File SamInput
        String Sample

        command {
        java -jar /usr/gitc/picard.jar MarkDuplicates \
                I=${SamInput} \
                M=Mark_duplicate.txt \
                O=${Sample}_NoDuplicates.sam \
                REMOVE_DUPLICATES=TRUE \
                REMOVE_SEQUENCING_DUPLICATES=TRUE
        }

	runtime {
        docker: "kittisak1803/mygenetools"
        }

        output {
        File DedupSam = "${Sample}_NoDuplicates.sam"
        }
}




task SamToBam {

        File SamInput
        String Sample

        command {
        java -jar  /usr/gitc/picard.jar SamFormatConverter \
                I=${SamInput} \
                O=${Sample}.bam
        }

	 runtime {
        docker: "kittisak1803/mygenetools"
        }

        output {
        File Bam = "${Sample}.bam"
        }
}


task IndexBam {

        File bam
        String Sample

        command {
        java -jar /usr/gitc/picard.jar  BuildBamIndex \
        I=${bam} \
        O=${Sample}.bam.bai
        }

	 runtime {
        docker: "kittisak1803/mygenetools"
        }

        output {
        File BamIndex = "${Sample}.bam.bai"
        }

}


