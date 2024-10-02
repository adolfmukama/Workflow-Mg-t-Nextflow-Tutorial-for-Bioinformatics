# Workflow-Mg-t-Nextflow-Tutorial-for-Bioinformatics
# Introduction
**Why Nextflow?:** I think its easier to use and simplifies the design and execution of bioinformatics complex workflows, enabling reproducibility and scalability across diverse computing environments. 

## Summary of some of the Beneifits:

- **Reproducibility:** Ensures consistent results across different environments.
- **Scalability:** Easily scales workflows on local machines, clusters, or cloud platforms.
- **Portability:** Supports multiple containerization technologies like Docker and Singularity.
- **Parallelization:** Enables concurrent execution of tasks for faster analysis.
- **Modularity:** Allows for flexible workflow design and reuse of components.
- **Robust error handling:** Automatically manages task retries and recovery.

  ## Prerequisites

  Before we start ensure that you have the following:
- .yml files containing the conda environments that we shall use
- conda / miniforge
- github account
- Linux terminal access | wsl for windows | virtual machine
- Text editor e.g Vscode, nano, vim etc
### Step 01:
- Open your terminal and clone this repo in your home directory <br>

  ```
  cd ~
  ``` 
  Then 
  ```
  git clone 'https://github.com/adolfmukama/Workflow-Mg-t-Nextflow-Tutorial-for-Bioinformatics.git'
  ```
### step 02: create the nexflow script
- Lets start by creating a dir called scripts in our cloned repo <br>
```
cd Workflow-Mg-t-Nextflow-Tutorial-for-Bioinformatics
``` 
```
mkdir -p scripts 
``` 
- create nextflow file in the scripts dir 
```
cd scripts; touch nextflow_script.nf 
```
- open the script in your preferred text editor In my case i will use Vs code
  ```
  code nextflow_script.nf # Vscode users
  vim nextflow_script.nf # vim users
  nano nextflow_script.nf # nano users

  ```
- Basic concepts <br>
-- Nextflow workflows are built by connecting different processes.<br>
-- Each process can use any scripting language executable on Linux (e.g., Bash, Python).<br>
-- Processes run independently and are isolated from one another.<br>
-- Communication between processes occurs through asynchronous channels (FIFO queues).<br>
-- Inputs and outputs of processes are defined as channels.<br>
-- Workflow execution flow is determined by the input/output declarations.<br>
```
// 3 main parts that will make up our script
- Parameters
- Processes
- Workflow execution block
```
### step 03: Define parameters for our workflow
```
// Workflow params
params.reads = params.reads ?: '~/Workflow-Mg-t-Nextflow-Tutorial-for-Bioinformatics/data/sample.txt'
// Skip the first  FASTQDUMP if true
params.skip_fastqdump = false
params.skip_fastqc01 = false
params.skip_multiqc01 = false
params.skip_fastp = false
```
### step 04: Create worflow processes

#### FASTQDUMP process
```
// worflow processes

process FASTQDUMP {
  // define the input for this process
  input:
  // path to sample.txt
  path reads

  // define the output folder for this process
  output:
  // folder where the files will be saved
  path "miseq_reads"

  when:
  // Run this process only if the 'skip_fastqdump' parameter is not set (or is false)
  !params.skip_fastqdump

  // write the script for this process
  script:
  """
  # Create the output directory if it doesn't exist
    mkdir -p miseq_reads
    # Loop through each sample ID from the sampleID file
    for sample in \$(cat "${reads}"); do
        # Run FastQDump for each sample's ID and save the output in the miseq_reads directory
        fastq-dump --split-files "\${sample} --outdir miseq_reads
    
    done
    """
}
```

#### FASTQC process
```
process FASTQC_01 {
    
    input:
    // Input file path for the MiSeq reads 
    path miseq_reads 
    // Input file containing a list of sample IDs
    path reads

    output:
    // Directory where FastQC results will be saved
    path "fastqc_results"

    when:
    // Run this process only if the 'skip_fastqc01' parameter is not set (or is false)
    !params.skip_fastqc01

    script:

    """
    #!/usr/bin/env bash
    # Create the output directory if it doesn't exist
    mkdir -p fastqc_results
    # Loop through each sample ID from the sampleID file
    for sample in \$(cat "${reads}"); do
        # Run FastQC for each sample's fastq files and save the output in the fastqc_results directory
        fastqc "${reads}"/"\${sample}"*.fastq --outdir fastqc_results
    
    done
    """
}

```
#### MULTIQC process
```
process MULTIQC_01 {
    
    input:
    // Input file path for the fastqc results folder
    path fastqc_results

    output:
    // Directory where MultiQC results will be saved
    path "multiqc_01"

    when:
    // Run this process only if the 'skip_multiqc01' parameter is not set (or is false)
    !params.skip_multiqc01

    script:
    """
    #!/usr/bin/env bash

    # Create the output directory if it doesn't exist 
    mkdir -p multiq_01
    multiqc fastqc_results/* --outdir multiqc_01
    """
}

```

#### FASTP process

```
process FASTP_A {

    input:
    // Input file path for the MiSeq reads
    path reads_miseq
    // Input file containing a list of sample IDs
    path sampleID

    output:
    // Directory where FASTP_A results will be saved
    path "fastp_output"

    when:
    // Run this process only if the 'skip_fastp' parameter is not set (or is false)
    !params.skip_fastp

    script:
    """
    # Create the output directory if it doesn't exist
    mkdir -p fastp_output

    # Loop through each sample ID from the sampleID file
    for sample in \$(cat \${sampleID}); do

    conda run -n fastp fastp -i "\${reads_miseq}"/"\${sample}"_R1.fastq.gz -I "\${reads_miseq}"/"\${sample}"_R2.fastq.gz \
              -o fastp_output/"\${sample}"_filtered_fastp_R1.fastq.gz \
              -O fastp_output/"\${sample}"_filtered_fastp_R2.fastq.gz \
              --json fastp_output/"\${sample}"_filtered_fastp.json \
              --html fastp_output/"\${sample}"_filtered_fastp.html \
              -q 20 --thread 20 \
              --detect_adapter_for_pe \
              --cut_tail 20

    done
    """
}

```

#### MULTIQC_02 process
```

```
### step 05: Create  workflow execution block

```

```





  


