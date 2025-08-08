# Autumn - Project Overview

## Executive Summary

Autumn is a collaborative platform that guides users through rigorous hypothesis testing using the scientific method. It combines local data analysis with AI-powered reasoning to create an evidence-based research companion that fosters both scientific discovery and personal growth.

## Core Features

- **Privacy-First Design**: All data analysis occurs locally; only aggregated statistics are shared
- **Four-Phase Scientific Process**: Structured progression through hypothesis formulation, planning, implementation, and analysis
- **Knowledge-Enhanced AI**: Integrates Anthropic's reasoning with academic literature for evidence-based discourse
- **Chat-Based Collaboration**: Natural conversational interface throughout the research journey
- **Educational Focus**: Designed to help users grow as scientific thinkers

## Key Documents

### Core Documentation
1. **[Autumn Philosophy](autumn-philosophy.md)** - Core philosophical foundation
2. **[Technical Architecture](technical-architecture.md)** - System specifications and data flow
3. **[API Model Reference](api-model-reference.md)** - Complete API configuration and troubleshooting

### Implementation Guides
4. **[Implementation Guidelines](implementation-guidelines.md)** - Development constraints and requirements
5. **[Data Format Specifications](data-format-specifications.md)** - RDS file requirements and validation
6. **[Deployment Guide](deployment-guide.md)** - shinyapps.io deployment instructions

### Design & Interface
7. **[UI/UX Design Principles](uiux-design-principles.md)** - Interface design and emotional goals
8. **[Chat Interface Specifications](chat-interface-specifications.md)** - Conversational design by phase

### Research Standards
9. **[Causal Inference Requirements](causal-inference.md)** - Standards for causal hypotheses
10. **[AI Code of Conduct](ai-code-of-conduct.md)** - Ethical standards for AI
11. **[Investigator Code of Conduct](investigator-code-of-conduct.md)** - Ethical standards for researchers

## Quick Start for Developers

1. Review the Autumn Philosophy to understand project goals
2. Study the Technical Architecture for system requirements
3. Implement the Chat Interface following phase-specific guidelines
4. Apply UI/UX principles throughout development
5. Ensure Causal Inference requirements are met for relevant hypotheses
6. Follow Implementation Guidelines for constraints and error handling

## Technology Stack

- **Frontend**: RShiny with dynamic model selection interface
- **AI Integration**: Direct Anthropic API integration with configurable models
- **Knowledge Base**: Perplexity API for literature search with configurable models
- **Data Format**: RDS files only
- **Output**: Interactive HTML via R Markdown

## AI Model Configuration

Autumn supports dynamic model selection for both Anthropic and Perplexity APIs. Users can switch models in real-time through the AI Assistant Status panel. For complete model specifications, troubleshooting, and configuration details, see **[API Model Reference](api-model-reference.md)**.

## Privacy & Compliance

- Raw data never leaves user's local environment
- Only descriptive and inferential statistics shared via JSON
- Designed for compliance with health privacy laws (HIPAA, GDPR)
- No session persistence - single session completion required

## Contact & Support

[Add project maintainer contact information here]