/*

GENERATING CURRENT EMPLOYMENT AND CAREGIVING VARIABLES

Laurence Rowley-Abel, University of Edinburgh
lrowley@ed.ac.uk

Description: This file creates variables recording detailed information on each respondent's current employment and caregiving situation. It generates the following variables:
	- unemployed : whether currently unemployed
	- fixedterm : contract security of current employment
	- agency_worker : whether currently working as an agency worker/freelancer/self-employed/sub-contractor
	- selfemployed : whether currently self-employed
	- parttime : whether currently working part-time
	- second_job : whether currently working a second job
	- invol_job_loss : whether experienced involuntary job loss since the last interview
	- invol_retired : whether expereienced involuntary retirement since the last interview
	- left_job_to_care : whether left job to provide care since the last interivew
	- intensive_unpaid_care : whether currently providing intensive unpaid care (ie: 35+ hours per week)
	- mixed_work_care : whether currently mixing substantial amounts of work and caregiving (ie: at least 20 hours of careginving and 20 hours of employed per week)

*/

// Clear environment
clear

// Set maximum number of variables
set maxvar 20000

// Set working directory to current file's location (ammend as necessary)
cd ""

forval W = 6/9 {
	
	// Read in the original ELSA file
	use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave `W'.dta", clear
	rename *, lower
	
	// Keep the relevant variables
	keep idauniq w`W'indout indager indsex wperp wpdes wprrmrh wprrmre wprrmfi wpreamrh wpreamre wpreamfi wpactw wpowkaf wpowkif wpcjag wpcjse wpcjsc wpever wpcjob wpstj wpemp wpljomti wpljomdi wpljomcl wpljomre wpljom* wplnj wpwynmti wpwynmrh wpwynmou wpwynmre wpwynmor iintdaty wpystmti wpystmrh wpystmou wpystmre wpystmfi wpystm* ercac wphjob cahpc headl96 catno hotenu hopro* homove hormvmer hormvmsp hormvmof hormvmpc hocenh homeal homoft exrela *nssec* sclddr exrslf
	
	// Merge in variables to be used from the Harmonised ELSA file
	merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\h_elsa_g3.dta", keepusing(idauniq r`W'unemp r`W'jhours r`W'work2 r`W'retemp)
	drop if _merge == 2
	drop _merge
	
	//Create indicator of whether respondent is unemployed
	gen unemployed = .
	replace unemployed = 0 if r`W'unem == 0 | r`W'unem == .x | r`W'unem == .o
	replace unemployed = 1 if r`W'unem == 1
	
	
	// Use the fed-forward variable on non-standard employment arrangements to create an indicator of whether respondent is working as an agency worker/freelancer/self-employed/sub-contractor
	merge 1:1 idauniq using "..\..\Data\Processed Data\Fed Forward Employment and Retirement Variables.dta", keepusing(idauniq W`W'ff*)
	drop if _merge == 2
	drop _merge
	
	// Create indicator of whether respondent is working on a fixed-term contract of less than a year, a fixed-term contract of less than three years, a fixed-term contract of more than three years, or a permnanent contract
	gen fixedterm = 0
	replace fixedterm = 0 if wpcjob == 4
	replace fixedterm = 0.33 if wpcjob == 3
	replace fixedterm = 0.66 if wpcjob == 2
	replace fixedterm = 1 if wpcjob == 1
	replace fixedterm = . if wpcjob < -1 | wpcjob == .
	
	// Create indicator of working as an agency worker
	gen agency_worker = .
	replace agency_worker = 0 if W`W'ffwpcjag != . & wpdes > 0
	replace agency_worker = 1 if W`W'ffwpcjag == 1 & wpever != 1
	
	// Cretae indicator of being self-employed/freelancer/sub-contractor
	gen selfemployed = .
	replace selfemployed = 0 if wpdes != 3 & W`W'ffwpcjfr != 1 & W`W'ffwpcjsc != 1 & W`W'ffwpcjse != 1
	replace selfemployed = 1 if ((W`W'ffwpcjfr == 1 | W`W'ffwpcjsc == 1 | W`W'ffwpcjse == 1) & wpever != 1) | wpdes == 3
	
	// Create indicator of whether respondent is in work part-time
	gen parttime = .
	replace parttime = 0 if r`W'jhours >= 35 & r`W'jhours < .
	replace parttime = 0 if r`W'jhours == .w
	replace parttime = 1 if r`W'jhours < 35 & r`W'jhours > 0	
	
	// Create indicator of working multiple jobs
	gen second_job = 0 if r`W'work2 == 0
	replace second_job = 1 if r`W'work2 == 1
	replace second_job = . if r`W'work2 >= .
	
	// Create an indicator of involuntary job loss
	gen invol_job_loss = 0
	replace invol_job_loss = 1 if ((wpstj == 2 | wpemp == 2) & (wpljomcl == 1 | wpljomre == 1))
	replace invol_job_loss = 1 if wplnj == 1 & (wpwynmou == 1 | wpwynmre == 1 | wpwynmor == 1)
	replace invol_job_loss = 1  if wpystmou == 1 | wpystmre == 1 | wpystmfi == 1
	replace invol_job_loss = . if wpstj < -1 | wpemp < -1 | wpljomti < -1 | wpwynmti < -1 | wpystmti < -1
	
	// Create indicator of whether respondent is involuntarily retird/semi-retired
	gen invol_retired = 0
	replace invol_retired = 1 if  (wpdes == 1 | wpdes == 96) & (wprrmre == 1 | wprrmfi == 1 | wpreamre == 1 | wpreamfi == 1)
	replace invol_retired = . if wpdes < -1 | wprrmrh < -1
	
	// Create an indicator of leaving job to provide care
	gen left_job_to_care = 0
	replace left_job_to_care = 1 if ((wpstj == 2 | wpemp == 2) & wpljomdi == 1)
	replace left_job_to_care = 1 if wplnj == 1 & wpwynmrh == 1
	replace left_job_to_care = 1  if wpystmrh == 1
	replace left_job_to_care = 1 if  (wpdes == 1 | wpdes == 96) & (wprrmrh == 1 | wpreamrh == 1)
	replace left_job_to_care = . if wpstj < -1 | wpemp < -1 | wpljomti < -1 | wpwynmti < -1 | wpystmti < -1 | wprrmrh < -1 | wpreamrh< -1
	
	// Create indicator of of providing intense unpaid caregiving
	gen intensive_unpaid_care = .
	replace intensive_unpaid_care = 1 if ercac >= 35 & ercac < .
	replace intensive_unpaid_care = 0 if ercac == -1 | (ercac >= 0 & ercac < 35)

	// Create an indicator of mixing work and unpaid care
	gen mixed_work_care = .
	replace mixed_work_care = 1 if ercac >= 20 & ercac < . & r`W'jhours >= 20 & r`W'jhours < .
	replace mixed_work_care = 0 if (ercac > 0 & ercac < 20) | ercac == -1 | (r`W'jhours != .w & r`W'jhours < 20) | r`W'jhours == .w

	keep idauniq unemployed fixedterm agency_worker selfemployed parttime second_job invol_job_loss invol_retired left_job_to_care intensive_unpaid_care mixed_work_care

	save "..\..\\Data\Processed Data\Employment and Caregiving Variables Wave `W'.dta", replace
	
}



//// WAVE 2 ////


// Read in the original ELSA file
use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 2.dta", clear

rename *, lower


// Keep the relevant variables
keep idauniq w2indout indager indsex wperp wpdes wprrem* wpream* wpcjb* wpever wpactw wpstj wpcjob wpemp wpljob* wplnj wpwhyn* wpystm* ercac wphjob hehpc hehpa hotenu hoprm* homove hormvm* hocenh homeal homoft exrela exrslf


// Merge in variables to be used from the Harmonised ELSA file
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\h_elsa_g3.dta", keepusing(idauniq r2unemp r2jhours r2work2 r2retemp)
drop if _merge == 2
drop _merge


//Create indicator of whether respondent is unemployed
gen unemployed = .
replace unemployed = 0 if r2unem == 0 | r2unem == .x | r2unem == .o
replace unemployed = 1 if r2unem == 1


// Use the fed-forward variable on non-standard employment arrangements to create an indicator of whether respondent is working as an agency worker/freelancer/self-employed/sub-contractor
merge 1:1 idauniq using "..\..\Data\Processed Data\Fed Forward Employment and Retirement Variables.dta", keepusing(idauniq W2ff*)
drop if _merge == 2
drop _merge

// Create indicator of whether respondent is working on a fixed-term contract of less than a year, a fixed-term contract of less than three years, a fixed-term contract of more than three years, or a permnanent contract
gen fixedterm = 0
replace fixedterm = 0 if wpcjob == 4
replace fixedterm = 0.33 if wpcjob == 3
replace fixedterm = 0.66 if wpcjob == 2
replace fixedterm = 1 if wpcjob == 1
replace fixedterm = . if wpcjob < -1 | wpcjob == .


// Create indicator of working as an agency worker
gen agency_worker = .
replace agency_worker = 0 if W2ffwpcjag != . & wpdes > 0
replace agency_worker = 1 if W2ffwpcjag == 1 & wpever != 1

// Cretae indicator of being self-employed/freelancer/sub-contractor
gen selfemployed = .
replace selfemployed = 0 if wpdes != 3 & W2ffwpcjfr != 1 & W2ffwpcjsc != 1 & W2ffwpcjse != 1
replace selfemployed = 1 if ((W2ffwpcjfr == 1 | W2ffwpcjsc == 1 | W2ffwpcjse == 1) & wpever != 1) | wpdes == 3

// Create indicator of whether respondent is in work part-time
gen parttime = .
replace parttime = 0 if r2jhours >= 35 & r2jhours < .
replace parttime = 0 if r2jhours == .w
replace parttime = 1 if r2jhours < 35 & r2jhours > 0	

// Create indicator of working multiple jobs
gen second_job = 0 if r2work2 == 0
replace second_job = 1 if r2work2 == 1
replace second_job = . if r2work2 >= .

// Create an indicator of involuntary job loss
gen invol_job_loss = 0

foreach v of varlist wpljob1-wpljob5 {
	foreach x in 4 5 {
		replace invol_job_loss = 1 if (wpstj == 2 | wpemp == 2) & (`v' == `x')
	}
	
}

foreach v of varlist wpwhyn1-wpwhyn6 {
	foreach x in 4 5 {
		replace invol_job_loss = 1 if (wplnj == 1) & (`v' == `x')
	}

}

foreach v of varlist wpystm1-wpystm5 {
	foreach x in 4 5 7 {
		replace invol_job_loss = 1 if `v' == `x'
	}

}

replace invol_job_loss = . if wpstj < -1 | wpemp < -1 | wpljob1 < -1 | wpwhyn1 < -1 | wpystm1 < -1


// Create indicator of whether respondent is involuntarily retird/semi-retired
gen invol_retired = 0

foreach v of varlist wprrem1-wprrem5 wpream1-wpream6 {
	foreach x in 4 5 {
		replace invol_retired = 1 if (wpdes == 1 | wpdes == 96) & (`v' == `x')
	}

}
replace invol_retired = . if wpdes < -1 | wprrem1 < -1 | wpream1 < -1


// Create indicator of leaving job to provide care
gen left_job_to_care = 0

foreach v of varlist wpljob1-wpljob5 {
	replace left_job_to_care = 1 if (wpstj == 2 | wpemp == 2) & (`v' == 3)
}

foreach v of varlist wpwhyn1-wpwhyn6 {
	replace left_job_to_care = 1 if (wplnj == 1) & (`v' == 3)
}

foreach v of varlist wpystm1-wpystm5 {
	replace left_job_to_care = 1 if `v' == 3
}

replace left_job_to_care = . if wpstj < -1 | wpemp < -1 | wpljob1 < -1 | wpwhyn1 < -1 | wpystm1 < -1


// Create indicator of of providing intense unpaid caregiving
gen intensive_unpaid_care = .
replace intensive_unpaid_care = 1 if ercac >= 35 & ercac < .
replace intensive_unpaid_care = 0 if ercac == -1 | (ercac >= 0 & ercac < 35)

// Create an indicator of mixing work and unpaid care
gen mixed_work_care = .
replace mixed_work_care = 1 if ercac >= 20 & ercac < . & r2jhours >= 20 & r2jhours < .
replace mixed_work_care = 0 if (ercac > 0 & ercac < 20) | ercac == -1 | (r2jhours != .w & r2jhours < 20) | r2jhours == .w


keep idauniq unemployed fixedterm agency_worker selfemployed parttime second_job invol_job_loss invol_retired left_job_to_care intensive_unpaid_care mixed_work_care
	

	
save "..\..\\Data\Processed Data\Employment and Caregiving Variables Wave 2.dta", replace
	
	

//// WAVE 3 ////



// Read in the original ELSA file
use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 3.dta", clear

rename *, lower


// Keep the relevant variables
keep idauniq w3indout indager indsex wperp wpdes wprrmrh wprrmre wprrmfi wpreamrh wpreamre wpreamfi wpactw wpever wpcjob wpstj wpemp wpljomti wpljomdi wpljomcl wpljomre wpljom* wplnj wpwynmti wpwynmrh wpwynmou wpwynmre wpwynmor iintdaty wpystmti wpystmrh wpystmou wpystmre wpystmfi wpystm* ercac wphjob
	

// Merge in variables to be used from the Harmonised ELSA file
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\h_elsa_g3.dta", keepusing(idauniq r3unemp r3jhours r3work2 r3retemp)
drop if _merge == 2
drop _merge


//Create indicator of whether respondent is unemployed
gen unemployed = .
replace unemployed = 0 if r3unem == 0 | r3unem == .x | r3unem == .o
replace unemployed = 1 if r3unem == 1


// Use the fed-forward variable on non-standard employment arrangements to create an indicator of whether respondent is working as an agency worker/freelancer/self-employed/sub-contractor
merge 1:1 idauniq using "..\..\Data\Processed Data\Fed Forward Employment and Retirement Variables.dta", keepusing(idauniq W3ff*)
drop if _merge == 2
drop _merge

// Create indicator of whether respondent is working on a fixed-term contract of less than a year, a fixed-term contract of less than three years, a fixed-term contract of more than three years, or a permnanent contract
gen fixedterm = 0
replace fixedterm = 0 if wpcjob == 4
replace fixedterm = 0.33 if wpcjob == 3
replace fixedterm = 0.66 if wpcjob == 2
replace fixedterm = 1 if wpcjob == 1
replace fixedterm = . if wpcjob < -1 | wpcjob == .


// Create indicator of working as an agency worker
gen agency_worker = .
replace agency_worker = 0 if W3ffwpcjag != . & wpdes > 0
replace agency_worker = 1 if W3ffwpcjag == 1 & wpever != 1

// Cretae indicator of being self-employed/freelancer/sub-contractor
gen selfemployed = .
replace selfemployed = 0 if wpdes != 3 & W3ffwpcjfr != 1 & W3ffwpcjsc != 1 & W3ffwpcjse != 1
replace selfemployed = 1 if ((W3ffwpcjfr == 1 | W3ffwpcjsc == 1 | W3ffwpcjse == 1) & wpever != 1) | wpdes == 3

// Create indicator of whether respondent is in work part-time
gen parttime = .
replace parttime = 0 if r3jhours >= 35 & r3jhours < .
replace parttime = 0 if r3jhours == .w
replace parttime = 1 if r3jhours < 35 & r3jhours > 0	

// Create indicator of working multiple jobs
gen second_job = 0 if r3work2 == 0
replace second_job = 1 if r3work2 == 1
replace second_job = . if r3work2 >= .

// Create an indicator of involuntary job loss
gen invol_job_loss = 0
replace invol_job_loss = 1 if ((wpstj == 2 | wpemp == 2) & (wpljomcl == 1 | wpljomre == 1))
replace invol_job_loss = 1 if wplnj == 1 & (wpwynmou == 1 | wpwynmre == 1 | wpwynmor == 1)
replace invol_job_loss = 1  if wpystmou == 1 | wpystmre == 1 | wpystmfi == 1
replace invol_job_loss = . if wpstj < -1 | wpemp < -1 | wpljomti < -1 | wpwynmti < -1 | wpystmti < -1

// Create indicator of whether respondent is involuntarily retird/semi-retired
gen invol_retired = 0
replace invol_retired = 1 if  (wpdes == 1 | wpdes == 96) & (wprrmre == 1 | wprrmfi == 1 | wpreamre == 1 | wpreamfi == 1)
replace invol_retired = . if wpdes < -1 | wprrmrh < -1

// Create an indicator of leaving job to provide care
gen left_job_to_care = 0
replace left_job_to_care = 1 if ((wpstj == 2 | wpemp == 2) & wpljomdi == 1)
replace left_job_to_care = 1 if wplnj == 1 & wpwynmrh == 1
replace left_job_to_care = 1  if wpystmrh == 1
replace left_job_to_care = 1 if  (wpdes == 1 | wpdes == 96) & (wprrmrh == 1 | wpreamrh == 1)
replace left_job_to_care = . if wpstj < -1 | wpemp < -1 | wpljomti < -1 | wpwynmti < -1 | wpystmti < -1 | wprrmrh < -1 | wpreamrh< -1


//// Create indicator of of providing intense unpaid caregiving
gen intensive_unpaid_care = .
replace intensive_unpaid_care = 1 if ercac >= 35 & ercac < .
replace intensive_unpaid_care = 0 if ercac == -1 | (ercac >= 0 & ercac < 35)

// Create an indicator of mixing work and unpaid care
gen mixed_work_care = .
replace mixed_work_care = 1 if ercac >= 20 & ercac < . & r3jhours >= 20 & r3jhours < .
replace mixed_work_care = 0 if (ercac > 0 & ercac < 20) | ercac == -1 | (r3jhours != .w & r3jhours < 20) | r3jhours == .w


keep idauniq unemployed fixedterm agency_worker selfemployed parttime second_job invol_job_loss invol_retired left_job_to_care intensive_unpaid_care mixed_work_care
	

save "..\..\\Data\Processed Data\Employment and Caregiving Variables Wave 3.dta", replace


//// WAVE 4 ////



// Read in the original ELSA file
use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 4.dta", clear

rename *, lower


// Keep the relevant variables
keep idauniq outindw4 indager indsex wperp wpdes wprrmrh wprrmre wprrmfi wpreamrh wpreamre wpreamfi wpactw wpever wpcjob wpstj wpemp wpljomti wpljomdi wpljomcl wpljomre wpljom* wplnj wpwynti wpwynrh wpwynou wpwynre iintdaty wpystmti wpystmrh wpystmou wpystmre wpystmfi wpystm* ercac wphjob
	

// Merge in variables to be used from the Harmonised ELSA file
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\h_elsa_g3.dta", keepusing(idauniq r4unemp r4jhours r4work2 r4retemp)
drop if _merge == 2
drop _merge


//Create indicator of whether respondent is unemployed
gen unemployed = .
replace unemployed = 0 if r4unem == 0 | r4unem == .x | r4unem == .o
replace unemployed = 1 if r4unem == 1


// Use the fed-forward variable on non-standard employment arrangements to create an indicator of whether respondent is working as an agency worker/freelancer/self-employed/sub-contractor
merge 1:1 idauniq using "..\..\Data\Processed Data\Fed Forward Employment and Retirement Variables.dta", keepusing(idauniq W4ff*)
drop if _merge == 2
drop _merge

// Create indicator of whether respondent is working on a fixed-term contract of less than a year, a fixed-term contract of less than three years, a fixed-term contract of more than three years, or a permnanent contract
gen fixedterm = 0
replace fixedterm = 0 if wpcjob == 4
replace fixedterm = 0.33 if wpcjob == 3
replace fixedterm = 0.66 if wpcjob == 2
replace fixedterm = 1 if wpcjob == 1
replace fixedterm = . if wpcjob < -1 | wpcjob == .


// Create indicator of working as an agency worker
gen agency_worker = .
replace agency_worker = 0 if W4ffwpcjag != . & wpdes > 0
replace agency_worker = 1 if W4ffwpcjag == 1 & wpever != 1

// Cretae indicator of being self-employed/freelancer/sub-contractor
gen selfemployed = .
replace selfemployed = 0 if wpdes != 3 & W4ffwpcjfr != 1 & W4ffwpcjsc != 1 & W4ffwpcjse != 1
replace selfemployed = 1 if ((W4ffwpcjfr == 1 | W4ffwpcjsc == 1 | W4ffwpcjse == 1) & wpever != 1) | wpdes == 3

// Create indicator of whether respondent is in work part-time
gen parttime = .
replace parttime = 0 if r4jhours >= 35 & r4jhours < .
replace parttime = 0 if r4jhours == .w
replace parttime = 1 if r4jhours < 35 & r4jhours > 0	

// Create indicator of working multiple jobs
gen second_job = 0 if r4work2 == 0
replace second_job = 1 if r4work2 == 1
replace second_job = . if r4work2 >= .

// Create an indicator of involuntary job loss
gen invol_job_loss = 0
replace invol_job_loss = 1 if ((wpstj == 2 | wpemp == 2) & (wpljomcl == 1 | wpljomre == 1))
replace invol_job_loss = 1 if wplnj == 1 & (wpwynou == 1 | wpwynre == 1)
replace invol_job_loss = 1  if wpystmou == 1 | wpystmre == 1 | wpystmfi == 1
replace invol_job_loss = . if wpstj < -1 | wpemp < -1 | wpljomti < -1 | wpwynti < -1 | wpystmti < -1

// Create indicator of whether respondent is involuntarily retird/semi-retired
gen invol_retired = 0
replace invol_retired = 1 if  (wpdes == 1 | wpdes == 96) & (wprrmre == 1 | wprrmfi == 1 | wpreamre == 1 | wpreamfi == 1)
replace invol_retired = . if wpdes < -1 | wprrmrh < -1

// Create an indicator of leaving job to provide care
gen left_job_to_care = 0
replace left_job_to_care = 1 if ((wpstj == 2 | wpemp == 2) & wpljomdi == 1)
replace left_job_to_care = 1 if wplnj == 1 & wpwynrh == 1
replace left_job_to_care = 1  if wpystmrh == 1
replace left_job_to_care = 1 if  (wpdes == 1 | wpdes == 96) & (wprrmrh == 1 | wpreamrh == 1)
replace left_job_to_care = . if wpstj < -1 | wpemp < -1 | wpljomti < -1 | wpwynti < -1 | wpystmti < -1 | wprrmrh < -1 | wpreamrh< -1

// Create indicator of of providing intense unpaid caregiving
gen intensive_unpaid_care = .
replace intensive_unpaid_care = 1 if ercac >= 35 & ercac < .
replace intensive_unpaid_care = 0 if ercac == -1 | (ercac >= 0 & ercac < 35)

// Create an indicator of mixing work and unpaid care
gen mixed_work_care = .
replace mixed_work_care = 1 if ercac >= 20 & ercac < . & r4jhours >= 20 & r4jhours < .
replace mixed_work_care = 0 if (ercac > 0 & ercac < 20) | ercac == -1 | (r4jhours != .w & r4jhours < 20) | r4jhours == .w


keep idauniq unemployed fixedterm agency_worker selfemployed parttime second_job invol_job_loss invol_retired left_job_to_care intensive_unpaid_care mixed_work_care
	
	
save "..\..\\Data\Processed Data\Employment and Caregiving Variables Wave 4.dta", replace




//// WAVE 5 ////



// Read in the original ELSA file
use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 5.dta", clear

rename *, lower


// Keep the relevant variables
keep idauniq w5indout indager indsex wperp wpdes wprrmrh wprrmre wprrmfi wpreamrh wpreamre wpreamfi wpactw wpever wpcjob wpstj wpemp wpljomti wpljomdi wpljomcl wpljomre wpljom* wplnj wpwynti wpwynrh wpwynou wpwynre iintdaty wpystmti wpystmrh wpystmou wpystmre wpystmfi wpystm* ercac wphjob
	

// Merge in variables to be used from the Harmonised ELSA file
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\h_elsa_g3.dta", keepusing(idauniq r5unemp r5jhours r5work2 r5retemp)
drop if _merge == 2
drop _merge


//Create indicator of whether respondent is unemployed
gen unemployed = .
replace unemployed = 0 if r5unem == 0 | r5unem == .x | r5unem == .o
replace unemployed = 1 if r5unem == 1


// Use the fed-forward variable on non-standard employment arrangements to create an indicator of whether respondent is working as an agency worker/freelancer/self-employed/sub-contractor
merge 1:1 idauniq using "..\..\Data\Processed Data\Fed Forward Employment and Retirement Variables.dta", keepusing(idauniq W5ff*)
drop if _merge == 2
drop _merge

// Create indicator of whether respondent is working on a fixed-term contract of less than a year, a fixed-term contract of less than three years, a fixed-term contract of more than three years, or a permnanent contract
gen fixedterm = 0
replace fixedterm = 0 if wpcjob == 4
replace fixedterm = 0.33 if wpcjob == 3
replace fixedterm = 0.66 if wpcjob == 2
replace fixedterm = 1 if wpcjob == 1
replace fixedterm = . if wpcjob < -1 | wpcjob == .


// Create indicator of working as an agency worker
gen agency_worker = .
replace agency_worker = 0 if W5ffwpcjag != . & wpdes > 0
replace agency_worker = 1 if W5ffwpcjag == 1 & wpever != 1

// Cretae indicator of being self-employed/freelancer/sub-contractor
gen selfemployed = .
replace selfemployed = 0 if wpdes != 3 & W5ffwpcjfr != 1 & W5ffwpcjsc != 1 & W5ffwpcjse != 1
replace selfemployed = 1 if ((W5ffwpcjfr == 1 | W5ffwpcjsc == 1 | W5ffwpcjse == 1) & wpever != 1) | wpdes == 3

// Create indicator of whether respondent is in work part-time
gen parttime = .
replace parttime = 0 if r5jhours >= 35 & r5jhours < .
replace parttime = 0 if r5jhours == .w
replace parttime = 1 if r5jhours < 35 & r5jhours > 0	

// Create indicator of working multiple jobs
gen second_job = 0 if r5work2 == 0
replace second_job = 1 if r5work2 == 1
replace second_job = . if r5work2 >= .

// Create an indicator of involuntary job loss
gen invol_job_loss = 0
replace invol_job_loss = 1 if ((wpstj == 2 | wpemp == 2) & (wpljomcl == 1 | wpljomre == 1))
replace invol_job_loss = 1 if wplnj == 1 & (wpwynou == 1 | wpwynre == 1)
replace invol_job_loss = 1  if wpystmou == 1 | wpystmre == 1 | wpystmfi == 1
replace invol_job_loss = . if wpstj < -1 | wpemp < -1 | wpljomti < -1 | wpwynti < -1 | wpystmti < -1

// Create indicator of whether respondent is involuntarily retird/semi-retired
gen invol_retired = 0
replace invol_retired = 1 if  (wpdes == 1 | wpdes == 96) & (wprrmre == 1 | wprrmfi == 1 | wpreamre == 1 | wpreamfi == 1)
replace invol_retired = . if wpdes < -1 | wprrmrh < -1

// Create an indicator of leaving job to provide care
gen left_job_to_care = 0
replace left_job_to_care = 1 if ((wpstj == 2 | wpemp == 2) & wpljomdi == 1)
replace left_job_to_care = 1 if wplnj == 1 & wpwynrh == 1
replace left_job_to_care = 1  if wpystmrh == 1
replace left_job_to_care = 1 if  (wpdes == 1 | wpdes == 96) & (wprrmrh == 1 | wpreamrh == 1)
replace left_job_to_care = . if wpstj < -1 | wpemp < -1 | wpljomti < -1 | wpwynti < -1 | wpystmti < -1 | wprrmrh < -1 | wpreamrh< -1

// Create indicator of of providing intense unpaid caregiving
gen intensive_unpaid_care = .
replace intensive_unpaid_care = 1 if ercac >= 35 & ercac < .
replace intensive_unpaid_care = 0 if ercac == -1 | (ercac >= 0 & ercac < 35)

// Create an indicator of mixing work and unpaid care
gen mixed_work_care = .
replace mixed_work_care = 1 if ercac >= 20 & ercac < . & r5jhours >= 20 & r5jhours < .
replace mixed_work_care = 0 if (ercac > 0 & ercac < 20) | ercac == -1 | (r5jhours != .w & r5jhours < 20) | r5jhours == .w


keep idauniq unemployed fixedterm agency_worker selfemployed parttime second_job invol_job_loss invol_retired left_job_to_care intensive_unpaid_care mixed_work_care
	
save "..\..\\Data\Processed Data\Employment and Caregiving Variables Wave 5.dta", replace

