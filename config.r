# Configuration file for Heart Rate and Temperature Cross-Correlation Analysis
# Modify this file to adapt the analysis to your specific dataset

# ============================================================================
# FILE PATHS
# ============================================================================
# Path to your input Excel file
INPUT_FILE <- "~/Desktop/your_data.xlsx"  # Change this to your file path

# Directory for output files (Excel files and plots)
OUTPUT_DIR <- "~/Desktop/"           # Change if you want outputs elsewhere

# ============================================================================
# COLUMN NAMES
# ============================================================================
# These should match exactly the column names in your Excel file
HR_COLUMN <- "HR(bpm):ECG"               # Heart rate column name
TEMP_COLUMN <- "T_NPMN(Celsius):Temp"    # Temperature column name
TIME_COLUMN <- "Time"                     # Time column name

# ============================================================================
# ANALYSIS PARAMETERS
# ============================================================================
# Sampling interval in seconds (time between consecutive measurements)
SAMPLING_INTERVAL <- 10  

# LOESS span parameter for detrending (between 0 and 1)
# Smaller values = more flexible fit, larger values = smoother fit
DETREND_SPAN <- 0.3      

# ============================================================================
# OUTPUT SETTINGS
# ============================================================================
# Prefix for output files (will create files like: yourdata_correlation_original.xlsx)
OUTPUT_PREFIX <- "correlation"  

# Plot settings
PLOT_WIDTH <- 10   # Width of output plot in inches
PLOT_HEIGHT <- 8   # Height of output plot in inches

# ============================================================================
# ADVANCED SETTINGS (Usually don't need to change)
# ============================================================================
# Maximum lag for cross-correlation (set to NULL to use full length)
MAX_LAG <- NULL  # Will use length(data) - 1 if NULL

# Remove missing data
REMOVE_NA <- TRUE  # Set to FALSE if you want to handle NAs differently

# Plot colors
PLOT_FILL_COLOR <- "blue"
PLOT_LINE_COLOR <- "red"

# ============================================================================
# BATCH PROCESSING (Optional)
# ============================================================================
# To process multiple files, uncomment and modify the following:
# FILES_TO_PROCESS <- c(
#     "~/Desktop/DBF2.xlsx",
#     "~/Desktop/DBTNF12.xlsx",
#     "~/Desktop/another_file.xlsx"
# )
# 
# Then in the main script, loop through these files:
# for(file in FILES_TO_PROCESS) {
#     INPUT_FILE <- file
#     source("heart_rate_temp_correlation.R")
# }