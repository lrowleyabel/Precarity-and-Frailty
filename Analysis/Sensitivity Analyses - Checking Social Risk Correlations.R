library(dplyr)
library(psych)

setwd("C:/Users/lrowley/OneDrive - University of Edinburgh/Published Paper GitHub Repositories/New Frailty and Social Risks/Analysis")
rm(list = ls())


# Read in frailty data with social risk markers
df<- readstata13::read.dta13("../Data/Processed Data/ELSA Frailty and Social Risks Analysis Dataset.dta", nonint.factors = T)

# Drop any rows with missing frailty outcome
df<- df%>%
  filter(!is.na(frailty_index))

# Drop those below 50
df<- df%>%
  filter(age >= 50)

# Separate the social risk variables into continuous, dichotomous and polytomous
continuous_vars<- c("wealth_percentile", "income_percentile", "not_enough_future")
dichotomous_vars<- c("benefits", "has_no_occ_pension", "has_no_personal_pension", "reduced_pension", "invol_job_loss", "ever_unemployed", "ever_left_job_to_care", "ever_mixed_work_care", "widowed", "divorced", "lives_alone", "renting", "ever_homeless", "fuel_poverty")
polytomous_vars<- c("ever_unpaid_care", "housing_problems", "food_insecurity", "not_enough_money")

# Create a separate dataframe with just the social risk variables
risks_df<- df%>%
  select(all_of(c(continuous_vars, dichotomous_vars, polytomous_vars)))

# Ensure factors/characters are converted to numeric
risks_df<- risks_df%>%
  mutate(across(where(is.character), ~as.numeric(factor(.x))))%>%
  mutate(across(where(is.factor), ~as.numeric(.x)))

# Calculate the correlation matrix using appropriate correlation measures for each data type
cormat<- mixedCor(data = risks_df, c = continuous_vars, p = polytomous_vars, d = dichotomous_vars)

# Isolate pairs of variables with correlations >= 0.7
cormat$rho[abs(cormat$rho)<0.7]<- NA

cormat$rho
