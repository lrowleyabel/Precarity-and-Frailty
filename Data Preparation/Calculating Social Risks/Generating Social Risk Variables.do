/*

GENERATING SOCIAL RISK VARIABLES

Laurence Rowley-Abel, University of Edinburgh
lrowley@ed.ac.uk

Description: This file generates for each wave each of the social risk variables to be used in the analysis. All of the variables are scaled to between 0 and 1, with higher values indicating worse social circumstances. It creates the following variables:
	- non_home_wealth_scaled : wealth (exluding home value) percentile reversed such that higher values equals lower wealth
	- home_wealth_scaled : home value pecentile reversed such that higher values equals lower value
	- income_scaled : income percentile reversed such that higher values equals lower income
	- has_no_occ_pension : has no occupational pension
	- has_no_personal_pension : has no personal pension
	- reduced_pension : retired on a reduced pension
	- receiving_benefits : is receiving benefits
	- ever_unemployed : has reported ever being unemployed either at current/previous ELSA waves or in life history module
	- max_emp_insecurity : maximum level of employment contract insecurity reported at current/previous ELSA waves
	- ever_agency_worker : ever reported being a non-standard worker (e.g. agency worker, freelancer etc) at current/previous ELSA waves
	- ever_selfemployed : ever self-employed at current/previous ELSA waves
	- ever_parttime : ever worked part-time at current/previous ELSA waves
	- ever_second_job : ever worked a second job at current/previous ELSA waves
	- ever_invol_job_loss : ever experienced innvoluntary job loss at current/previous ELSA waves or in life history module
	- ever_invol_retired : ever reported having to involuntarily retired at current/previous ELSA waves
	- ever_left_job_to_care : ever reporting having to leave job to provide care at current/previous ELSA waves
	- ever_mixed_work_care : ever been mixing substantial amounts of work and unpaid caregiving at current/previous ELSA waves
	- ever_int_unpaid_care : ever been providing intensive (35+ hours per week) of unpaid care at current/previous ELSA waves
	- widowed : whether widowed
	- divorced : whether divorced
	- lives_alone : whether living alone
	- renting : whether renting
	- mortgage : whether paying a mortgage
	- overcrowded : whether living in overcrowded housing
	- housing_problems : number of housing problems reported
	- invol_move : whether had to involuntarily move home since last wave
	- ever_homeless : ever reported being homeless in life history module
	- no_central_heating : whether living without central heating
	- fuel_poverty : whether in fuel poverty (i.e. >10% of household income being spent on energy costs)
	- food_insecurity : whether household is experiencing food insecurity
	- not_enough_money : whether has enough money to cover household needs
	- income_decrease : whether experienced a substantial decrease (>25%) in income since last interview
	- not_enough_future : self-reported likelihood of not having enough money in the future to cover household needs

*/

// Clear environment
clear

// Set maximum number of variables
set maxvar 20000

// Set working directory to current file's location (ammend as necessary)
cd ""

// For Waves 6 - 9, the relevant variable names/coding are consistent across waves, so we can loop through these waves and create the social risk variables. For the other waves, we will create the social risk variables individually for each wave.

forval W = 6/9 {
	
	// Read in the original ELSA file
	use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave `W'.dta", clear
	
	rename *, lower
	
	// Create indicator of the previous wave number
	local lastW = `W' - 1
	
	if `lastW' == 0 {
		local lastW = 1
	}

	// Keep the relevant variables
	if `W' >= 8 {
			keep idauniq w`W'indout indager indsex wperp wpdes wprrmrh wprrmre wprrmfi wpreamrh wpreamre wpreamfi wpactw wpowkaf wpowkif wpcjag wpcjse wpcjsc wpever wpcjob wpstj wpemp wpljomti wpljomdi wpljomcl wpljomre wpljom* wplnj wpwynmti wpwynmrh wpwynmou wpwynmre wpwynmor iintdaty wpystmti wpystmrh wpystmou wpystmre wpystmfi wpystm* ercac wphjob cahpc headl96 catno hotenu hopro* homove hormvmer hormvmsp hormvmof hormvmpc hocenh homeal homoft exrela *nssec* sclddr exrslf
	
	}
	else {
		keep idauniq w`W'indout indager indsex wperp wpdes wprrmrh wprrmre wprrmfi wpreamrh wpreamre wpreamfi wpactw wpowkaf wpowkif wpcjag wpcjse wpcjsc wpever wpcjob wpstj wpemp wpljomti wpljomdi wpljomcl wpljomre wpljom* wplnj wpwynmti wpwynmrh wpwynmou wpwynmre wpwynmor wplljy iintdaty wpystmti wpystmrh wpystmou wpystmre wpystmfi wpystm* ercac wphjob cahpc headl96 catno hotenu hopro* homove hormvmer hormvmsp hormvmof hormvmpc hocenh homeal homoft exrela *nssec* sclddr exrslf
	
	}
	
	// Merge in variables to be used from the Harmonised ELSA file
	merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\h_elsa_g3.dta", keepusing(idauniq h`W'atoth h`W'atotb h`W'itot r`W'issdi r`W'igxfr r`W'unemp r`W'jhours r`W'work2 h`W'hhres r`W'mstat hh`W'cutil raeduc_e raracem rabplace h`lastW'itot r`lastW'issdi r`lastW'igxfr r`W'retemp)
	drop if _merge == 2
	drop _merge
	
	// Merge in variables to be used from the IFS Derived Variables files
	merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Wave `W'.dta", keepusing(idauniq nrooms npeople numbus numhhad numhhkid spage)
	drop if _merge == 2
	drop _merge
	
	// Merge in variables to be used from the Financial Derived Variables files
	merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Financial Wave `W'.dta", keepusing(idauniq totinc_bu_s eqtotinc_bu_s beninc_bu_s bueq)
	drop if _merge == 2
	drop _merge
	
	
	
	//// WEALTH DOMAIN ////
	
	
	
	// Calculate net worth of assets excluding primary residence
	gen non_home_wealth = h`W'atotb - h`W'atoth
	
	// Calculate percetniles for net worth of assets excluding primary residence
	xtile non_home_wealth_percentile = non_home_wealth, nq(100)
	
	// Create scaled version of quintiles for net worth of assets excluding primary residence
	gen non_home_wealth_scaled = ((non_home_wealth_percentile/100)*-1)+1

	// Calculate percentiles for net worth of primary residence
	xtile home_wealth_percentile = h`W'atoth, nq(100)
	
	// Create scaled version of percentiles for net worth of primary residence
	gen home_wealth_scaled = ((home_wealth_percentile/100)*-1)+1
	
	
	//// INCOME AND PENSIONS DOMAIN ////
	
	
	
	// Calculate percentiles for equivalised income excluding benefits
	
	mvdecode totinc_bu_s, mv(-999 -998 -995)
	gen nonben_income = totinc_bu_s - beninc_bu_s	
	gen eq_nonben_income = nonben_income/bueq
	xtile income_percentile = eq_nonben_income, nq(100)
	
	// Create scaled version of quintiles for equivalised income
	gen income_scaled = ((income_percentile/100)*-1)+1
	
	// Calculate percentiles for non-equivalised income
	mvdecode totinc_bu_s, mv(-999 -998 -995)
	xtile non_equiv_income_percentiles = totinc_bu_s, nq(100)
	
	
	// Calculate percentiles for non-equivalised income from the Harmonised dataset variable
	xtile h_non_equiv_income_percentiles = h`W'itot, nq(100)
	
	//  Use the Pensions Grid files to create indicators of whther respondent has occupational/private pensions and merge in those variable
	preserve
	
	use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Pensions Data\ELSA Pensions Grid Wave `W'.dta", clear
	
	rename *, lower
	
	gen occupation_pension = 0
	replace occupation_pension = 1 if wpffpent == 1 | wppent == 1

	gen personal_pension = 0
	replace personal_pension = 1 if wpffpent != 1 & wppent != 1

	collapse (max) occupation_pension personal_pension, by(idauniq)

	rename occupation_pension has_occ_pension
	rename personal_pension has_personal_pension

	save "..\..\Data\Processed Data\ELSA Occupational and Private Pensions Wave `W'", replace
	
	restore
	
	merge 1:1 idauniq using "..\..\Data\Processed Data\ELSA Occupational and Private Pensions Wave `W'"
	drop if _merge == 2
	
	replace has_occ_pension = 0 if _merge == 1  & w`W'indout == 11
	replace has_personal_pension = 0 if _merge == 1 & w`W'indout == 11
	
	gen has_no_occ_pension = 1 if has_occ_pension == 0
	replace has_no_occ_pension = 0 if has_occ_pension == 1
	
	gen has_no_personal_pension = 1 if has_personal_pension == 0
	replace has_no_personal_pension = 0 if has_personal_pension == 1
	
	drop _merge

	// Create an indicator of whether respondent retired on a reduced/no pension
	merge 1:1 idauniq using "..\..\Data\Processed Data\Fed Forward Employment and Retirement Variables.dta", keepusing(idauniq W`W'ffwperp)
	drop if _merge == 2
	drop _merge
	
	
	gen reduced_pension = 1 if W`W'ffwperp == 2 | W`W'ffwperp == 3
	replace reduced_pension = 0 if W`W'ffwperp == 1 | W`W'ffwperp == -1
	replace reduced_pension = . if W`W'ffwperp < -1
	
	
	// Create indicator of whether respondent is receiving benefits
	gen receiving_benefits = 1 if r`W'issdi > 0 | r`W'igxfr > 0
	replace receiving_benefits = 0 if r`W'issdi == 0 & r`W'igxfr == 0
	
	
	
	//// EMPLOYMENT AND RETIREMENT ////
	
	
	
	forval pw = 2(1)`W' {
		
		merge 1:1 idauniq using "..\..\Data\Processed Data\Employment and Caregiving Variables Wave `pw'.dta"
		drop if _merge == 2
		drop _merge
		rename (unemployed fixedterm agency_worker selfemployed parttime second_job invol_job_loss invol_retired left_job_to_care mixed_work_care intensive_unpaid_care) W`pw'_=

	}
	
	// Create indicator of ever being unemployed across all waves to date
	egen ever_unemployed = rowmax(W?_unemployed)
	
	// Create indicator of maximum employment insecurity exoerienced across all waves to date
	egen max_emp_insecurity = rowmax(W?_fixedterm)
	
	// Create indicator of ever working as agency worker across all waves to date
	egen ever_agency_worker = rowmax(W?_agency_worker)
	
	// Create indicator of ever working as self-employed across all waves to date
	egen ever_selfemployed = rowmax(W?_selfemployed)
	
	// Create indicator of ever working part-time across all waves to date
	egen ever_parttime = rowmax(W?_parttime)
	
	// Create indicator of ever working multiple jobs simultaneously across all waves to date
	egen ever_second_job = rowmax(W?_second_job)
	
	// Create indicator of ever experiencing job loss across all waves to date
	egen ever_invol_job_loss = rowmax(W?_invol_job_loss)
	
	// Create indicator of ever experiencing involuntary retirement/semi-retirement across all waves to date
	egen ever_invol_retired = rowmax(W?_invol_retired)
	
	// Create indicator of ever having to leave job to care across all waves to date
	egen ever_left_job_to_care = rowmax(W?_left_job_to_care)
	
	// Create indicator of maximum intensity of mixing work and care across all waves to date
	egen ever_mixed_work_care = rowmax(W?_mixed_work_care)
	
	
	// Merge in Life History data and update ever_unemployed and ever_invol_job_loss to being present if the respondent reports having experienced these during their life
	merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_life_history_data.dta", keepusing(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1 rwbus)
	drop if _merge == 2
	drop _merge
	
	egen lifecourse_unemployed = rowmax(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1)
	
	replace ever_unemployed = 1 if lifecourse_unemployed == 1
	
	replace ever_invol_job_loss = 1 if rwbus == 1
	
	
	
	//// CARE ////
	
	
	
	// Create indicator of current intensity of unpaid caregiving
	xtile unpaid_care_quintile = ercac if ercac > 0, nq(5)
	
	gen unpaid_care_intensity = .
	replace unpaid_care_intensity = 1 if unpaid_care_quintile == 5
	replace unpaid_care_intensity = 0.8 if unpaid_care_quintile == 4
	replace unpaid_care_intensity = 0.6 if unpaid_care_quintile == 3
	replace unpaid_care_intensity = 0.4 if unpaid_care_quintile == 2
	replace unpaid_care_intensity = 0.2 if unpaid_care_quintile == 1
	replace unpaid_care_intensity = 0 if ercac == -1
	
	// Create indicator of having ever provided intensive unpaid care
	egen ever_int_unpaid_care = rowmax(W?_intensive_unpaid_care)
	
	
	// Create indicator of having unmet care needs
	gen unmet_care_need = 0
	replace unmet_care_need = 1 if (cahpc == 2 | cahpc == 3 | cahpc == 4) | (headl96 == 0 & catno == 0)
	replace unmet_care_need = . if cahpc < -1 | headl96 < -1
	
	
	
	//// LIVING ARRANGEMENTS ////
	
	
	
	// Create indicatpr of living alone
	gen lives_alone = .
	replace lives_alone = 1 if h`W'hhres == 1
	replace lives_alone = 0 if h`W'hhres > 1
	
	
	
	//// RELATIONSHIPS ////
	
	
	
	// Create indicator of being widowed
	gen widowed = .
	replace widowed = 1 if r`W'mstat == 7
	replace widowed = 0 if r`W'mstat == 1 | r`W'mstat == 3 | r`W'mstat == 4 | r`W'mstat == 5 | r`W'mstat == 8
	
	// Create indicator being divorced/separated
	gen divorced = .
	replace divorced = 1 if r`W'mstat == 4 | r`W'mstat == 5
	replace divorced = 0 if r`W'mstat == 1 | r`W'mstat == 3 | r`W'mstat == 7 | r`W'mstat == 8
	
	
	
	//// HOUSING ////
	
	
	
	// Create indicator of renting
	gen renting = 0
	replace renting = 1 if hotenu == 3 | hotenu == 4
	replace renting = . if hotenu < -1
	
	// Create indicator of paying a mortgage
	gen mortgage = 0
	replace mortgage = 1 if hotenu == 2 | hotenu == 3
	replace mortgage = . if hotenu < -1
	
	// Create indicator of living in overcrowded housing
	gen n_pair_children = floor(numhhkid/2)
	gen n_remaining_children = numhhkid - (2*n_pair_children)
	gen standard_rooms = 1 + numbus + n_pair_children + n_remaining_children
	
	gen overcrowded = 0 if nrooms >= standard_rooms
	replace overcrowded = 1 if nrooms < standard_rooms
	replace overcrowded = . if numhhkid == . | numbus == .
	
	// Create indicator of housing problems
	drop hoprom86 hoprom96
	mvdecode hoprom*, mv(-1=.i \ -100/-2 = .m)
	egen housing_problems = rowmean(hoprom*)
	egen count_housing_problems = rowtotal(hoprom*)
	replace housing_problems = 0 if hopromsp == .i
	replace count_housing_problems = 0 if hopromsp == .i
	
	
	
	
	// Create indicator of whether home has no central heating
	gen no_central_heating = 0
	replace no_central_heating = 1 if hocenh == 2
	replace no_central_heating = . if hocenh < -1
	
	// Create indicator of having involuntarily moved home
	gen invol_move = 0
	replace invol_move = 1 if homove >= (iintdaty - 5) & (hormvmer == 1 | hormvmsp == 1 | hormvmof == 1 | hormvmpc == 1)
	replace invol_move = . if homove < -1 | hormvmer < -1
	
	// Use the Life History Module data to create an indicator of whether the respondent has ever been homeless
	merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_life_history_data.dta", keepusing(idauniq ralis8)
	drop if _merge == 2
	drop _merge
	
	gen ever_homeless = 0
	replace ever_homeless = 1 if ralis8 == 1
	replace ever_homeless = . if ralis8 < -1

	
	
	//// GENERAL DEPRIVATION ////
	
	
	
	// Create indicator of fuel poverty
	gen fuel_poverty = 0
	replace fuel_poverty = 1 if hh`W'cutil > (0.1 * h`W'itot)
	replace fuel_poverty = . if hh`W'cutil >= . | h`W'itot >= .
	
	// Create indicator of food insecurity
	gen food_insecurity = 0
	replace food_insecurity = 0.25 if homeal == 1 & homoft == 4
	replace food_insecurity = 0.5 if homeal == 1 & homoft == 3
	replace food_insecurity = 0.75 if homeal == 1 & homoft == 2
	replace food_insecurity = 1 if homeal == 1 & homoft == 1
	replace food_insecurity = . if homeal < -1
	
	// Create indicator of not having enough money to cover needs
	gen not_enough_money = 0
	replace not_enough_money = 0.25 if exrela == 2
	replace not_enough_money = 0.5 if exrela == 3
	replace not_enough_money = 0.75 if exrela == 4
	replace not_enough_money = 1 if exrela == 5
	replace not_enough_money = . if exrela < 0
	
	
	
	//// UNCERTAINTY AND VOLATILITY ////
	
	
	
	// Use the calculate data on Last Recorded Income and Benefits Variables to create indicators of whether a respondent has experienced a substantial decrease in income or benefits
	merge 1:1 idauniq using "..\..\Data\Processed Data\Last Recorded Income and Benefits Variables.dta"
	drop if _merge == 2
	drop _merge
	
	replace W`W'_last_income_report = 900000 if W`W'_last_income_report == .t
	
	gen income_decrease = .
	
	if W`W'_last_income_report > 0 {
		
		replace income_decrease = 0 if eq_nonben_income >= (0.75*W`W'_last_income_report)
		replace income_decrease = 1 if eq_nonben_income < (0.75*W`W'_last_income_report)
	
	}
	else {
		
		replace income_decrease = 0 if eq_nonben_income >= (1.25*W`W'_last_income_report)
		replace income_decrease = 1 if eq_nonben_income < (1.25*W`W'_last_income_report)
	
		
	}
	
	replace income_decrease = . if eq_nonben_income >= . | W`W'_last_income_report >= .
	
	// Create indicator of self-reported likelihood that respondent will not have enough money to cover needs in the future
	gen not_enough_future = exrslf/100 if exrslf >= 0 & exrslf < .
	
	
	
	
	
	//// SAVE THE DATA ////

	keep idauniq non_home_wealth_scaled home_wealth_scaled income_scaled has_no_occ_pension has_no_personal_pension reduced_pension receiving_benefits ever_unemployed max_emp_insecurity ever_agency_worker ever_selfemployed ever_parttime ever_second_job ever_invol_job_loss ever_invol_retired ever_left_job_to_care ever_mixed_work_care ever_int_unpaid_care widowed divorced lives_alone renting mortgage overcrowded housing_problems count_housing_problems invol_move ever_homeless no_central_heating fuel_poverty food_insecurity not_enough_money income_decrease not_enough_future

	rename * =_wave_`W'
	rename idauniq_wave_`W' idauniq

	save  "..\..\Data\Processed Data\ELSA Wave `W' Social Risk Variables.dta", replace


}



/////////////////
// WAVES 2 - 5 //
/////////////////



//// WAVE 2 ////



// Read in the original ELSA file
use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 2.dta", clear

rename *, lower


// Keep the relevant variables
keep idauniq w2indout iintdty indager indsex wperp wpdes ercac hehpc hehpa hotenu hoprm* homove hormvm* hocenh homeal homoft exrela exrslf


// Merge in variables to be used from the Harmonised ELSA file
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\h_elsa_g3.dta", keepusing(idauniq h2atoth h2atotb h2itot r2issdi r2igxfr r2unemp r2jhours r2work2 h2hhres r2mstat hh2cutil raeduc_e raracem rabplace h1itot r2retemp)
drop if _merge == 2
drop _merge

// Merge in variables to be used from the IFS Derived Variables files
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Wave 2.dta", keepusing(idauniq nrooms npeople numbus numhhad numhhkid spage)
drop if _merge == 2
drop _merge

// Merge in variables to be used from the Financial Derived Variables files
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Financial Wave 2.dta", keepusing(idauniq totinc_bu_s eqtotinc_bu_s beninc_bu_s bueq)
drop if _merge == 2
drop _merge



//// WEALTH DOMAIN ////


	
	
// Calculate net worth of assets excluding primary residence
gen non_home_wealth = h2atotb - h2atoth

// Calculate percetniles for net worth of assets excluding primary residence
xtile non_home_wealth_percentile = non_home_wealth, nq(100)

// Create scaled version of quintiles for net worth of assets excluding primary residence
gen non_home_wealth_scaled = ((non_home_wealth_percentile/100)*-1)+1

// Calculate percentiles for net worth of primary residence
xtile home_wealth_percentile = h2atoth, nq(100)

// Create scaled version of percentiles for net worth of primary residence
gen home_wealth_scaled = ((home_wealth_percentile/100)*-1)+1



//// INCOME AND PENSIONS DOMAIN ////



// Calculate percentiles for equivalised income excluding benefits

mvdecode totinc_bu_s, mv(-999 -998 -995)
gen nonben_income = totinc_bu_s - beninc_bu_s	
gen eq_nonben_income = nonben_income/bueq
xtile income_percentile = eq_nonben_income, nq(100)

// Create scaled version of quintiles for equivalised income
gen income_scaled = ((income_percentile/100)*-1)+1

// Calculate percentiles for non-equivalised income
mvdecode totinc_bu_s, mv(-999 -998 -995)
xtile non_equiv_income_percentiles = totinc_bu_s, nq(100)


// Calculate percentiles for non-equivalised income from the Harmonised dataset variable
xtile h_non_equiv_income_percentiles = h2itot, nq(100)



//  Use the Pensions Grid files to create indicators of whther respondent has occupational/private pensions and merge in those variable
preserve

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Pensions Data\ELSA Pensions Grid Wave 2.dta", clear

rename *, lower

gen occupation_pension = 0
replace occupation_pension = 1 if demppen == 1

gen personal_pension = 0
replace personal_pension = 1 if demppen == 0

collapse (max) occupation_pension personal_pension, by(idauniq)

rename occupation_pension has_occ_pension
rename personal_pension has_personal_pension

save "..\..\Data\Processed Data\ELSA Occupational and Private Pensions Wave 2", replace

restore

merge 1:1 idauniq using "..\..\Data\Processed Data\ELSA Occupational and Private Pensions Wave 2"
drop if _merge == 2

replace has_occ_pension = 0 if _merge == 1  & w2indout == 11
replace has_personal_pension = 0 if _merge == 1 & w2indout == 11

gen has_no_occ_pension = 1 if has_occ_pension == 0
replace has_no_occ_pension = 0 if has_occ_pension == 1

gen has_no_personal_pension = 1 if has_personal_pension == 0
replace has_no_personal_pension = 0 if has_personal_pension == 1

drop _merge

// Create an indicator of whether respondent retired on a reduced/no pension
merge 1:1 idauniq using "..\..\Data\Processed Data\Fed Forward Employment and Retirement Variables.dta", keepusing(idauniq W2ffwperp)
drop if _merge == 2
drop _merge

gen reduced_pension = 1 if W2ffwperp == 2 | W2ffwperp == 3
replace reduced_pension = 0 if W2ffwperp == 1 | W2ffwperp == -1
replace reduced_pension = . if W2ffwperp < -1


// Create indicator of whether respondent is receiving benefits
gen receiving_benefits = 1 if r2issdi > 0 | r2igxfr > 0
replace receiving_benefits = 0 if r2issdi == 0 & r2igxfr == 0



//// EMPLOYMENT AND RETIREMENT ////


forval pw = 2(1)2 {
	
	merge 1:1 idauniq using "..\..\Data\Processed Data\Employment and Caregiving Variables Wave `pw'.dta"
	drop if _merge == 2
	drop _merge
	rename (unemployed fixedterm agency_worker selfemployed parttime second_job invol_job_loss invol_retired left_job_to_care mixed_work_care intensive_unpaid_care) W`pw'_=

}

// Create indicator of ever being unemployed across all waves to date
egen ever_unemployed = rowmax(W?_unemployed)

// Create indicator of maximum employment insecurity exoerienced across all waves to date
egen max_emp_insecurity = rowmax(W?_fixedterm)

// Create indicator of ever working as agency worker across all waves to date
egen ever_agency_worker = rowmax(W?_agency_worker)

// Create indicator of ever working as self-employed across all waves to date
egen ever_selfemployed = rowmax(W?_selfemployed)

// Create indicator of ever working part-time across all waves to date
egen ever_parttime = rowmax(W?_parttime)

// Create indicator of ever working multiple jobs simultaneously across all waves to date
egen ever_second_job = rowmax(W?_second_job)

// Create indicator of ever experiencing job loss across all waves to date
egen ever_invol_job_loss = rowmax(W?_invol_job_loss)

// Create indicator of ever experiencing involuntary retirement/semi-retirement across all waves to date
egen ever_invol_retired = rowmax(W?_invol_retired)

// Create indicator of ever having to leave job to care across all waves to date
egen ever_left_job_to_care = rowmax(W?_left_job_to_care)

// Create indicator of maximum intensity of mixing work and care across all waves to date
egen ever_mixed_work_care = rowmax(W?_mixed_work_care)



// Merge in Life History data and update ever_unemployed and ever_invol_job_loss to being present if the respondent reports having experienced these during their life
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_life_history_data.dta", keepusing(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1 rwbus)
drop if _merge == 2
drop _merge

egen lifecourse_unemployed = rowmax(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1)

replace ever_unemployed = 1 if lifecourse_unemployed == 1

replace ever_invol_job_loss = 1 if rwbus == 1

	
//// CARE ////



// Create indicator of current intensity of unpaid caregiving
xtile unpaid_care_quintile = ercac if ercac > 0, nq(5)

gen unpaid_care_intensity = .
replace unpaid_care_intensity = 1 if unpaid_care_quintile == 5
replace unpaid_care_intensity = 0.8 if unpaid_care_quintile == 4
replace unpaid_care_intensity = 0.6 if unpaid_care_quintile == 3
replace unpaid_care_intensity = 0.4 if unpaid_care_quintile == 2
replace unpaid_care_intensity = 0.2 if unpaid_care_quintile == 1
replace unpaid_care_intensity = 0 if ercac == -1

// Create indicator of having ever provided intensive unpaid care
egen ever_int_unpaid_care = rowmax(W?_intensive_unpaid_care)
	

// Create indicator of having unmet care needs
gen unmet_care_need = 0
replace unmet_care_need = 1 if (hehpc == 2 | hehpc == 3 | hehpc == 4) | (hehpa == 2)
replace unmet_care_need = . if hehpc < -1 | hehpa < -1



//// LIVING ARRANGEMENTS ////



// Create indicatpr of living alone
gen lives_alone = .
replace lives_alone = 1 if h2hhres == 1
replace lives_alone = 0 if h2hhres > 1



//// RELATIONSHIPS ////



// Create indicator of being widowed
gen widowed = .
replace widowed = 1 if r2mstat == 7
replace widowed = 0 if r2mstat == 1 | r2mstat == 3 | r2mstat == 4 | r2mstat == 5 | r2mstat == 8

// Create indicator being divorced/separated
gen divorced = .
replace divorced = 1 if r2mstat == 4 | r2mstat == 5
replace divorced = 0 if r2mstat == 1 | r2mstat == 3 | r2mstat == 7 | r2mstat == 8



//// HOUSING ////



// Create indicator of renting
gen renting = 0
replace renting = 1 if hotenu == 3 | hotenu == 4
replace renting = . if hotenu < -1

// Create indicator of paying a mortgage
gen mortgage = 0
replace mortgage = 1 if hotenu == 2 | hotenu == 3
replace mortgage = . if hotenu < -1

// Create indicator of living in overcrowded housing
gen n_pair_children = floor(numhhkid/2)
gen n_remaining_children = numhhkid - (2*n_pair_children)
gen standard_rooms = 1 + numbus + n_pair_children + n_remaining_children

gen overcrowded = 0 if nrooms >= standard_rooms
replace overcrowded = 1 if nrooms < standard_rooms
replace overcrowded = . if numhhkid == . | numbus == .

// Create indicator of housing problems
gen housing_problems = 0
foreach v of varlist hoprm1 - hoprm10 {
	forval x = 1/52 {
		replace housing_problems = housing_problems + 1 if `v' == `x'
	}
}
replace housing_problems = housing_problems/12
replace housing_problems = . if hoprm1 < -1


// Create indicator of whether home has no central heating
gen no_central_heating = 0
replace no_central_heating = 1 if hocenh == 2
replace no_central_heating = . if hocenh < -1

// Create indicator of having involuntarily moved home
gen invol_move = 0
foreach v of varlist hormvm1-hormvm4 {
	foreach x in 6 9 12 {
		replace invol_move = 1 if homove >= (iintdty - 5) & (`v' == `x')
	}
}
replace invol_move = . if homove < -1 | hormvm1 < -1


// Use the Life History Module data to create an indicator of whether the respondent has ever been homeless
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_life_history_data.dta", keepusing(idauniq ralis8)
drop if _merge == 2
drop _merge

gen ever_homeless = 0
replace ever_homeless = 1 if ralis8 == 1
replace ever_homeless = . if ralis8 < -1



//// GENERAL DEPRIVATION ////



// Create indicator of fuel poverty
gen fuel_poverty = 0
replace fuel_poverty = 1 if hh2cutil > (0.1 * h2itot)
replace fuel_poverty = . if hh2cutil >= . | h2itot >= .

// Create indicator of food insecurity
gen food_insecurity = 0
replace food_insecurity = 0.25 if homeal == 1 & homoft == 4
replace food_insecurity = 0.5 if homeal == 1 & homoft == 3
replace food_insecurity = 0.75 if homeal == 1 & homoft == 2
replace food_insecurity = 1 if homeal == 1 & homoft == 1
replace food_insecurity = . if homeal < -1

// Create indicator of not having enough money to cover needs
gen not_enough_money = 0
replace not_enough_money = 0.25 if exrela == 2
replace not_enough_money = 0.5 if exrela == 3
replace not_enough_money = 0.75 if exrela == 4
replace not_enough_money = 1 if exrela == 5
replace not_enough_money = . if exrela < 0



//// UNCERTAINTY AND VOLATILITY ////



// Use the calculate data on Last Recorded Income and Benefits Variables to create indicators of whether a respondent has experienced a substantial decrease in income or benefits
merge 1:1 idauniq using "..\..\Data\Processed Data\Last Recorded Income and Benefits Variables.dta"
drop if _merge == 2
drop _merge

replace W2_last_income_report = 900000 if W2_last_income_report == .t

gen income_decrease = .

if W2_last_income_report > 0 {
	
	replace income_decrease = 0 if eq_nonben_income >= (0.75*W2_last_income_report)
	replace income_decrease = 1 if eq_nonben_income < (0.75*W2_last_income_report)

}
else {
	
	replace income_decrease = 0 if eq_nonben_income >= (1.25*W2_last_income_report)
	replace income_decrease = 1 if eq_nonben_income < (1.25*W2_last_income_report)

	
}

replace income_decrease = . if eq_nonben_income >= . | W2_last_income_report >= .

// Create indicator of self-reported likelihood that respondent will not have enough money to cover needs in the future
gen not_enough_future = exrslf/100 if exrslf >= 0 & exrslf < .


//// SAVE THE DATA ////
	
keep idauniq non_home_wealth_scaled home_wealth_scaled income_scaled has_no_occ_pension has_no_personal_pension reduced_pension receiving_benefits ever_unemployed max_emp_insecurity ever_agency_worker ever_selfemployed ever_parttime ever_second_job ever_invol_job_loss ever_invol_retired ever_left_job_to_care ever_mixed_work_care ever_int_unpaid_care widowed divorced lives_alone renting mortgage overcrowded housing_problems invol_move ever_homeless no_central_heating fuel_poverty food_insecurity not_enough_money income_decrease not_enough_future

rename * =_wave_2
rename idauniq_wave_2 idauniq

save  "..\..\Data\Processed Data\ELSA Wave 2 Social Risk Variables.dta", replace




//// WAVE 3 ////


// Read in the original ELSA file
use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 3.dta", clear

rename *, lower

// Keep the relevant variables

keep idauniq w3indout indager indsex wperp wpdes iintdaty ercac hehpc hehpa hotenu hopro* homove hormvmer hormvmsp hormvmof hormvmpc hocenh homeal homoft exrela exrslf


// Merge in variables to be used from the Harmonised ELSA file
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\h_elsa_g3.dta", keepusing(idauniq h3atoth h3atotb h3itot r3issdi r3igxfr r3unemp r3jhours r3work2 h3hhres r3mstat hh3cutil raeduc_e raracem rabplace h2itot r2issdi r2igxfr r3retemp)
drop if _merge == 2
drop _merge

// Merge in variables to be used from the IFS Derived Variables files
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Wave 3.dta", keepusing(idauniq nrooms npeople numbus numhhad numhhkid spage)
drop if _merge == 2
drop _merge

// Merge in variables to be used from the Financial Derived Variables files
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Financial Wave 3.dta", keepusing(idauniq totinc_bu_s eqtotinc_bu_s beninc_bu_s bueq)
drop if _merge == 2
drop _merge
	
	

//// WEALTH DOMAIN ////


	
	
// Calculate net worth of assets excluding primary residence
gen non_home_wealth = h3atotb - h3atoth

// Calculate percetniles for net worth of assets excluding primary residence
xtile non_home_wealth_percentile = non_home_wealth, nq(100)

// Create scaled version of quintiles for net worth of assets excluding primary residence
gen non_home_wealth_scaled = ((non_home_wealth_percentile/100)*-1)+1

// Calculate percentiles for net worth of primary residence
xtile home_wealth_percentile = h3atoth, nq(100)

// Create scaled version of percentiles for net worth of primary residence
gen home_wealth_scaled = ((home_wealth_percentile/100)*-1)+1



//// INCOME AND PENSIONS DOMAIN ////



// Calculate percentiles for equivalised income excluding benefits

mvdecode totinc_bu_s, mv(-999 -998 -995)
gen nonben_income = totinc_bu_s - beninc_bu_s	
gen eq_nonben_income = nonben_income/bueq
xtile income_percentile = eq_nonben_income, nq(100)

// Create scaled version of quintiles for equivalised income
gen income_scaled = ((income_percentile/100)*-1)+1

// Calculate percentiles for non-equivalised income
mvdecode totinc_bu_s, mv(-999 -998 -995)
xtile non_equiv_income_percentiles = totinc_bu_s, nq(100)


// Calculate percentiles for non-equivalised income from the Harmonised dataset variable
xtile h_non_equiv_income_percentiles = h3itot, nq(100)


//  Use the Pensions Grid files to create indicators of whther respondent has occupational/private pensions and merge in those variable
preserve

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Pensions Data\ELSA Pensions Grid Wave 3.dta", clear

rename *, lower

gen occupation_pension = 0
replace occupation_pension = 1 if demppen == 1

gen personal_pension = 0
replace personal_pension = 1 if demppen == 0

collapse (max) occupation_pension personal_pension, by(idauniq)

rename occupation_pension has_occ_pension
rename personal_pension has_personal_pension

save "..\..\Data\Processed Data\ELSA Occupational and Private Pensions Wave 3", replace

restore

merge 1:1 idauniq using "..\..\Data\Processed Data\ELSA Occupational and Private Pensions Wave 3"
drop if _merge == 2

replace has_occ_pension = 0 if _merge == 1  & w3indout == 11
replace has_personal_pension = 0 if _merge == 1 & w3indout == 11

gen has_no_occ_pension = 1 if has_occ_pension == 0
replace has_no_occ_pension = 0 if has_occ_pension == 1

gen has_no_personal_pension = 1 if has_personal_pension == 0
replace has_no_personal_pension = 0 if has_personal_pension == 1

drop _merge


// Create an indicator of whether respondent retired on a reduced/no pension
merge 1:1 idauniq using "..\..\Data\Processed Data\Fed Forward Employment and Retirement Variables.dta", keepusing(idauniq W3ffwperp)
drop if _merge == 2
drop _merge


gen reduced_pension = 1 if W3ffwperp == 2 | W3ffwperp == 3
replace reduced_pension = 0 if W3ffwperp == 1 | W3ffwperp == -1
replace reduced_pension = . if W3ffwperp < -1


// Create indicator of whether respondent is receiving benefits
gen receiving_benefits = 1 if r3issdi > 0 | r3igxfr > 0
replace receiving_benefits = 0 if r3issdi == 0 & r3igxfr == 0

	

//// EMPLOYMENT AND RETIREMENT ////



forval pw = 2(1)3 {
	
	merge 1:1 idauniq using "..\..\Data\Processed Data\Employment and Caregiving Variables Wave `pw'.dta"
	drop if _merge == 2
	drop _merge
	rename (unemployed fixedterm agency_worker selfemployed parttime second_job invol_job_loss invol_retired left_job_to_care mixed_work_care intensive_unpaid_care) W`pw'_=

}

// Create indicator of ever being unemployed across all waves to date
egen ever_unemployed = rowmax(W?_unemployed)

// Create indicator of maximum employment insecurity exoerienced across all waves to date
egen max_emp_insecurity = rowmax(W?_fixedterm)

// Create indicator of ever working as agency worker across all waves to date
egen ever_agency_worker = rowmax(W?_agency_worker)

// Create indicator of ever working as self-employed across all waves to date
egen ever_selfemployed = rowmax(W?_selfemployed)

// Create indicator of ever working part-time across all waves to date
egen ever_parttime = rowmax(W?_parttime)

// Create indicator of ever working multiple jobs simultaneously across all waves to date
egen ever_second_job = rowmax(W?_second_job)

// Create indicator of ever experiencing job loss across all waves to date
egen ever_invol_job_loss = rowmax(W?_invol_job_loss)

// Create indicator of ever experiencing involuntary retirement/semi-retirement across all waves to date
egen ever_invol_retired = rowmax(W?_invol_retired)

// Create indicator of ever having to leave job to care across all waves to date
egen ever_left_job_to_care = rowmax(W?_left_job_to_care)

// Create indicator of maximum intensity of mixing work and care across all waves to date
egen ever_mixed_work_care = rowmax(W?_mixed_work_care)


// Merge in Life History data and update ever_unemployed and ever_invol_job_loss to being present if the respondent reports having experienced these during their life
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_life_history_data.dta", keepusing(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1 rwbus)
drop if _merge == 2
drop _merge

egen lifecourse_unemployed = rowmax(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1)

replace ever_unemployed = 1 if lifecourse_unemployed == 1

replace ever_invol_job_loss = 1 if rwbus == 1

	
	
//// CARE ////



// Create indicator of current intensity of unpaid caregiving
xtile unpaid_care_quintile = ercac if ercac > 0, nq(5)

gen unpaid_care_intensity = .
replace unpaid_care_intensity = 1 if unpaid_care_quintile == 5
replace unpaid_care_intensity = 0.8 if unpaid_care_quintile == 4
replace unpaid_care_intensity = 0.6 if unpaid_care_quintile == 3
replace unpaid_care_intensity = 0.4 if unpaid_care_quintile == 2
replace unpaid_care_intensity = 0.2 if unpaid_care_quintile == 1
replace unpaid_care_intensity = 0 if ercac == -1

// Create indicator of having ever provided intensive unpaid care
egen ever_int_unpaid_care = rowmax(W?_intensive_unpaid_care)


// Create indicator of having unmet care needs
gen unmet_care_need = 0
replace unmet_care_need = 1 if (hehpc == 2 | hehpc == 3 | hehpc == 4) | (hehpa == 2)
replace unmet_care_need = . if hehpc < -1 | hehpa < -1

	
	
//// LIVING ARRANGEMENTS ////



// Create indicatpr of living alone
gen lives_alone = .
replace lives_alone = 1 if h3hhres == 1
replace lives_alone = 0 if h3hhres > 1



//// RELATIONSHIPS ////



// Create indicator of being widowed
gen widowed = .
replace widowed = 1 if r3mstat == 7
replace widowed = 0 if r3mstat == 1 | r3mstat == 3 | r3mstat == 4 | r3mstat == 5 | r3mstat == 8

// Create indicator being divorced/separated
gen divorced = .
replace divorced = 1 if r3mstat == 4 | r3mstat == 5
replace divorced = 0 if r3mstat == 1 | r3mstat == 3 | r3mstat == 7 | r3mstat == 8
	
	
	
//// HOUSING ////



// Create indicator of renting
gen renting = 0
replace renting = 1 if hotenu == 3 | hotenu == 4
replace renting = . if hotenu < -1

// Create indicator of paying a mortgage
gen mortgage = 0
replace mortgage = 1 if hotenu == 2 | hotenu == 3
replace mortgage = . if hotenu < -1

// Create indicator of living in overcrowded housing
gen n_pair_children = floor(numhhkid/2)
gen n_remaining_children = numhhkid - (2*n_pair_children)
gen standard_rooms = 1 + numbus + n_pair_children + n_remaining_children

gen overcrowded = 0 if nrooms >= standard_rooms
replace overcrowded = 1 if nrooms < standard_rooms
replace overcrowded = . if numhhkid == . | numbus == .

// Create indicator of housing problems
drop hoprom86 hoprom96
mvdecode hoprom*, mv(-1=.i \ -100/-2 = .m)
egen housing_problems = rowmean(hoprom*)
replace housing_problems = 0 if hopromsp == .i


// Create indicator of whether home has no central heating
gen no_central_heating = 0
replace no_central_heating = 1 if hocenh == 2
replace no_central_heating = . if hocenh < -1

// Create indicator of having involuntarily moved home
gen invol_move = 0
replace invol_move = 1 if homove >= (iintdaty - 5) & (hormvmer == 1 | hormvmsp == 1 | hormvmof == 1 | hormvmpc == 1)
replace invol_move = . if homove < -1 | hormvmer < -1

// Use the Life History Module data to create an indicator of whether the respondent has ever been homeless
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_life_history_data.dta", keepusing(idauniq ralis8)
drop if _merge == 2
drop _merge

gen ever_homeless = 0
replace ever_homeless = 1 if ralis8 == 1
replace ever_homeless = . if ralis8 < -1

	
	
//// GENERAL DEPRIVATION ////



// Create indicator of fuel poverty
gen fuel_poverty = 0
replace fuel_poverty = 1 if hh3cutil > (0.1 * h3itot)
replace fuel_poverty = . if hh3cutil >= . | h3itot >= .

// Create indicator of food insecurity
gen food_insecurity = 0
replace food_insecurity = 0.25 if homeal == 1 & homoft == 4
replace food_insecurity = 0.5 if homeal == 1 & homoft == 3
replace food_insecurity = 0.75 if homeal == 1 & homoft == 2
replace food_insecurity = 1 if homeal == 1 & homoft == 1
replace food_insecurity = . if homeal < -1

// Create indicator of not having enough money to cover needs
gen not_enough_money = 0
replace not_enough_money = 0.25 if exrela == 2
replace not_enough_money = 0.5 if exrela == 3
replace not_enough_money = 0.75 if exrela == 4
replace not_enough_money = 1 if exrela == 5
replace not_enough_money = . if exrela < 0



//// UNCERTAINTY AND VOLATILITY ////



// Use the calculate data on Last Recorded Income and Benefits Variables to create indicators of whether a respondent has experienced a substantial decrease in income or benefits
merge 1:1 idauniq using "..\..\Data\Processed Data\Last Recorded Income and Benefits Variables.dta"
drop if _merge == 2
drop _merge

replace W3_last_income_report = 900000 if W3_last_income_report == .t

gen income_decrease = .

if W3_last_income_report > 0 {
	
	replace income_decrease = 0 if eq_nonben_income >= (0.75*W3_last_income_report)
	replace income_decrease = 1 if eq_nonben_income < (0.75*W3_last_income_report)

}
else {
	
	replace income_decrease = 0 if eq_nonben_income >= (1.25*W3_last_income_report)
	replace income_decrease = 1 if eq_nonben_income < (1.25*W3_last_income_report)

	
}

replace income_decrease = . if eq_nonben_income >= . | W3_last_income_report >= .

// Create indicator of self-reported likelihood that respondent will not have enough money to cover needs in the future
gen not_enough_future = exrslf/100 if exrslf >= 0 & exrslf < .



//// SAVE THE DATA ////
	
keep idauniq non_home_wealth_scaled home_wealth_scaled income_scaled has_no_occ_pension has_no_personal_pension reduced_pension receiving_benefits ever_unemployed max_emp_insecurity ever_agency_worker ever_selfemployed ever_parttime ever_second_job ever_invol_job_loss ever_invol_retired ever_left_job_to_care ever_mixed_work_care ever_int_unpaid_care widowed divorced lives_alone renting mortgage overcrowded housing_problems invol_move ever_homeless no_central_heating fuel_poverty food_insecurity not_enough_money income_decrease not_enough_future

rename * =_wave_3
rename idauniq_wave_3 idauniq

save  "..\..\Data\Processed Data\ELSA Wave 3 Social Risk Variables.dta", replace




//// WAVE 4 ////


// Read in the original ELSA file
use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 4.dta", clear

rename *, lower

// Keep the relevant variables

keep idauniq outindw4 indager indsex wperp wpdes iintdaty ercac hehpc hehpa hotenu hopro* homove hormvmer hormvmsp hormvmof hormvmpc hocenh homeal homoft exrela exrslf


// Merge in variables to be used from the Harmonised ELSA file
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\h_elsa_g3.dta", keepusing(idauniq h4atoth h4atotb h4itot r4issdi r4igxfr r4unemp r4jhours r4work2 h4hhres r4mstat hh4cutil raeduc_e raracem rabplace h3itot r3issdi r3igxfr r4retemp)
drop if _merge == 2
drop _merge

// Merge in variables to be used from the IFS Derived Variables files
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Wave 4.dta", keepusing(idauniq nrooms npeople numbus numhhad numhhkid spage)
drop if _merge == 2
drop _merge

// Merge in variables to be used from the Financial Derived Variables files
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Financial Wave 4.dta", keepusing(idauniq totinc_bu_s eqtotinc_bu_s beninc_bu_s bueq)
drop if _merge == 2
drop _merge
	
	

//// WEALTH DOMAIN ////

	
	
// Calculate net worth of assets excluding primary residence
gen non_home_wealth = h4atotb - h4atoth

// Calculate percetniles for net worth of assets excluding primary residence
xtile non_home_wealth_percentile = non_home_wealth, nq(100)

// Create scaled version of quintiles for net worth of assets excluding primary residence
gen non_home_wealth_scaled = ((non_home_wealth_percentile/100)*-1)+1

// Calculate percentiles for net worth of primary residence
xtile home_wealth_percentile = h4atoth, nq(100)

// Create scaled version of percentiles for net worth of primary residence
gen home_wealth_scaled = ((home_wealth_percentile/100)*-1)+1



//// INCOME AND PENSIONS DOMAIN ////



// Calculate percentiles for equivalised income excluding benefits

mvdecode totinc_bu_s, mv(-999 -998 -995)
gen nonben_income = totinc_bu_s - beninc_bu_s	
gen eq_nonben_income = nonben_income/bueq
xtile income_percentile = eq_nonben_income, nq(100)

// Create scaled version of quintiles for equivalised income
gen income_scaled = ((income_percentile/100)*-1)+1

// Calculate percentiles for non-equivalised income
mvdecode totinc_bu_s, mv(-999 -998 -995)
xtile non_equiv_income_percentiles = totinc_bu_s, nq(100)


// Calculate percentiles for non-equivalised income from the Harmonised dataset variable
xtile h_non_equiv_income_percentiles = h4itot, nq(100)

	
//  Use the Pensions Grid files to create indicators of whther respondent has occupational/private pensions and merge in those variable
preserve

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Pensions Data\ELSA Pensions Grid Wave 4.dta", clear

rename *, lower

gen occupation_pension = 0
replace occupation_pension = 1 if demppen == 1

gen personal_pension = 0
replace personal_pension = 1 if demppen == 0

collapse (max) occupation_pension personal_pension, by(idauniq)

rename occupation_pension has_occ_pension
rename personal_pension has_personal_pension

save "..\..\Data\Processed Data\ELSA Occupational and Private Pensions Wave 4", replace

restore

merge 1:1 idauniq using "..\..\Data\Processed Data\ELSA Occupational and Private Pensions Wave 4"
drop if _merge == 2

replace has_occ_pension = 0 if _merge == 1  & outindw4 == 11
replace has_personal_pension = 0 if _merge == 1 & outindw4 == 11

gen has_no_occ_pension = 1 if has_occ_pension == 0
replace has_no_occ_pension = 0 if has_occ_pension == 1

gen has_no_personal_pension = 1 if has_personal_pension == 0
replace has_no_personal_pension = 0 if has_personal_pension == 1

drop _merge


// Create an indicator of whether respondent retired on a reduced/no pension
merge 1:1 idauniq using "..\..\Data\Processed Data\Fed Forward Employment and Retirement Variables.dta", keepusing(idauniq W4ffwperp)
drop if _merge == 2
drop _merge


gen reduced_pension = 1 if W4ffwperp == 2 | W4ffwperp == 3
replace reduced_pension = 0 if W4ffwperp == 1 | W4ffwperp == -1
replace reduced_pension = . if W4ffwperp < -1


// Create indicator of whether respondent is receiving benefits
gen receiving_benefits = 1 if r4issdi > 0 | r4igxfr > 0
replace receiving_benefits = 0 if r4issdi == 0 & r4igxfr == 0

	

//// EMPLOYMENT AND RETIREMENT ////



forval pw = 2(1)4 {
	
	merge 1:1 idauniq using "..\..\Data\Processed Data\Employment and Caregiving Variables Wave `pw'.dta"
	drop if _merge == 2
	drop _merge
	rename (unemployed fixedterm agency_worker selfemployed parttime second_job invol_job_loss invol_retired left_job_to_care mixed_work_care intensive_unpaid_care) W`pw'_=

}

// Create indicator of ever being unemployed across all waves to date
egen ever_unemployed = rowmax(W?_unemployed)

// Create indicator of maximum employment insecurity exoerienced across all waves to date
egen max_emp_insecurity = rowmax(W?_fixedterm)

// Create indicator of ever working as agency worker across all waves to date
egen ever_agency_worker = rowmax(W?_agency_worker)

// Create indicator of ever working as self-employed across all waves to date
egen ever_selfemployed = rowmax(W?_selfemployed)

// Create indicator of ever working part-time across all waves to date
egen ever_parttime = rowmax(W?_parttime)

// Create indicator of ever working multiple jobs simultaneously across all waves to date
egen ever_second_job = rowmax(W?_second_job)

// Create indicator of ever experiencing job loss across all waves to date
egen ever_invol_job_loss = rowmax(W?_invol_job_loss)

// Create indicator of ever experiencing involuntary retirement/semi-retirement across all waves to date
egen ever_invol_retired = rowmax(W?_invol_retired)

// Create indicator of ever having to leave job to care across all waves to date
egen ever_left_job_to_care = rowmax(W?_left_job_to_care)

// Create indicator of maximum intensity of mixing work and care across all waves to date
egen ever_mixed_work_care = rowmax(W?_mixed_work_care)


// Merge in Life History data and update ever_unemployed and ever_invol_job_loss to being present if the respondent reports having experienced these during their life
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_life_history_data.dta", keepusing(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1 rwbus)
drop if _merge == 2
drop _merge

egen lifecourse_unemployed = rowmax(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1)

replace ever_unemployed = 1 if lifecourse_unemployed == 1

replace ever_invol_job_loss = 1 if rwbus == 1

	
	
//// CARE ////



// Create indicator of current intensity of unpaid caregiving
xtile unpaid_care_quintile = ercac if ercac > 0, nq(5)

gen unpaid_care_intensity = .
replace unpaid_care_intensity = 1 if unpaid_care_quintile == 5
replace unpaid_care_intensity = 0.8 if unpaid_care_quintile == 4
replace unpaid_care_intensity = 0.6 if unpaid_care_quintile == 3
replace unpaid_care_intensity = 0.4 if unpaid_care_quintile == 2
replace unpaid_care_intensity = 0.2 if unpaid_care_quintile == 1
replace unpaid_care_intensity = 0 if ercac == -1

// Create indicator of having ever provided intensive unpaid care
egen ever_int_unpaid_care = rowmax(W?_intensive_unpaid_care)
	
	


// Create indicator of having unmet care needs
gen unmet_care_need = 0
replace unmet_care_need = 1 if (hehpc == 2 | hehpc == 3 | hehpc == 4) | (hehpa == 2)
replace unmet_care_need = . if hehpc < -1 | hehpa < -1
	
	
	
//// LIVING ARRANGEMENTS ////



// Create indicatpr of living alone
gen lives_alone = .
replace lives_alone = 1 if h4hhres == 1
replace lives_alone = 0 if h4hhres > 1



//// RELATIONSHIPS ////



// Create indicator of being widowed
gen widowed = .
replace widowed = 1 if r4mstat == 7
replace widowed = 0 if r4mstat == 1 | r4mstat == 3 | r4mstat == 4 | r4mstat == 5 | r4mstat == 8

// Create indicator being divorced/separated
gen divorced = .
replace divorced = 1 if r4mstat == 4 | r4mstat == 5
replace divorced = 0 if r4mstat == 1 | r4mstat == 3 | r4mstat == 7 | r4mstat == 8
	
	
	
//// HOUSING ////



// Create indicator of renting
gen renting = 0
replace renting = 1 if hotenu == 3 | hotenu == 4
replace renting = . if hotenu < -1

// Create indicator of paying a mortgage
gen mortgage = 0
replace mortgage = 1 if hotenu == 2 | hotenu == 3
replace mortgage = . if hotenu < -1

// Create indicator of living in overcrowded housing
gen n_pair_children = floor(numhhkid/2)
gen n_remaining_children = numhhkid - (2*n_pair_children)
gen standard_rooms = 1 + numbus + n_pair_children + n_remaining_children

gen overcrowded = 0 if nrooms >= standard_rooms
replace overcrowded = 1 if nrooms < standard_rooms
replace overcrowded = . if numhhkid == . | numbus == .

// Create indicator of housing problems
drop hoprom86 hoprom96
mvdecode hoprom*, mv(-1=.i \ -100/-2 = .m)
egen housing_problems = rowmean(hoprom*)
replace housing_problems = 0 if hopromsp == .i


// Create indicator of whether home has no central heating
gen no_central_heating = 0
replace no_central_heating = 1 if hocenh == 2
replace no_central_heating = . if hocenh < -1

// Create indicator of having involuntarily moved home
gen invol_move = 0
replace invol_move = 1 if homove >= (iintdaty - 5) & (hormvmer == 1 | hormvmsp == 1 | hormvmof == 1 | hormvmpc == 1)
replace invol_move = . if homove < -1 | hormvmer < -1

// Use the Life History Module data to create an indicator of whether the respondent has ever been homeless
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_life_history_data.dta", keepusing(idauniq ralis8)
drop if _merge == 2
drop _merge

gen ever_homeless = 0
replace ever_homeless = 1 if ralis8 == 1
replace ever_homeless = . if ralis8 < -1

	
	
//// GENERAL DEPRIVATION ////



// Create indicator of fuel poverty
gen fuel_poverty = 0
replace fuel_poverty = 1 if hh4cutil > (0.1 * h4itot)
replace fuel_poverty = . if hh4cutil >= . | h4itot >= .

// Create indicator of food insecurity
gen food_insecurity = 0
replace food_insecurity = 0.25 if homeal == 1 & homoft == 4
replace food_insecurity = 0.5 if homeal == 1 & homoft == 3
replace food_insecurity = 0.75 if homeal == 1 & homoft == 2
replace food_insecurity = 1 if homeal == 1 & homoft == 1
replace food_insecurity = . if homeal < -1

// Create indicator of not having enough money to cover needs
gen not_enough_money = 0
replace not_enough_money = 0.25 if exrela == 2
replace not_enough_money = 0.5 if exrela == 3
replace not_enough_money = 0.75 if exrela == 4
replace not_enough_money = 1 if exrela == 5
replace not_enough_money = . if exrela < 0



//// UNCERTAINTY AND VOLATILITY ////



// Use the calculate data on Last Recorded Income and Benefits Variables to create indicators of whether a respondent has experienced a substantial decrease in income or benefits
merge 1:1 idauniq using "..\..\Data\Processed Data\Last Recorded Income and Benefits Variables.dta"
drop if _merge == 2
drop _merge

replace W4_last_income_report = 900000 if W4_last_income_report == .t

gen income_decrease = .

if W4_last_income_report > 0 {
	
	replace income_decrease = 0 if eq_nonben_income >= (0.75*W4_last_income_report)
	replace income_decrease = 1 if eq_nonben_income < (0.75*W4_last_income_report)

}
else {
	
	replace income_decrease = 0 if eq_nonben_income >= (1.25*W4_last_income_report)
	replace income_decrease = 1 if eq_nonben_income < (1.25*W4_last_income_report)

	
}

replace income_decrease = . if eq_nonben_income >= . | W4_last_income_report >= .

// Create indicator of self-reported likelihood that respondent will not have enough money to cover needs in the future
gen not_enough_future = exrslf/100 if exrslf >= 0 & exrslf < .



//// SAVE THE DATA ////
	
keep idauniq non_home_wealth_scaled home_wealth_scaled income_scaled has_no_occ_pension has_no_personal_pension reduced_pension receiving_benefits ever_unemployed max_emp_insecurity ever_agency_worker ever_selfemployed ever_parttime ever_second_job ever_invol_job_loss ever_invol_retired ever_left_job_to_care ever_mixed_work_care ever_int_unpaid_care widowed divorced lives_alone renting mortgage overcrowded housing_problems invol_move ever_homeless no_central_heating fuel_poverty food_insecurity not_enough_money income_decrease not_enough_future

rename * =_wave_4
rename idauniq_wave_4 idauniq

save  "..\..\Data\Processed Data\ELSA Wave 4 Social Risk Variables.dta", replace



//// WAVE 5 ////


// Read in the original ELSA file
use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 5.dta", clear

rename *, lower

// Keep the relevant variables

keep idauniq w5indout indager indsex wperp wpdes iintdaty ercac hehpc hehpa hotenu hopro* homove hormvmer hormvmsp hormvmof hormvmpc hocenh homeal homoft exrela exrslf


// Merge in variables to be used from the Harmonised ELSA file
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\h_elsa_g3.dta", keepusing(idauniq h5atoth h5atotb h5itot r5issdi r5igxfr r5unemp r5jhours r5work2 h5hhres r5mstat hh5cutil raeduc_e raracem rabplace h4itot r4issdi r4igxfr r5retemp)
drop if _merge == 2
drop _merge

// Merge in variables to be used from the IFS Derived Variables files
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Wave 5.dta", keepusing(idauniq nrooms npeople numbus numhhad numhhkid spage)
drop if _merge == 2
drop _merge

// Merge in variables to be used from the Financial Derived Variables files
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Financial Wave 5.dta", keepusing(idauniq totinc_bu_s eqtotinc_bu_s beninc_bu_s bueq)
drop if _merge == 2
drop _merge
	
	

//// WEALTH DOMAIN ////


	
	
// Calculate net worth of assets excluding primary residence
gen non_home_wealth = h5atotb - h5atoth

// Calculate percetniles for net worth of assets excluding primary residence
xtile non_home_wealth_percentile = non_home_wealth, nq(100)

// Create scaled version of quintiles for net worth of assets excluding primary residence
gen non_home_wealth_scaled = ((non_home_wealth_percentile/100)*-1)+1

// Calculate percentiles for net worth of primary residence
xtile home_wealth_percentile = h5atoth, nq(100)

// Create scaled version of percentiles for net worth of primary residence
gen home_wealth_scaled = ((home_wealth_percentile/100)*-1)+1



//// INCOME AND PENSIONS DOMAIN ////



// Calculate percentiles for equivalised income excluding benefits

mvdecode totinc_bu_s, mv(-999 -998 -995)
gen nonben_income = totinc_bu_s - beninc_bu_s	
gen eq_nonben_income = nonben_income/bueq
xtile income_percentile = eq_nonben_income, nq(100)

// Create scaled version of quintiles for equivalised income
gen income_scaled = ((income_percentile/100)*-1)+1

// Calculate percentiles for non-equivalised income
mvdecode totinc_bu_s, mv(-999 -998 -995)
xtile non_equiv_income_percentiles = totinc_bu_s, nq(100)


// Calculate percentiles for non-equivalised income from the Harmonised dataset variable
xtile h_non_equiv_income_percentiles = h5itot, nq(100)

	
//  Use the Pensions Grid files to create indicators of whther respondent has occupational/private pensions and merge in those variable
preserve

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Pensions Data\ELSA Pensions Grid Wave 5.dta", clear

rename *, lower

gen occupation_pension = 0
replace occupation_pension = 1 if demppen == 1

gen personal_pension = 0
replace personal_pension = 1 if demppen == 0

collapse (max) occupation_pension personal_pension, by(idauniq)

rename occupation_pension has_occ_pension
rename personal_pension has_personal_pension

save "..\..\Data\Processed Data\ELSA Occupational and Private Pensions Wave 5", replace

restore

merge 1:1 idauniq using "..\..\Data\Processed Data\ELSA Occupational and Private Pensions Wave 5"
drop if _merge == 2

replace has_occ_pension = 0 if _merge == 1  & w5indout == 11
replace has_personal_pension = 0 if _merge == 1 & w5indout == 11

gen has_no_occ_pension = 1 if has_occ_pension == 0
replace has_no_occ_pension = 0 if has_occ_pension == 1

gen has_no_personal_pension = 1 if has_personal_pension == 0
replace has_no_personal_pension = 0 if has_personal_pension == 1

drop _merge


// Create an indicator of whether respondent retired on a reduced/no pension
merge 1:1 idauniq using "..\..\Data\Processed Data\Fed Forward Employment and Retirement Variables.dta", keepusing(idauniq W5ffwperp)
drop if _merge == 2
drop _merge


gen reduced_pension = 1 if W5ffwperp == 2 | W5ffwperp == 3
replace reduced_pension = 0 if W5ffwperp == 1 | W5ffwperp == -1
replace reduced_pension = . if W5ffwperp < -1


// Create indicator of whether respondent is receiving benefits
gen receiving_benefits = 1 if r5issdi > 0 | r5igxfr > 0
replace receiving_benefits = 0 if r5issdi == 0 & r5igxfr == 0

	

//// EMPLOYMENT AND RETIREMENT ////



forval pw = 2(1)5 {
	
	merge 1:1 idauniq using "..\..\Data\Processed Data\Employment and Caregiving Variables Wave `pw'.dta"
	drop if _merge == 2
	drop _merge
	rename (unemployed fixedterm agency_worker selfemployed parttime second_job invol_job_loss invol_retired left_job_to_care mixed_work_care intensive_unpaid_care) W`pw'_=

}

// Create indicator of ever being unemployed across all waves to date
egen ever_unemployed = rowmax(W?_unemployed)

// Create indicator of maximum employment insecurity exoerienced across all waves to date
egen max_emp_insecurity = rowmax(W?_fixedterm)

// Create indicator of ever working as agency worker across all waves to date
egen ever_agency_worker = rowmax(W?_agency_worker)

// Create indicator of ever working as self-employed across all waves to date
egen ever_selfemployed = rowmax(W?_selfemployed)

// Create indicator of ever working part-time across all waves to date
egen ever_parttime = rowmax(W?_parttime)

// Create indicator of ever working multiple jobs simultaneously across all waves to date
egen ever_second_job = rowmax(W?_second_job)

// Create indicator of ever experiencing job loss across all waves to date
egen ever_invol_job_loss = rowmax(W?_invol_job_loss)

// Create indicator of ever experiencing involuntary retirement/semi-retirement across all waves to date
egen ever_invol_retired = rowmax(W?_invol_retired)

// Create indicator of ever having to leave job to care across all waves to date
egen ever_left_job_to_care = rowmax(W?_left_job_to_care)

// Create indicator of maximum intensity of mixing work and care across all waves to date
egen ever_mixed_work_care = rowmax(W?_mixed_work_care)


// Merge in Life History data and update ever_unemployed and ever_invol_job_loss to being present if the respondent reports having experienced these during their life
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_life_history_data.dta", keepusing(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1 rwbus)
drop if _merge == 2
drop _merge

egen lifecourse_unemployed = rowmax(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1)

replace ever_unemployed = 1 if lifecourse_unemployed == 1

replace ever_invol_job_loss = 1 if rwbus == 1

	
	
//// CARE ////



// Create indicator of current intensity of unpaid caregiving
xtile unpaid_care_quintile = ercac if ercac > 0, nq(5)

gen unpaid_care_intensity = .
replace unpaid_care_intensity = 1 if unpaid_care_quintile == 5
replace unpaid_care_intensity = 0.8 if unpaid_care_quintile == 4
replace unpaid_care_intensity = 0.6 if unpaid_care_quintile == 3
replace unpaid_care_intensity = 0.4 if unpaid_care_quintile == 2
replace unpaid_care_intensity = 0.2 if unpaid_care_quintile == 1
replace unpaid_care_intensity = 0 if ercac == -1

// Create indicator of having ever provided intensive unpaid care
egen ever_int_unpaid_care = rowmax(W?_intensive_unpaid_care)
	
	


// Create indicator of having unmet care needs
gen unmet_care_need = 0
replace unmet_care_need = 1 if (hehpc == 2 | hehpc == 3 | hehpc == 4) | (hehpa == 2)
replace unmet_care_need = . if hehpc < -1 | hehpa < -1
	
	
	
//// LIVING ARRANGEMENTS ////



// Create indicatpr of living alone
gen lives_alone = .
replace lives_alone = 1 if h5hhres == 1
replace lives_alone = 0 if h5hhres > 1



//// RELATIONSHIPS ////



// Create indicator of being widowed
gen widowed = .
replace widowed = 1 if r5mstat == 7
replace widowed = 0 if r5mstat == 1 | r5mstat == 3 | r5mstat == 4 | r5mstat == 5 | r5mstat == 8

// Create indicator being divorced/separated
gen divorced = .
replace divorced = 1 if r5mstat == 4 | r5mstat == 5
replace divorced = 0 if r5mstat == 1 | r5mstat == 3 | r5mstat == 7 | r5mstat == 8
	
	
	
//// HOUSING ////



// Create indicator of renting
gen renting = 0
replace renting = 1 if hotenu == 3 | hotenu == 4
replace renting = . if hotenu < -1

// Create indicator of paying a mortgage
gen mortgage = 0
replace mortgage = 1 if hotenu == 2 | hotenu == 3
replace mortgage = . if hotenu < -1

// Create indicator of living in overcrowded housing
gen n_pair_children = floor(numhhkid/2)
gen n_remaining_children = numhhkid - (2*n_pair_children)
gen standard_rooms = 1 + numbus + n_pair_children + n_remaining_children

gen overcrowded = 0 if nrooms >= standard_rooms
replace overcrowded = 1 if nrooms < standard_rooms
replace overcrowded = . if numhhkid == . | numbus == .

// Create indicator of housing problems
drop hoprom86 hoprom96
mvdecode hoprom*, mv(-1=.i \ -100/-2 = .m)
egen housing_problems = rowmean(hoprom*)
replace housing_problems = 0 if hopromsp == .i


// Create indicator of whether home has no central heating
gen no_central_heating = 0
replace no_central_heating = 1 if hocenh == 2
replace no_central_heating = . if hocenh < -1

// Create indicator of having involuntarily moved home
gen invol_move = 0
replace invol_move = 1 if homove >= (iintdaty - 5) & (hormvmer == 1 | hormvmsp == 1 | hormvmof == 1 | hormvmpc == 1)
replace invol_move = . if homove < -1 | hormvmer < -1

// Use the Life History Module data to create an indicator of whether the respondent has ever been homeless
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_life_history_data.dta", keepusing(idauniq ralis8)
drop if _merge == 2
drop _merge

gen ever_homeless = 0
replace ever_homeless = 1 if ralis8 == 1
replace ever_homeless = . if ralis8 < -1

	
	
//// GENERAL DEPRIVATION ////



// Create indicator of fuel poverty
gen fuel_poverty = 0
replace fuel_poverty = 1 if hh5cutil > (0.1 * h5itot)
replace fuel_poverty = . if hh5cutil >= . | h5itot >= .

// Create indicator of food insecurity
gen food_insecurity = 0
replace food_insecurity = 0.25 if homeal == 1 & homoft == 4
replace food_insecurity = 0.5 if homeal == 1 & homoft == 3
replace food_insecurity = 0.75 if homeal == 1 & homoft == 2
replace food_insecurity = 1 if homeal == 1 & homoft == 1
replace food_insecurity = . if homeal < -1

// Create indicator of not having enough money to cover needs
gen not_enough_money = 0
replace not_enough_money = 0.25 if exrela == 2
replace not_enough_money = 0.5 if exrela == 3
replace not_enough_money = 0.75 if exrela == 4
replace not_enough_money = 1 if exrela == 5
replace not_enough_money = . if exrela < 0



//// UNCERTAINTY AND VOLATILITY ////



// Use the calculate data on Last Recorded Income and Benefits Variables to create indicators of whether a respondent has experienced a substantial decrease in income or benefits
merge 1:1 idauniq using "..\..\Data\Processed Data\Last Recorded Income and Benefits Variables.dta"
drop if _merge == 2
drop _merge

replace W5_last_income_report = 900000 if W5_last_income_report == .t

gen income_decrease = .

if W5_last_income_report > 0 {
	
	replace income_decrease = 0 if eq_nonben_income >= (0.75*W5_last_income_report)
	replace income_decrease = 1 if eq_nonben_income < (0.75*W5_last_income_report)

}
else {
	
	replace income_decrease = 0 if eq_nonben_income >= (1.25*W5_last_income_report)
	replace income_decrease = 1 if eq_nonben_income < (1.25*W5_last_income_report)

	
}

replace income_decrease = . if eq_nonben_income >= . | W5_last_income_report >= .

// Create indicator of self-reported likelihood that respondent will not have enough money to cover needs in the future
gen not_enough_future = exrslf/100 if exrslf >= 0 & exrslf < .



	
//// SAVE THE DATA ////
	
keep idauniq non_home_wealth_scaled home_wealth_scaled income_scaled has_no_occ_pension has_no_personal_pension reduced_pension receiving_benefits ever_unemployed max_emp_insecurity ever_agency_worker ever_selfemployed ever_parttime ever_second_job ever_invol_job_loss ever_invol_retired ever_left_job_to_care ever_mixed_work_care ever_int_unpaid_care widowed divorced lives_alone renting mortgage overcrowded housing_problems invol_move ever_homeless no_central_heating fuel_poverty food_insecurity not_enough_money income_decrease not_enough_future

rename * =_wave_5
rename idauniq_wave_5 idauniq

save  "..\..\Data\Processed Data\ELSA Wave 5 Social Risk Variables.dta", replace
