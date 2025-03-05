/*

SENSITIVITY ANALYSES - REDUCAED MODEL 1

Laurence Rowley-Abel, University of Edinburgh
lrowley@ed.ac.uk

Description: This file runs a version of Model 1 without variables that are highly collinear. Specifically, the variable indicating renting and the variable indicating having ever mixed work and care are removed.

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


// Set as panel data
xtset idauniq wave


// Run a model with all the selected exposures
collect clear

collect: xtreg frailty_index c.age##c.age i.gender wealth_percentile income_percentile benefits has_no_occ_pension has_no_personal_pension reduced_pension ever_unemployed ever_invol_job_loss  i.ever_unpaid_care ever_left_job_to_care widowed divorced lives_alone ever_homeless i.housing_problems fuel_poverty i.food_insecurity i.not_enough_money not_enough_future, re  vce(robust)

collect layout (colname) (result[_r_b _r_ci])
collect style cell result[_r_b _r_ci], nformat(%8.3f)
collect stars _r_p 0.001 "***" 0.01 "**" 0.05 "*", attach(_r_b)
collect style cell result[_r_ci], cidelimiter(,)
collect style column, dups(center)
collect label drop colname
collect preview
collect label drop colname

collect preview

putexcel set "../Model Results/Model 5.xlsx", replace

putexcel A1 = "term"

putexcel A1 = collect