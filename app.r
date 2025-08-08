# Scientific Methods Engine - Chat-Enhanced Version
# Collaborative AI-powered hypothesis testing with Anthropic as thought partner

library(shiny)
library(shinydashboard)
library(DT)
library(tidyverse)
library(jsonlite)
library(knitr)
library(rmarkdown)
library(httr)

# Source enhanced functionality
source("R/perplexity_integration.R")
source("R/enhanced_chat_functions.R") 
source("R/phase_specific_searches.R")
source("R/api_testing.R")

# Define chat UI component
chatUI <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      id = ns("chat-container"),
      uiOutput(ns("chat_history"))
    ),
    tags$div(
      class = "chat-input-container",
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
  dashboardHeader(
    title = "Scientific Methods Engine - AI Collaborative",
    tags$li(
      class = "dropdown",
      tags$div(
        class = "theme-toggle",
        id = "theme-toggle",
        onclick = "toggleTheme()",
        tags$span(class = "theme-toggle-icon sun", "☀️"),
        tags$span(class = "theme-toggle-text", "Light"),
        tags$span(class = "theme-toggle-icon moon", "🌙")
      )
    )
  ),
  
  dashboardSidebar(
    sidebarMenu(
      id = "phases",
      conditionalPanel(
        condition = "output.anthropic_key_required",
        menuItem("Anthropic API Setup", tabName = "anthropic_setup", icon = icon("key"))
      ),
      conditionalPanel(
        condition = "output.perplexity_key_required && !output.anthropic_key_required",
        menuItem("Perplexity API Setup", tabName = "perplexity_setup", icon = icon("search"))
      ),
      conditionalPanel(
        condition = "!output.anthropic_key_required && !output.perplexity_key_required",
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
        condition = "output.anthropic_key_required",
        tags$p(icon("circle", style = "color: #dc3545;"), " Anthropic Key Required",
               style = "color: #dc3545; margin: 0; font-size: 0.9em;")
      ),
      conditionalPanel(
        condition = "output.perplexity_key_required && !output.anthropic_key_required",
        tags$p(icon("circle", style = "color: #ffc107;"), " Perplexity Key Required",
               style = "color: #856404; margin: 0; font-size: 0.9em;")
      ),
      conditionalPanel(
        condition = "!output.anthropic_key_required && !output.perplexity_key_required",
        tags$div(
          uiOutput("api_status_display"),
          tags$br(),
          
          # Model Selection Controls
          tags$div(
            style = "margin-bottom: 15px;",
            h6("Model Selection", style = "margin-bottom: 8px; color: #495057;"),
            
            # Anthropic Model Selection
            tags$div(
              style = "margin-bottom: 8px;",
              tags$label("Anthropic Model:", style = "font-size: 0.85em; color: #6c757d; display: block; margin-bottom: 2px;"),
              selectInput("anthropic_model", 
                          label = NULL,
                          choices = list(
                            "Claude 3.5 Sonnet (Latest)" = "claude-3-5-sonnet-20241022",
                            "Claude 3.5 Sonnet (June)" = "claude-3-5-sonnet-20240620",
                            "Claude 3.5 Haiku" = "claude-3-5-haiku-20241022",
                            "Claude 3 Opus" = "claude-3-opus-20240229",
                            "Claude 3 Sonnet" = "claude-3-sonnet-20240229",
                            "Claude 3 Haiku" = "claude-3-haiku-20240307"
                          ),
                          selected = "claude-3-5-sonnet-20241022",
                          width = "100%")
            ),
            
            # Perplexity Model Selection
            conditionalPanel(
              condition = "!output.perplexity_key_required",
              tags$div(
                style = "margin-bottom: 8px;",
                tags$label("Perplexity Model:", style = "font-size: 0.85em; color: #6c757d; display: block; margin-bottom: 2px;"),
                selectInput("perplexity_model", 
                            label = NULL,
                            choices = list(
                              "Sonar Pro (Flagship)" = "sonar-pro",
                              "Sonar (Standard)" = "sonar",
                              "Sonar Reasoning" = "sonar-reasoning"
                            ),
                            selected = "sonar-pro",
                            width = "100%")
              )
            )
          ),
          
          actionButton("test_apis", "Test Connections", 
                       class = "btn btn-sm btn-outline-info",
                       icon = icon("wifi"))
        )
      ),
      conditionalPanel(
        condition = "!output.anthropic_key_required && output.perplexity_key_required",
        tags$div(
          tags$p(icon("check-circle", style = "color: #28a745;"), " Anthropic Ready",
                 style = "color: #28a745; margin: 0; font-size: 0.9em;"),
          tags$p(icon("exclamation-triangle", style = "color: #ffc107;"), " Basic Mode Only",
                 style = "color: #856404; margin: 0; font-size: 0.9em;")
        )
      )
    )
  ),
  
  dashboardBody(
    # CSS includes at the top
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
    includeCSS("www/styles.css"),
    
    # Apply Refined Autumn Theme
    tags$style(HTML("
      :root {
        /* Your Original 5 Colors */
        --autumn-cream: #fdf6f2;    /* 253,246,242 - lightest */
        --autumn-blue: #c0d8e3;     /* 192,216,227 - muted blue-gray */
        --autumn-rose: #a78d8a;     /* 167,141,138 - dusty rose */
        --autumn-coral: #e18a7a;    /* 225,138,122 - coral */
        --autumn-peach: #eeb9a2;    /* 238,185,162 - light peach */
        
        /* Dark versions for proper contrast */
        --autumn-dark: #3d2f2e;     /* 60% darker than dusty rose */
        --autumn-darker: #2a1f1e;   /* 80% darker than dusty rose */
        
        /* Light Theme Variables */
        --bg-primary: var(--autumn-cream);
        --bg-secondary: rgba(192, 216, 227, 0.4);
        --bg-card: var(--autumn-cream);
        --text-primary: var(--autumn-dark);
        --text-secondary: var(--autumn-rose);
        --accent-primary: var(--autumn-coral);
        --accent-secondary: var(--autumn-peach);
        --border-color: rgba(167, 141, 138, 0.3);
        --shadow-color: rgba(167, 141, 138, 0.2);
      }
      
      body {
        background-color: var(--bg-primary) !important;
        color: var(--text-primary) !important;
        transition: all 0.3s ease !important;
      }
      
      .main-header .navbar {
        background-color: var(--bg-card) !important;
        border-bottom: 2px solid var(--accent-primary) !important;
      }
      
      .content-wrapper {
        background-color: var(--bg-primary) !important;
      }
      
      .main-sidebar {
        background-color: var(--bg-secondary) !important;
      }
      
      .skin-blue .main-header .navbar {
        background-color: var(--bg-card) !important;
      }
      
      .theme-toggle {
        background-color: var(--accent-primary) !important;
        color: white !important;
        border: none !important;
        border-radius: 25px !important;
        padding: 8px 16px !important;
        margin-right: 10px !important;
        cursor: pointer !important;
        transition: all 0.3s ease !important;
      }
      
      .theme-toggle:hover {
        transform: translateY(-1px) !important;
        box-shadow: 0 4px 12px var(--shadow-color) !important;
      }
      
      /* Dark Theme - Using your original colors as accents */
      [data-theme='dark'] {
        --bg-primary: var(--autumn-darker);        /* Very dark brown background */
        --bg-secondary: rgba(61, 47, 46, 0.6);     /* Dark brown panels */
        --bg-card: var(--autumn-dark);             /* Dark brown cards */
        --text-primary: var(--autumn-cream);       /* Your cream for text */
        --text-secondary: var(--autumn-blue);      /* Your blue-gray for secondary text */
        --accent-primary: var(--autumn-coral);     /* Your coral (unchanged) */
        --accent-secondary: var(--autumn-peach);   /* Your peach (unchanged) */
        --border-color: rgba(167, 141, 138, 0.4);  /* Your dusty rose for borders */
        --shadow-color: rgba(0, 0, 0, 0.4);        /* Darker shadows */
      }
      
      /* Ensure smooth transitions */
      * {
        transition: background-color 0.3s ease, color 0.3s ease, border-color 0.3s ease !important;
      }
    ")),
    
    tabItems(
      # Anthropic API Key Setup (shown when no Anthropic API key found)
      tabItem(
        tabName = "anthropic_setup",
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
      
      # Perplexity API Key Setup (shown when Anthropic is available but Perplexity is missing)
      tabItem(
        tabName = "perplexity_setup",
        fluidRow(
          column(8, offset = 2,
            box(
              title = "Perplexity API Key Setup Required for Literature Integration",
              width = 12,
              status = "warning",
              solidHeader = TRUE,
              
              div(
                style = "text-align: center; margin-bottom: 20px;",
                icon("search", style = "font-size: 48px; color: #ffc107; margin-bottom: 10px;"),
                h3("Literature Integration Available", style = "color: #856404;"),
                p("Anthropic API is configured, but Perplexity API is needed for literature-enhanced responses.", 
                  style = "font-size: 16px; margin-bottom: 15px;"),
                p("Without Perplexity, you'll have basic AI collaboration. With it, every response will be grounded in current research literature.",
                  style = "font-size: 14px; color: #666; margin-bottom: 20px;"),
                div(
                  style = "background-color: #fff3cd; padding: 15px; border-radius: 5px; margin-bottom: 15px; border-left: 4px solid #ffc107;",
                  tags$strong("Benefits of Literature Integration:"),
                  tags$ul(
                    style = "text-align: left; margin-top: 10px;",
                    tags$li("AI responses include specific citations from recent studies"),
                    tags$li("Effect sizes and findings from meta-analyses"),
                    tags$li("Methodological guidance based on published research"),
                    tags$li("Evidence-based challenge to research assumptions")
                  )
                )
              ),
              
              h4("Setup Options:"),
              
              tabsetPanel(
                tabPanel("Option 1: Add to CSV",
                  div(style = "margin-top: 15px;",
                    p("Add your Perplexity API key to the same CSV file used for Anthropic:"),
                    tags$ol(
                      tags$li("Open your CSV file containing the Anthropic API key"),
                      tags$li("Add a new column named 'PERPLEXITY_API_KEY'"),
                      tags$li("Enter your Perplexity API key in this column"),
                      tags$li("Re-upload the CSV file below")
                    ),
                    
                    fileInput("perplexity_csv_file", 
                              "Choose Updated CSV File",
                              accept = c(".csv", ".txt"),
                              width = "100%"),
                    
                    conditionalPanel(
                      condition = "output.perplexity_csv_uploaded",
                      div(
                        style = "margin-top: 20px; padding: 15px; background-color: #f8f9fa; border-radius: 8px;",
                        h5("Variables found in CSV:"),
                        verbatimTextOutput("perplexity_csv_variables"),
                        
                        h5("Step 2: Select the variable containing your Perplexity API key:"),
                        selectInput("perplexity_key_variable",
                                    "Choose variable:",
                                    choices = NULL,
                                    width = "100%"),
                        
                        conditionalPanel(
                          condition = "input.perplexity_key_variable != ''",
                          div(
                            style = "margin-top: 15px;",
                            h6("Preview of selected variable (first few characters):"),
                            verbatimTextOutput("perplexity_key_preview"),
                            
                            actionButton("confirm_perplexity_key", 
                                         "Set Perplexity Key & Enable Literature Integration",
                                         class = "btn-success btn-lg",
                                         style = "margin-top: 15px; width: 100%;",
                                         icon = icon("check"))
                          )
                        )
                      )
                    )
                  )
                ),
                
                tabPanel("Option 2: Skip for Now",
                  div(style = "margin-top: 15px;",
                    div(
                      style = "background-color: #d1ecf1; padding: 15px; border-radius: 5px; border-left: 4px solid #bee5eb;",
                      tags$strong("Continue with Basic Mode"),
                      p("You can proceed without Perplexity API key, but responses will be based on AI training knowledge only (no current literature integration).", 
                        style = "margin-top: 10px; margin-bottom: 0;")
                    ),
                    
                    actionButton("skip_perplexity", 
                                 "Continue with Basic AI Collaboration",
                                 class = "btn-info btn-lg",
                                 style = "margin-top: 20px; width: 100%;",
                                 icon = icon("arrow-right")),
                    
                    p("You can add the Perplexity API key later by restarting the application with the PERPLEXITY_API_KEY environment variable.",
                      style = "margin-top: 15px; font-size: 0.9em; color: #666; text-align: center;")
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
          column(3,
            box(
              title = "Phase 1: Hypothesis Formulation",
              width = 12,
              status = "primary",
              solidHeader = TRUE,
              collapsible = TRUE,
              collapsed = FALSE,
              
              h4("Step 1: Upload Data"),
              fileInput("data_file", 
                        "Choose RDS File",
                        accept = ".rds"),
              
              conditionalPanel(
                condition = "output.data_uploaded",
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
            )
          ),
          
          column(9,
            box(
              title = uiOutput("hypothesis_collaboration_title"),
              width = 12,
              status = "info",
              solidHeader = TRUE,
              
              uiOutput("hypothesis_collaboration_description"),
              
              chatUI("hypothesis_chat"),
              
              # Evidence Base Panel
              tags$div(
                style = "margin-top: 15px;",
                tags$button(
                  "Evidence Base", 
                  type = "button", 
                  class = "btn btn-outline-info btn-sm", 
                  `data-toggle` = "collapse", 
                  `data-target` = "#evidence-panel-hypothesis",
                  tags$i(class = "fa fa-book", style = "margin-right: 5px;")
                ),
                tags$div(
                  id = "evidence-panel-hypothesis",
                  class = "collapse",
                  style = "margin-top: 10px; padding: 10px; background-color: #f8f9fa; border-radius: 5px; border-left: 3px solid #17a2b8;",
                  tags$h6("Literature Searches Performed:", style = "color: #17a2b8; font-weight: bold;"),
                  uiOutput("hypothesis_literature_summary"),
                  tags$h6("Key Citations:", style = "color: #17a2b8; font-weight: bold; margin-top: 10px;"),
                  uiOutput("hypothesis_citations")
                )
              ),
              
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
          column(3,
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
          
          column(9,
            box(
              title = uiOutput("planning_collaboration_title"),
              width = 12,
              status = "warning",
              solidHeader = TRUE,
              
              uiOutput("planning_collaboration_description"),
              
              chatUI("planning_chat"),
              
              # Evidence Base Panel for Planning
              tags$div(
                style = "margin-top: 15px;",
                tags$button(
                  "Evidence Base", 
                  type = "button", 
                  class = "btn btn-outline-warning btn-sm", 
                  `data-toggle` = "collapse", 
                  `data-target` = "#evidence-panel-planning",
                  tags$i(class = "fa fa-book", style = "margin-right: 5px;")
                ),
                tags$div(
                  id = "evidence-panel-planning",
                  class = "collapse",
                  style = "margin-top: 10px; padding: 10px; background-color: #f8f9fa; border-radius: 5px; border-left: 3px solid #ffc107;",
                  tags$h6("Literature Searches Performed:", style = "color: #856404; font-weight: bold;"),
                  uiOutput("planning_literature_summary"),
                  tags$h6("Key Citations:", style = "color: #856404; font-weight: bold; margin-top: 10px;"),
                  uiOutput("planning_citations")
                )
              ),
              
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
          column(3,
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
          
          column(9,
            box(
              title = uiOutput("implementation_collaboration_title"),
              width = 12,
              status = "info",
              solidHeader = TRUE,
              
              uiOutput("implementation_collaboration_description"),
              
              chatUI("implementation_chat"),
              
              # Evidence Base Panel for Implementation
              tags$div(
                style = "margin-top: 15px;",
                tags$button(
                  "Evidence Base", 
                  type = "button", 
                  class = "btn btn-outline-info btn-sm", 
                  `data-toggle` = "collapse", 
                  `data-target` = "#evidence-panel-implementation",
                  tags$i(class = "fa fa-book", style = "margin-right: 5px;")
                ),
                tags$div(
                  id = "evidence-panel-implementation",
                  class = "collapse",
                  style = "margin-top: 10px; padding: 10px; background-color: #f8f9fa; border-radius: 5px; border-left: 3px solid #17a2b8;",
                  tags$h6("Literature Searches Performed:", style = "color: #17a2b8; font-weight: bold;"),
                  uiOutput("implementation_literature_summary"),
                  tags$h6("Key Citations:", style = "color: #17a2b8; font-weight: bold; margin-top: 10px;"),
                  uiOutput("implementation_citations")
                )
              ),
              
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
              title = uiOutput("analysis_collaboration_title"),
              width = 12,
              status = "success",
              solidHeader = TRUE,
              
              uiOutput("analysis_collaboration_description"),
              
              chatUI("analysis_chat"),
              
              # Evidence Base Panel for Analysis
              tags$div(
                style = "margin-top: 15px;",
                tags$button(
                  "Evidence Base", 
                  type = "button", 
                  class = "btn btn-outline-success btn-sm", 
                  `data-toggle` = "collapse", 
                  `data-target` = "#evidence-panel-analysis",
                  tags$i(class = "fa fa-book", style = "margin-right: 5px;")
                ),
                tags$div(
                  id = "evidence-panel-analysis",
                  class = "collapse",
                  style = "margin-top: 10px; padding: 10px; background-color: #f8f9fa; border-radius: 5px; border-left: 3px solid #28a745;",
                  tags$h6("Literature Searches Performed:", style = "color: #155724; font-weight: bold;"),
                  uiOutput("analysis_literature_summary"),
                  tags$h6("Key Citations:", style = "color: #155724; font-weight: bold; margin-top: 10px;"),
                  uiOutput("analysis_citations")
                )
              ),
              
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
    ),
    
    # Theme Toggle JavaScript
    tags$script(HTML("
      // Theme management
      function getTheme() {
        return localStorage.getItem('theme') || 'light';
      }
      
      function setTheme(theme) {
        localStorage.setItem('theme', theme);
        document.documentElement.setAttribute('data-theme', theme);
        updateThemeToggle(theme);
      }
      
      function toggleTheme() {
        const currentTheme = getTheme();
        const newTheme = currentTheme === 'light' ? 'dark' : 'light';
        setTheme(newTheme);
      }
      
      function updateThemeToggle(theme) {
        const toggleText = document.querySelector('.theme-toggle-text');
        if (toggleText) {
          toggleText.textContent = theme.charAt(0).toUpperCase() + theme.slice(1);
        }
      }
      
      // Initialize theme on page load
      document.addEventListener('DOMContentLoaded', function() {
        const savedTheme = getTheme();
        setTheme(savedTheme);
      });
      
      // Apply theme immediately
      const initialTheme = localStorage.getItem('theme') || 'light';
      document.documentElement.setAttribute('data-theme', initialTheme);
    "))
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
    literature_results = list(
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
    perplexity_csv_data = NULL,
    api_key_set = FALSE,
    perplexity_key_set = FALSE,
    perplexity_enabled = FALSE,
    skip_perplexity = FALSE,
    selected_anthropic_model = "claude-3-5-sonnet-20241022",
    selected_perplexity_model = "sonar-pro"
  )
  
  # Check for Anthropic API key availability
  anthropic_key_available <- reactive({
    env_vars <- c("ANTHROPIC_API_KEY", "CLAUDE_API_KEY", "ANTHROPIC_KEY")
    api_found <- any(sapply(env_vars, function(x) nchar(Sys.getenv(x)) > 0))
    return(api_found || values$api_key_set)
  })
  
  # Check for Perplexity API key availability
  perplexity_key_available <- reactive({
    perplexity_found <- nchar(Sys.getenv("PERPLEXITY_API_KEY")) > 0
    return(perplexity_found || values$perplexity_key_set)
  })
  
  # Control which tab is shown based on API key availability
  output$anthropic_key_required <- reactive({
    !anthropic_key_available()
  })
  outputOptions(output, "anthropic_key_required", suspendWhenHidden = FALSE)
  
  output$perplexity_key_required <- reactive({
    !perplexity_key_available() && !values$skip_perplexity
  })
  outputOptions(output, "perplexity_key_required", suspendWhenHidden = FALSE)
  
  # Control data upload UI visibility
  output$data_uploaded <- reactive({
    !is.null(values$data)
  })
  outputOptions(output, "data_uploaded", suspendWhenHidden = FALSE)
  
  # Redirect to appropriate tab on startup
  observe({
    if (!anthropic_key_available()) {
      updateTabItems(session, "phases", "anthropic_setup")
    } else if (!perplexity_key_available() && !values$skip_perplexity) {
      updateTabItems(session, "phases", "perplexity_setup")
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
        
        showNotification("Anthropic API Key set successfully!", type = "message")
        
        # Redirect to appropriate next step
        if (!perplexity_key_available() && !values$skip_perplexity) {
          updateTabItems(session, "phases", "perplexity_setup")
        } else {
          updateTabItems(session, "phases", "hypothesis")
        }
        
      } else {
        showNotification("Invalid API key. Please check the selected variable.", type = "error")
      }
    }
  })
  
  # Handle CSV file upload for Perplexity API key
  observeEvent(input$perplexity_csv_file, {
    req(input$perplexity_csv_file)
    
    tryCatch({
      # Read the CSV file
      csv_path <- input$perplexity_csv_file$datapath
      csv_data <- read.csv(csv_path, stringsAsFactors = FALSE)
      values$perplexity_csv_data <- csv_data
      
      # Update variable choices
      var_names <- names(csv_data)
      updateSelectInput(session, "perplexity_key_variable",
                        choices = c("Select variable..." = "", setNames(var_names, var_names)))
      
    }, error = function(e) {
      showNotification(paste("Error reading CSV file:", e$message), type = "error")
    })
  })
  
  # Show Perplexity CSV variables
  output$perplexity_csv_variables <- renderText({
    req(values$perplexity_csv_data)
    var_info <- sapply(names(values$perplexity_csv_data), function(var) {
      paste0(var, " (", class(values$perplexity_csv_data[[var]])[1], ", ", nrow(values$perplexity_csv_data), " rows)")
    })
    paste(var_info, collapse = "\n")
  })
  
  # Control Perplexity CSV uploaded conditional panel
  output$perplexity_csv_uploaded <- reactive({
    !is.null(values$perplexity_csv_data)
  })
  outputOptions(output, "perplexity_csv_uploaded", suspendWhenHidden = FALSE)
  
  # Show Perplexity API key preview
  output$perplexity_key_preview <- renderText({
    req(input$perplexity_key_variable, values$perplexity_csv_data)
    
    if (input$perplexity_key_variable != "" && input$perplexity_key_variable %in% names(values$perplexity_csv_data)) {
      api_values <- values$perplexity_csv_data[[input$perplexity_key_variable]]
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
  
  # Confirm and set Perplexity API key
  observeEvent(input$confirm_perplexity_key, {
    req(input$perplexity_key_variable, values$perplexity_csv_data)
    
    if (input$perplexity_key_variable != "" && input$perplexity_key_variable %in% names(values$perplexity_csv_data)) {
      api_values <- values$perplexity_csv_data[[input$perplexity_key_variable]]
      # Get first non-empty value
      api_key <- trimws(api_values[nchar(trimws(api_values)) > 0][1])
      
      if (!is.na(api_key) && nchar(api_key) > 10) {  # Basic validation
        # Set the API key in environment
        Sys.setenv("PERPLEXITY_API_KEY" = api_key)
        values$perplexity_key_set <- TRUE
        
        showNotification("Perplexity API Key set successfully! Literature integration enabled.", type = "message")
        
        # Redirect to hypothesis phase
        updateTabItems(session, "phases", "hypothesis")
        
      } else {
        showNotification("Invalid Perplexity API key. Please check the selected variable.", type = "error")
      }
    }
  })
  
  # Skip Perplexity setup
  observeEvent(input$skip_perplexity, {
    values$skip_perplexity <- TRUE
    showNotification("Proceeding with basic AI collaboration (no literature integration).", type = "message")
    updateTabItems(session, "phases", "hypothesis")
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
  
  # Dynamic collaboration titles and descriptions based on literature integration status
  output$hypothesis_collaboration_title <- renderUI({
    if (values$perplexity_enabled) {
      h4("Evidence-Based Collaborative Refinement with Anthropic", style = "margin: 0;")
    } else {
      h4("Collaborative Hypothesis Refinement with Anthropic", style = "margin: 0;")
    }
  })
  
  output$hypothesis_collaboration_description <- renderUI({
    if (values$perplexity_enabled) {
      p("Discuss your hypothesis with Anthropic, now enhanced with current literature. Your AI collaborator will:",
        tags$ul(
          tags$li("Challenge assumptions with specific citations from recent studies"),
          tags$li("Provide effect sizes from meta-analyses and systematic reviews"),
          tags$li("Suggest methodological improvements based on published research"),
          tags$li("Identify gaps in current knowledge and contradictory findings")
        )
      )
    } else {
      div(
        div(
          style = "background-color: #fff3cd; padding: 10px; border-radius: 5px; border-left: 3px solid #ffc107; margin-bottom: 15px;",
          tags$strong("Basic Mode Active"), 
          p("Literature integration is not available. Responses are based on AI training knowledge only.", 
            style = "margin: 5px 0 0 0; font-size: 0.9em;")
        ),
        p("Discuss your hypothesis with Anthropic. As your thought partner, Anthropic will:",
          tags$ul(
            tags$li("Ask clarifying questions about your research goals"),
            tags$li("Challenge assumptions constructively"),
            tags$li("Suggest improvements to make your hypothesis more testable"),
            tags$li("Help identify potential confounders and limitations")
          )
        )
      )
    }
  })
  
  output$planning_collaboration_title <- renderUI({
    if (values$perplexity_enabled) {
      h4("Literature-Enhanced Analytic Planning with Anthropic", style = "margin: 0;")
    } else {
      h4("Analytic Planning Discussion with Anthropic", style = "margin: 0;")
    }
  })
  
  output$planning_collaboration_description <- renderUI({
    if (values$perplexity_enabled) {
      p("Collaborate with Anthropic to develop your analytic plan, grounded in current literature:",
        tags$ul(
          tags$li("Literature-benchmarked effect sizes and power analysis"),
          tags$li("Evidence-based statistical test selection and validation"),
          tags$li("Methodological recommendations from recent studies"),
          tags$li("Sensitivity analyses based on published best practices")
        )
      )
    } else {
      div(
        div(
          style = "background-color: #fff3cd; padding: 10px; border-radius: 5px; border-left: 3px solid #ffc107; margin-bottom: 15px;",
          tags$strong("Basic Mode Active"), 
          p("Literature integration unavailable. Using general methodological knowledge.", 
            style = "margin: 5px 0 0 0; font-size: 0.9em;")
        ),
        p("Collaborate with Anthropic to develop your analytic plan:",
          tags$ul(
            tags$li("Appropriateness of selected statistical test"),
            tags$li("Power analysis interpretation and implications"),
            tags$li("General effect size considerations"),
            tags$li("Potential sensitivity analyses")
          )
        )
      )
    }
  })
  
  output$implementation_collaboration_title <- renderUI({
    if (values$perplexity_enabled) {
      h4("Research-Informed Implementation Support", style = "margin: 0;")
    } else {
      h4("Implementation Support with Anthropic", style = "margin: 0;")
    }
  })
  
  output$implementation_collaboration_description <- renderUI({
    if (values$perplexity_enabled) {
      p("Get research-informed help during implementation:",
        tags$ul(
          tags$li("Best practices from methodological literature"),
          tags$li("Evidence-based diagnostic and troubleshooting guidance"),
          tags$li("Literature-contextualized result interpretation"),
          tags$li("Research-grounded discussion of unexpected findings")
        )
      )
    } else {
      div(
        div(
          style = "background-color: #fff3cd; padding: 10px; border-radius: 5px; border-left: 3px solid #ffc107; margin-bottom: 15px;",
          tags$strong("Basic Mode Active"), 
          p("General implementation support without literature integration.", 
            style = "margin: 5px 0 0 0; font-size: 0.9em;")
        ),
        p("Get help from Anthropic during implementation:",
          tags$ul(
            tags$li("Understanding the generated code"),
            tags$li("Troubleshooting errors"),
            tags$li("Interpreting preliminary results"),
            tags$li("Discussing unexpected findings")
          )
        )
      )
    }
  })
  
  output$analysis_collaboration_title <- renderUI({
    if (values$perplexity_enabled) {
      h4("Evidence-Based Results Discussion", style = "margin: 0;")
    } else {
      h4("Final Discussion with Anthropic", style = "margin: 0;")
    }
  })
  
  output$analysis_collaboration_description <- renderUI({
    if (values$perplexity_enabled) {
      p("Discuss your findings with literature-enhanced Anthropic:",
        tags$ul(
          tags$li("Results interpretation grounded in recent studies"),
          tags$li("Literature-benchmarked clinical/practical significance"),
          tags$li("Evidence-based discussion of limitations"),
          tags$li("Research-informed future directions"),
          tags$li("Alternative explanations from published research")
        )
      )
    } else {
      div(
        div(
          style = "background-color: #fff3cd; padding: 10px; border-radius: 5px; border-left: 3px solid #ffc107; margin-bottom: 15px;",
          tags$strong("Basic Mode Active"), 
          p("General interpretation guidance without literature context.", 
            style = "margin: 5px 0 0 0; font-size: 0.9em;")
        ),
        p("Discuss your findings with Anthropic:",
          tags$ul(
            tags$li("Interpretation of results"),
            tags$li("Clinical/practical significance"),
            tags$li("Study limitations"),
            tags$li("Future research directions")
          )
        )
      )
    }
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
        ai_response <- generate_ai_response(phase, input$user_input, values, 
                                          anthropic_model = values$selected_anthropic_model,
                                          perplexity_model = values$selected_perplexity_model)
        
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
  
  # Check for Perplexity API integration
  observe({
    perplexity_key <- perplexity_key_available()
    anthropic_key <- anthropic_key_available()
    values$perplexity_enabled <- perplexity_key && anthropic_key && !values$skip_perplexity
  })
  
  # API Status Testing
  values$api_test_results <- reactiveVal(NULL)
  
  # Observe model selection changes
  observeEvent(input$anthropic_model, {
    req(input$anthropic_model)
    values$selected_anthropic_model <- input$anthropic_model
    showNotification(paste("Anthropic model changed to:", 
                          names(which(sapply(c("Claude 3.5 Sonnet (Latest)" = "claude-3-5-sonnet-20241022",
                                               "Claude 3.5 Sonnet (June)" = "claude-3-5-sonnet-20240620",
                                               "Claude 3.5 Haiku" = "claude-3-5-haiku-20241022",
                                               "Claude 3 Opus" = "claude-3-opus-20240229",
                                               "Claude 3 Sonnet" = "claude-3-sonnet-20240229",
                                               "Claude 3 Haiku" = "claude-3-haiku-20240307"), 
                                             function(x) x == input$anthropic_model))[1])), 
                   type = "message", duration = 3)
  })
  
  observeEvent(input$perplexity_model, {
    req(input$perplexity_model)
    values$selected_perplexity_model <- input$perplexity_model
    showNotification(paste("Perplexity model changed to:", 
                          names(which(sapply(c("Sonar Pro (Flagship)" = "sonar-pro",
                                               "Sonar (Standard)" = "sonar",
                                               "Sonar Reasoning" = "sonar-reasoning"), 
                                             function(x) x == input$perplexity_model))[1])), 
                   type = "message", duration = 3)
  })

  # Test APIs when button is clicked
  observeEvent(input$test_apis, {
    showNotification("Testing API connections...", type = "message", duration = 2)
    
    # Run tests synchronously with selected models
    test_results <- test_all_apis(
      anthropic_model = values$selected_anthropic_model,
      perplexity_model = values$selected_perplexity_model
    )
    values$api_test_results(test_results)
    
    if (test_results$literature_enabled) {
      showNotification("✅ All APIs working! Literature integration active.", type = "message")
    } else {
      failed_apis <- c()
      if (!test_results$anthropic$success) failed_apis <- c(failed_apis, "Anthropic")
      if (!test_results$perplexity$success) failed_apis <- c(failed_apis, "Perplexity")
      showNotification(paste("❌", paste(failed_apis, collapse = " and "), "API(s) failed"), type = "warning")
    }
  })
  
  # Initial API test on startup (delayed)
  observe({
    if (anthropic_key_available()) {
      # Wait a bit before testing on startup
      invalidateLater(3000, session)  # 3 seconds
      if (is.null(values$api_test_results())) {
        test_results <- test_all_apis(
          anthropic_model = values$selected_anthropic_model,
          perplexity_model = values$selected_perplexity_model
        )
        values$api_test_results(test_results)
      }
    }
  })
  
  # Display API status
  output$api_status_display <- renderUI({
    test_results <- values$api_test_results()
    
    if (is.null(test_results)) {
      return(tags$div(
        tags$p(icon("clock"), " Testing connections...", 
               style = "color: #666; margin: 0; font-size: 0.9em;")
      ))
    }
    
    status_items <- list()
    
    # Anthropic status
    if (test_results$anthropic$success) {
      status_items <- append(status_items, list(
        tags$p(icon("check-circle", style = "color: #28a745;"), " Anthropic API",
               style = "color: #28a745; margin: 0; font-size: 0.9em;")
      ))
    } else {
      status_items <- append(status_items, list(
        tags$p(icon("times-circle", style = "color: #dc3545;"), " Anthropic API",
               style = "color: #dc3545; margin: 0; font-size: 0.9em;",
               title = test_results$anthropic$details)
      ))
    }
    
    # Perplexity status
    if (test_results$perplexity$success) {
      status_items <- append(status_items, list(
        tags$p(icon("check-circle", style = "color: #28a745;"), " Perplexity API",
               style = "color: #28a745; margin: 0; font-size: 0.9em;")
      ))
    } else {
      status_items <- append(status_items, list(
        tags$p(icon("times-circle", style = "color: #dc3545;"), " Perplexity API",
               style = "color: #dc3545; margin: 0; font-size: 0.9em;",
               title = test_results$perplexity$details)
      ))
    }
    
    # Overall status
    if (test_results$literature_enabled) {
      status_items <- append(status_items, list(
        tags$p(icon("microscope", style = "color: #28a745;"), " Literature Enhanced",
               style = "color: #28a745; margin: 0; font-size: 0.9em; font-weight: bold;")
      ))
    } else {
      status_items <- append(status_items, list(
        tags$p(icon("exclamation-triangle", style = "color: #ffc107;"), " Basic Mode Only",
               style = "color: #856404; margin: 0; font-size: 0.9em;")
      ))
    }
    
    return(tags$div(status_items))
  })
  
  # Evidence Base UI outputs for each phase
  # Hypothesis phase literature
  output$hypothesis_literature_summary <- renderUI({
    lit_results <- values$literature_results$hypothesis
    if (length(lit_results) == 0) {
      return(tags$p("No literature searches performed yet.", style = "font-style: italic; color: #666;"))
    }
    
    searches <- lapply(seq_along(lit_results), function(i) {
      result <- lit_results[[i]]
      status_icon <- if (result$success %||% FALSE) "✓" else "✗"
      status_color <- if (result$success %||% FALSE) "#28a745" else "#dc3545"
      
      tags$div(
        style = "margin-bottom: 8px;",
        tags$span(status_icon, style = paste("color:", status_color, "; font-weight: bold; margin-right: 5px;")),
        tags$code(result$query %||% "Unknown query", style = "font-size: 0.85em;")
      )
    })
    
    return(tags$div(searches))
  })
  
  output$hypothesis_citations <- renderUI({
    lit_results <- values$literature_results$hypothesis
    if (length(lit_results) == 0) {
      return(tags$p("No citations available.", style = "font-style: italic; color: #666;"))
    }
    
    all_citations <- c()
    for (result in lit_results) {
      if (result$success %||% FALSE) {
        citations <- result$citations %||% c()
        all_citations <- c(all_citations, citations)
      }
    }
    
    if (length(all_citations) == 0) {
      return(tags$p("No citations extracted from searches.", style = "font-style: italic; color: #666;"))
    }
    
    unique_citations <- unique(all_citations)
    citation_list <- lapply(unique_citations, function(citation) {
      tags$li(citation, style = "font-size: 0.9em; margin-bottom: 3px;")
    })
    
    return(tags$ol(citation_list, style = "padding-left: 20px;"))
  })
  
  # Planning phase literature
  output$planning_literature_summary <- renderUI({
    lit_results <- values$literature_results$planning
    if (length(lit_results) == 0) {
      return(tags$p("No literature searches performed yet.", style = "font-style: italic; color: #666;"))
    }
    
    searches <- lapply(seq_along(lit_results), function(i) {
      result <- lit_results[[i]]
      status_icon <- if (result$success %||% FALSE) "✓" else "✗"
      status_color <- if (result$success %||% FALSE) "#28a745" else "#dc3545"
      
      tags$div(
        style = "margin-bottom: 8px;",
        tags$span(status_icon, style = paste("color:", status_color, "; font-weight: bold; margin-right: 5px;")),
        tags$code(result$query %||% "Unknown query", style = "font-size: 0.85em;")
      )
    })
    
    return(tags$div(searches))
  })
  
  output$planning_citations <- renderUI({
    lit_results <- values$literature_results$planning
    if (length(lit_results) == 0) {
      return(tags$p("No citations available.", style = "font-style: italic; color: #666;"))
    }
    
    all_citations <- c()
    for (result in lit_results) {
      if (result$success %||% FALSE) {
        citations <- result$citations %||% c()
        all_citations <- c(all_citations, citations)
      }
    }
    
    if (length(all_citations) == 0) {
      return(tags$p("No citations extracted from searches.", style = "font-style: italic; color: #666;"))
    }
    
    unique_citations <- unique(all_citations)
    citation_list <- lapply(unique_citations, function(citation) {
      tags$li(citation, style = "font-size: 0.9em; margin-bottom: 3px;")
    })
    
    return(tags$ol(citation_list, style = "padding-left: 20px;"))
  })
  
  # Implementation phase literature  
  output$implementation_literature_summary <- renderUI({
    lit_results <- values$literature_results$implementation
    if (length(lit_results) == 0) {
      return(tags$p("No literature searches performed yet.", style = "font-style: italic; color: #666;"))
    }
    
    searches <- lapply(seq_along(lit_results), function(i) {
      result <- lit_results[[i]]
      status_icon <- if (result$success %||% FALSE) "✓" else "✗"
      status_color <- if (result$success %||% FALSE) "#28a745" else "#dc3545"
      
      tags$div(
        style = "margin-bottom: 8px;",
        tags$span(status_icon, style = paste("color:", status_color, "; font-weight: bold; margin-right: 5px;")),
        tags$code(result$query %||% "Unknown query", style = "font-size: 0.85em;")
      )
    })
    
    return(tags$div(searches))
  })
  
  output$implementation_citations <- renderUI({
    lit_results <- values$literature_results$implementation
    if (length(lit_results) == 0) {
      return(tags$p("No citations available.", style = "font-style: italic; color: #666;"))
    }
    
    all_citations <- c()
    for (result in lit_results) {
      if (result$success %||% FALSE) {
        citations <- result$citations %||% c()
        all_citations <- c(all_citations, citations)
      }
    }
    
    if (length(all_citations) == 0) {
      return(tags$p("No citations extracted from searches.", style = "font-style: italic; color: #666;"))
    }
    
    unique_citations <- unique(all_citations)
    citation_list <- lapply(unique_citations, function(citation) {
      tags$li(citation, style = "font-size: 0.9em; margin-bottom: 3px;")
    })
    
    return(tags$ol(citation_list, style = "padding-left: 20px;"))
  })
  
  # Analysis phase literature
  output$analysis_literature_summary <- renderUI({
    lit_results <- values$literature_results$analysis
    if (length(lit_results) == 0) {
      return(tags$p("No literature searches performed yet.", style = "font-style: italic; color: #666;"))
    }
    
    searches <- lapply(seq_along(lit_results), function(i) {
      result <- lit_results[[i]]
      status_icon <- if (result$success %||% FALSE) "✓" else "✗"
      status_color <- if (result$success %||% FALSE) "#28a745" else "#dc3545"
      
      tags$div(
        style = "margin-bottom: 8px;",
        tags$span(status_icon, style = paste("color:", status_color, "; font-weight: bold; margin-right: 5px;")),
        tags$code(result$query %||% "Unknown query", style = "font-size: 0.85em;")
      )
    })
    
    return(tags$div(searches))
  })
  
  output$analysis_citations <- renderUI({
    lit_results <- values$literature_results$analysis
    if (length(lit_results) == 0) {
      return(tags$p("No citations available.", style = "font-style: italic; color: #666;"))
    }
    
    all_citations <- c()
    for (result in lit_results) {
      if (result$success %||% FALSE) {
        citations <- result$citations %||% c()
        all_citations <- c(all_citations, citations)
      }
    }
    
    if (length(all_citations) == 0) {
      return(tags$p("No citations extracted from searches.", style = "font-style: italic; color: #666;"))
    }
    
    unique_citations <- unique(all_citations)
    citation_list <- lapply(unique_citations, function(citation) {
      tags$li(citation, style = "font-size: 0.9em; margin-bottom: 3px;")
    })
    
    return(tags$ol(citation_list, style = "padding-left: 20px;"))
  })
  
  # Source phase-specific logic
  source("R/phase1_hypothesis_chat.R", local = TRUE)
  source("R/phase2_planning_chat.R", local = TRUE)
  source("R/phase3_implementation_chat.R", local = TRUE)
  source("R/phase4_analysis_chat.R", local = TRUE)
  source("R/ai_responses.R", local = TRUE)
}

# Run the application
shinyApp(ui = ui, server = server)