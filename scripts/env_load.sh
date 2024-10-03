#!/usr/bin/env bash

conda env create -f ../yam/nextflow.yml
conda env create -f ../yam/fastp.yml
conda env create -f ../yam/fastqc.yml
conda env create -f ../yam/multiqc.yml
conda env create -f ../yam/fastqdump.yml
