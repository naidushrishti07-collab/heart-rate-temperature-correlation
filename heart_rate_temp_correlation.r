# Heart Rate and Temperature Cross-Correlation Analysis
# Generalized script for analyzing correlation between HR and temperature signals

# Load necessary libraries
library(tidyverse)
library(readxl)
library(writexl)
library(gridExtra)
library(grid)

# ============================================================================
# CONFIGURATION SECTION - Modify these parameters as needed
# ============================================================================

# File paths
INPUT_FILE <- "~/Desktop/your_data.xlsx"  # UPDATE THIS: Path to your input Excel file
OUTPUT_DIR <- "~/Desktop/"                # Directory for output files

# Column names in your Excel file
HR_COLUMN <- "HR(bpm):ECG"               # Heart rate column name
TEMP_COLUMN <- "T_NPMN(Celsius):Temp"    # Temperature column name
TIME_COLUMN <- "Time"                     # Time column name

# Analysis parameters
SAMPLING_INTERVAL <- 10  # Sampling interval in seconds
DETREND_SPAN <- 0.3      # LOESS span parameter for detrending (0-1)

# Output file naming
OUTPUT_PREFIX <- "correlation"  # Prefix for output files

# ============================================================================
# MAIN ANALYSIS - No need to modify below unless changing methodology
# ============================================================================

# Extract base filename without extension for output naming
base_filename <- tools::file_path_sans_ext(basename(INPUT_FILE))

# Read data from Excel file
cat("Reading data from:", INPUT_FILE, "\n")
data <- read_excel(INPUT_FILE)

# Remove rows with missing data
initial_rows <- nrow(data)
data <- data %>% drop_na()
final_rows <- nrow(data)
cat("Removed", initial_rows - final_rows, "rows with missing data\n")
cat("Processing", final_rows, "rows of data\n\n")

# Extract heart rate and temperature signals
heart_rate <- data[[HR_COLUMN]]
temp <- data[[TEMP_COLUMN]]
time <- data[[TIME_COLUMN]]

# Standardize the signals
standardize <- function(x) {
    return((x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE))
}

heart_rate_std <- standardize(heart_rate)
temp_std <- standardize(temp)

# Remove rhythmic component (detrending)
remove_rhythm <- function(x, span = 0.3) {
    time_index <- 1:length(x)
    loess_fit <- loess(x ~ time_index, span = span)
    detrended <- x - predict(loess_fit)
    return(detrended)
}

cat("Applying detrending with LOESS span =", DETREND_SPAN, "\n")
heart_rate_detrended <- remove_rhythm(heart_rate_std, span = DETREND_SPAN)
temp_detrended <- remove_rhythm(temp_std, span = DETREND_SPAN)

# Function to compute lag and correlation for each time point
compute_ccf_data <- function(x, y, time) {
    ccf_result <- ccf(x, y, lag.max = length(x) - 1, plot = FALSE)
    
    # Convert lags to minutes based on sampling interval
    lag_in_minutes <- (ccf_result$lag * SAMPLING_INTERVAL) / 60
    
    # Adjust the correlation to match the length of lag_in_minutes
    correlation_values <- ccf_result$acf
    
    # Create a data frame with time, lag, and correlation values
    df <- data.frame(
        Time = time[1:length(lag_in_minutes)],  # Matching the length of lag_in_minutes
        Lag_in_Minutes = lag_in_minutes,
        Correlation = correlation_values
    )
    
    return(df)
}

# Compute lag and correlation for both original and detrended data
cat("\nComputing cross-correlations...\n")
ccf_data_original <- compute_ccf_data(heart_rate_std, temp_std, time)
ccf_data_detrended <- compute_ccf_data(heart_rate_detrended, temp_detrended, time)

# Save results to Excel files
output_file_original <- file.path(OUTPUT_DIR, paste0(base_filename, "_", OUTPUT_PREFIX, "_original.xlsx"))
output_file_detrended <- file.path(OUTPUT_DIR, paste0(base_filename, "_", OUTPUT_PREFIX, "_detrended.xlsx"))

write_xlsx(ccf_data_original, output_file_original)
write_xlsx(ccf_data_detrended, output_file_detrended)

cat("\nSaved correlation results to:\n")
cat("  -", output_file_original, "\n")
cat("  -", output_file_detrended, "\n")

# Function to find and print the maximum correlation and corresponding lag
find_max_correlation <- function(ccf_data, title) {
    max_idx <- which.max(abs(ccf_data$Correlation))
    max_lag <- ccf_data$Lag_in_Minutes[max_idx]
    max_corr <- ccf_data$Correlation[max_idx]
    
    cat(sprintf("\n%s:\n", title))
    cat(sprintf("Max Lag: %.2f minutes\n", max_lag))
    cat(sprintf("Correlation: %.3f\n", max_corr))
    
    if(max_lag < 0) {
        cat("(Temperature changes precede heart rate changes)\n")
    } else if(max_lag > 0) {
        cat("(Heart rate changes precede temperature changes)\n")
    } else {
        cat("(Changes are simultaneous)\n")
    }
    
    return(list(max_lag = max_lag, max_corr = max_corr))
}

# Find and display maximum correlations
max_original <- find_max_correlation(ccf_data_original, "Temperature vs Heart Rate (Original)")
max_detrended <- find_max_correlation(ccf_data_detrended, "Temperature vs Heart Rate (Detrended)")

# Plot correlation vs. lag
plot_ccf_data <- function(ccf_data, max_info, title) {
    ggplot(ccf_data, aes(x = Lag_in_Minutes, y = Correlation)) +
        geom_hline(yintercept = 0, color = "black") +
        geom_col(fill = "blue") +
        geom_vline(xintercept = max_info$max_lag, color = "red", linetype = "dashed") +
        annotate("text", x = 0, y = 0.9, 
                 label = sprintf("Max Lag: %.2f min\nCorrelation: %.3f", 
                                 max_info$max_lag, max_info$max_corr),
                 color = "red", hjust = 0.5, size = 4.5) +
        labs(title = title, x = "Lag (minutes)", y = "Cross-Correlation") +
        theme_minimal() +
        scale_x_continuous(limits = c(min(ccf_data$Lag_in_Minutes), max(ccf_data$Lag_in_Minutes)))
}

# Create plots
p1 <- plot_ccf_data(ccf_data_original, max_original, "Temperature vs Heart Rate (Original)")
p2 <- plot_ccf_data(ccf_data_detrended, max_detrended, "Temperature vs Heart Rate (Detrended)")

# Combine and display plots
main_title <- paste("Heart Rate and Temperature Analysis:", base_filename)
title <- textGrob(main_title, gp = gpar(fontface = "bold", fontsize = 20))
combined_plot <- grid.arrange(title, p1, p2, heights = c(0.1, 1, 1), ncol = 1)

# Display the plot
grid.draw(combined_plot)

# Save plot to PDF
output_plot <- file.path(OUTPUT_DIR, paste0(base_filename, "_", OUTPUT_PREFIX, "_plot.pdf"))
pdf(output_plot, width = 10, height = 8)
grid.draw(combined_plot)
dev.off()

cat("\nSaved plot to:", output_plot, "\n")

# Summary statistics
cat("\n============================================\n")
cat("ANALYSIS COMPLETE\n")
cat("============================================\n")
cat("Dataset:", base_filename, "\n")
cat("Total data points analyzed:", final_rows, "\n")
cat("Sampling interval:", SAMPLING_INTERVAL, "seconds\n")
cat("Total duration:", round(final_rows * SAMPLING_INTERVAL / 60, 2), "minutes\n")
cat("\nKey findings:\n")
cat("- Original data: Correlation =", sprintf("%.3f", max_original$max_corr), 
    "at lag =", sprintf("%.2f", max_original$max_lag), "minutes\n")
cat("- Detrended data: Correlation =", sprintf("%.3f", max_detrended$max_corr), 
    "at lag =", sprintf("%.2f", max_detrended$max_lag), "minutes\n")
cat("============================================\n")