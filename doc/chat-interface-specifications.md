# Autumn Chat Interface Specifications

## Overview

The chat interface serves as the primary interaction mechanism, fostering collaboration between users and Anthropic throughout the scientific process. All interactions should feel conversational and supportive, with AI acting as a knowledgeable companion.

## Phase-Specific Implementations

### Phase 1: Hypothesis Formulation (Fully Chat-Based)

**Objective**: Arrive at consensus on a specific, clear, falsifiable, and testable hypothesis through iterative dialogue.

**Interface Features**:
- User initiates with research question or hypothesis
- Anthropic asks clarifying questions:
  - Outcome variables and measurement
  - Predictor/treatment variables
  - Target population
  - Associational vs. causal claims
- Real-time refinement through dialogue
- Skeptical but constructive feedback
- Formal hypothesis statement requiring confirmation
- Lock mechanism upon confirmation

**Example Interaction**:
```
User: "I want to test if exercise reduces depression in elderly adults"

Anthropic: "That's an interesting hypothesis. Let me ask some clarifying questions:
1. How is depression measured in your dataset?
2. How is exercise defined and measured?
3. Do you have randomized assignment to exercise, or is this observational data?"

[Dialogue continues until consensus reached]
```

### Phase 2: Analytic Planning (Hybrid Chat-Form)

**Objective**: Develop consensus on analytic plan with power considerations.

**Interface Features**:
- MDE calculations presented conversationally
- Literature-based effect size discussion
- Interactive method selection through dialogue
- Collaborative DAG construction for causal hypotheses
- Trade-off negotiations (power vs. complexity)
- Structured plan presentation for approval

**Knowledge Integration**:
- Trigger literature searches for:
  - Similar study methodologies
  - Effect size benchmarks
  - Best practices for analysis type

### Phase 3: Implementation (Guided Chat)

**Objective**: Generate and execute R functions with user understanding.

**Interface Features**:
- Plain language code explanations
- Q&A about functions and approaches
- Error translation to understandable language
- Modification options based on issues
- Progress updates through chat

**Example Interaction**:
```
Anthropic: "I've generated a function to run your t-test with assumptions checks. 
The code first verifies normality using Shapiro-Wilk, then proceeds with either 
a standard or Welch's t-test based on variance equality. Would you like me to 
explain any part in more detail?"

User: "What happens if normality is violated?"

Anthropic: "Good question! If the Shapiro-Wilk test indicates non-normality, 
we have several options..."
```

### Phase 4: Analysis (Explanatory Chat)

**Objective**: Interpret results and document limitations.

**Interface Features**:
- Narrative result interpretation
- Interactive meaning discussion
- Collaborative limitations drafting
- Clarification on statistical interpretations
- Final report review opportunity

## System Prompts Integration

### Base Anthropic Prompt
```
You are a skeptical scientific collaborator with access to current research 
literature. Your role is to:
1. Guide users through rigorous hypothesis testing
2. Challenge assumptions with evidence
3. Suggest improvements based on best practices
4. Maintain a supportive, educational tone
5. Respect user expertise while encouraging growth
```

### Literature Search Integration
```
For every significant claim or methodological decision:
1. Use search_literature() to find relevant evidence
2. Synthesize findings to represent field consensus
3. Weight evidence by study quality (RCTs > observational)
4. Present balanced view, not cherry-picked contrarian examples
```

## Enhanced Chat Function

The enhanced chat function orchestrates interaction between Anthropic and Perplexity APIs:

**Key Features**:
- Dynamic model selection through UI
- Literature search integration with Perplexity API
- Automatic caching of literature results
- Graceful fallback on API failures
- Rate limiting (0.5s between searches)

**Implementation Pattern**:
1. Generate literature search queries via Anthropic
2. Execute searches via Perplexity with caching
3. Synthesize evidence into final response
4. Return both response and literature citations

For implementation details and code examples, see the source files in `/R` directory.

## Model Selection Integration

Model selection is handled through the UI with real-time switching capabilities. For complete model configuration details and API testing implementation, see **[API Model Reference](api-model-reference.md)**.

## Conversation Management

### State Tracking
- Maintain conversation history within phase
- Track key decisions and confirmations
- Store literature citations used
- Log hypothesis evolution

### Error Handling
- Graceful API failures with fallback options
- Clear messaging when literature unavailable
- Option to proceed without external evidence
- User notification of degraded functionality

## UI Integration

### Chat Component Design
- Central placement in interface
- Clear visual separation of speakers
- Subtle animation for thinking states
- Citation previews on hover
- Collapsible evidence panels

### Supporting Elements
- "Thinking" indicator during API calls
- Evidence strength visualization
- Confidence meters for recommendations
- Export conversation capability