#!/usr/bin/env bash

conda env create -f nextflow.yml
conda env create -f fastp.yml
conda env create -f fastqc.yml
conda env create -f multiqc.yml
