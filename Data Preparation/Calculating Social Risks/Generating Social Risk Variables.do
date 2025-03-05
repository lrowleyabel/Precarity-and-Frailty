/*

GENERATING SOCIAL RISK VARIABLES

Laurence Rowley-Abel, University of Edinburgh
lrowley@ed.ac.uk

Description: This file generates detailed social risk variables for each wave of ELSA from 2 - 9. It creates the following variables:
	- wealth_percentile : percentile of net worth of all assets measured at household level
	- income_percentile : percentile of total income measured at benefit-unit level
	- benefits : whether receiving benefits (either health-related or other types of benefits)
	- nonhealth_benefits : whether receiving non-health-related benefits
	- has_no_occ_pension : has no occupational pension
	- has_no_personal_pension : has no personal pension
	- reduced_pension : retired on a reduced pension or no pension
	- unemployed : currently unemployed
	- fixedterm : currently working on a fixed-term contract
	- agency_worker : currently employed as a non-standard worker (e.g. agency worker, freelancer etc)
	- selfemployed : currently self-employed
	- parttime : ever currently working part-time
	- second_job : currently working more than one job
	- invol_job_loss : experienced involuntary job loss since last interview
	- invol_retired : experienced involuntary retirement since last interview
	- ever_unemployed : has reported ever being unemployed either at current/previous ELSA waves or in life history module
	- max_emp_insecurity : maximum level of employment contract insecurity reported at current/previous ELSA waves
	- ever_agency_worker : ever reported being a non-standard worker (e.g. agency worker, freelancer etc) at current/previous ELSA waves
	- ever_selfemployed : ever self-employed at current/previous ELSA waves
	- ever_parttime : ever worked part-time at current/previous ELSA waves
	- ever_second_job : ever worked a second job at current/previous ELSA waves
	- ever_invol_job_loss : ever experienced innvoluntary job loss at current/previous ELSA waves or in life history module
	- ever_invol_retired : ever reported having to involuntarily retired at current/previous ELSA waves
	- unpaid_care : current amount of unapid care being provided by the respondent
	- left_job_to_care : whether left job to provide unpaid care since last interview
	- mixed_work_care : whether currently mixing paid work and unpaid caregiving
	- ever_unpaid_care : maximum amount of unpaid caregiving provided by respondent at current/previous ELSA waves
	- ever_left_job_to_care : ever reporting having to leave job to provide care at current/previous ELSA waves
	- ever_mixed_work_care : ever been mixing substantial amounts of work and unpaid caregiving at current/previous ELSA waves (per week, at least 7 hours or work and 7 hours of care and at least 35 total work+care hours)
	- widowed : whether widowed
	- divorced : whether divorced
	- lives_alone : whether living alone
	- renting : whether renting
	- mortgage : whether paying a mortgage
	- overcrowded : whether living in overcrowded housing
	- count_housing_problems : number of housing problems (e.g. damp, pests) reported 
	- housing_problems : number of housing problems (e.g. damp, pests) reported (categorised)
	- invol_move : whether had to involuntarily move home since last wave
	- ever_homeless : ever reported being homeless in life history module
	- no_central_heating : whether living without central heating
	- fuel_poverty : whether in fuel poverty (i.e. >10% of household income being spent on energy costs)
	- food_insecurity : whether household is experiencing food insecurity
	- not_enough_money : whether has enough money to cover household needs
	- not_enough_future : self-reported likelihood of not having enough money in the future to cover household needs

*/

// Clear environment
clear all

// Set maximum number of variables
set maxvar 20000

// Set working directory to current file's location (ammend as necessary)
cd "C:\Users\lrowley\OneDrive - University of Edinburgh\Published Paper GitHub Repositories\New Frailty and Social Risks\Data Preparation\Calculating Social Risks"

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
	
	
	
	//// FINANCES DOMAIN ////
	
	
	// Create percentile for net worth of total assets
	xtile wealth_percentile = h`W'atotb, nq(100)	
	
	// Calculate percentiles for equivalised income
	mvdecode totinc_bu_s, mv(-999 -998 -995)
	gen eq_income = totinc_bu_s/bueq
	xtile income_percentile = eq_income, nq(100)
	
	// Create indicator of whether respondent is receiving benefits (either health-related or other)
	gen benefits = 1 if (r`W'issdi > 0 & !missing(r`W'issdi)) | (r`W'igxfr > 0 & !missing(r`W'igxfr))
	replace benefits = 0 if r`W'issdi == 0 & r`W'igxfr == 0
	
	// Create indicator of whether respondent is receiving non-health benefits
	gen nonhealth_benefits = 1 if r`W'igxfr > 0 & !missing(r`W'igxfr)
	replace nonhealth_benefits = 0 if r`W'igxfr == 0
	
	
	
	//// PENSIONS DOMAIN ////
	
	
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
	
	
	
	
	//// EMPLOYMENT DOMAIN ////
	
	
	
	forval pw = 2(1)`W' {
		
		merge 1:1 idauniq using "..\..\Data\Processed Data\Employment and Caregiving Variables Wave `pw'.dta"
		drop if _merge == 2
		drop _merge
		rename (unemployed fixedterm agency_worker selfemployed parttime second_job invol_job_loss invol_retired left_job_to_care mixed_work_care unpaid_care) W`pw'_=

	}
	
	// Create indicator of ever being unemployed across all waves to date
	egen ever_unemployed = rowmax(W?_unemployed)
	
	// Create indicator of ever working on a fixed-term contract across all waves to date
	egen ever_fixedterm = rowmax(W?_fixedterm)
	
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
	
	// Create indicator of being unemployed currently
	rename W`W'_unemployed unemployed
	
	// Create indicator of working on a fixed-term contract currently
	rename W`W'_fixedterm fixedterm
	
	// Create indicator of working as an agecy worked currently
	rename W`W'_agency_worker agency_worker
	
	// Create indicator of working self-employed currently
	rename W`W'_selfemployed selfemployed
	
	// Create indicator of working part-time currently
	rename W`W'_parttime parttime
	
	// Create indicator of working multiple jobs currently
	rename W`W'_second_job second_job
	
	
	// Create indicator of whether experienced job loss since last interview
	rename W`W'_invol_job_loss invol_job_loss
	
	// Create indicator whether experienced involuntary retirement/semi-retirement since last interview
	rename W`W'_invol_retired invol_retired
	

	// Merge in Life History data and update ever_unemployed and ever_invol_job_loss to being present if the respondent reports having experienced these during their life
	merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_life_history_data.dta", keepusing(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1 rwbus)
	drop if _merge == 2
	drop _merge
	
	egen lifecourse_unemployed = rowmax(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1)
	
	replace ever_unemployed = 1 if lifecourse_unemployed == 1
	
	replace ever_invol_job_loss = 1 if rwbus == 1
	
	
	
	//// UNPAID CAREGIVING ////
	
	
	
	// Create maximum amount of unpaid care provided across all waves to date
	egen ever_unpaid_care = rowmax(W?_unpaid_care)
	
	// Create indicator of ever having to leave job to care across all waves to date
	egen ever_left_job_to_care = rowmax(W?_left_job_to_care)
	
	// Create indicator of maximum intensity of mixing work and care across all waves to date
	egen ever_mixed_work_care = rowmax(W?_mixed_work_care)
	
	// Create indicator of current amount of unpaid care provided
	rename W`W'_unpaid_care unpaid_care
	
	// Create indicator of whether left job to provide care since last interview
	rename W`W'_left_job_to_care left_job_to_care
	
	// Create indicator of whether currently mixing work and care
	rename W`W'_mixed_work_care mixed_work_care
	
	
	
	
	//// RELATIONSHIPS ////
	
	
	// Create indicatpr of living alone
	gen lives_alone = .
	replace lives_alone = 1 if h`W'hhres == 1
	replace lives_alone = 0 if h`W'hhres > 1
	
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
	egen count_housing_problems = rowtotal(hoprom*)
	replace count_housing_problems = 0 if hopromsp == .i
	gen housing_problems = .
	replace housing_problems = 1 if count_housing_problems == 0
	replace housing_problems = 2 if count_housing_problems >= 1 & count_housing_problems <= 2
	replace housing_problems = 3 if count_housing_problems >= 3 & count_housing_problems <= 4
	replace housing_problems = 4 if count_housing_problems >= 5 & count_housing_problems < .
	
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

	
	
	//// MATERIAL DEPRIVATION ////
	
	
	
	// Create indicator of fuel poverty
	gen fuel_poverty = 0
	replace fuel_poverty = 1 if hh`W'cutil > (0.1 * h`W'itot)
	replace fuel_poverty = . if hh`W'cutil >= . | h`W'itot >= .
	
	// Create indicator of food insecurity
	gen food_insecurity = 1 if homeal == 2
	replace food_insecurity = 2 if homeal == 1 & (homoft == 4 | homoft == 3 | homoft == 2)
	replace food_insecurity = 3 if homeal == 1 & homoft == 1
	replace food_insecurity = . if homeal < -1
	
	// Create indicator of not having enough money to cover needs
	gen not_enough_money = exrela
	replace not_enough_money = . if exrela < 1
	
	// Create indicator of self-reported likelihood that respondent will not have enough money to cover needs in the future
	gen not_enough_future = exrslf if exrslf >= 0 & exrslf < .

	
	
	
	//// SAVE THE DATA ////

	// Keep the calculated social risk variables
	keep idauniq ///
	wealth_percentile /// Finances
	income_percentile ///
	benefits ///
	nonhealth_benefits /// Pensions
	has_no_occ_pension ///
	has_no_personal_pension ///
	reduced_pension ///
	unemployed /// Employment
	invol_job_loss ///
	fixedterm ///
	agency_worker ///
	selfemployed ///
	parttime ///
	second_job ///
	invol_retired ///
	ever_unemployed ///
	ever_invol_job_loss ///
	ever_fixedterm ///
	ever_agency_worker ///
	ever_selfemployed ///
	ever_parttime ///
	ever_second_job ///
	ever_invol_retired ///
	unpaid_care /// Unpaid caregiving
	left_job_to_care ///
	mixed_work_care ///
	ever_unpaid_care ///
	ever_left_job_to_care ///
	ever_mixed_work_care ///
	lives_alone /// Relationships
	widowed ///
	divorced ///
	renting /// Housing
	mortgage ///
	count_housing_problems ///
	housing_problems ///
	overcrowded ///
	no_central_heating ///
	invol_move ///
	ever_homeless ///
	food_insecurity /// Material deprivation
	fuel_poverty ///
	not_enough_money ///
	not_enough_future
	
	// Order the variables
	order idauniq ///
	wealth_percentile /// Finances
	income_percentile ///
	benefits ///
	nonhealth_benefits /// Pensions
	has_no_occ_pension ///
	has_no_personal_pension ///
	reduced_pension ///
	unemployed /// Employment
	invol_job_loss ///
	fixedterm ///
	agency_worker ///
	selfemployed ///
	parttime ///
	second_job ///
	invol_retired ///
	ever_unemployed ///
	ever_invol_job_loss ///
	ever_fixedterm ///
	ever_agency_worker ///
	ever_selfemployed ///
	ever_parttime ///
	ever_second_job ///
	ever_invol_retired ///
	unpaid_care /// Unpaid caregiving
	left_job_to_care ///
	mixed_work_care ///
	ever_unpaid_care ///
	ever_left_job_to_care ///
	ever_mixed_work_care ///
	lives_alone /// Relationships
	widowed ///
	divorced ///
	renting /// Housing
	mortgage ///
	count_housing_problems ///
	housing_problems ///
	overcrowded ///
	no_central_heating ///
	invol_move ///
	ever_homeless ///
	food_insecurity /// Material deprivation
	fuel_poverty ///
	not_enough_money ///
	not_enough_future
	
	
	// Label the variables
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
	
	// Create value labels where necessary
	label define unpaid_care 1 "None" 2 "0 - 9 hours per week" 3 "10 - 34 hours per week" 4 "35 hours per week or more"
	label values unpaid_care unpaid_care
	label values ever_unpaid_care unpaid_care
	
	label define housing_problems 1 "None" 2 "1 - 2 problems" 3 "3 - 4 problems" 4 "5 problems or more"
	label values housing_problems housing_problems
	
	label define food_insecurity 1 "Never" 2 "At least yearly" 3 "At least monthly"
	label values food_insecurity food_insecurity
	
	label define not_enough_money 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Most of the time"
	label values not_enough_money not_enough_money
	
	// Rename the variables to show which wave they belong to
	rename * =_wave_`W'
	rename idauniq_wave_`W' idauniq
	
	// Save the dataset
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


//// FINANCES DOMAIN ////


// Create percentile for net worth of total assets
xtile wealth_percentile = h2atotb, nq(100)	

// Calculate percentiles for equivalised income
mvdecode totinc_bu_s, mv(-999 -998 -995)
gen eq_income = totinc_bu_s/bueq
xtile income_percentile = eq_income, nq(100)

// Create indicator of whether respondent is receiving benefits (either health-related or other)
gen benefits = 1 if (r2issdi > 0 & !missing(r2issdi)) | (r2igxfr > 0 & !missing(r2igxfr))
replace benefits = 0 if r2issdi == 0 & r2igxfr == 0

// Create indicator of whether respondent is receiving non-health benefits
gen nonhealth_benefits = 1 if r2igxfr > 0 & !missing(r2igxfr)
replace nonhealth_benefits = 0 if r2igxfr == 0


//// PENSIONS DOMAIN ////


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



//// EMPLOYMENT AND RETIREMENT ////


forval pw = 2(1)2 {
	
	merge 1:1 idauniq using "..\..\Data\Processed Data\Employment and Caregiving Variables Wave `pw'.dta"
	drop if _merge == 2
	drop _merge
	rename (unemployed fixedterm agency_worker selfemployed parttime second_job invol_job_loss invol_retired left_job_to_care mixed_work_care unpaid_care) W`pw'_=

}

// Create indicator of ever being unemployed across all waves to date
egen ever_unemployed = rowmax(W?_unemployed)

// Create indicator of ever working on a fixed-term contract across all waves to date
egen ever_fixedterm = rowmax(W?_fixedterm)

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

// Create indicator of being unemployed currently
rename W2_unemployed unemployed

// Create indicator of working on a fixed-term contract currently
rename W2_fixedterm fixedterm

// Create indicator of working as an agecy worked currently
rename W2_agency_worker agency_worker

// Create indicator of working self-employed currently
rename W2_selfemployed selfemployed

// Create indicator of working part-time currently
rename W2_parttime parttime

// Create indicator of working multiple jobs currently
rename W2_second_job second_job


// Create indicator of whether experienced job loss since last interview
rename W2_invol_job_loss invol_job_loss

// Create indicator whether experienced involuntary retirement/semi-retirement since last interview
rename W2_invol_retired invol_retired



// Merge in Life History data and update ever_unemployed and ever_invol_job_loss to being present if the respondent reports having experienced these during their life
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_life_history_data.dta", keepusing(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1 rwbus)
drop if _merge == 2
drop _merge

egen lifecourse_unemployed = rowmax(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1)

replace ever_unemployed = 1 if lifecourse_unemployed == 1

replace ever_invol_job_loss = 1 if rwbus == 1

	
	
//// UNPAID CAREGIVING ////



// Create maximum amount of unpaid care provided across all waves to date
egen ever_unpaid_care = rowmax(W?_unpaid_care)

// Create indicator of ever having to leave job to care across all waves to date
egen ever_left_job_to_care = rowmax(W?_left_job_to_care)

// Create indicator of maximum intensity of mixing work and care across all waves to date
egen ever_mixed_work_care = rowmax(W?_mixed_work_care)

// Create indicator of current amount of unpaid care provided
rename W2_unpaid_care unpaid_care

// Create indicator of whether left job to provide care since last interview
rename W2_left_job_to_care left_job_to_care

// Create indicator of whether currently mixing work and care
rename W2_mixed_work_care mixed_work_care




//// RELATIONSHIPS ////


// Create indicatpr of living alone
gen lives_alone = .
replace lives_alone = 1 if h2hhres == 1
replace lives_alone = 0 if h2hhres > 1

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
gen count_housing_problems = 0
foreach v of varlist hoprm1 - hoprm10 {
	forval x = 1/52 {
		replace count_housing_problems = count_housing_problems + 1 if `v' == `x'
	}
}

replace count_housing_problems = . if hoprm1 < -1

gen housing_problems = .
replace housing_problems = 1 if count_housing_problems == 0
replace housing_problems = 2 if count_housing_problems >= 1 & count_housing_problems <= 2
replace housing_problems = 3 if count_housing_problems >= 3 & count_housing_problems <= 4
replace housing_problems = 4 if count_housing_problems >= 5 & count_housing_problems < .


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



//// MATERIAL DEPRIVATION ////



// Create indicator of fuel poverty
gen fuel_poverty = 0
replace fuel_poverty = 1 if hh2cutil > (0.1 * h2itot)
replace fuel_poverty = . if hh2cutil >= . | h2itot >= .

// Create indicator of food insecurity
gen food_insecurity = 1 if homeal == 2
replace food_insecurity = 2 if homeal == 1 & (homoft == 4 | homoft == 3 | homoft == 2)
replace food_insecurity = 3 if homeal == 1 & homoft == 1
replace food_insecurity = . if homeal < -1

// Create indicator of not having enough money to cover needs
gen not_enough_money = exrela
replace not_enough_money = . if exrela < 1

// Create indicator of self-reported likelihood that respondent will not have enough money to cover needs in the future
gen not_enough_future = exrslf if exrslf >= 0 & exrslf < .


//// SAVE THE DATA ////

// Keep the calculated social risk variables
keep idauniq ///
wealth_percentile /// Finances
income_percentile ///
benefits ///
nonhealth_benefits /// Pensions
has_no_occ_pension ///
has_no_personal_pension ///
reduced_pension ///
unemployed /// Employment
invol_job_loss ///
fixedterm ///
agency_worker ///
selfemployed ///
parttime ///
second_job ///
invol_retired ///
ever_unemployed ///
ever_invol_job_loss ///
ever_fixedterm ///
ever_agency_worker ///
ever_selfemployed ///
ever_parttime ///
ever_second_job ///
ever_invol_retired ///
unpaid_care /// Unpaid caregiving
left_job_to_care ///
mixed_work_care ///
ever_unpaid_care ///
ever_left_job_to_care ///
ever_mixed_work_care ///
lives_alone /// Relationships
widowed ///
divorced ///
renting /// Housing
mortgage ///
count_housing_problems ///
housing_problems ///
overcrowded ///
no_central_heating ///
invol_move ///
ever_homeless ///
food_insecurity /// Material deprivation
fuel_poverty ///
not_enough_money ///
not_enough_future

// Order the variables
order idauniq ///
wealth_percentile /// Finances
income_percentile ///
benefits ///
nonhealth_benefits /// Pensions
has_no_occ_pension ///
has_no_personal_pension ///
reduced_pension ///
unemployed /// Employment
invol_job_loss ///
fixedterm ///
agency_worker ///
selfemployed ///
parttime ///
second_job ///
invol_retired ///
ever_unemployed ///
ever_invol_job_loss ///
ever_fixedterm ///
ever_agency_worker ///
ever_selfemployed ///
ever_parttime ///
ever_second_job ///
ever_invol_retired ///
unpaid_care /// Unpaid caregiving
left_job_to_care ///
mixed_work_care ///
ever_unpaid_care ///
ever_left_job_to_care ///
ever_mixed_work_care ///
lives_alone /// Relationships
widowed ///
divorced ///
renting /// Housing
mortgage ///
count_housing_problems ///
housing_problems ///
overcrowded ///
no_central_heating ///
invol_move ///
ever_homeless ///
food_insecurity /// Material deprivation
fuel_poverty ///
not_enough_money ///
not_enough_future


// Label the variables
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

// Create value labels where necessary
label define unpaid_care 1 "None" 2 "0 - 9 hours per week" 3 "10 - 34 hours per week" 4 "35 hours per week or more"
label values unpaid_care unpaid_care
label values ever_unpaid_care unpaid_care

label define housing_problems 1 "None" 2 "1 - 2 problems" 3 "3 - 4 problems" 4 "5 problems or more"
label values housing_problems housing_problems

label define food_insecurity 1 "Never" 2 "At least yearly" 3 "At least monthly"
label values food_insecurity food_insecurity

label define not_enough_money 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Most of the time"
label values not_enough_money not_enough_money

// Rename the variables to show which wave they belong to
rename * =_wave_2
rename idauniq_wave_2 idauniq

// Save the dataset
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
	
	

//// FINANCES DOMAIN ////


// Create percentile for net worth of total assets
xtile wealth_percentile = h3atotb, nq(100)	

// Calculate percentiles for equivalised income
mvdecode totinc_bu_s, mv(-999 -998 -995)
gen eq_income = totinc_bu_s/bueq
xtile income_percentile = eq_income, nq(100)

// Create indicator of whether respondent is receiving benefits (either health-related or other)
gen benefits = 1 if (r3issdi > 0 & !missing(r3issdi)) | (r3igxfr > 0 & !missing(r3igxfr))
replace benefits = 0 if r3issdi == 0 & r3igxfr == 0

// Create indicator of whether respondent is receiving non-health benefits
gen nonhealth_benefits = 1 if r3igxfr > 0 & !missing(r3igxfr)
replace nonhealth_benefits = 0 if r3igxfr == 0



//// PENSIONS DOMAIN ////



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

	

//// EMPLOYMENT AND RETIREMENT ////



forval pw = 2(1)3 {
	
	merge 1:1 idauniq using "..\..\Data\Processed Data\Employment and Caregiving Variables Wave `pw'.dta"
	drop if _merge == 2
	drop _merge
	rename (unemployed fixedterm agency_worker selfemployed parttime second_job invol_job_loss invol_retired left_job_to_care mixed_work_care unpaid_care) W`pw'_=

}

// Create indicator of ever being unemployed across all waves to date
egen ever_unemployed = rowmax(W?_unemployed)

// Create indicator of ever working on a fixed-term contract across all waves to date
egen ever_fixedterm = rowmax(W?_fixedterm)


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

// Create indicator of being unemployed currently
rename W3_unemployed unemployed

// Create indicator of working on a fixed-term contract currently
rename W3_fixedterm fixedterm

// Create indicator of working as an agecy worked currently
rename W3_agency_worker agency_worker

// Create indicator of working self-employed currently
rename W3_selfemployed selfemployed

// Create indicator of working part-time currently
rename W3_parttime parttime

// Create indicator of working multiple jobs currently
rename W3_second_job second_job


// Create indicator of whether experienced job loss since last interview
rename W3_invol_job_loss invol_job_loss

// Create indicator whether experienced involuntary retirement/semi-retirement since last interview
rename W3_invol_retired invol_retired


// Merge in Life History data and update ever_unemployed and ever_invol_job_loss to being present if the respondent reports having experienced these during their life
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_life_history_data.dta", keepusing(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1 rwbus)
drop if _merge == 2
drop _merge

egen lifecourse_unemployed = rowmax(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1)

replace ever_unemployed = 1 if lifecourse_unemployed == 1

replace ever_invol_job_loss = 1 if rwbus == 1

	

//// UNPAID CAREGIVING ////



// Create maximum amount of unpaid care provided across all waves to date
egen ever_unpaid_care = rowmax(W?_unpaid_care)

// Create indicator of ever having to leave job to care across all waves to date
egen ever_left_job_to_care = rowmax(W?_left_job_to_care)

// Create indicator of maximum intensity of mixing work and care across all waves to date
egen ever_mixed_work_care = rowmax(W?_mixed_work_care)

// Create indicator of current amount of unpaid care provided
rename W3_unpaid_care unpaid_care

// Create indicator of whether left job to provide care since last interview
rename W3_left_job_to_care left_job_to_care

// Create indicator of whether currently mixing work and care
rename W3_mixed_work_care mixed_work_care

	

//// RELATIONSHIPS ////


// Create indicatpr of living alone
gen lives_alone = .
replace lives_alone = 1 if h3hhres == 1
replace lives_alone = 0 if h3hhres > 1


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
egen count_housing_problems = rowtotal(hoprom*)
replace count_housing_problems = 0 if hopromsp == .i
gen housing_problems = .
replace housing_problems = 1 if count_housing_problems == 0
replace housing_problems = 2 if count_housing_problems >= 1 & count_housing_problems <= 2
replace housing_problems = 3 if count_housing_problems >= 3 & count_housing_problems <= 4
replace housing_problems = 4 if count_housing_problems >= 5 & count_housing_problems < .


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

	
	
//// MATERIAL DEPRIVATION ////



// Create indicator of fuel poverty
gen fuel_poverty = 0
replace fuel_poverty = 1 if hh3cutil > (0.1 * h3itot)
replace fuel_poverty = . if hh3cutil >= . | h3itot >= .

// Create indicator of food insecurity
gen food_insecurity = 1 if homeal == 2
replace food_insecurity = 2 if homeal == 1 & (homoft == 4 | homoft == 3 | homoft == 2)
replace food_insecurity = 3 if homeal == 1 & homoft == 1
replace food_insecurity = . if homeal < -1

// Create indicator of not having enough money to cover needs
gen not_enough_money = exrela
replace not_enough_money = . if exrela < 1


// Create indicator of self-reported likelihood that respondent will not have enough money to cover needs in the future
gen not_enough_future = exrslf if exrslf >= 0 & exrslf < .



//// SAVE THE DATA ////

// Keep the calculated social risk variables
keep idauniq ///
wealth_percentile /// Finances
income_percentile ///
benefits ///
nonhealth_benefits /// Pensions
has_no_occ_pension ///
has_no_personal_pension ///
reduced_pension ///
unemployed /// Employment
invol_job_loss ///
fixedterm ///
agency_worker ///
selfemployed ///
parttime ///
second_job ///
invol_retired ///
ever_unemployed ///
ever_invol_job_loss ///
ever_fixedterm ///
ever_agency_worker ///
ever_selfemployed ///
ever_parttime ///
ever_second_job ///
ever_invol_retired ///
unpaid_care /// Unpaid caregiving
left_job_to_care ///
mixed_work_care ///
ever_unpaid_care ///
ever_left_job_to_care ///
ever_mixed_work_care ///
lives_alone /// Relationships
widowed ///
divorced ///
renting /// Housing
mortgage ///
count_housing_problems ///
housing_problems ///
overcrowded ///
no_central_heating ///
invol_move ///
ever_homeless ///
food_insecurity /// Material deprivation
fuel_poverty ///
not_enough_money ///
not_enough_future

// Order the variables
order idauniq ///
wealth_percentile /// Finances
income_percentile ///
benefits ///
nonhealth_benefits /// Pensions
has_no_occ_pension ///
has_no_personal_pension ///
reduced_pension ///
unemployed /// Employment
invol_job_loss ///
fixedterm ///
agency_worker ///
selfemployed ///
parttime ///
second_job ///
invol_retired ///
ever_unemployed ///
ever_invol_job_loss ///
ever_fixedterm ///
ever_agency_worker ///
ever_selfemployed ///
ever_parttime ///
ever_second_job ///
ever_invol_retired ///
unpaid_care /// Unpaid caregiving
left_job_to_care ///
mixed_work_care ///
ever_unpaid_care ///
ever_left_job_to_care ///
ever_mixed_work_care ///
lives_alone /// Relationships
widowed ///
divorced ///
renting /// Housing
mortgage ///
count_housing_problems ///
housing_problems ///
overcrowded ///
no_central_heating ///
invol_move ///
ever_homeless ///
food_insecurity /// Material deprivation
fuel_poverty ///
not_enough_money ///
not_enough_future


// Label the variables
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

// Create value labels where necessary
label define unpaid_care 1 "None" 2 "0 - 9 hours per week" 3 "10 - 34 hours per week" 4 "35 hours per week or more"
label values unpaid_care unpaid_care
label values ever_unpaid_care unpaid_care

label define housing_problems 1 "None" 2 "1 - 2 problems" 3 "3 - 4 problems" 4 "5 problems or more"
label values housing_problems housing_problems

label define food_insecurity 1 "Never" 2 "At least yearly" 3 "At least monthly"
label values food_insecurity food_insecurity

label define not_enough_money 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Most of the time"
label values not_enough_money not_enough_money

// Rename the variables to show which wave they belong to
rename * =_wave_3
rename idauniq_wave_3 idauniq

// Save the dataset
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
	
	

//// FINANCES DOMAIN ////


// Create percentile for net worth of total assets
xtile wealth_percentile = h4atotb, nq(100)	

// Calculate percentiles for equivalised income
mvdecode totinc_bu_s, mv(-999 -998 -995)
gen eq_income = totinc_bu_s/bueq
xtile income_percentile = eq_income, nq(100)

// Create indicator of whether respondent is receiving benefits (either health-related or other)
gen benefits = 1 if (r4issdi > 0 & !missing(r4issdi)) | (r4igxfr > 0 & !missing(r4igxfr))
replace benefits = 0 if r4issdi == 0 & r4igxfr == 0

// Create indicator of whether respondent is receiving non-health benefits
gen nonhealth_benefits = 1 if r4igxfr > 0 & !missing(r4igxfr)
replace nonhealth_benefits = 0 if r4igxfr == 0



//// PENSIONS DOMAIN ////


	
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

	

//// EMPLOYMENT AND RETIREMENT ////



forval pw = 2(1)4 {
	
	merge 1:1 idauniq using "..\..\Data\Processed Data\Employment and Caregiving Variables Wave `pw'.dta"
	drop if _merge == 2
	drop _merge
	rename (unemployed fixedterm agency_worker selfemployed parttime second_job invol_job_loss invol_retired left_job_to_care mixed_work_care unpaid_care) W`pw'_=

}

// Create indicator of ever being unemployed across all waves to date
egen ever_unemployed = rowmax(W?_unemployed)

// Create indicator of ever working on a fixed-term contract across all waves to date
egen ever_fixedterm = rowmax(W?_fixedterm)


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

// Create indicator of being unemployed currently
rename W4_unemployed unemployed

// Create indicator of working on a fixed-term contract currently
rename W4_fixedterm fixedterm

// Create indicator of working as an agecy worked currently
rename W4_agency_worker agency_worker

// Create indicator of working self-employed currently
rename W4_selfemployed selfemployed

// Create indicator of working part-time currently
rename W4_parttime parttime

// Create indicator of working multiple jobs currently
rename W4_second_job second_job

// Create indicator of whether experienced job loss since last interview
rename W4_invol_job_loss invol_job_loss

// Create indicator whether experienced involuntary retirement/semi-retirement since last interview
rename W4_invol_retired invol_retired


// Merge in Life History data and update ever_unemployed and ever_invol_job_loss to being present if the respondent reports having experienced these during their life
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_life_history_data.dta", keepusing(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1 rwbus)
drop if _merge == 2
drop _merge

egen lifecourse_unemployed = rowmax(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1)

replace ever_unemployed = 1 if lifecourse_unemployed == 1

replace ever_invol_job_loss = 1 if rwbus == 1

	
	

//// UNPAID CAREGIVING ////



// Create maximum amount of unpaid care provided across all waves to date
egen ever_unpaid_care = rowmax(W?_unpaid_care)

// Create indicator of ever having to leave job to care across all waves to date
egen ever_left_job_to_care = rowmax(W?_left_job_to_care)

// Create indicator of maximum intensity of mixing work and care across all waves to date
egen ever_mixed_work_care = rowmax(W?_mixed_work_care)

// Create indicator of current amount of unpaid care provided
rename W4_unpaid_care unpaid_care

// Create indicator of whether left job to provide care since last interview
rename W4_left_job_to_care left_job_to_care

// Create indicator of whether currently mixing work and care
rename W4_mixed_work_care mixed_work_care




//// RELATIONSHIPS ////




// Create indicatpr of living alone
gen lives_alone = .
replace lives_alone = 1 if h4hhres == 1
replace lives_alone = 0 if h4hhres > 1

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
egen count_housing_problems = rowtotal(hoprom*)
replace count_housing_problems = 0 if hopromsp == .i
gen housing_problems = .
replace housing_problems = 1 if count_housing_problems == 0
replace housing_problems = 2 if count_housing_problems >= 1 & count_housing_problems <= 2
replace housing_problems = 3 if count_housing_problems >= 3 & count_housing_problems <= 4
replace housing_problems = 4 if count_housing_problems >= 5 & count_housing_problems < .


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

	
	
//// MATERIAL DEPRIVATION ////



// Create indicator of fuel poverty
gen fuel_poverty = 0
replace fuel_poverty = 1 if hh4cutil > (0.1 * h4itot)
replace fuel_poverty = . if hh4cutil >= . | h4itot >= .

// Create indicator of food insecurity
gen food_insecurity = 1 if homeal == 2
replace food_insecurity = 2 if homeal == 1 & (homoft == 4 | homoft == 3 | homoft == 2)
replace food_insecurity = 3 if homeal == 1 & homoft == 1
replace food_insecurity = . if homeal < -1

// Create indicator of not having enough money to cover needs
gen not_enough_money = exrela
replace not_enough_money = . if exrela < 1

// Create indicator of self-reported likelihood that respondent will not have enough money to cover needs in the future
gen not_enough_future = exrslf if exrslf >= 0 & exrslf < .





//// SAVE THE DATA ////

// Keep the calculated social risk variables
keep idauniq ///
wealth_percentile /// Finances
income_percentile ///
benefits ///
nonhealth_benefits /// Pensions
has_no_occ_pension ///
has_no_personal_pension ///
reduced_pension ///
unemployed /// Employment
invol_job_loss ///
fixedterm ///
agency_worker ///
selfemployed ///
parttime ///
second_job ///
invol_retired ///
ever_unemployed ///
ever_invol_job_loss ///
ever_fixedterm ///
ever_agency_worker ///
ever_selfemployed ///
ever_parttime ///
ever_second_job ///
ever_invol_retired ///
unpaid_care /// Unpaid caregiving
left_job_to_care ///
mixed_work_care ///
ever_unpaid_care ///
ever_left_job_to_care ///
ever_mixed_work_care ///
lives_alone /// Relationships
widowed ///
divorced ///
renting /// Housing
mortgage ///
count_housing_problems ///
housing_problems ///
overcrowded ///
no_central_heating ///
invol_move ///
ever_homeless ///
food_insecurity /// Material deprivation
fuel_poverty ///
not_enough_money ///
not_enough_future

// Order the variables
order idauniq ///
wealth_percentile /// Finances
income_percentile ///
benefits ///
nonhealth_benefits /// Pensions
has_no_occ_pension ///
has_no_personal_pension ///
reduced_pension ///
unemployed /// Employment
invol_job_loss ///
fixedterm ///
agency_worker ///
selfemployed ///
parttime ///
second_job ///
invol_retired ///
ever_unemployed ///
ever_invol_job_loss ///
ever_fixedterm ///
ever_agency_worker ///
ever_selfemployed ///
ever_parttime ///
ever_second_job ///
ever_invol_retired ///
unpaid_care /// Unpaid caregiving
left_job_to_care ///
mixed_work_care ///
ever_unpaid_care ///
ever_left_job_to_care ///
ever_mixed_work_care ///
lives_alone /// Relationships
widowed ///
divorced ///
renting /// Housing
mortgage ///
count_housing_problems ///
housing_problems ///
overcrowded ///
no_central_heating ///
invol_move ///
ever_homeless ///
food_insecurity /// Material deprivation
fuel_poverty ///
not_enough_money ///
not_enough_future


// Label the variables
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

// Create value labels where necessary
label define unpaid_care 1 "None" 2 "0 - 9 hours per week" 3 "10 - 34 hours per week" 4 "35 hours per week or more"
label values unpaid_care unpaid_care
label values ever_unpaid_care unpaid_care

label define housing_problems 1 "None" 2 "1 - 2 problems" 3 "3 - 4 problems" 4 "5 problems or more"
label values housing_problems housing_problems

label define food_insecurity 1 "Never" 2 "At least yearly" 3 "At least monthly"
label values food_insecurity food_insecurity

label define not_enough_money 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Most of the time"
label values not_enough_money not_enough_money

// Rename the variables to show which wave they belong to
rename * =_wave_4
rename idauniq_wave_4 idauniq

// Save the dataset
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
	
	

//// FINANCES DOMAIN ////


// Create percentile for net worth of total assets
xtile wealth_percentile = h5atotb, nq(100)	

// Calculate percentiles for equivalised income
mvdecode totinc_bu_s, mv(-999 -998 -995)
gen eq_income = totinc_bu_s/bueq
xtile income_percentile = eq_income, nq(100)

// Create indicator of whether respondent is receiving benefits (either health-related or other)
gen benefits = 1 if (r5issdi > 0 & !missing(r5issdi)) | (r5igxfr > 0 & !missing(r5igxfr))
replace benefits = 0 if r5issdi == 0 & r5igxfr == 0

// Create indicator of whether respondent is receiving non-health benefits
gen nonhealth_benefits = 1 if r5igxfr > 0 & !missing(r5igxfr)
replace nonhealth_benefits = 0 if r5igxfr == 0



//// PENSIONS DOMAIN ////


	
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

	

//// EMPLOYMENT AND RETIREMENT ////



forval pw = 2(1)5 {
	
	merge 1:1 idauniq using "..\..\Data\Processed Data\Employment and Caregiving Variables Wave `pw'.dta"
	drop if _merge == 2
	drop _merge
	rename (unemployed fixedterm agency_worker selfemployed parttime second_job invol_job_loss invol_retired left_job_to_care mixed_work_care unpaid_care) W`pw'_=

}

// Create indicator of ever being unemployed across all waves to date
egen ever_unemployed = rowmax(W?_unemployed)

// Create indicator of ever working on a fixed-term contract across all waves to date
egen ever_fixedterm = rowmax(W?_fixedterm)


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

// Create indicator of being unemployed currently
rename W5_unemployed unemployed

// Create indicator of working on a fixed-term contract currently
rename W5_fixedterm fixedterm

// Create indicator of working as an agecy worked currently
rename W5_agency_worker agency_worker

// Create indicator of working self-employed currently
rename W5_selfemployed selfemployed

// Create indicator of working part-time currently
rename W5_parttime parttime

// Create indicator of working multiple jobs currently
rename W5_second_job second_job


// Create indicator of whether experienced job loss since last interview
rename W5_invol_job_loss invol_job_loss

// Create indicator whether experienced involuntary retirement/semi-retirement since last interview
rename W5_invol_retired invol_retired


// Merge in Life History data and update ever_unemployed and ever_invol_job_loss to being present if the respondent reports having experienced these during their life
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_life_history_data.dta", keepusing(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1 rwbus)
drop if _merge == 2
drop _merge

egen lifecourse_unemployed = rowmax(rwstf2m rwstf2 rwstf1m rwstf1 rwst2t rwst2s rwst2r rwst2q rwst2p rwst2o rwst2n rwst2m rwst2l rwst2km rwst2k rwst2jm rwst2j rwst2im rwst2i rwst2hm rwst2h rwst2gm rwst2g rwst2fm rwst2f rwst2em rwst2e rwst2dm rwst2d rwst2cm rwst2c rwst2bm rwst2b rwst2am rwst2a rwst1t rwst1s rwst1r rwst1q rwst1p rwst1o rwst1n rwst1m rwst1l rwst1km rwst1k rwst1jm rwst1j rwst1im rwst1i rwst1hm rwst1h rwst1gm rwst1g rwst1fm rwst1f rwst1em rwst1e rwst1dm rwst1d rwst1cm rwst1c rwst1bm rwst1b rwst1am rwst1a rwsff92 rwsff91 rwsff83 rwsff82 rwsff74 rwsff73 rwsff65 rwsff64 rwsff56 rwsff55 rwsff47 rwsff46 rwsff38 rwsff37 rwsff29 rwsff28 rwsff20 rwsff2 rwsff192 rwsff191 rwsff19 rwsff182 rwsff181 rwsff172 rwsff171 rwsff162 rwsff161 rwsff152 rwsff151 rwsff142 rwsff141 rwsff132 rwsff131 rwsff122 rwsff121 rwsff112 rwsff111 rwsff11 rwsff10 rwsff1 rwnwc74 rwnwc73 rwnwc65 rwnwc64 rwnwc56 rwnwc55 rwnwc47 rwnwc46 rwnwc38 rwnwc37 rwnwc29 rwnwc28 rwnwc20 rwnwc2 rwnwc19 rwnwc11 rwnwc10 rwnwc1)

replace ever_unemployed = 1 if lifecourse_unemployed == 1

replace ever_invol_job_loss = 1 if rwbus == 1

	
	

//// UNPAID CAREGIVING ////



// Create maximum amount of unpaid care provided across all waves to date
egen ever_unpaid_care = rowmax(W?_unpaid_care)

// Create indicator of ever having to leave job to care across all waves to date
egen ever_left_job_to_care = rowmax(W?_left_job_to_care)

// Create indicator of maximum intensity of mixing work and care across all waves to date
egen ever_mixed_work_care = rowmax(W?_mixed_work_care)

// Create indicator of current amount of unpaid care provided
rename W5_unpaid_care unpaid_care

// Create indicator of whether left job to provide care since last interview
rename W5_left_job_to_care left_job_to_care

// Create indicator of whether currently mixing work and care
rename W5_mixed_work_care mixed_work_care

	
	


//// RELATIONSHIPS ////



// Create indicatpr of living alone
gen lives_alone = .
replace lives_alone = 1 if h5hhres == 1
replace lives_alone = 0 if h5hhres > 1

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
egen count_housing_problems = rowtotal(hoprom*)
replace count_housing_problems = 0 if hopromsp == .i
gen housing_problems = .
replace housing_problems = 1 if count_housing_problems == 0
replace housing_problems = 2 if count_housing_problems >= 1 & count_housing_problems <= 2
replace housing_problems = 3 if count_housing_problems >= 3 & count_housing_problems <= 4
replace housing_problems = 4 if count_housing_problems >= 5 & count_housing_problems < .


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

	
	
//// MATERIAL DEPRIVATION ////



// Create indicator of fuel poverty
gen fuel_poverty = 0
replace fuel_poverty = 1 if hh5cutil > (0.1 * h5itot)
replace fuel_poverty = . if hh5cutil >= . | h5itot >= .

// Create indicator of food insecurity
gen food_insecurity = 1 if homeal == 2
replace food_insecurity = 2 if homeal == 1 & (homoft == 4 | homoft == 3 | homoft == 2)
replace food_insecurity = 3 if homeal == 1 & homoft == 1
replace food_insecurity = . if homeal < -1

// Create indicator of not having enough money to cover needs
gen not_enough_money = exrela
replace not_enough_money = . if exrela < 1

// Create indicator of self-reported likelihood that respondent will not have enough money to cover needs in the future
gen not_enough_future = exrslf if exrslf >= 0 & exrslf < .



	


//// SAVE THE DATA ////

// Keep the calculated social risk variables
keep idauniq ///
wealth_percentile /// Finances
income_percentile ///
benefits ///
nonhealth_benefits /// Pensions
has_no_occ_pension ///
has_no_personal_pension ///
reduced_pension ///
unemployed /// Employment
invol_job_loss ///
fixedterm ///
agency_worker ///
selfemployed ///
parttime ///
second_job ///
invol_retired ///
ever_unemployed ///
ever_invol_job_loss ///
ever_fixedterm ///
ever_agency_worker ///
ever_selfemployed ///
ever_parttime ///
ever_second_job ///
ever_invol_retired ///
unpaid_care /// Unpaid caregiving
left_job_to_care ///
mixed_work_care ///
ever_unpaid_care ///
ever_left_job_to_care ///
ever_mixed_work_care ///
lives_alone /// Relationships
widowed ///
divorced ///
renting /// Housing
mortgage ///
count_housing_problems ///
housing_problems ///
overcrowded ///
no_central_heating ///
invol_move ///
ever_homeless ///
food_insecurity /// Material deprivation
fuel_poverty ///
not_enough_money ///
not_enough_future

// Order the variables
order idauniq ///
wealth_percentile /// Finances
income_percentile ///
benefits ///
nonhealth_benefits /// Pensions
has_no_occ_pension ///
has_no_personal_pension ///
reduced_pension ///
unemployed /// Employment
invol_job_loss ///
fixedterm ///
agency_worker ///
selfemployed ///
parttime ///
second_job ///
invol_retired ///
ever_unemployed ///
ever_invol_job_loss ///
ever_fixedterm ///
ever_agency_worker ///
ever_selfemployed ///
ever_parttime ///
ever_second_job ///
ever_invol_retired ///
unpaid_care /// Unpaid caregiving
left_job_to_care ///
mixed_work_care ///
ever_unpaid_care ///
ever_left_job_to_care ///
ever_mixed_work_care ///
lives_alone /// Relationships
widowed ///
divorced ///
renting /// Housing
mortgage ///
count_housing_problems ///
housing_problems ///
overcrowded ///
no_central_heating ///
invol_move ///
ever_homeless ///
food_insecurity /// Material deprivation
fuel_poverty ///
not_enough_money ///
not_enough_future


// Label the variables
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

// Create value labels where necessary
label define unpaid_care 1 "None" 2 "0 - 9 hours per week" 3 "10 - 34 hours per week" 4 "35 hours per week or more"
label values unpaid_care unpaid_care
label values ever_unpaid_care unpaid_care

label define housing_problems 1 "None" 2 "1 - 2 problems" 3 "3 - 4 problems" 4 "5 problems or more"
label values housing_problems housing_problems

label define food_insecurity 1 "Never" 2 "At least yearly" 3 "At least monthly"
label values food_insecurity food_insecurity

label define not_enough_money 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Most of the time"
label values not_enough_money not_enough_money

// Rename the variables to show which wave they belong to
rename * =_wave_5
rename idauniq_wave_5 idauniq

// Save the dataset
save  "..\..\Data\Processed Data\ELSA Wave 5 Social Risk Variables.dta", replace

