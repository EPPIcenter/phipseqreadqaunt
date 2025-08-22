// target mapping stats
process MAPPING_STATISTICS {
    label "process_low"

	publishDir "${params.outdir}/${mapper}_mapping_statistics", mode: 'copy', overwrite: true

	tag "target mapping stats: $pair_id"

 	conda 'bioconda::samtools'

	input:
	tuple val(pair_id), val(mapper), path(bam_fnp), path(bam_bai_fnp)

	output:
    path "${pair_id}_mapping_stats_summary.tsv.gz", emit: mapping_stats_summary
	// path "${pair_id}_mapping.tab"
	// path "${pair_id}_mapping.summary.tab"
	// path "${pair_id}_mapping.paired_r1.tab"
	// path "${pair_id}_mapping.paired_r1.summary.tab"
	// path "${pair_id}_mapping.unfiltered.tab"
	// path "${pair_id}_mapping.unfiltered.summary.tab"
	// path "${pair_id}_mapping.semifiltered.tab"
	// path "${pair_id}_mapping.semifiltered.summary.tab"

 	//
	script:

	"""
	#!/usr/bin/env bash

	# load module
	# module load CBI samtools

	## unfiltered
	( samtools view -F 2304 ${bam_fnp} | \
		cut -f 3,6 >> ${pair_id}_mapping.unfiltered.tab && \
	cut -f 1 ${pair_id}_mapping.unfiltered.tab | uniq -c > ${pair_id}_mapping.unfiltered.summary.tab ) || \
	( echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.unfiltered.tab && \
	echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.unfiltered.summary.tab )

    ## strict filter based on CIGAR string (no insertion, deletion or clipping)
    ( samtools view -F 2304 ${bam_fnp} |  \
            cut -f 3,6  | \
            grep -e "[IDSH*]" -v >> ${pair_id}_mapping.tab && \
    cut -f 1 ${pair_id}_mapping.tab | uniq -c > ${pair_id}_mapping.filtered.summary.tab ) || \
    ( echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.filtered.tab && \
    echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.filtered.summary.tab )

    ## 'paired' files have inclusion flag -f 67 to select [paired, properly paired, first read in pair] for quantification
    ## strict filter, paired and first read in pair only
    ( samtools view -hF 2304 ${bam_fnp} | samtools view -f 67 |\
            cut -f 3,6  | \
            grep -e "[IDSH*]" -v >> ${pair_id}_mapping.paired_r1.tab && \
    cut -f 1 ${pair_id}_mapping.paired_r1.tab | uniq -c > ${pair_id}_mapping.paired_r1.summary.tab ) || \
    ( echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.paired_r1.tab && \
    echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.paired_r1.summary.tab )

    ## 'paired' files have inclusion flag -f 131 to select [paired, properly paired, second read in pair] for quantification
    ## strict filter, paired and first read in pair only
    ( samtools view -hF 2304 ${bam_fnp} | samtools view -f 131 |\
            cut -f 3,6  | \
            grep -e "[IDSH*]" -v >> ${pair_id}_mapping.paired_r2.tab && \
    cut -f 1 ${pair_id}_mapping.paired_r2.tab | uniq -c > ${pair_id}_mapping.paired_r2.summary.tab ) || \
    ( echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.paired_r2.tab && \
    echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.paired_r2.summary.tab )

	## semifiltered based on CIGAR string
	( samtools view -F 2304 ${bam_fnp} | \
		cut -f 3,6  | \
		grep -e "[ID*]" -v >> ${pair_id}_mapping.semifiltered.tab && \
	cut -f 1 ${pair_id}_mapping.tab | uniq -c > ${pair_id}_mapping.semifiltered.summary.tab ) || \
	( echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.semifiltered.tab && \
	echo "#${pair_id} had no good reads!" > ${pair_id}_mapping.semifiltered.summary.tab )

    # create one output file to append to for one singular output
    echo -e "count\ttarget_id\tclass" > ${pair_id}_mapping_stats_summary.tsv

    if [ "\$(wc -l < ${pair_id}_mapping.unfiltered.summary.tab)" -gt 1 ]; then
        awk 'BEGIN{OFS="\t"} NF>=2{print \$1,\$2,"unfiltered_r1_r2"}' \
            ${pair_id}_mapping.unfiltered.summary.tab >> ${pair_id}_mapping_stats_summary.tsv
    fi

    if [ "\$(wc -l < ${pair_id}_mapping.filtered.summary.tab)" -gt 1 ]; then
        awk 'BEGIN{OFS="\t"} NF>=2{print \$1,\$2,"filtered_clipping_and_indels_r1_r2"}' \
            ${pair_id}_mapping.filtered.summary.tab >> ${pair_id}_mapping_stats_summary.tsv
    fi

    if [ "\$(wc -l < ${pair_id}_mapping.paired_r1.summary.tab)" -gt 1 ]; then
        awk 'BEGIN{OFS="\t"} NF>=2{print \$1,\$2,"filtered_clipping_and_indels_proper_pair_r1"}' \
            ${pair_id}_mapping.paired_r1.summary.tab >> ${pair_id}_mapping_stats_summary.tsv
    fi

    if [ "\$(wc -l < ${pair_id}_mapping.paired_r2.summary.tab)" -gt 1 ]; then
        awk 'BEGIN{OFS="\t"} NF>=2{print \$1,\$2,"filtered_clipping_and_indels_proper_pair_r2"}' \
            ${pair_id}_mapping.paired_r2.summary.tab >> ${pair_id}_mapping_stats_summary.tsv
    fi

    if [ "\$(wc -l < ${pair_id}_mapping.semifiltered.summary.tab)" -gt 1 ]; then
        awk 'BEGIN{OFS="\t"} NF>=2{print \$1,\$2,"filtered_indels_r1_r2"}' \
            ${pair_id}_mapping.semifiltered.summary.tab >> ${pair_id}_mapping_stats_summary.tsv
    fi

    gzip ${pair_id}_mapping_stats_summary.tsv

    """

}
