rule glnexus:
  input: 
    gvcfs=expand("output/{sample}/{sample}.g.vcf.gz", sample=samples.index)
  output: 
    bcf=temp("output/{project}/{project}.bcf")
  params:
    project="{project}",
    reference=config["ref"]["genome"],
    extra=lambda wildcards, input: ' '.join(input.gvcfs)
  threads: 32
  resources:
    runtime=720,
    mem_gb=128
  log: "logs/glnexus/{project}_glnexus.log"
  shell:
    """
    module load glnexus
    glnexus_cli -m {resources.mem_gb} --threads {threads} --dir 'output/glnexus_db' {params.extra}  -c gatk > {output}
    """


rule conversion:
  input: 
    bcf="output/{project}/{project}.bcf"
  output: 
    vcf=protected("output/{project}/{project}.vcf.gz")
  params:
    project="{project}",
    extra="-Oz"
  threads: 12
  resources:
    runtime=720,
    mem_mb=12400
  log: "logs/glnexus/{project}_conversion.log"
  wrapper: "file:wrapper/bcftools/view"


rule tabix:
  input:
    vcf="output/{project}/{project}.vcf.gz"
  output:
    idx=protected("output/{project}/{project}.vcf.gz.tbi")
  params:
    project="{project}",
    extra="-p vcf -f"
  threads: 1
  resources:
    runtime=60,
    mem_mb=12400
  log: "logs/glnexus/{project}_tabix.log"
  wrapper: "file:wrapper/tabix"


rule md5:
  input:
    vcf="output/{project}/{project}.vcf.gz"
  output:
    md5=protected("output/{project}/{project}.vcf.gz.md5")
  params:
    project="{project}"
  threads: 1
  resources:
    runtime=60,
    mem_mb=12400
  log: "logs/glnexus/{project}_md5.log"
  shell:
    """
    md5sum {input} > {output}
    """

