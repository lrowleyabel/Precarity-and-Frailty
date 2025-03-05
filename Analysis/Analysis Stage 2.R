library(dplyr)
library(ggplot2)
library(patchwork)
library(caret)
library(glmnet)

setwd("C:/Users/lrowley/OneDrive - University of Edinburgh/Published Paper GitHub Repositories/New Frailty and Social Risks/Analysis")
rm(list = ls())


#### Setup ####

# Read in frailty data with social risk markers
df<- readstata13::read.dta13("../Data/Processed Data/ELSA Frailty and Social Risks Analysis Dataset.dta", nonint.factors = T)

# Drop any rows with missing frailty outcome
df<- df%>%
  filter(!is.na(frailty_index))

# Drop those below 50
df<- df%>%
  filter(age >= 50)

# Create dummy variables
df<- df%>%
  fastDummies::dummy_columns(select_columns = c("gender", "ever_unpaid_care", "housing_problems", "food_insecurity", "not_enough_money"), remove_first_dummy = T, remove_selected_columns = T, ignore_na = T)

# Clean up the names of the created dummy variables
colnames(df)<- colnames(df)%>%
  stringr::str_replace_all("\\-", " ")%>%
  stringr::str_squish()%>%
  stringr::str_replace_all(" ", "_")

# Create age-squared variable
df<- df%>%
  mutate(agesqrd = age*age)

# Scale the continuous variables
df<- df%>%
  mutate(across(c(wealth_percentile, income_percentile, not_enough_future), ~(.x-mean(.x, na.rm = T))/sd(.x, na.rm = T)))

# Select relevant variables
stressors<- c("wealth_percentile", "income_percentile", "not_enough_future",  "benefits", "has_no_occ_pension", "has_no_personal_pension", "reduced_pension", "ever_unemployed", "ever_invol_job_loss", "ever_unpaid_care_0_9_hours_per_week", "ever_unpaid_care_10_34_hours_per_week", "ever_unpaid_care_35_hours_per_week_or_more", "ever_left_job_to_care", "ever_mixed_work_care", "widowed", "divorced", "lives_alone", "renting", "housing_problems_1_2_problems", "housing_problems_3_4_problems", "housing_problems_5_problems_or_more", "ever_homeless", "fuel_poverty", "food_insecurity_At_least_yearly", "food_insecurity_At_least_monthly", "not_enough_money_Rarely", "not_enough_money_Sometimes", "not_enough_money_Often", "not_enough_money_Most_of_the_time")

df<- df%>%
  select(idauniq, wave, frailty_index, age, agesqrd, gender_Women, all_of(stressors))

# Check data
head(df, 10)


#### Analysis Stage 2 - Develop Later Life Precarity Index ####


# Create dataset of stressors at Wave 2, with all possible interactions and quadratic terms
elnet_df<- df%>%
  filter(wave == 2)%>%
  select(frailty_index, all_of(stressors))%>%
  filter(if_all(everything(), ~!is.na(.x)))

quads<- sapply(c("wealth_percentile", "income_percentile", "not_enough_future"), function(x){paste0("I(", x, "^2)")})%>%
  paste0(collapse = " + ")

f<- as.formula(paste0("frailty_index ~ .^2 + ", quads))

model_df<- model.matrix(f, elnet_df)[,-1]


# Use train function from caret to find optimal alpha value using five-fold cross-validation
set.seed(1538)

train_cv = trainControl(method = "cv", number = 5)

cv_results<- train(x = model_df, y = elnet_df$frailty_index, method = "glmnet", trControl = train_cv, tuneLength = 10)

cv_results$bestTune

best_alpha<- cv_results$bestTune$alpha

# Use cross-validation to find the optimal lambda value
cv_fit<- cv.glmnet(x = model_df, y = elnet_df$frailty_index, alpha = best_alpha)

plot(cv_fit)

coef(cv_fit, s = "lambda.min")


# Save the model
save(cv_fit, file = "../Models/Elastic Net FI Model.Rda")
load("../Models/Elastic Net FI Model.Rda")

# Generate predicted frailty
elnet_pred<- predict(cv_fit, newx = model_df, s = "lambda.min")

# Look at the R-squared 
cor(elnet_pred, elnet_df$frailty_index)^2
cor.test(elnet_pred, elnet_df$frailty_index)

# Join the precarity index to the data
elnet_df$precarity<- elnet_pred[,1]

# Plot the distribution of the precarity index
pal<- RColorBrewer::brewer.pal(n = 8, "YlGnBu")
monochromeR::view_palette(pal)

p1<- elnet_df%>%
  ggplot(aes(x = precarity))+
  geom_histogram(fill = pal[7], colour = "white")+
  theme_minimal()+
  labs(x = "Later Life Precarity Index", y = "Count of individuals", title = "A")+
  theme(plot.background = element_rect(color = "white", fill = "white"),
        text = element_text(size = 8),
        axis.title.x = element_text(margin = margin(10,0,10,0)),
        axis.title.y = element_text(margin = margin(0,10,0,10)),
        #axis.text = element_text(size = 10),
        panel.grid.major = element_line(linewidth = 0.25),
        panel.grid.minor = element_line(linewidth = 0.25),
        plot.title.position = "plot",
        plot.title = element_text(margin = margin(10,5,10,5), size = 8))

p1

ggsave(plot = p1, "../Plots/Figure 2a - Histogram of LLPI.png", units = "cm", width = 12, height = 9, dpi = 300)


# Plot the association of the precarity index with the frailty index
p2<- elnet_df%>%
  ggplot(aes(x = precarity, y = frailty_index))+
  geom_point(size = 0.5, colour = pal[5], alpha = 0.25)+
  geom_smooth(method = "lm", colour = pal[7])+
  theme_minimal()+
  labs(x = "Later Life Precarity Index", y = "Frailty Index", title = "B")+
  theme(plot.background = element_rect(color = "white", fill = "white"),
        text = element_text(size = 8),
        axis.title.x = element_text(margin = margin(10,0,10,0)),
        axis.title.y = element_text(margin = margin(0,10,0,10)),
        #axis.text = element_text(size = 10),
        panel.grid.major = element_line(linewidth = 0.25),
        panel.grid.minor = element_line(linewidth = 0.25),
        plot.title.position = "plot",
        plot.title = element_text(margin = margin(10,5,10,5), size = 8))

p2

ggsave(plot = p2, "../Plots/Figure 2b - Scatter Plot of LLPI and FI.png", units = "cm", width = 12, height = 9, dpi = 300)

p<- p1 + p2

ggsave(plot = p, "../Plots/Figure 2.jpg", units = "cm", width = 16, height = 9, dpi = 300)

# Calculate the precarity index for all waves in the data
df<- df%>%
  select(idauniq, wave, age, agesqrd, gender_Women, frailty_index, all_of(stressors))%>%
  filter(if_all(everything(), ~!is.na(.x)))

# Generate the interaction terms and quadratic terms
f<- as.formula(paste0("frailty_index ~ .^2 + ", quads))

model_df<- model.matrix(f, df%>%
                          select(frailty_index, all_of(stressors)))[,-1]

# Generate the Precarity Index using the elastic net model
precarity<- predict(cv_fit, newx = model_df, s = "lambda.min")

df$precarity<- precarity[,1]

# Select relevant variables
df<- df%>%
  select(idauniq, wave, frailty_index, precarity, age, agesqrd, gender_Women)

# Export the data
write.csv(df, row.names = F, file = "../Data/Processed Data/ELSA Subset with Elastic Net Precarity Index.csv")

