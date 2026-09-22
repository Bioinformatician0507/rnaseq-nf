process SALMON_QUANT {
    tag "$meta.id"
    container 'quay.io/biocontainers/salmon:1.10.1--h7e5ed60_0'
    publishDir "${params.outdir}/salmon_quant", mode: 'copy'

    input:
    tuple val(meta), path(reads)
    path index

    output:
    tuple val(meta), path("${meta.id}"), emit: results

    script:
    def lib_type = '--libType A'
    if (meta.single_end) {
        """
        salmon quant \\
            -i $index \\
            $lib_type \\
            -r ${reads} \\
            -p $task.cpus \\
            --validateMappings \\
            -o ${meta.id}
        """
    } else {
        """
        salmon quant \\
            -i $index \\
            $lib_type \\
            -1 ${reads[0]} -2 ${reads[1]} \\
            -p $task.cpus \\
            --validateMappings \\
            -o ${meta.id}
        """
    }
}
