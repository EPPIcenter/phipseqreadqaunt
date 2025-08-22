// bwa based alignment
process BWA_ALIGN_PAIRED {

    label "process_medium"

	publishDir "${params.outdir}/$pair_id", mode: 'copy', overwrite: true

	tag "bwa: $pair_id"

	conda 'bioconda::bwa bioconda::samtools'

	input:
    tuple path(bwa_index), val(pair_id), path(reads_r1), path(reads_r2)

	output:
    tuple val (pair_id), path ("${pair_id}.sorted.bam"), path ("${pair_id}.sorted.bam.bai"), emit: id_with_sorted_bam

	script:

	"""
	#!/usr/bin/env bash

	# load modules
	# module load CBI bwa samtools
    INDEX=`find -L ./ -name "*.amb" | sed 's/\\.amb\$//'`

	# alignment
	bwa mem -M -t $task.cpus \$INDEX ${reads_r1} ${reads_r2} | \
		samtools sort -@ $task.cpus -o ${pair_id}.sorted.bam

	# index bam
	samtools index ${pair_id}.sorted.bam
	"""
}
