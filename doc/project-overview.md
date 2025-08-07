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

1. **[Vision & Philosophy](vision-philosophy.md)** - Core mission and reasoning approach
2. **[UI/UX Design Principles](uiux-principles.md)** - Interface design and emotional goals
3. **[Technical Architecture](technical-architecture.md)** - System specifications and data flow
4. **[Causal Inference Requirements](causal-inference.md)** - Standards for causal hypotheses
5. **[Chat Interface Specifications](chat-interface.md)** - Conversational design by phase
6. **[Implementation Guidelines](implementation-guidelines.md)** - Development constraints and requirements

## Quick Start for Developers

1. Review the Vision & Philosophy to understand project goals
2. Study the Technical Architecture for system requirements
3. Implement the Chat Interface following phase-specific guidelines
4. Apply UI/UX principles throughout development
5. Ensure Causal Inference requirements are met for relevant hypotheses
6. Follow Implementation Guidelines for constraints and error handling

## Technology Stack

- **Frontend**: RShiny
- **AI Integration**: ellmer package for Anthropic API
- **Knowledge Base**: Perplexity API for literature search
- **Data Format**: RDS files only
- **Output**: Interactive HTML via R Markdown

## Privacy & Compliance

- Raw data never leaves user's local environment
- Only descriptive and inferential statistics shared via JSON
- Designed for compliance with health privacy laws (HIPAA, GDPR)
- No session persistence - single session completion required

## Contact & Support

[Add project maintainer contact information here]