process DESEQ2 {
    container 'rnaseq-nf-deseq2:latest'
    publishDir "${params.outdir}/deseq2", mode: 'copy'

    input:
    path quant_dirs
    path metadata
    path gtf

    output:
    path "deseq2_results.csv", emit: results
    path "volcano_plot.png",   emit: plot

    script:
    """
    make_tx2gene.sh $gtf
    deseq2.R . $metadata tx2gene.tsv .
    """
}
