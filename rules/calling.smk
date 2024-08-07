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
    log:
        "results/logs/pbsv/discover_{sample}.log"
    conda:
        "envs/pbsv.yaml"
    shell:
        """
        pbsv discover {params.extra} {input.bam} {output} --log-file {log}
        
        """

rule pbsv_call:
    input:
        sig="results/pbsv/{sample}/{sample}.svsig",
        ref_fa=config["reference"]["reference_fasta"]
    output:
        sv_vcf_single="results/pbsv/{sample}/{sample}_pbsv.vcf"
    params:
        extra="--hifi"
    log:
        "results/logs/pbsv/call_{sample}.log"
    threads: 8
    conda:
        "envs/pbsv.yaml"
    shell:
        """
        pbsv call -j {threads} {params.extra} {input.ref_fa} {input.sig} {output} --log-file {log}
        """


rule pbcnv:
   input:
        bam_haplotagged="results/{sample}/{sample}_deepvariant_haplotagged.bam",
        phased_vcf="results/{sample}/{sample}_deepvariant_phased.vcf.gz",
        ref_fa=config["reference"]["reference_fasta"],
    output:
        cnv_vcf="results/pbcnv/{sample}/{sample}cnvs.vcf.gz",
        depth_track="results/pbcnv/{sample}/{sample}.depth.bw",
        cnv_track="results/pbcnv/{sample}/{sample}.copynum.bedgraph",
        maf_track="results/pbcnv/{sample}/{sample}.maf.bw"
    log:
        "results/logs/pbcnv/pbcnv_{sample}.log"
    threads: 8
    params:
        extra="--exclude /path/to/cnv.excluded_regions.common_50.hg38.bed.gz --expected-cn /path/to/expected_cn.hg38.XY.bed "
        prefix="{sample}"
    conda:
        "envs/pbcnv.yaml"
    shell:
        """
        hificnv --bam {bam_haplotagged} --maf {input.phased_vcf} --ref {input.ref_fa} {params.extra} --threads {threads} --output_prefix {params.prefix} 2&1>{log}
        
        """

#rule convert_bam_to_fastq:
#
#rule paraphase:
#
#rule hiphase:
#
#rule trgt_repeat_genotyping:
#
#rule sort_and_index_mapped_bam:
#
#rule annotate_svs_svpack:
#
#rule jellyfish:
#
#rule pb_cpg_tools:
#
#rule convert_fastq_to_bam:
#
#

