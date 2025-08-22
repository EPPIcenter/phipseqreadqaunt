// cutadapt based quality filtering and QC
// Filter to only reads with primer detected and trim poly-g
process CUTADAPT {
    label "process_low"
	conda 'bioconda::cutadapt'

	publishDir "${params.outdir}/$pair_id",
		saveAs: {filename ->
			if (filename.indexOf(".fastq.gz") > 0) "filtered/$filename"
			else if (filename.indexOf(".cutadapt.log") > 0) "logs/$filename"
			else filename
		}, mode: 'copy', overwrite: true

	tag "cudadapt: $pair_id"

	input:
    // consume a single channel of tuples
    tuple val(pair_id), path(reads_r1), path(reads_r2), val(forward_linker_5_3), val(reverse_linker_5_3)

	output:
    tuple val(pair_id), path("filtered_${pair_id}_R1.fastq.gz"), path("filtered_${pair_id}_R2.fastq.gz"), emit: id_with_trimmed_pairs
    path("${pair_id}.cutadapt.log"), emit: cutadapt_log

	script:
	"""
	#!/usr/bin/env bash

	## load module
	## module load CBI cutadapt

	## cutadapt to remove phip-seq primers and poly-g tails
	cutadapt \
	    --action=trim \
        --nextseq-trim=20 \
        --discard-untrimmed \
        -g ^NNN${forward_linker_5_3} -g ^NN${forward_linker_5_3} -g ^N${forward_linker_5_3} -g ^${forward_linker_5_3} \
		-G ^NNN${reverse_linker_5_3} -G ^NN${reverse_linker_5_3} -G ^N${reverse_linker_5_3} -G ^${reverse_linker_5_3} \
        -o filtered_${pair_id}_R1.fastq.gz \
        -p filtered_${pair_id}_R2.fastq.gz \
        ${reads_r1} \
        ${reads_r2} \
        --cores ${task.cpus}
        > ${pair_id}.cutadapt.log
	"""
}
