// target mapping stats
process MAPPING_STATISTICS {
    label "process_low"

	publishDir "${params.outdir}/$pair_id", mode: 'copy', overwrite: true

	tag "target mapping stats: $pair_id"

 	conda 'bioconda::samtools'

	input:
	tuple val(pair_id), path(bam_fnp), path(bam_bai_fnp)

	output:
	path "${pair_id}_mapping.tab"
	path "${pair_id}_mapping.summary.tab"
	path "${pair_id}_mapping.paired.tab"
	path "${pair_id}_mapping.paired.summary.tab"
	path "${pair_id}_mapping.unfiltered.tab"
	path "${pair_id}_mapping.unfiltered.summary.tab"
	path "${pair_id}_mapping.semifiltered.tab"
	path "${pair_id}_mapping.semifiltered.summary.tab"

 	//
	script:

	"""
	#!/usr/bin/env bash

	# load module
	# module load CBI samtools

    ## 'paired' files have inclusion flag -f 67 to select [paired, properly paired, first read in pair] for quantification

    ## strict filter based on CIGAR string (no insertion, deletion or clipping)
    ( samtools view -F 2304 ${bam_fnp} |  \
            cut -f 3,6  | \
            grep -e "[IDSH*]" -v >> ${pair_id}_mapping.tab && \
    cut -f 1 ${pair_id}_mapping.tab | uniq -c > ${pair_id}_mapping.summary.tab ) || \
    ( echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.tab && \
    echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.summary.tab )

    ## strict filter, paired and first read in pair only
    ( samtools view -hF 2304 ${bam_fnp} | samtools view -f 67 |\
            cut -f 3,6  | \
            grep -e "[IDSH*]" -v >> ${pair_id}_mapping.paired.tab && \
    cut -f 1 ${pair_id}_mapping.paired.tab | uniq -c > ${pair_id}_mapping.paired.summary.tab ) || \
    ( echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.paired.tab && \
    echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.paired.summary.tab )

	## semifiltered based on CIGAR string
	( samtools view -F 2304 ${bam_fnp} | \
		cut -f 3,6  | \
		grep -e "[ID*]" -v >> ${pair_id}_mapping.semifiltered.tab && \
	cut -f 1 ${pair_id}_mapping.tab | uniq -c > ${pair_id}_mapping.semifiltered.summary.tab ) || \
	( echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.semifiltered.tab && \
	echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.semifiltered.summary.tab )

	## unfiltered
	( samtools view -F 2304 ${bam_fnp} | \
		cut -f 3,6 >> ${pair_id}_mapping.unfiltered.tab && \
	cut -f 1 ${pair_id}_mapping.unfiltered.tab | uniq -c > ${pair_id}_mapping.unfiltered.summary.tab ) || \
	( echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.unfiltered.tab && \
	echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.unfiltered.summary.tab )
	"""

}
