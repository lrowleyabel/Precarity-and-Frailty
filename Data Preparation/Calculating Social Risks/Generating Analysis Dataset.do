/*

GENERATING ANALYSIS DATASET

Laurence Rowley-Abel, University of Edinburgh
lrowley@ed.ac.uk

Description: This file compiles all of the social risk variables and the calculated Frailty Index for each wave into a single dataset for analysis. The resultant dataset is in long-format.

*/

// Clear environment
clear all

// Set maximum number of variables
set maxvar 20000

// Set working directory to current file's location (ammend as necessary)
cd "C:\Users\lrowley\OneDrive - University of Edinburgh\Published Paper GitHub Repositories\New Frailty and Social Risks\Data Preparation\Calculating Social Risks"

// Read in the wide-format frailty data
use "..\..\Data\Processed Data\Harmonised ELSA Dataset with Frailty Index.dta", clear

// Drop Wave 1 variables since social risk variables is not calculated for this wave
drop *_wave_1 *_w1 h1*

// Read in each wave of social risk data and merge to the frailty data
forval W = 2/9 {
	
	
	merge 1:1 idauniq using "..\..\Data\Processed Data\ELSA Wave `W' Social Risk Variables.dta"
	
	drop if _merge == 2
	drop _merge
	
}

// Merge in additional variables from the harmonised dataset (retirement status, labour force status, cross-sectional weight)
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\h_elsa_g3.dta", keepusing(idauniq r?retemp r?lbrf_e r?cwtresp inw? r?smokev r?smoken r?smokef r?drinkd_e r?mbmi h?atoth r?igxfr)
drop if _merge == 2
drop _merge

// Merge in the cluster and strata variable from the original ELSA data (the clusters in the Harmonised ELSA data are wrong)
forval W = 2/9 {
	
	if `W' == 2 {
		merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave `W'.dta", keepusing(idauniq hseclst astratif)
		drop if _merge == 2
		drop _merge
		rename hseclst elsacluster_wave_`W'
		rename astratif elsastrata_wave_`W'
	
	}
	else {
		merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave `W'.dta", keepusing(idauniq idahhw`W' gor)
		drop if _merge == 2
		drop _merge
		rename idahhw`W' elsacluster_wave_`W'
		encode gor, gen(gor_factor)
		rename gor_factor elsastrata_wave_`W'
		drop gor

	}
	
}


// Reshape to long format
reshape long frailty_index_wave_@ p_fun_deficits_wave_@ c_fun_deficits_wave_@ adl_deficits_wave_@ chronic_deficits_wave_@ psych_deficits_wave_@ general_deficits_wave_@ /// frailty variables 
wealth_percentile_wave_@ income_percentile_wave_@ benefits_wave_@ nonhealth_benefits_wave_@ has_no_occ_pension_wave_@ has_no_personal_pension_wave_@ reduced_pension_wave_@ unemployed_wave_@ fixedterm_wave_@ agency_worker_wave_@ selfemployed_wave_@ parttime_wave_@ second_job_wave_@ invol_job_loss_wave_@ invol_retired_wave_@ ever_unemployed_wave_@ ever_fixedterm_wave_@ ever_agency_worker_wave_@ ever_selfemployed_wave_@ ever_parttime_wave_@ ever_second_job_wave_@ ever_invol_job_loss_wave_@ ever_invol_retired_wave_@ unpaid_care_wave_@ left_job_to_care_wave_@ mixed_work_care_wave_@ ever_unpaid_care_wave_@ ever_left_job_to_care_wave_@ ever_mixed_work_care_wave_@ widowed_wave_@ divorced_wave_@ lives_alone_wave_@ renting_wave_@ mortgage_wave_@ overcrowded_wave_@ housing_problems_wave_@ count_housing_problems_wave_@ invol_move_wave_@ ever_homeless_wave_@ no_central_heating_wave_@ fuel_poverty_wave_@ food_insecurity_wave_@ not_enough_money_wave_@ not_enough_future_wave_@ /// Social Risk Variables
age_w@ age_group_w@ marstat_w@ h@atotb h@atoth h@itot r@retemp r@lbrf_e r@igxfr /// other socio-demographic variables
r@smokev r@smoken r@smokef r@drinkd_e r@mbmi /// health-behaciour variables
inw@ r@cwtresp elsacluster_wave_@ elsastrata_wave_@ /// sampling variables
, i(idauniq) j(wave)

// Tidy up names of variables and label all the variables
rename *_wave_ *
rename *_w *

// Label all the variables
label variable frailty "Frailty Index"
label variable p_fun_deficits "Physical function deficit index"
label variable c_fun_deficits "Cognitive function deficit index"
label variable adl_deficits "ADL/IADL deficit index"
label variable chronic_deficits "Chronic condition deficit index"
label variable psych_deficits "Phsychological health deficit index"
label variable general_deficits "General health deficits index"
label variable education "Education level"
label variable race "Race"
label variable pob "Place of birth"
label variable marstat "Marital status"
label variable rretemp "Retirement status"
label variable rlbrf_e "Labour force status"
label variable rsmokev "Ever smoked"
label variable rsmoken "Current smoker"
label variable rsmokef "Number of cigarettes smoked per day"
label variable rdrinkd_e "Number of days per week that respondent drinks"
label variable rmbmi "Body Mass Index"
label variable hitot "Total household income"
label variable hatotb "Total household wealth"
label variable hatoth "Total home value"
label variable rigxfr "Non-disability benefit income"
label variable age "Age"
label variable age_group "Age group"
label variable gender "Gender"
label variable wave "Wave"
label variable inw "Wave-specific response status"
label variable rcwtresp "Cross-sectional weight"
label variable r9lwtresp "Longitudinal weight Wave 9"
label variable elsacluster "Sampling cluster"
label variable elsastrata "Sampling strata"

label variable income_percentile "Income percentile (equivalised)"
label variable wealth_percentile "Wealth percentile"
label variable has_no_occ_pension "No occupational pension"
label variable has_no_personal_pension "No personal pension"
label variable reduced_pension "Retired on reduced/no pension"
label variable benefits "Receiving benefits (either health-related or other)"
label variable nonhealth_benefits "Receiving non-health-related benefits"
label variable unemployed "Currently unemployed"
label variable agency_worker "Currently non-standard employed"
label variable selfemployed "Currently self-employed"
label variable fixedterm "Currently worked on a fixed-term contract"
label variable parttime "Currently worked part-time"
label variable second_job "Currently worked second job"
label variable invol_job_loss "Lost job since last interview"
label variable invol_retired "Involuntarily retired since last interview"
label variable ever_unemployed "Ever unemployed"
label variable ever_agency_worker "Ever non-standard employed"
label variable ever_selfemployed "Ever self-employed"
label variable ever_fixedterm "Ever worked on a fixed-term contract"
label variable ever_parttime "Ever worked part-time"
label variable ever_second_job "Ever worked second job"
label variable ever_invol_job_loss "Ever lost job"
label variable ever_invol_retired "Ever involuntarily retired"
label variable unpaid_care "Current hours of unpaid care respondent provides"
label variable left_job_to_care "Left job to provide unpaid care since last interview"
label variable mixed_work_care "Currently mixing paid work and unpaid caregiving"
label variable ever_unpaid_care "Maximum hours of unpaid care respondent provided across ELSA waves to date"
label variable ever_left_job_to_care "Ever left job to provide unpaid care"
label variable ever_mixed_work_care "Ever mixed paid work and unpaid care"
label variable widowed "Widowed"
label variable divorced "Divorced or separated"
label variable lives_alone "Living alone"
label variable renting "Renting"
label variable mortgage "Paying mortgage"
label variable overcrowded "Living in overcrowded housing"
label variable housing_problems "Number of housing problems (e.g. damp, pests) reported (categorical)"
label variable count_housing_problems "Number of housing problems (e.g. damp, pests) reported"
label variable invol_move "Involuntarily moved home"
label variable ever_homeless "Ever been homeless"
label variable no_central_heating "No central heating"
label variable fuel_poverty "In fuel poverty"
label variable food_insecurity "Food insecurity scale"
label variable not_enough_money "Financial ability to cover household's needs"
label variable not_enough_future "Future financial risk scale (0 - 100)"

// Add value labels where needed
label define gender 1 "Men" 2 "Women", replace
label values gender gender

label define education 1 "Less than upper secondary" 2 "Upper secondary/vocational" 3 "Tertiary"
label values education education


// Order the variables
order idauniq wave inw age age_group gender frailty p_fun c_fun adl_deficits chronic_deficits psych_deficits general_deficits wealth_percentile income_percentile benefits nonhealth_benefits has_no_occ_pension has_no_personal_pension reduced_pension unemployed fixedterm agency_worker selfemployed parttime second_job invol_job_loss invol_retired ever_unemployed ever_fixedterm ever_agency_worker ever_selfemployed ever_parttime ever_second_job ever_invol_job_loss ever_invol_retired unpaid_care left_job_to_care mixed_work_care ever_unpaid_care ever_left_job_to_care ever_mixed_work_care widowed divorced lives_alone renting mortgage overcrowded housing_problems count_housing_problems invol_move ever_homeless no_central_heating fuel_poverty food_insecurity not_enough_money not_enough_future  education hitot hatotb hatoth rigxfr marstat race pob rlbrf_e rretemp rsmokev rsmokev rsmokef rdrinkd_e rmbmi rcwtresp r9lwtresp elsacluster elsastrata


// Save the dataset
save "..\..\Data\Processed Data\ELSA Frailty and Social Risks Analysis Dataset.dta", replace
