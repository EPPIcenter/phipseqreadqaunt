# phipseqreadqaunt
A nextflow pipeline for quantifying Phip-Seq sequenced libraries


Example

```
nextflow run phipseqreadqaunt/main.nf  --reads "fastq/*{R1,R2}.fastq.gz" --targets_fnp references/all_falciparome_targets_no_primer.fasta --forward_linker_5_3 GTGGTTGGTGCTGTAGGAGCA --reverse_linker_5_3 GAGGCCATGGCATATGCTTATCA  --outdir phipseqreadqaunt_counts --do_bwa --do_kallisto --do_bowtie2
```
## Input
### Required input

- **\-\-reads** - A file pattern to specify the raw paired end input
- **\-\-targets_fnp** - The fasta with the targets sequence with the linkers removed
- **\-\-forward\_linker\_5\_3** - The forward linker to be checked for and removed by cutadapt
- **\-\-reverse\_linker\_5\_3** - The reverse linker to be checked for and removed by cutadapt
- **\-\-outdir** - Output directory to but the processed counts, will overwrite if it exists already

In additional `--do_bwa` or `--do_kallisto` or both need to be supplied

Reads will be processed with cutadapt for quality trimming and removing linker sequences. Reads will then be counted by `bwa`, `kallisto`, or both.

### Optional input


- **\-\-do_bwa** - Output counts by using BWA alignments
- **\-\-do_bowtie2** - Output counts by using BOWTIE2 alignments
- **\-\-do_kallisto** - Output counts by using kallisto


