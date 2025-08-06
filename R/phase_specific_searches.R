# Phase-Specific Literature Search Implementations
# Tailored search strategies for each phase of the scientific method

# Phase 1: Hypothesis Formulation Literature Searches
generate_hypothesis_searches <- function(user_input, hypothesis_type, outcome_var, treatment_var, predictor_vars) {
  
  searches <- c()
  
  # Base search for the relationship
  if (hypothesis_type == "causal" && !is.null(treatment_var) && !is.null(outcome_var)) {
    searches <- c(searches,
      paste(treatment_var, outcome_var, "causal effect systematic review"),
      paste(treatment_var, outcome_var, "randomized controlled trial meta-analysis"),
      paste(treatment_var, "confounders", outcome_var, "observational study")
    )
  } else if (hypothesis_type == "associational" && length(predictor_vars) > 0) {
    searches <- c(searches,
      paste(predictor_vars[1], outcome_var, "association correlation studies"),
      paste(outcome_var, "predictors", "systematic review meta-analysis"),
      paste(predictor_vars[1], "relationship", outcome_var, "longitudinal study")
    )
  }
  
  # Add input-specific searches
  input_lower <- tolower(user_input)
  
  if (grepl("mechanism|pathway|mediation", input_lower)) {
    searches <- c(searches, paste(outcome_var, "mechanism pathway mediation analysis"))
  }
  
  if (grepl("moderator|interaction", input_lower)) {
    searches <- c(searches, paste(outcome_var, "moderator interaction effect"))
  }
  
  # Generic theoretical framework search
  searches <- c(searches, paste(outcome_var, "theoretical framework conceptual model"))
  
  return(head(unique(searches), 3))
}

# Phase 2: Analytic Planning Literature Searches  
generate_planning_searches <- function(user_input, statistical_test, outcome_var, effect_size_target = NULL) {
  
  searches <- c()
  input_lower <- tolower(user_input)
  
  # Power analysis and effect size searches
  if (grepl("power|sample size|effect size", input_lower)) {
    searches <- c(searches,
      paste(outcome_var, "effect size meta-analysis systematic review"),
      paste(statistical_test, "power analysis sample size calculation"),
      paste(outcome_var, "minimal clinically important difference")
    )
  }
  
  # Statistical method searches
  if (grepl("test|method|analysis", input_lower)) {
    searches <- c(searches,
      paste(statistical_test, "assumptions violations robustness"),
      paste(outcome_var, "statistical analysis best practices"),
      paste(statistical_test, "alternatives comparison methodology")
    )
  }
  
  # Sensitivity analysis planning
  if (grepl("sensitivity|robust|assumption", input_lower)) {
    searches <- c(searches,
      paste(outcome_var, "sensitivity analysis methods"),
      paste(statistical_test, "assumption checking validation"),
      "sensitivity analysis reporting guidelines best practices"
    )
  }
  
  # Default planning searches
  if (length(searches) == 0) {
    searches <- c(
      paste(outcome_var, "analysis methods comparison systematic review"),
      paste(statistical_test, "application guidelines methodology"),
      paste(outcome_var, "study design analysis plan")
    )
  }
  
  return(head(unique(searches), 3))
}

# Phase 3: Implementation Literature Searches
generate_implementation_searches <- function(user_input, statistical_method, data_characteristics = NULL) {
  
  searches <- c()
  input_lower <- tolower(user_input)
  
  # Code and implementation searches
  if (grepl("code|implementation|software", input_lower)) {
    searches <- c(searches,
      paste(statistical_method, "R implementation best practices"),
      paste(statistical_method, "software comparison validation"),
      "statistical analysis reproducibility code practices"
    )
  }
  
  # Error and diagnostic searches
  if (grepl("error|diagnostic|assumption", input_lower)) {
    searches <- c(searches,
      paste(statistical_method, "diagnostic plots interpretation"),
      paste(statistical_method, "assumption violations detection"),
      paste(statistical_method, "troubleshooting common errors")
    )
  }
  
  # Results interpretation searches
  if (grepl("result|interpret|output", input_lower)) {
    searches <- c(searches,
      paste(statistical_method, "results interpretation guidelines"),
      paste(statistical_method, "output explanation examples"),
      paste(statistical_method, "reporting standards guidelines")
    )
  }
  
  # Default implementation searches
  if (length(searches) == 0) {
    searches <- c(
      paste(statistical_method, "implementation best practices guidelines"),
      paste(statistical_method, "quality control validation methods"),
      "statistical analysis implementation reproducibility"
    )
  }
  
  return(head(unique(searches), 3))
}

# Phase 4: Analysis and Interpretation Literature Searches
generate_analysis_searches <- function(user_input, results_summary = NULL, effect_size = NULL) {
  
  searches <- c()
  input_lower <- tolower(user_input)
  
  # Interpretation searches
  if (grepl("interpret|meaning|significance", input_lower)) {
    searches <- c(searches,
      "statistical significance clinical significance difference",
      "effect size interpretation practical importance",
      "research findings interpretation guidelines systematic review"
    )
  }
  
  # Clinical/practical significance
  if (grepl("clinical|practical|meaningful", input_lower)) {
    searches <- c(searches,
      "clinical significance effect size benchmarks",
      "practical significance statistical significance difference",
      "meaningful effect size thresholds meta-analysis"
    )
  }
  
  # Limitations and future directions
  if (grepl("limitation|weakness|future", input_lower)) {
    searches <- c(searches,
      "research limitations discussion best practices",
      "study limitations systematic review methodology",
      "future research directions recommendations"
    )
  }
  
  # Alternative explanations
  if (grepl("alternative|explain|confound", input_lower)) {
    searches <- c(searches,
      "alternative explanations confounding systematic review",
      "residual confounding unmeasured variables",
      "causal inference alternative explanations"
    )
  }
  
  # Default analysis searches
  if (length(searches) == 0) {
    searches <- c(
      "research findings interpretation best practices",
      "statistical results clinical implications",
      "effect size interpretation guidelines"
    )
  }
  
  return(head(unique(searches), 3))
}

# Master function to generate phase-appropriate searches
generate_phase_specific_searches <- function(phase, user_input, values) {
  
  searches <- switch(phase,
    "hypothesis" = {
      if (!is.null(values$hypothesis)) {
        generate_hypothesis_searches(
          user_input, 
          values$hypothesis$type,
          values$hypothesis$outcome_var,
          values$hypothesis$treatment_var,
          values$hypothesis$predictor_vars
        )
      } else {
        c("hypothesis formulation methodology systematic review",
          "research question development best practices",
          "study design hypothesis testing")
      }
    },
    
    "planning" = {
      statistical_test <- values$plan$statistical_test %||% "statistical analysis"
      outcome_var <- values$hypothesis$outcome_var %||% "outcome variable"
      
      generate_planning_searches(user_input, statistical_test, outcome_var)
    },
    
    "implementation" = {
      statistical_method <- values$plan$method %||% "statistical analysis"
      generate_implementation_searches(user_input, statistical_method)
    },
    
    "analysis" = {
      effect_size <- values$results$effect_size %||% NULL
      generate_analysis_searches(user_input, values$results, effect_size)
    },
    
    # Default fallback
    c("systematic review meta-analysis", 
      "research methodology best practices",
      "evidence-based research guidelines")
  )
  
  return(searches)
}

# Function to customize search queries based on domain/field
customize_searches_by_domain <- function(searches, domain = NULL) {
  
  if (is.null(domain)) {
    return(searches)
  }
  
  # Add domain-specific terms
  domain_terms <- switch(tolower(domain),
    "psychology" = "psychological",
    "medicine" = "medical clinical",
    "education" = "educational",
    "economics" = "economic econometric",
    "sociology" = "sociological social",
    ""  # Default: no additional terms
  )
  
  if (nchar(domain_terms) > 0) {
    searches <- paste(searches, domain_terms)
  }
  
  return(searches)
}

# Quality filter for search queries
apply_quality_filters <- function(searches) {
  
  # Add quality indicators to searches
  quality_terms <- c(
    "peer-reviewed",
    "systematic review",
    "meta-analysis", 
    "randomized controlled trial",
    "longitudinal study"
  )
  
  # Randomly add quality terms to searches (to avoid all being identical)
  enhanced_searches <- sapply(searches, function(search) {
    if (runif(1) > 0.5) {  # 50% chance of adding quality filter
      quality_term <- sample(quality_terms, 1)
      if (!grepl(quality_term, search, ignore.case = TRUE)) {
        search <- paste(search, quality_term)
      }
    }
    return(search)
  })
  
  return(as.character(enhanced_searches))
}