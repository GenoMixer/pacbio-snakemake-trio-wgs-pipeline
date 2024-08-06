rule map:
    input:
        query=get_fastqs
    output:
        sam=temp("results/{sample}/{sample}.sam")
    log:
        "logs/minimap2/{sample}.log"
    params:
        target=config["genome"],
        extra="-x map-hifi -aLyY --MD --eqx -R '@RG\\tID:{sample}\\tSM:{sample}\\tLB:WGS\\tPL:PacBio'"
        #-x preset; -a output SAM; -L; -y; -Y; --MD; --eqx; -R read group
    threads: 1
    resources:
        mem_gb=100,
        runtime=1444
    shell:
        """
        minimap2 -t {threads} {params.extra} {params.target} {input} > {output} 2> {log}
        """

rule sort:
    input:
        sam="results/{sample}/{sample}.sam",
    output:
        bam=protected("results/{sample}/{sample}.bam"),
        bai=protected("results/{sample}/{sample}.bam.bai")
    log:
        "logs/samtools/sort/{sample}.log",
    params:
        extra="-m 30G --write-index",
    threads: 1
    shell:
        """
        samtools sort -@ {threads} {params.extra} -o {output.bam}##idx##{output.bai} {input}  2> {log}
        """

rule mosdepth:
    input:
        bam=protected("results/{sample}/{sample}.bam"),
        bai=protected("results/{sample}/{sample}.bam.bai")
    output:
        depth="results/{sample}/{sample}_mosdepth_summary.txt"
        
    log:
        "logs/mosdepth/{sample}_depth.log"
    params:
        prefix="results/{sample}/{sample}"
    threads: 4
    conda: "envs/mosdepth.yaml"
    shell:
        """
        mosdepth --threads {threads} {params.prefix} {input.bam} >{log} 2>&1
        
        """


rule md5:
    input:
        bam="results/{sample}/{sample}.bam",
    output:
        md5=protected("results/{sample}/{sample}.bam.md5")
    log:
        "logs/md5sum/{sample}.log",
    threads: 1
    shell:
        """
        md5sum {input} > {output} 2> {log}
        """
