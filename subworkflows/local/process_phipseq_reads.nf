#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { BOWTIE2_ALIGN_PAIRED } from '../../modules/local/bowtie2_align'
include { BOWTIE2_INDEX } from '../../modules/local/bowtie2_index'
include { BWA_ALIGN_PAIRED } from '../../modules/local/bwa_align'
include { BWA_INDEX } from '../../modules/local/bwa_index'
include { CUTADAPT } from '../../modules/local/cutadapt'
include { FASTP } from '../../modules/local/fastp'
include { KALLISTO_INDEX } from '../../modules/local/kallisto_index'
include { KALLISTO_QUANT_PAIRED } from '../../modules/local/kallisto_quant'
include { MAPPING_STATISTICS as MAPPING_STATISTICS_BWA } from '../../modules/local/mapping_statistics'
include { MAPPING_STATISTICS as MAPPING_STATISTICS_BOWTIE2 } from '../../modules/local/mapping_statistics'


workflow PROCESS_PHIPSEQ_READS_COUNTS {
    take:
    reads
    targets_fnp
    output_dir
    do_kallisto
    do_bwa
    do_bowtie2
    forward_linker_5_3
    reverse_linker_5_3

    main:

    // getting reads
    Channel
        .fromFilePairs(reads)
        .ifEmpty { error "Cannot find any reads matching: ${reads}" }
        .set { read_pairs }
    // Reshape read_pairs into (pair_id, R1, R2)
    // remove adapters and do some qc
    read_pairs
        .map { id, reads_paired_fnps ->
            tuple(id, reads_paired_fnps[0], reads_paired_fnps[1], forward_linker_5_3, reverse_linker_5_3)
            } | CUTADAPT

    CUTADAPT.out.id_with_trimmed_pairs.set { trimmed_pairs }
    // kallisto
    if (do_kallisto){
        KALLISTO_INDEX(
            file(targets_fnp),
            file("${targets_fnp}.kallisto.idx"),
            params.kallisto_kmer_size
        )
        trimmed_pairs
            .combine( KALLISTO_INDEX.out.kallisto_index_fnp )
            .map { id, r1, r2, idx -> tuple(idx, id, r1, r2, params.kallisto_bootstraps) }
            | KALLISTO_QUANT_PAIRED
    }

    if(do_bwa){
        BWA_INDEX(file(targets_fnp))

        // Combine index list with trimmed pairs into 4-tuples
        bwa_align_in = BWA_INDEX.out.bwa_index
            .combine(trimmed_pairs)                     // (idx_list) x (id, r1, r2)
            .map { bwa_idx, id, r1, r2 -> tuple(bwa_idx, id, r1, r2) }

        // Call the process with the *single* tuple channel
        BWA_ALIGN_PAIRED(bwa_align_in)

        BWA_ALIGN_PAIRED.out.id_with_sorted_bam | MAPPING_STATISTICS_BWA
    }

    if(do_bowtie2){
        BOWTIE2_INDEX(file(targets_fnp))

        // Combine index list with trimmed pairs into 4-tuples
        bowtie2_align_in = BOWTIE2_INDEX.out.bowtie2_index
            .combine(trimmed_pairs)                     // (idx_list) x (id, r1, r2)
            .map { bowtie2_idx, id, r1, r2 -> tuple(bowtie2_idx, id, r1, r2) }

        // Call the process with the *single* tuple channel
        BOWTIE2_ALIGN_PAIRED(bowtie2_align_in)

        BOWTIE2_ALIGN_PAIRED.out.id_with_sorted_bam | MAPPING_STATISTICS_BOWTIE2
    }
}

