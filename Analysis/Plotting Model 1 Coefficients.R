library(dplyr)
library(tidyr)
library(ggplot2)
library(readxl)

setwd("C:/Users/lrowley/OneDrive - University of Edinburgh/Published Paper GitHub Repositories/New Frailty and Social Risks/Analysis")
rm(list = ls())

estimates<- read_excel(path = "../Model Results/Model 1.xlsx")

estimates$term[13]<- "Does not provide unpaid care"
estimates$term[24]<- "No problems"
estimates$term[29]<- "Never - food insecurity"
estimates$term[32]<- "Never - enough money"

estimates<- estimates%>%
  mutate(variable = case_when(term == "wealth_percentile" ~ "**Wealth percentile**",
                              term == "income_percentile" ~ "**Income percentile**",
                              term == "benefits" ~ "**Receiving benefits (ref: No)**: _Yes_",
                              term == "has_no_occ_pension" ~ "**No occupational pension (ref: No)**: _Yes_",
                              term == "has_no_personal_pension" ~ "**No personal pension (ref: No)**: _Yes_",
                              term == "reduced_pension" ~ "**Retried on reduced pension (ref: No)**: _Yes_",
                              term == "ever_unemployed" ~ "**Ever unemployed (ref: No)**: _Yes_",
                              term == "ever_invol_job_loss" ~ "**Ever experienced job loss (ref: No)**: _Yes_",
                              term == "0 - 9 hours per week" ~ "**Maximum unpaid caregiving (ref: None)**: _0 - 9 hours per week_",
                              term == "10 - 34 hours per week" ~ "_10 - 34 hours per week_",
                              term == "35 hours per week or more" ~ "_35 hours per week or more_",
                              term == "ever_left_job_to_care" ~ "**Ever left job to provide unpaid care (ref: No)**: _Yes_",
                              term == "ever_mixed_work_care" ~ "**Ever mixed work and unpaid care (ref: No)**: _Yes_",
                              term == "widowed" ~ "**Widowed (ref: No)**: _Yes_", 
                              term == "divorced" ~ ",**Divorced/separated (ref: No)**: _Yes_",
                              term == "lives_alone" ~ "**Lives alone (ref: No)**: _Yes_",
                              term == "renting" ~ "**Renting home (ref: No)**: _Yes_",
                              term == "1 - 2 problems" ~ "**Number of housing problems (ref: None)**: _1 - 2 problems_",
                              term == "3 - 4 problems" ~ "_3 - 4 problems_",
                              term == "5 problems or more" ~ "_5 problems or more_",
                              term == "ever_homeless" ~ "**Ever experienced homelessness (ref: No)**: _Yes_",
                              term == "fuel_poverty" ~ "**Fuel poverty (ref: No)**: _Yes_",
                              term == "At least yearly" ~ "**Frequency of food insecurity (ref: Never)**: _At least yearly_",
                              term == "At least monthly" ~ "_At least monthly_",
                              term == "Rarely" ~ "**Frequency of inability to cover needs (ref: Never)**: _Rarely_",
                              term == "Sometimes" ~ "_Sometimes_",
                              term == "Often" ~ "_Often_",
                              term == "Most of the time" ~ "_Most of the time_",
                              term == "not_enough_future" ~ "**Future financial insecurity**",
                              term == "age" ~ "**Age**",
                              term == "age # age" ~ "**Age-squared**",
                              T ~ term))

ordered_vars<- c("**Wealth percentile**",
                 "**Income percentile**",
                 "**Future financial insecurity**",
                 "**Receiving benefits (ref: No)**: _Yes_",
                 "**Fuel poverty (ref: No)**: _Yes_",
                 "**Frequency of food insecurity (ref: Never)**: _At least yearly_",
                 "_At least monthly_",
                 "**Frequency of inability to cover needs (ref: Never)**: _Rarely_",
                 "_Sometimes_",
                 "_Often_",
                 "_Most of the time_",
                 "**No occupational pension (ref: No)**: _Yes_",
                 "**No personal pension (ref: No)**: _Yes_",
                 "**Retried on reduced pension (ref: No)**: _Yes_",
                 "**Ever unemployed (ref: No)**: _Yes_",
                 "**Ever experienced job loss (ref: No)**: _Yes_",
                 "**Renting home (ref: No)**: _Yes_",
                 "**Number of housing problems (ref: None)**: _1 - 2 problems_",
                 "_3 - 4 problems_",
                 "_5 problems or more_",
                 "**Ever experienced homelessness (ref: No)**: _Yes_",
                 "**Widowed (ref: No)**: _Yes_", 
                 ",**Divorced/separated (ref: No)**: _Yes_",
                 "**Lives alone (ref: No)**: _Yes_",
                 "**Maximum unpaid caregiving (ref: None)**: _0 - 9 hours per week_",
                 "_10 - 34 hours per week_",
                 "_35 hours per week or more_",
                 "**Ever left job to provide unpaid care (ref: No)**: _Yes_",
                 "**Ever mixed work and unpaid care (ref: No)**: _Yes_")

estimates<- estimates%>%
  mutate(variable = factor(variable, levels = rev(ordered_vars)))


estimates<- estimates%>%
  mutate(domain = case_when(term %in% c("wealth_percentile", "income_percentile", "not_enough_future", "benefits", "fuel_poverty", "Never - food insecurity", "At least yearly", "At least monthly", "Never - not enough", "Rarely", "Sometimes", "Often", "Most of the time") ~ "Finances",
                            term %in% c("has_no_occ_pension", "has_no_personal_pension", "reduced_pension") ~ "Pensions",
                            term %in% c("ever_unemployed", "ever_invol_job_loss") ~ "Emplymt.",
                            term %in% c("0 - 9 hours per week", "10 - 34 hours per week", "35 hours per week or more", "ever_left_job_to_care", "ever_mixed_work_care") ~ "Unpaid caregiving",
                            term %in% c("widowed", "divorced", "lives_alone") ~ "Relationships",
                            term %in% c("renting", "1 - 2 problems", "3 - 4 problems", "5 problems or more", "ever_homeless") ~ "Housing")%>%
           factor(levels = c("Finances", "Pensions", "Emplymt.", "Housing", "Relationships", "Unpaid caregiving")))

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
  geom_errorbar(aes(xmin = conf.low, xmax = conf.high, y = variable), width = 0)+
  geom_point(aes(x = beta, y = variable), position = position_dodge(width = 0.5), size = 2, color = pal[7])+
  scale_color_manual(values = pal)+
  theme_minimal()+
  theme(legend.position = "bottom",
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 10),
        plot.background = element_rect(color = "white", fill = "white"),
        text = element_text(size = 10),
        axis.title.x = element_text(margin = margin(10,0,10,0), size = 10),
        axis.title.y = element_text(margin = margin(0,10,0,10), size = 10),
        axis.text = ggtext::element_markdown(size = 10),
        plot.title.position = "plot",
        plot.title = element_text(margin = margin(10,10,10,10)),
        strip.text.y = element_text(size = 10),
        strip.background = element_rect())+
  labs(x = "Beta", y = "")+
  facet_grid(domain ~ ., scales = "free_y", space = "free")

ggsave("../Plots/Figure 1.jpg", units = "in", width = 9, height = 10, dpi = 500)
