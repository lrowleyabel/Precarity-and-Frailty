rm(list = ls())

estimates<- read_excel("Model Results/Preliminary Models.xlsx", skip = 1)

colnames(estimates)[1]<- "term"

estimates<- estimates%>%
  separate(term, into = c("term", "sex"), sep = " ")


estimates<- estimates%>%
  mutate(variable = case_when(term == "non_home_wealth_scaled" ~ "Wealth scale (higher = less wealth)",
                              term == "home_wealth_scaled" ~ "Home value scale (higher = less valuable)",
                              term == "income_scaled" ~ "Income scale (higher = lower income)",
                              term == "has_no_occ_pension" ~ "No occupational pension",
                              term == "has_no_personal_pension" ~ "No personal pension",
                              term == "reduced_pension" ~ "Retried on reduced pension",
                              term == "receiving_benefits" ~ "Receiving benefits",
                              term == "ever_unemployed" ~ "Ever unemployed",
                              term == "ever_invol_job_loss" ~ "Ever experienced job loss",
                              term == "ever_left_job_to_care" ~ "Ever left job to provide care",
                              term == "ever_mixed_work_care" ~ "Ever mixed work and care",
                              term == "ever_int_unpaid_care" ~ "Ever provided intense unpaid care",
                              term == "widowed" ~ "Widowed", 
                              term == "divorced" ~ "Divorced/separated",
                              term == "lives_alone" ~ "Lives alone",
                              term == "renting" ~ "Renting home",
                              term == "housing_problems" ~ "Housing problems scale",
                              term == "ever_homeless" ~ "Ever experienced homelessness",
                              term == "fuel_poverty" ~ "Fuel poverty",
                              term == "food_insecurity" ~ "Food insecurity",
                              term == "not_enough_money" ~ "Current financial security scale (higher = less secure)",
                              term == "not_enough_future" ~ "Future financial security scale (higher = less secure)",
                              term == "income_decrease" ~ "Experienced income decrease",
                              term == "mortgage" ~ "Paying mortgage",
                              term == "overcrowded" ~ "Overcrowded housing",
                              term == "ever_second_job" ~ "Ever worked second job",
                              term == "ever_selfemployed" ~ "Ever self-employed",
                              term == "ever_parttime" ~ "Ever worked part-time",
                              term == "ever_agency_worker" ~ "Ever agency worker",
                              term == "max_emp_insecurity" ~ "Employment insecurity scale",
                              term == "invol_move" ~ "Involuntarily moved home",
                              term == "ever_invol_retired" ~ "Involuntary retirement",
                              term == "no_central_heating" ~ "No central heating",
                              T ~ term))

ordered_vars<- c("Wealth scale (higher = less wealth)",
                 "Income scale (higher = lower income)",
                 "Home value scale (higher = less valuable)",
                 "Receiving benefits",
                 "Current financial security scale (higher = less secure)",
                 "Future financial security scale (higher = less secure)",
                 "Experienced income decrease",
                 "Fuel poverty",
                 "Food insecurity",
                 "No occupational pension",
                 "No personal pension",
                 "Retried on reduced pension",
                 "Ever unemployed",
                 "Ever experienced job loss",
                 "Ever worked second job",
                 "Ever worked part-time",
                 "Ever self-employed",
                 "Ever agency worker",
                 "Employment insecurity scale",
                 "Involuntary retirement",
                 "Renting home",
                 "Paying mortgage",
                 "Housing problems scale",
                 "Ever experienced homelessness",
                 "Overcrowded housing",
                 "No central heating",
                 "Involuntarily moved home",
                 "Widowed",
                 "Divorced/separated",
                 "Lives alone",
                 "Ever left job to provide care",
                 "Ever mixed work and care",
                 "Ever provided intense unpaid care")

estimates<- estimates%>%
  mutate(variable = factor(variable, levels = rev(ordered_vars)))

estimates<- estimates%>%
  mutate(Coefficient = case_when(is.na(as.numeric(Coefficient)) ~ Coefficient,
                                 T ~ as.character(round(as.numeric(Coefficient), 3))))
estimates%>%
  pivot_wider(id_cols = variable, names_from = Sex, values_from = c(Coefficient, `95% CI`))%>%
  select(variable, "Coefficient_Men", "95% CI_Men", "Coefficient_Women", "95% CI_Women")%>%
  gt::gt()



library(stringr)

rm(list = ls())

load("Models/Elastic Net FI Model.Rda")

estimates<- data.frame(v2 = rownames(coef(cv_fit, s = "lambda.min")), beta = as.numeric(coef(cv_fit, s = "lambda.min")))

estimates<- estimates%>%
  separate(v2, into = c("v1", "v2"), sep = ":")

estimates<- estimates%>%
  mutate(v2 = case_when(str_detect(v1, "2") ~ v1%>%
                          str_remove("I\\(")%>%
                          str_remove("\\^2\\)"),
                        T ~ v2))%>%
  mutate(v1 = case_when(str_detect(v1, "2") ~ v1%>%
                          str_remove("I\\(")%>%
                          str_remove("\\^2\\)"),
                        T ~ v1))


estimates<- estimates%>%
  mutate(v1 = case_when(v1 == "non_home_wealth_scaled" ~ "Wealth scale",
                        v1 == "home_wealth_scaled" ~ "Home value scale",
                        v1 == "income_scaled" ~ "Income scale",
                        v1 == "has_no_occ_pension" ~ "No occupational pension",
                        v1 == "has_no_personal_pension" ~ "No personal pension",
                        v1 == "reduced_pension" ~ "Retried on reduced pension",
                        v1 == "receiving_benefits" ~ "Receiving benefits",
                        v1 == "ever_unemployed" ~ "Ever unemployed",
                        v1 == "ever_invol_job_loss" ~ "Ever experienced job loss",
                        v1 == "ever_left_job_to_care" ~ "Ever left job to provide care",
                        v1 == "ever_mixed_work_care" ~ "Ever mixed work and care",
                        v1 == "ever_int_unpaid_care" ~ "Ever provided intense unpaid care",
                        v1 == "widowed" ~ "Widowed", 
                        v1 == "divorced" ~ "Divorced",
                        v1 == "lives_alone" ~ "Lives alone",
                        v1 == "renting" ~ "Renting home",
                        v1 == "housing_problems" ~ "Housing problems scale",
                        v1 == "ever_homeless" ~ "Ever experienced homelessness",
                        v1 == "fuel_poverty" ~ "Fuel poverty",
                        v1 == "food_insecurity" ~ "Food insecurity",
                        v1 == "not_enough_money" ~ "Current financial security scale",
                        v1 == "not_enough_future" ~ "Future financial security scale",
                        v1 == "income_decrease" ~ "Experienced income decrease",
                        v1 == "mortgage" ~ "Paying mortgage",
                        v1 == "overcrowded" ~ "Overcrowded housing",
                        v1 == "ever_second_job" ~ "Ever worked second job",
                        v1 == "ever_selfemployed" ~ "Ever self-employed",
                        v1 == "ever_parttime" ~ "Ever worked part-time",
                        v1 == "ever_agency_worker" ~ "Ever agency worker",
                        v1 == "max_emp_insecurity" ~ "Employment insecurity scale",
                        v1 == "invol_move" ~ "Involuntarily moved home",
                        v1 == "ever_invol_retired" ~ "Involuntary retirement",
                        v1 == "no_central_heating" ~ "No central heating",
                        T ~ v1))


estimates<- estimates%>%
  mutate(v2 = case_when(v2 == "non_home_wealth_scaled" ~ "Wealth scale",
                        v2 == "home_wealth_scaled" ~ "Home value scale",
                        v2 == "income_scaled" ~ "Income scale",
                        v2 == "has_no_occ_pension" ~ "No occupational pension",
                        v2 == "has_no_personal_pension" ~ "No personal pension",
                        v2 == "reduced_pension" ~ "Retried on reduced pension",
                        v2 == "receiving_benefits" ~ "Receiving benefits",
                        v2 == "ever_unemployed" ~ "Ever unemployed",
                        v2 == "ever_invol_job_loss" ~ "Ever experienced job loss",
                        v2 == "ever_left_job_to_care" ~ "Ever left job to provide care",
                        v2 == "ever_mixed_work_care" ~ "Ever mixed work and care",
                        v2 == "ever_int_unpaid_care" ~ "Ever provided intense unpaid care",
                        v2 == "widowed" ~ "Widowed", 
                        v2 == "divorced" ~ "Divorced",
                        v2 == "lives_alone" ~ "Lives alone",
                        v2 == "renting" ~ "Renting home",
                        v2 == "housing_problems" ~ "Housing problems scale",
                        v2 == "ever_homeless" ~ "Ever experienced homelessness",
                        v2 == "fuel_poverty" ~ "Fuel poverty",
                        v2 == "food_insecurity" ~ "Food insecurity",
                        v2 == "not_enough_money" ~ "Current financial security scale",
                        v2 == "not_enough_future" ~ "Future financial security scale",
                        v2 == "income_decrease" ~ "Experienced income decrease",
                        v2 == "mortgage" ~ "Paying mortgage",
                        v2 == "overcrowded" ~ "Overcrowded housing",
                        v2 == "ever_second_job" ~ "Ever worked second job",
                        v2 == "ever_selfemployed" ~ "Ever self-employed",
                        v2 == "ever_parttime" ~ "Ever worked part-time",
                        v2 == "ever_agency_worker" ~ "Ever agency worker",
                        v2 == "max_emp_insecurity" ~ "Employment insecurity scale",
                        v2 == "invol_move" ~ "Involuntarily moved home",
                        v2 == "ever_invol_retired" ~ "Involuntary retirement",
                        v2 == "no_central_heating" ~ "No central heating",
                        T ~ v2))

estimates<- estimates%>%
  mutate(Variable = case_when(!is.na(v2) ~ paste(v1, "*", v2),
                              T ~ v1))

estimates%>%
  select(Variable, beta)%>%
  gt::gt()%>%
  gt::fmt_number(decimals = 4)
