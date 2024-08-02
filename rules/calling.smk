rule deepvariant:
    input:
        bam="results/{sample}/{sample}.bam",
        ref=config["genome"]
    output:
        vcf="results/{sample}/{sample}.vcf.gz",
        gvcf="results/{sample}/{sample}.g.vcf.gz",
        report=report(
            "results/{sample}/{sample}.visual_report.html",
            caption="../report/vcf.rst",
            category="Calls")
    params:
        model=config["deepvariant_gvcf"]["model"],
        extra=config["deepvariant_gvcf"]["extra"],
    threads: config["deepvariant_gvcf"]["threads"]
    log:
        "results/logs/deepvariant/{sample}.log"
    wrapper:
        "v3.13.8/bio/deepvariant"
