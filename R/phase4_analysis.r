# Phase 4: Analysis & Interpretation Logic
# This file contains server logic for Phase 4 of the Scientific Methods Engine

# Generate final report
output$final_report <- renderUI({
  req(values$results_confirmed)
  
  # Generate the complete analysis report
  report_html <- generate_final_report(values$hypothesis, values$plan, values$results, values$data)
  
  # Display as HTML
  HTML(report_html)
})

# Download handlers
output$download_html <- downloadHandler(
  filename = function() {
    paste0("scientific_analysis_report_", Sys.Date(), ".html")
  },
  content = function(file) {
    # Render the R Markdown file to HTML
    tryCatch({
      # Update the template with results
      update_rmd_with_results(values$hypothesis, values$plan, values$results, values$data)
      
      # Render to HTML
      rmarkdown::render("output/analysis_template.Rmd", 
                        output_file = file,
                        output_format = "html_document")
    }, error = function(e) {
      # If rendering fails, create a simple HTML report
      report_html <- generate_final_report(values$hypothesis, values$plan, values$results, values$data)
      writeLines(report_html, file)
    })
  }
)

output$download_rmd <- downloadHandler(
  filename = function() {
    paste0("scientific_analysis_report_", Sys.Date(), ".Rmd")
  },
  content = function(file) {
    # Update and provide the R Markdown source
    update_rmd_with_results(values$hypothesis, values$plan, values$results, values$data)
    file.copy("output/analysis_template.Rmd", file)
  }
)

# Helper function to generate final report HTML
generate_final_report <- function(hypothesis, plan, results, data) {
  
  # Start building the report
  report <- paste0(
    "<div class='report-container'>",
    "<h1>Scientific Analysis Report</h1>",
    "<p class='date'>", Sys.Date(), "</p>",
    
    "<h2>Executive Summary</h2>",
    "<div class='summary-box'>",
    "<p><strong>Hypothesis:</strong> ", hypothesis$statement, "</p>",
    "<p><strong>Result:</strong> ",
    if (!is.null(results$test) && results$test$p.value < plan$alpha) {
      "The hypothesis is supported by the data (p < α)."
    } else {
      "The hypothesis is not supported by the data (p ≥ α)."
    },
    "</p>",
    "</div>",
    
    "<h2>Introduction</h2>",
    "<p>This report presents the results of a ", 
    if (hypothesis$type == "causal") "causal" else "associational",
    " analysis examining the relationship between ",
    if (hypothesis$type == "causal") {
      paste0(hypothesis$treatment_var, " and ", hypothesis$outcome_var)
    } else {
      paste0(paste(hypothesis$predictor_vars, collapse = ", "), " and ", hypothesis$outcome_var)
    },
    ".</p>",
    
    "<h2>Methods</h2>",
    "<h3>Data</h3>",
    "<p>The analysis was conducted on a dataset with ", nrow(data), " observations and ",
    ncol(data), " variables.</p>",
    
    "<h3>Statistical Analysis</h3>",
    "<p>Statistical test: ", 
    switch(plan$test,
           "t_test" = "Independent samples t-test",
           "anova" = "One-way ANOVA",
           "lm" = "Linear regression",
           "glm" = "Logistic regression",
           "chisq" = "Chi-square test"),
    "</p>",
    "<p>Significance level: α = ", plan$alpha, "</p>",
    "<p>Statistical power: ", plan$power, "</p>"
  )
  
  # Add power analysis results
  if (!is.null(plan$mde)) {
    report <- paste0(report,
      "<h3>Power Analysis</h3>",
      "<p>", gsub("\n", "<br>", plan$mde), "</p>"
    )
  }
  
  # Add results section
  report <- paste0(report,
    "<h2>Results</h2>",
    "<h3>Descriptive Statistics</h3>"
  )
  
  # Add descriptive statistics table
  desc_stats <- data.frame(
    Variable = hypothesis$outcome_var,
    N = sum(!is.na(data[[hypothesis$outcome_var]])),
    Mean = round(mean(data[[hypothesis$outcome_var]], na.rm = TRUE), 3),
    SD = round(sd(data[[hypothesis$outcome_var]], na.rm = TRUE), 3),
    Min = round(min(data[[hypothesis$outcome_var]], na.rm = TRUE), 3),
    Max = round(max(data[[hypothesis$outcome_var]], na.rm = TRUE), 3)
  )
  
  report <- paste0(report,
    "<table class='stats-table'>",
    "<tr><th>Variable</th><th>N</th><th>Mean</th><th>SD</th><th>Min</th><th>Max</th></tr>",
    "<tr>",
    "<td>", desc_stats$Variable, "</td>",
    "<td>", desc_stats$N, "</td>",
    "<td>", desc_stats$Mean, "</td>",
    "<td>", desc_stats$SD, "</td>",
    "<td>", desc_stats$Min, "</td>",
    "<td>", desc_stats$Max, "</td>",
    "</tr>",
    "</table>"
  )
  
  # Add inferential statistics
  report <- paste0(report,
    "<h3>Inferential Statistics</h3>",
    "<pre>", results$summary, "</pre>"
  )
  
  # Add interpretation
  report <- paste0(report,
    "<h2>Discussion</h2>",
    "<p>The analysis tested the hypothesis that ", hypothesis$statement, ". ",
    "The results indicate that ",
    if (!is.null(results$test) && results$test$p.value < plan$alpha) {
      paste0("there is statistically significant evidence to support this hypothesis (p = ",
             round(results$test$p.value, 4), ").")
    } else if (!is.null(results$test)) {
      paste0("there is insufficient evidence to support this hypothesis (p = ",
             round(results$test$p.value, 4), ").")
    } else {
      "the analysis has been completed as specified."
    },
    "</p>"
  )
  
  # Add effect size interpretation if available
  if (!is.null(results$effect_size)) {
    report <- paste0(report,
      "<p>The effect size (Cohen's d = ", round(results$effect_size, 3), ") indicates a ",
      if (abs(results$effect_size) < 0.2) "negligible"
      else if (abs(results$effect_size) < 0.5) "small"
      else if (abs(results$effect_size) < 0.8) "medium"
      else "large",
      " effect.</p>"
    )
  }
  
  # Add limitations
  report <- paste0(report,
    "<h2>Limitations</h2>",
    "<ul>"
  )
  
  # Sample size limitations
  if (nrow(data) < 100) {
    report <- paste0(report,
      "<li>The sample size (n = ", nrow(data), ") is relatively small, ",
      "which may limit the generalizability of findings.</li>"
    )
  }
  
  # Causal inference limitations
  if (hypothesis$type == "causal") {
    report <- paste0(report,
      "<li>As this is an observational study, causal claims should be interpreted with caution. ",
      "Unmeasured confounding may affect the results.</li>"
    )
  }
  
  # Missing data
  missing_pct <- sum(is.na(data[[hypothesis$outcome_var]])) / nrow(data) * 100
  if (missing_pct > 5) {
    report <- paste0(report,
      "<li>The outcome variable has ", round(missing_pct, 1), "% missing values, ",
      "which may introduce bias if missingness is not at random.</li>"
    )
  }
  
  report <- paste0(report,
    "</ul>",
    
    "<h2>Conclusions</h2>",
    "<p>This analysis examined ", hypothesis$statement, ". ",
    "Based on the statistical evidence, we ",
    if (!is.null(results$test) && results$test$p.value < plan$alpha) {
      "found support for"
    } else {
      "did not find sufficient support for"
    },
    " the hypothesis. ",
    "These findings should be interpreted in the context of the study limitations ",
    "and the broader scientific literature.</p>",
    
    "</div>",
    
    # Add some basic styling
    "<style>",
    ".report-container { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; }",
    ".summary-box { background-color: #f0f0f0; padding: 15px; border-radius: 5px; margin: 20px 0; }",
    ".stats-table { width: 100%; border-collapse: collapse; margin: 20px 0; }",
    ".stats-table th, .stats-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }",
    ".stats-table th { background-color: #f2f2f2; }",
    "pre { background-color: #f5f5f5; padding: 10px; border-radius: 3px; }",
    "h1, h2, h3 { color: #333; }",
    ".date { color: #666; font-style: italic; }",
    "</style>"
  )
  
  return(report)
}

# Helper function to update R Markdown with results
update_rmd_with_results <- function(hypothesis, plan, results, data) {
  
  # Read the template
  template_lines <- readLines("output/analysis_template.Rmd")
  
  # Find and replace placeholders with actual results
  # This is a simplified version - in practice, you'd want more sophisticated replacement
  
  # Update data description
  data_desc <- paste0(
    "The dataset contains ", nrow(data), " observations and ", ncol(data), " variables. ",
    "The primary outcome variable is ", hypothesis$outcome_var, "."
  )
  
  # Update MDE results
  mde_text <- if (!is.null(plan$mde)) plan$mde else "MDE calculation not available."
  
  # Update descriptive statistics
  desc_stats <- paste0(
    "```{r descriptive-stats}\n",
    "# Descriptive statistics\n",
    "summary(data$", hypothesis$outcome_var, ")\n",
    "```"
  )
  
  # Update inferential statistics
  inf_stats <- paste0(
    "```{r inferential-stats}\n",
    "# Results from analysis\n",
    "print(results$summary)\n",
    "```"
  )
  
  # Simple placeholder replacement (in practice, use more sophisticated method)
  updated_content <- paste(template_lines, collapse = "\n")
  updated_content <- gsub("\\[Data description to be added\\]", data_desc, updated_content)
  updated_content <- gsub("\\[MDE results to be added\\]", mde_text, updated_content)
  updated_content <- gsub("\\[To be populated\\]", "See results below.", updated_content)
  
  # Write updated content
  writeLines(updated_content, "output/analysis_template.Rmd")
}