# rnaseq-nf

[![CI](https://github.com/Bioinformatician0507/rnaseq-nf/actions/workflows/ci.yml/badge.svg)](https://github.com/Bioinformatician0507/rnaseq-nf/actions/workflows/ci.yml)

A reproducible Nextflow pipeline for bulk RNA-seq differential expression analysis, from raw reads to a volcano plot.

## Pipeline

1. **QC** — FastQC on raw reads
2. **Trimming** — fastp adapter/quality trimming
3. **Quantification** — Salmon (decoy-aware index, selective alignment)
4. **Differential expression** — tximport + DESeq2, with a volcano plot
5. **Reporting** — MultiQC aggregation of all QC/trimming/quant metrics

## Quick start

\`\`\`bash
nextflow run . -profile test,docker
\`\`\`

This runs the pipeline end-to-end on a small public test dataset in a few minutes.

## Requirements

- [Nextflow](https://www.nextflow.io/) (\`>=24.0\`)
- [Docker](https://www.docker.com/)

## Running on your own data

Provide a samplesheet (see \`assets/samplesheet_test.csv\` for the format) and reference files:

\`\`\`bash
nextflow run . -profile docker \\
    --input samplesheet.csv \\
    --fasta genome.fasta \\
    --transcript_fasta transcriptome.fasta \\
    --gtf genes.gtf.gz \\
    --metadata metadata.csv \\
    --outdir results
\`\`\`

## Output

- \`results/fastqc/\` — per-sample QC reports
- \`results/fastp/\` — trimmed reads and trimming reports
- \`results/salmon_quant/\` — per-sample transcript quantification
- \`results/deseq2/\` — differential expression results (\`deseq2_results.csv\`) and volcano plot
- \`results/multiqc/\` — aggregated QC report

## Validation

Tested on the [nf-core test-datasets](https://github.com/nf-core/test-datasets) yeast RNA-seq set (GSE110004). CI runs this test profile on every push.

## Author

Iqra Nadeem — [GitHub](https://github.com/Bioinformatician0507) · [LinkedIn](https://linkedin.com/in/iqra-nadeem)
