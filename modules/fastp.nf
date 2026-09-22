process FASTP {
    tag "$meta.id"
    container 'quay.io/biocontainers/fastp:0.23.4--h5f740d0_0'
    publishDir "${params.outdir}/fastp", mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.trim.fastq.gz"), emit: reads
    tuple val(meta), path("*.fastp.json"),    emit: json
    tuple val(meta), path("*.fastp.html"),    emit: html

    script:
    if (meta.single_end) {
        """
        fastp --in1 ${reads} \\
            --out1 ${meta.id}.trim.fastq.gz \\
            --json ${meta.id}.fastp.json --html ${meta.id}.fastp.html \\
            --thread $task.cpus
        """
    } else {
        """
        fastp --in1 ${reads[0]} --in2 ${reads[1]} \\
            --out1 ${meta.id}_1.trim.fastq.gz --out2 ${meta.id}_2.trim.fastq.gz \\
            --detect_adapter_for_pe \\
            --json ${meta.id}.fastp.json --html ${meta.id}.fastp.html \\
            --thread $task.cpus
        """
    }
}
