# Phase 4: Analysis & Interpretation with Chat Integration
# Enhanced version with collaborative AI interaction

# Generate final report
output$final_report <- renderUI({
  req(values$results_confirmed)
  
  # Generate the complete analysis report
  report_html <- generate_final_report(values$hypothesis, values$plan, values$results, values$data)
  
  # Store for later use
  values$final_report <- report_html
  
  # Add welcome message to chat
  if (length(values$chat_history$analysis) == 0) {
    ai_msg <- list(
      sender = "ai",
      content = paste0(
        "Welcome to the final phase! I've generated your complete analysis report. As we review it together, I can help you:\n\n",
        "1. **Interpret the findings** - What do these results really mean?\n",
        "2. **Assess practical significance** - Beyond p-values, what's the real-world impact?\n",
        "3. **Identify limitations** - What caveats should readers know?\n",
        "4. **Suggest future directions** - Where do we go from here?\n",
        "5. **Refine the narrative** - How to communicate this effectively?\n\n",
        "What aspects of your results would you like to discuss first?"
      )
    )
    values$chat_history$analysis <- append(values$chat_history$analysis, list(ai_msg))
  }
  
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
                        output_format = "html_document",
                        quiet = TRUE)
    }, error = function(e) {
      # If rendering fails, save the HTML report directly
      writeLines(values$final_report, file)
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
    "<p class='date'>Generated on ", Sys.Date(), "</p>",
    
    "<h2>Executive Summary</h2>",
    "<div class='summary-box'>",
    "<p><strong>Research Question:</strong> ", hypothesis$statement, "</p>",
    "<p><strong>Key Finding:</strong> "
  )
  
  # Add key finding based on results
  if (!is.null(results$test) && !is.null(results$test$p.value)) {
    report <- paste0(report,
      ifelse(results$test$p.value < plan$alpha,
             paste0("The analysis revealed a statistically significant effect (p ", 
                    format.pval(results$test$p.value), ")."),
             paste0("The analysis did not find a statistically significant effect (p ", 
                    format.pval(results$test$p.value), ").")
      )
    )
  } else if (!is.null(results$model)) {
    report <- paste0(report,
      "The regression model explained ", 
      round(results$r_squared * 100, 1), 
      "% of the variance in the outcome."
    )
  }
  
  report <- paste0(report,
    "</p>",
    if (!is.null(results$effect_size)) {
      paste0("<p><strong>Effect Size:</strong> ", 
             round(results$effect_size, 3), 
             " (", 
             if (abs(results$effect_size) < 0.2) "negligible" 
             else if (abs(results$effect_size) < 0.5) "small"
             else if (abs(results$effect_size) < 0.8) "medium"
             else "large",
             " effect)</p>")
    },
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
    
    "<h3>Hypothesis</h3>",
    "<p><em>", hypothesis$statement, "</em></p>",
    
    "<h2>Methods</h2>",
    "<h3>Data</h3>",
    "<p>The analysis was conducted on a dataset with ", nrow(data), " observations and ",
    ncol(data), " variables.",
    if (!is.null(results$n) && results$n < nrow(data)) {
      paste0(" After excluding cases with missing data, ", results$n, 
             " observations were included in the analysis.")
    },
    "</p>",
    
    "<h3>Statistical Analysis</h3>",
    "<p>Statistical test: ", 
    switch(plan$test,
           "t_test" = "Independent samples t-test",
           "anova" = "One-way ANOVA",
           "lm" = "Linear regression",
           "glm" = "Logistic regression",
           "chisq" = "Chi-square test"),
    "</p>",
    "<ul>",
    "<li>Significance level: α = ", plan$alpha, "</li>",
    "<li>Statistical power: ", plan$power, "</li>",
    if (!is.null(plan$mde)) {
      paste0("<li>Minimum detectable effect: ", round(plan$mde, 3), "</li>")
    },
    "</ul>"
  )
  
  # Add power analysis context
  if (!is.null(plan$mde)) {
    report <- paste0(report,
      "<h3>Power Analysis</h3>",
      "<p>With the available sample size and specified parameters, this study had ",
      plan$power * 100, "% power to detect effects of size ",
      round(plan$mde, 3), " or larger. ",
      if (plan$mde > 0.5) {
        "This indicates the study was only powered to detect medium to large effects."
      } else {
        "This indicates good sensitivity to detect even small to medium effects."
      },
      "</p>"
    )
  }
  
  # Add benchmarks if available
  if (!is.null(plan$benchmarks) && nrow(plan$benchmarks) > 0) {
    report <- paste0(report,
      "<h3>Literature Benchmarks</h3>",
      "<p>Effect sizes from comparable studies:</p>",
      "<ul>"
    )
    for (i in 1:nrow(plan$benchmarks)) {
      report <- paste0(report,
        "<li>", plan$benchmarks$Study[i], ": ", 
        plan$benchmarks$Effect_Size[i], " (n = ", 
        plan$benchmarks$Sample_Size[i], ")</li>"
      )
    }
    report <- paste0(report, "</ul>")
  }
  
  # Results section
  report <- paste0(report,
    "<h2>Results</h2>",
    "<h3>Descriptive Statistics</h3>"
  )
  
  # Create descriptive statistics table
  desc_stats <- data.frame(
    Variable = hypothesis$outcome_var,
    N = sum(!is.na(data[[hypothesis$outcome_var]])),
    Mean = round(mean(data[[hypothesis$outcome_var]], na.rm = TRUE), 2),
    SD = round(sd(data[[hypothesis$outcome_var]], na.rm = TRUE), 2),
    Min = round(min(data[[hypothesis$outcome_var]], na.rm = TRUE), 2),
    Max = round(max(data[[hypothesis$outcome_var]], na.rm = TRUE), 2)
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
  
  # Group statistics for t-test
  if (plan$test == "t_test" && !is.null(results$means)) {
    report <- paste0(report,
      "<h4>Group Statistics</h4>",
      "<table class='stats-table'>",
      "<tr><th>Group</th><th>N</th><th>Mean</th><th>SD</th></tr>"
    )
    for (i in 1:length(results$means)) {
      report <- paste0(report,
        "<tr>",
        "<td>", names(results$means)[i], "</td>",
        "<td>", results$ns[i], "</td>",
        "<td>", round(results$means[i], 2), "</td>",
        "<td>", round(results$sds[i], 2), "</td>",
        "</tr>"
      )
    }
    report <- paste0(report, "</table>")
  }
  
  # Inferential statistics
  report <- paste0(report,
    "<h3>Inferential Statistics</h3>",
    "<div class='results-box'>",
    "<pre>", results$summary, "</pre>",
    "</div>"
  )
  
  # Interpretation section
  report <- paste0(report,
    "<h2>Discussion</h2>",
    "<h3>Interpretation of Results</h3>",
    "<p>"
  )
  
  # Add interpretation based on results
  if (!is.null(results$test) && !is.null(results$test$p.value)) {
    if (results$test$p.value < plan$alpha) {
      report <- paste0(report,
        "The analysis provides statistically significant evidence ",
        "to support the hypothesis (p ", format.pval(results$test$p.value), "). "
      )
      if (!is.null(results$effect_size)) {
        report <- paste0(report,
          "The effect size of ", round(results$effect_size, 3),
          " suggests a ", 
          if (abs(results$effect_size) < 0.2) "negligible" 
          else if (abs(results$effect_size) < 0.5) "small"
          else if (abs(results$effect_size) < 0.8) "medium"
          else "large",
          " practical impact. "
        )
      }
    } else {
      report <- paste0(report,
        "The analysis did not find statistically significant evidence ",
        "to support the hypothesis (p ", format.pval(results$test$p.value), "). ",
        "This could indicate either no true effect exists, ",
        "or the study lacked sufficient power to detect it."
      )
    }
  }
  
  report <- paste0(report, "</p>")
  
  # Comparison to benchmarks
  if (!is.null(results$effect_size) && !is.null(plan$benchmarks) && nrow(plan$benchmarks) > 0) {
    avg_benchmark <- mean(plan$benchmarks$Effect_Size)
    report <- paste0(report,
      "<h3>Comparison to Literature</h3>",
      "<p>The observed effect size of ", round(results$effect_size, 3),
      " is ",
      if (abs(results$effect_size) < avg_benchmark * 0.8) "smaller than"
      else if (abs(results$effect_size) > avg_benchmark * 1.2) "larger than"
      else "comparable to",
      " the average effect size in the literature (", round(avg_benchmark, 3), ").</p>"
    )
  }
  
  # Limitations section
  report <- paste0(report,
    "<h2>Limitations</h2>",
    "<ul>"
  )
  
  # Add specific limitations
  if (nrow(data) < 100) {
    report <- paste0(report,
      "<li><strong>Sample size:</strong> The relatively small sample size (n = ", 
      nrow(data), ") limits statistical power and generalizability.</li>"
    )
  }
  
  if (hypothesis$type == "causal") {
    report <- paste0(report,
      "<li><strong>Causal inference:</strong> ",
      "As an observational study, causal conclusions should be drawn cautiously. ",
      "Unmeasured confounding remains a possibility.</li>"
    )
  }
  
  missing_pct <- sum(is.na(data[[hypothesis$outcome_var]])) / nrow(data) * 100
  if (missing_pct > 5) {
    report <- paste0(report,
      "<li><strong>Missing data:</strong> ",
      round(missing_pct, 1), "% of outcome data was missing, ",
      "which could introduce bias if missingness is not random.</li>"
    )
  }
  
  if (!is.null(results$normality_p) && any(results$normality_p < 0.05, na.rm = TRUE)) {
    report <- paste0(report,
      "<li><strong>Assumption violations:</strong> ",
      "Tests indicated potential violations of normality assumptions, ",
      "though the analysis may be robust to minor violations.</li>"
    )
  }
  
  report <- paste0(report,
    "</ul>",
    
    "<h2>Conclusions</h2>",
    "<p>This analysis examined the hypothesis: <em>", hypothesis$statement, "</em>. ",
    "The results "
  )
  
  if (!is.null(results$test) && !is.null(results$test$p.value)) {
    report <- paste0(report,
      ifelse(results$test$p.value < plan$alpha,
             "provide evidence supporting",
             "do not provide sufficient evidence to support"),
      " this hypothesis. "
    )
  }
  
  report <- paste0(report,
    "These findings should be interpreted in the context of the study's limitations ",
    "and the existing scientific literature. ",
    if (!is.null(plan$mde) && plan$mde > 0.5) {
      "Future studies with larger samples may be needed to detect smaller effects. "
    },
    "</p>",
    
    "<h2>References</h2>",
    if (!is.null(plan$benchmarks) && nrow(plan$benchmarks) > 0) {
      paste0("<ul>",
        paste(apply(plan$benchmarks, 1, function(row) {
          paste0("<li>", row["Study"], "</li>")
        }), collapse = ""),
        "</ul>")
    } else {
      "<p><em>No literature benchmarks were included in this analysis.</em></p>"
    },
    
    "</div>",
    
    # Add styling
    "<style>",
    ".report-container { font-family: Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px; line-height: 1.6; }",
    ".summary-box { background-color: #f0f8ff; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #0066cc; }",
    ".results-box { background-color: #f5f5f5; padding: 15px; border-radius: 4px; margin: 15px 0; }",
    ".stats-table { width: 100%; border-collapse: collapse; margin: 20px 0; }",
    ".stats-table th, .stats-table td { border: 1px solid #ddd; padding: 10px; text-align: left; }",
    ".stats-table th { background-color: #f2f2f2; font-weight: bold; }",
    ".stats-table tr:nth-child(even) { background-color: #f9f9f9; }",
    "pre { background-color: #f5f5f5; padding: 15px; border-radius: 4px; overflow-x: auto; font-family: 'Courier New', monospace; }",
    "h1, h2, h3 { color: #333; }",
    "h1 { border-bottom: 2px solid #0066cc; padding-bottom: 10px; }",
    "h2 { margin-top: 30px; color: #0066cc; }",
    "h3 { color: #666; }",
    ".date { color: #666; font-style: italic; }",
    "ul { line-height: 1.8; }",
    "em { color: #0066cc; font-style: italic; }",
    "</style>"
  )
  
  return(report)
}

# Helper function to update R Markdown with results
update_rmd_with_results <- function(hypothesis, plan, results, data) {
  
  # Read the template if it exists
  template_path <- "output/analysis_template.Rmd"
  if (!file.exists(template_path)) {
    # Create a basic template if it doesn't exist
    generate_rmd_template(hypothesis, plan)
  }
  
  template_lines <- readLines(template_path)
  
  # Prepare content updates
  data_desc <- paste0(
    "The dataset contains ", nrow(data), " observations and ", ncol(data), " variables. ",
    "The primary outcome variable is `", hypothesis$outcome_var, "`.",
    if (!is.null(results$n) && results$n < nrow(data)) {
      paste0(" After excluding missing data, ", results$n, " cases were analyzed.")
    }
  )
  
  # MDE results
  mde_text <- if (!is.null(plan$mde)) {
    paste0("With the current sample size and α = ", plan$alpha, 
           ", the study has ", plan$power * 100, 
           "% power to detect effects of size ", round(plan$mde, 3), " or larger.")
  } else {
    "Power analysis was not conducted."
  }
  
  # Create descriptive statistics code chunk
  desc_stats_chunk <- paste0(
    "```{r descriptive-stats, echo=FALSE}\n",
    "# Descriptive statistics\n",
    "desc_table <- data.frame(\n",
    "  Variable = c('", hypothesis$outcome_var, "'),\n",
    "  N = c(", sum(!is.na(data[[hypothesis$outcome_var]])), "),\n",
    "  Mean = c(", round(mean(data[[hypothesis$outcome_var]], na.rm = TRUE), 2), "),\n",
    "  SD = c(", round(sd(data[[hypothesis$outcome_var]], na.rm = TRUE), 2), "),\n",
    "  Min = c(", round(min(data[[hypothesis$outcome_var]], na.rm = TRUE), 2), "),\n",
    "  Max = c(", round(max(data[[hypothesis$outcome_var]], na.rm = TRUE), 2), ")\n",
    ")\n",
    "kable(desc_table, caption = 'Descriptive Statistics')\n",
    "```"
  )
  
  # Create inferential statistics section
  inf_stats_text <- if (!is.null(results$summary)) {
    paste0("```\n", results$summary, "\n```")
  } else {
    "Results not available."
  }
  
  # Discussion text
  discussion_text <- paste0(
    "The analysis tested the hypothesis: ", hypothesis$statement, ". ",
    if (!is.null(results$test) && !is.null(results$test$p.value)) {
      paste0("The results ",
             ifelse(results$test$p.value < plan$alpha, "support", "do not support"),
             " this hypothesis (p ", format.pval(results$test$p.value), ").")
    }
  )
  
  # Limitations text
  limitations_text <- paste0(
    "- Sample size: n = ", nrow(data), "\n",
    if (hypothesis$type == "causal") {
      "- Causal inference limited by observational design\n"
    },
    if (sum(is.na(data[[hypothesis$outcome_var]])) > 0) {
      paste0("- Missing data: ", sum(is.na(data[[hypothesis$outcome_var]])), " cases\n")
    }
  )
  
  # Replace placeholders
  updated_content <- paste(template_lines, collapse = "\n")
  updated_content <- gsub("\\[Data description to be added\\]", data_desc, updated_content)
  updated_content <- gsub("\\[MDE results to be added\\]", mde_text, updated_content)
  updated_content <- gsub("\\[To be populated\\]", "See results below.", updated_content)
  
  # Write updated content
  writeLines(updated_content, template_path)
}

# Monitor chat for specific analysis questions
observe({
  # This observer could trigger specific analyses or updates based on chat content
  # For now, it's a placeholder for future enhancements
})

# Helper function to format p-values (if not already defined)
if (!exists("format.pval")) {
  format.pval <- function(p) {
    if (is.null(p) || is.na(p)) return("NA")
    if (p < 0.001) return("< 0.001")
    if (p < 0.01) return(paste0("= ", format(round(p, 3), nsmall = 3)))
    return(paste0("= ", format(round(p, 2), nsmall = 2)))
  }
}

# Helper function for R Markdown template generation
generate_rmd_template <- function(hypothesis, plan) {
  template <- paste0(
    "---\n",
    "title: \"Scientific Analysis Report\"\n",
    "author: \"Scientific Methods Engine\"\n",
    "date: \"`r Sys.Date()`\"\n",
    "output: \n",
    "  html_document:\n",
    "    toc: true\n",
    "    toc_float: true\n",
    "    theme: cerulean\n",
    "    code_folding: hide\n",
    "---\n\n",
    "```{r setup, include=FALSE}\n",
    "knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE)\n",
    "library(tidyverse)\n",
    "library(knitr)\n",
    "library(broom)\n",
    "```\n\n",
    "# Abstract\n\n",
    "This report presents the results of a scientific analysis testing the following hypothesis:\n\n",
    "> ", hypothesis$statement, "\n\n",
    "# Introduction\n\n",
    "## Research Question\n\n",
    "[To be populated with results]\n\n",
    "## Hypothesis\n\n",
    "- **Type**: ", capitalize(hypothesis$type), "\n",
    "- **Outcome Variable**: ", hypothesis$outcome_var, "\n",
    if (hypothesis$type == "causal") {
      paste0("- **Treatment Variable**: ", hypothesis$treatment_var, "\n",
             if (length(hypothesis$covariate_vars) > 0) {
                paste0("- **Covariates**: ", paste(hypothesis$covariate_vars, collapse = ", "), "\n")
             })
    } else {
      paste0("- **Predictor Variables**: ", paste(hypothesis$predictor_vars, collapse = ", "), "\n")
    },
    "\n",
    "# Methods\n\n",
    "## Data\n\n",
    "[Data description to be added]\n\n",
    "## Statistical Analysis\n\n",
    "- **Test**: ", switch(plan$test,
                           "t_test" = "Independent samples t-test",
                           "anova" = "One-way ANOVA",
                           "lm" = "Linear regression",
                           "glm" = "Logistic regression",
                           "chisq" = "Chi-square test"), "\n",
    "- **Significance Level**: α = ", plan$alpha, "\n",
    "- **Power**: ", plan$power, "\n\n",
    "## Power Analysis\n\n",
    "[MDE results to be added]\n\n",
    "# Results\n\n",
    "## Descriptive Statistics\n\n",
    "[To be populated]\n\n",
    "## Inferential Statistics\n\n",
    "[To be populated]\n\n",
    "## Visualizations\n\n",
    "```{r results-plot, echo=FALSE, fig.width=8, fig.height=6}\n",
    "# Visualization code will be added here\n",
    "```\n\n",
    "# Discussion\n\n",
    "[To be populated]\n\n",
    "# Limitations\n\n",
    "[To be populated]\n\n",
    "# Conclusions\n\n",
    "[To be populated]\n\n",
    "# References\n\n",
    "[To be added]\n\n",
    "# Appendix: Chat Log\n\n",
    "Key insights from the collaborative analysis process:\n\n",
    "[Selected chat excerpts could be added here]\n"
  )
  
  # Create output directory if needed
  if (!dir.exists("output")) {
    dir.create("output")
  }
  
  # Save template
  writeLines(template, "output/analysis_template.Rmd")
}

# Helper to capitalize (if not defined)
if (!exists("capitalize")) {
  capitalize <- function(x) {
    paste0(toupper(substr(x, 1, 1)), substr(x, 2, nchar(x)))
  }
}