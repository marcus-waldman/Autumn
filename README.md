<img width="256" height="256" alt="image" src="https://github.com/user-attachments/assets/f5ba4725-52b3-4d61-b794-08381889cf3a" />

# Autumn - Accelerating Scientific Discovery Through AI-Enhanced Collaboration

Autumn transforms how researchers test hypotheses by combining the rigor of the scientific method with the power of AI-assisted reasoning. Built as an RShiny application, it guides users through a structured research journey while fostering both scientific discovery and personal growth as researchers.

## 🏛️ A Return to the Academy

Autumn represents a return to the philosophical traditions of the Academy and Lyceum—sacred spaces where seekers gathered for the pure pursuit of understanding. In our digital age, we recreate this *temenos*, a sanctuary where researchers can momentarily escape the pressures of modern academia and reconnect with why they began their journey: the love of knowledge itself.

Like Socrates in the agora, our AI companion asks not to show its wisdom but to reveal yours. Through thoughtful dialogue—the elenchus of productive inquiry—we practice the art of collaborative discovery. This is the Socratic method meets the scientific method, where every hypothesis faces loving scrutiny and emerges stronger for having been tested.

## 🚀 Why Autumn?

Autumn reimagines research as a collaborative journey where AI serves as a knowledgeable companion, challenging assumptions with evidence from current literature and ensuring every analytical decision can withstand scientific scrutiny.

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
- **AI Integration**: Direct Anthropic Claude API integration
- **Knowledge Base**: Perplexity API for academic literature search
- **Data Format**: RDS files for secure local processing
- **Output**: Interactive HTML reports via R Markdown
- **Deployment**: Optimized for shinyapps.io hosting

## 📊 How It Accelerates Discovery

### 1. Creates Sacred Space for Thought
- Provides refuge from publish-or-perish pressures
- Slows time to the rhythm of deep thinking
- Reconnects researchers with their original curiosity

### 2. Prevents Wasted Effort
- Literature integration identifies already-answered questions
- Power analysis prevents underpowered studies
- Effect size benchmarking sets realistic expectations

### 3. Improves Research Quality
- Enforces rigorous causal inference standards
- Documents all assumptions transparently
- Challenges confirmation bias through skeptical AI

### 4. Democratizes Expertise
- Makes advanced methods accessible to non-statisticians
- Provides plain-language explanations of complex concepts
- Builds researcher capabilities over time

### 5. Reduces Time to Insight
- Automated code generation eliminates programming barriers
- Concurrent literature search provides immediate context
- Structured workflow prevents analytical wandering

## 🎯 Use Cases

- **Clinical Researchers**: Test treatment efficacy with proper controls
- **Social Scientists**: Examine causal relationships in observational data
- **Public Health**: Analyze population-level interventions
- **Education Researchers**: Evaluate program effectiveness
- **Behavioral Scientists**: Study human behavior patterns

## 🔧 Installation

```r
# Install required packages
install.packages(c("shiny", "shinydashboard", "DT", 
                   "tidyverse", "jsonlite", "knitr", 
                   "rmarkdown", "httr"))

# Clone repository
git clone https://github.com/marcus-waldman/Autumn.git

# Set up API keys in .Renviron
ANTHROPIC_API_KEY=your_anthropic_key
PERPLEXITY_API_KEY=your_perplexity_key

# Run the application
shiny::runApp("app.r")
```

## 🤝 The Autumn Philosophy

Autumn embodies "Companionship in Discovery" - treating users not as operators of statistical software, but as scientists on a journey of understanding. Every interaction is designed to leave researchers more capable than before, building confidence through supportive challenge and celebration of intellectual growth.

In this sacred space, time moves differently. The frantic pace of modern research slows to the rhythm of thought. Here, wondering is as valued as knowing, where the journey matters as much as the destination. We believe, as the ancients did, that the unexamined hypothesis is not worth testing.

## 🎨 How Autumn Was Designed

Autumn itself is a testament to the collaborative philosophy it embodies. This project emerged through a synergistic partnership between human vision and AI capability:

1. **Philosophical Foundation**: A human researcher articulated the core vision—creating a sacred space for scientific inquiry that honors both rigor and humanity.

2. **Collaborative Elaboration**: Through Socratic dialogue with AI, this vision was refined and expanded, exploring how classical philosophy could inform modern research tools.

3. **Document Generation**: AI was asked to produce specifications, design principles, and technical architectures that aligned with this philosophy, always checked and refined by human judgment.

4. **Code Development**: Implementation follows the same pattern—AI generates code that embodies our principles, while human wisdom ensures it serves researcher needs.

This meta-level demonstration shows that Autumn practices what it preaches: the best outcomes emerge from thoughtful collaboration between human insight and AI capability, where neither dominates but both contribute their unique strengths.

### Development Acknowledgment

The conceptual development and documentation of Autumn was conducted using Claude (Anthropic) as a collaborative partner. The philosophical framework, technical specifications, and design principles emerged through iterative human-AI dialogue, with all final decisions and creative direction provided by the human researcher. This README itself was co-created through this process, demonstrating the very principles Autumn embodies.

## 📈 Impact Potential

As a newly developed platform, Autumn has not yet undergone formal evaluation studies. Future assessment will track metrics such as:

- Time to hypothesis refinement through AI dialogue
- Reduction in statistical errors through automated checks  
- User confidence growth in research methods
- Data security through local-only processing architecture

We are committed to rigorous evaluation of Autumn's impact on research efficiency and quality. Results from pilot studies and user feedback will be transparently reported as they become available.

## 🚧 Roadmap

- [ ] Expand statistical methods (survival analysis, multilevel models)
- [ ] Enhanced visualization capabilities
- [ ] Multi-language support
- [ ] Integration with electronic health records
- [ ] Collaborative team features

## 📚 Documentation

Comprehensive documentation available in `/doc`:
- [Project Overview](doc/project-overview.md) - Executive summary and quick-start guide
- [API Model Reference](doc/api-model-reference.md) - Complete API configuration guide
- [Data Format Specifications](doc/data-format-specifications.md) - RDS file requirements
- [Deployment Guide](doc/deployment-guide.md) - shinyapps.io deployment instructions
- [Autumn Philosophy](doc/autumn-philosophy.md) - Core philosophical foundation

See [Knowledge Statement](doc/knowledge-statement.md) for complete documentation index.

## 👥 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Autumn represents a new paradigm in scientific software—where AI doesn't replace human judgment but amplifies human intelligence. By grounding every decision in evidence and treating users as partners in discovery, we're not just analyzing data; we're accelerating the pace of human knowledge.

This project itself emerged through the very process it promotes: a human researcher with a vision engaged in deep dialogue with AI, together crafting something neither could have created alone. Every line of code, every design decision, every word of documentation reflects this synergistic collaboration.

### AI Collaboration Acknowledgment

The development of Autumn's conceptual framework, documentation, and philosophical foundations was conducted using Claude (Anthropic) as a collaborative partner. Specific contributions include:
- Co-development of the UI/UX design principles emphasizing "Companionship in Discovery"
- Assistance in articulating the connection to classical philosophical traditions
- Generation of technical specifications and implementation guidelines
- Collaborative refinement of the project's ethical frameworks

All creative direction, final decisions, and the core vision remained with the human researcher. This acknowledgment demonstrates Autumn's commitment to transparency in human-AI collaboration.

We honor the philosophical traditions that guide us—from Socrates' questioning method to Aristotle's empirical rigor to Plato's pursuit of ideal forms. In Autumn, these ancient wisdoms live again, helping modern researchers find truth in an age of information overload.

---

*"The best way to have a good idea is to have lots of ideas and throw the bad ones away." - Linus Pauling*

*"The unexamined hypothesis is not worth testing." - Socrates (via Autumn)*

*Autumn helps you examine deeply, test rigorously, and discover joyfully.*
