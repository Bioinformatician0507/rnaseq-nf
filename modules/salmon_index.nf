process SALMON_INDEX {
    container 'quay.io/biocontainers/salmon:1.10.1--h7e5ed60_0'
    publishDir "${params.outdir}/salmon_index", mode: 'copy'

    input:
    path transcript_fasta
    path genome_fasta

    output:
    path "salmon_index", emit: index

    script:
    """
    grep '^>' $genome_fasta | cut -d ' ' -f 1 | sed 's/^>//' > decoys.txt
    cat $transcript_fasta $genome_fasta > gentrome.fa

    salmon index \\
        -t gentrome.fa \\
        -d decoys.txt \\
        -i salmon_index \\
        -k 31 \\
        -p $task.cpus
    """
}
