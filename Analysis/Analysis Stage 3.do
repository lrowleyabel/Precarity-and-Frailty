/*

HYBRID PANEL REGRESSION MODELS

Laurence Rowley-Abel, University of Edinburgh

lrowley@ed.ac.uK

This file runs a series of hybrid panel regressions that model the relationship between frailty and several social exposure measures across eight time points in ELSA.

*/


//// SET UP ////

// Set working directory
cd "C:\Users\lrowley\OneDrive - University of Edinburgh\Published Paper GitHub Repositories\New Frailty and Social Risks\Analysis"

// Clear environment
clear all

// Read in long-format ELSA data with frailty and social exposure measures
import delimited "..\Data\Processed Data\ELSA Subset with Elastic Net Precarity Index.csv", clear

// Merge in the wealth and variables
merge 1:1 idauniq wave using "../Data/Processed Data/ELSA Frailty and Social Risks Analysis Dataset.dta", keepusing(idauniq wave wealth_percentile education)
keep if _merge == 3
drop _merge

// Drop individuals under 50
drop if age < 50

// Set as panel data
xtset idauniq wave

xtdescribe
xtsum


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
collect, tag(model[1]): xtreg frailty dage dagesqrd mage magesqrd i.gender_women, re vce(robust)
estimates store m1

// Run a model with the precarity index, age age-squared and gender (model 2)
collect, tag(model[2]): xtreg frailty dage dagesqrd mage magesqrd i.gender_women dprecarity mprecarity, re vce(robust)
estimates store m2

// Run a model with wealth, education age age-squared and gender (model 2)
collect, tag(model[3]): xtreg frailty dage dagesqrd mage magesqrd i.gender_women i.education dwealth_percentile mwealth_percentile, re vce(robust)
estimates store m3


collect layout (colname) (model#result[_r_b _r_ci])
collect stars _r_p 0.001 "***" 0.01 "**" 0.05 "*", attach(_r_b)
collect style cell result[_r_b _r_ci], nformat(%8.3f)
collect style cell result[_r_ci], cidelimiter(,)
collect style column, dups(center)
collect preview



// Export the model results
collect layout  (colname[dage dagesqrd dprecarity dwealth_percentile mage magesqrd mprecarity mwealth_percentile 0.gender_women 1.gender_women 1.education 2.education 3.education _cons] ) (model#result[_r_b _r_ci])

putexcel set "../Model Results/Models 2 - 4.xlsx", replace

putexcel A1 = collect

// Look at the model R2s
collect layout (result[r2_w r2_b r2_o]) (model)
collect style cell result[r2_w r2_b r2_o], nformat(%8.3f)
collect preview

// Look at the model sample sizes
collect layout (result[N N_clust]) (model)




//// DEMONSTRATING PREDICTED EFFECTS ////

preserve
clear
input age age_o
	50	50
	51	51
	52	52
	53	53
	54	54
	55	55
	56	56
	57	57
	58	58
	59	59
	60	60
	61	61
	62	62
	63	63
	64	64
	65	65
	66	66
	67	67
	68	68
	69	69
	70	70
	71	71
	72	72
	73	73
	74	74
	75	75
	76	76
	77	77
	78	78
	79	79
	80	80
	81	81
	82	82
	83	83
	84	84
	85	85
	86	86
	87	87
	88	88
	89	89
	90	90

end


gen gender_women = 1


summarize age
replace age = (age-r(mean))/r(sd)

gen agesqrd = age*age

egen mage = mean(age)
generate dage = age - mage

egen magesqrd = mean(agesqrd)
generate dagesqrd = agesqrd - magesqrd

estimates restore m1

predict predicted_frailty, xb

list age_o predicted_frailty

scatter predicted_frailty age_o

restore




//// CHECKING MAIN MODEL ASSUMPTIONS ////

estimates restore m2
capture drop pred_frailty resid_e resid_u
predict pred_frailty
predict resid_e, e
predict resid_u, u
scatter resid_e pred_frailty, msize(0.1) name(scatter_e, replace) title("Level 1 Residuals vs Predicted Values", size(3))
scatter resid_u pred_frailty, msize(0.1) name(scatter_u, replace)  title("Level 2 Residuals vs Predicted Values", size(3))
hist resid_e, name(hist_e, replace) title("Level 1 Residuals Histogram", size(3))
hist resid_u, name(hist_u, replace) title("Level 2 Residuals Histogram", size(3))
graph combine scatter_e scatter_u hist_e hist_u, rows(2) title("Model of frailty", size(3))
graph export "Plots/Hybrid Model Plots/Model 3 Diagnostics.png", replace