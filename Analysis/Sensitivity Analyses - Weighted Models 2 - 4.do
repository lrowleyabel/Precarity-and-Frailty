/*

SENSITIVITY ANALYSES - WEIGHTS MODELS 2 - 4

Laurence Rowley-Abel, University of Edinburgh

lrowley@ed.ac.uK

This file runs weighted versions of Models 2 - 4 using the mixed command.

*/


//// SET UP ////

// Set working directory
cd "C:\Users\lrowley\OneDrive - University of Edinburgh\Published Paper GitHub Repositories\New Frailty and Social Risks\Analysis"

// Clear environment
clear all

// Read in long-format ELSA data with frailty and social exposure measures
import delimited "..\Data\Processed Data\ELSA Subset with Elastic Net Precarity Index.csv", clear

// Merge in the wealth and education variables and the longitudinal weight
merge 1:1 idauniq wave using "../Data/Processed Data/ELSA Frailty and Social Risks Analysis Dataset.dta", keepusing(idauniq wave wealth_percentile education r9lwtresp)
keep if _merge == 3
drop _merge

// Drop individuals under 50
drop if age < 50



// Z-transform age, wealth and precartiy
summarize age
replace age = (age-r(mean))/r(sd)

summarize wealth_percentile
replace wealth_percentile = (wealth_percentile-r(mean))/r(sd)

summarize precarity
replace precarity = (precarity-r(mean))/r(sd)

// Create an age squared variable from the z-transformed age variable
drop agesqrd
gen agesqrd = age*age


// For each time varying variable, generate variables with each individual's mean value and their deviation from their person-sepcific mean at each time point

mark nonmiss
markout nonmiss frailty precarity age gender_women

egen mprecarity = mean(precarity) if nonmiss == 1, by(idauniq)
generate dprecarity = precarity - mprecarity

egen mage = mean(age) if nonmiss == 1, by(idauniq)
generate dage = age - mage

egen magesqrd = mean(agesqrd) if nonmiss == 1, by(idauniq)
generate dagesqrd = agesqrd - magesqrd

egen mwealth_percentile = mean(wealth_percentile) if nonmiss == 1, by(idauniq)
generate dwealth_percentile = wealth_percentile - mwealth_percentile


//// MODELS ////

// Clear the collections
collect clear

// Run a model with just age, age-squared and gender (model 1)
collect, tag(model[1]): mixed frailty dage dagesqrd mage magesqrd i.gender_women [weight = r9lwtresp] || idauniq:, vce(robust)
estimates store m1


// Run a model with the precarity index, age age-squared and gender (model 2)
collect, tag(model[2]): mixed frailty dage dagesqrd mage magesqrd i.gender_women dprecarity mprecarity [weight = r9lwtresp] || idauniq:, vce(robust)
estimates store m2

// Run a model with wealth, education age age-squared and gender (model 2)
collect, tag(model[3]): mixed frailty dage dagesqrd mage magesqrd i.gender_women i.education dwealth_percentile mwealth_percentile [weight = r9lwtresp] || idauniq:, vce(robust)
estimates store m3


collect layout (colname) (model#result[_r_b _r_ci])
collect stars _r_p 0.001 "***" 0.01 "**" 0.05 "*", attach(_r_b)
collect style cell result[_r_b _r_ci], nformat(%8.3f)
collect style cell result[_r_ci], cidelimiter(,)
collect style column, dups(center)
collect preview



// Export the model results
collect layout  (colname[dage dagesqrd dprecarity dwealth_percentile mage magesqrd mprecarity mwealth_percentile 0.gender_women 1.gender_women 1.education 2.education 3.education _cons] ) (model#result[_r_b _r_ci])

putexcel set "../Model Results/Models 6 - 8.xlsx", replace

putexcel A1 = collect
