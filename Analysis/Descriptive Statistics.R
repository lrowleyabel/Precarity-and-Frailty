library(dplyr)
library(tidyr)
library(gt)

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

# Select relevant variables (replace wealth percentile and income percentile with the raw values, so that they have meaningful summary statistics)
stressors<- c("hatotb", "hitot", "not_enough_future",  "benefits", "has_no_occ_pension", "has_no_personal_pension", "reduced_pension", "ever_unemployed", "ever_invol_job_loss", "ever_unpaid_care", "ever_left_job_to_care", "ever_mixed_work_care", "widowed", "divorced", "lives_alone", "renting", "housing_problems", "ever_homeless", "fuel_poverty", "food_insecurity", "not_enough_money")

df<- df%>%
  select(idauniq, wave, frailty_index, age, gender, all_of(stressors))

df<- df%>%
  rename(wealth = hatotb,
         income = hitot)

# Filter to rows without missing data
df<- df%>%
  filter(if_all(everything(), ~!is.na(.x)))

# Look at sample size
paste("Number of observations:", nrow(df))
paste("Number of individuals:", n_distinct(df$idauniq))

# Create a table of descriptve statistics for individuals at baseline (i.e. at the first entrance into ELSA)
continuous_vars<- df%>%
  group_by(idauniq)%>%
  slice_min(wave, n = 1)%>%
  ungroup()%>%
  summarise(across(c(age, frailty_index, wealth, income), list(min = min, max = max, median = median, mean = mean, sd = sd), .names = "{.col}__{.fn}"))%>%
  pivot_longer(cols = everything(), names_to = "name", values_to = "value")%>%
  separate_wider_delim(cols = name, names = c("variable", "statistic"), delim = "__")
  

cat_vars<- df%>%
  group_by(idauniq)%>%
  slice_min(wave, n = 1)%>%
  ungroup()%>%
  count(gender)%>%
  mutate(proportion = 100*n/sum(n))%>%
  pivot_longer(cols = c(n, proportion), names_to = "statistic", values_to = "value")%>%
  rename(variable = gender)


rbind(continuous_vars, cat_vars)%>%
gt()%>%
  fmt_number(decimals = 2)

