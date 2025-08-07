# Causal Inference Requirements

## Overview

Hypotheses can be either associational or causal. When hypotheses involve causal claims, the system must implement rigorous requirements to ensure appropriate analysis and interpretation.

## 1. Causal Identification Strategy

For any causal hypothesis, explicitly document:

- **Causal mechanism**: Theoretical justification for proposed causal pathway
- **Confounders**: Complete list of potential confounders and measurement status
- **Bias assessment**: 
  - Unmeasured confounding risks
  - Selection bias potential
  - Collider bias concerns
  - Mediation bias possibilities
- **DAG requirement**: Directed acyclic graph visualizing assumed causal relationships

## 2. Study Design Assessment

### Randomized Designs
If treatment is randomized:
- Document randomization procedure
- Check for balance across treatment groups
- Verify randomization integrity

### Observational Designs
If non-randomized, select appropriate quasi-experimental methods:

**Propensity Score Methods**
- Matching, weighting, or stratification
- When treatment assignment based on observables
- Balance diagnostics required

**Instrumental Variables**
- When valid instrument exists
- Document instrument validity assumptions
- Test for weak instruments

**Regression Discontinuity**
- When treatment assignment has threshold
- Verify discontinuity assumptions
- Bandwidth selection justification

**Difference-in-Differences**
- When panel data available
- Parallel trends assumption testing
- Event study specifications

**Synthetic Control Methods**
- For aggregate unit comparisons
- Pre-treatment fit assessment
- Placebo tests required

## 3. Robustness Checks

The analytic plan must include:

### Sensitivity Analyses
- E-value calculations for unmeasured confounding
- Bounds on causal effects
- Alternative model specifications

### Falsification Tests
- Negative control outcomes when possible
- Placebo tests for unaffected groups
- Pre-treatment trends examination

### Assumption Testing
- Formal tests where available
- Graphical diagnostics
- Multiple specification approaches

## 4. Reporting Standards

### Language Requirements
- Use "consistent with a causal effect" not "proves causation"
- Acknowledge uncertainty appropriately
- Avoid definitive causal claims without strong design

### Confidence Levels
Report causal interpretation confidence as:
- **High**: Randomized design with good compliance
- **Moderate**: Strong quasi-experimental design with robustness checks
- **Low**: Observational with residual confounding concerns

### Required Elements
- All causal assumptions explicitly stated
- Specific threats to inference acknowledged
- Limitations that cannot be ruled out documented
- Strength of design clearly communicated

## 5. Special Considerations

### Social and Behavioral Sciences
- Acknowledge constructed nature of social phenomena
- Consider temporal and cultural context
- Avoid universal law claims
- Respect complexity of human behavior

### Power for Causal Analysis
- Causal methods often require larger samples
- Document power for specific causal estimators
- Consider simplification if underpowered

### Ethical Considerations
- Some causal questions cannot be tested experimentally
- Acknowledge when randomization would be unethical
- Use best available observational methods