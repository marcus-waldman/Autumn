# Autumn - Implementation Guidelines

## Navigation and Flow Control

### Linear Progression
- Users must complete phases sequentially (1→2→3→4)
- No backwards navigation once phase completed
- Clear visual indicators for phase status:
  - Completed (checkmark)
  - Current (highlighted)
  - Locked (grayed out)

### Checkpoints
- **End of Phase 1**: Hypothesis confirmation required
- **End of Phase 2**: Analytic plan approval required
- **End of Phase 3**: Function execution verification required
- **End of Phase 4**: Final output only, no checkpoint

### Session Management
- **No persistence**: Single session completion required
- **Warning messages**: Clear notifications about lack of save functionality
- **Export options** at each checkpoint:
  - Hypothesis statement (Phase 1)
  - Analytic plan (Phase 2)
  - R code (Phase 3)
  - Final markdown (Phase 4)

## Quality Control

### Data Verification Phase
**Automatic checks**:
- Variable types match hypothesis requirements
- Sufficient non-missing data (>80% complete)
- Required variables present
- Sample size adequate for proposed analysis

**Negotiation outcomes**:
1. Proceed with analysis as planned
2. Modify analysis approach (with user consent)
3. Terminate program with clear explanation

### Error States
**Data incompatibility**:
- Clear message explaining why data cannot test hypothesis
- Specific missing elements identified
- Suggestions for resolution if possible

**Power insufficient**:
- Proceed with documented limitations
- Suggest alternative approaches
- Clear communication about interpretation constraints

**Technical errors**:
- User-friendly error messages
- Avoid technical jargon in error reporting
- Provide actionable next steps

## Literature Integration

### API-Based Literature Search
Literature integration is powered by the Perplexity API, providing real-time access to academic sources:

**Integration Features**:
- Automatic literature searches during AI responses
- Real-time citation extraction and formatting
- Evidence synthesis across multiple studies
- Caching to minimize redundant API calls
- Graceful fallback to basic mode if Perplexity unavailable

**API Configuration**:
- Set `PERPLEXITY_API_KEY` environment variable
- Select model through UI dropdown (Sonar Pro, Sonar, Sonar Reasoning)
- Test connection via "Test Connections" button

For complete API configuration details, see **[API Model Reference](api-model-reference.md)**.

## Scope and Constraints

### Domain Boundaries
**In scope**:
- Health research questions
- Behavioral science studies
- Social science investigations
- Educational research
- Public health analyses

**Out of scope**:
- Analyses requiring external API calls
- Real-time data streaming
- Proprietary software requirements
- Exploratory data analysis
- Machine learning model development

### Technical Constraints
- **Single session**: No ability to save and resume
- **Local processing**: All data analysis client-side
- **No revision**: Hypothesis locked after Phase 1
- **RDS only**: Data input format restriction
- **Fixed sample**: No data collection features

## Performance Considerations

### Response Times
- Chat responses: <2 seconds
- Literature search simulation: <1 second
- R code execution: Variable (show progress)
- Markdown rendering: <3 seconds

### Resource Management
- Limit conversation history to 50 exchanges
- Cache literature entries within session
- Clear temporary objects between phases
- Monitor memory usage for large datasets

## Security and Privacy

### Data Handling
- No raw data transmission to APIs
- Statistics aggregation before sharing
- Clear user consent for any external communication
- Audit trail of shared information

### API Key Management
- Environment variables only
- Never exposed in UI
- Clear setup instructions
- Validation before use

## API Configuration

For comprehensive API configuration, model compatibility, and troubleshooting information, see **[API Model Reference](api-model-reference.md)**.

**Quick Setup**:
1. Set environment variables: `ANTHROPIC_API_KEY` and `PERPLEXITY_API_KEY`
2. Select models via UI dropdowns in AI Assistant Status panel
3. Test connections using built-in diagnostic button
4. Application handles model-specific response formats automatically

## Development Priorities

### Phase 1 (MVP)
1. Basic chat interface
2. Hypothesis formulation flow
3. Simple R function generation
4. Basic markdown output

### Phase 2 (Enhancement)
1. Literature integration
2. Power analysis tools
3. Causal inference features
4. Enhanced error handling

### Phase 3 (Polish)
1. UI/UX refinements
2. Performance optimization
3. Extended statistical methods
4. Export enhancements

## Testing Requirements

### Unit Tests
- Phase transition logic
- R code generation
- JSON serialization
- Error handling paths

### Integration Tests
- Full workflow completion
- API communication
- Export functionality