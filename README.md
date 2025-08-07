---
editor_options: 
  markdown: 
    wrap: 72
---

# Autumn - Accelerating Scientific Discovery Through AI-Enhanced Collaboration

Autumn transforms how researchers test hypotheses by combining the rigor of the scientific method with the power of AI-assisted reasoning. Built as an RShiny application, it guides users through a structured research journey while fostering both scientific discovery and personal growth as researchers.

## 🚀 Why Autumn?

Traditional statistical software treats analysis as a mechanical process. Autumn reimagines research as a collaborative journey where AI serves as a knowledgeable companion, challenging assumptions with evidence from current literature and ensuring every analytical decision can withstand scientific scrutiny.

By integrating real-time literature synthesis with statistical analysis, Autumn accelerates the path from hypothesis to discovery—helping researchers avoid dead ends, identify promising directions, and produce more robust conclusions.

## ✨ Key Features

### Privacy-First Architecture
- **Local data processing** - Raw data never leaves your machine
- **HIPAA/GDPR compliant** - Only aggregated statistics shared with AI
- **Secure collaboration** - Maintain full control over sensitive research data

### Evidence-Based AI Reasoning
- **Dual AI integration** - Anthropic for reasoning + Perplexity for literature
- **Real-time literature grounding** - Every suggestion backed by current research
- **Skeptical collaboration** - AI challenges assumptions with specific citations
- **Meta-analysis synthesis** - Aggregates findings across multiple studies

### Four-Phase Scientific Method

1. **Hypothesis Formulation** - Iterative refinement through Socratic dialogue
2. **Analytic Planning** - Power analysis with literature-based effect sizes
3. **Implementation** - Automated R code generation with plain-language explanations
4. **Analysis & Interpretation** - Context-aware results discussion

### Technical Capabilities
- **Statistical tests**: T-tests, ANOVA, regression (linear/logistic), chi-square
- **Causal inference**: Propensity scores, instrumental variables, difference-in-differences
- **Power analysis**: MDE calculations with literature benchmarking
- **Reproducible research**: R Markdown generation with APA formatting

## 🛠️ Technology Stack

- **Frontend**: RShiny with reactive programming
- **AI Integration**: `ellmer` package for Anthropic Claude API
- **Knowledge Base**: Perplexity API for academic literature search
- **Data Format**: RDS files for secure local processing
- **Output**: Interactive HTML reports via R Markdown

## 📊 How It Accelerates Discovery

### 1. Prevents Wasted Effort
- Literature integration identifies already-answered questions
- Power analysis prevents underpowered studies
- Effect size benchmarking sets realistic expectations

### 2. Improves Research Quality
- Enforces rigorous causal inference standards
- Documents all assumptions transparently
- Challenges confirmation bias through skeptical AI

### 3. Democratizes Expertise
- Makes advanced methods accessible to non-statisticians
- Provides plain-language explanations of complex concepts
- Builds researcher capabilities over time

### 4. Reduces Time to Insight
- Automated code generation eliminates programming barriers
- Concurrent literature search provides immediate context
- Structured workflow prevents analytical wandering

## 🎯 Use Cases

- **Clinical Researchers**: 
- **Social Scientists**:
- **Public Health**: 
- **Education Researchers**: 
- **Behavioral Scientists**: 

## 🔧 Installation

```r
# Install required packages
install.packages(c("shiny", "shinydashboard", "ellmer", 
                   "tidyverse", "DT", "knitr", "rmarkdown"))

# Clone repository
git clone https://github.com/marcus-waldman/Autumn.git

# Set up API keys in .Renviron
ANTHROPIC_API_KEY=your_anthropic_key
PERPLEXITY_API_KEY=your_perplexity_key

# Run the application
shiny::runApp("app.R")
```

## 🤝 The Autumn Philosophy

Autumn embodies "Companionship in Discovery" - treating users not as operators of statistical software, but as scientists on a journey of understanding. Every interaction is designed to leave researchers more capable than before, building confidence through supportive challenge and celebration of intellectual growth.

## 🚧 Roadmap

- [ ] Expand statistical methods (survival analysis, multilevel models)
- [ ] Enhanced visualization capabilities
- [ ] Multi-language support
- [ ] Integration with electronic health records
- [ ] Collaborative team features

## 📚 Documentation

Comprehensive documentation available in `/doc`:
- [Project Overview](doc/project-overview.md)
- [Technical Architecture](doc/technical-architecture.md)
- [UI/UX Design Principles](doc/uiux-design-principles.md)
- [Implementation Guidelines](doc/implementation-guidelines.md)

## 👥 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Autumn represents a new paradigm in scientific software—where AI doesn't replace human judgment but amplifies human intelligence. By grounding every decision in evidence and treating users as partners in discovery, we're not just analyzing data; we're accelerating the pace of human knowledge.

---

*"The best way to have a good idea is to have lots of ideas and throw the bad ones away." - Linus Pauling*

*Autumn helps you identify the good ones faster.*

##
