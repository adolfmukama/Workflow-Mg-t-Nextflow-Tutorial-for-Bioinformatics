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
```

#### FASTQC process
```

```
#### MULTIQC process
```

```

#### FASTP process

```

```

#### MULTIQC_02 process
```

```
### step 05: Create  workflow execution block

```

```





  


