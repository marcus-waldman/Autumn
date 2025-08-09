# Autumn Scientific Methods Engine - Clean Single Page Version
# Starting fresh with minimal black and white design

library(shiny)
library(shinyjs)
library(httr)
library(ellmer)
library(jsonlite)

# UI - Single Page, Vertical Flow
ui <- fluidPage(
  # Initialize shinyjs
  useShinyjs(),
  
  # Basic styling - black and white only
  tags$head(
    tags$style(HTML("
      body {
        font-family: 'Segoe UI', sans-serif;
        background-color: white;
        color: black;
        max-width: 800px;
        margin: 0 auto;
        padding: 40px 20px;
        line-height: 1.6;
      }
      
      .section {
        margin: 40px 0;
        padding: 20px 0;
        border-bottom: 1px solid #ddd;
      }
      
      .api-status {
        display: inline-block;
        margin-left: 10px;
        font-weight: bold;
      }
      
      .status-success {
        color: black;
      }
      
      .status-error {
        color: black;
      }
      
      .file-input {
        margin: 10px 0;
      }
      
      .input-row {
        display: flex;
        align-items: center;
        gap: 15px;
        margin: 10px 0;
      }
      
      .file-upload {
        flex: 1;
      }
      
      .column-select {
        min-width: 150px;
      }
      
      /* Shinychat styling to match black and white theme */
      .chat-container {
        background-color: white !important;
        color: black !important;
      }
      
      .chat-message {
        border-color: #ddd !important;
      }
    "))
  ),
  
  # Page Title
  h1("Autumn - Accelerating Science through Collaborative Discovery"),
  
  # Section 1: API Keys
  div(class = "section",
    h2("API Configuration"),
    p("Upload CSV files containing your API keys to get started."),
    
    # Anthropic API Key Upload
    div(class = "input-row",
      div(class = "file-upload",
        fileInput("anthropic_key_file", 
                  "Anthropic API Key (CSV file):",
                  accept = c(".csv"))
      ),
      div(class = "column-select",
        selectInput("anthropic_column", 
                    "Column:",
                    choices = NULL,
                    width = "150px")
      ),
      span(id = "anthropic_status", class = "api-status", "⏳ Not tested")
    ),
    div(id = "anthropic_error", style = "color: black; font-size: 14px; margin: 5px 0; min-height: 20px;"),
    
    # Perplexity API Key Upload  
    div(class = "input-row",
      div(class = "file-upload",
        fileInput("perplexity_key_file",
                  "Perplexity API Key (CSV file):",
                  accept = c(".csv"))
      ),
      div(class = "column-select",
        selectInput("perplexity_column",
                    "Column:", 
                    choices = NULL,
                    width = "150px")
      ),
      span(id = "perplexity_status", class = "api-status", "⏳ Not tested")
    ),
    div(id = "perplexity_error", style = "color: black; font-size: 14px; margin: 5px 0; min-height: 20px;"),
    
    # Model Selection Section
    div(class = "section",
      h2("Model Selection"),
      p("Choose which AI models to use for testing and analysis."),
      
      div(class = "input-row",
        div(class = "file-upload",
          selectInput("anthropic_model", 
                      "Anthropic Model:",
                      choices = NULL,
                      selected = NULL)
        ),
        div(class = "file-upload",
          selectInput("perplexity_model",
                      "Perplexity Model:", 
                      choices = list(
                        "Sonar Pro" = "sonar-pro",
                        "Sonar" = "sonar",
                        "Sonar Reasoning" = "sonar-reasoning"
                      ),
                      selected = "sonar-pro")
        )
      )
    ),
    
    # Test Connection Button
    br(),
    actionButton("test_apis", "Test API Connections", 
                style = "background-color: white; border: 1px solid black; color: black;")
  ),
  
  # Simple Chat Interface with Ellmer
  div(class = "section",
    h2("Chat with AI"),
    p("Chat with your configured AI models."),
    
    # Provider selection
    div(style = "margin: 10px 0;",
      selectInput("chat_provider", "Choose AI Provider:",
                  choices = list("Anthropic" = "anthropic", 
                                "Perplexity" = "perplexity"),
                  selected = "anthropic",
                  width = "200px")
    ),
    
    # Academic mode toggle for Perplexity
    conditionalPanel(
      condition = "input.chat_provider == 'perplexity'",
      div(style = "margin: 10px 0;",
        checkboxInput("academic_mode", 
                     "Academic Mode (scholarly sources only)", 
                     value = FALSE),
        div(style = "font-size: 12px; color: #666; margin-top: 5px;",
            "When enabled, searches only peer-reviewed papers, journal articles, and research publications. Citations will include DOI numbers when available.")
      )
    ),
    
    # Model info display
    div(id = "current_model_display", 
        style = "margin: 10px 0; padding: 10px; background: #f0f0f0; border: 1px solid #ddd;"),
    
    # Chat history
    div(id = "chat_history", 
        style = "height: 300px; border: 1px solid #ddd; padding: 15px; margin: 10px 0; overflow-y: scroll; background-color: #f9f9f9;"),
    
    # Message input
    div(style = "display: flex; gap: 10px;",
      textInput("chat_message", NULL, 
               placeholder = "Type your message here...",
               width = "100%"),
      actionButton("send_message", "Send",
                  style = "background-color: white; border: 1px solid black; color: black;")
    )
  )
)

# Server Logic
server <- function(input, output, session) {
  
  # Store API keys and selected models
  values <- reactiveValues(
    anthropic_key = NULL,
    perplexity_key = NULL,
    selected_anthropic_model = NULL,
    selected_perplexity_model = "sonar-pro",
    ellmer_setup = FALSE,
    chat_messages = character(0),
    chat_session_anthropic = NULL,
    chat_session_perplexity = NULL
  )
  
  # Initialize ellmer models on startup
  observe({
    tryCatch({
      # Try to get Anthropic models using ellmer
      anthropic_models <- models_anthropic()
      if (length(anthropic_models) > 0) {
        # Create named list for dropdown
        model_choices <- setNames(anthropic_models, anthropic_models)
        updateSelectInput(session, "anthropic_model", 
                         choices = model_choices,
                         selected = anthropic_models[1])
        values$selected_anthropic_model <- anthropic_models[1]
      }
    }, error = function(e) {
      # Fallback to static models if ellmer fails
      fallback_models <- list(
        "claude-3-5-sonnet-20241022" = "claude-3-5-sonnet-20241022",
        "claude-3-5-haiku-20241022" = "claude-3-5-haiku-20241022",
        "claude-3-haiku-20240307" = "claude-3-haiku-20240307"
      )
      updateSelectInput(session, "anthropic_model",
                       choices = fallback_models,
                       selected = "claude-3-5-sonnet-20241022")
      values$selected_anthropic_model <- "claude-3-5-sonnet-20241022"
    })
  })
  
  # Handle Anthropic key upload
  observeEvent(input$anthropic_key_file, {
    req(input$anthropic_key_file)
    
    tryCatch({
      key_data <- read.csv(input$anthropic_key_file$datapath, stringsAsFactors = FALSE)
      column_names <- names(key_data)
      
      # Update column dropdown
      updateSelectInput(session, "anthropic_column", 
                       choices = column_names,
                       selected = column_names[1])
      
      showNotification("CSV loaded - select the column containing your API key", type = "message")
      
    }, error = function(e) {
      showNotification(paste("Error reading file:", e$message), type = "error")
    })
  })
  
  # Handle Anthropic column selection
  observeEvent(input$anthropic_column, {
    req(input$anthropic_key_file, input$anthropic_column)
    
    tryCatch({
      key_data <- read.csv(input$anthropic_key_file$datapath, stringsAsFactors = FALSE)
      if (input$anthropic_column %in% names(key_data)) {
        values$anthropic_key <- key_data[[input$anthropic_column]][1]
        
        # Set up ellmer with Anthropic API key
        Sys.setenv(ANTHROPIC_API_KEY = values$anthropic_key)
        
        showNotification("Anthropic key extracted from selected column", type = "message")
      }
    }, error = function(e) {
      showNotification(paste("Error extracting key:", e$message), type = "error")
    })
  })
  
  # Handle Perplexity key upload
  observeEvent(input$perplexity_key_file, {
    req(input$perplexity_key_file)
    
    tryCatch({
      key_data <- read.csv(input$perplexity_key_file$datapath, stringsAsFactors = FALSE)
      column_names <- names(key_data)
      
      # Update column dropdown
      updateSelectInput(session, "perplexity_column", 
                       choices = column_names,
                       selected = column_names[1])
      
      showNotification("CSV loaded - select the column containing your API key", type = "message")
      
    }, error = function(e) {
      showNotification(paste("Error reading file:", e$message), type = "error")
    })
  })
  
  # Handle Perplexity column selection
  observeEvent(input$perplexity_column, {
    req(input$perplexity_key_file, input$perplexity_column)
    
    tryCatch({
      key_data <- read.csv(input$perplexity_key_file$datapath, stringsAsFactors = FALSE)
      if (input$perplexity_column %in% names(key_data)) {
        values$perplexity_key <- key_data[[input$perplexity_column]][1]
        
        # Set up ellmer with Perplexity API key if available
        Sys.setenv(PERPLEXITY_API_KEY = values$perplexity_key)
        
        showNotification("Perplexity key extracted from selected column", type = "message")
      }
    }, error = function(e) {
      showNotification(paste("Error extracting key:", e$message), type = "error")
    })
  })
  
  # Update selected models when changed
  observeEvent(input$anthropic_model, {
    values$selected_anthropic_model <- input$anthropic_model
  })
  
  observeEvent(input$perplexity_model, {
    values$selected_perplexity_model <- input$perplexity_model
  })
  
  # Test API connections
  observeEvent(input$test_apis, {
    # Clear previous error messages
    runjs("document.getElementById('anthropic_error').innerHTML = '';")
    runjs("document.getElementById('perplexity_error').innerHTML = '';")
    
    # Test Anthropic API
    if (!is.null(values$anthropic_key)) {
      anthropic_result <- test_anthropic_connection(values$anthropic_key, values$selected_anthropic_model)
      if (anthropic_result$success) {
        runjs("document.getElementById('anthropic_status').innerHTML = '✓ Connected';")
        runjs("document.getElementById('anthropic_status').className = 'api-status status-success';")
      } else {
        runjs("document.getElementById('anthropic_status').innerHTML = '✗ Failed';")
        runjs("document.getElementById('anthropic_status').className = 'api-status status-error';")
        error_msg <- gsub("'", "\\\\'", anthropic_result$message)
        runjs(sprintf("document.getElementById('anthropic_error').innerHTML = 'Error: %s';", error_msg))
      }
    } else {
      runjs("document.getElementById('anthropic_status').innerHTML = '✗ No key';")
      runjs("document.getElementById('anthropic_status').className = 'api-status status-error';")
      runjs("document.getElementById('anthropic_error').innerHTML = 'No API key provided';")
    }
    
    # Test Perplexity API
    if (!is.null(values$perplexity_key)) {
      perplexity_result <- test_perplexity_connection(values$perplexity_key, values$selected_perplexity_model)
      if (perplexity_result$success) {
        runjs("document.getElementById('perplexity_status').innerHTML = '✓ Connected';")
        runjs("document.getElementById('perplexity_status').className = 'api-status status-success';")
      } else {
        runjs("document.getElementById('perplexity_status').innerHTML = '✗ Failed';")
        runjs("document.getElementById('perplexity_status').className = 'api-status status-error';")
        error_msg <- gsub("'", "\\\\'", perplexity_result$message)
        error_msg <- gsub('"', '\\\\"', error_msg)
        runjs(sprintf("document.getElementById('perplexity_error').innerHTML = 'Error: %s';", error_msg))
      }
    } else {
      runjs("document.getElementById('perplexity_status').innerHTML = '✗ No key';")
      runjs("document.getElementById('perplexity_status').className = 'api-status status-error';")
      runjs("document.getElementById('perplexity_error').innerHTML = 'No API key provided';")
    }
  })
  
  # Update model display
  observe({
    if (!is.null(values$selected_anthropic_model)) {
      model_info <- paste0("Current Model: ", values$selected_anthropic_model)
      runjs(sprintf("document.getElementById('current_model_display').innerHTML = '%s';", model_info))
    }
  })
  
  # Update model display based on selected provider
  observe({
    req(input$chat_provider)
    
    if (input$chat_provider == "anthropic" && !is.null(values$selected_anthropic_model)) {
      model_info <- paste0("Provider: Anthropic | Model: ", values$selected_anthropic_model)
      runjs(sprintf("document.getElementById('current_model_display').innerHTML = '%s';", model_info))
    } else if (input$chat_provider == "perplexity" && !is.null(values$selected_perplexity_model)) {
      model_info <- paste0("Provider: Perplexity | Model: ", values$selected_perplexity_model)
      runjs(sprintf("document.getElementById('current_model_display').innerHTML = '%s';", model_info))
    }
  })
  
  # Handle chat messages
  observeEvent(input$send_message, {
    req(input$chat_message, input$chat_provider)
    
    # Check if appropriate API key exists
    if (input$chat_provider == "anthropic" && is.null(values$anthropic_key)) {
      showNotification("Please upload Anthropic API key first", type = "error")
      return()
    }
    
    if (input$chat_provider == "perplexity" && is.null(values$perplexity_key)) {
      showNotification("Please upload Perplexity API key first", type = "error")
      return()
    }
    
    # Immediately show user message and disable send button
    user_msg <- paste0("<div style='margin: 10px 0; padding: 10px; background: white; border-left: 3px solid #333;'><strong>You:</strong> ", 
                      htmltools::htmlEscape(input$chat_message), "</div>")
    values$chat_messages <- c(values$chat_messages, user_msg)
    
    # Add thinking indicator
    thinking_msg <- "<div id='thinking-indicator' style='margin: 10px 0; padding: 10px; background: #f8f8f8; border-left: 3px solid #999; font-style: italic; color: #666;'><strong>AI:</strong> Thinking... 💭</div>"
    values$chat_messages <- c(values$chat_messages, thinking_msg)
    
    # Update display and disable button
    current_chat <- paste0(values$chat_messages, collapse = "")
    runjs(sprintf("document.getElementById('chat_history').innerHTML = '%s';", 
                 gsub("'", "\\\\'", current_chat)))
    runjs("document.getElementById('chat_history').scrollTop = document.getElementById('chat_history').scrollHeight;")
    runjs("document.getElementById('send_message').disabled = true;")
    runjs("document.getElementById('send_message').innerHTML = 'Processing...';")
    
    # Clear input immediately
    user_message <- input$chat_message
    updateTextInput(session, "chat_message", value = "")
    
    tryCatch({
      if (input$chat_provider == "anthropic") {
        # Set environment variable for Anthropic
        Sys.setenv(ANTHROPIC_API_KEY = values$anthropic_key)
        
        # Get model
        model_to_use <- if(is.null(values$selected_anthropic_model)) "claude-3-5-sonnet-20241022" else values$selected_anthropic_model
        
        # Direct Anthropic chat using ellmer
        if (is.null(values$chat_session_anthropic)) {
          values$chat_session_anthropic <- chat_anthropic(model = model_to_use)
        }
        
        response <- values$chat_session_anthropic$chat(user_message)
        provider_label <- paste0("Anthropic (", model_to_use, ")")
        
      } else if (input$chat_provider == "perplexity") {
        # Direct Perplexity API call using httr
        model_to_use <- values$selected_perplexity_model
        
        # Modify user message for academic mode to request DOI citations
        enhanced_message <- if (!is.null(input$academic_mode) && input$academic_mode) {
          paste0(user_message, "\n\nPlease provide citations in academic format with DOI numbers when available (format: Author et al. (Year). Title. Journal. DOI: 10.xxxx/xxxxx).")
        } else {
          user_message
        }
        
        # Build API request body with conditional academic mode
        request_body <- list(
          model = model_to_use,
          messages = list(list(role = "user", content = enhanced_message)),
          max_tokens = 2000,
          temperature = 0.2,
          top_p = 0.9,
          return_citations = TRUE,
          return_images = FALSE,
          return_related_questions = FALSE,
          search_recency_filter = "month",
          top_k = 0,
          stream = FALSE,
          presence_penalty = 0,
          frequency_penalty = 1
        )
        
        # Add academic mode if enabled
        if (!is.null(input$academic_mode) && input$academic_mode) {
          request_body$search_mode <- "academic"
          # Remove general domain filter for academic mode
        } else {
          # Use general web search for non-academic mode
          request_body$search_domain_filter <- list("perplexity.ai")
        }
        
        api_response <- httr::POST(
          url = "https://api.perplexity.ai/chat/completions",
          httr::add_headers(
            "Authorization" = paste("Bearer", values$perplexity_key),
            "Content-Type" = "application/json"
          ),
          body = jsonlite::toJSON(request_body, auto_unbox = TRUE),
          encode = "raw"
        )
        
        if (httr::status_code(api_response) == 200) {
          content <- httr::content(api_response, "text", encoding = "UTF-8")
          parsed <- jsonlite::fromJSON(content, flatten = FALSE)
          
          # Note: Perplexity API returns OpenAI-compatible format but jsonlite parses as data frames
          
          # Perplexity uses OpenAI format but parsed as data frame
          if (!is.null(parsed$choices) && nrow(parsed$choices) > 0) {
            # Choices is a data frame, extract content from first row
            if (!is.null(parsed$choices$message) && nrow(parsed$choices$message) > 0) {
              response <- parsed$choices$message$content[1]
            } else {
              response <- "Error: No message content in choices data frame"
            }
          } else if (!is.null(parsed$content)) {
            # Direct content field
            response <- parsed$content
          } else if (!is.null(parsed$message) && !is.null(parsed$message$content)) {
            # Message wrapper
            response <- parsed$message$content
          } else if (!is.null(parsed$text)) {
            # Simple text field
            response <- parsed$text
          } else {
            # If we can't find content, show what fields are available
            available_fields <- names(parsed)
            response <- paste0("Error: Unable to find content in Perplexity response. Available fields: ", 
                             paste(available_fields, collapse = ", "), 
                             ". Raw response: ", substr(content, 1, 300))
          }
          
          # Add citations if available
          if (!is.null(parsed$citations) && length(parsed$citations) > 0) {
            citations_text <- paste0("\n\n**Sources:**\n")
            for (i in 1:length(parsed$citations)) {
              citations_text <- paste0(citations_text, "- ", parsed$citations[i], "\n")
            }
            response <- paste0(response, citations_text)
          }
        } else {
          error_content <- httr::content(api_response, "text", encoding = "UTF-8")
          response <- paste0("Perplexity API Error (", httr::status_code(api_response), "): ", error_content)
        }
        
        # Create provider label with academic mode indicator
        academic_indicator <- if (!is.null(input$academic_mode) && input$academic_mode) " - Academic Mode" else ""
        provider_label <- paste0("Perplexity (", model_to_use, ")", academic_indicator)
      }
      
      # Remove thinking indicator and add AI response
      values$chat_messages <- values$chat_messages[!grepl("thinking-indicator", values$chat_messages)]
      
      ai_msg <- paste0("<div style='margin: 10px 0; padding: 10px; background: #f0f0f0; border-left: 3px solid #666;'><strong>", 
                      provider_label, ":</strong> ", 
                      gsub("\n", "<br>", htmltools::htmlEscape(response)), "</div>")
      
      # Update chat display
      values$chat_messages <- c(values$chat_messages, ai_msg)
      current_chat <- paste0(values$chat_messages, collapse = "")
      
      runjs(sprintf("document.getElementById('chat_history').innerHTML = '%s';", 
                   gsub("'", "\\\\'", current_chat)))
      runjs("document.getElementById('chat_history').scrollTop = document.getElementById('chat_history').scrollHeight;")
      
      # Re-enable send button
      runjs("document.getElementById('send_message').disabled = false;")
      runjs("document.getElementById('send_message').innerHTML = 'Send';")
      
      # Clear input
      updateTextInput(session, "chat_message", value = "")
      
    }, error = function(e) {
      # Remove thinking indicator on error
      values$chat_messages <- values$chat_messages[!grepl("thinking-indicator", values$chat_messages)]
      
      error_msg <- paste0("<div style='color: red; margin: 10px 0;'><strong>Error:</strong> ", 
                         htmltools::htmlEscape(e$message), "</div>")
      values$chat_messages <- c(values$chat_messages, error_msg)
      current_chat <- paste0(values$chat_messages, collapse = "")
      
      runjs(sprintf("document.getElementById('chat_history').innerHTML = '%s';", 
                   gsub("'", "\\\\'", current_chat)))
      
      # Re-enable send button on error
      runjs("document.getElementById('send_message').disabled = false;")
      runjs("document.getElementById('send_message').innerHTML = 'Send';")
    })
  })
  
  # Enable Enter key
  runjs("
    $(document).on('keypress', '#chat_message', function(e) {
      if (e.which == 13) {
        $('#send_message').click();
      }
    });
  ")
}

# Helper function to test Anthropic API
test_anthropic_connection <- function(api_key, model = "claude-3-5-sonnet-20241022") {
  tryCatch({
    response <- httr::POST(
      url = "https://api.anthropic.com/v1/messages",
      httr::add_headers(
        "x-api-key" = api_key,
        "anthropic-version" = "2023-06-01",
        "content-type" = "application/json"
      ),
      body = jsonlite::toJSON(list(
        model = model,
        max_tokens = 10,
        messages = list(list(role = "user", content = "test"))
      ), auto_unbox = TRUE),
      encode = "raw"
    )
    
    if (httr::status_code(response) == 200) {
      return(list(success = TRUE, message = "Connected"))
    } else {
      return(list(success = FALSE, message = paste("HTTP", httr::status_code(response))))
    }
  }, error = function(e) {
    return(list(success = FALSE, message = e$message))
  })
}

# Helper function to test Perplexity API
test_perplexity_connection <- function(api_key, model = "sonar-pro") {
  tryCatch({
    response <- httr::POST(
      url = "https://api.perplexity.ai/chat/completions",
      httr::add_headers(
        "Authorization" = paste("Bearer", api_key),
        "Content-Type" = "application/json"
      ),
      body = jsonlite::toJSON(list(
        model = model,
        messages = list(list(role = "user", content = "test")),
        max_tokens = 10
      ), auto_unbox = TRUE),
      encode = "raw"
    )
    
    status <- httr::status_code(response)
    if (status == 200) {
      return(list(success = TRUE, message = "Connected"))
    } else {
      # Try to get more detailed error info
      content <- httr::content(response, "text")
      return(list(success = FALSE, message = paste("HTTP", status, "-", content)))
    }
  }, error = function(e) {
    return(list(success = FALSE, message = e$message))
  })
}

# Run the application
shinyApp(ui = ui, server = server)