# Phase 1: Hypothesis Formulation with Chat Integration
# Enhanced version with collaborative AI interaction

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
    
    # Add automated message to chat
    ai_msg <- list(
      sender = "ai", 
      content = paste0(
        "Great! I've received your data file. Let me take a look...\n\n",
        "I can see you have ", nrow(data), " observations and ", ncol(data), " variables. ",
        "The variables in your dataset are: ", paste(names(data)[1:min(10, length(names(data)))], collapse = ", "),
        ifelse(length(names(data)) > 10, ", and more", ""), ".\n\n",
        "Now, let's work together to formulate a clear, testable hypothesis. ",
        "What research question are you hoping to answer with this data?"
      )
    )
    values$chat_history$hypothesis <- append(values$chat_history$hypothesis, list(ai_msg))
    
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
  cat("First few variable names:\n")
  cat(paste(head(names(values$data), 10), collapse = ", "))
  if (length(names(values$data)) > 10) cat(", ...")
  cat("\n")
})

# Variable selection UI
output$variable_selection <- renderUI({
  req(values$data)
  
  vars <- names(values$data)
  
  tagList(
    h4("Step 3: Select Variables"),
    selectInput("outcome_var", 
                "Select outcome variable:",
                choices = c("", vars),
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
                  "Select treatment/exposure variable:",
                  choices = c("", vars),
                  selected = NULL),
      selectInput("covariate_vars", 
                  "Select covariates for adjustment (optional):",
                  choices = vars,
                  selected = NULL,
                  multiple = TRUE)
    )
  )
})

# Draft hypothesis button - initiates collaborative discussion
observeEvent(input$draft_hypothesis, {
  req(input$hypothesis_input, input$outcome_var)
  
  # Validate basic requirements
  if (input$hypothesis_type == "associational" && length(input$predictor_vars) == 0) {
    showNotification("Please select at least one predictor variable", type = "error")
    return()
  }
  
  if (input$hypothesis_type == "causal" && (is.null(input$treatment_var) || input$treatment_var == "")) {
    showNotification("Please select a treatment variable", type = "error")
    return()
  }
  
  # Create initial hypothesis summary
  hypothesis_summary <- paste0(
    "Hypothesis: ", input$hypothesis_input, "\n",
    "Type: ", input$hypothesis_type, "\n",
    "Outcome: ", input$outcome_var, "\n",
    if (input$hypothesis_type == "causal") {
      paste0("Treatment: ", input$treatment_var)
    } else {
      paste0("Predictors: ", paste(input$predictor_vars, collapse = ", "))
    }
  )
  
  # Add user's draft to chat
  user_msg <- list(
    sender = "user",
    content = paste0(
      "I'd like to discuss this hypothesis:\n\n",
      hypothesis_summary
    )
  )
  values$chat_history$hypothesis <- append(values$chat_history$hypothesis, list(user_msg))
  
  # Generate AI response with critique and suggestions
  ai_response_content <- generate_hypothesis_critique(
    input$hypothesis_input,
    input$hypothesis_type,
    input$outcome_var,
    input$treatment_var,
    input$predictor_vars,
    input$causal_mechanism,
    values$data
  )
  
  ai_msg <- list(
    sender = "ai",
    content = ai_response_content
  )
  values$chat_history$hypothesis <- append(values$chat_history$hypothesis, list(ai_msg))
  
  # Update the refined hypothesis area
  values$refined_hypothesis <- input$hypothesis_input
})

# Display refined hypothesis
output$refined_hypothesis <- renderText({
  if (values$refined_hypothesis == "") {
    "Your refined hypothesis will appear here after discussion with Anthropic."
  } else {
    values$refined_hypothesis
  }
})

# Confirm hypothesis button handler
observeEvent(input$confirm_hypothesis, {
  req(values$refined_hypothesis != "")
  
  # Store hypothesis information
  values$hypothesis <- list(
    statement = values$refined_hypothesis,
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
  
  # Add confirmation to chat
  ai_msg <- list(
    sender = "ai",
    content = paste0(
      "Excellent! Your hypothesis has been confirmed and locked in:\n\n",
      "\"", values$refined_hypothesis, "\"\n\n",
      "This is a ", input$hypothesis_type, " hypothesis with:\n",
      "- Outcome: ", input$outcome_var, "\n",
      if (input$hypothesis_type == "causal") {
        paste0("- Treatment: ", input$treatment_var)
      } else {
        paste0("- Predictors: ", paste(input$predictor_vars, collapse = ", "))
      },
      "\n\nLet's proceed to Phase 2 where we'll develop your analytic plan and conduct power analysis."
    )
  )
  values$chat_history$hypothesis <- append(values$chat_history$hypothesis, list(ai_msg))
  
  # Show confirmation and navigate to next phase
  showNotification("Hypothesis confirmed! Proceeding to analytic planning.", 
                   type = "success", 
                   duration = 5)
  
  updateTabItems(session, "phases", "planning")
})

# Helper function to generate hypothesis critique
generate_hypothesis_critique <- function(hypothesis, type, outcome, treatment, predictors, mechanism, data) {
  
  critique_parts <- c()
  suggestions <- c()
  
  # Analyze hypothesis specificity
  if (nchar(hypothesis) < 50) {
    critique_parts <- c(critique_parts, 
      "Your hypothesis is quite brief. Let's work on making it more specific."
    )
  }
  
  # Check for directional language
  if (!grepl("increase|decrease|reduce|improve|associate|relate|predict", hypothesis, ignore.case = TRUE)) {
    suggestions <- c(suggestions,
      "- Specify the expected direction of the relationship"
    )
  }
  
  # Check for quantification
  if (!grepl("significant|percent|times|fold|points", hypothesis, ignore.case = TRUE)) {
    suggestions <- c(suggestions,
      "- Consider adding expected magnitude (if known from literature)"
    )
  }
  
  # Type-specific critiques
  if (type == "causal") {
    # Check treatment variable
    if (!is.null(treatment) && treatment != "") {
      treat_data <- data[[treatment]]
      n_groups <- length(unique(na.omit(treat_data)))
      
      if (n_groups != 2) {
        critique_parts <- c(critique_parts,
          paste0("I notice your treatment variable has ", n_groups, " groups. ",
                 "For clearest causal interpretation, consider focusing on a specific comparison.")
        )
      }
      
      # Check for balance
      if (n_groups == 2) {
        treat_table <- table(treat_data)
        balance_ratio <- min(treat_table) / max(treat_table)
        if (balance_ratio < 0.4) {
          critique_parts <- c(critique_parts,
            "The treatment groups appear imbalanced, which might affect power."
          )
        }
      }
    }
    
    # Causal mechanism check
    if (is.null(mechanism) || nchar(mechanism) < 10) {
      suggestions <- c(suggestions,
        "- Articulate the causal mechanism more clearly"
      )
    }
    
    critique_parts <- c(critique_parts,
      "\nFor causal claims, we need to carefully consider:",
      "1. **Exchangeability**: Are treatment groups comparable?",
      "2. **Positivity**: Do we have treated and untreated units across covariate levels?",
      "3. **SUTVA**: No interference between units, consistent treatment versions?"
    )
    
  } else {
    # Associational hypothesis
    if (length(predictors) > 5) {
      critique_parts <- c(critique_parts,
        paste0("You've selected ", length(predictors), " predictors. ",
               "Consider focusing on key variables to avoid overfitting.")
      )
    }
  }
  
  # Sample size consideration
  n <- nrow(data)
  outcome_missing <- sum(is.na(data[[outcome]]))
  effective_n <- n - outcome_missing
  
  if (effective_n < 30) {
    critique_parts <- c(critique_parts,
      paste0("\n⚠️ Your effective sample size is ", effective_n, " after excluding missing outcomes. ",
             "This is quite small and will limit detectable effect sizes.")
    )
  }
  
  # Build response
  response <- paste0(
    "Thank you for sharing your hypothesis. Let me provide some constructive feedback:\n\n",
    paste(critique_parts, collapse = "\n"),
    if (length(suggestions) > 0) {
      paste0("\n\nTo strengthen your hypothesis, consider:\n", paste(suggestions, collapse = "\n"))
    },
    "\n\n**Suggested refinement:**\n",
    "\"",
    if (type == "causal") {
      paste0("Among [your population], ", treatment, " will ",
             "[increase/decrease] ", outcome, " by [expected amount] ",
             "compared to [control group], after adjusting for [key confounders].")
    } else {
      paste0("In [your population], ", paste(predictors[1:min(3, length(predictors))], collapse = " and "),
             " will be [positively/negatively] associated with ", outcome,
             ", explaining approximately [X]% of the variance.")
    },
    "\"\n\n",
    "How would you like to refine your hypothesis based on this feedback?"
  )
  
  return(response)
}

# Monitor for hypothesis updates in chat
observe({
  # Check recent chat messages for hypothesis refinements
  recent_messages <- tail(values$chat_history$hypothesis, 5)
  
  for (msg in recent_messages) {
    if (msg$sender == "user") {
      refined <- check_hypothesis_refinement(msg$content, "", values)
      if (!is.null(refined) && nchar(refined) > 20) {
        values$refined_hypothesis <- refined
      }
    }
  }
})

# Add scroll functionality
tags$script(HTML("
  Shiny.addCustomMessageHandler('scrollChat', function(message) {
    var element = document.getElementById(message.id);
    if (element) {
      element.scrollTop = element.scrollHeight;
    }
  });
"))