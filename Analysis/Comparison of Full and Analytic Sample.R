library(dplyr)
library(tidyr)
library(gt)

setwd("C:/Users/lrowley/OneDrive - University of Edinburgh/Published Paper GitHub Repositories/New Frailty and Social Risks/Analysis")
rm(list = ls())

# Read in frailty data with social risk markers
full_df<- readstata13::read.dta13("../Data/Processed Data/ELSA Frailty and Social Risks Analysis Dataset.dta", nonint.factors = T)

# Drop those below 50
full_df<- full_df%>%
  filter(age >= 50)


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


full_df<- full_df%>%
  rename(wealth = hatotb,
         income = hitot)

df<- df%>%
  rename(wealth = hatotb,
         income = hitot)


full_sample_cont_variables<- full_df%>%
  filter(inw == "1.resp,alive")%>%
  group_by(idauniq)%>%
  slice_min(wave, n = 1)%>%
  ungroup()%>%
  summarise(across(c(age, frailty_index, wealth, income), list(mean = ~mean(.x, na.rm = T)), .names = "{.col}__{.fn}"))%>%
  pivot_longer(cols = everything(), names_to = "name", values_to = "full_sample_value")%>%
  separate_wider_delim(cols = name, names = c("variable", "statistic"), delim = "__")

analytic_sample_cont_variables<- df%>%
  group_by(idauniq)%>%
  slice_min(wave, n = 1)%>%
  ungroup()%>%
  summarise(across(c(age, frailty_index, wealth, income), list(mean = ~mean(.x, na.rm = T)), .names = "{.col}__{.fn}"))%>%
  pivot_longer(cols = everything(), names_to = "name", values_to = "analytic_sample_value")%>%
  separate_wider_delim(cols = name, names = c("variable", "statistic"), delim = "__")


cont_variables<- left_join(full_sample_cont_variables, analytic_sample_cont_variables)


cont_variables%>%
  gt()%>%
  fmt_number(decimals = 2)


full_sample_cat_variables<- full_df%>%
  filter(inw == "1.resp,alive")%>%
  group_by(idauniq)%>%
  slice_min(wave, n = 1)%>%
  ungroup()%>%
  count(gender)%>%
  mutate(proportion = 100*n/sum(n))%>%
  select(-n)%>%
  pivot_longer(cols = c(proportion), names_to = "statistic", values_to = "full_sample_value")%>%
  rename(variable = gender)


analytic_sample_cat_variables<- df%>%
  group_by(idauniq)%>%
  slice_min(wave, n = 1)%>%
  ungroup()%>%
  count(gender)%>%
  mutate(proportion = 100*n/sum(n))%>%
  select(-n)%>%
  pivot_longer(cols = c(proportion), names_to = "statistic", values_to = "analytic_sample_value")%>%
  rename(variable = gender)

cat_variables<- left_join(full_sample_cat_variables, analytic_sample_cat_variables)

cat_variables%>%
  gt()%>%
  fmt_number(decimals = 2)

tbl<- rbind(cont_variables, cat_variables)

tbl%>%
  gt()%>%
  fmt_number(decimals = 2)
