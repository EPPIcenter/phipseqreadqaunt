// bwa
process BWA_INDEX {

    label "process_low"
    memory { 6.B * input_fasta_fnp.size() }

	conda 'bioconda::bwa'
	tag "bwa_INDEX: $input_fasta_fnp"

	input:
	path input_fasta_fnp

	output:
	path("bwa"), emit: bwa_index

    script:
    def prefix = task.ext.prefix ?: "${input_fasta_fnp.baseName}"
    def args   = task.ext.args ?: ''

	"""
	#!/usr/bin/env bash

	## load module bwa
	## module load CBI bwa
    mkdir bwa
    bwa \\
        index \\
        $args \\
        -p bwa/${prefix} \\
        $input_fasta_fnp
	"""
}
