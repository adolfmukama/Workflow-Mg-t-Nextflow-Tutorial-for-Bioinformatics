#!/usr/bin/env nextflow

log.info """\
    NEXTFLOW - FOR BIOINFORMATICS PIPELINE DEV
    ===================================
    
    """
    .stripIndent(true)
// Define Processes

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


