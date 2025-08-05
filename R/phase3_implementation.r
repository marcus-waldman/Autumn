# Phase 3: Implementation Logic
# This file contains server logic for Phase 3 of the Scientific Methods Engine

# Display approved plan
output$approved_plan_display <- renderText({
  req(values$plan_confirmed)
  
  paste0(
    "Statistical Test: ", 
    switch(values$plan$test,
           "t_test" = "Independent samples t-test",
           "anova" = "One-way ANOVA",
           "lm" = "Linear regression",
           "glm" = "Logistic regression",
           "chisq" = "Chi-square test"), "\n",
    "Alpha: ", values$plan$alpha, "\n",
    "Power: ", values$plan$power
  )
})

# Generate analysis code
output$generated_code <- renderText({
  req(values$plan_confirmed)
  
  # Generate R function based on test type
  code <- generate_analysis_function(values$hypothesis, values$plan)
  
  # Store the code for execution
  values$analysis_code <- code
  
  code
})

# Execute analysis button
observeEvent(input$execute_analysis, {
  req(values$analysis_code, values$data)
  
  showNotification("Executing analysis...", type = "message", duration = 2)
  
  tryCatch({
    # Parse and execute the analysis function
    eval(parse(text = values$analysis_code))
    
    # Run the analysis
    results <- analyze_data(values$data)
    
    # Store results
    values$results <- results
    
    # Convert results to JSON format for sharing
    values$results_json <- create_results_json(results, values$hypothesis, values$plan)
    
    output$execution_status <- renderText({
      "Analysis completed successfully!"
    })
    
    showNotification("Analysis completed!", type = "success")
    
  }, error = function(e) {
    output$execution_status <- renderText({
      paste("Error:", e$message)
    })
    showNotification(paste("Analysis error:", e$message), type = "error")
  })
})

# Results plot
output$results_plot <- renderPlot({
  req(values$results)
  
  if (!is.null(values$results$plot)) {
    values$results$plot
  } else {
    # Generate a default plot based on test type
    if (values$plan$test == "t_test" && values$hypothesis$type == "causal") {
      # Box plot for t-test
      ggplot(values$data, aes_string(x = values$hypothesis$treatment_var, 
                                     y = values$hypothesis$outcome_var)) +
        geom_boxplot(fill = c("#3498db", "#e74c3c")) +
        geom_jitter(width = 0.2, alpha = 0.5) +
        theme_minimal() +
        labs(title = "Treatment Group Comparison",
             x = values$hypothesis$treatment_var,
             y = values$hypothesis$outcome_var)
    } else if (values$plan$test == "lm") {
      # Scatter plot for regression
      if (length(values$hypothesis$predictor_vars) > 0) {
        ggplot(values$data, aes_string(x = values$hypothesis$predictor_vars[1], 
                                       y = values$hypothesis$outcome_var)) +
          geom_point(alpha = 0.6) +
          geom_smooth(method = "lm", se = TRUE) +
          theme_minimal() +
          labs(title = "Regression Relationship")
      }
    }
  }
})

# Results summary
output$results_summary <- renderText({
  req(values$results)
  
  if (!is.null(values$results$summary)) {
    values$results$summary
  } else {
    "Results summary will appear here after analysis execution."
  }
})

# Confirm results button
observeEvent(input$confirm_results, {
  req(values$results)
  
  values$results_confirmed <- TRUE
  
  showNotification("Results confirmed! Generating final report...", 
                   type = "success", 
                   duration = 5)
  
  updateTabItems(session, "phases", "analysis")
})

# Helper function to generate analysis function
generate_analysis_function <- function(hypothesis, plan) {
  
  if (plan$test == "t_test" && hypothesis$type == "causal") {
    code <- paste0(
      "analyze_data <- function(data) {\n",
      "  # T-test analysis\n",
      "  formula_str <- paste('", hypothesis$outcome_var, " ~ ", hypothesis$treatment_var, "')\n",
      "  \n",
      "  # Run t-test\n",
      "  test_result <- t.test(formula = as.formula(formula_str), data = data)\n",
      "  \n",
      "  # Calculate effect size (Cohen's d)\n",
      "  group_data <- split(data$", hypothesis$outcome_var, ", data$", hypothesis$treatment_var, ")\n",
      "  means <- sapply(group_data, mean, na.rm = TRUE)\n",
      "  sds <- sapply(group_data, sd, na.rm = TRUE)\n",
      "  ns <- sapply(group_data, function(x) sum(!is.na(x)))\n",
      "  \n",
      "  pooled_sd <- sqrt(((ns[1]-1)*sds[1]^2 + (ns[2]-1)*sds[2]^2) / (ns[1]+ns[2]-2))\n",
      "  cohens_d <- (means[1] - means[2]) / pooled_sd\n",
      "  \n",
      "  # Create results object\n",
      "  results <- list(\n",
      "    test = test_result,\n",
      "    effect_size = cohens_d,\n",
      "    means = means,\n",
      "    summary = paste0(\n",
      "      'T-test Results:\\n',\n",
      "      't = ', round(test_result$statistic, 3), '\\n',\n",
      "      'df = ', round(test_result$parameter, 1), '\\n',\n",
      "      'p-value = ', format.pval(test_result$p.value), '\\n',\n",
      "      'Cohen\\'s d = ', round(cohens_d, 3), '\\n',\n",
      "      'Conclusion: ', ifelse(test_result$p.value < ", plan$alpha, ",\n",
      "        'Reject null hypothesis', 'Fail to reject null hypothesis')\n",
      "    )\n",
      "  )\n",
      "  \n",
      "  return(results)\n",
      "}\n"
    )
    
  } else if (plan$test == "lm") {
    predictors <- if (hypothesis$type == "causal") {
      c(hypothesis$treatment_var, hypothesis$covariate_vars)
    } else {
      hypothesis$predictor_vars
    }
    
    code <- paste0(
      "analyze_data <- function(data) {\n",
      "  # Linear regression analysis\n",
      "  formula_str <- paste('", hypothesis$outcome_var, " ~ ",
      paste(predictors, collapse = " + "), "')\n",
      "  \n",
      "  # Fit model\n",
      "  model <- lm(formula = as.formula(formula_str), data = data)\n",
      "  \n",
      "  # Get summary\n",
      "  model_summary <- summary(model)\n",
      "  \n",
      "  # Create results object\n",
      "  results <- list(\n",
      "    model = model,\n",
      "    summary_table = model_summary$coefficients,\n",
      "    r_squared = model_summary$r.squared,\n",
      "    summary = paste0(\n",
      "      'Linear Regression Results:\\n',\n",
      "      'R-squared = ', round(model_summary$r.squared, 3), '\\n',\n",
      "      'Adjusted R-squared = ', round(model_summary$adj.r.squared, 3), '\\n',\n",
      "      'F-statistic = ', round(model_summary$fstatistic[1], 2), '\\n',\n",
      "      'p-value = ', format.pval(pf(model_summary$fstatistic[1], \n",
      "        model_summary$fstatistic[2], model_summary$fstatistic[3], \n",
      "        lower.tail = FALSE)), '\\n'\n",
      "    )\n",
      "  )\n",
      "  \n",
      "  return(results)\n",
      "}\n"
    )
    
  } else {
    # Default template for other tests
    code <- paste0(
      "analyze_data <- function(data) {\n",
      "  # Analysis for ", plan$test, "\n",
      "  # [Implementation needed]\n",
      "  \n",
      "  results <- list(\n",
      "    summary = 'Analysis implementation pending for this test type'\n",
      "  )\n",
      "  \n",
      "  return(results)\n",
      "}\n"
    )
  }
  
  return(code)
}

# Helper function to create JSON results
create_results_json <- function(results, hypothesis, plan) {
  json_data <- list(
    descriptive_stats = list(
      sample_size = nrow(values$data),
      outcome_summary = summary(values$data[[hypothesis$outcome_var]])
    ),
    inferential_results = list(
      test_name = plan$test,
      test_statistics = if (!is.null(results$test)) {
        list(
          statistic = results$test$statistic,
          p_value = results$test$p.value,
          confidence_interval = results$test$conf.int
        )
      } else if (!is.null(results$model)) {
        list(
          coefficients = coef(results$model),
          p_values = summary(results$model)$coefficients[, "Pr(>|t|)"],
          r_squared = summary(results$model)$r.squared
        )
      },
      effect_sizes = if (!is.null(results$effect_size)) results$effect_size else NA
    )
  )
  
  return(toJSON(json_data, pretty = TRUE))
}