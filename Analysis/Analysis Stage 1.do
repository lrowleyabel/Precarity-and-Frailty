/*

ANALYSIS STAGE 1

Laurence Rowley-Abel, University of Edinburgh
lrowley@ed.ac.uk

Description: This file tests the association of the Frality Index with each of the social risks individually (controlling for age and age-squared, and stratified by sex). All of the social variables that are positively associated with frailty and statistically significant for either women or men are then retained and entered into models simultaneously. Random-effects panel regression models with robust standard errors are used.

*/

// Clear environment
clear all

// Set maximum number of variables
set maxvar 20000

// Set working directory to current file's location (ammend as necessary)
cd "C:\Users\lrowley\OneDrive - University of Edinburgh\Published Paper GitHub Repositories\New Frailty and Social Risks\Analysis"

// Read in the data
use "../Data/Processed Data/ELSA Frailty and Social Risks Analysis Dataset.dta"

// Drop observations with missing frailty index value
drop if missing(frailty_index)

// Drop if under 50
drop if age < 50

// Scale the continuous social risks
su wealth_percentile
replace wealth_percentile = (wealth_percentile-r(mean))/r(sd)

su income_percentile
replace income_percentile = (income_percentile-r(mean))/r(sd)

su not_enough_future
replace not_enough_future = (not_enough_future-r(mean))/r(sd)


/// ANALYSIS STAGE 1: TESTING INDIVIDUAL EXPOSURES ////


// Set as panel data
xtset idauniq wave

// Create list of continuous and categorical social risks
vl create continuous_social_risks = (wealth_percentile income_percentile not_enough_future)

vl create categorical_social_risks = (has_no_occ_pension has_no_personal_pension reduced_pension benefits ever_unemployed ever_fixedterm ever_agency_worker ever_selfemployed ever_parttime ever_second_job ever_invol_job_loss ever_invol_retired ever_left_job_to_care ever_mixed_work_care widowed divorced lives_alone renting mortgage overcrowded invol_move ever_homeless no_central_heating fuel_poverty ever_unpaid_care housing_problems food_insecurity not_enough_money)

// Test each risk individually controlling for age and age-squared
collect clear

foreach v in $continuous_social_risks {
	
	qui: capture drop exposure
	qui: gen exposure = `v'
	
	qui: collect, tag(model["`v'"]):  xtreg frailty c.age##c.age i.gender exposure, re vce(robust)

}

foreach v in $categorical_social_risks {
		
		qui: capture drop exposure
		qui: gen exposure = `v'
		
		qui: collect, tag(model["`v'"]):  xtreg frailty c.age##c.age i.gender i.exposure, re vce(robust)

	
}


drop exposure

// Export the results for each exposure
collect layout (model#colname)(result[_r_b _r_ci])
collect style cell result[_r_b _r_ci], nformat(%8.3f)
collect stars _r_p 0.001 "***" 0.01 "**" 0.05 "*", attach(_r_b)
collect style cell result[_r_ci], cidelimiter(,)
collect style column, dups(center)
collect preview
putexcel set "../Model Results/Preliminary Models.xlsx", replace

putexcel A1 = collect



// Run a model with all the selected exposures
collect clear

collect: xtreg frailty_index c.age##c.age i.gender wealth_percentile income_percentile benefits has_no_occ_pension has_no_personal_pension reduced_pension ever_unemployed ever_invol_job_loss  i.ever_unpaid_care ever_left_job_to_care ever_mixed_work_care widowed divorced lives_alone renting ever_homeless i.housing_problems fuel_poverty i.food_insecurity i.not_enough_money not_enough_future, re  vce(robust)

collect layout (colname) (result[_r_b _r_ci])
collect style cell result[_r_b _r_ci], nformat(%8.3f)
collect stars _r_p 0.001 "***" 0.01 "**" 0.05 "*", attach(_r_b)
collect style cell result[_r_ci], cidelimiter(,)
collect style column, dups(center)
collect label drop colname
collect preview
collect label drop colname

collect preview

putexcel set "../Model Results/Model 1.xlsx", replace

putexcel A1 = "term"

putexcel A1 = collect
