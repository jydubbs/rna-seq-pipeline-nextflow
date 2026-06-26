#!/usr/bin/env nextflow

params.samples = "samples.csv"
params.index = "${launchDir}/reference/genome_index"
params.annotation = "${launchDir}/reference/gencode.v45.annotation.gtf"

process TRIM {
    module 'trimgalore/0.6.10'
    publishDir "data/trimmed", pattern: "*.fq", mode: 'copy'
    publishDir "results/trimgalore", pattern: "*.{txt,html,zip}", mode: 'copy'

    input:
    tuple val(sample_id), val(condition), path(r1), path(r2)

    output:
    tuple val(sample_id), val(condition), path("${sample_id}_val_1.fq"), path("${sample_id}_val_2.fq")

    script:
    """
    trim_galore \
      --paired \
      --quality 20 \
      --length 35 \
      --cores 4 \
      --basename ${sample_id} \
      ${r1} ${r2}
    """
}

process ALIGN_HISAT2 {
    module 'hisat2/2.2.1-gcc-12.2.0-g5omdki'
    publishDir "results/hisat2", pattern: "*.log", mode: 'copy'

    input:
    tuple val(sample_id), val(condition), path(r1), path(r2)

    output:
    tuple val(sample_id), val(condition), path("${sample_id}.sam"), path("${sample_id}.hisat2.log")

    script:
    """
    hisat2 \
      -x ${params.index} \
      -1 ${r1} \
      -2 ${r2} \
      -p 4 \
      -S ${sample_id}.sam \
      2> ${sample_id}.hisat2.log
    """
}

process SORT_BAM {
    module 'samtools/1.19.2-python-3.11.7-gcc-12.2.0'

    publishDir "results/bam", pattern: "*.sorted.bam", mode: 'copy'

    input:
    tuple val(sample_id), val(condition), path(sam), path(log)

    output:
    tuple val(sample_id), val(condition), path("${sample_id}.sorted.bam")

    script:
    """
    samtools view -@ 4 -bS ${sam} | \
    samtools sort -@ 4 -o ${sample_id}.sorted.bam
    """
}

process INDEX_BAM {
    module 'samtools/1.19.2-python-3.11.7-gcc-12.2.0'

    publishDir "results/bam", pattern: "*.bai", mode: 'copy'

    input:
    tuple val(sample_id), val(condition), path(bam)

    output:
    tuple val(sample_id), val(condition), path(bam), path("${bam}.bai")

    script:
    """
    samtools index ${bam}
    """
}

process FEATURECOUNTS {
    module 'subread/2.0.6-gcc-12.2.0'

    publishDir "results/counts", mode: 'copy'

    input:
    path bam_files

    output:
    path "gene_counts.txt"
    path "gene_counts.txt.summary"

    script:
    """
    featureCounts \
      -a ${params.annotation} \
      -o gene_counts.txt \
      -p \
      -t exon \
      -g gene_id \
      ${bam_files}
    """
}

workflow {
    fastq_ch = Channel
        .fromPath(params.samples)
        .splitCsv(header: true)
        .map { row ->
            tuple(
                row.sample_id,
                row.condition,
                file("data/raw/${row.sample_id}_1.fastq"),
                file("data/raw/${row.sample_id}_2.fastq")
            )
        }
    trimmed_ch = TRIM(fastq_ch)
    sam_ch = ALIGN_HISAT2(trimmed_ch)
    sorted_bam_ch = SORT_BAM(sam_ch)
    indexed_bam_ch = INDEX_BAM(sorted_bam_ch)

    bam_files_ch = indexed_bam_ch.map { sample_id, condition, bam, bai -> bam }.collect()

    FEATURECOUNTS(bam_files_ch)
}

