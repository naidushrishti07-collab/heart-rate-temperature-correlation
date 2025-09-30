# Batch processing script for multiple datasets
# This script processes multiple files using the same analysis pipeline

# Load necessary libraries
library(tidyverse)
library(readxl)
library(writexl)
library(gridExtra)
library(grid)

# ============================================================================
# BATCH CONFIGURATION
# ============================================================================

# List of files to process
FILES_TO_PROCESS <- c(
    "~/Desktop/your_file1.xlsx",
    "~/Desktop/your_file2.xlsx"
    # Add more files as needed
)

# Common settings for all files
OUTPUT_DIR <- "~/Desktop/batch_results/"  # Create this folder first
HR_COLUMN <- "HR(bpm):ECG"
TEMP_COLUMN <- "T_NPMN(Celsius):Temp"
TIME_COLUMN <- "Time"
SAMPLING_INTERVAL <- 10
DETREND_SPAN <- 0.3
OUTPUT_PREFIX <- "correlation"

# Create output directory if it doesn't exist
if(!dir.exists(OUTPUT_DIR)) {
    dir.create(OUTPUT_DIR, recursive = TRUE)
    cat("Created output directory:", OUTPUT_DIR, "\n")
}

# Store results for summary
batch_results <- list()

# ============================================================================
# PROCESS EACH FILE
# ============================================================================

cat("\n============================================\n")
cat("STARTING BATCH PROCESSING\n")
cat("============================================\n")
cat("Processing", length(FILES_TO_PROCESS), "files\n\n")

for(i in seq_along(FILES_TO_PROCESS)) {
    
    INPUT_FILE <- FILES_TO_PROCESS[i]
    
    # Check if file exists
    if(!file.exists(INPUT_FILE)) {
        cat("WARNING: File not found -", INPUT_FILE, "\n")
        cat("Skipping to next file...\n\n")
        next
    }
    
    cat("----------------------------------------\n")
    cat("Processing file", i, "of", length(FILES_TO_PROCESS), "\n")
    cat("File:", INPUT_FILE, "\n")
    cat("----------------------------------------\n")
    
    tryCatch({
        # Set the current file
        base_filename <- tools::file_path_sans_ext(basename(INPUT_FILE))
        
        # Source the main analysis script
        # Note: The main script uses the variables we've defined above
        source("heart_rate_temp_correlation.R")
        
        # Store results
        batch_results[[base_filename]] <- list(
            file = INPUT_FILE,
            original_max_lag = max_original$max_lag,
            original_max_corr = max_original$max_corr,
            detrended_max_lag = max_detrended$max_lag,
            detrended_max_corr = max_detrended$max_corr,
            n_rows = final_rows
        )
        
        cat("✓ Successfully processed:", base_filename, "\n\n")
        
    }, error = function(e) {
        cat("✗ ERROR processing", INPUT_FILE, ":\n")
        cat("  ", conditionMessage(e), "\n\n")
    })
}

# ============================================================================
# SUMMARY REPORT
# ============================================================================

cat("\n============================================\n")
cat("BATCH PROCESSING SUMMARY\n")
cat("============================================\n")

if(length(batch_results) > 0) {
    # Create summary data frame
    summary_df <- do.call(rbind, lapply(names(batch_results), function(name) {
        res <- batch_results[[name]]
        data.frame(
            Dataset = name,
            N_Rows = res$n_rows,
            Original_Lag_min = res$original_max_lag,
            Original_Corr = res$original_max_corr,
            Detrended_Lag_min = res$detrended_max_lag,
            Detrended_Corr = res$detrended_max_corr
        )
    }))
    
    # Display summary
    print(summary_df)
    
    # Save summary to Excel
    summary_file <- file.path(OUTPUT_DIR, "batch_summary.xlsx")
    write_xlsx(summary_df, summary_file)
    cat("\nSummary saved to:", summary_file, "\n")
    
    # Calculate and display statistics
    cat("\n----------------------------------------\n")
    cat("OVERALL STATISTICS\n")
    cat("----------------------------------------\n")
    cat("Files processed successfully:", length(batch_results), "\n")
    cat("Average correlation (original):", mean(summary_df$Original_Corr), "\n")
    cat("Average correlation (detrended):", mean(summary_df$Detrended_Corr), "\n")
    cat("Average lag (original):", mean(summary_df$Original_Lag_min), "minutes\n")
    cat("Average lag (detrended):", mean(summary_df$Detrended_Lag_min), "minutes\n")
    
} else {
    cat("No files were successfully processed.\n")
}

cat("\n============================================\n")
cat("BATCH PROCESSING COMPLETE\n")
cat("============================================\n")
