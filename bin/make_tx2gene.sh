#!/bin/bash
set -euo pipefail
zcat "$1" | awk -F'\t' '$3=="transcript"' | \
awk -F'\t' '{
    tx=""; gene="";
    n = split($9, attrs, ";");
    for (i=1; i<=n; i++) {
        a = attrs[i];
        gsub(/^[ \t]+/, "", a);
        if (a ~ /^transcript_id/) {
            s = a;
            sub(/^transcript_id[ \t]*"/, "", s);
            sub(/".*$/, "", s);
            tx = s;
        }
        if (a ~ /^gene_id/) {
            s = a;
            sub(/^gene_id[ \t]*"/, "", s);
            sub(/".*$/, "", s);
            gene = s;
        }
    }
    if (tx != "" && gene != "") print tx "\t" gene
}' > tx2gene.tsv
