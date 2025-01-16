/*

ANALYSIS STAGE 1

Laurence Rowley-Abel, University of Edinburgh
lrowley@ed.ac.uk

Description: This file tests the association of the Frality Index with each of the social risks individually (controlling for age and age-squared, and stratified by sex). All of the social variables that are positively associated with frailty and statistically significant for either women or men are then retained and entered into models simultaneously. Random-effects panel regression models with robust standard errors are used.

*/

// Clear environment
clear

// Set maximum number of variables
set maxvar 20000

// Set working directory to current file's location (ammend as necessary)
cd ""

// Read in the data
use "../Data/Processed Data/ELSA Frailty and Social Risks Analysis Dataset.dta"

// Drop observations with missing frailty index value
drop if missing(frailty_index)

// Drop if under 50
drop if age < 50


//// ANALYSIS STAGE 1: TESTING INDIVIDUAL EXPOSURES ////


// Set as panel data
xtset idauniq wave

// Create list of exposures
vl create precarity_vars = (non_home_wealth_scaled home_wealth_scaled income_scaled has_no_occ_pension has_no_personal_pension reduced_pension receiving_benefits ever_unemployed max_emp_insecurity ever_agency_worker ever_selfemployed ever_parttime ever_second_job ever_invol_job_loss ever_invol_retired ever_left_job_to_care ever_mixed_work_care ever_int_unpaid_care widowed divorced lives_alone renting mortgage overcrowded housing_problems invol_move ever_homeless no_central_heating fuel_poverty food_insecurity not_enough_money income_decrease not_enough_future)


// Test each exposure individually for men and women
collect clear

foreach v in $precarity_vars {
	qui: capture drop exposure
	qui: gen exposure = `v'
	qui: collect, tag(model["`v' men"]):  xtreg frailty c.age##c.age exposure if gender == 1, re vce(robust)
	qui: collect, tag(model["`v' women"]):  xtreg frailty c.age##c.age exposure if gender == 2, re vce(robust)

}

drop exposure

// Export the results for each exposure
collect layout (model)(colname[exposure]#result[_r_b _r_ci])
collect style cell colname[exposure]#result[_r_b _r_ci], nformat(%8.3f)
collect stars _r_p 0.001 "***" 0.01 "**" 0.05 "*", attach(_r_b)
collect style cell result[_r_ci], cidelimiter(,)
collect style column, dups(center)
collect preview

putexcel set "../Model Results/Preliminary Models.xlsx", replace

putexcel A1 = collect



// Recreate the list of exposures with only exposures which were postiviely and staticially significantly associated with frailty for either men or women
vl drop precarity_vars

vl create precarity_vars = (non_home_wealth_scaled home_wealth_scaled income_scaled has_no_occ_pension has_no_personal_pension reduced_pension receiving_benefits ever_unemployed ever_invol_job_loss ever_left_job_to_care ever_mixed_work_care ever_int_unpaid_care widowed divorced lives_alone renting housing_problems ever_homeless fuel_poverty food_insecurity not_enough_money income_decrease not_enough_future)

// Run a model with all the selected exposures, stratified by sex
collect clear

collect: xtreg frailty_index c.age##c.age $precarity_vars if gender == 1, re  vce(robust)

collect layout (colname) (result[_r_b _r_ci])
collect style cell result[_r_b _r_ci], nformat(%8.3f)
collect stars _r_p 0.001 "***" 0.01 "**" 0.05 "*", attach(_r_b)
collect style cell result[_r_ci], cidelimiter(,)
collect style column, dups(center)
collect preview
collect label drop colname

collect preview

putexcel set "../Model Results/Model 1.xlsx", replace

putexcel A1 = "term"

putexcel A1 = collect

collect clear

collect: xtreg frailty_index c.age##c.age $precarity_vars if gender == 2, re  vce(robust)

collect layout (colname) (result[_r_b _r_ci])
collect style cell result[_r_b _r_ci], nformat(%8.3f)
collect stars _r_p 0.001 "***" 0.01 "**" 0.05 "*", attach(_r_b)
collect style cell result[_r_ci], cidelimiter(,)
collect style column, dups(center)
collect preview
collect label drop colname

putexcel set "../Model Results/Model 2.xlsx", replace

putexcel A1 = collect

putexcel A1 = "term"
