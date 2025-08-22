// bowtie2 based alignment
process BOWTIE2_ALIGN_PAIRED {

    label "process_medium"

	publishDir "${params.outdir}/$pair_id/bowtie2", pattern: "*.bam*", mode: 'copy', overwrite: true
	publishDir "${params.outdir}/${pair_id}/logs", pattern: "*.bowtie2.log", mode: 'copy', overwrite: true

	tag "bowtie2: $pair_id"

	conda 'bioconda::bowtie2 bioconda::samtools'

	input:
    tuple path(bowtie2_index), val(pair_id), path(reads_r1), path(reads_r2)

	output:
    tuple val (pair_id), val("bowtie2"), path ("${pair_id}.sorted.bam"), path ("${pair_id}.sorted.bam.bai"), emit: id_with_sorted_bam
    path "${pair_id}.bowtie2.log", emit: bowtie2_log

	script:
    def extra_args = task.ext.args ?: ""

	"""
	#!/usr/bin/env bash

	# load modules
	# module load CBI bowtie2 samtools
    INDEX=`find -L ./ -name "*.rev.1.bt2" | sed "s/\\.rev.1.bt2\$//"`
    [ -z "\$INDEX" ] && INDEX=`find -L ./ -name "*.rev.1.bt2l" | sed "s/\\.rev.1.bt2l\$//"`
    [ -z "\$INDEX" ] && echo "Bowtie2 index files not found" 1>&2 && exit 1

	# alignment
	bowtie2 $extra_args --threads $task.cpus -x \$INDEX -1 ${reads_r1} -2 ${reads_r2} 2>| >(tee ${pair_id}.bowtie2.log >&2) | \
		samtools sort -@ $task.cpus -o ${pair_id}.sorted.bam

	# index bam
	samtools index ${pair_id}.sorted.bam
	"""
}
