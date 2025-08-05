# Scientific Methods Engine - Detailed Instructions

## Important Notes

### Data Privacy
- All data processing occurs locally in your R environment
- No data is uploaded to external servers
- Results can be shared via JSON format while maintaining privacy

### Statistical Considerations

1. **Power Analysis**
   - MDE < 0.2: Very small effect (may be hard to detect)
   - MDE 0.2-0.5: Small effect
   - MDE 0.5-0.8: Medium effect
   - MDE > 0.8: Large effect (easier to detect)

2. **Sample Size Requirements**
   - Minimum 20 observations for basic analyses
   - For group comparisons: At least 10 per group
   - For regression: 10-20 observations per predictor

3. **Causal Inference**
   - Causal claims require careful consideration
   - The app implements basic adjustment for confounders
   - Results should be interpreted with caution
   - Consider unmeasured confounding

### Troubleshooting

1. **"File must contain a data frame or tibble"**
   - Ensure your RDS file contains a data.frame or tibble object
   - Use `saveRDS(your_data, "filename.rds")` to save properly

2. **"Missing variables" error**
   - Check that selected variables exist in your dataset
   - Variable names are case-sensitive

3. **Power too low**
   - Consider simplifying your analysis
   - Focus on larger effect sizes
   - Collect more data if possible

4. **Analysis fails to execute**
   - Check for missing values in key variables
   - Ensure appropriate variable types (numeric for continuous outcomes)
   - Review error messages in execution status

### Best Practices

1. **Hypothesis Formulation**
   - Be specific and measurable
   - State expected direction of effect
   - Ensure hypothesis is testable with available data

2. **Variable Selection**
   - Choose theoretically relevant covariates
   - Avoid including too many predictors relative to sample size
   - Consider multicollinearity for multiple predictors

3. **Interpretation**
   - Statistical significance ≠ practical significance
   - Consider effect sizes, not just p-values
   - Acknowledge limitations honestly
   - Compare results to literature benchmarks

4. **Reporting**
   - Download both HTML and R Markdown files
   - The R Markdown can be further edited and customized
   - Include all relevant assumptions and limitations

## File Structure

```
scientific-methods-engine-ai/
├── app.R                    # Main Shiny application
├── R/
│   ├── phase1_hypothesis.R  # Hypothesis formulation logic
│   ├── phase2_planning.R    # Analytic planning logic
│   ├── phase3_implementation.R # Implementation logic
│   ├── phase4_analysis.R    # Analysis and reporting logic
│   └── utils.R             # Utility functions
├── www/
│   └── styles.css          # Custom styling
├── data/
│   ├── example_medical_data.rds    # Example causal data
│   └── example_lifestyle_data.rds  # Example associational data
├── output/
│   └── (generated files)    # Reports generated during analysis
└── generate_example_data.R  # Script to create example datasets
```

## Extending the Application

### Adding New Statistical Tests

To add a new test, modify these files:

1. `phase2_planning.R`: Add test to selection dropdown
2. `phase3_implementation.R`: Add code generation in `generate_analysis_function()`
3. `utils.R`: Add power/MDE calculations for the new test

### Customizing Reports

Edit `phase4_analysis.R` to modify:
- Report structure in `generate_final_report()`
- R Markdown template in `generate_rmd_template()` (in phase2_planning.R)

### Adding Visualizations

Modify `phase3_implementation.R` to add new plot types in the results visualization section.

## Support and Contributions

This is a minimum workable example designed to demonstrate the concept of a scientific methods engine. For production use, consider:

- Adding more statistical tests
- Implementing advanced causal inference methods
- Adding more robust error handling
- Creating unit tests
- Implementing user authentication for multi-user environments

## License

This project is provided as-is for educational and research purposes.

---

For questions or issues, please refer to the inline documentation in the source code or create an issue in the project repository. Overview

The Scientific Methods Engine is an R Shiny application designed to guide users through a structured scientific analysis following the four phases of the scientific method:

1. **Hypothesis Formulation** - Define and validate your research question
2. **Analytic Planning** - Develop a statistical plan with power analysis
3. **Implementation** - Execute the analysis with generated R code
4. **Analysis** - Interpret results and generate reports

## Installation and Setup

### Prerequisites

1. **R** (version 4.0 or higher)
2. **RStudio** (recommended for easy execution)
3. **Required R packages**:

```r
# Install required packages
install.packages(c(
  "shiny",
  "shinydashboard",
  "DT",
  "tidyverse",
  "jsonlite",
  "knitr",
  "rmarkdown",
  "ggplot2",
  "broom"
))
```

### Running the Application

1. Open RStudio
2. Set your working directory to the project folder:
```r
setwd("C:/Users/marcu/git-repositories/scientific-methods-engine-ai")
```

3. Generate example data (first time only):
```r
source("generate_example_data.R")
```

4. Launch the application:
```r
shiny::runApp("app.R")
```

## Using the Application

### Phase 1: Hypothesis Formulation

1. **Upload Data**
   - Click "Choose RDS File" and select your `.rds` data file
   - Example files are provided in the `data/` folder:
     - `example_medical_data.rds` - For causal hypothesis testing
     - `example_lifestyle_data.rds` - For associational analysis

2. **Formulate Hypothesis**
   - Enter a clear, testable hypothesis
   - Select hypothesis type:
     - **Associational**: Examines relationships between variables
     - **Causal**: Tests cause-and-effect relationships
   
3. **Select Variables**
   - Choose your outcome variable
   - For causal hypotheses: Select treatment variable and covariates
   - For associational: Select predictor variables

4. **Review Validation**
   - Check data validation results
   - Ensure adequate sample size and variable types

5. **Confirm** to proceed to Phase 2

### Phase 2: Analytic Planning

1. **Power Analysis**
   - Set significance level (α, typically 0.05)
   - Set desired power (typically 0.80)
   - Review Minimum Detectable Effect Size (MDE)

2. **Select Statistical Test**
   - T-test: Compare two groups
   - ANOVA: Compare multiple groups
   - Linear Regression: Continuous outcome with predictors
   - Logistic Regression: Binary outcome
   - Chi-square: Categorical variables

3. **Add Literature Benchmarks** (optional)
   - Click "Add Benchmark" to enter effect sizes from similar studies
   - Helps contextualize your expected results

4. **Review Analytic Plan**
   - Ensure the plan aligns with your hypothesis
   - **Approve Plan** to generate R Markdown template

### Phase 3: Implementation

1. **Review Generated Code**
   - Examine the R function created for your analysis
   - The code is tailored to your specific hypothesis and data

2. **Execute Analysis**
   - Click "Execute Analysis" to run the statistical tests
   - View execution status and any errors

3. **Review Results**
   - Examine plots and statistical summaries
   - **Confirm Results** to proceed to final phase

### Phase 4: Analysis & Interpretation

1. **Review Final Report**
   - Complete analysis report with:
     - Executive summary
     - Methods description
     - Results with tables and figures
     - Statistical interpretation
     - Limitations
     - Conclusions

2. **Export Results**
   - Download HTML Report: Formatted final report
   - Download R Markdown Source: Editable analysis document

## Example Hypotheses

### Causal Hypothesis Example
Using `example_medical_data.rds`:
- **Hypothesis**: "The treatment will significantly reduce outcome scores compared to control"
- **Type**: Causal
- **Outcome**: outcome_score
- **Treatment**: treatment_group
- **Covariates**: age, baseline_score, diabetes, hypertension

### Associational Hypothesis Example
Using `example_lifestyle_data.rds`:
- **Hypothesis**: "Stress level and sleep hours are significantly associated with health scores"
- **Type**: Associational
- **Outcome**: health_score
- **Predictors**: stress_level, sleep_hours, exercise_hours_per_week

##