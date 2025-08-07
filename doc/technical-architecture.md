# Technical Architecture for Autumn

## Four Phases of the Scientific Method

### Phase 1: Hypothesis Formulation
**Goal**: Arrive at consensus between Anthropic and user on a specific, clear, falsifiable, and testable hypothesis.

**Requirements**:
- User provides initial hypothesis statement
- AI may recommend improvements but reformulations require user direction
- Includes data validation to ensure data can test the hypothesis
- Once confirmed, hypothesis becomes immutable
- Hypothesis remains visible throughout subsequent phases

### Phase 2: Analytic Planning
**Goal**: Develop consensus on analytic plan that can be implemented in local R environment.

**Requirements**:
- Anthropic supplements internal knowledge with literature scanning
- Pre-populate R markdown file with agreed evidence

**Power Analysis Components** (given fixed sample size):
- Minimum detectable effect size (MDE) calculation
- Literature-based benchmarking against similar studies
- Sensitivity analyses (power = 0.70, 0.80, 0.90)
- Alternative approaches if power insufficient:
  - Focus on estimation with confidence intervals
  - Bayesian methods incorporating prior information
  - Outcome aggregation or simplified comparisons

### Phase 3: Implementation
**Goal**: Generate and execute R functions for analysis.

**Requirements**:
- Develop R function for descriptive and inferential statistics
- Source functions into local R environment
- Execute and capture outputs
- Return results to Anthropic via JSON

### Phase 4: Analysis
**Goal**: Interpret results and document limitations.

**Requirements**:
- Read output from local R environment
- Populate R markdown with evidence
- Interpret findings regarding hypothesis
- Document assumptions and limitations
- Include power limitations in conclusions

## Data Management

### Input Specifications
- **Format**: RDS files only (.rds extension)
- **Validation**: Verify valid RDS format containing data frame/tibble
- **Persistence**: Data remains local only; no server-side storage

### Data Sharing Protocol
- **Format**: JSON for statistics exchange
- **Structure**:
```json
{
  "descriptive_stats": {
    "summary_statistics": {},
    "plots": ["base64_encoded_images"],
    "sample_characteristics": {}
  },
  "inferential_results": {
    "test_name": "string",
    "test_statistics": {},
    "p_values": {},
    "confidence_intervals": {},
    "effect_sizes": {}
  }
}
```

## R Environment Integration

### Reactive Programming
- Parse Anthropic-generated R code
- Automatically source functions into user's environment
- Capture and display errors in user-friendly format

### Example Implementation
```r
output$analysis_results <- renderPlot({
  # Parse Anthropic output
  code_string <- parse_anthropic_response(input$anthropic_output)
  
  # Create temporary function
  temp_func <- eval(parse(text = code_string))
  
  # Execute with user data
  results <- temp_func(user_data())
  
  # Return plot or results
  results$plot
})
```

## Output Specifications

### R Markdown Rendering
- **Format**: HTML for interactive display
- **Components**: 
  - Embedded plots (ggplot2, base R)
  - Interactive tables (DT, kableExtra)
  - APA-style formatted results
- **Live preview**: Real-time rendering as completed

### Export Options
- HTML (primary)
- .Rmd source file download
- Complete reproducible analysis

## General Requirements

- All coding in R with thorough documentation
- Explicit package sourcing in function calls
- APA convention for tables and plots
- Citations include article links where appropriate