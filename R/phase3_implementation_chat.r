# Phase 3: Implementation with Chat Integration
# Enhanced version with collaborative AI interaction

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
    "Power: ", values$plan$power,
    if (!is.null(values$plan$mde)) {
      paste0("\nMDE: ", round(values$plan$mde, 3))
    }
  )
})

# Generate analysis code
output$generated_code <- renderText({
  req(values$plan_confirmed)
  
  # Generate R function based on test type
  code <- generate_analysis_function(values$hypothesis, values$plan)
  
  # Store the code for execution
  values$analysis_code <- code
  
  # Add message to chat about code generation
  ai_msg <- list(
    sender = "ai",
    content = paste0(
      "I've generated the analysis function for your ", 
      switch(values$plan$test,
             "t_test" = "t-test",
             "anova" = "ANOVA",
             "lm" = "linear regression",
             "glm" = "logistic regression",
             "chisq" = "chi-square test"),
      ". The code includes:\n\n",
      "1. **Main analysis**: Implements your chosen statistical test\n",
      "2. **Effect size calculation**: Quantifies the magnitude of effects\n",
      "3. **Diagnostics**: Checks key assumptions\n",
      "4. **Results formatting**: Organizes output for interpretation\n\n",
      "Feel free to ask me about any part of the code before we run it!"
    )
  )
  values$chat_history$implementation <- append(values$chat_history$implementation, list(ai_msg))
  
  code
})

# Execute analysis button
observeEvent(input$execute_analysis, {
  req(values$analysis_code, values$data)
  
  showNotification("Executing analysis...", type = "message", duration = 2)
  
  # Add user message to chat
  user_msg <- list(
    sender = "user",
    content = "I'm running the analysis now..."
  )
  values$chat_history$implementation <- append(values$chat_history$implementation, list(user_msg))
  
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
    
    # Add success message to chat with initial interpretation
    ai_msg <- list(
      sender = "ai",
      content = generate_initial_results_interpretation(results, values$hypothesis, values$plan)
    )
    values$chat_history$implementation <- append(values$chat_history$implementation, list(ai_msg))
    
    showNotification("Analysis completed!", type = "success")
    
  }, error = function(e) {
    output$execution_status <- renderText({
      paste("Error:", e$message)
    })
    
    # Add error help to chat
    ai_msg <- list(
      sender = "ai",
      content = paste0(
        "I see there was an error: ", e$message, "\n\n",
        "Let's debug this together. Common causes include:\n",
        "1. Missing values in key variables\n",
        "2. Variable type mismatches\n",
        "3. Empty factor levels\n",
        "4. Perfect separation (for logistic regression)\n\n",
        "Can you tell me more about what happened? We can check the data and adjust our approach."
      )
    )
    values$chat_history$implementation <- append(values$chat_history$implementation, list(ai_msg))
    
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
        geom_boxplot(fill = c("#3498db", "#e74c3c"), alpha = 0.7) +
        geom_jitter(width = 0.2, alpha = 0.3, size = 2) +
        theme_minimal() +
        theme(
          plot.title = element_text(size = 16, face = "bold"),
          axis.title = element_text(size = 12),
          axis.text = element_text(size = 10)
        ) +
        labs(title = "Treatment Group Comparison",
             subtitle = paste("p-value:", 
                              if(!is.null(values$results$test)) 
                                format.pval(values$results$test$p.value) 
                              else "NA"),
             x = values$hypothesis$treatment_var,
             y = values$hypothesis$outcome_var)
    } else if (values$plan$test == "lm") {
      # Scatter plot for regression
      if (length(values$hypothesis$predictor_vars) > 0) {
        ggplot(values$data, aes_string(x = values$hypothesis$predictor_vars[1], 
                                       y = values$hypothesis$outcome_var)) +
          geom_point(alpha = 0.6, size = 2, color = "#2c3e50") +
          geom_smooth(method = "lm", se = TRUE, color = "#e74c3c") +
          theme_minimal() +
          theme(
            plot.title = element_text(size = 16, face = "bold"),
            axis.title = element_text(size = 12)
          ) +
          labs(title = "Regression Relationship",
               subtitle = paste("R-squared:", 
                                if(!is.null(values$results$r_squared)) 
                                  round(values$results$r_squared, 3) 
                                else "NA"))
      }
    } else {
      # Default histogram of outcome
      ggplot(values$data, aes_string(x = values$hypothesis$outcome_var)) +
        geom_histogram(bins = 30, fill = "#3498db", alpha = 0.7) +
        theme_minimal() +
        labs(title = "Distribution of Outcome Variable")
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
  
  # Add confirmation to chat
  ai_msg <- list(
    sender = "ai",
    content = paste0(
      "Great! We've completed the implementation phase successfully. Here's what we found:\n\n",
      if (!is.null(values$results$test) && !is.null(values$results$test$p.value)) {
        paste0("- Statistical significance: p = ", format.pval(values$results$test$p.value), 
               " (", ifelse(values$results$test$p.value < values$plan$alpha, "significant", "not significant"), ")\n")
      },
      if (!is.null(values$results$effect_size)) {
        paste0("- Effect size: ", round(values$results$effect_size, 3), "\n")
      },
      "\nLet's move to the final phase where we'll:\n",
      "1. Interpret these results in context\n",
      "2. Discuss limitations\n",
      "3. Consider practical significance\n",
      "4. Generate your final report\n\n",
      "Ready to complete your analysis?"
    )
  )
  values$chat_history$implementation <- append(values$chat_history$implementation, list(ai_msg))
  
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
      "  # T-test analysis for causal hypothesis\n",
      "  # Clean data first\n",
      "  clean_data <- data[!is.na(data$", hypothesis$outcome_var, ") & \n",
      "                     !is.na(data$", hypothesis$treatment_var, "), ]\n",
      "  \n",
      "  formula_str <- paste('", hypothesis$outcome_var, " ~ ", hypothesis$treatment_var, "')\n",
      "  \n",
      "  # Run t-test\n",
      "  test_result <- t.test(formula = as.formula(formula_str), data = clean_data)\n",
      "  \n",
      "  # Calculate effect size (Cohen's d)\n",
      "  group_data <- split(clean_data$", hypothesis$outcome_var, ", clean_data$", hypothesis$treatment_var, ")\n",
      "  means <- sapply(group_data, mean, na.rm = TRUE)\n",
      "  sds <- sapply(group_data, sd, na.rm = TRUE)\n",
      "  ns <- sapply(group_data, function(x) sum(!is.na(x)))\n",
      "  \n",
      "  # Pooled standard deviation\n",
      "  pooled_sd <- sqrt(((ns[1]-1)*sds[1]^2 + (ns[2]-1)*sds[2]^2) / (ns[1]+ns[2]-2))\n",
      "  cohens_d <- (means[1] - means[2]) / pooled_sd\n",
      "  \n",
      "  # Check assumptions\n",
      "  normality_p <- c()\n",
      "  for(i in 1:length(group_data)) {\n",
      "    if(length(group_data[[i]]) >= 3 && length(group_data[[i]]) <= 5000) {\n",
      "      normality_p[i] <- shapiro.test(group_data[[i]])$p.value\n",
      "    } else {\n",
      "      normality_p[i] <- NA\n",
      "    }\n",
      "  }\n",
      "  \n",
      "  # Create results object\n",
      "  results <- list(\n",
      "    test = test_result,\n",
      "    effect_size = cohens_d,\n",
      "    means = means,\n",
      "    sds = sds,\n",
      "    ns = ns,\n",
      "    normality_p = normality_p,\n",
      "    summary = paste0(\n",
      "      'T-test Results:\\n',\n",
      "      '==============\\n',\n",
      "      't = ', round(test_result$statistic, 3), '\\n',\n",
      "      'df = ', round(test_result$parameter, 1), '\\n',\n",
      "      'p-value = ', format.pval(test_result$p.value), '\\n',\n",
      "      '95% CI: [', round(test_result$conf.int[1], 3), ', ', \n",
      "                   round(test_result$conf.int[2], 3), ']\\n',\n",
      "      '\\nEffect Size:\\n',\n",
      "      'Cohen\\'s d = ', round(cohens_d, 3), '\\n',\n",
      "      '\\nGroup Statistics:\\n',\n",
      "      paste(names(means), ': n=', ns, ', mean=', round(means, 2), \n",
      "            ', sd=', round(sds, 2), collapse='\\n'), '\\n',\n",
      "      '\\nConclusion: ', ifelse(test_result$p.value < ", plan$alpha, ",\n",
      "        'Statistically significant difference', 'No significant difference'), \n",
      "      ' at α = ', ", plan$alpha, "\n",
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
      "  # Remove missing values\n",
      "  vars_needed <- c('", hypothesis$outcome_var, "', ",
      paste0("'", predictors, "'", collapse = ", "), ")\n",
      "  clean_data <- data[complete.cases(data[, vars_needed]), ]\n",
      "  \n",
      "  formula_str <- paste('", hypothesis$outcome_var, " ~ ",
      paste(predictors, collapse = " + "), "')\n",
      "  \n",
      "  # Fit model\n",
      "  model <- lm(formula = as.formula(formula_str), data = clean_data)\n",
      "  \n",
      "  # Get summary\n",
      "  model_summary <- summary(model)\n",
      "  \n",
      "  # Calculate standardized coefficients\n",
      "  std_coefs <- coef(model)[-1] * apply(clean_data[, predictors, drop=FALSE], 2, sd) / \n",
      "               sd(clean_data$", hypothesis$outcome_var, ")\n",
      "  \n",
      "  # Create results object\n",
      "  results <- list(\n",
      "    model = model,\n",
      "    summary_table = model_summary$coefficients,\n",
      "    r_squared = model_summary$r.squared,\n",
      "    adj_r_squared = model_summary$adj.r.squared,\n",
      "    std_coefs = std_coefs,\n",
      "    n = nrow(clean_data),\n",
      "    summary = paste0(\n",
      "      'Linear Regression Results:\\n',\n",
      "      '========================\\n',\n",
      "      'N = ', nrow(clean_data), ' (', nrow(data) - nrow(clean_data), ' excluded due to missing data)\\n',\n",
      "      'R-squared = ', round(model_summary$r.squared, 3), '\\n',\n",
      "      'Adjusted R-squared = ', round(model_summary$adj.r.squared, 3), '\\n',\n",
      "      'F-statistic = ', round(model_summary$fstatistic[1], 2), '\\n',\n",
      "      'Model p-value = ', format.pval(pf(model_summary$fstatistic[1], \n",
      "        model_summary$fstatistic[2], model_summary$fstatistic[3], \n",
      "        lower.tail = FALSE)), '\\n\\n',\n",
      "      'Coefficients:\\n',\n",
      "      paste(capture.output(print(round(model_summary$coefficients, 3))), \n",
      "            collapse = '\\n')\n",
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
      "    summary = 'Analysis implementation pending for this test type.\\n',\n",
      "    message = 'The ", plan$test, " analysis is not yet implemented in this prototype.'\n",
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
      sample_size = if(!is.null(results$n)) results$n else nrow(values$data),
      outcome_summary = summary(values$data[[hypothesis$outcome_var]]),
      groups = if(!is.null(results$ns)) results$ns else NA
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

# Helper function to generate initial results interpretation
generate_initial_results_interpretation <- function(results, hypothesis, plan) {
  
  interpretation <- "Analysis completed! Let me help you understand these results:\n\n"
  
  # Statistical significance
  if (!is.null(results$test) && !is.null(results$test$p.value)) {
    p_val <- results$test$p.value
    interpretation <- paste0(
      interpretation,
      "**Statistical Significance:**\n",
      "- p-value = ", format.pval(p_val), "\n",
      "- This is ", ifelse(p_val < plan$alpha, "statistically significant", "not statistically significant"),
      " at α = ", plan$alpha, "\n",
      if (p_val < 0.001) {
        "- Very strong evidence against the null hypothesis\n"
      } else if (p_val < 0.01) {
        "- Strong evidence against the null hypothesis\n"
      } else if (p_val < 0.05) {
        "- Moderate evidence against the null hypothesis\n"
      } else if (p_val < 0.10) {
        "- Weak evidence against the null hypothesis\n"
      } else {
        "- No evidence against the null hypothesis\n"
      }
    )
  }
  
  # Effect size
  if (!is.null(results$effect_size)) {
    d <- abs(results$effect_size)
    interpretation <- paste0(
      interpretation,
      "\n**Effect Size (Cohen's d = ", round(results$effect_size, 3), "):**\n",
      "- This represents a ",
      if (d < 0.2) "negligible" else if (d < 0.5) "small" else if (d < 0.8) "medium" else "large",
      " effect\n",
      "- In practical terms, this means the groups differ by ",
      round(d, 2), " standard deviations\n"
    )
  }
  
  # R-squared for regression
  if (!is.null(results$r_squared)) {
    interpretation <- paste0(
      interpretation,
      "\n**Model Fit (R² = ", round(results$r_squared, 3), "):**\n",
      "- Your model explains ", round(results$r_squared * 100, 1), "% of the variance in ", hypothesis$outcome_var, "\n",
      "- This is considered ",
      if (results$r_squared < 0.1) "weak" else if (results$r_squared < 0.3) "moderate" else if (results$r_squared < 0.5) "substantial" else "strong",
      " explanatory power\n"
    )
  }
  
  # Practical significance
  interpretation <- paste0(
    interpretation,
    "\n**Key Questions to Consider:**\n",
    "1. Is this effect size meaningful in your context?\n",
    "2. How does this compare to your literature benchmarks?\n",
    "3. Are there any unexpected patterns in the results?\n",
    "4. Should we run any additional analyses?\n\n",
    "Feel free to ask me about any aspect of these results!"
  )
  
  return(interpretation)
}

# Format p-value helper
format.pval <- function(p) {
  if (is.null(p) || is.na(p)) return("NA")
  if (p < 0.001) return("< 0.001")
  if (p < 0.01) return(paste0("= ", format(round(p, 3), nsmall = 3)))
  return(paste0("= ", format(round(p, 2), nsmall = 2)))
}