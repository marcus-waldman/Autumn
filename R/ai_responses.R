# AI Response Generation for Scientific Methods Engine
# This module generates context-aware responses from Anthropic as a thought partner

generate_ai_response <- function(phase, user_input, values) {
  
  # Get context-specific information
  context <- get_phase_context(phase, values)
  
  # Generate response based on phase
  response <- switch(phase,
    "hypothesis" = generate_hypothesis_response(user_input, context, values),
    "planning" = generate_planning_response(user_input, context, values),
    "implementation" = generate_implementation_response(user_input, context, values),
    "analysis" = generate_analysis_response(user_input, context, values),
    "I'm here to help with your scientific analysis. What would you like to discuss?"
  )
  
  return(response)
}

# Get phase-specific context
get_phase_context <- function(phase, values) {
  context <- list()
  
  if (!is.null(values$data)) {
    context$has_data <- TRUE
    context$n_obs <- nrow(values$data)
    context$n_vars <- ncol(values$data)
    context$var_names <- names(values$data)
  }
  
  if (!is.null(values$hypothesis)) {
    context$hypothesis <- values$hypothesis
  }
  
  if (!is.null(values$plan)) {
    context$plan <- values$plan
  }
  
  if (!is.null(values$results)) {
    context$results <- values$results
  }
  
  return(context)
}

# Phase 1: Hypothesis Formation Responses
generate_hypothesis_response <- function(user_input, context, values) {
  input_lower <- tolower(user_input)
  
  # Initial hypothesis discussion
  if (grepl("hypothesis|idea|research|study|test", input_lower) && 
      !context$has_data) {
    return("I see you're thinking about your hypothesis. Before we dive deep, have you uploaded your data? Understanding your available variables will help us craft a more specific and testable hypothesis. What's the general relationship you're interested in exploring?")
  }
  
  # Data-related questions
  if (grepl("data|variable|column", input_lower) && context$has_data) {
    return(paste0(
      "Looking at your data, you have ", context$n_obs, " observations and ", 
      context$n_vars, " variables. The variables include: ", 
      paste(head(context$var_names, 10), collapse = ", "),
      ifelse(length(context$var_names) > 10, "...", ""), 
      ".\n\nWhich of these variables represents your primary outcome of interest? And are you thinking of a causal relationship or an association?"
    ))
  }
  
  # Causal vs associational clarification
  if (grepl("causal|cause|effect|impact", input_lower)) {
    return("You're interested in causal inference. That's great, but it comes with additional requirements. Can you tell me:
1. Is your treatment/exposure randomly assigned, or is this observational data?
2. What potential confounders might affect both your treatment and outcome?
3. Are there any time-ordering considerations we should account for?

Remember, establishing causation requires careful consideration of these factors.")
  }
  
  # Power and sample size concerns
  if (grepl("sample size|power|enough data|sufficient", input_lower)) {
    if (context$has_data) {
      n <- context$n_obs
      assessment <- if (n < 30) "quite small" else if (n < 100) "modest" else if (n < 500) "reasonable" else "substantial"
      
      return(paste0(
        "Your sample size of ", n, " is ", assessment, ". For hypothesis testing, we need to consider:\n",
        "- The expected effect size (how big a difference/relationship you expect)\n",
        "- The variability in your outcome\n",
        "- Your tolerance for Type I and Type II errors\n\n",
        "What effect size would be meaningful in your field? Do you have any prior studies or pilot data to guide expectations?"
      ))
    }
  }
  
  # Hypothesis refinement
  if (grepl("improve|better|refine|specific", input_lower)) {
    suggestions <- c(
      "Let's make your hypothesis more specific. A good hypothesis should clearly state:",
      "- The population of interest",
      "- The independent variable(s) or predictor(s)",
      "- The dependent variable(s) or outcome(s)",
      "- The expected direction of the relationship",
      "",
      "For example, instead of 'Treatment X affects outcome Y', consider:",
      "'Among [population], [treatment/exposure] will [increase/decrease] [specific outcome] by [expected magnitude] compared to [control/reference group].'",
      "",
      "How would you rephrase your hypothesis with these elements?"
    )
    return(paste(suggestions, collapse = "\n"))
  }
  
  # Challenging assumptions
  if (grepl("assume|assumption|think|believe", input_lower)) {
    return("I notice you're making some assumptions. Let's examine them critically:
- What evidence supports this assumption?
- What would happen to your hypothesis if this assumption were violated?
- Can we test this assumption with your data?
- Are there alternative explanations we should consider?

Being explicit about assumptions now will strengthen your analysis later.")
  }
  
  # Default thoughtful response
  return("That's an interesting point. To help refine your hypothesis further, could you elaborate on:
1. What specific relationship you expect to find?
2. Why this relationship is theoretically plausible?
3. What would constitute a meaningful effect in your context?

Remember, a well-formulated hypothesis guides the entire analysis, so let's make sure we get it right.")
}

# Phase 2: Planning Responses
generate_planning_response <- function(user_input, context, values) {
  input_lower <- tolower(user_input)
  
  # Power analysis discussion
  if (grepl("power|mde|detect|effect size", input_lower)) {
    if (!is.null(context$plan$mde)) {
      mde_value <- as.numeric(gsub("[^0-9.]", "", context$plan$mde))
      interpretation <- if (mde_value < 0.2) "very small" else if (mde_value < 0.5) "small" else if (mde_value < 0.8) "medium" else "large"
      
      return(paste0(
        "Your minimum detectable effect size indicates you can reliably detect ", interpretation, " effects. ",
        "This means:\n",
        "- Smaller effects might exist but go undetected (Type II error)\n",
        "- You have adequate power for effects of this magnitude or larger\n",
        "- Consider whether effects smaller than this would be practically meaningful\n\n",
        "Is this MDE acceptable for your research question? If not, we might need to consider alternative approaches."
      ))
    }
  }
  
  # Statistical test selection
  if (grepl("test|statistic|analysis|method", input_lower)) {
    return("Let's think through the most appropriate statistical test:
1. What's the nature of your outcome variable (continuous, binary, count, time-to-event)?
2. What's the structure of your predictor/treatment (categorical groups, continuous)?
3. Do you have repeated measures or clustered data?
4. Are there multiple predictors you need to adjust for?

Your current selection seems reasonable, but let's verify it aligns with these considerations.")
  }
  
  # Literature and benchmarks
  if (grepl("literature|benchmark|prior|study|research", input_lower)) {
    return("Excellent question about benchmarking against existing literature. Consider:
- What effect sizes have similar studies reported?
- Were those studies in comparable populations?
- Did they use similar measures and methods?
- What's the clinical or practical significance threshold in your field?

Adding literature benchmarks helps contextualize your findings. Do you have specific studies in mind we should reference?")
  }
  
  # Sensitivity analysis planning
  if (grepl("sensitivity|robust|assumption|alternative", input_lower)) {
    return("Planning sensitivity analyses is crucial for robust conclusions. Let's consider:
1. **Primary analysis assumptions**: What happens if they're violated?
2. **Alternative specifications**: Different variable coding, model forms
3. **Subgroup analyses**: Are effects consistent across groups?
4. **Missing data approaches**: Complete case vs. imputation
5. **Outlier influence**: How do extreme values affect results?

Which of these concerns you most for your specific analysis?")
  }
  
  # Default planning response
  return("Good question about the analytic plan. Remember, a solid plan should:
- Align with your hypothesis (don't fish for significance!)
- Account for your data structure and limitations
- Include pre-specified sensitivity analyses
- Consider practical alongside statistical significance

What specific aspect of the plan would you like to discuss further?")
}

# Phase 3: Implementation Responses  
generate_implementation_response <- function(user_input, context, values) {
  input_lower <- tolower(user_input)
  
  # Code understanding
  if (grepl("code|function|script|understand|explain", input_lower)) {
    return("Let me explain the key parts of the generated code:
1. **Data preparation**: Ensures variables are properly formatted
2. **Main analysis**: Implements the statistical test we planned
3. **Effect size calculation**: Quantifies the magnitude of findings
4. **Diagnostics**: Checks model assumptions
5. **Output formatting**: Organizes results for interpretation

Which part would you like me to explain in more detail?")
  }
  
  # Error troubleshooting
  if (grepl("error|problem|issue|fail|wrong", input_lower)) {
    return("I see you're encountering an issue. Let's debug systematically:
1. What's the exact error message?
2. At what step does it occur?
3. Have you checked for missing values in key variables?
4. Are variable types what the function expects?

Common issues include:
- Factor levels in treatment variables
- Missing data patterns
- Variable naming mismatches

Can you share the specific error for targeted help?")
  }
  
  # Results interpretation
  if (grepl("result|finding|significant|interpret", input_lower)) {
    return("Let's interpret these results carefully:
- **Statistical significance**: What does the p-value tell us?
- **Effect magnitude**: Is the effect size practically meaningful?
- **Confidence intervals**: What's the range of plausible values?
- **Model fit**: How well does the model explain the data?

Remember: statistical significance ≠ practical importance. What stands out to you in these results?")
  }
  
  # Unexpected findings
  if (grepl("unexpected|surprise|strange|different", input_lower)) {
    return("Unexpected results often lead to the most interesting insights! Let's explore:
1. **Data quality**: Could there be coding errors or outliers?
2. **Model specification**: Are we missing important variables?
3. **Theoretical implications**: Does this challenge our assumptions?
4. **Statistical artifacts**: Could this be due to multiple testing or chance?

What specifically surprised you? Sometimes 'null' results are just as informative as significant ones.")
  }
  
  # Default implementation response
  return("Good observation about the implementation. At this stage, it's important to:
- Verify the analysis ran as intended
- Check that results align with the planned approach
- Look for any red flags in diagnostics
- Consider whether additional analyses would be informative

What aspect of the implementation would you like to explore?")
}

# Phase 4: Analysis and Interpretation Responses
generate_analysis_response <- function(user_input, context, values) {
  input_lower <- tolower(user_input)
  
  # Overall interpretation
  if (grepl("interpret|mean|conclude|finding", input_lower)) {
    return("Let's synthesize your findings thoughtfully:
1. **Primary hypothesis**: Was it supported? To what degree?
2. **Effect magnitude**: Is it clinically/practically meaningful?
3. **Uncertainty**: What do confidence intervals tell us?
4. **Context**: How do results compare to prior literature?
5. **Mechanisms**: What might explain these findings?

Remember to distinguish between what you found and what it means. What's your key takeaway?")
  }
  
  # Limitations discussion
  if (grepl("limitation|weakness|concern|caveat", input_lower)) {
    return("Acknowledging limitations strengthens your research. Key areas to consider:
- **Design limitations**: Observational vs. experimental, sample selection
- **Measurement issues**: Validity, reliability, missing data
- **Statistical concerns**: Power, multiple comparisons, model assumptions
- **Generalizability**: Does your sample represent the target population?
- **Causal inference**: What threats remain unaddressed?

Which limitations are most important for readers to understand?")
  }
  
  # Clinical/practical significance
  if (grepl("practical|clinical|meaningful|important", input_lower)) {
    return("Statistical significance is just the start. For practical significance, consider:
- What's the smallest effect that would matter in practice?
- How does your effect size compare to this threshold?
- What would this mean for individual patients/subjects?
- Are the costs/benefits favorable for implementation?
- How certain are we about these estimates?

In your field, what constitutes a meaningful effect?")
  }
  
  # Future directions
  if (grepl("future|next|follow-up|research", input_lower)) {
    return("Great thinking about next steps! Consider:
1. **Replication**: How could findings be confirmed?
2. **Extension**: What populations, outcomes, or timeframes to explore?
3. **Mechanisms**: What studies could unpack 'why' this occurs?
4. **Implementation**: How to translate findings to practice?
5. **Methods advancement**: What would you do differently?

What feels like the most important next question?")
  }
  
  # Alternative explanations
  if (grepl("alternative|other|explain|why|because", input_lower)) {
    return("Considering alternative explanations is crucial for robust science:
- **Confounding**: What unmeasured variables might explain results?
- **Selection bias**: Could who's in your sample drive findings?
- **Measurement error**: How might this affect estimates?
- **Reverse causation**: Could the direction be opposite?
- **Chance**: With multiple tests, could this be random?

Which alternative explanations seem most plausible for your results?")
  }
  
  # Default analysis response
  return("That's a thoughtful point about the analysis. At this final stage, focus on:
- Clear communication of what you found
- Honest assessment of what it means
- Transparent discussion of limitations
- Constructive suggestions for future work

How can we best convey your findings to your intended audience?")
}

# Helper function to check if refined hypothesis should be updated
check_hypothesis_refinement <- function(user_input, ai_response, values) {
  # This would be called after certain AI responses to update the refined hypothesis
  # In a real implementation, this would use more sophisticated NLP
  
  keywords <- c("hypothesis is:", "I would state:", "reformulated as:", "specifically:")
  
  for (keyword in keywords) {
    if (grepl(keyword, user_input, ignore.case = TRUE)) {
      # Extract the hypothesis statement after the keyword
      parts <- strsplit(user_input, keyword, ignore.case = TRUE)[[1]]
      if (length(parts) > 1) {
        refined <- trimws(parts[2])
        # Remove trailing punctuation if needed
        refined <- gsub("[.?!]+$", "", refined)
        return(refined)
      }
    }
  }
  
  return(NULL)
}

# Function to generate contextual prompts for users
generate_prompt_suggestion <- function(phase, context) {
  prompts <- switch(phase,
    "hypothesis" = c(
      "What variables should I consider for my analysis?",
      "How can I make my hypothesis more specific?",
      "What sample size do I need for adequate power?",
      "Should I frame this as causal or associational?"
    ),
    "planning" = c(
      "Is my statistical test appropriate for my data?",
      "What effect size should I expect based on literature?",
      "What sensitivity analyses should I include?",
      "How do I interpret the power analysis?"
    ),
    "implementation" = c(
      "Can you explain what this code is doing?",
      "Why am I getting this error message?",
      "Are these results what we expected?",
      "Should we run additional analyses?"
    ),
    "analysis" = c(
      "How should I interpret these findings?",
      "What are the key limitations of this study?",
      "Is this effect practically significant?",
      "What future research would you recommend?"
    )
  )
  
  return(sample(prompts, 1))
}