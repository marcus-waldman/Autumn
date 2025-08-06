# Perplexity API Integration for Literature Search
# Provides evidence-based research support for the Scientific Methods Engine

library(httr)
library(jsonlite)

# Function to search literature using Perplexity API
search_literature <- function(query, max_results = 5, model = "llama-3.1-sonar-small-128k-online") {
  
  # Get API key from environment
  api_key <- Sys.getenv("PERPLEXITY_API_KEY")
  
  if (nchar(api_key) == 0) {
    return(list(
      success = FALSE,
      error = "Perplexity API key not found. Please set PERPLEXITY_API_KEY environment variable.",
      fallback = TRUE
    ))
  }
  
  # Construct API request
  url <- "https://api.perplexity.ai/chat/completions"
  
  # Enhanced prompt to get structured research results
  research_prompt <- paste0(
    "Search for recent scientific literature on: ", query, "\n\n",
    "Provide a structured summary with:\n",
    "1. Key findings from recent studies (last 5 years preferred)\n",
    "2. Effect sizes or quantitative results when available\n",
    "3. Study populations and methodologies\n",
    "4. Gaps or limitations in current research\n",
    "5. Specific citations with authors and year\n\n",
    "Focus on peer-reviewed studies, meta-analyses, and systematic reviews. ",
    "Include specific statistical findings (p-values, effect sizes, confidence intervals) when available."
  )
  
  body <- list(
    model = model,
    messages = list(
      list(
        role = "system",
        content = "You are a scientific research assistant. Provide accurate, evidence-based information from recent peer-reviewed literature. Always cite specific studies with authors and publication years. Focus on quantitative findings and statistical results."
      ),
      list(
        role = "user", 
        content = research_prompt
      )
    ),
    max_tokens = 1000,
    temperature = 0.2,
    top_p = 0.9
  )
  
  # Make API request with error handling
  tryCatch({
    response <- POST(
      url,
      add_headers(
        "Authorization" = paste("Bearer", api_key),
        "Content-Type" = "application/json"
      ),
      body = toJSON(body, auto_unbox = TRUE),
      timeout(30)  # 30 second timeout
    )
    
    if (status_code(response) == 200) {
      content <- fromJSON(content(response, "text"))
      
      # Extract the research summary
      research_summary <- content$choices[[1]]$message$content
      
      # Parse citations (basic pattern matching)
      citations <- extract_citations(research_summary)
      
      return(list(
        success = TRUE,
        query = query,
        summary = research_summary,
        citations = citations,
        timestamp = Sys.time(),
        model_used = model
      ))
      
    } else {
      return(list(
        success = FALSE,
        error = paste("API request failed with status:", status_code(response)),
        details = content(response, "text"),
        fallback = TRUE
      ))
    }
    
  }, error = function(e) {
    return(list(
      success = FALSE,
      error = paste("Request error:", e$message),
      fallback = TRUE
    ))
  })
}

# Helper function to extract citations from research text
extract_citations <- function(text) {
  # Basic pattern matching for citations
  # Matches patterns like "Smith et al. (2023)" or "Johnson & Brown (2022)"
  citation_patterns <- c(
    "\\b[A-Z][a-z]+\\s+et\\s+al\\.\\s+\\(\\d{4}\\)",  # Smith et al. (2023)
    "\\b[A-Z][a-z]+\\s+&\\s+[A-Z][a-z]+\\s+\\(\\d{4}\\)",  # Smith & Jones (2023)
    "\\b[A-Z][a-z]+\\s+\\(\\d{4}\\)"  # Smith (2023)
  )
  
  citations <- c()
  for (pattern in citation_patterns) {
    matches <- regmatches(text, gregexpr(pattern, text))[[1]]
    citations <- c(citations, matches)
  }
  
  # Remove duplicates and return
  return(unique(citations))
}

# Function to extract search queries from AI response
extract_search_queries <- function(ai_response) {
  # Look for patterns that indicate literature search needs
  # This is a simplified implementation - could be enhanced with NLP
  
  queries <- c()
  
  # Pattern 1: Direct mentions of searches
  search_patterns <- c(
    "search for:?\\s*\"([^\"]+)\"",
    "literature on:?\\s*\"([^\"]+)\"",
    "studies about:?\\s*\"([^\"]+)\"",
    "research on:?\\s*([^\n.]+)"
  )
  
  for (pattern in search_patterns) {
    matches <- regmatches(ai_response, gregexpr(pattern, ai_response, ignore.case = TRUE))[[1]]
    if (length(matches) > 0) {
      # Extract the quoted or captured content
      extracted <- gsub(pattern, "\\1", matches, ignore.case = TRUE)
      queries <- c(queries, trimws(extracted))
    }
  }
  
  # Pattern 2: Numbered search suggestions
  numbered_pattern <- "\\d+\\.\\s*([^\\n.]+(?:meta-analysis|systematic review|RCT|randomized trial|effect size|studies?))"
  numbered_matches <- regmatches(ai_response, gregexpr(numbered_pattern, ai_response, ignore.case = TRUE))[[1]]
  if (length(numbered_matches) > 0) {
    extracted_numbered <- gsub("\\d+\\.\\s*", "", numbered_matches)
    queries <- c(queries, trimws(extracted_numbered))
  }
  
  # Default searches if none found
  if (length(queries) == 0) {
    queries <- c("recent systematic review meta-analysis")
  }
  
  # Limit to 3 searches to control API costs
  return(head(unique(queries), 3))
}

# Function to format literature results for display
format_literature <- function(literature_results) {
  if (length(literature_results) == 0) {
    return("No literature searches were performed.")
  }
  
  formatted <- c()
  
  for (i in seq_along(literature_results)) {
    result <- literature_results[[i]]
    
    if (result$success) {
      section <- paste0(
        "**Literature Search ", i, ": \"", result$query, "\"**\n\n",
        result$summary, "\n\n",
        if (length(result$citations) > 0) {
          paste0("**Key Citations:** ", paste(result$citations, collapse = "; "), "\n\n")
        } else {
          ""
        },
        "---\n\n"
      )
    } else {
      section <- paste0(
        "**Literature Search ", i, " (Failed):**\n",
        "Query: ", result$query %||% "Unknown", "\n",
        "Error: ", result$error, "\n\n",
        "---\n\n"
      )
    }
    
    formatted <- c(formatted, section)
  }
  
  return(paste(formatted, collapse = ""))
}

# Safe wrapper for literature search with fallback
safe_literature_search <- function(query) {
  tryCatch({
    result <- search_literature(query)
    
    if (!result$success && result$fallback) {
      # Return a structured fallback response
      return(list(
        success = FALSE,
        fallback = TRUE,
        query = query,
        message = "Literature search unavailable. Using general knowledge base.",
        general_guidance = generate_fallback_guidance(query)
      ))
    }
    
    return(result)
    
  }, error = function(e) {
    return(list(
      success = FALSE,
      fallback = TRUE,
      query = query,
      error = e$message,
      message = "Literature search failed. Using general knowledge base."
    ))
  })
}

# Generate fallback guidance when Perplexity is unavailable
generate_fallback_guidance <- function(query) {
  # Basic pattern matching to provide general guidance
  query_lower <- tolower(query)
  
  if (grepl("meta-analysis|systematic review", query_lower)) {
    return("Consider searching PubMed, Cochrane, or PROSPERO for recent meta-analyses and systematic reviews. Look for studies with large sample sizes and diverse populations.")
  }
  
  if (grepl("effect size|cohen", query_lower)) {
    return("Typical effect size conventions: small (d=0.2), medium (d=0.5), large (d=0.8). However, field-specific benchmarks are more meaningful. Consider the clinical or practical significance threshold in your domain.")
  }
  
  if (grepl("power analysis|sample size", query_lower)) {
    return("Standard power analysis targets 80% power with α=0.05. Consider the smallest effect size of interest (SESOI) rather than conventional effect sizes. Account for expected attrition and missing data.")
  }
  
  if (grepl("randomized|rct|causal", query_lower)) {
    return("For causal inference, prioritize randomized controlled trials when available. For observational studies, consider instrumental variables, regression discontinuity, or difference-in-differences designs.")
  }
  
  return("Consider searching recent peer-reviewed literature in your field. Focus on studies with similar populations, measures, and methodological approaches.")
}

# Function to cache literature search results to avoid redundant API calls
create_literature_cache <- function() {
  cache_env <- new.env()
  
  list(
    get = function(query) {
      cache_env[[query]]
    },
    
    set = function(query, result) {
      cache_env[[query]] <- list(
        result = result,
        timestamp = Sys.time()
      )
    },
    
    is_fresh = function(query, max_age_hours = 24) {
      cached <- cache_env[[query]]
      if (is.null(cached)) return(FALSE)
      
      age_hours <- as.numeric(difftime(Sys.time(), cached$timestamp, units = "hours"))
      return(age_hours <= max_age_hours)
    }
  )
}

# Initialize global cache
literature_cache <- create_literature_cache()

# Cached literature search function
cached_literature_search <- function(query) {
  # Check cache first
  if (literature_cache$is_fresh(query)) {
    cached_result <- literature_cache$get(query)
    cached_result$result$from_cache <- TRUE
    return(cached_result$result)
  }
  
  # Perform new search
  result <- safe_literature_search(query)
  
  # Cache successful results
  if (result$success) {
    literature_cache$set(query, result)
  }
  
  return(result)
}