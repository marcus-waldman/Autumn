# Dual API Key Setup Guide

## Overview

The Scientific Methods Engine now requires **both** Anthropic and Perplexity API keys for optimal functionality. The system will guide users through a two-step setup process to configure both APIs before accessing the research phases.

## User Flow Scenarios

### Scenario 1: No API Keys Available
**Initial State**: Neither Anthropic nor Perplexity API keys are found in environment variables.

**User Experience**:
1. App starts with "Anthropic API Setup" screen
2. User uploads CSV with Anthropic API key
3. Upon successful Anthropic setup, automatically redirects to "Perplexity API Setup" screen  
4. User can either:
   - Add Perplexity API key to enable literature integration
   - Skip Perplexity to proceed with basic mode
5. Redirects to Phase 1: Hypothesis after setup completion

### Scenario 2: Only Anthropic API Available
**Initial State**: Anthropic API key found in environment, but no Perplexity API key.

**User Experience**:
1. App starts directly with "Perplexity API Setup" screen
2. Clear explanation that Anthropic is already configured
3. User sees benefits of adding Perplexity for literature integration
4. User can either:
   - Add Perplexity API key for enhanced mode
   - Skip to proceed with basic AI collaboration
5. Redirects to Phase 1: Hypothesis after decision

### Scenario 3: Both API Keys Available
**Initial State**: Both API keys found in environment variables.

**User Experience**:
1. App starts directly in Phase 1: Hypothesis
2. Full literature-enhanced mode active
3. Sidebar shows "Literature Enhanced" status
4. All phases show enhanced descriptions and Evidence Base panels

### Scenario 4: Only Perplexity API Available
**Initial State**: Perplexity API key found, but no Anthropic API key.

**User Experience**:
1. App starts with "Anthropic API Setup" screen (Anthropic is required for basic functionality)
2. After Anthropic setup, automatically proceeds to Phase 1 with literature integration enabled

## API Key Setup Screens

### Anthropic API Setup Screen
- **Title**: "Anthropic API Key Setup Required"
- **Icon**: Key icon (red)
- **Message**: Anthropic API key is required for basic AI collaboration
- **Process**: CSV upload → variable selection → key confirmation
- **Next Step**: Either Perplexity setup (if missing) or Phase 1 (if available)

### Perplexity API Setup Screen  
- **Title**: "Perplexity API Key Setup Required for Literature Integration"
- **Icon**: Search icon (yellow)
- **Message**: Anthropic is ready, but Perplexity enables literature-enhanced responses
- **Benefits Highlighted**:
  - AI responses with specific citations from recent studies
  - Effect sizes and findings from meta-analyses
  - Methodological guidance based on published research
  - Evidence-based challenge to research assumptions

#### Setup Options:
1. **Option 1: Add to CSV**
   - Instructions to add Perplexity key to existing CSV
   - CSV re-upload process
   - Variable selection and confirmation
   
2. **Option 2: Skip for Now**
   - Clear explanation of basic mode limitations
   - Option to proceed without literature integration
   - Note about adding key later via environment variables

## Sidebar Status Indicators

The sidebar dynamically shows API integration status:

### All Keys Available ✅
- ✅ Anthropic Ready
- ✅ Literature Enhanced

### Only Anthropic Available ⚠️
- ✅ Anthropic Ready  
- ⚠️ Basic Mode Only

### Perplexity Setup Required ⚠️
- ⚠️ Perplexity Key Required

### Anthropic Setup Required ❌
- ❌ Anthropic Key Required

## Phase Experience Differences

### Literature-Enhanced Mode (Both APIs)
- **Titles**: "Evidence-Based Collaborative Refinement", "Literature-Enhanced Planning", etc.
- **Descriptions**: Emphasize literature integration, citations, and evidence-based feedback
- **Evidence Base Panels**: Active and populated with search results and citations
- **AI Responses**: Include specific citations, effect sizes, and research-grounded challenges

### Basic Mode (Anthropic Only)
- **Titles**: Standard collaboration titles
- **Descriptions**: Include yellow warning banners explaining basic mode limitations
- **Evidence Base Panels**: Show "No literature searches performed yet"
- **AI Responses**: Based on training knowledge only, no current literature integration

## Technical Implementation

### Environment Variables
```bash
# Required for basic functionality
ANTHROPIC_API_KEY=your-anthropic-key

# Required for literature integration  
PERPLEXITY_API_KEY=your-perplexity-key
```

### CSV Format
Users can include both keys in a single CSV file:
```csv
ANTHROPIC_API_KEY,PERPLEXITY_API_KEY
sk-ant-...,pplx-...
```

### Reactive Logic
- `anthropic_key_available()`: Checks environment and CSV upload status
- `perplexity_key_available()`: Checks environment and CSV upload status  
- `values$perplexity_enabled`: Determines literature integration availability
- `values$skip_perplexity`: Tracks user decision to proceed without Perplexity

## User Benefits

### Enhanced Mode Benefits
- **Evidence-Based Responses**: Every AI response grounded in current literature
- **Specific Citations**: References to recent studies and meta-analyses
- **Effect Size Guidance**: Quantitative findings from research literature
- **Methodological Validation**: Research-backed statistical approach recommendations
- **Gap Identification**: Highlights areas where current knowledge is insufficient

### Basic Mode Limitations
- **Training Knowledge Only**: Responses based on AI training cutoff
- **No Current Literature**: Cannot access recent studies or findings
- **General Guidance**: Methodological advice without specific research backing
- **No Citations**: Cannot provide specific study references

## Migration Guide

### For Existing Users
1. **Environment Variables**: Add `PERPLEXITY_API_KEY` to your environment
2. **CSV Method**: Add Perplexity key column to existing CSV file
3. **Skip Option**: Choose to continue with basic mode without changes

### For New Users
1. **Recommended**: Set up both API keys for full functionality
2. **Minimum**: Anthropic API key required for basic operation
3. **Enhancement**: Add Perplexity later for literature integration

## Troubleshooting

### Common Issues
1. **Stuck on API Setup**: Ensure CSV file is properly formatted with correct column names
2. **Keys Not Working**: Verify API key validity and permissions
3. **Basic Mode Only**: Check that Perplexity API key is properly set in environment or CSV

### Debug Steps
1. Check environment variables: `Sys.getenv("ANTHROPIC_API_KEY")` and `Sys.getenv("PERPLEXITY_API_KEY")`
2. Verify CSV upload success: Look for confirmation messages
3. Check sidebar status indicators for current API state
4. Use integration tests: `source("R/integration_tests.R"); quick_test()`

## Future Considerations

### Potential Enhancements
1. **API Key Management UI**: In-app key management without CSV upload
2. **Key Validation**: Real-time API key testing during setup
3. **Usage Monitoring**: Track API usage and costs within the app
4. **Multiple Key Support**: Support for backup or rotating API keys

The dual API setup ensures users understand the benefits of literature integration while maintaining flexibility for different use cases and API availability scenarios.