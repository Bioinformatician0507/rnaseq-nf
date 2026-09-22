process FASTQC {
    tag "$meta.id"
    container 'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0'
    publishDir "${params.outdir}/fastqc", mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.zip"),  emit: zip
    tuple val(meta), path("*.html"), emit: html

    script:
    """
    fastqc --threads $task.cpus $reads
    """
}
