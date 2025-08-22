// kallisto
process KALLISTO_INDEX {

    label "process_medium"

	conda 'bioconda::kallisto'
	tag "KALLISTO_INDEX: $input_fasta_fnp"

	input:
	path input_fasta_fnp
    path output_index_fnp
    val kmer_size


	output:
	path output_index_fnp, emit: kallisto_index_fnp

    script:
    def extra_args = task.ext.args ? task.ext.args : ''

	"""
	#!/usr/bin/env bash

	## load module kallisto
	## module load CBI kallisto

    kallisto index -i ${output_index_fnp} ${input_fasta_fnp} -t ${task.cpus} -k ${kmer_size} ${extra_args}
	"""
}


