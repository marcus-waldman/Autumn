# Phase 2: Analytic Planning Logic
# This file contains server logic for Phase 2 of the Scientific Methods Engine

# Display confirmed hypothesis
output$confirmed_hypothesis_display <- renderText({
  req(values$hypothesis_confirmed)
  paste0(
    "Statement: ", values$hypothesis$statement, "\n",
    "Type: ", capitalize(values$hypothesis$type), "\n",
    "Outcome: ", values$hypothesis$outcome_var, "\n",
    if (values$hypothesis$type == "causal") {
      paste0("Treatment: ", values$hypothesis$treatment_var)
    } else {
      paste0("Predictors: ", paste(values$hypothesis$predictor_vars, collapse = ", "))
    }
  )
})

# Sample size information
output$sample_size_info <- renderText({
  req(values$data, values$hypothesis)
  
  # Calculate effective sample size
  if (values$hypothesis$type == "causal" && !is.null(values$hypothesis$treatment_var)) {
    treatment_table <- table(values$data[[values$hypothesis$treatment_var]])
    paste0(
      "Total sample size: ", nrow(values$data), "\n",
      "Group sizes: ", paste(names(treatment_table), "=", treatment_table, collapse = ", ")
    )
  } else {
    paste0("Total sample size: ", nrow(values$data))
  }
})

# MDE calculation
output$mde_calculation <- renderText({
  req(input$alpha_level, input$desired_power, values$data, values$hypothesis)
  
  # Calculate MDE based on test type
  if (input$statistical_test == "t_test" && values$hypothesis$type == "causal") {
    # Two-sample t-test MDE
    treatment_table <- table(values$data[[values$hypothesis$treatment_var]])
    if (length(treatment_table) == 2) {
      n1 <- treatment_table[1]
      n2 <- treatment_table[2]
      
      # Use pwr package formula for MDE
      # MDE = (t_alpha + t_beta) * sqrt(1/n1 + 1/n2) * sigma
      # Assuming sigma = 1 for standardized effect size
      
      z_alpha <- qnorm(1 - input$alpha_level/2)
      z_beta <- qnorm(input$desired_power)
      mde <- (z_alpha + z_beta) * sqrt(1/n1 + 1/n2)
      
      paste0(
        "Minimum Detectable Effect Size (Cohen's d): ", round(mde, 3), "\n",
        "Interpretation: ",
        if (mde < 0.2) "Very small" 
        else if (mde < 0.5) "Small"
        else if (mde < 0.8) "Medium"
        else "Large",
        " effect size"
      )
    }
  } else if (input$statistical_test == "lm") {
    # Linear regression MDE
    n <- nrow(values$data)
    k <- length(c(values$hypothesis$predictor_vars, values$hypothesis$covariate_vars))
    
    # Cohen's f2 for multiple regression
    z_alpha <- qnorm(1 - input$alpha_level/2)
    z_beta <- qnorm(input$desired_power)
    f2 <- ((z_alpha + z_beta)^2 * (k + 1)) / (n - k - 1)
    
    paste0(
      "Minimum Detectable Effect Size (Cohen's f²): ", round(f2, 3), "\n",
      "Interpretation: ",
      if (f2 < 0.02) "Very small"
      else if (f2 < 0.15) "Small"
      else if (f2 < 0.35) "Medium"
      else "Large",
      " effect size"
    )
  } else {
    "MDE calculation pending for selected test type"
  }
})

# Literature benchmarks handling
observeEvent(input$add_benchmark, {
  showModal(modalDialog(
    title = "Add Literature Benchmark",
    textInput("bench_study", "Study Citation:"),
    numericInput("bench_effect", "Effect Size:", value = 0),
    numericInput("bench_ci_lower", "CI Lower:", value = 0),
    numericInput("bench_ci_upper", "CI Upper:", value = 0),
    numericInput("bench_n", "Sample Size:", value = 100),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("save_benchmark", "Save")
    )
  ))
})

observeEvent(input$save_benchmark, {
  req(input$bench_study)
  
  new_row <- data.frame(
    Study = input$bench_study,
    Effect_Size = input$bench_effect,
    CI_Lower = input$bench_ci_lower,
    CI_Upper = input$bench_ci_upper,
    Sample_Size = input$bench_n
  )
  
  values$benchmarks <- rbind(values$benchmarks, new_row)
  removeModal()
})

output$benchmark_table <- renderDT({
  datatable(values$benchmarks, 
            options = list(pageLength = 5, dom = 't'),
            rownames = FALSE)
})

# Analytic plan preview
output$analytic_plan_preview <- renderText({
  req(input$statistical_test, values$hypothesis)
  
  plan_text <- paste0(
    "ANALYTIC PLAN\n",
    "=============\n\n",
    "1. Hypothesis: ", values$hypothesis$statement, "\n\n",
    "2. Statistical Test: ", 
    switch(input$statistical_test,
           "t_test" = "Independent samples t-test",
           "anova" = "One-way ANOVA",
           "lm" = "Linear regression",
           "glm" = "Logistic regression",
           "chisq" = "Chi-square test"), "\n\n",
    "3. Significance Level: α = ", input$alpha_level, "\n\n",
    "4. Power Analysis:\n",
    "   - Desired Power: ", input$desired_power, "\n",
    "   - Sample Size: ", values$hypothesis$data_summary$n_obs, "\n\n"
  )
  
  if (values$hypothesis$type == "causal") {
    plan_text <- paste0(
      plan_text,
      "5. Causal Framework:\n",
      "   - Treatment: ", values$hypothesis$treatment_var, "\n",
      "   - Covariates: ", paste(values$hypothesis$covariate_vars, collapse = ", "), "\n",
      "   - Assumptions: Ignorability, SUTVA, positivity\n\n"
    )
  }
  
  plan_text <- paste0(
    plan_text,
    "6. Robustness Checks:\n",
    "   - Assumption diagnostics\n",
    "   - Sensitivity analyses\n",
    "   - Alternative specifications\n"
  )
  
  plan_text
})

# Confirm plan button
observeEvent(input$confirm_plan, {
  req(input$statistical_test)
  
  # Create the analytic plan object
  values$plan <- list(
    test = input$statistical_test,
    alpha = input$alpha_level,
    power = input$desired_power,
    benchmarks = values$benchmarks,
    mde = isolate(output$mde_calculation()),
    template_created = TRUE
  )
  
  # Generate R Markdown template
  generate_rmd_template(values$hypothesis, values$plan)
  
  values$plan_confirmed <- TRUE
  
  showNotification("Analytic plan approved! R Markdown template generated.", 
                   type = "success", 
                   duration = 5)
  
  updateTabItems(session, "phases", "implementation")
})

# Helper function to generate R Markdown template
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
      paste0("- **Treatment Variable**: ", hypothesis$treatment_var, "\n")
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
    "# Discussion\n\n",
    "[To be populated]\n\n",
    "# Limitations\n\n",
    "[To be populated]\n\n",
    "# Conclusions\n\n",
    "[To be populated]\n\n",
    "# References\n\n",
    "[To be added]\n"
  )
  
  # Save template to output directory
  writeLines(template, "output/analysis_template.Rmd")
}

# Helper function to capitalize
capitalize <- function(x) {
  paste0(toupper(substr(x, 1, 1)), substr(x, 2, nchar(x)))
}