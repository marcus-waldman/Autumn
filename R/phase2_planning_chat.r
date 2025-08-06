# Phase 2: Analytic Planning with Chat Integration
# Enhanced version with collaborative AI interaction

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
  
  mde_text <- ""
  
  # Calculate MDE based on test type
  if (input$statistical_test == "t_test" && values$hypothesis$type == "causal") {
    treatment_table <- table(values$data[[values$hypothesis$treatment_var]])
    if (length(treatment_table) == 2) {
      n1 <- treatment_table[1]
      n2 <- treatment_table[2]
      
      z_alpha <- qnorm(1 - input$alpha_level/2)
      z_beta <- qnorm(input$desired_power)
      mde <- (z_alpha + z_beta) * sqrt(1/n1 + 1/n2)
      
      mde_text <- paste0(
        "Minimum Detectable Effect Size (Cohen's d): ", round(mde, 3), "\n",
        "Interpretation: ",
        if (mde < 0.2) "Very small" 
        else if (mde < 0.5) "Small"
        else if (mde < 0.8) "Medium"
        else "Large",
        " effect size"
      )
      
      # Store MDE for later use
      values$current_mde <- mde
    }
  } else if (input$statistical_test == "lm") {
    n <- nrow(values$data)
    k <- length(c(values$hypothesis$predictor_vars, values$hypothesis$covariate_vars))
    
    z_alpha <- qnorm(1 - input$alpha_level/2)
    z_beta <- qnorm(input$desired_power)
    f2 <- ((z_alpha + z_beta)^2 * (k + 1)) / (n - k - 1)
    
    mde_text <- paste0(
      "Minimum Detectable Effect Size (Cohen's f²): ", round(f2, 3), "\n",
      "Interpretation: ",
      if (f2 < 0.02) "Very small"
      else if (f2 < 0.15) "Small"
      else if (f2 < 0.35) "Medium"
      else "Large",
      " effect size"
    )
    
    values$current_mde <- f2
  } else {
    mde_text <- "MDE calculation pending for selected test type"
  }
  
  mde_text
})

# Discuss plan button - initiates planning discussion
observeEvent(input$discuss_plan, {
  req(input$statistical_test)
  
  # Add user message about planning
  user_msg <- list(
    sender = "user",
    content = paste0(
      "I'd like to discuss my analytic plan. I'm considering:\n",
      "- Statistical test: ", input$statistical_test, "\n",
      "- Alpha level: ", input$alpha_level, "\n",
      "- Desired power: ", input$desired_power, "\n",
      "Is this appropriate for my hypothesis?"
    )
  )
  values$chat_history$planning <- append(values$chat_history$planning, list(user_msg))
  
  # Generate AI response about the plan
  ai_response_content <- generate_planning_critique(
    values$hypothesis,
    input$statistical_test,
    input$alpha_level,
    input$desired_power,
    values$current_mde,
    values$data
  )
  
  ai_msg <- list(
    sender = "ai",
    content = ai_response_content
  )
  values$chat_history$planning <- append(values$chat_history$planning, list(ai_msg))
})

# Literature benchmarks modal
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
  
  # Add to chat
  ai_msg <- list(
    sender = "ai",
    content = paste0(
      "Good! You've added a benchmark from the literature:\n",
      "- Study: ", input$bench_study, "\n",
      "- Effect size: ", input$bench_effect, " [", input$bench_ci_lower, ", ", input$bench_ci_upper, "]\n",
      "- Sample size: ", input$bench_n, "\n\n",
      "This helps contextualize what effect sizes are realistic in your field. ",
      if (!is.null(values$current_mde)) {
        paste0("Your MDE of ", round(values$current_mde, 3), 
               " means you can detect effects ",
               ifelse(values$current_mde <= input$bench_effect, "similar to", "larger than"),
               " this benchmark study.")
      }
    )
  )
  values$chat_history$planning <- append(values$chat_history$planning, list(ai_msg))
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
    "   - Sample Size: ", values$hypothesis$data_summary$n_obs, "\n",
    if (!is.null(values$current_mde)) {
      paste0("   - MDE: ", round(values$current_mde, 3), "\n")
    },
    "\n"
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
  
  # Add benchmarks if available
  if (nrow(values$benchmarks) > 0) {
    plan_text <- paste0(
      plan_text,
      "6. Literature Benchmarks:\n"
    )
    for (i in 1:nrow(values$benchmarks)) {
      plan_text <- paste0(
        plan_text,
        "   - ", values$benchmarks$Study[i], ": ES = ", values$benchmarks$Effect_Size[i], "\n"
      )
    }
    plan_text <- paste0(plan_text, "\n")
  }
  
  plan_text <- paste0(
    plan_text,
    "7. Robustness Checks:\n",
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
    mde = values$current_mde,
    template_created = TRUE
  )
  
  # Generate R Markdown template
  generate_rmd_template(values$hypothesis, values$plan)
  
  values$plan_confirmed <- TRUE
  
  # Add confirmation to chat
  ai_msg <- list(
    sender = "ai",
    content = paste0(
      "Excellent! Your analytic plan has been approved and I've generated an R Markdown template for your analysis.\n\n",
      "Key decisions locked in:\n",
      "- Statistical test: ", switch(input$statistical_test,
                                     "t_test" = "Independent samples t-test",
                                     "anova" = "One-way ANOVA",
                                     "lm" = "Linear regression",
                                     "glm" = "Logistic regression",
                                     "chisq" = "Chi-square test"), "\n",
      "- Alpha level: ", input$alpha_level, "\n",
      "- Power: ", input$desired_power, "\n",
      if (!is.null(values$current_mde)) {
        paste0("- MDE: ", round(values$current_mde, 3), "\n")
      },
      "\nLet's proceed to Phase 3 where I'll generate the analysis code and we can implement your plan!"
    )
  )
  values$chat_history$planning <- append(values$chat_history$planning, list(ai_msg))
  
  showNotification("Analytic plan approved! R Markdown template generated.", 
                   type = "success", 
                   duration = 5)
  
  updateTabItems(session, "phases", "implementation")
})

# Helper function to generate planning critique
generate_planning_critique <- function(hypothesis, test, alpha, power, mde, data) {
  
  critique_parts <- c()
  
  # Test appropriateness
  outcome_type <- class(data[[hypothesis$outcome_var]])[1]
  
  if (test == "t_test") {
    if (!outcome_type %in% c("numeric", "integer", "double")) {
      critique_parts <- c(critique_parts, 
        "⚠️ T-test requires a continuous outcome, but your outcome appears to be ", outcome_type
      )
    }
    if (hypothesis$type == "causal") {
      n_groups <- length(unique(data[[hypothesis$treatment_var]]))
      if (n_groups != 2) {
        critique_parts <- c(critique_parts,
          paste0("⚠️ T-test is for 2 groups, but you have ", n_groups, " groups. Consider ANOVA instead.")
        )
      }
    }
  }
  
  # Power considerations
  if (!is.null(mde)) {
    if (mde > 0.8) {
      critique_parts <- c(critique_parts,
        paste0("Your MDE of ", round(mde, 3), " indicates you can only detect large effects. ",
               "Many meaningful effects might go undetected.")
      )
    } else if (mde < 0.2) {
      critique_parts <- c(critique_parts,
        paste0("Great! Your MDE of ", round(mde, 3), " means you can detect even small effects.")
      )
    }
  }
  
  # Alpha level
  if (alpha != 0.05) {
    critique_parts <- c(critique_parts,
      paste0("You've chosen α = ", alpha, " instead of the conventional 0.05. ",
             if (alpha < 0.05) "This reduces Type I error risk but decreases power." 
             else "This increases power but raises Type I error risk.")
    )
  }
  
  # Build comprehensive response
  response <- paste0(
    "Let's review your analytic plan:\n\n",
    if (length(critique_parts) > 0) {
      paste0("**Important considerations:**\n", paste(critique_parts, collapse = "\n"), "\n\n")
    },
    "**Statistical test assessment:**\n",
    "Your choice of ", switch(test,
                              "t_test" = "t-test",
                              "anova" = "ANOVA",
                              "lm" = "linear regression",
                              "glm" = "logistic regression",
                              "chisq" = "chi-square test"),
    " seems ", 
    ifelse(length(critique_parts) == 0, "appropriate", "worth reconsidering"),
    " for your hypothesis.\n\n",
    "**Power analysis interpretation:**\n",
    "- With ", power * 100, "% power, you have a ", power * 100, "% chance of detecting true effects\n",
    "- This means a ", (1 - power) * 100, "% false negative rate (Type II error)\n",
    if (!is.null(mde)) {
      paste0("- You can reliably detect effects of size ", round(mde, 3), " or larger\n")
    },
    "\n**Recommendations:**\n",
    "1. Consider what effect size would be practically meaningful in your context\n",
    "2. Plan sensitivity analyses to test robustness of findings\n",
    "3. Pre-specify any subgroup analyses to avoid p-hacking\n",
    if (hypothesis$type == "causal") {
      "4. Document your causal assumptions clearly\n"
    },
    "\nWould you like to adjust any parameters or shall we proceed with this plan?"
  )
  
  return(response)
}

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
    if (!is.null(plan$mde)) {
      paste0("Minimum detectable effect size: ", round(plan$mde, 3), "\n")
    } else {
      "[MDE results to be added]\n"
    },
    "\n",
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
    if (nrow(plan$benchmarks) > 0) {
      paste(apply(plan$benchmarks, 1, function(row) {
        paste0("- ", row["Study"])
      }), collapse = "\n")
    } else {
      "[To be added]\n"
    }
  )
  
  # Create output directory if it doesn't exist
  if (!dir.exists("output")) {
    dir.create("output")
  }
  
  # Save template
  writeLines(template, "output/analysis_template.Rmd")
}

# Helper function to capitalize
capitalize <- function(x) {
  paste0(toupper(substr(x, 1, 1)), substr(x, 2, nchar(x)))
}