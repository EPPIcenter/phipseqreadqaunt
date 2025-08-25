// further filtering

process FASTP {
    label "process_medium"
	conda 'bioconda::fastap'

	tag "fastp: $pair_id"
	publishDir "${params.outdir}/$pair_id",
		saveAs: {filename ->
			if (filename.indexOf(".fastq.gz") > 0) "filtered/$filename"
			else if (filename.indexOf(".json") > 0) "logs/$filename"
            else if (filename.indexOf(".html") > 0) "logs/$filename"
			else filename
		}, mode: 'copy', overwrite: true

	input:
	tuple val(pair_id), path(reads_r1), path(reads_r2), val(merge)

	output:
	tuple val(pair_id), path("fastp_filtered_${pair_id}_R1.fastq.gz"), path("fastp_filtered_${pair_id}_R2.fastq.gz"), emit: id_with_trimmed_pairs
    tuple val(pair_id), path("merged_${pair_id}.fastq.gz"), optional: true, emit: id_with_merged_fnp
	path("fastp_${pair_id}.json"), emit: fastp_json_log
	path("fastp_${pair_id}.html"), emit: fastp_html_log



	script:

    def merge_args = merge ? "-m --merged_out fastp_merged_${pair_id}.fastq.gz" : ''

	"""
	#!/usr/bin/env bash

	## load module
	## module load CBI fastp
    fastp \
        --in1 ${reads_r1} \
        --in2 ${reads_r2} \
        --out1 fastp_filtered_${pair_id}_R1.fastq.gz \
        --out2 fastp_filtered_${pair_id}_R2.fastq.gz \
        --thread ${task.cpus} \
        --trim_poly_g \
        --low_complexity_filter \
        -j fastp_${pair_id}.json \
        -h fastp_${pair_id}.html  \
        ${merge_args}
	"""
}
