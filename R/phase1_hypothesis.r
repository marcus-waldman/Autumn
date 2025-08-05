# Phase 1: Hypothesis Formulation Logic
# This file contains server logic for Phase 1 of the Scientific Methods Engine

# File upload handler
observeEvent(input$data_file, {
  req(input$data_file)
  
  tryCatch({
    # Read RDS file
    data <- readRDS(input$data_file$datapath)
    
    # Validate that it's a data frame or tibble
    if (!is.data.frame(data) && !inherits(data, "tbl_df")) {
      showNotification("Error: File must contain a data frame or tibble", type = "error")
      return()
    }
    
    values$data <- data
    showNotification("Data uploaded successfully!", type = "success")
    
  }, error = function(e) {
    showNotification(paste("Error reading file:", e$message), type = "error")
  })
})

# Data summary display
output$data_summary <- renderPrint({
  req(values$data)
  
  cat("Data Summary:\n")
  cat(paste("Rows:", nrow(values$data), "\n"))
  cat(paste("Columns:", ncol(values$data), "\n\n"))
  cat("Variable types:\n")
  print(sapply(values$data, class))
  cat("\n")
  cat("Missing values:\n")
  print(colSums(is.na(values$data)))
})

# Variable selection UI
output$variable_selection <- renderUI({
  req(values$data)
  
  vars <- names(values$data)
  
  tagList(
    selectInput("outcome_var", 
                "Select outcome variable:",
                choices = vars,
                selected = NULL),
    
    conditionalPanel(
      condition = "input.hypothesis_type == 'associational'",
      selectInput("predictor_vars", 
                  "Select predictor variable(s):",
                  choices = vars,
                  selected = NULL,
                  multiple = TRUE)
    ),
    
    conditionalPanel(
      condition = "input.hypothesis_type == 'causal'",
      selectInput("treatment_var", 
                  "Select treatment variable:",
                  choices = vars,
                  selected = NULL),
      selectInput("covariate_vars", 
                  "Select covariates for adjustment:",
                  choices = vars,
                  selected = NULL,
                  multiple = TRUE)
    )
  )
})

# Data validation
output$data_validation <- renderUI({
  req(values$data, input$outcome_var)
  
  validation_results <- list()
  
  # Check outcome variable
  outcome_data <- values$data[[input$outcome_var]]
  validation_results$outcome_type <- class(outcome_data)[1]
  validation_results$outcome_missing <- sum(is.na(outcome_data))
  validation_results$outcome_unique <- length(unique(na.omit(outcome_data)))
  
  # Check predictors/treatment
  if (input$hypothesis_type == "associational" && !is.null(input$predictor_vars)) {
    validation_results$predictor_info <- lapply(input$predictor_vars, function(var) {
      list(
        name = var,
        type = class(values$data[[var]])[1],
        missing = sum(is.na(values$data[[var]])),
        unique = length(unique(na.omit(values$data[[var]])))
      )
    })
  } else if (input$hypothesis_type == "causal" && !is.null(input$treatment_var)) {
    treatment_data <- values$data[[input$treatment_var]]
    validation_results$treatment_type <- class(treatment_data)[1]
    validation_results$treatment_missing <- sum(is.na(treatment_data))
    validation_results$treatment_levels <- length(unique(na.omit(treatment_data)))
  }
  
  # Generate validation report
  tags$div(
    class = "alert alert-info",
    h5("Validation Results:"),
    tags$ul(
      tags$li(paste("Outcome variable:", input$outcome_var, 
                    "- Type:", validation_results$outcome_type,
                    "- Missing:", validation_results$outcome_missing)),
      if (input$hypothesis_type == "causal" && !is.null(input$treatment_var)) {
        tags$li(paste("Treatment variable:", input$treatment_var,
                      "- Type:", validation_results$treatment_type,
                      "- Levels:", validation_results$treatment_levels))
      }
    ),
    if (validation_results$outcome_missing > nrow(values$data) * 0.2) {
      tags$p(class = "text-warning", 
             "Warning: Outcome variable has >20% missing values")
    }
  )
})

# Confirm hypothesis button handler
observeEvent(input$confirm_hypothesis, {
  req(input$hypothesis_input, input$outcome_var)
  
  # Validate required fields
  if (input$hypothesis_type == "associational" && length(input$predictor_vars) == 0) {
    showNotification("Please select at least one predictor variable", type = "error")
    return()
  }
  
  if (input$hypothesis_type == "causal" && is.null(input$treatment_var)) {
    showNotification("Please select a treatment variable", type = "error")
    return()
  }
  
  # Store hypothesis information
  values$hypothesis <- list(
    statement = input$hypothesis_input,
    type = input$hypothesis_type,
    outcome_var = input$outcome_var,
    predictor_vars = input$predictor_vars,
    treatment_var = input$treatment_var,
    covariate_vars = input$covariate_vars,
    causal_mechanism = input$causal_mechanism,
    confounders = input$confounders,
    data_summary = list(
      n_obs = nrow(values$data),
      n_vars = ncol(values$data),
      outcome_type = class(values$data[[input$outcome_var]])[1]
    )
  )
  
  # Confirm hypothesis
  values$hypothesis_confirmed <- TRUE
  
  # Show confirmation and navigate to next phase
  showNotification("Hypothesis confirmed! Proceeding to analytic planning.", 
                   type = "success", 
                   duration = 5)
  
  updateTabItems(session, "phases", "planning")
})

# Helper function to validate hypothesis testability
validate_hypothesis_testability <- function(hypothesis, data) {
  issues <- list()
  
  # Check sample size
  if (nrow(data) < 30) {
    issues <- append(issues, "Sample size is very small (n < 30)")
  }
  
  # Check outcome variable
  outcome_data <- data[[hypothesis$outcome_var]]
  if (sum(!is.na(outcome_data)) < 20) {
    issues <- append(issues, "Too few non-missing outcome observations")
  }
  
  # Check treatment/predictor variables
  if (hypothesis$type == "causal") {
    treatment_data <- data[[hypothesis$treatment_var]]
    treatment_table <- table(treatment_data)
    if (any(treatment_table < 10)) {
      issues <- append(issues, "Some treatment groups have < 10 observations")
    }
  }
  
  return(issues)
}