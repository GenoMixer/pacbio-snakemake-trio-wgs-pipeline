import os
import sys
import glob
import pandas
from snakemake.utils import validate
from snakemake.utils import min_version

min_version("6.1.0")

report: "../report/workflow.rst"

configfile: "../config/config.yaml"
#validate(config, schema="../schemas/config.schema.yaml")

# Setup config file and sample sheets
samples = pandas.read_csv(
    config["samples"],
    sep="\t",
    header=0,
).set_index("sample", drop=False)

#validate(samples, schema="workflow/schemas/samples.schema.yml")

# Identifying trios
families = samples.groupby('family').groups.keys()

# Set wildcard constraints
wildcard_constraints:
    sample="|".join(map(str, samples.index)),
    trio="|".join(samples.groupby('family').groups.keys()),
    project=config["project"]

# Helper functions
def get_samples(wildcards):
    return config["samples"][wildcards.sample]

#def get_fastqs(wildcards):
#    return config["fastqs"][wildcards.sample]

def get_all_samples(wildcards):
    return config["samples"].values()

def get_fastqs(wildcards):
        return sorted(glob.glob("data/" + wildcards.sample + "/Cell_*/" + "*.fastq.gz", recursive=True))
