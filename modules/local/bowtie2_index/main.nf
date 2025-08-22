// bowtie2
process BOWTIE2_INDEX {

    label "process_low"

	conda 'bioconda::bowtie2'
	tag "bowtie2_INDEX: $input_fasta_fnp"

	input:
	path input_fasta_fnp

	output:
	path("bowtie2"), emit: bowtie2_index

    script:
    def prefix = task.ext.prefix ?: "${input_fasta_fnp.baseName}"
    def args   = task.ext.args ?: ''

	"""
	#!/usr/bin/env bash

	## load module bowtie2
	## module load CBI bowtie2
    mkdir bowtie2
    bowtie2-build $args --threads $task.cpus $input_fasta_fnp bowtie2/${prefix}
	"""
}
