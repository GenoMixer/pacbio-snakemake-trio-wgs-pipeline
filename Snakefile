include: "rules/common.smk"


# Target rules
rule all:
    input:
        expand("results/{sample}/{sample}.bam", sample=samples.index),
        expand("results/{sample}/{sample}.bam.bai", sample=samples.index),
        expand("results/{sample}/{sample}.bam.md5", sample=samples.index),
        expand("results/{sample}/{sample}.vcf.gz", sample=samples.index),
        expand("results/{sample}/{sample}.g.vcf.gz", sample=samples.index),
        expand("results/{sample}/{sample}.visual_report.html", sample=samples.index)


# Modules
include: "rules/mapping.smk"
include: "rules/calling.smk"
#include: "rules/qc.smk"
#include: "rules/vep.smk"


