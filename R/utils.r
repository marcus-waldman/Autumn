# Utility Functions for Scientific Methods Engine

# Function to validate data structure
validate_data <- function(data, hypothesis) {
  validation <- list(
    valid = TRUE,
    issues = character()
  )
  
  # Check if required variables exist
  required_vars <- c(hypothesis$outcome_var)
  if (hypothesis$type == "causal") {
    required_vars <- c(required_vars, hypothesis$treatment_var)
  } else {
    required_vars <- c(required_vars, hypothesis$predictor_vars)
  }
  
  missing_vars <- setdiff(required_vars, names(data))
  if (length(missing_vars) > 0) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, 
                          paste("Missing variables:", paste(missing_vars, collapse = ", ")))
  }
  
  # Check sample size
  if (nrow(data) < 20) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Sample size too small (n < 20)")
  }
  
  # Check for complete separation in categorical predictors
  if (hypothesis$type == "causal" && !is.null(hypothesis$treatment_var)) {
    if (is.factor(data[[hypothesis$treatment_var]]) || is.character(data[[hypothesis$treatment_var]])) {
      treatment_table <- table(data[[hypothesis$treatment_var]])
      if (any(treatment_table == 0)) {
        validation$valid <- FALSE
        validation$issues <- c(validation$issues, "Some treatment groups have no observations")
      }
    }
  }
  
  return(validation)
}

# Function to perform basic power analysis
calculate_power <- function(n, effect_size, alpha = 0.05, test_type = "t_test") {
  
  if (test_type == "t_test") {
    # Two-sample t-test power calculation
    # Using simplified formula for equal groups
    n_per_group <- n / 2
    
    # Non-centrality parameter
    ncp <- effect_size * sqrt(n_per_group / 2)
    
    # Critical value
    crit <- qt(1 - alpha/2, df = n - 2)
    
    # Power
    power <- 1 - pt(crit, df = n - 2, ncp = ncp) + pt(-crit, df = n - 2, ncp = ncp)
    
  } else if (test_type == "correlation") {
    # Correlation test power
    # Fisher's z transformation
    z <- 0.5 * log((1 + effect_size) / (1 - effect_size))
    se <- 1 / sqrt(n - 3)
    
    # Critical value
    crit <- qnorm(1 - alpha/2)
    
    # Power
    power <- pnorm(abs(z) / se - crit)
    
  } else {
    # Default to 0.80 for other tests
    power <- 0.80
  }
  
  return(power)
}

# Function to calculate minimum detectable effect size
calculate_mde <- function(n, power = 0.80, alpha = 0.05, test_type = "t_test") {
  
  if (test_type == "t_test") {
    # Two-sample t-test MDE (Cohen's d)
    n_per_group <- n / 2
    
    # Z-scores for alpha and beta
    z_alpha <- qnorm(1 - alpha/2)
    z_beta <- qnorm(power)
    
    # MDE formula
    mde <- (z_alpha + z_beta) * sqrt(2 / n_per_group)
    
  } else if (test_type == "correlation") {
    # Correlation MDE
    z_alpha <- qnorm(1 - alpha/2)
    z_beta <- qnorm(power)
    
    # Fisher's z for MDE
    z_mde <- (z_alpha + z_beta) / sqrt(n - 3)
    
    # Convert back to correlation
    mde <- (exp(2 * z_mde) - 1) / (exp(2 * z_mde) + 1)
    
  } else {
    # Default MDE
    mde <- 0.5
  }
  
  return(mde)
}

# Function to generate DAG visualization for causal hypotheses
create_dag <- function(hypothesis) {
  if (!hypothesis$type == "causal") {
    return(NULL)
  }
  
  # Simple text-based DAG representation
  dag_text <- paste0(
    "Causal DAG:\n",
    "\n",
    "  Confounders\n",
    "      |\n",
    "      v\n",
    hypothesis$treatment_var, " --> ", hypothesis$outcome_var, "\n"
  )
  
  if (!is.null(hypothesis$confounders) && nchar(hypothesis$confounders) > 0) {
    confounders <- trimws(strsplit(hypothesis$confounders, ",")[[1]])
    dag_text <- paste0(dag_text, "\n",
                      "Identified confounders: ", paste(confounders, collapse = ", "))
  }
  
  return(dag_text)
}

# Function to format p-values
format_pval <- function(p) {
  if (p < 0.001) {
    return("< 0.001")
  } else if (p < 0.01) {
    return(paste0("= ", format(round(p, 3), nsmall = 3)))
  } else {
    return(paste0("= ", format(round(p, 2), nsmall = 2)))
  }
}

# Function to calculate effect size confidence intervals
effect_size_ci <- function(effect_size, n, conf_level = 0.95) {
  # Standard error for Cohen's d
  se <- sqrt((2/n) + (effect_size^2 / (2*n)))
  
  # Critical value
  z_crit <- qnorm((1 + conf_level) / 2)
  
  # Confidence interval
  ci_lower <- effect_size - z_crit * se
  ci_upper <- effect_size + z_crit * se
  
  return(c(lower = ci_lower, upper = ci_upper))
}

# Function to perform assumption checks
check_assumptions <- function(model, test_type) {
  assumptions <- list()
  
  if (test_type %in% c("t_test", "anova")) {
    # Normality check
    residuals <- if (inherits(model, "lm")) residuals(model) else model$residuals
    shapiro_test <- shapiro.test(residuals[1:min(5000, length(residuals))])
    
    assumptions$normality <- list(
      test = "Shapiro-Wilk",
      p_value = shapiro_test$p.value,
      met = shapiro_test$p.value > 0.05
    )
    
    # Homogeneity of variance
    # (Would need to implement Levene's test here)
    assumptions$homogeneity <- list(
      test = "Levene's test",
      p_value = NA,
      met = NA
    )
  }
  
  if (test_type == "lm") {
    # Linearity, normality, homoscedasticity
    assumptions$residual_plots <- "See diagnostic plots"
    assumptions$vif <- "Check for multicollinearity"
  }
  
  return(assumptions)
}

# Function to create a simple progress bar
create_progress_bar <- function(current_phase, total_phases = 4) {
  progress <- (current_phase / total_phases) * 100
  
  bar_html <- paste0(
    '<div class="progress" style="height: 20px;">',
    '<div class="progress-bar" role="progressbar" style="width: ', progress, '%;" ',
    'aria-valuenow="', progress, '" aria-valuemin="0" aria-valuemax="100">',
    round(progress), '%',
    '</div>',
    '</div>'
  )
  
  return(HTML(bar_html))
}

# Function to validate statistical test selection
recommend_statistical_test <- function(hypothesis, data) {
  outcome_type <- class(data[[hypothesis$outcome_var]])[1]
  
  recommendations <- list()
  
  if (hypothesis$type == "causal") {
    treatment_type <- class(data[[hypothesis$treatment_var]])[1]
    treatment_levels <- length(unique(data[[hypothesis$treatment_var]]))
    
    if (outcome_type %in% c("numeric", "integer", "double")) {
      if (treatment_levels == 2) {
        recommendations$primary <- "t_test"
        recommendations$alternative <- "wilcox"  # Mann-Whitney U
      } else if (treatment_levels > 2) {
        recommendations$primary <- "anova"
        recommendations$alternative <- "kruskal"  # Kruskal-Wallis
      }
    } else if (outcome_type %in% c("factor", "character")) {
      recommendations$primary <- "chisq"
      recommendations$alternative <- "fisher"  # Fisher's exact
    }
  } else {
    # Associational hypothesis
    if (outcome_type %in% c("numeric", "integer", "double")) {
      recommendations$primary <- "lm"
      recommendations$alternative <- "gam"  # Generalized additive model
    } else if (outcome_type %in% c("factor", "character") || 
               outcome_type == "logical") {
      recommendations$primary <- "glm"
      recommendations$alternative <- "randomForest"
    }
  }
  
  return(recommendations)
}

# Function to generate example data for testing
generate_example_data <- function(n = 200, hypothesis_type = "causal") {
  set.seed(123)
  
  if (hypothesis_type == "causal") {
    # Generate data for causal hypothesis
    data <- data.frame(
      treatment = sample(c("Control", "Treatment"), n, replace = TRUE),
      age = round(rnorm(n, mean = 45, sd = 15)),
      gender = sample(c("Male", "Female"), n, replace = TRUE),
      baseline_score = rnorm(n, mean = 50, sd = 10)
    )
    
    # Create outcome with treatment effect
    treatment_effect <- ifelse(data$treatment == "Treatment", 5, 0)
    data$outcome <- data$baseline_score + treatment_effect + 
                   0.3 * data$age + 
                   rnorm(n, mean = 0, sd = 8)
    
  } else {
    # Generate data for associational hypothesis
    data <- data.frame(
      predictor1 = rnorm(n, mean = 0, sd = 1),
      predictor2 = rnorm(n, mean = 0, sd = 1),
      predictor3 = sample(c("Low", "Medium", "High"), n, replace = TRUE)
    )
    
    # Create outcome with associations
    data$outcome <- 2 + 3 * data$predictor1 - 1.5 * data$predictor2 +
                   ifelse(data$predictor3 == "Medium", 2, 
                          ifelse(data$predictor3 == "High", 4, 0)) +
                   rnorm(n, mean = 0, sd = 2)
  }
  
  return(data)
}