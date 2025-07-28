library(dplyr)
library(tidyr)
library(gt)

setwd("C:/Users/lrowley/OneDrive - University of Edinburgh/Published Paper GitHub Repositories/New Frailty and Social Risks/Analysis")
rm(list = ls())

# Read in frailty data with social risk markers
full_df<- readstata13::read.dta13("../Data/Processed Data/ELSA Frailty and Social Risks Analysis Dataset.dta", nonint.factors = T)

# Filter to just Waves 2 - 9
full_df<- full_df%>%
  filter(wave >= 2 & wave <= 9)

# Filter to only waves where an individual responded
full_df<- full_df%>%
  filter(inw == "1.resp,alive")

# Look at the total number of individuals interviewed across Waves 2 - 9
n_distinct(full_df$idauniq)

# Drop any rows with missing frailty outcome
df<- full_df%>%
  filter(!is.na(frailty_index))

# Drop those below 50
df<- df%>%
  filter(age >= 50)

# Select relevant variables (replace wealth percentile and income percentile with the raw values, so that they have meaningful summary statistics)
stressors<- c("hatotb", "hitot", "not_enough_future",  "benefits", "has_no_occ_pension", "has_no_personal_pension", "reduced_pension", "ever_unemployed", "ever_invol_job_loss", "ever_unpaid_care", "ever_left_job_to_care", "ever_mixed_work_care", "widowed", "divorced", "lives_alone", "renting", "housing_problems", "ever_homeless", "fuel_poverty", "food_insecurity", "not_enough_money")

df<- df%>%
  select(idauniq, wave, frailty_index, age, gender, all_of(stressors))

# Filter to rows without missing data
df<- df%>%
  filter(if_all(everything(), ~!is.na(.x)))


# Look at the sample sizes of the full and analytic sample
n_distinct(full_df$idauniq)
n_distinct(df$idauniq)


# For the purpose of comparing the full and analytic samples descriptive sttistics, we exclude individuals aged under 50 from the full sample too
full_df<- full_df%>%
  filter(age >= 50)

# Rename the wealth and income variables
full_df<- full_df%>%
  rename(wealth = hatotb,
         income = hitot)

df<- df%>%
  rename(wealth = hatotb,
         income = hitot)

# Create a dataset with the both the full and analytic sample
full_and_analytic_df<- rbind(full_df%>%
                               filter(inw == "1.resp,alive")%>%
                               group_by(idauniq)%>%
                               slice_min(wave, n = 1)%>%
                               ungroup()%>%
                               select(all_of(colnames(df)))%>%
                               mutate(dataset = "full"), df%>%
                               group_by(idauniq)%>%
                               slice_min(wave, n = 1)%>%
                               ungroup()%>%
                               mutate(dataset = "analytic"))

# Look at the descriptive statistics for the continuous variables in the full and analytic datasets and test the difference
tableone::CreateContTable(data = full_and_analytic, vars = c("age", "frailty_index", "wealth", "income"), strata = "dataset")

# Look at the descriptive statistics for the categorical variable in the full and analytic datasets and test the difference
tableone::CreateCatTable(data = full_and_analytic, vars = c("gender"), strata = "dataset")
