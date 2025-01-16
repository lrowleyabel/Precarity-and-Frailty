/*

CHECKING MISSING VALUES FOR SOCIAL RISKS

Laurence Rowley-Abel, University of Edinburgh
lrowley@ed.ac.uk

Description: This file checks how many missing values there are for each social risk at each wave.

*/

// Clear environment
clear

// Set maximum number of variables
set maxvar 20000

// Set working directory to current file's location (ammend as necessary)
cd ""

// Loop through waves and check number of missing values for each social exposure
forval w = 2/9 {
	
	di "MISSING VALUES FOR WAVE `w'"
	
	use "..\..\Data\Processed Data\ELSA Wave `w' Social Risk Variables.dta", clear

	mdesc *
	
}

/*
We have relatively large numbers of missing values for:
- pension variables because proxy respondents do not appear to be in the pension grid files
- fuel poverty variable because of a large number of 'Don't Knows' for the question asking about expenditure on energy
- the variables about not having enough money now or in the future, due to institutional respondents not being asked these questions
- income decrease variable due to new respondents (eg: from refreshment samples) not having measures of previous income

*/