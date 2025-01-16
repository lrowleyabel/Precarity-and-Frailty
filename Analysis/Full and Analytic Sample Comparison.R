library(dplyr)

setwd("C:/Users/lrowley/University of Strathclyde/SIPBS_MRC Ageing Project - General/ELSA/Analysis/ELSA Later Life Precarity and Frailty")
rm(list = ls())

# Read in analysis dataset being used in the models
df<- read.csv(file = "../../Data/CSV/Submission Version/ELSA Subset with Elastic Net Precarity Index.csv")

# Read in the validation dataset being used in the last stage
validation_df<- read.csv(file = "../../Data/CSV/Submission Version/ELSA Validation Subset with Elastic Net Precarity Index.csv")

# Join the two together
df<- rbind(df, validation_df)

# Read in the full frailty dataset
full_df<- readstata13::read.dta13("../../Data/Dta/Processed Data/ELSA Frailty and Precarity Analysis Dataset.dta")


full_df<- full_df%>%
  filter(inw == "1.resp,alive" & wave > 1 & age >= 50)



# Join wealth and income to the analysis dataset
df<- df%>%
  left_join(full_df%>%
              select(idauniq, wave, hatotb, hitot))

# Create dataframe with each individual's first observation
person_df<- df%>%
  group_by(idauniq)%>%
  slice_min(order_by = wave, n = 1)%>%
  ungroup()


person_df%>%
  summarise(across(c(age, frailty_index, hatotb, hitot), .fns = list(Mean = mean, SD = sd), .names = "{.fn} {.col}"))%>%
  tidyr::pivot_longer(cols = everything())%>%
  tidyr::separate(col = name, into = c("Fun", "Var"), sep = " ")%>%
  select(Var, Fun, value)%>%
  gt::gt()%>%
  gt::fmt_number()

person_df%>%
  count(female)%>%
  mutate(p = n/sum(n))

person_df%>%
  with(table(female))%>%
  prop.table()

full_df%>%
  group_by(idauniq)%>%
  slice_min(order_by = wave, n = 1)%>%
  ungroup()%>%
  summarise(across(c(age, frailty_index, hatotb, hitot), .fns = list(Mean = function(x){mean(x, na.rm = T)}, SD = function(x){sd(x, na.rm = T)}), .names = "{.fn} {.col}"))%>%
  tidyr::pivot_longer(cols = everything())%>%
  tidyr::separate(col = name, into = c("Fun", "Var"), sep = " ")%>%
  select(Var, Fun, value)%>%
  gt::gt()%>%
  gt::fmt_number()

full_df%>%
  group_by(idauniq)%>%
  slice_min(order_by = wave, n = 1)%>%
  ungroup()%>%
  nrow()
  with(table(gender))%>%
  prop.table()






