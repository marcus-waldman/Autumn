# Knowledge-Enhanced Collaborative Reasoning Implementation

## Overview

This implementation transforms the RShiny Scientific Methods Engine into an evidence-based collaborative system that integrates Perplexity API calls within Anthropic chat interactions. The system now grounds all scientific discourse in current literature, creating a truly knowledge-enhanced collaborative reasoning experience.

## Key Features

### 🔬 Evidence-Based Scientific Collaboration
- **Literature-Grounded Responses**: Every AI response is informed by current research literature
- **Skeptical Scientific Partner**: Challenges assumptions with specific citations
- **Effect Size Awareness**: Provides quantitative findings from meta-analyses and systematic reviews
- **Gap Identification**: Highlights areas where current knowledge is insufficient

### 📊 Phase-Specific Literature Integration
- **Hypothesis Formation**: Searches for similar studies, theoretical frameworks, and contradictory findings
- **Analytic Planning**: Benchmarks effect sizes, validates statistical approaches, suggests sensitivity analyses
- **Implementation**: Provides methodological best practices and diagnostic guidance
- **Analysis**: Contextualizes findings within existing literature and identifies future directions

### 🔍 Intelligent Search Orchestration
- **Automatic Query Generation**: Extracts relevant search needs from user inputs
- **Phase-Aware Searches**: Tailors literature searches to specific research phase requirements
- **Multi-API Coordination**: Seamlessly coordinates Anthropic and Perplexity API calls
- **Graceful Fallbacks**: Maintains functionality when APIs are unavailable

## Architecture Components

### Core Files

#### `R/perplexity_integration.R`
- **Primary Function**: `search_literature()` - Performs structured literature searches
- **Features**: API error handling, citation extraction, result caching
- **Caching**: 24-hour cache to prevent redundant API calls
- **Safety**: 30-second timeouts, graceful error handling

#### `R/enhanced_chat_functions.R`
- **Primary Function**: `enhanced_chat()` - Orchestrates dual-API conversations
- **Process**: 
  1. Identifies literature needs from user input
  2. Executes parallel literature searches
  3. Generates evidence-based response
- **Fallbacks**: Maintains original functionality when enhanced features unavailable

#### `R/phase_specific_searches.R`
- **Purpose**: Generates contextually relevant search queries for each research phase
- **Functions**: Phase-specific search generation, domain customization, quality filters
- **Intelligence**: Adapts searches based on hypothesis type, statistical methods, and user input patterns

#### `R/ai_responses.R` (Enhanced)
- **Modification**: Integrated literature-aware system prompts
- **Enhancement**: Challenges assumptions with evidence-based skepticism
- **Functionality**: Maintains backward compatibility with original response system

### UI Enhancements

#### Evidence Base Panels
- **Location**: Collapsible panels in each phase's chat interface
- **Content**: 
  - Literature searches performed
  - Success/failure indicators
  - Extracted citations with links
- **Design**: Phase-color-coded, expandable, non-intrusive

#### Enhanced Descriptions
- **Updated**: Phase descriptions now emphasize literature integration
- **Clarity**: Explains what users can expect from evidence-based collaboration
- **Expectations**: Sets appropriate expectations for literature-grounded feedback

## Setup Instructions

### 1. API Key Configuration

#### Option A: Environment Variables (Recommended)
```r
# Set in your R session or .Renviron file
Sys.setenv("ANTHROPIC_API_KEY" = "your-anthropic-api-key")
Sys.setenv("PERPLEXITY_API_KEY" = "your-perplexity-api-key")
```

#### Option B: CSV Upload (Built-in)
- Use the existing CSV upload mechanism for Anthropic keys
- Add Perplexity key to the same CSV file
- System will auto-detect and configure both keys

### 2. Required Libraries
```r
install.packages(c("httr", "jsonlite"))
# Existing dependencies: shiny, shinydashboard, DT, tidyverse
```

### 3. File Structure
```
scientific-methods-engine-ai/
├── app_chat_enhanced.r                 # Main enhanced app
├── R/
│   ├── perplexity_integration.R        # Literature search functions
│   ├── enhanced_chat_functions.R       # API orchestration
│   ├── phase_specific_searches.R       # Smart search generation
│   ├── ai_responses.R                  # Enhanced system prompts
│   └── integration_tests.R             # Testing framework
```

## Usage Guide

### Basic Operation

1. **Start the Application**
   ```r
   shiny::runApp("app_chat_enhanced.r")
   ```

2. **API Key Setup**
   - If keys are not in environment, use the built-in CSV upload
   - System will display integration status in the sidebar

3. **Normal Workflow**
   - Upload data and begin hypothesis formulation as usual
   - Notice enhanced AI responses with literature citations
   - Expand "Evidence Base" panels to see search details
   - Benefit from evidence-grounded collaborative reasoning

### Expected Behavior Changes

#### Before Enhancement
- AI provided general methodological advice
- Responses based on training knowledge cutoff
- No specific citations or recent findings
- General effect size conventions (small/medium/large)

#### After Enhancement
- AI challenges claims with specific study citations
- Responses include recent meta-analysis findings
- Specific effect sizes from relevant literature
- Identification of contradictory evidence
- Methodological recommendations based on published research

### Example Interaction

**User**: "I want to test if exercise reduces depression in elderly adults"

**Enhanced AI Response**:
```
Before we proceed, let me examine what the current literature tells us about this relationship.

Based on recent systematic reviews:

Johnson et al. (2023) found in their meta-analysis of 15 RCTs (n=3,247) that structured exercise interventions show moderate effects on depression in older adults (d=0.52, 95% CI: 0.34-0.70). However, effect sizes varied significantly by:
- Exercise type: Aerobic (d=0.61) > Resistance (d=0.43) > Mixed (d=0.48)
- Intervention duration: >12 weeks showed larger effects
- Baseline depression severity: Moderate-severe depression showed greater improvement

Critical considerations from the literature:
1. Smith & Brown (2022) noted high dropout rates (35-40%) in elderly exercise trials
2. Chen et al. (2023) found that social interaction components may confound exercise-specific effects
3. Most studies used self-report measures; objective biomarkers show smaller effects

Your hypothesis should specify:
- Type of exercise intervention
- Comparison condition (waitlist vs. attention control vs. alternative treatment)
- Depression measurement approach
- Expected effect size based on this evidence

What specific exercise intervention are you considering, and how will you address the methodological concerns raised in recent literature?
```

## Technical Implementation Details

### API Call Orchestration

```r
enhanced_chat <- function(user_input, phase, values) {
  # Step 1: Identify literature needs
  search_queries <- extract_search_queries(initial_anthropic_response)
  
  # Step 2: Execute parallel searches
  literature_results <- lapply(search_queries, cached_literature_search)
  
  # Step 3: Generate evidence-informed response
  final_response <- call_anthropic_api(literature_enhanced_prompt)
  
  return(evidence_based_response)
}
```

### Literature Search Pipeline

```r
search_literature <- function(query, max_results = 5) {
  # Construct research-focused prompt
  research_prompt <- paste0(
    "Search for recent scientific literature on: ", query,
    "\n\nProvide structured summary with:",
    "\n1. Key findings from recent studies",
    "\n2. Effect sizes or quantitative results", 
    "\n3. Study populations and methodologies",
    "\n4. Gaps or limitations in current research",
    "\n5. Specific citations with authors and year"
  )
  
  # Execute API call with error handling
  response <- POST(perplexity_api_endpoint, body = research_prompt)
  
  # Parse and structure results
  return(structured_literature_summary)
}
```

### Caching Strategy

- **Duration**: 24 hours for successful searches
- **Key**: Exact query string
- **Benefits**: Reduces API costs, improves response time
- **Storage**: In-memory environment (session-scoped)

## Testing and Validation

### Run Integration Tests
```r
source("R/integration_tests.R")

# Full test suite
run_all_tests()

# Quick functionality check
quick_test()

# Specific scenario testing
test_hypothesis_scenario()
```

### Test Coverage
- ✅ API key detection and configuration
- ✅ Literature search functionality with real API calls
- ✅ Query extraction from AI responses
- ✅ Phase-specific search generation
- ✅ Literature formatting and display
- ✅ Cache functionality and performance
- ✅ Graceful fallback mechanisms
- ✅ UI panel population and updates

## Performance Considerations

### Optimization Features
- **Request Limiting**: Maximum 3 literature searches per interaction
- **Caching**: 24-hour literature search cache
- **Timeouts**: 30-second API call limits
- **Parallel Processing**: Concurrent literature searches when possible
- **Graceful Degradation**: Falls back to original system when APIs unavailable

### Cost Management
- **Search Limits**: Controlled number of searches per session
- **Smart Caching**: Prevents duplicate API calls for similar queries
- **Efficient Prompting**: Optimized prompts for both APIs to minimize token usage
- **Fallback Systems**: Reduces API dependency through intelligent fallbacks

## Troubleshooting

### Common Issues

#### API Keys Not Working
```r
# Check environment variables
Sys.getenv("ANTHROPIC_API_KEY")
Sys.getenv("PERPLEXITY_API_KEY")

# Verify integration status
literature_integration_enabled()
```

#### Literature Searches Failing
```r
# Test individual components
test_result <- search_literature("test query")
print(test_result$success)
print(test_result$error)  # If failed
```

#### UI Panels Not Updating
```r
# Check literature results storage
values$literature_results$hypothesis  # Should contain search results
```

### Debug Mode
```r
# Enable verbose logging
options(shiny.trace = TRUE)

# Run integration tests for diagnostics
source("R/integration_tests.R")
test_knowledge_integration()
```

## Future Enhancements

### Potential Improvements
1. **Domain-Specific Search Optimization**: Customize searches by research field
2. **Citation Network Analysis**: Identify highly-cited foundational papers
3. **Real-Time Literature Alerts**: Notify of new relevant publications
4. **Multi-Language Support**: Search literature in multiple languages
5. **Expert Network Integration**: Connect with domain experts for validation

### Scalability Considerations
1. **Database Backend**: Persistent literature cache storage
2. **Rate Limiting**: Advanced API quota management
3. **Load Balancing**: Multiple API key rotation
4. **User Management**: Individual usage tracking and limits

## Ethical Considerations

### Responsible AI Use
- **Citation Accuracy**: System emphasizes proper citation and source verification
- **Bias Awareness**: Acknowledges potential biases in literature selection
- **Transparency**: Clear indication when responses are literature-enhanced vs. fallback
- **User Agency**: Maintains user control over research direction and interpretation

### Data Privacy
- **No Personal Data**: Literature searches use only research topic information
- **Session Isolation**: Cache data is session-specific and temporary
- **API Privacy**: Follows both Anthropic and Perplexity privacy policies

## Support and Maintenance

### Regular Maintenance Tasks
1. **API Key Rotation**: Update keys as needed
2. **Cache Clearing**: Periodic cleanup of old cached results
3. **Performance Monitoring**: Track API response times and success rates
4. **Literature Quality**: Monitor citation accuracy and relevance

### Getting Help
- **Integration Tests**: Use built-in test functions for diagnostics
- **Error Logs**: Check R console for detailed error messages
- **API Documentation**: Refer to Anthropic and Perplexity API docs for limits and changes

## Conclusion

This implementation successfully transforms the Scientific Methods Engine into a knowledge-enhanced collaborative reasoning system. By integrating current literature into every interaction, the system provides evidence-based scientific collaboration that grounds discussions in empirical research rather than general knowledge.

The modular architecture ensures maintainability and extensibility while providing graceful fallbacks for reliability. Users benefit from a more rigorous, evidence-based approach to scientific hypothesis development and analysis planning.

**Key Achievement**: Every scientific claim is now examined against current literature, creating a truly evidence-based collaborative research environment.