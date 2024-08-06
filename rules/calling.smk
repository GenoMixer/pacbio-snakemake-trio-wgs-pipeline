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

rule pbsv_discover:
    input:
        bam=protected("results/{sample}/{sample}.bam"),
        bai=protected("results/{sample}/{sample}.bam.bai")
    output:
        sig="results/pbsv/{sample}/{sample}.svsig"
    params:
        extra="--hifi"
    conda:
        "envs/pbsv.yaml"
    shell:
        """
        pbsv discover {params.extra} {input.bam} {output}
        
        """

rule pbsv_call:
    input:
        sig="results/pbsv/{sample}/{sample}.svsig",
        ref_fa=config["reference"]["reference_fasta"]
    output:
        sv_vcf_single="results/pbsv/{sample}/{sample}_pbsv.vcf"
    params:
        extra="--hifi"
    threads: 8
    conda:
        "envs/pbsv.yaml"
    shell:
        """
        pbsv call -j {threads} {params.extra} {input.ref_fa} {input.sig} {output}
        """