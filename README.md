# Workflow-Mg-t-Nextflow-Tutorial-for-Bioinformatics
<details>
  <summary><h2>Introduction</h2></summary>

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
  </details>
  
<details>
  <summary><h2>Step 01:</h2></summary>
- Open your terminal and clone this repo in your home directory <br>

  ```
  cd ~
  ``` 
  Then 
  ```
  git clone 'https://github.com/adolfmukama/Workflow-Mg-t-Nextflow-Tutorial-for-Bioinformatics.git'
  ```
  #### Acquire data using FASTQDUMP
```
cd Workflow-Mg-t-Nextflow-Tutorial-for-Bioinformatics
mkdir -p data
cd data
    
# Run FastQDump for each sample's ID 
fastq-dump --split-files ERR4920877 ERR4920878

```
</details>

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
### step 03: Define parameters for our workflow in a nextflow.config 
```
#!/usr/bin/env nextflow

// ================================
// Define the workflow parameters
// ================================

// 'params' block defines user-provided inputs and options for the workflow.
// These can be specified by the user when running the workflow or set to default values.
params {
    // Path to a file containing sample IDs. Each ID will be processed in the workflow.
    sampleID = '/home/jovyan/Workflow-Mg-t-Nextflow-Tutorial-for-Bioinformatics/data/sample.txt'
    
    // Path to the directory containing MiSeq sequencing reads. This will be used for analysis.
    reads_miseq = '/home/jovyan/Workflow-Mg-t-Nextflow-Tutorial-for-Bioinformatics/data/'
    
    // Flags to control skipping certain steps of the workflow. If set to 'true', these steps are skipped.
    
    // Skip the first FastQC analysis (before filtering with Fastp).
    skip_fastqc01 = false
    
    // Skip running MultiQC after the first FastQC analysis.
    skip_multiqc01 = false
    
    // Skip the Fastp filtering process (for read quality filtering).
    skip_fastp = false
    
    // Skip the second FastQC analysis (after filtering with Fastp).
    skip_fastqc02 = false
    
    // Skip running MultiQC after the second FastQC analysis.
    skip_multiqc02 = false
}

// ================================
// Executor Settings
// ================================

// The 'executor' block defines the settings for how tasks will be executed. 
// This includes resource allocation and queue management for jobs in the workflow.
executor {
    // The 'queueSize' defines the maximum number of tasks that can be queued at once.
    queueSize = 100  // Set to allow a maximum of 100 tasks in the queue.
    
    // 'cpus' specifies the number of CPU cores allocated for each task.
    cpus = 4  // Each task will get 4 CPU cores.
    
    // 'memory' defines the amount of memory (RAM) allocated per task.
    memory = '24 GB'  // Each task is allocated 24 GB of RAM.
}

// ================================
// Additional workflow steps will follow here
// ================================

// Typically, the workflow's processes would be defined after these parameters.
// For example, processes like FASTQC, Fastp, and MultiQC would be described,
// with conditions for skipping the steps based on the parameters defined above.


```

### step 04: Create worflow processes


#### FASTQC process
```
process FASTQC_01 {
    // Specify the Conda environment to use for this process
    conda 'fastqc'

    input:
    // Input file path for the MiSeq reads 
    path reads_miseq 
    // Input file containing a list of sample IDs
    path sampleID

    output:
    // Directory where FastQC results will be saved
    path "fastqc_results"

    when:
    // Run this process only if the 'skip_fastqc01' parameter is not set (or is false)
    !params.skip_fastqc01

    script:

    """
    # Create the output directory if it doesn't exist
    mkdir -p fastqc_results
   
    # Loop through each sample ID from the sampleID file
    for sample in \$(cat "${sampleID}"); do
        # Run FastQC for each sample's fastq.gz files and save the output in the fastqc_results directory
        conda run -n fastqc fastqc "${reads_miseq}"/"\${sample}"*.fastq --outdir fastqc_results
    done
    
       """
}

```
#### MULTIQC process
```
process MULTIQC_01 {
    // Specify the Conda environment to use for this process
    conda 'multiqc'
   
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
    # Create the output directory if it doesn't exist 
    mkdir -p multiq_01
    conda run -n multiqc multiqc fastqc_results/* --outdir multiqc_01
    """
}
```

#### FASTP process

```
process FASTP_A {
    // Specify the Conda environment to use for this process
    conda 'fastp'

    input:
    path reads_miseq  // Ensure this variable is passed to the process
    path sampleID     // Input path for the sample ID file

    output:
    path 'fastp_output'  // Output directory for fastp results

    when:
    !params.skip_fastp  // Skip if the parameter is set to true

    script:
    """
    # Create the output directory if it doesn't exist
    mkdir -p fastp_output
    
    # Loop through each sample ID from the sampleID file
    for sample in \$(cat "${sampleID}"); do
        if [[ -f "${reads_miseq}/\${sample}_1.fastq" && -f "${reads_miseq}/\${sample}_2.fastq" ]]; then
            echo "Processing sample: \${sample}"
            
            conda run -n fastp fastp -i "${reads_miseq}/\${sample}_1.fastq" \
                      -I "${reads_miseq}/\${sample}_2.fastq" \
                      -o fastp_output/\${sample}_filt_fastp_R1.fastq \
                      -O fastp_output/\${sample}_filt_fastp_R2.fastq \
                      --json fastp_output/\${sample}_filt_fastp.json \
                      --html fastp_output/\${sample}_filt_fastp.html \
                      -q 20 --thread 10 \
                      --detect_adapter_for_pe \
                      --cut_tail 20
        else
            echo "Input files for sample \${sample} not found. Skipping."
        fi
    done
    """
}
```

#### FASTQC_02 process

process FASTQC_02 {
    // Specify the Conda environment to use for this process
    conda 'fastqc'

    input:
    // Input file path for the fastp results
    path fastp_output

    output:
    // Output directories
    path "fastqc_02_results"
    path "multiqc_02"

    when:
    // Run this process only if the 'skip_fastqc02' parameter is not set (or is false)
    !params.skip_fastqc02

    script:
    """
    # Create the output directory if it doesn't exist
    mkdir -p fastqc_02_results
    mkdir -p multiqc_02

    for sample in fastp_output/*.fastq; do
        conda run -n fastqc fastqc "\${sample}"*.fastq --outdir fastqc_02_results
        
    done
    """
}

#### MULTIQC_02 process
```
process MULTIQC_02 {
    // Specify the Conda environment to use for this process
    conda 'multiqc'


    input:
    // Input file path for the fastp results
    path fastp_output

    output:
    // Directory where MultiQC results will be saved
    path "multiqc_fastp"

    when:
    // Run this process only if the 'skip_multiqc02' parameter is not set (or is false)
    !params.skip_multiqc02

    script:
    """
    # Create the output directory if it doesn't exist
    mkdir -p multiqc_02
    conda run -n multiq multiqc fastp_output/* --outdir multiqc_fastp
    """
}


```

### step 05:Create  workflow execution block

```
workflow {
    // Check if the FASTQC analysis for the initial reads should be performed
    if (!params.skip_fastqc01) {
        fastqc_results = FASTQC_01(params.reads_miseq, params.sampleID)
       }

    // Check if the MultiQC report for the FASTQC results should be generated
    if (!params.skip_multiqc01) {
        multiqc_report = MULTIQC_01(fastqc_results)
    }
// Check if the fastp filtering process should be executed
    if (!params.skip_fastp) {
        fastp_output = FASTP_A(params.reads_miseq, params.sampleID)
    }

    // Check if a second round of FASTQC analysis should be conducted on fastp output
    if (!params.skip_fastqc02) {
        fastqc_results_02 = FASTQC_02(fastp_output)
    }

    // Check if the MultiQC report for the second FASTQC analysis should be generated
    if (!params.skip_multiqc02) {
        multiqc_02 = MULTIQC_02(fastp_output)
    }

}
```



## Resources
- [nextflow training](https://training.nextflow.io/basic_training/intro/) <br>
- [awesome nextflow repo](https://github.com/nextflow-io/awesome-nextflow)





  


