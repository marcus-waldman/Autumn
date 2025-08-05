# Scientific Methods Engine - Main Shiny Application
# A collaborative tool for hypothesis testing following the scientific method

library(shiny)
library(shinydashboard)
library(DT)
library(tidyverse)
library(jsonlite)
library(knitr)
library(rmarkdown)

# Source helper functions
#source("R/phase1_hypothesis.R")
#source("R/phase2_planning.R")
#source("R/phase3_implementation.R")
#source("R/phase4_analysis.R")
source("R/utils.R")

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Scientific Methods Engine"),
  
  dashboardSidebar(
    sidebarMenu(
      id = "phases",
      menuItem("Phase 1: Hypothesis", tabName = "hypothesis", icon = icon("lightbulb")),
      menuItem("Phase 2: Planning", tabName = "planning", icon = icon("tasks")),
      menuItem("Phase 3: Implementation", tabName = "implementation", icon = icon("code")),
      menuItem("Phase 4: Analysis", tabName = "analysis", icon = icon("chart-line"))
    ),
    
    # Phase status indicators
    tags$hr(),
    tags$div(
      id = "phase-status",
      style = "padding: 10px;",
      h4("Progress"),
      uiOutput("progress_indicators")
    )
  ),
  
  dashboardBody(
    # Include custom CSS
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
    
    tabItems(
      # Phase 1: Hypothesis Formulation
      tabItem(
        tabName = "hypothesis",
        fluidRow(
          box(
            title = "Phase 1: Hypothesis Formulation",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            
            # Data upload section
            h4("Step 1: Upload Data"),
            fileInput("data_file", 
                      "Choose RDS File",
                      accept = ".rds"),
            
            verbatimTextOutput("data_summary"),
            
            tags$hr(),
            
            # Hypothesis formulation
            h4("Step 2: Formulate Hypothesis"),
            textAreaInput("hypothesis_input",
                          "Enter your hypothesis:",
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
                            rows = 2),
              textAreaInput("confounders",
                            "List potential confounders (comma-separated):",
                            rows = 2)
            ),
            
            # Variables selection
            h4("Step 3: Select Variables"),
            uiOutput("variable_selection"),
            
            # Data validation results
            h4("Step 4: Data Validation"),
            uiOutput("data_validation"),
            
            # Confirm hypothesis
            actionButton("confirm_hypothesis", 
                         "Confirm Hypothesis & Proceed",
                         class = "btn-success",
                         icon = icon("check"))
          )
        )
      ),
      
      # Phase 2: Analytic Planning
      tabItem(
        tabName = "planning",
        fluidRow(
          box(
            title = "Phase 2: Analytic Planning",
            width = 12,
            status = "warning",
            solidHeader = TRUE,
            
            # Display confirmed hypothesis
            wellPanel(
              h4("Confirmed Hypothesis"),
              verbatimTextOutput("confirmed_hypothesis_display")
            ),
            
            # Power analysis section
            h4("Power Analysis"),
            fluidRow(
              column(6,
                     numericInput("alpha_level", "Significance Level (α):", 
                                  value = 0.05, min = 0.01, max = 0.10, step = 0.01),
                     numericInput("desired_power", "Desired Power:", 
                                  value = 0.80, min = 0.70, max = 0.95, step = 0.05)
              ),
              column(6,
                     verbatimTextOutput("sample_size_info"),
                     verbatimTextOutput("mde_calculation")
              )
            ),
            
            tags$hr(),
            
            # Statistical test selection
            h4("Statistical Test Selection"),
            selectInput("statistical_test",
                        "Select appropriate test:",
                        choices = list(
                          "T-Test (Two groups)" = "t_test",
                          "ANOVA (Multiple groups)" = "anova",
                          "Linear Regression" = "lm",
                          "Logistic Regression" = "glm",
                          "Chi-Square Test" = "chisq"
                        )),
            
            # Literature benchmarks
            h4("Literature Benchmarks"),
            p("Enter effect sizes from relevant literature:"),
            actionButton("add_benchmark", "Add Benchmark", icon = icon("plus")),
            DTOutput("benchmark_table"),
            
            # Analytic plan preview
            h4("Analytic Plan Preview"),
            verbatimTextOutput("analytic_plan_preview"),
            
            # Confirm plan
            actionButton("confirm_plan", 
                         "Approve Plan & Generate R Markdown Template",
                         class = "btn-warning",
                         icon = icon("check"))
          )
        )
      ),
      
      # Phase 3: Implementation
      tabItem(
        tabName = "implementation",
        fluidRow(
          box(
            title = "Phase 3: Implementation",
            width = 12,
            status = "info",
            solidHeader = TRUE,
            
            # Display analytic plan
            wellPanel(
              h4("Approved Analytic Plan"),
              verbatimTextOutput("approved_plan_display")
            ),
            
            # Generated R code
            h4("Generated Analysis Function"),
            verbatimTextOutput("generated_code"),
            
            # Execute analysis
            actionButton("execute_analysis", 
                         "Execute Analysis",
                         class = "btn-info",
                         icon = icon("play")),
            
            tags$hr(),
            
            # Execution results
            h4("Execution Results"),
            verbatimTextOutput("execution_status"),
            
            # Results preview
            h4("Results Preview"),
            plotOutput("results_plot"),
            verbatimTextOutput("results_summary"),
            
            # Confirm results
            actionButton("confirm_results", 
                         "Confirm Results & Proceed to Analysis",
                         class = "btn-info",
                         icon = icon("check"))
          )
        )
      ),
      
      # Phase 4: Analysis
      tabItem(
        tabName = "analysis",
        fluidRow(
          box(
            title = "Phase 4: Analysis & Interpretation",
            width = 12,
            status = "success",
            solidHeader = TRUE,
            
            # Final report preview
            h4("Final Analysis Report"),
            uiOutput("final_report"),
            
            # Download options
            h4("Export Options"),
            downloadButton("download_html", "Download HTML Report"),
            downloadButton("download_rmd", "Download R Markdown Source"),
            
            tags$hr(),
            
            # Session complete message
            tags$div(
              class = "alert alert-success",
              tags$strong("Analysis Complete!"),
              tags$p("Your scientific analysis has been completed. Please download your reports before closing this session.")
            )
          )
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive values to store state
  values <- reactiveValues(
    data = NULL,
    hypothesis = NULL,
    hypothesis_confirmed = FALSE,
    plan = NULL,
    plan_confirmed = FALSE,
    results = NULL,
    results_confirmed = FALSE,
    benchmarks = data.frame(
      Study = character(),
      Effect_Size = numeric(),
      CI_Lower = numeric(),
      CI_Upper = numeric(),
      Sample_Size = integer(),
      stringsAsFactors = FALSE
    )
  )
  
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
      tags$p(icon("circle", class = "text-muted"), " Analysis", class = "text-muted")
    )
  })
  
  # Phase navigation control
  observe({
    if (!values$hypothesis_confirmed) {
      updateTabItems(session, "phases", "hypothesis")
    }
  })
  
  # Source the server logic for each phase
  source("R/phase1_hypothesis.R", local = TRUE)
  source("R/phase2_planning.R", local = TRUE)
  source("R/phase3_implementation.R", local = TRUE)
  source("R/phase4_analysis.R", local = TRUE)
}

# Run the application
shinyApp(ui = ui, server = server)