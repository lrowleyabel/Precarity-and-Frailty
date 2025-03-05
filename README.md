# Precarity and Frailty


This is the code for the paper 'Later Life Precarity and Longitudinal Frailty Trajectories in Older Adults'. It produces a Frailty Index and a Later Life Precarity Index in the English Longitudinal Study of Ageing (ELSA). The analysis consists of three stages:

  - evaluating the longitudinal association of frailty with individual social risks
  - deriving a composite index of social risks associated with frailty (the Later Life Precarity Index)
  - evaluating the longitudinal association of the composite index with frailty

## Workflow:

### Setup:

  - Download the ELSA data files from the UK Data Service. The relevant study is Study Number 5050. Extract the files and place the folder UKDA-5050-Stata in the Raw Data directory of this repository.

  - We first save copies of some of the main ELSA data files for each wave with standardised file names. This makes looping through waves easier.
    - _File Setup.do_


### Data preparation:

#### Calculating Frailty Index:

  - We first calculate the Frailty Index and save it as a separate datset:
    - _Calculating Frailty Index.do_

#### Calculating Social Risks:

  - We need to generate some variables that will be used to calculate the social risk variables. These include fed-forward versions of variables etc.
    - _Generating Last Recorded Income and Benefits Variables.do_
    - _Generating Fed Forward Employment and Retirement Variables.do_
    - _Generating Current Employment and Caregiving Variables.do_
  - We can then calculate the social risk variables at each wave:
    - _Generating Social Risk Variables.do_
    - _Checking Missing Values for Social Risks.do_
  - We then generate the analysis dataset by joining the social risk variables to the Frailty Index:
    - _Generating Analysis Dataset.do_

### Main Analysis:

#### Stage 1:

  - We first evaluate the association of the Frailty Index with each social risk individually. All of the risks that are statistically significant and positively associated with frailty (in either owmen or men) are retained and entered into a model simultaneously. We then plot the results.
    - _Analysis Stage 1.do_
    - _Plotting Model 1 Coefficients.R_

#### Stage 2:

  - We then derive the Later Life Precarity Index, which is a composite measure capturing social risks associated with frailty. This is done using elastic net regression.
    - _Analysis Stage 2.R_

#### Stage 3:

  - We then model the longitudinal relationship between the Later Life Precarity Index and frailty using hybrid panel regression models.
    - _Analysis Stage 3.do_

### Sensitivity Analysis:

  - We check for strongly correlated independent variables in Model 1 and run a model with strongly correlated variables removed:
    - _Sensitivity Analyses - Checking Social Risk Correlations.R_
    - _Sensitivity Analyses - Model 5 Multicollinearity Check.do_
    - _Sensitivity Analyses - Plotting Model 5 Coefficients.R_
  - We run weighted versions of the main models (Models 2 - 4):
    - _Sensitivity Analyses - Weighted Models 2 - 4.do_    

### Further Code:

  - _Descriptive Statistics.R_
  - _Comparison of Full and Analytic Sample.R_
