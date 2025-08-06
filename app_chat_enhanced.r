# Scientific Methods Engine - Chat-Enhanced Version
# Collaborative AI-powered hypothesis testing with Anthropic as thought partner

library(shiny)
library(shinydashboard)
library(DT)
library(tidyverse)
library(jsonlite)
library(knitr)
library(rmarkdown)

# Define chat UI component
chatUI <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      id = ns("chat-container"),
      style = "height: 400px; overflow-y: auto; border: 1px solid #ddd; padding: 10px; background-color: #f9f9f9; border-radius: 8px;",
      uiOutput(ns("chat_history"))
    ),
    tags$div(
      style = "margin-top: 10px;",
      fluidRow(
        column(10, 
          textAreaInput(ns("user_input"), 
                        label = NULL,
                        placeholder = "Ask Anthropic anything about your analysis...",
                        rows = 2,
                        width = "100%")
        ),
        column(2,
          actionButton(ns("send_message"), 
                       "Send", 
                       icon = icon("paper-plane"),
                       class = "btn-primary",
                       style = "margin-top: 12px; width: 100%;")
        )
      )
    )
  )
}

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Scientific Methods Engine - AI Collaborative"),
  
  dashboardSidebar(
    sidebarMenu(
      id = "phases",
      conditionalPanel(
        condition = "output.api_key_required",
        menuItem("API Key Setup", tabName = "api_setup", icon = icon("key"))
      ),
      conditionalPanel(
        condition = "!output.api_key_required",
        menuItem("Phase 1: Hypothesis", tabName = "hypothesis", icon = icon("lightbulb")),
        menuItem("Phase 2: Planning", tabName = "planning", icon = icon("tasks")),
        menuItem("Phase 3: Implementation", tabName = "implementation", icon = icon("code")),
        menuItem("Phase 4: Analysis", tabName = "analysis", icon = icon("chart-line"))
      )
    ),
    
    tags$hr(),
    tags$div(
      id = "phase-status",
      style = "padding: 10px;",
      h4("Progress"),
      uiOutput("progress_indicators")
    ),
    
    tags$hr(),
    tags$div(
      style = "padding: 10px;",
      h5("AI Assistant Status"),
      conditionalPanel(
        condition = "output.api_key_required",
        tags$p(icon("circle", style = "color: #dc3545;"), " API Key Required",
               style = "color: #dc3545; margin: 0;")
      ),
      conditionalPanel(
        condition = "!output.api_key_required",
        tags$p(icon("circle", style = "color: #28a745;"), " Anthropic Ready",
               style = "color: #28a745; margin: 0;")
      )
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
      tags$style(HTML("
        .chat-message {
          margin-bottom: 15px;
          padding: 10px;
          border-radius: 8px;
        }
        .user-message {
          background-color: #e3f2fd;
          margin-left: 20%;
          text-align: right;
        }
        .ai-message {
          background-color: #f5f5f5;
          margin-right: 20%;
        }
        .message-header {
          font-weight: bold;
          margin-bottom: 5px;
          font-size: 0.9em;
        }
        .user-header {
          color: #1976d2;
        }
        .ai-header {
          color: #616161;
        }
      "))
    ),
    
    tabItems(
      # API Key Setup (shown when no API key found)
      tabItem(
        tabName = "api_setup",
        fluidRow(
          column(8, offset = 2,
            box(
              title = "Anthropic API Key Setup Required",
              width = 12,
              status = "warning",
              solidHeader = TRUE,
              
              div(
                style = "text-align: center; margin-bottom: 20px;",
                icon("exclamation-triangle", style = "font-size: 48px; color: #f39c12; margin-bottom: 10px;"),
                h3("API Key Required", style = "color: #f39c12;"),
                p("No Anthropic API key was found in your system environment.", 
                  style = "font-size: 16px; margin-bottom: 20px;"),
                p("Please upload a CSV file containing your Anthropic API key to proceed.",
                  style = "font-size: 14px; color: #666;")
              ),
              
              h4("Step 1: Upload CSV File with API Key"),
              fileInput("api_csv_file", 
                        "Choose CSV File containing your Anthropic API Key",
                        accept = c(".csv", ".txt"),
                        width = "100%"),
              
              conditionalPanel(
                condition = "output.csv_uploaded",
                div(
                  style = "margin-top: 20px; padding: 15px; background-color: #f8f9fa; border-radius: 8px;",
                  h5("Variables found in CSV:"),
                  verbatimTextOutput("csv_variables"),
                  
                  h5("Step 2: Select the variable containing your API key:"),
                  selectInput("api_key_variable",
                              "Choose variable:",
                              choices = NULL,
                              width = "100%"),
                  
                  conditionalPanel(
                    condition = "input.api_key_variable != ''",
                    div(
                      style = "margin-top: 15px;",
                      h6("Preview of selected variable (first few characters):"),
                      verbatimTextOutput("api_key_preview"),
                      
                      actionButton("confirm_api_key", 
                                   "Set API Key & Continue to Phase 1",
                                   class = "btn-success btn-lg",
                                   style = "margin-top: 15px; width: 100%;",
                                   icon = icon("check"))
                    )
                  )
                )
              )
            )
          )
        )
      ),
      
      # Phase 1: Hypothesis Formulation with Chat
      tabItem(
        tabName = "hypothesis",
        fluidRow(
          column(6,
            box(
              title = "Phase 1: Hypothesis Formulation",
              width = 12,
              status = "primary",
              solidHeader = TRUE,
              
              h4("Step 1: Upload Data"),
              fileInput("data_file", 
                        "Choose RDS File",
                        accept = ".rds"),
              
              verbatimTextOutput("data_summary"),
              
              tags$hr(),
              
              h4("Step 2: Initial Hypothesis"),
              textAreaInput("hypothesis_input",
                            "Enter your initial hypothesis:",
                            rows = 3,
                            placeholder = "Example: Treatment X will significantly reduce outcome Y compared to control"),
              
              radioButtons("hypothesis_type",
                           "Hypothesis Type:",
                           choices = list("Associational" = "associational",
                                          "Causal" = "causal")),
              
              conditionalPanel(
                condition = "input.hypothesis_type == 'causal'",
                h5("Causal Framework"),
                textAreaInput("causal_mechanism",
                              "Describe the causal mechanism:",
                              rows = 2)
              ),
              
              uiOutput("variable_selection"),
              
              actionButton("draft_hypothesis", 
                           "Draft Hypothesis for Discussion",
                           class = "btn-info",
                           icon = icon("comments"))
            )
          ),
          
          column(6,
            box(
              title = "Collaborative Hypothesis Refinement with Anthropic",
              width = 12,
              status = "info",
              solidHeader = TRUE,
              
              p("Discuss your hypothesis with Anthropic. As your thought partner, Anthropic will:",
              tags$ul(
                tags$li("Ask clarifying questions about your research goals"),
                tags$li("Challenge assumptions constructively"),
                tags$li("Suggest improvements to make your hypothesis more testable"),
                tags$li("Help identify potential confounders and limitations")
              )),
              
              chatUI("hypothesis_chat"),
              
              tags$hr(),
              
              wellPanel(
                h5("Refined Hypothesis"),
                verbatimTextOutput("refined_hypothesis"),
                actionButton("confirm_hypothesis", 
                             "Confirm Hypothesis & Proceed",
                             class = "btn-success",
                             icon = icon("check"))
              )
            )
          )
        )
      ),
      
      # Phase 2: Analytic Planning with Chat
      tabItem(
        tabName = "planning",
        fluidRow(
          column(6,
            box(
              title = "Phase 2: Analytic Planning",
              width = 12,
              status = "warning",
              solidHeader = TRUE,
              
              wellPanel(
                h5("Confirmed Hypothesis"),
                verbatimTextOutput("confirmed_hypothesis_display")
              ),
              
              h4("Power Analysis Parameters"),
              numericInput("alpha_level", "Significance Level (α):", 
                           value = 0.05, min = 0.01, max = 0.10, step = 0.01),
              numericInput("desired_power", "Desired Power:", 
                           value = 0.80, min = 0.70, max = 0.95, step = 0.05),
              
              verbatimTextOutput("sample_size_info"),
              verbatimTextOutput("mde_calculation"),
              
              h4("Statistical Test Selection"),
              selectInput("statistical_test",
                          "Preliminary test selection:",
                          choices = list(
                            "T-Test (Two groups)" = "t_test",
                            "ANOVA (Multiple groups)" = "anova",
                            "Linear Regression" = "lm",
                            "Logistic Regression" = "glm",
                            "Chi-Square Test" = "chisq"
                          )),
              
              actionButton("discuss_plan", 
                           "Discuss Analytic Plan",
                           class = "btn-warning",
                           icon = icon("comments"))
            )
          ),
          
          column(6,
            box(
              title = "Analytic Planning Discussion with Anthropic",
              width = 12,
              status = "warning",
              solidHeader = TRUE,
              
              p("Collaborate with Anthropic to develop your analytic plan. Topics include:",
              tags$ul(
                tags$li("Appropriateness of selected statistical test"),
                tags$li("Power analysis interpretation and implications"),
                tags$li("Literature benchmarks and expected effect sizes"),
                tags$li("Potential sensitivity analyses"),
                tags$li("Causal identification strategies (if applicable)")
              )),
              
              chatUI("planning_chat"),
              
              tags$hr(),
              
              wellPanel(
                h5("Final Analytic Plan"),
                verbatimTextOutput("analytic_plan_preview"),
                actionButton("confirm_plan", 
                             "Approve Plan & Generate Template",
                             class = "btn-warning",
                             icon = icon("check"))
              )
            )
          )
        )
      ),
      
      # Phase 3: Implementation with Chat Support
      tabItem(
        tabName = "implementation",
        fluidRow(
          column(6,
            box(
              title = "Phase 3: Implementation",
              width = 12,
              status = "info",
              solidHeader = TRUE,
              
              wellPanel(
                h5("Approved Analytic Plan"),
                verbatimTextOutput("approved_plan_display")
              ),
              
              h4("Generated Analysis Function"),
              verbatimTextOutput("generated_code"),
              
              actionButton("execute_analysis", 
                           "Execute Analysis",
                           class = "btn-info",
                           icon = icon("play")),
              
              tags$hr(),
              
              h4("Execution Results"),
              verbatimTextOutput("execution_status"),
              
              plotOutput("results_plot"),
              verbatimTextOutput("results_summary")
            )
          ),
          
          column(6,
            box(
              title = "Implementation Support with Anthropic",
              width = 12,
              status = "info",
              solidHeader = TRUE,
              
              p("Get help from Anthropic during implementation:",
              tags$ul(
                tags$li("Understanding the generated code"),
                tags$li("Troubleshooting errors"),
                tags$li("Interpreting preliminary results"),
                tags$li("Discussing unexpected findings"),
                tags$li("Planning additional analyses")
              )),
              
              chatUI("implementation_chat"),
              
              tags$hr(),
              
              actionButton("confirm_results", 
                           "Confirm Results & Proceed to Final Analysis",
                           class = "btn-info",
                           icon = icon("check"))
            )
          )
        )
      ),
      
      # Phase 4: Analysis and Interpretation with Chat
      tabItem(
        tabName = "analysis",
        fluidRow(
          column(8,
            box(
              title = "Phase 4: Analysis & Interpretation",
              width = 12,
              status = "success",
              solidHeader = TRUE,
              
              h4("Final Analysis Report"),
              uiOutput("final_report"),
              
              tags$hr(),
              
              h4("Export Options"),
              downloadButton("download_html", "Download HTML Report"),
              downloadButton("download_rmd", "Download R Markdown Source")
            )
          ),
          
          column(4,
            box(
              title = "Final Discussion with Anthropic",
              width = 12,
              status = "success",
              solidHeader = TRUE,
              
              p("Discuss your findings with Anthropic:",
              tags$ul(
                tags$li("Interpretation of results"),
                tags$li("Clinical/practical significance"),
                tags$li("Study limitations"),
                tags$li("Future research directions"),
                tags$li("Alternative explanations")
              )),
              
              chatUI("analysis_chat"),
              
              tags$div(
                class = "alert alert-success",
                style = "margin-top: 20px;",
                tags$strong("Analysis Complete!"),
                tags$p("Your collaborative scientific analysis is finished.")
              )
            )
          )
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive values to store state and chat history
  values <- reactiveValues(
    data = NULL,
    hypothesis = NULL,
    hypothesis_confirmed = FALSE,
    plan = NULL,
    plan_confirmed = FALSE,
    results = NULL,
    results_confirmed = FALSE,
    chat_history = list(
      hypothesis = list(),
      planning = list(),
      implementation = list(),
      analysis = list()
    ),
    refined_hypothesis = "",
    benchmarks = data.frame(
      Study = character(),
      Effect_Size = numeric(),
      CI_Lower = numeric(),
      CI_Upper = numeric(),
      Sample_Size = integer(),
      stringsAsFactors = FALSE
    ),
    api_key_found = FALSE,
    csv_data = NULL,
    api_key_set = FALSE
  )
  
  # Check for Anthropic API key on startup
  api_key_available <- reactive({
    # Check environment variables for common Anthropic API key names
    env_vars <- c("ANTHROPIC_API_KEY", "CLAUDE_API_KEY", "ANTHROPIC_KEY")
    api_found <- any(sapply(env_vars, function(x) nchar(Sys.getenv(x)) > 0))
    return(api_found || values$api_key_set)
  })
  
  # Control which tab is shown based on API key availability
  output$api_key_required <- reactive({
    !api_key_available()
  })
  outputOptions(output, "api_key_required", suspendWhenHidden = FALSE)
  
  # Redirect to appropriate tab on startup
  observe({
    if (!api_key_available()) {
      updateTabItems(session, "phases", "api_setup")
    } else {
      updateTabItems(session, "phases", "hypothesis")
    }
  })
  
  # Handle CSV file upload for API key
  observeEvent(input$api_csv_file, {
    req(input$api_csv_file)
    
    tryCatch({
      # Read the CSV file
      csv_path <- input$api_csv_file$datapath
      csv_data <- read.csv(csv_path, stringsAsFactors = FALSE)
      values$csv_data <- csv_data
      
      # Update variable choices
      var_names <- names(csv_data)
      updateSelectInput(session, "api_key_variable",
                        choices = c("Select variable..." = "", setNames(var_names, var_names)))
      
    }, error = function(e) {
      showNotification(paste("Error reading CSV file:", e$message), type = "error")
    })
  })
  
  # Show CSV variables
  output$csv_variables <- renderText({
    req(values$csv_data)
    var_info <- sapply(names(values$csv_data), function(var) {
      paste0(var, " (", class(values$csv_data[[var]])[1], ", ", nrow(values$csv_data), " rows)")
    })
    paste(var_info, collapse = "\n")
  })
  
  # Control CSV uploaded conditional panel
  output$csv_uploaded <- reactive({
    !is.null(values$csv_data)
  })
  outputOptions(output, "csv_uploaded", suspendWhenHidden = FALSE)
  
  # Show API key preview
  output$api_key_preview <- renderText({
    req(input$api_key_variable, values$csv_data)
    
    if (input$api_key_variable != "" && input$api_key_variable %in% names(values$csv_data)) {
      api_values <- values$csv_data[[input$api_key_variable]]
      # Show first non-empty value, truncated to first 20 characters
      first_val <- api_values[nchar(trimws(api_values)) > 0][1]
      if (!is.na(first_val)) {
        preview <- substr(trimws(first_val), 1, 20)
        if (nchar(trimws(first_val)) > 20) {
          paste0(preview, "...")
        } else {
          preview
        }
      } else {
        "No valid API key found in this variable"
      }
    }
  })
  
  # Confirm and set API key
  observeEvent(input$confirm_api_key, {
    req(input$api_key_variable, values$csv_data)
    
    if (input$api_key_variable != "" && input$api_key_variable %in% names(values$csv_data)) {
      api_values <- values$csv_data[[input$api_key_variable]]
      # Get first non-empty value
      api_key <- trimws(api_values[nchar(trimws(api_values)) > 0][1])
      
      if (!is.na(api_key) && nchar(api_key) > 10) {  # Basic validation
        # Set the API key in environment
        Sys.setenv("ANTHROPIC_API_KEY" = api_key)
        values$api_key_set <- TRUE
        
        showNotification("API Key set successfully! Redirecting to Phase 1...", type = "message")
        
        # Redirect to hypothesis tab
        updateTabItems(session, "phases", "hypothesis")
        
      } else {
        showNotification("Invalid API key. Please check the selected variable.", type = "error")
      }
    }
  })
  
  # Progress indicators
  output$progress_indicators <- renderUI({
    tags$div(
      tags$p(icon("check-circle", class = if(values$hypothesis_confirmed) "text-success" else "text-muted"), 
             " Hypothesis", 
             class = if(values$hypothesis_confirmed) "text-success" else "text-muted"),
      tags$p(icon("check-circle", class = if(values$plan_confirmed) "text-success" else "text-muted"), 
             " Planning",
             class = if(values$plan_confirmed) "text-success" else "text-muted"),
      tags$p(icon("check-circle", class = if(values$results_confirmed) "text-success" else "text-muted"), 
             " Implementation",
             class = if(values$results_confirmed) "text-success" else "text-muted"),
      tags$p(icon("check-circle", class = if(!is.null(values$final_report)) "text-success" else "text-muted"), 
             " Analysis",
             class = if(!is.null(values$final_report)) "text-success" else "text-muted")
    )
  })
  
  # Chat server module
  chatServer <- function(id, phase) {
    moduleServer(id, function(input, output, session) {
      
      # Display chat history
      output$chat_history <- renderUI({
        messages <- values$chat_history[[phase]]
        
        if (length(messages) == 0) {
          return(tags$p("Start the conversation by typing your question below.", 
                        style = "color: #666; font-style: italic;"))
        }
        
        tags$div(
          lapply(messages, function(msg) {
            tags$div(
              class = paste("chat-message", if(msg$sender == "user") "user-message" else "ai-message"),
              tags$div(
                class = paste("message-header", if(msg$sender == "user") "user-header" else "ai-header"),
                if(msg$sender == "user") "You" else "Anthropic"
              ),
              tags$div(msg$content)
            )
          })
        )
      })
      
      # Send message
      observeEvent(input$send_message, {
        req(input$user_input)
        
        # Add user message to history
        user_msg <- list(sender = "user", content = input$user_input)
        values$chat_history[[phase]] <- append(values$chat_history[[phase]], list(user_msg))
        
        # Generate AI response based on phase and context
        ai_response <- generate_ai_response(phase, input$user_input, values)
        
        # Add AI response to history
        ai_msg <- list(sender = "ai", content = ai_response)
        values$chat_history[[phase]] <- append(values$chat_history[[phase]], list(ai_msg))
        
        # Clear input
        updateTextAreaInput(session, "user_input", value = "")
        
        # Scroll to bottom
        session$sendCustomMessage(type = "scrollChat", message = list(id = paste0(id, "-chat-container")))
      })
    })
  }
  
  # Initialize chat modules for each phase
  chatServer("hypothesis_chat", "hypothesis")
  chatServer("planning_chat", "planning")
  chatServer("implementation_chat", "implementation")
  chatServer("analysis_chat", "analysis")
  
  # Source phase-specific logic
  source("R/phase1_hypothesis_chat.R", local = TRUE)
  source("R/phase2_planning_chat.R", local = TRUE)
  source("R/phase3_implementation_chat.R", local = TRUE)
  source("R/phase4_analysis_chat.R", local = TRUE)
  source("R/ai_responses.R", local = TRUE)
}

# Run the application
shinyApp(ui = ui, server = server)