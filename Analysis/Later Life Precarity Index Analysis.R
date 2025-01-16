library(dplyr)
library(ggplot2)
library(patchwork)
library(caret)
library(glmnet)

setwd("C:/Users/lrowley/University of Strathclyde/SIPBS_MRC Ageing Project - General/ELSA/Analysis/ELSA Precarity and Frailty Paper Code")
rm(list = ls())


#### Setup ####

# Read in frailty data with social risk markers
df<- readstata13::read.dta13("../../Data/Dta/Processed Data/ELSA Frailty and Precarity Analysis Dataset.dta")

# Drop any rows with missing frailty outcome
df<- df%>%
  filter(!is.na(frailty_index))

# Drop those below 50
df<- df%>%
  filter(age >= 50)

# Create dummy variable for female
df<- df%>%
  mutate(female = ifelse(gender == "Women", 1, 0))%>%
  select(-gender)

# Create age-squared variable
df<- df%>%
  mutate(agesqrd = age*age)

# Select relevant variables
stressors<- c("non_home_wealth_scaled", "home_wealth_scaled", "income_scaled", "has_no_occ_pension", "has_no_personal_pension", "reduced_pension", "receiving_benefits", "ever_unemployed", "ever_invol_job_loss", "ever_left_job_to_care", "ever_mixed_work_care", "ever_int_unpaid_care", "widowed", "divorced", "lives_alone", "renting", "housing_problems", "ever_homeless", "fuel_poverty", "food_insecurity", "not_enough_money", "income_decrease", "not_enough_future")

df<- df%>%
  select(idauniq, wave, frailty_index, age, agesqrd, female, all_of(stressors))

# Check data
head(df, 10)


#### Analysis Stage 3 - Develop Later Life Precarity Index ####


# Remove a subset of individuals to be used in the final stage as a validation set
set.seed(1538)

validation_ids<- sample(unique(df$idauniq), size = round(0.2*length(unique(df$idauniq)), 0))

validation_df<- df%>%
  filter(idauniq %in% validation_ids)

df<- df%>%
  filter(!idauniq %in% validation_ids)

# Create dataset of stressors at Wave 2, with all possible interactions and quadratic terms
elnet_df<- df%>%
  filter(wave == 2)%>%
  select(frailty_index, all_of(stressors))%>%
  filter(if_all(everything(), ~!is.na(.x)))

quads<- sapply(c("non_home_wealth_scaled", "home_wealth_scaled", "income_scaled", "housing_problems", "food_insecurity", "not_enough_money", "not_enough_future"), function(x){paste0("I(", x, "^2)")})%>%
  paste0(collapse = " + ")

f<- as.formula(paste0("frailty_index ~ .^2 + ", quads))

model_df<- model.matrix(f, elnet_df)[,-1]

colnames(model_df)

# Use train function from caret to find optimal alpha value using five-fold cross-validation
train_cv = trainControl(method = "cv", number = 5)

cv_results<- train(x = model_df, y = elnet_df$frailty_index, method = "glmnet", trControl = train_cv, tuneLength = 10)

cv_results$bestTune

best_alpha<- cv_results$bestTune$alpha

# Use cross-validation to find the optimal lambda value
cv_fit<- cv.glmnet(x = model_df, y = elnet_df$frailty_index, alpha = best_alpha)

plot(cv_fit)

coef(cv_fit, s = "lambda.min")


# Save the model
save(cv_fit, file = "Models/Elastic Net FI Model.Rda")
load("Models/Elastic Net FI Model.Rda")

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
  labs(x = "Later Life Precarity Index", y = "Count of individuals", title = "A: Histogram of Later Life Precarity Index")+
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

ggsave(plot = p1, "Plots/Figure 2a - Histogram of LLPI.png", units = "cm", width = 12, height = 9, dpi = 300)


# Plot the association of the precarity index with the frailty index
p2<- elnet_df%>%
  ggplot(aes(x = precarity, y = frailty_index))+
  geom_point(size = 0.5, colour = pal[5], alpha = 0.25)+
  geom_smooth(method = "lm", colour = pal[7])+
  theme_minimal()+
  labs(x = "Later Life Precarity Index", y = "Frailty Index", title = "B: Scatter Plot of Frailty Index and Later Life Precarity Index")+
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

ggsave(plot = p2, "Plots/Figure 2b - Scatter Plot of LLPI and FI.png", units = "cm", width = 12, height = 9, dpi = 300)


#### Analysis Stage 3 - Longitudinal Models ####

# Create a dataset to use in the panel regressions
panel_df<- df%>%
  select(idauniq, wave, age, agesqrd, female, frailty_index, all_of(stressors))%>%
  filter(if_all(everything(), ~!is.na(.x)))

# Generate the interaction terms and quadratic terms
f<- as.formula(paste0("frailty_index ~ .^2 + ", quads))

model_df<- model.matrix(f, panel_df%>%
                          select(frailty_index, all_of(stressors)))[,-1]

# Generate the Precarity Index using the elastic net model
precarity<- predict(cv_fit, newx = model_df, s = "lambda.min")

panel_df$precarity<- precarity[,1]

# Select relevant variables
panel_df<- panel_df%>%
  select(idauniq, wave, frailty_index, precarity, age, agesqrd, female)

# Export the data
#write.csv(panel_df, row.names = F, file = "../../Data/CSV/Submission Version/ELSA Subset with Elastic Net Precarity Index.csv")





#### Analysis Stage 4 - Predict Frailty Status ####
#### Cross-sectional classification 

### Training the logistic regression in the main data

# Create a dataframe of frail vs non-frail in wide-format
wide_outcomes<- panel_df%>%
  select(idauniq, wave, frailty_index)%>%
  mutate(frail = case_when(frailty_index >= 0.25 ~ 1,
                           frailty_index < 0.25 ~ 0,
                           T ~ NA))%>%
  select(-frailty_index)%>%
  tidyr::pivot_wider(id_cols = idauniq, names_from = wave, values_from = frail, names_prefix = "frail_")

# Create a dataframe of the baseline predictors
baseline_df<- panel_df%>%
  filter(wave == 2)%>%
  select(idauniq, age, agesqrd, female, frailty_index, precarity)%>%
  filter(if_all(everything(), ~!is.na(.x)))

# Join the predictors to the outcomes
df_wide<- baseline_df%>%
  left_join(wide_outcomes, by = "idauniq")

# Run a logistic regression to classify frailty status at baseline based on precarity, age and sex at baseline
m<- glm(frail_2 ~ age + agesqrd + female + precarity, data = df_wide, family = binomial())

# Look at the AUC in this main data
logistic_cross_sectional_preds<- predict(m, type = "response")

pROC::roc(response = df_wide$frail_2, predictor = logistic_cross_sectional_preds)

### Testing the model in the unseen data

# Create a dataframe of frail vs non-frail in wide format
wide_outcomes<- validation_df%>%
  select(idauniq, wave, frailty_index)%>%
  mutate(frail = case_when(frailty_index >= 0.25 ~ 1,
                           frailty_index < 0.25 ~ 0,
                           T ~ NA))%>%
  select(-frailty_index)%>%
  tidyr::pivot_wider(id_cols = idauniq, names_from = wave, values_from = frail, names_prefix = "frail_")

# Create a dataframe of baseline predictors
baseline_df<- validation_df%>%
  filter(wave == 2)%>%
  select(idauniq, age, agesqrd, female, frailty_index, all_of(stressors))%>%
  filter(if_all(everything(), ~!is.na(.x)))

# Calculate the precarity index at baseline
f<- as.formula(paste0("frailty_index ~ .^2 + ", quads))

validation_model_df<- model.matrix(f, baseline_df%>%
                                     select(-c(idauniq, age, agesqrd, female)))[,-1]

validation_preds<- predict(cv_fit, newx = validation_model_df)

baseline_df$precarity<- validation_preds[,1]

# Join the predictors ot the outcomes
df_wide<- baseline_df%>%
  left_join(wide_outcomes, by = "idauniq")

# Generate classifications
logistic_cross_sectional_preds<- predict(m, newdata = df_wide, type = "response")

# Calculate AUC
pROC::roc(response = df_wide$frail_2, predictor = logistic_cross_sectional_preds)

# Get ROC data
pred_df<- data.frame(frail_2 = df_wide$frail_2, pred = logistic_cross_sectional_preds)

cp<- cutpointr::cutpointr(data = pred_df, x = "pred", class = "frail_2")

auc_cross_sectional<- as.data.frame(cp$roc_curve)



#### Longitudinal classification

### Training the logistic regression in the main data

# Create a dataframe of frail vs non-frail in wide format
wide_outcomes<- panel_df%>%
  select(idauniq, wave, frailty_index)%>%
  mutate(frail = case_when(frailty_index >= 0.25 ~ 1,
                           frailty_index < 0.25 ~ 0,
                           T ~ NA))%>%
  select(-frailty_index)%>%
  tidyr::pivot_wider(id_cols = idauniq, names_from = wave, values_from = frail, names_prefix = "frail_")

# Create a dataframe of baseline predictors
baseline_df<- panel_df%>%
  filter(wave == 2)%>%
  select(idauniq, age, agesqrd, female, frailty_index, precarity)%>%
  filter(if_all(everything(), ~!is.na(.x)))

# Join the predictors to the outcomes
df_wide<- baseline_df%>%
  left_join(wide_outcomes, by = "idauniq")

# Filter to those who are non-frali at baseline and who have a valid frailty status at Wave 7
df_wide<- df_wide%>%
  filter(frail_2 == 0)%>%
  filter(!is.na(frail_7))

# Run the logistic regression 
m<- glm(frail_7 ~ age + agesqrd + female + precarity, data = df_wide, family = binomial())

# Look at the AUC in the main data
logistic_longitudinal_preds<- predict(m, type = "response")

pROC::roc(response = df_wide$frail_7, predictor = logistic_longitudinal_preds)


### Testing the model in the unseen data

# Create a dataframe of frail vs non-frali in wide format
wide_outcomes<- validation_df%>%
  select(idauniq, wave, frailty_index)%>%
  mutate(frail = case_when(frailty_index >= 0.25 ~ 1,
                           frailty_index < 0.25 ~ 0,
                           T ~ NA))%>%
  select(-frailty_index)%>%
  tidyr::pivot_wider(id_cols = idauniq, names_from = wave, values_from = frail, names_prefix = "frail_")

# Create a dataframe of baseline predictors
baseline_df<- validation_df%>%
  filter(wave == 2)%>%
  select(idauniq, age, agesqrd, female, frailty_index, all_of(stressors))%>%
  filter(if_all(everything(), ~!is.na(.x)))

# Calculate the precarity index
f<- as.formula(paste0("frailty_index ~ .^2 + ", quads))

validation_model_df<- model.matrix(f, baseline_df%>%
                                     select(-c(idauniq, age, agesqrd, female)))[,-1]

validation_preds<- predict(cv_fit, newx = validation_model_df)

baseline_df$precarity<- validation_preds[,1]

# Join the predictors ot the outcomes
df_wide<- baseline_df%>%
  left_join(wide_outcomes, by = "idauniq")

# Filter to those not frail at baseline and who have valid frailty status at Wave 7
df_wide<- df_wide%>%
  filter(frail_2 == 0)%>%
  filter(!is.na(frail_7))

# Generate classifications using the model
logistic_longitudinal_preds<- predict(m, newdata = df_wide, type = "response")

pROC::roc(response = df_wide$frail_7, predictor = logistic_longitudinal_preds)

# Get ROC data
pred_df<- data.frame(frail_7 = df_wide$frail_7, pred = logistic_longitudinal_preds)

cp<- cutpointr::cutpointr(data = pred_df, x = "pred", class = "frail_7")

auc_longitudinal<- as.data.frame(cp$roc_curve)

# Combine the ROC data from each model
auc_df<- rbind(auc_cross_sectional%>%
                 mutate(Model = "Cross-sectional (Model 6)"), auc_longitudinal%>%
                                                                      mutate(Model = "10-year follow-up (Model 7)"))

# Plot the ROC Curves

p3<- auc_df%>%
  mutate(Model = relevel(factor(Model), "Cross-sectional (Model 6)"))%>%
  ggplot(aes(x = fpr, y = tpr, group = Model, colour = Model))+
  geom_abline(linetype = 2)+
  annotate(geom = "text", x = 0.125, y = 0.8, label = "AUC = 0.841", color = pal[5], size = 2.5)+
  annotate(geom = "text", x = 0.4, y = 0.625, label = "AUC = 0.777", color = pal[7], size = 2.5)+
  geom_line()+
  scale_color_manual(values = pal[c(5,7)])+
  theme_minimal()+
  theme(legend.position = "bottom",
        legend.box.margin = margin(0,0,0,0),
        legend.margin = margin(0,0,0,0),
        plot.background = element_rect(color = "white", fill = "white"),
        text = element_text(size = 8),
        axis.title.x = element_text(margin = margin(10,0,0,0)),
        axis.title.y = element_text(margin = margin(0,10,0,10)),
        #axis.text = element_text(size = 10),
        panel.grid.major = element_line(linewidth = 0.25),
        panel.grid.minor = element_line(linewidth = 0.25),
        plot.title.position = "plot",
        plot.title = element_text(margin = margin(10,5,10,5), size = 8))+
  labs(x = "False positive rate", y = "True positive rate", title = "C: ROC Curves for Prediction of Frailty Status (Models 6 and 7)")


ggsave(plot = p3, "Plots/Figure 2C - ROC Curves for Models 6 and 7.png", units = "cm", width = 12, height = 9, dpi = 300)


# Megre all the plots and save as a single image
p<- p1 + p2 + p3 + patchwork::plot_layout(ncol = 1)

p

ggsave(plot = p, "Plots/Figure 2.png", units = "cm", width = 12, height = 27, dpi = 300)


#### Calculate the precarity index in the long-format validation dataset ####


f<- as.formula(paste0("frailty_index ~ .^2 + ", quads))

validation_df<- validation_df%>%
  filter(if_all(everything(), ~!is.na(.x)))

validation_model_df<- model.matrix(f, validation_df%>%
                                     select(frailty_index, all_of(stressors)))[,-1]

colnames(validation_model_df)

validation_preds<- predict(cv_fit, newx = validation_model_df)

validation_df$precarity<- validation_preds[,1]

validation_df<- validation_df%>%
  select(idauniq, wave, frailty_index, precarity, age, agesqrd, female)

write.csv(validation_df, row.names = F, file = "../../Data/CSV/Submission Version/ELSA Validation Subset with Elastic Net Precarity Index.csv")
