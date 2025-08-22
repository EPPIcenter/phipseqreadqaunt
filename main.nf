#!/usr/bin/env nextflow
nextflow.enable.dsl = 2


include { PROCESS_PHIPSEQ_READS_COUNTS } from './subworkflows/local/process_phipseq_reads'


workflow {

main:
    // Validate inputs
    if (params.reads == null  || params.genome_fnp == null || params.outdir == null || params.forward_linker_5_3 == null || params.reverse_linker_5_3 == null) {
        error "flags '--reads', '--genome_fnp', '--forward_linker_5_3', '--reverse_linker_5_3', and '--outdir' must be specified!"
    }
    if(params.do_bwa == null && params.do_kallisto == null){
        error "have to have at least one of --do_bwa or --do_kallisto"
    }
    do_kallito = params.do_kallisto == null ? false : true
    do_bwa = params.do_bwa == null ? false : true

    // Create output directory if not exists and overwrite if it does
    def results_dir_obj = file(params.outdir)
    if (results_dir_obj.exists()){
        results_dir_obj.deleteDir()
    }
    results_dir_obj.mkdirs()

    PROCESS_PHIPSEQ_READS_COUNTS(params.reads,
    params.genome_fnp,
    params.outdir,
    do_kallito,
    do_bwa,
    params.forward_linker_5_3,
    params.reverse_linker_5_3)

}

