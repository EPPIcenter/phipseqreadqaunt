// kallisto pseudoalignment
process KALLISTO_QUANT_PAIRED {

    label "process_medium"
	publishDir "${params.outdir}/kallisto_quant/", pattern: "*.tsv.gz", mode: 'copy', overwrite: true
	publishDir "${params.outdir}/${pair_id}/logs", pattern: "*.json", mode: 'copy', overwrite: true

	conda 'bioconda::kallisto'

	tag "kallisto quant: $pair_id"

	input:
    tuple path(kallisto_index), val(pair_id), path(read_r1), path(read_r2), val(bootstraps)

	output:
	path ("${pair_id}_abundance.tsv.gz"), emit: abundance_fnp
	path ("${pair_id}_kallisto_run_info.json"), emit: kallisto_quant_log


	script:
    def extra_args = task.ext.args ? task.ext.args : ''

	"""
	#!/usr/bin/env bash

	## load module kallisto
	## module load CBI kallisto

	## kallisto quant, bootstraps = 100

	mkdir kallisto_${pair_id}

	kallisto quant -t ${task.cpus} -i ${kallisto_index} -o kallisto_${pair_id} -b ${bootstraps} ${read_r1} ${read_r2} ${extra_args}

	## link the abundance.tsv file so it's easier to export
    gzip ./kallisto_${pair_id}/abundance.tsv
	ln -s ./kallisto_${pair_id}/abundance.tsv.gz ${pair_id}_abundance.tsv.gz
    ln -s ./kallisto_${pair_id}/run_info.json ${pair_id}_kallisto_run_info.json
	## kallisto quant pseudobam NOT WORKING

	## kallisto quant -i ${kallisto_index} -o kallisto_${pair_id} -b ${bootstraps} ${read_r1} ${read_r2} --pseudobam | samtools view -Sb -> ${pair_id}.pseudo.bam

	"""
}
