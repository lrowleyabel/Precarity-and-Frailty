# Frailty and Social Risks


This is the code for the paper 'Novel index of later life social risks accurately explains and tracks frailty'. It produces a Frailty Index and a set of variables capturing detailed social risks in the English Longitudinal Study of Ageing (ELSA). The analysis consists of 4 stages:

  - evaluating the longitudinal association of frailty with individual social risks
  - deriving a composite index of social risks associated with frailty
  - evaluating the longitudinal association of the composite index with frailty
  - evaluating the ability of the composite index to classify individuals as frail or non-frail.
  
## Workflow:

### Setup:

  - Download the ELSA data files from the UK Data Service. The relevant study is Study Number 5050. Extract the files and place the folder UKDA-5050-Stata in the Raw Data directory of this repository.

  - _File Setup.do_ : This saves copies of some of the main ELSA data files for each wave with standardised file names. This makes looping through waves easier.


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
  - We then generate the analysis dataset by joining the social risk variables to the Frailty Index:
    - _Generating Analysis Dataset.do_

### Analysis:

#### Stage 1:

  - We first evaluate the association of the Frailty Index with each social risk individually. All of the risks that are statistically significant and positively associated with frailty (in either owmen or men) are retained and entered into a model simultaneously. We then plot the results.
    - _Analysis Stage 1.do_
    - _Plotting Model 1 and 2 Coefficients.R_