# Generate Example Data for Scientific Methods Engine Testing

# Set seed for reproducibility
set.seed(42)

# Generate sample size
n <- 200

# Create example dataset for a medical treatment study
example_data <- data.frame(
  # Patient ID
  patient_id = 1:n,
  
  # Treatment group (randomized)
  treatment_group = sample(c("Control", "Treatment"), n, replace = TRUE, prob = c(0.5, 0.5)),
  
  # Demographics
  age = round(rnorm(n, mean = 45, sd = 12)),
  gender = sample(c("Male", "Female"), n, replace = TRUE, prob = c(0.45, 0.55)),
  
  # Baseline measurements
  baseline_score = round(rnorm(n, mean = 75, sd = 15)),
  bmi = round(rnorm(n, mean = 26, sd = 4), 1),
  
  # Comorbidities (potential confounders)
  diabetes = sample(c("Yes", "No"), n, replace = TRUE, prob = c(0.2, 0.8)),
  hypertension = sample(c("Yes", "No"), n, replace = TRUE, prob = c(0.3, 0.7)),
  
  # Additional covariates
  education_level = sample(c("High School", "College", "Graduate"), n, 
                          replace = TRUE, prob = c(0.3, 0.5, 0.2)),
  income_category = sample(c("Low", "Medium", "High"), n, 
                          replace = TRUE, prob = c(0.25, 0.50, 0.25))
)

# Generate outcome with treatment effect and confounding
# True treatment effect: 8 points
# Confounding by age, baseline score, and comorbidities

treatment_effect <- ifelse(example_data$treatment_group == "Treatment", 8, 0)
age_effect <- -0.2 * (example_data$age - 45)
baseline_effect <- 0.4 * (example_data$baseline_score - 75)
diabetes_effect <- ifelse(example_data$diabetes == "Yes", -5, 0)
hypertension_effect <- ifelse(example_data$hypertension == "Yes", -3, 0)

# Add random noise
noise <- rnorm(n, mean = 0, sd = 10)

# Calculate outcome score
example_data$outcome_score <- round(
  80 + treatment_effect + age_effect + baseline_effect + 
  diabetes_effect + hypertension_effect + noise
)

# Ensure outcome is within reasonable bounds
example_data$outcome_score[example_data$outcome_score < 0] <- 0
example_data$outcome_score[example_data$outcome_score > 100] <- 100

# Add some missing values (5% missing)
missing_indices <- sample(1:n, size = n * 0.05)
example_data$outcome_score[missing_indices] <- NA

# Add a categorical outcome for demonstration
example_data$improvement <- ifelse(
  example_data$outcome_score > example_data$baseline_score, 
  "Improved", 
  "Not Improved"
)
example_data$improvement[is.na(example_data$outcome_score)] <- NA

# Save as RDS file
saveRDS(example_data, file = "data/example_medical_data.rds")

# Print summary
cat("Example data generated successfully!\n")
cat("File saved as: data/example_medical_data.rds\n")
cat("\nDataset summary:\n")
cat("- Number of observations:", nrow(example_data), "\n")
cat("- Number of variables:", ncol(example_data), "\n")
cat("- Treatment groups:", table(example_data$treatment_group), "\n")
cat("- Missing outcome values:", sum(is.na(example_data$outcome_score)), "\n")

# Create a second example dataset for associational analysis
set.seed(123)
n2 <- 150

example_data_2 <- data.frame(
  # Subject ID
  subject_id = 1:n2,
  
  # Continuous predictors
  stress_level = round(runif(n2, min = 1, max = 10), 1),
  sleep_hours = round(rnorm(n2, mean = 7, sd = 1.5), 1),
  exercise_hours_per_week = round(rgamma(n2, shape = 2, rate = 0.5), 1),
  
  # Categorical predictors
  diet_quality = sample(c("Poor", "Fair", "Good", "Excellent"), n2,
                       replace = TRUE, prob = c(0.2, 0.3, 0.3, 0.2)),
  smoking_status = sample(c("Never", "Former", "Current"), n2,
                         replace = TRUE, prob = c(0.5, 0.3, 0.2)),
  
  # Demographics
  age_group = sample(c("18-30", "31-45", "46-60", "60+"), n2,
                    replace = TRUE, prob = c(0.25, 0.35, 0.25, 0.15))
)

# Generate health outcome score based on predictors
health_score <- 70 +
  -2 * example_data_2$stress_level +
  3 * (example_data_2$sleep_hours - 7) +
  1.5 * example_data_2$exercise_hours_per_week +
  ifelse(example_data_2$diet_quality == "Poor", -10,
         ifelse(example_data_2$diet_quality == "Fair", -5,
                ifelse(example_data_2$diet_quality == "Good", 5, 10))) +
  ifelse(example_data_2$smoking_status == "Current", -15,
         ifelse(example_data_2$smoking_status == "Former", -5, 0)) +
  rnorm(n2, mean = 0, sd = 8)

example_data_2$health_score <- round(health_score)
example_data_2$health_score[example_data_2$health_score < 0] <- 0
example_data_2$health_score[example_data_2$health_score > 100] <- 100

# Save second dataset
saveRDS(example_data_2, file = "data/example_lifestyle_data.rds")

cat("\n\nSecond example dataset generated!\n")
cat("File saved as: data/example_lifestyle_data.rds\n")
cat("This dataset is suitable for associational analyses.\n")