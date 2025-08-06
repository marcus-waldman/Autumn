# Enhanced Chat Functions with Literature Integration
# Orchestrates Anthropic + Perplexity API calls for evidence-based responses

source("R/perplexity_integration.R")

# Main enhanced chat function that orchestrates API calls
enhanced_chat <- function(user_input, phase, values) {
  
  # Step 1: Initial Anthropic response with literature needs identification
  initial_prompt <- paste0(
    "Phase: ", phase, "\n",
    "User input: ", user_input, "\n\n",
    "Context:\n", get_context_summary(phase, values), "\n\n",
    
    "TASK 1: First, identify what literature searches would help provide ",
    "evidence-based feedback on this input. List 2-3 specific searches that would strengthen your response. ",
    "Format each search as a clear, specific query that would find relevant studies.\n\n",
    
    "Examples of good search queries:\n",
    "- '[intervention] effect size meta-analysis'\n",
    "- '[outcome variable] [predictor] relationship studies'\n", 
    "- '[statistical method] assumptions violations'\n",
    "- '[population] [intervention] randomized trials'\n\n",
    
    "Provide only the search queries, one per line, without additional explanation."
  )
  
  # Generate search needs with fallback
  search_queries <- tryCatch({
    initial_response <- call_anthropic_api(initial_prompt)
    extract_search_queries(initial_response)
  }, error = function(e) {
    # Fallback to general searches based on phase and input
    generate_fallback_searches(phase, user_input)
  })
  
  # Step 2: Execute literature searches in parallel if possible
  literature_results <- lapply(search_queries, function(query) {
    result <- cached_literature_search(query)
    Sys.sleep(0.5)  # Small delay to avoid rate limiting
    return(result)
  })
  
  # Step 3: Generate final Anthropic response incorporating evidence
  evidence_summary <- format_literature(literature_results)
  
  final_prompt <- paste0(
    "You are a skeptical scientific collaborator providing evidence-based feedback.\n\n",
    
    "USER INPUT:\n", user_input, "\n\n",
    
    "CURRENT CONTEXT (", phase, "):\n", get_context_summary(phase, values), "\n\n",
    
    "LITERATURE EVIDENCE:\n", evidence_summary, "\n\n",
    
    "INSTRUCTIONS:\n",
    "Based on the literature evidence above, provide feedback that:\n",
    "1. Challenges assumptions with specific citations\n",
    "2. Suggests alternatives based on published research\n",
    "3. Provides specific effect sizes or findings from studies\n",
    "4. Identifies gaps in current knowledge\n",
    "5. Never accepts claims without empirical support\n\n",
    
    "Format your response to include:\n",
    "- Direct quotes or specific findings from studies (with citations)\n",
    "- Specific effect sizes or statistical findings\n",
    "- Methodological considerations from similar research\n",
    "- Evidence-based suggestions for improvement\n\n",
    
    "Be constructively skeptical and ground all feedback in the evidence provided."
  )
  
  # Generate evidence-based response
  final_response <- tryCatch({
    call_anthropic_api(final_prompt)
  }, error = function(e) {
    # Fallback to original response system
    generate_ai_response(phase, user_input, values)
  })
  
  # Store literature results in values for UI display
  values$literature_results[[phase]] <- literature_results
  
  # Package the response with metadata
  return(list(
    response = final_response,
    literature_searches = search_queries,
    literature_results = literature_results,
    evidence_used = !all(sapply(literature_results, function(x) x$fallback %||% FALSE)),
    timestamp = Sys.time()
  ))
}

# Helper function to call Anthropic API
call_anthropic_api <- function(prompt, model = "claude-3-sonnet-20240229") {
  
  api_key <- Sys.getenv("ANTHROPIC_API_KEY")
  if (nchar(api_key) == 0) {
    stop("Anthropic API key not found")
  }
  
  url <- "https://api.anthropic.com/v1/messages"
  
  body <- list(
    model = model,
    max_tokens = 1000,
    messages = list(
      list(
        role = "user",
        content = prompt
      )
    )
  )
  
  response <- POST(
    url,
    add_headers(
      "x-api-key" = api_key,
      "Content-Type" = "application/json",
      "anthropic-version" = "2023-06-01"
    ),
    body = toJSON(body, auto_unbox = TRUE),
    timeout(30)
  )
  
  if (status_code(response) == 200) {
    content <- fromJSON(content(response, "text"))
    return(content$content[[1]]$text)
  } else {
    stop(paste("Anthropic API call failed:", status_code(response)))
  }
}

# Get context summary for the current phase
get_context_summary <- function(phase, values) {
  
  context_parts <- c()
  
  # Data context
  if (!is.null(values$data)) {
    context_parts <- c(context_parts, 
      paste0("Data: ", nrow(values$data), " observations, ", 
             ncol(values$data), " variables")
    )
  }
  
  # Phase-specific context
  if (phase == "hypothesis") {
    if (!is.null(values$hypothesis)) {
      context_parts <- c(context_parts,
        paste0("Hypothesis type: ", values$hypothesis$type),
        paste0("Outcome variable: ", values$hypothesis$outcome_var)
      )
    }
  }
  
  if (phase == "planning") {
    if (!is.null(values$hypothesis)) {
      context_parts <- c(context_parts,
        paste0("Confirmed hypothesis: ", values$hypothesis$statement),
        paste0("Statistical test being considered: ", values$plan$statistical_test %||% "Not selected")
      )
    }
  }
  
  if (phase == "implementation") {
    if (!is.null(values$plan)) {
      context_parts <- c(context_parts,
        "Analytic plan has been approved",
        paste0("Analysis approach: ", values$plan$method %||% "Standard analysis")
      )
    }
  }
  
  if (phase == "analysis") {
    if (!is.null(values$results)) {
      context_parts <- c(context_parts,
        "Analysis has been completed",
        "Results are available for interpretation"
      )
    }
  }
  
  if (length(context_parts) == 0) {
    return("No specific context available.")
  }
  
  return(paste(context_parts, collapse = "\n"))
}

# Generate fallback searches when initial API call fails
generate_fallback_searches <- function(phase, user_input) {
  
  input_lower <- tolower(user_input)
  
  # Phase-specific searches
  phase_searches <- switch(phase,
    "hypothesis" = c(
      "hypothesis formulation methodology systematic review",
      "research question development best practices",
      "causal inference study design"
    ),
    "planning" = c(
      "power analysis effect size estimation",
      "statistical test selection guidelines",
      "sample size calculation methods"
    ),
    "implementation" = c(
      "statistical analysis implementation best practices",
      "assumption checking methods validation",
      "data analysis reproducibility"
    ),
    "analysis" = c(
      "result interpretation statistical significance",
      "effect size clinical significance",
      "research limitations discussion"
    )
  )
  
  # Add input-specific searches
  if (grepl("power|sample size", input_lower)) {
    phase_searches <- c(phase_searches, "power analysis sample size meta-analysis")
  }
  
  if (grepl("effect size", input_lower)) {
    phase_searches <- c(phase_searches, "effect size interpretation Cohen systematic review")
  }
  
  if (grepl("causal|cause", input_lower)) {
    phase_searches <- c(phase_searches, "causal inference methods randomized controlled trials")
  }
  
  # Return up to 3 searches
  return(head(phase_searches, 3))
}

# Enhanced response wrapper that includes literature context
generate_enhanced_response <- function(phase, user_input, values, use_literature = TRUE) {
  
  if (use_literature) {
    # Use the enhanced chat with literature integration
    enhanced_result <- enhanced_chat(user_input, phase, values)
    
    # Store literature results in values for UI display
    values$last_literature_searches <- enhanced_result$literature_results
    
    return(enhanced_result$response)
    
  } else {
    # Fallback to original response system
    return(generate_ai_response(phase, user_input, values))
  }
}

# Check if literature integration is enabled
literature_integration_enabled <- function() {
  # Check if both API keys are available
  anthropic_key <- nchar(Sys.getenv("ANTHROPIC_API_KEY")) > 0
  perplexity_key <- nchar(Sys.getenv("PERPLEXITY_API_KEY")) > 0
  
  return(anthropic_key && perplexity_key)
}

# Function to update the AI response system to use literature
integrate_literature_in_chat <- function(values) {
  
  # Override the existing generate_ai_response function to include literature
  original_function <- generate_ai_response
  
  generate_ai_response <<- function(phase, user_input, values) {
    
    if (literature_integration_enabled()) {
      return(generate_enhanced_response(phase, user_input, values, use_literature = TRUE))
    } else {
      return(original_function(phase, user_input, values))
    }
  }
  
  return(TRUE)
}