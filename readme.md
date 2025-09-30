# Heart Rate and Temperature Cross-Correlation Analysis

## Overview
A generalized R toolkit for analyzing cross-correlation between heart rate (HR) and temperature signals from physiological data. This analysis identifies temporal relationships between these physiological parameters using both original and detrended signal processing.

## Features
- **Flexible Configuration**: Easy-to-modify configuration file for different datasets
- **Batch Processing**: Analyze multiple files at once
- **Signal Processing**: Standardization and optional detrending using LOESS smoothing
- **Cross-Correlation Analysis**: Comprehensive lag and correlation computation
- **Automated Reporting**: Excel outputs and publication-ready visualizations
- **Summary Statistics**: Detailed analysis metrics and interpretations

## Repository Structure
```
heart-rate-temperature-correlation/
├── README.md
├── heart_rate_temp_correlation.R  # Main analysis script
├── config.R                       # Configuration file
├── run_analysis.R                 # Simple runner script
├── batch_analysis.R               # Batch processing script
├── data/                          # Place your input files here
├── output/                        # Analysis outputs
└── .gitignore
```

## Installation

### Prerequisites
Install required R packages:
```r
install.packages(c("tidyverse", "readxl", "writexl", "gridExtra", "grid"))
```

### Clone Repository
```bash
git clone https://github.com/yourusername/heart-rate-temperature-correlation.git
cd heart-rate-temperature-correlation
```

## Usage

### Option 1: Single File Analysis

1. **Edit the configuration file** (`config.R`):
```r
INPUT_FILE <- "~/Desktop/your_data.xlsx"  # Your data file
HR_COLUMN <- "HR(bpm):ECG"               # Your HR column name
TEMP_COLUMN <- "T_NPMN(Celsius):Temp"    # Your temperature column name
```

2. **Run the analysis**:
```r
source("run_analysis.R")
```

### Option 2: Direct Script Execution

Run the main script with custom parameters:
```r
# Set your parameters
INPUT_FILE <- "path/to/your/data.xlsx"
HR_COLUMN <- "HeartRate"
TEMP_COLUMN <- "Temperature"
SAMPLING_INTERVAL <- 10  # seconds

# Run analysis
source("heart_rate_temp_correlation.R")
```

### Option 3: Batch Processing

Process multiple files at once:
```r
# Edit batch_analysis.R to list your files
FILES_TO_PROCESS <- c(
    "data/dataset1.xlsx",
    "data/dataset2.xlsx",
    "data/dataset3.xlsx"
)

# Run batch analysis
source("batch_analysis.R")
```

## Input Data Format

### Required Columns
Your Excel file must contain:
- **Heart Rate Column**: Numeric values in beats per minute (bpm)
- **Temperature Column**: Numeric values in Celsius
- **Time Column**: Time stamps for measurements

### Example Data Structure
| Time | HR(bpm):ECG | T_NPMN(Celsius):Temp |
|------|-------------|---------------------|
| 0    | 72.5        | 36.8                |
| 10   | 73.2        | 36.7                |
| 20   | 71.8        | 36.9                |

## Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `INPUT_FILE` | Path to input Excel file | Required |
| `OUTPUT_DIR` | Directory for outputs | `~/Desktop/` |
| `HR_COLUMN` | Name of heart rate column | `HR(bpm):ECG` |
| `TEMP_COLUMN` | Name of temperature column | `T_NPMN(Celsius):Temp` |
| `TIME_COLUMN` | Name of time column | `Time` |
| `SAMPLING_INTERVAL` | Time between measurements (seconds) | `10` |
| `DETREND_SPAN` | LOESS smoothing parameter (0-1) | `0.3` |

## Outputs

### Files Generated
1. **Excel Files**:
   - `[filename]_correlation_original.xlsx` - Original signal correlations
   - `[filename]_correlation_detrended.xlsx` - Detrended signal correlations

2. **Visualization**:
   - `[filename]_correlation_plot.pdf` - Combined correlation plots

3. **Batch Processing** (if applicable):
   - `batch_summary.xlsx` - Summary of all processed files

### Console Output
- Processing status and progress
- Maximum correlation values and lag times
- Interpretation of temporal relationships
- Summary statistics

## Interpretation Guide

### Lag Values
- **Negative lag**: Temperature changes precede heart rate changes
- **Positive lag**: Heart rate changes precede temperature changes
- **Zero lag**: Changes are simultaneous

### Correlation Values
- **|r| > 0.7**: Strong correlation
- **0.4 < |r| < 0.7**: Moderate correlation
- **0.2 < |r| < 0.4**: Weak correlation
- **|r| < 0.2**: Very weak/no correlation

## Example Results

```
Temperature vs Heart Rate (Original):
Max Lag: -13.17 minutes
Correlation: 0.408
(Temperature changes precede heart rate changes)

Temperature vs Heart Rate (Detrended):
Max Lag: -13.17 minutes
Correlation: 0.478
(Temperature changes precede heart rate changes)
```

## Troubleshooting

### Common Issues

1. **"File not found" error**:
   - Check file path in `config.R`
   - Ensure file extension is .xlsx

2. **"Column not found" error**:
   - Verify column names match exactly (case-sensitive)
   - Check for extra spaces in column names

3. **Missing data warnings**:
   - Normal if your data has gaps
   - Rows with NA values are automatically removed

## Methods

### Signal Processing Pipeline
1. **Data Loading**: Read Excel file and validate columns
2. **Preprocessing**: Remove rows with missing values
3. **Standardization**: Transform to zero mean, unit variance
4. **Detrending** (optional): LOESS smoothing to remove low-frequency components
5. **Cross-correlation**: Compute correlation at all possible lags
6. **Peak Detection**: Identify maximum correlation and corresponding lag
7. **Visualization**: Generate plots with annotations

### Statistical Methods
- **Standardization**: `(x - mean(x)) / sd(x)`
- **LOESS**: Local regression with configurable span
- **Cross-correlation**: Pearson correlation at various time lags

## Citation
If you use this code in your research, please cite:
```
[Your citation information here]
```

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
[Your license here - e.g., MIT, GPL, etc.]

## Contact
[Your contact information]

## Acknowledgments
[Any acknowledgments]