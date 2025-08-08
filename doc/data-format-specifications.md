# Data Format Specifications for Autumn

## Overview

Autumn exclusively uses RDS (R Data Serialization) format for data input to ensure security, efficiency, and compatibility with the R/Shiny environment. This document specifies the requirements and structure for data files.

## File Format Requirements

### Basic Requirements
- **Extension**: `.rds` (required)
- **Format**: R Data Serialization format
- **Content**: Must contain a data.frame or tibble object
- **Encoding**: UTF-8 for character data
- **Size Limit**: Recommended maximum 100MB for web deployment

### Creating RDS Files

```r
# From CSV
data <- read.csv("yourfile.csv", stringsAsFactors = FALSE)
saveRDS(data, "yourfile.rds")

# From Excel
library(readxl)
data <- read_excel("yourfile.xlsx")
saveRDS(data, "yourfile.rds")

# From existing data.frame
saveRDS(your_dataframe, "yourfile.rds")
```

### Reading RDS Files

```r
# Load data
data <- readRDS("yourfile.rds")

# Verify structure
str(data)
class(data)  # Should be "data.frame" or "tbl_df"
```

## Data Structure Requirements

### Required Structure
The RDS file must contain a single data.frame or tibble with:
- **Rows**: Individual observations/subjects
- **Columns**: Variables/measurements
- **Headers**: Valid R variable names (no spaces, start with letter)

### Variable Types

#### Supported Types
- **numeric**: Continuous measurements (age, weight, scores)
- **integer**: Count data (number of events)
- **character**: Text data (converted to factors as needed)
- **factor**: Categorical variables with defined levels
- **logical**: TRUE/FALSE binary variables
- **Date/POSIXct**: Temporal data (limited support)

#### Type Examples
```r
# Example data structure
example_data <- data.frame(
  subject_id = 1:100,                    # integer
  age = rnorm(100, 50, 10),             # numeric
  treatment = factor(c("A", "B")),       # factor
  gender = c("M", "F", "M", ...),       # character
  improved = c(TRUE, FALSE, TRUE, ...),  # logical
  enrollment_date = Sys.Date() - 1:100   # Date
)
```

## Variable Naming Conventions

### Best Practices
- Use lowercase with underscores: `blood_pressure`, not `BloodPressure`
- Avoid spaces: `heart_rate`, not `heart rate`
- No special characters except underscore
- Start with letter, not number: `phase_1`, not `1_phase`
- Be descriptive but concise: `systolic_bp`, not `s` or `systolic_blood_pressure_measurement`

### Reserved Names to Avoid
- R reserved words: `if`, `else`, `for`, `while`, `function`, `return`
- Common function names: `mean`, `sum`, `data`, `df`
- Single letters: `c`, `t`, `T`, `F`

## Data Quality Requirements

### Completeness
- **Minimum**: 80% non-missing values for key variables
- **Missing data coding**: Use `NA` for missing values
- **Avoid**: Empty strings, "NULL", 999, -999 as missing indicators

### Consistency
- **Units**: Consistent units within variables (all kg or all lbs)
- **Coding**: Consistent categorical coding (not mixing "Male"/"M"/"1")
- **Dates**: Single format throughout (YYYY-MM-DD recommended)

### Example Quality Check
```r
# Check data quality
data <- readRDS("yourfile.rds")

# Check structure
str(data)

# Check missing data
missing_summary <- sapply(data, function(x) sum(is.na(x))/length(x))
print(missing_summary)

# Check for complete cases
complete_cases <- sum(complete.cases(data))
cat("Complete cases:", complete_cases, "/", nrow(data))
```

## Hypothesis Testing Requirements

### For Comparative Studies
Required variables:
- **Outcome variable**: Continuous or binary measure
- **Group/Treatment variable**: Factor with 2+ levels
- **Covariates** (optional): Additional adjustment variables

Example:
```r
comparative_data <- data.frame(
  patient_id = 1:200,
  treatment_group = factor(rep(c("Control", "Treatment"), each = 100)),
  outcome_score = c(rnorm(100, 50, 10), rnorm(100, 55, 10)),
  baseline_score = rnorm(200, 48, 8),
  age = rnorm(200, 45, 12),
  gender = factor(sample(c("M", "F"), 200, replace = TRUE))
)
```

### For Correlational Studies
Required variables:
- **Predictor variables**: One or more continuous/categorical
- **Outcome variable**: Continuous or binary
- **Sample size**: Minimum 30 for basic analyses

Example:
```r
correlation_data <- data.frame(
  subject_id = 1:150,
  exercise_hours = rlnorm(150, 2, 0.5),
  diet_quality = runif(150, 1, 10),
  bmi = rnorm(150, 27, 4),
  cholesterol = rnorm(150, 200, 30),
  diabetes = factor(sample(c("No", "Yes"), 150, replace = TRUE, prob = c(0.8, 0.2)))
)
```

### For Time Series/Longitudinal
Required structure:
- **Subject identifier**: Unique ID per subject
- **Time variable**: Numeric or date indicating time points
- **Measurements**: Repeated measures at each time point

Example:
```r
longitudinal_data <- data.frame(
  subject_id = rep(1:50, each = 4),
  time_point = rep(c(0, 3, 6, 12), 50),  # months
  measurement = rnorm(200, 100, 15) + rep(1:50, each = 4) * 0.5,
  treatment = factor(rep(c("A", "B"), each = 100))
)
```

## Example Data Generation

Autumn includes built-in example datasets. To generate them:

```r
# Run the data generation script
source("sme-example-data.r")

# This creates:
# - data/example_medical_data.rds
# - data/example_lifestyle_data.rds
```

### Example Medical Data Structure
```r
example_medical <- readRDS("data/example_medical_data.rds")
# Contains:
# - patient_id: Unique identifier
# - age: Numeric age in years
# - gender: Factor with levels "Male", "Female"
# - treatment_group: Factor with levels "Control", "Treatment"
# - baseline_score: Numeric baseline measurement
# - outcome_score: Numeric outcome measurement
# - adverse_events: Integer count of events
```

### Example Lifestyle Data Structure
```r
example_lifestyle <- readRDS("data/example_lifestyle_data.rds")
# Contains:
# - participant_id: Unique identifier
# - exercise_hours: Numeric hours per week
# - sleep_quality: Numeric scale 1-10
# - stress_level: Numeric scale 1-10
# - diet_quality: Numeric scale 1-10
# - bmi: Numeric body mass index
# - mood_score: Numeric psychological measure
```

## Validation in Autumn

### Automatic Checks
When data is uploaded, Autumn automatically:
1. Verifies valid RDS format
2. Confirms data.frame/tibble structure
3. Checks variable types
4. Assesses missing data patterns
5. Validates sample size adequacy

### Error Messages
Common validation errors and solutions:

| Error | Cause | Solution |
|-------|-------|----------|
| "Invalid RDS file" | Not proper RDS format | Re-save using `saveRDS()` |
| "No data.frame found" | Contains list or other object | Ensure single data.frame saved |
| "Insufficient sample size" | N < 30 | Collect more data or adjust hypothesis |
| "No variation in outcome" | All values identical | Check data processing pipeline |
| "Variables not found" | Expected columns missing | Verify variable names match hypothesis |

## Best Practices

### Before Upload
1. **Clean data** in R or preferred tool
2. **Standardize** variable names
3. **Code missing** values as `NA`
4. **Document** any transformations
5. **Save as RDS** using `saveRDS()`

### Data Preparation Checklist
- [ ] Data in data.frame/tibble format
- [ ] Variable names follow conventions
- [ ] Missing values coded as NA
- [ ] Categorical variables as factors
- [ ] No empty columns or rows
- [ ] Sample size adequate for analysis
- [ ] Outcome and predictor variables present
- [ ] Data dictionary documented

## Security Considerations

### Why RDS Format?
1. **Binary format**: Harder to tamper with than CSV
2. **Type preservation**: Maintains R data types exactly
3. **Single object**: Reduces injection risks
4. **Efficient**: Smaller file sizes than text formats
5. **Native to R**: No parsing vulnerabilities

### Data Privacy
- All processing occurs locally in user's browser
- No raw data transmitted to servers
- Only aggregated statistics shared with APIs
- RDS files never leave local environment

## Troubleshooting

### Common Issues

**1. File Won't Upload**
- Check file extension is `.rds`
- Verify file size < 100MB
- Ensure valid RDS format

**2. Variables Not Recognized**
- Check variable names for spaces/special characters
- Verify data types match requirements
- Ensure required variables present

**3. Analysis Won't Run**
- Verify sufficient non-missing data
- Check for variation in outcomes
- Ensure appropriate variable types

### Diagnostic Code
```r
# Comprehensive data diagnostic
diagnose_data <- function(file_path) {
  data <- readRDS(file_path)
  
  cat("Data Diagnostics\n")
  cat("================\n")
  cat("Class:", class(data), "\n")
  cat("Dimensions:", nrow(data), "rows x", ncol(data), "columns\n")
  cat("Column names:", paste(names(data), collapse = ", "), "\n\n")
  
  cat("Variable Types:\n")
  print(sapply(data, class))
  
  cat("\nMissing Data:\n")
  missing <- sapply(data, function(x) sum(is.na(x)))
  print(missing[missing > 0])
  
  cat("\nNumeric Summaries:\n")
  numeric_vars <- sapply(data, is.numeric)
  if(any(numeric_vars)) {
    print(summary(data[, numeric_vars]))
  }
  
  cat("\nFactor Levels:\n")
  factor_vars <- sapply(data, is.factor)
  if(any(factor_vars)) {
    lapply(data[, factor_vars, drop = FALSE], table)
  }
}

# Run diagnostic
diagnose_data("your_data.rds")
```

## Additional Resources

- [R Data Import/Export Manual](https://cran.r-project.org/doc/manuals/r-release/R-data.html)
- [Tidyverse Style Guide](https://style.tidyverse.org/)
- [RDS Format Documentation](https://www.rdocumentation.org/packages/base/versions/3.6.2/topics/readRDS)