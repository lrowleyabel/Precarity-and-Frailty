/*

SENSITIVITY ANALYSIS - WEALTH QUINTILES

Laurence Rowley-Abel, University of Edinburgh

lrowley@ed.ac.uK

This file runs a sensitivity analysis where the continuous wealth percentile variable in Model 4 is replaced with a categorical wealth quintile variable.

*/


//// SET UP ////

// Set working directory
cd "C:\Users\lrowley\OneDrive - University of Edinburgh\Published Paper GitHub Repositories\New Frailty and Social Risks\Analysis"

// Clear environment
clear all

// Create a long-format dataset with the IFS wealth quintile variables for each wave
use "..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Financial Wave 2.dta"

keep idauniq nfwq5_bu_s
rename nfwq5_bu_s ifs_wealthq_2

forval W = 3/9 {
	
	merge 1:1 idauniq using "..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Financial Wave `W'.dta", keepusing(idauniq nfwq5_bu_s)
	rename nfwq5_bu_s ifs_wealthq_`W'
	drop _merge
	
}

reshape long ifs_wealthq_@, i(idauniq) j(wave)

rename ifs_wealthq_ ifs_wealth_quintile

save "../Data/Processed Data/IFS Wealth Quintiles Long-Format.dta"

clear

// Read in long-format ELSA data with frailty and social exposure measures
import delimited "..\Data\Processed Data\ELSA Subset with Elastic Net Precarity Index.csv", clear

// Merge in the IFS wealth quintiles
merge 1:1 idauniq wave using "../Data/Processed Data/IFS Wealth Quintiles Long-Format.dta", keepusing(idauniq wave ifs_wealth_quintile)

drop _merge


// Merge in the eudcation variable
merge 1:1 idauniq wave using "../Data/Processed Data/ELSA Frailty and Social Risks Analysis Dataset.dta", keepusing(idauniq wave education)
keep if _merge == 3
drop _merge

// Drop individuals under 50
drop if age < 50

// Create dummy variables for each wealth quintile
tabulate ifs_wealth_quintile, generate(wealth_q)


// Set as panel data
xtset idauniq wave

xtdescribe
xtsum


// Z-transform age, wealth and precartiy
summarize age
replace age = (age-r(mean))/r(sd)

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

// Create cross-wave mean versions of each dummy variable (the 'between' variable)
egen mwealth_q1 = mean(wealth_q1) if nonmiss == 1, by(idauniq)
egen mwealth_q2 = mean(wealth_q2) if nonmiss == 1, by(idauniq)
egen mwealth_q3 = mean(wealth_q3) if nonmiss == 1, by(idauniq)
egen mwealth_q4 = mean(wealth_q4) if nonmiss == 1, by(idauniq)
egen mwealth_q5 = mean(wealth_q5) if nonmiss == 1, by(idauniq)

// Create versions of each dummy variable showing the wave-specific deviation from the cross-wave mean (the 'within' variable)
generate dwealth_q1 = wealth_q1 - mwealth_q1
generate dwealth_q2 = wealth_q2 - mwealth_q2
generate dwealth_q3 = wealth_q3 - mwealth_q3
generate dwealth_q4 = wealth_q4 - mwealth_q4
generate dwealth_q5 = wealth_q5 - mwealth_q5


//// MODELS ////

// Clear the collections
collect clear

// Hybrid model
collect, tag(model[9]): xtreg frailty dage dagesqrd  dwealth_q2 dwealth_q3 dwealth_q4 dwealth_q5 mage magesqrd i.gender_women i.education mwealth_q2 mwealth_q3 mwealth_q4 mwealth_q5, re vce(robust)


collect layout (colname) (model#result[_r_b _r_ci])
collect stars _r_p 0.001 "***" 0.01 "**" 0.05 "*", attach(_r_b)
collect style cell result[_r_b _r_ci], nformat(%8.3f)
collect style cell result[_r_ci], cidelimiter(,)
collect style column, dups(center)
collect preview



// Export the model results
putexcel set "../Model Results/Model 9.xlsx", replace

putexcel A1 = collect

// Look at the model R2s
collect layout (result[r2_w r2_b r2_o]) (model)
collect style cell result[r2_w r2_b r2_o], nformat(%8.3f)
collect preview

// Look at the model sample sizes
collect layout (result[N N_clust]) (model)
