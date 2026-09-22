include { FASTQC       } from './modules/fastqc'
include { FASTP        } from './modules/fastp'
include { SALMON_INDEX } from './modules/salmon_index'
include { SALMON_QUANT } from './modules/salmon_quant'
include { DESEQ2       } from './modules/deseq2'
include { MULTIQC      } from './modules/multiqc'

workflow {
    if (!params.input) {
        error "Please provide a samplesheet with --input"
    }

    ch_reads = channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header: true)
        .map { row ->
            def meta  = [id: file(row.fastq_1).simpleName, sample: row.sample, single_end: !row.fastq_2]
            def reads = row.fastq_2 ? [file(row.fastq_1), file(row.fastq_2)] : [file(row.fastq_1)]
            [meta, reads]
        }

    FASTQC(ch_reads)
    FASTP(ch_reads)

    SALMON_INDEX(
        file(params.transcript_fasta),
        file(params.fasta)
    )

    SALMON_QUANT(
        FASTP.out.reads,
        SALMON_INDEX.out.index
    )

    if (params.metadata) {
        ch_quant_dirs = SALMON_QUANT.out.results
            .map { meta, dir -> dir }
            .collect()

        DESEQ2(
            ch_quant_dirs,
            file(params.metadata),
            file(params.gtf)
        )
    }

    ch_multiqc_files = FASTQC.out.zip
        .map { meta, zip -> zip }
        .mix(FASTP.out.json.map { meta, json -> json })
        .mix(SALMON_QUANT.out.results.map { meta, dir -> dir })
        .collect()

    MULTIQC(ch_multiqc_files)
}
