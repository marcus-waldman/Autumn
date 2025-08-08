# Deployment Guide for Autumn

## Deployment Platform: shinyapps.io

This guide covers deploying the Autumn application to shinyapps.io, RStudio's hosting platform for Shiny applications.

## Prerequisites

### 1. Account Setup
- Create an account at [shinyapps.io](https://www.shinyapps.io/)
- Choose appropriate plan (Free tier allows 5 applications, 25 active hours/month)
- Note your account name for deployment URL: `https://[account-name].shinyapps.io/autumn/`

### 2. Local Requirements
- R (version 4.0 or higher)
- RStudio (recommended for easier deployment)
- rsconnect package: `install.packages("rsconnect")`

### 3. API Keys Configuration
Since environment variables cannot be set directly on shinyapps.io Free/Starter plans, use one of these approaches:

**Option A: Secrets Management (Recommended for paid plans)**
```r
# In your app.R, use rsconnect secrets
rsconnect::setAccountInfo(
  name = "your-account",
  token = "your-token",
  secret = "your-secret"
)
```

**Option B: Secure Configuration File**
Create a `.Renviron` file in your app directory (add to .gitignore):
```
ANTHROPIC_API_KEY=your_anthropic_key
PERPLEXITY_API_KEY=your_perplexity_key
```

**Option C: In-App Configuration**
Use the built-in CSV upload feature for API keys (already implemented)

## Deployment Steps

### 1. Prepare Application

```r
# Install all required packages locally first
install.packages(c(
  "shiny",
  "shinydashboard", 
  "DT",
  "tidyverse",
  "jsonlite",
  "knitr",
  "rmarkdown",
  "httr"
))
```

### 2. Configure rsconnect

```r
# Authorize your account
rsconnect::setAccountInfo(
  name = "your-account-name",
  token = "your-token",
  secret = "your-secret"
)

# These values are found in shinyapps.io dashboard under Account > Tokens
```

### 3. Test Locally

```r
# Run the app locally to ensure it works
shiny::runApp("app.r")
```

### 4. Deploy to shinyapps.io

```r
# Deploy the application
rsconnect::deployApp(
  appDir = ".",
  appName = "autumn",
  account = "your-account-name",
  forceUpdate = TRUE
)
```

### 5. Configure Application Settings

In shinyapps.io dashboard:
1. Navigate to your application
2. Go to Settings tab
3. Configure:
   - **Instance Size**: Minimum 1GB RAM recommended
   - **Max Worker Processes**: 1 (for free tier)
   - **Max Connections**: 5-10 depending on usage
   - **Idle Timeout**: 15 minutes (to conserve active hours)

## File Structure for Deployment

Ensure your directory contains:
```
autumn/
├── app.r                 # Main application file
├── R/                    # R source files
│   ├── enhanced_chat_functions.R
│   ├── perplexity_integration.R
│   ├── ai_responses.R
│   ├── phase1_hypothesis_chat.r
│   ├── phase2_planning_chat.r
│   ├── phase3_implementation_chat.r
│   └── phase4_analysis_chat.r
├── www/                  # Static files
│   ├── styles.css
│   └── styles_chat.txt
├── data/                 # Example data files
│   ├── example_medical_data.rds
│   └── example_lifestyle_data.rds
└── .Renviron            # API keys (if using Option B)
```

## Important Considerations

### 1. Resource Limits
- **Free tier**: 25 active hours/month, 1GB RAM
- **Starter tier**: 100 active hours/month, 1GB RAM
- Monitor usage in dashboard to avoid exceeding limits

### 2. Performance Optimization
- Enable application sleeping when idle
- Consider caching API responses to reduce calls
- Use reactive programming efficiently
- Minimize package dependencies

### 3. Security
- Never hardcode API keys in source code
- Use HTTPS (automatic on shinyapps.io)
- Regularly rotate API keys
- Monitor application logs for suspicious activity

### 4. Data Privacy
- Remember: All data processing remains client-side
- No user data stored on server
- Only aggregated statistics sent to APIs
- Ensure compliance with institutional policies

## Monitoring and Maintenance

### Application Logs
Access logs through shinyapps.io dashboard:
1. Select your application
2. Click "Logs" tab
3. Review for errors or warnings

### Usage Metrics
Monitor in dashboard:
- Active hours consumed
- Number of connections
- Memory usage
- CPU utilization

### Updates and Redeployment
```r
# After making changes locally
rsconnect::deployApp(
  appDir = ".",
  appName = "autumn",
  forceUpdate = TRUE
)
```

## Troubleshooting

### Common Issues

**1. Deployment Fails**
- Check all required packages are listed
- Ensure no absolute file paths in code
- Verify app.r runs locally without errors

**2. API Keys Not Working**
- Verify environment variables are set correctly
- Test API connections using in-app diagnostics
- Check API key validity and rate limits

**3. Application Crashes**
- Review logs for memory errors
- Reduce concurrent user limit
- Optimize reactive expressions

**4. Slow Performance**
- Upgrade instance size if needed
- Implement caching for API calls
- Optimize data processing functions

### Support Resources
- [shinyapps.io Documentation](https://docs.rstudio.com/shinyapps.io/)
- [RStudio Community](https://community.rstudio.com/)
- [Shiny Google Group](https://groups.google.com/g/shiny-discuss)

## Cost Considerations

### Free Tier Limitations
- 5 applications maximum
- 25 active hours/month
- Suitable for testing and light use

### Recommended for Production
- **Starter Plan**: $9/month
  - 100 active hours
  - Better for regular use
- **Basic Plan**: $39/month
  - 500 active hours
  - Custom domains
  - Better performance

## Best Practices

1. **Version Control**: Use Git for code management
2. **Testing**: Thoroughly test before deployment
3. **Documentation**: Keep deployment notes updated
4. **Backup**: Maintain local copies of all code
5. **Monitoring**: Check application weekly for issues
6. **Updates**: Deploy security updates promptly

## Alternative Deployment Options

If shinyapps.io doesn't meet your needs:
- **Shiny Server** (self-hosted)
- **RStudio Connect** (enterprise)
- **Docker containers** (cloud platforms)
- **ShinyProxy** (containerized apps)

Each has different requirements for setup and maintenance.