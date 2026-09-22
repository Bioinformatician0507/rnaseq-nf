include { FASTQC } from './modules/fastqc'
include { FASTP  } from './modules/fastp'

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
}
