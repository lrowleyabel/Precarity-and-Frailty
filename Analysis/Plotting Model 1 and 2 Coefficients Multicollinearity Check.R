library(dplyr)
library(tidyr)
library(ggplot2)
library(readxl)

setwd("C:/Users/lrowley/University of Strathclyde/SIPBS_MRC Ageing Project - General/ELSA/Analysis/ELSA Precarity and Frailty Paper Code")
rm(list = ls())

male_estimates<- read_excel(path = "Model Results/Multicollinearity Check Model 1.xlsx")%>%
  mutate(Sex = "Men")

female_estimates<- read_excel(path = "Model Results/Multicollinearity Check Model 2.xlsx")%>%
  mutate(Sex = "Women")

estimates<- rbind(male_estimates, female_estimates)

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
                              term == "age" ~ "Age",
                              term == "age # age" ~ "Age-squared",
                              T ~ term))

ordered_vars<- c("Age",
                 "Age-squared",
                 "Wealth scale (higher = less wealth)",
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
                 "Renting home",
                 "Housing problems scale",
                 "Ever experienced homelessness",
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


estimates<- estimates%>%
  mutate(beta = stringr::str_remove_all(Coefficient, "\\*")%>%
           as.numeric())%>%
  separate(`95% CI`, sep = ",", into = c("conf.low", "conf.high"))%>%
  mutate(conf.low = as.numeric(conf.low),
         conf.high = as.numeric(conf.high))


pal<- RColorBrewer::brewer.pal(n = 8, "YlGnBu")

estimates%>%
  filter(!variable %in% c("Age", "Age-squared"))%>%
  filter(!is.na(variable))%>%
  ggplot()+
  geom_vline(xintercept = 0, linetype = 2)+
  geom_errorbar(aes(xmin = conf.low, xmax = conf.high, y = variable, group= Sex), position = position_dodge(width = 0.5), width = 0)+
  geom_point(aes(x = beta, y = variable, group = Sex, color = Sex), position = position_dodge(width = 0.5), size = 2)+
  scale_color_manual(values = pal[c(5,8)])+
  theme_minimal()+
  theme(legend.position = "bottom",
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 10),
        plot.background = element_rect(color = "white", fill = "white"),
        text = element_text(size = 10),
        axis.title.x = element_text(margin = margin(10,0,10,0), size = 10),
        axis.title.y = element_text(margin = margin(0,10,0,10), size = 10),
        axis.text = element_text(size = 10),
        plot.title.position = "plot",
        plot.title = element_text(margin = margin(10,10,10,10)))+
  labs(x = "Beta", y = "")

ggsave("Plots/Supplementary Figure 1 - Models 1 and 2 Coefficients Multicollinearity Check.png", units = "in", width = 7, height = 8, dpi = 500)
