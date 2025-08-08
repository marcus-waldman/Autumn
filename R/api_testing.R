# API Testing Functions for Autumn Scientific Methods Engine
# Tests connectivity and functionality of Anthropic and Perplexity APIs

library(httr)
library(jsonlite)

# Test Anthropic API connection
test_anthropic_api <- function(api_key = NULL, model = "claude-3-5-sonnet-20241022") {
  if (is.null(api_key)) {
    api_key <- Sys.getenv("ANTHROPIC_API_KEY")
  }
  
  if (nchar(api_key) == 0) {
    return(list(
      success = FALSE,
      error = "No API key found",
      details = "ANTHROPIC_API_KEY environment variable not set"
    ))
  }
  
  # Test with a simple prompt
  test_prompt <- "Respond with exactly: 'API connection successful'"
  
  tryCatch({
    url <- "https://api.anthropic.com/v1/messages"
    
    body <- list(
      model = model,
      max_tokens = 50,
      messages = list(
        list(
          role = "user",
          content = test_prompt
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
      timeout(10)  # 10 second timeout for testing
    )
    
    if (status_code(response) == 200) {
      content_response <- fromJSON(content(response, "text"))
      response_text <- content_response$content$text[1]
      
      return(list(
        success = TRUE,
        response = response_text,
        model = model,
        status_code = status_code(response)
      ))
    } else {
      error_content <- content(response, "text")
      return(list(
        success = FALSE,
        error = paste("HTTP", status_code(response)),
        details = error_content
      ))
    }
  }, error = function(e) {
    return(list(
      success = FALSE,
      error = "Connection failed",
      details = e$message
    ))
  })
}

# Test Perplexity API connection
test_perplexity_api <- function(api_key = NULL, model = "sonar-pro") {
  if (is.null(api_key)) {
    api_key <- Sys.getenv("PERPLEXITY_API_KEY")
  }
  
  if (nchar(api_key) == 0) {
    return(list(
      success = FALSE,
      error = "No API key found",
      details = "PERPLEXITY_API_KEY environment variable not set"
    ))
  }
  
  # Test with a simple search
  test_query <- "API connection test"
  
  tryCatch({
    url <- "https://api.perplexity.ai/chat/completions"
    
    body <- list(
      model = model,
      messages = list(
        list(
          role = "user",
          content = paste("Search for:", test_query, "- respond with 'Perplexity API working' if successful")
        )
      ),
      max_tokens = 50
    )
    
    response <- POST(
      url,
      add_headers(
        "Authorization" = paste("Bearer", api_key),
        "Content-Type" = "application/json"
      ),
      body = toJSON(body, auto_unbox = TRUE),
      timeout(15)  # Longer timeout for Perplexity
    )
    
    if (status_code(response) == 200) {
      content_response <- fromJSON(content(response, "text"))
      response_text <- content_response$choices$message$content[1]
      
      return(list(
        success = TRUE,
        response = response_text,
        model = model,
        status_code = status_code(response)
      ))
    } else {
      error_content <- content(response, "text")
      return(list(
        success = FALSE,
        error = paste("HTTP", status_code(response)),
        details = error_content
      ))
    }
  }, error = function(e) {
    return(list(
      success = FALSE,
      error = "Connection failed",
      details = e$message
    ))
  })
}

# Test both APIs and return comprehensive status
test_all_apis <- function(anthropic_model = "claude-3-5-sonnet-20241022", perplexity_model = "sonar-pro") {
  anthropic_result <- test_anthropic_api(model = anthropic_model)
  perplexity_result <- test_perplexity_api(model = perplexity_model)
  
  return(list(
    anthropic = anthropic_result,
    perplexity = perplexity_result,
    literature_enabled = anthropic_result$success && perplexity_result$success,
    timestamp = Sys.time()
  ))
}

# Generate status message for UI display
format_api_status <- function(test_results) {
  status_messages <- c()
  
  # Anthropic status
  if (test_results$anthropic$success) {
    status_messages <- c(status_messages, "✅ Anthropic API: Connected")
  } else {
    status_messages <- c(status_messages, paste("❌ Anthropic API:", test_results$anthropic$error))
  }
  
  # Perplexity status  
  if (test_results$perplexity$success) {
    status_messages <- c(status_messages, "✅ Perplexity API: Connected")
  } else {
    status_messages <- c(status_messages, paste("❌ Perplexity API:", test_results$perplexity$error))
  }
  
  # Overall status
  if (test_results$literature_enabled) {
    status_messages <- c(status_messages, "🔬 Literature Integration: Active")
  } else {
    status_messages <- c(status_messages, "⚠️ Literature Integration: Unavailable")
  }
  
  return(paste(status_messages, collapse = "\n"))
}

# Quick diagnostic function
diagnose_api_issues <- function() {
  cat("🔍 Diagnosing API connections...\n\n")
  
  results <- test_all_apis()
  
  cat("ANTHROPIC API:\n")
  if (results$anthropic$success) {
    cat("✅ Status: Working\n")
    cat("📝 Response:", substr(results$anthropic$response, 1, 100), "\n")
  } else {
    cat("❌ Status: Failed\n")
    cat("🚨 Error:", results$anthropic$error, "\n")
    cat("📋 Details:", results$anthropic$details, "\n")
  }
  
  cat("\nPERPLEXITY API:\n")
  if (results$perplexity$success) {
    cat("✅ Status: Working\n") 
    cat("📝 Response:", substr(results$perplexity$response, 1, 100), "\n")
  } else {
    cat("❌ Status: Failed\n")
    cat("🚨 Error:", results$perplexity$error, "\n")
    cat("📋 Details:", results$perplexity$details, "\n")
  }
  
  cat("\nOVERALL:\n")
  if (results$literature_enabled) {
    cat("🔬 Literature Integration: ACTIVE\n")
  } else {
    cat("⚠️ Literature Integration: DISABLED\n")
    cat("💡 Fix the failed API(s) above to enable full functionality\n")
  }
  
  return(results)
}