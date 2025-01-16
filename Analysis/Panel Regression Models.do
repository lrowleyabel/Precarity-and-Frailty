/*

HYBRID PANEL REGRESSION MODELS

Laurence Rowley-Abel, University of Edinburgh

lrowley@ed.ac.uK

This file runs a series of hybrid panel regressions that model the relationship between frailty and several social exposure measures across eight time points in ELSA.

*/


//// SET UP ////

// Set working directory
cd "C:\Users\lrowley\University of Strathclyde\SIPBS_MRC Ageing Project - General\ELSA\Analysis\ELSA Precarity and Frailty Paper Code"

// Clear environment
clear all

// Read in long-format ELSA data with frailty and social exposure measures
import delimited "C:\Users\lrowley\University of Strathclyde\SIPBS_MRC Ageing Project - General\ELSA\Data\CSV\ELSA Subset with Elastic Net Precarity Index.csv", clear

// Merge in the wealth variable
merge 1:1 idauniq wave using "../../Data/Dta/Processed Data/ELSA Frailty and Precarity Analysis Dataset.dta", keepusing(idauniq wave hatotb)
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

summarize hatotb
replace hatotb = (hatotb-r(mean))/r(sd)

summarize precarity
replace precarity = (precarity-r(mean))/r(sd)

// Create an age squared variable from the z-transformed age variable
drop agesqrd
gen agesqrd = age*age


// For each time varying variable, generate variables with each individual's mean value and their deviation from their person-sepcific mean at each time point

mark nonmiss
markout nonmiss frailty precarity age female

egen mprecarity = mean(precarity) if nonmiss == 1, by(idauniq)
generate dprecarity = precarity - mprecarity

egen mage = mean(age) if nonmiss == 1, by(idauniq)
generate dage = age - mage

egen magesqrd = mean(agesqrd) if nonmiss == 1, by(idauniq)
generate dagesqrd = agesqrd - magesqrd

egen mhatotb = mean(hatotb) if nonmiss == 1, by(idauniq)
generate dhatotb = hatotb - mhatotb


//// MODELS ////

// Clear the collections
collect clear

// Run a model with just age, age-squared and gender (model 1)
collect, tag(model[1]): xtreg frailty dage dagesqrd mage magesqrd i.female, re vce(robust)
estimates store m1

// Run a model with the precarity index, age age-squared and gender (model 2)
collect, tag(model[2]): xtreg frailty dage dagesqrd mage magesqrd i.female dprecarity mprecarity, re vce(robust)
estimates store m2

// Run a model with wealth, age age-squared and gender (model 2)
collect, tag(model[3]): xtreg frailty dage dagesqrd mage magesqrd i.female dhatotb mhatotb, re vce(robust)
estimates store m3


collect layout (colname) (model#result[_r_b _r_ci])
collect stars _r_p 0.001 "***" 0.01 "**" 0.05 "*", attach(_r_b)
collect style cell result[_r_b _r_ci], nformat(%8.3f)
collect style cell result[_r_ci], cidelimiter(,)
collect style column, dups(center)
collect preview



// Export the model results
collect layout  (colname[dage dagesqrd dprecarity dhatotb mage magesqrd mprecarity mhatotb 0.female 1.female _cons] ) (model#result[_r_b _r_ci])

putexcel set "Model Results/Models 3 - 5.xlsx", replace

putexcel A1 = collect

// Export the model R2s
collect layout (result[r2_w r2_b r2_o]) (model)
collect style cell result[r2_w r2_b r2_o], nformat(%8.3f)
collect preview

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


gen female = 1


summarize age
replace age = (age-r(mean))/r(sd)

gen agesqrd = age*age

egen mage = mean(age)
generate dage = age - mage

egen magesqrd = mean(agesqrd)
generate dagesqrd = agesqrd - magesqrd

estimates restore m1

predict predicted_frailty, xb

list

scatter predicted_frailty age_o

restore






summarize mprecarity, detail
local low_mprecarity = r(p10)
local median_mprecarity = r(p50)
local high_mprecarity = r(p90)

capture drop max_precarity min_precarity total_change_in_precarity
by idauniq, sort: egen max_precarity = max(precarity)
by idauniq, sort: egen min_precarity = min(precarity)
gen total_change_in_precarity = max_precarity - min_precarity
summarize total_change_in_precarity, det
local low_change = r(p10)
local median_change = r(p50)
local high_change = r(p90)

foreach mean_value in `low_mprecarity' `median_mprecarity' `high_mprecarity' {
		foreach change in `low_change' `median_change' `high_change' {
			forvalues i = -4/4 {
				local new_value = `mean_value' + (`i'*(`change'/9))
				if `i' == -4 {
					mat x = `new_value'
				}
				else {
					mat x = x \ `new_value'
				}
			}
			if `mean_value' == `low_mprecarity' & `change' == `low_change' {
				mat y = x
			}
			else {
				mat y = y \ x
			}
		}
}


forvalues i = 1/9 {
	forvalues j = 1/9 {
		if `i' == 1 & `j' == 1 {
			mat id = `i'
		}
		else {
			mat id = id \ `i'
		}	
	}
}

forvalues i = 1/9 {
	foreach j in 50 55 60 65 70 75 80 85 90 {
		if `i' == 1 & `j' == 50 {
			mat age = `j'
		}
		else {
			mat age = age \ `j'
		}	
	}
}

mat out = id, age, y


// Export Model 1 predicted values

preserve

	drop *
	
	svmat out
	
	rename out1 id
	
	rename out2 age
	
	rename out3 precarity
	
	// Z-transform age
	gen original_age = age
	summarize age
	replace age = (age-r(mean))/r(sd)

	// Create an age-squared variable
	gen agesqrd = age*age
	
	// Create a gender variable (set all observations as female)
	gen female = 0
	
	
	// Calculate the mean and within-individual deviation for precarity, age and age-squared and all the interaction terms
	egen mprecarity = mean(precarity), by(id)
	generate dprecarity = precarity - mprecarity

	egen mage = mean(age), by(id)
	generate dage = age - mage

	egen magesqrd = mean(agesqrd), by(id)
	generate dagesqrd = agesqrd - magesqrd


	// Restore the Model 1 estimates
	estimates restore m1
	
	// Predict frailty for each observation in the example data using Model 3
	predict pred_frailty
	predict pred_se, stdp
	
	// Un-Z-transform age
	summarize original_age
	replace age = (age*r(sd))+r(mean)
	
	// Export the results
	export excel using "Models\Hybrid Model 1 Predicted Effects Male.xlsx", firstrow(variables) replace


restore


preserve

	drop *
	
	svmat out
	
	rename out1 id
	
	rename out2 age
	
	rename out3 precarity
	
	// Z-transform age
	gen original_age = age
	summarize age
	replace age = (age-r(mean))/r(sd)

	// Create an age-squared variable
	gen agesqrd = age*age
	
	// Create a gender variable (set all observations as female)
	gen female = 1
	
	
	// Calculate the mean and within-individual deviation for precarity, age and age-squared and all the interaction terms
	egen mprecarity = mean(precarity), by(id)
	generate dprecarity = precarity - mprecarity

	egen mage = mean(age), by(id)
	generate dage = age - mage

	egen magesqrd = mean(agesqrd), by(id)
	generate dagesqrd = agesqrd - magesqrd


	// Restore the Model 1 estimates
	estimates restore m1
	
	// Predict frailty for each observation in the example data using Model 3
	predict pred_frailty
	predict pred_se, stdp
	
	// Un-Z-transform age
	summarize original_age
	replace age = (age*r(sd))+r(mean)
	
	// Export the results
	export excel using "Models\Hybrid Model 1 Predicted Effects Female.xlsx", firstrow(variables) replace


restore


// Export Model 2 predicted values

preserve

	drop *
	
	svmat out
	
	rename out1 id
	
	rename out2 age
	
	rename out3 precarity
	
	// Z-transform age
	gen original_age = age
	summarize age
	replace age = (age-r(mean))/r(sd)

	// Create an age-squared variable
	gen agesqrd = age*age
	
	// Create a gender variable (set all observations as female)
	gen female = 0
	
	
	// Calculate the mean and within-individual deviation for precarity, age and age-squared and all the interaction terms
	egen mprecarity = mean(precarity), by(id)
	generate dprecarity = precarity - mprecarity

	egen mage = mean(age), by(id)
	generate dage = age - mage

	egen magesqrd = mean(agesqrd), by(id)
	generate dagesqrd = agesqrd - magesqrd


	// Restore the Model 1 estimates
	estimates restore m2
	
	// Predict frailty for each observation in the example data using Model 3
	predict pred_frailty
	predict pred_se, stdp
	
	// Un-Z-transform age
	summarize original_age
	replace age = (age*r(sd))+r(mean)
	
	// Export the results
	export excel using "Models\Hybrid Model 2 Predicted Effects Male.xlsx", firstrow(variables) replace


restore


preserve

	drop *
	
	svmat out
	
	rename out1 id
	
	rename out2 age
	
	rename out3 precarity
	
	// Z-transform age
	gen original_age = age
	summarize age
	replace age = (age-r(mean))/r(sd)

	// Create an age-squared variable
	gen agesqrd = age*age
	
	// Create a gender variable (set all observations as female)
	gen female = 1
	
	
	// Calculate the mean and within-individual deviation for precarity, age and age-squared and all the interaction terms
	egen mprecarity = mean(precarity), by(id)
	generate dprecarity = precarity - mprecarity

	egen mage = mean(age), by(id)
	generate dage = age - mage

	egen magesqrd = mean(agesqrd), by(id)
	generate dagesqrd = agesqrd - magesqrd


	// Restore the Model 1 estimates
	estimates restore m2
	
	// Predict frailty for each observation in the example data using Model 3
	predict pred_frailty
	predict pred_se, stdp
	
	// Un-Z-transform age
	summarize original_age
	replace age = (age*r(sd))+r(mean)
	
	// Export the results
	export excel using "Models\Hybrid Model 2 Predicted Effects Female.xlsx", firstrow(variables) replace


restore





//// CHECKING MAIN MODEL ASSUMPTIONS ////

estimates restore m3
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

gen log_frailty = log(frailty)
xtreg log_frailty dprecarity dage dagesqrd mprecarity mage magesqrd i.female, re
capture drop pred_frailty resid_e resid_u
predict pred_frailty
predict resid_e, e
predict resid_u, u
scatter resid_e pred_frailty, msize(0.1) name(scatter_e, replace) title("Level 1 Residuals vs Predicted Values", size(3))
scatter resid_u pred_frailty, msize(0.1) name(scatter_u, replace)  title("Level 2 Residuals vs Predicted Values", size(3))
hist resid_e, name(hist_e, replace) title("Level 1 Residuals Histogram", size(3))
hist resid_u, name(hist_u, replace) title("Level 2 Residuals Histogram", size(3))
graph combine scatter_e scatter_u hist_e hist_u, rows(2) title("Model of log(frailty)", size(3))
graph export "Plots/Hybrid Model Plots/Log Model Diagnostics.png", replace
