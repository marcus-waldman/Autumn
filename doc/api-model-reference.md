# API Model Reference Guide

## Overview

This document provides comprehensive information about AI model support, compatibility, and configuration for the Autumn Scientific Methods Engine.

## Current Model Support (Updated January 2025)

### Anthropic API Models

| Model Name | Model ID | Capabilities | Use Cases |
|------------|----------|--------------|-----------|
| **Claude 3.5 Sonnet (Latest)** | `claude-3-5-sonnet-20241022` | Most advanced reasoning, analysis | Complex scientific discussions, hypothesis refinement |
| **Claude 3.5 Sonnet (June)** | `claude-3-5-sonnet-20240620` | Stable, reliable performance | General scientific collaboration |
| **Claude 3.5 Haiku** | `claude-3-5-haiku-20241022` | Fast, efficient responses | Quick interactions, simple queries |
| **Claude 3 Opus** | `claude-3-opus-20240229` | Highest capability (when available) | Complex analysis, detailed explanations |
| **Claude 3 Sonnet** | `claude-3-sonnet-20240229` | Balanced performance | Standard scientific discussions |
| **Claude 3 Haiku** | `claude-3-haiku-20240307` | Speed-optimized | Basic interactions, quick responses |

### Perplexity API Models

| Model Name | Model ID | Capabilities | Use Cases |
|------------|----------|--------------|-----------|
| **Sonar Pro** | `sonar-pro` | Flagship search, comprehensive results | Primary literature searches, detailed research |
| **Sonar** | `sonar` | Standard search capabilities | General literature searches |
| **Sonar Reasoning** | `sonar-reasoning` | Complex analysis with search | Specialized reasoning tasks with literature |

## Deprecated Models

### ⚠️ No Longer Supported
These models will cause API errors and should not be used:

**Anthropic (Old Naming)**:
- `claude-3-sonnet-20240229` (use `claude-3-5-sonnet-20241022` instead)
- Various beta model identifiers

**Perplexity (Deprecated February 2025)**:
- `llama-3.1-sonar-small-128k-online`
- `llama-3.1-sonar-large-128k-online`
- `llama-3.1-sonar-huge-128k-online`
- `llama-3-sonar-small-32k-online`
- `llama-3-sonar-large-32k-online`

## Model Selection Implementation

### User Interface
- **Location**: AI Assistant Status panel in left sidebar
- **Components**: Two dropdown menus for Anthropic and Perplexity model selection
- **Behavior**: Real-time switching with immediate effect on subsequent API calls

### Technical Implementation
```r
# Model storage in reactive values
values$selected_anthropic_model <- "claude-3-5-sonnet-20241022"
values$selected_perplexity_model <- "sonar-pro"

# Function calls with selected models
generate_ai_response(phase, user_input, values,
                    anthropic_model = values$selected_anthropic_model,
                    perplexity_model = values$selected_perplexity_model)
```

### API Function Updates
All API functions now accept model parameters:
```r
# Anthropic API calls
call_anthropic_api(prompt, model = selected_model)

# Perplexity API calls  
search_literature(query, model = selected_model)

# Testing functions
test_all_apis(anthropic_model = "claude-3-5-sonnet-20241022", 
              perplexity_model = "sonar-pro")
```

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. "Model Not Found" Error
**Symptoms**: HTTP 404 errors, "model not found" messages
**Cause**: Using deprecated model identifiers
**Solution**: 
- Use the model selection dropdown instead of hardcoded values
- Check the current supported models table above
- Update any hardcoded model names in custom code

#### 2. Response Parsing Errors
**Symptoms**: "$ operator is invalid for atomic vectors"
**Cause**: API response format changes between model versions
**Solution**: 
- Application automatically handles current response formats
- Ensure you're using supported models from the dropdown
- Update to latest version if using custom parsing code

#### 3. Literature Integration Failures
**Symptoms**: "Basic Mode Only" despite Perplexity API key being set
**Cause**: Model selection or API connectivity issues
**Solution**:
- Use the "Test Connections" button to diagnose
- Try switching to a different Perplexity model
- Check that `PERPLEXITY_API_KEY` environment variable is set correctly

#### 4. API Key Issues
**Symptoms**: "No API key found" or authentication errors
**Solutions**:
- **Environment Variables**: Set `ANTHROPIC_API_KEY` and `PERPLEXITY_API_KEY`
- **CSV Upload**: Use the built-in CSV upload feature in the application
- **Verification**: Use the "Test Connections" button to validate keys

## Performance Considerations

### Model Performance Characteristics

**Anthropic Models**:
- **Claude 3.5 Sonnet (Latest)**: Highest quality, moderate speed
- **Claude 3.5 Haiku**: Fastest response, good for quick interactions
- **Claude 3 Opus**: Highest capability but may have rate limits

**Perplexity Models**:
- **Sonar Pro**: Most comprehensive search results, slightly slower
- **Sonar**: Balanced performance and speed
- **Sonar Reasoning**: Best for complex queries, moderate speed

### Recommended Combinations

**For Research-Heavy Sessions**:
- Anthropic: Claude 3.5 Sonnet (Latest)
- Perplexity: Sonar Pro

**For Quick Interactions**:
- Anthropic: Claude 3.5 Haiku
- Perplexity: Sonar

**For Complex Analysis**:
- Anthropic: Claude 3 Opus (if available)
- Perplexity: Sonar Reasoning

## API Rate Limits and Best Practices

### Rate Limiting
- **Automatic Delays**: Built-in 0.5 second delays between literature searches
- **Error Handling**: Graceful fallbacks when rate limits are exceeded
- **Caching**: Literature search results are cached to reduce API calls

### Best Practices
1. **Test Before Important Sessions**: Use "Test Connections" to verify functionality
2. **Choose Appropriate Models**: Match model capabilities to task complexity
3. **Monitor Performance**: Switch models if experiencing slow response times
4. **Backup Plans**: Have fallback models ready for high-usage periods

## Migration Guide

### From Previous Versions
If upgrading from earlier versions of Autumn:

1. **Update Model Names**: Replace any hardcoded deprecated model names
2. **Test Functionality**: Run the built-in API tests after upgrade
3. **Verify Environment**: Ensure API keys are properly configured
4. **Update Documentation**: Review any custom documentation referencing old models

### Code Updates Required
Replace deprecated function calls:
```r
# Old (deprecated)
enhanced_chat(user_input, phase, values)

# New (with model selection)
enhanced_chat(user_input, phase, values,
              anthropic_model = values$selected_anthropic_model,
              perplexity_model = values$selected_perplexity_model)
```

## Support and Updates

### Staying Current
- Model availability may change based on API provider updates
- Check this document for the latest supported models
- Use the built-in testing features to verify model functionality

### Reporting Issues
When reporting API-related issues, include:
- Selected model names
- Error messages or response codes
- Steps to reproduce the issue
- Output from "Test Connections" diagnostics

## Version History

### January 2025 Update
- Added dynamic model selection interface
- Updated to current Anthropic model names (3.5 Sonnet series)
- Updated to current Perplexity model names (Sonar series)
- Fixed response parsing for all supported models
- Added comprehensive API testing and diagnostics
- Deprecated legacy model support

### Previous Versions
- Used fixed model assignments
- Limited to specific model versions
- Manual model configuration required