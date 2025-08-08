# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Autumn (Scientific Methods Engine - AI) is an R Shiny application that guides users through rigorous hypothesis testing using the scientific method. It combines local data analysis with AI-powered reasoning (Anthropic + Perplexity APIs) to create an evidence-based research companion.

## Key Commands

### Running the Application

``` bash
# Launch the main Shiny application
Rscript -e "shiny::runApp('app.r')"

# Alternative: Open in RStudio and run
# Open app.r in RStudio and click "Run App"
```

### Data Generation

``` bash
# Generate example datasets (first time setup)
Rscript sme-example-data.r
```

### Required R Packages

Install with: `install.packages(c("shiny", "shinydashboard", "DT", "tidyverse", "jsonlite", "knitr", "rmarkdown", "httr"))`

## Architecture Overview

### Four-Phase Scientific Method Flow

1.  **Phase 1: Hypothesis Formulation** (`R/phase1_hypothesis_chat.r`)
    -   Data upload (RDS files only)
    -   Hypothesis refinement with AI collaboration
    -   Variable selection and validation
2.  **Phase 2: Analytic Planning** (`R/phase2_planning_chat.r`)
    -   Power analysis and effect size calculation
    -   Statistical test selection
    -   Literature-enhanced planning
3.  **Phase 3: Implementation** (`R/phase3_implementation_chat.r`)
    -   R code generation and execution
    -   Results visualization
    -   Error handling and troubleshooting
4.  **Phase 4: Analysis** (`R/phase4_analysis_chat.r`)
    -   Results interpretation
    -   Report generation (HTML/R Markdown)
    -   Limitations and conclusions

### Core Architecture Components

-   **Main Application**: `app.r` - Complete Shiny UI/server with dashboard layout
-   **AI Integration**:
    -   `R/enhanced_chat_functions.R` - Orchestrates Anthropic API calls
    -   `R/perplexity_integration.R` - Literature search via Perplexity API
    -   `R/ai_responses.R` - Phase-specific AI response handlers
-   **Phase Logic**: Individual R files for each phase's specific functionality
-   **Data Management**: Local RDS file processing, JSON export for statistics
-   **UI Framework**: shinydashboard with conditional panels based on API availability

### Dual API System with Model Selection

The application requires two APIs for full functionality: - **Anthropic API**: Core AI collaboration (required) with configurable model selection - **Perplexity API**: Literature integration (optional, enables enhanced mode) with configurable model selection

API keys can be provided via: 1. Environment variables: `ANTHROPIC_API_KEY`, `PERPLEXITY_API_KEY` 2. CSV file upload through the application interface

### Model Selection Features

-   **Real-time Model Selection**: Users can choose from available Anthropic and Perplexity models
-   **UI Location**: Model selection dropdowns in AI Assistant Status panel (left sidebar)
-   **Supported Models**:
    -   Anthropic: Claude 3.5 Sonnet (Latest/June), Claude 3.5 Haiku, Claude 3 Opus/Sonnet/Haiku
    -   Perplexity: Sonar Pro, Sonar, Sonar Reasoning
-   **Live Switching**: Model changes apply immediately to subsequent interactions

## Data Privacy Architecture

-   All user data remains local (RDS files processed in user's R environment)
-   Only aggregated statistics shared via JSON format
-   No raw data transmitted to external APIs
-   Designed for HIPAA/GDPR compliance

## Key File Locations

-   **Configuration**: `Autumn.Rproj` (RStudio project settings)
-   **Styling**: `www/styles.css`, `www/styles_chat.txt`
-   **Example Data**: `data/example_medical_data.rds`, `data/example_lifestyle_data.rds`
-   **Documentation**: `doc/` directory with complete technical specifications
-   **Setup Guide**: `DUAL_API_SETUP_GUIDE.md` for API configuration

## Development Notes

### Code Style

-   Uses 2-space indentation (configured in .Rproj)
-   Reactive programming with Shiny
-   Modular chat UI components with `chatUI()` function
-   Error handling with `tryCatch()` throughout API calls

### Adding New Statistical Tests

1.  Update test selection in `phase2_planning_chat.r`
2.  Add code generation logic in `phase3_implementation_chat.r`
3.  Update power analysis calculations in utility functions

### Literature Integration

-   Literature searches triggered automatically during AI responses
-   Results cached to avoid redundant API calls
-   Citations extracted via regex patterns
-   Fallback guidance when Perplexity unavailable

### Testing

-   Integration tests available in `R/integration_tests.R`
-   Use `source("R/integration_tests.R"); quick_test()` for validation
-   Manual testing through the UI phases

## Troubleshooting Common Issues

1.  **API Key Issues**: Check environment variables or CSV file format; use "Test Connections" button
2.  **Model Compatibility**: Use model selection dropdown; avoid deprecated model names
3.  **Data Upload Failures**: Ensure RDS files contain data.frame/tibble objects
4.  **Missing Packages**: Install required packages listed above
5.  **Literature Search Failures**: Verify Perplexity API key; try different models; app falls back to basic mode
6.  **Analysis Errors**: Check for missing values and appropriate variable types
7.  **"Basic Mode Only" Issue**: Check both API keys are set and use "Test Connections" to diagnose

### API Diagnostics

-   **Built-in Testing**: Use "Test Connections" button in AI Assistant Status panel
-   **Model Switching**: Try different model combinations if experiencing issues\
-   **Status Indicators**: Check visual indicators for API functionality
-   **Reference Guide**: See `doc/api-model-reference.md` for detailed troubleshooting

## UI/UX Redesign Status

### Current State (January 2025)
- **Theme System**: Implemented light/dark theme toggle with autumn pastel colors (#fdf6f2, #c0d8e3, #a78d8a, #e18a7a, #eeb9a2)
- **Chat-Centric Interface**: Priority 1 tasks completed (expanded chat, floating input, hidden redundant controls)
- **Visual Breathing Room**: Priority 2 tasks partially completed (soft visual language, message spacing, color palette)

### Known Issues Requiring Immediate Attention
1. **Text Readability Crisis**: Some text is hard to read in both light/dark themes due to poor contrast ratios
2. **Interface Complexity**: User feedback indicates interface is "too busy" with "too much text"
3. **CSS Loading**: Inline styles in app.r may conflict with external CSS - use `includeCSS("www/styles.css")` and `!important` declarations

### Next Steps (see todo/clean-calm-autumn-redesign.md)
- **URGENT**: Fix text contrast issues - ensure dark text on cream background (light theme) and cream text on dark background (dark theme)
- **Visual Decluttering**: Hide 80% of form controls initially, remove visual noise
- **Conversational Simplicity**: Replace technical language with gentle, natural language
- **Minimal Color Strategy**: Use only 3-4 colors maximum per theme

### Files for UI/UX Work
- `www/styles.css` - Primary stylesheet with theme system
- `app.r` - Main application with potential inline style conflicts
- `todo/clean-calm-autumn-redesign.md` - Comprehensive redesign plan
- `todo/uiux-implementation-todo-list.md` - Detailed implementation tracking

## Extension Points

-   **New Statistical Methods**: Add to phase 2 planning and phase 3 implementation
-   **Additional APIs**: Extend literature search to other academic databases
-   **Export Formats**: Modify report generation in phase 4
-   **UI Themes**: Update CSS files in `www/` directory (see UI/UX Redesign Status above)
