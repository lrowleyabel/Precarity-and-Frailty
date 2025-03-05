/*

GENERATING FED-FORWARD EMPLOYMENT AND RETIREMENT VARIABLES

Laurence Rowley-Abel, University of Edinburgh
lrowley@ed.ac.uk

Description: This file creates variables that feed forward extra details of the last recorded employment/retirement situation of each respondent. This is necessary since detailed information on individuals' employment/retirment situation is not asked at a given wave if they haven't changed their employment/retirment situation since their previous interview. The fed-forward variables created here show us the latest value recorded for the following items:
	- wpcjb : type of non-employee work (asked if self-employed or if employed but not paid a salary directly by an employer), such as agency worker, freelancer etc.
	- wperp : whether retired on reduced pension


*/

// Clear environment
clear

// Set maximum number of variables
set maxvar 20000

// Set working directory to current file's location (ammend as necessary)
cd "C:\Users\lrowley\OneDrive - University of Edinburgh\Published Paper GitHub Repositories\New Frailty and Social Risks\Data Preparation\Calculating Social Risks"

// Read in Wave 1 data
use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 1.dta", clear

// Keep relevant variables
keep  idauniq /// id variable
	wpdes /// self-report of current activity status
	wpactw /// derived activity status
	wpes /// whether employed or self-employed
	wpsal /// whether paid a salary by an employer
	wpcjb* /// type of non-employee work (asked if self-employed or if employed but not paid a salary directly by an employer)
	wperp // whether retired on reduced pension

// In Waves 1 and 2, the wpcjb variables are recorded differently to subsequent waves. In Waves 1 and 2, wpcjb1 contains a number referring to the first mentioned job type, wpcjb2 refers to the second mentioned job type etc. In subsequent
// waves, there are a series of dummy-encoded variables for each job type, which indicate whether it was mentioned or not.

// Here we recode the Wave 1 variables to be in the same format as the later waves
gen wpcjag = -1
replace wpcjag = 0 if wpcjb1 != -1
replace wpcjag = 1 if wpcjb1 == 1 | wpcjb2 == 1 | wpcjb3 == 1 | wpcjb4 == 1

gen wpcjdi = -1
replace wpcjdi = 0 if wpcjb1 != -1
replace wpcjdi = 1 if wpcjb1 == 2 | wpcjb2 == 2 | wpcjb3 == 2 | wpcjb4 == 2

gen wpcjbu = -1
replace wpcjbu = 0 if wpcjb1 != -1
replace wpcjbu = 1 if wpcjb1 == 3 | wpcjb2 == 3 | wpcjb3 == 3 | wpcjb4 == 3

gen wpcjpa = -1
replace wpcjbu = 0 if wpcjb1 != -1
replace wpcjpa = 1 if wpcjb1 == 4 | wpcjb2 == 4 | wpcjb3 == 4 | wpcjb4 == 4

gen wpcjse = -1
replace wpcjse = 0 if wpcjb1 != -1
replace wpcjse = 1 if wpcjb1 == 5 | wpcjb2 == 5 | wpcjb3 == 5 | wpcjb4 == 5

gen wpcjsc = -1
replace wpcjsc = 0 if wpcjb1 != -1
replace wpcjsc = 1 if wpcjb1 == 6 | wpcjb2 == 6 | wpcjb3 == 6 | wpcjb4 == 6

gen wpcjfr = -1
replace wpcjfr = 0 if wpcjb1 != -1
replace wpcjfr = 1 if wpcjb1 == 7 | wpcjb2 == 7 | wpcjb3 == 7 | wpcjb4 == 7

gen wpcj96 = -1
replace wpcj96 = 0 if wpcjb1 != -1
replace wpcj96 = 1 if wpcjb1 == 96 | wpcjb2 == 96 | wpcjb3 == 96 | wpcjb4 == 96

// Drop the old variables
drop wpcjb1 wpcjb2 wpcjb3 wpcjb4

// Rename these variables to indicate they are Wave 1 variables
rename w* W1=


// Merge in the relevant Wave 2 job variables
merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 2.dta", keepusing(idauniq /// id variable
	wpdes /// self-report of current activity status
	wpactw /// derived activity status
	wpsal /// 
	wpes ///
	wpcjb* /// type of non-employee work (asked if self-employed or if employed but not paid a salary directly by an employer)
	wpstj /// whether  in same job as before
	wpemp /// whether working for sample employer as before
	wperp) // whether retired on reduced pension

// Recode the wpcjb variables to be in the same format as subsequent waves
gen wpcjag = -1
replace wpcjag = . if _merge == 1
replace wpcjag = 0 if wpcjb1 != -1 & _merge != 1
replace wpcjag = 1 if wpcjb1 == 1 | wpcjb2 == 1 | wpcjb3 == 1 | wpcjb4 == 1

gen wpcjdi = -1
replace wpcjdi = . if _merge == 1
replace wpcjdi = 0 if wpcjb1 != -1 & _merge != 1
replace wpcjdi = 1 if wpcjb1 == 2 | wpcjb2 == 2 | wpcjb3 == 2 | wpcjb4 == 2

gen wpcjbu = -1
replace wpcjbu = . if _merge == 1
replace wpcjbu = 0 if wpcjb1 != -1 & _merge != 1
replace wpcjbu = 1 if wpcjb1 == 3 | wpcjb2 == 3 | wpcjb3 == 3 | wpcjb4 == 3

gen wpcjpa = -1
replace wpcjpa = . if _merge == 1
replace wpcjbu = 0 if wpcjb1 != -1 & _merge != 1
replace wpcjpa = 1 if wpcjb1 == 4 | wpcjb2 == 4 | wpcjb3 == 4 | wpcjb4 == 4

gen wpcjse = -1
replace wpcjse = . if _merge == 1
replace wpcjse = 0 if wpcjb1 != -1 & _merge != 1
replace wpcjse = 1 if wpcjb1 == 5 | wpcjb2 == 5 | wpcjb3 == 5 | wpcjb4 == 5

gen wpcjsc = -1
replace wpcjsc = . if _merge == 1
replace wpcjsc = 0 if wpcjb1 != -1 & _merge != 1
replace wpcjsc = 1 if wpcjb1 == 6 | wpcjb2 == 6 | wpcjb3 == 6 | wpcjb4 == 6

gen wpcjfr = -1
replace wpcjfr = . if _merge == 1
replace wpcjfr = 0 if wpcjb1 != -1 & _merge != 1
replace wpcjfr = 1 if wpcjb1 == 7 | wpcjb2 == 7 | wpcjb3 == 7 | wpcjb4 == 7

gen wpcj96 = -1
replace wpcj96 = . if _merge == 1
replace wpcj96 = 0 if wpcjb1 != -1 & _merge != 1
replace wpcj96 = 1 if wpcjb1 == 96 | wpcjb2 == 96 | wpcjb3 == 96 | wpcjb4 == 96

// Drop old variables
drop wpcjb1 wpcjb2 wpcjb3 wpcjb4

// For Wave 2, create a fed-forward version of each job variable, which takes the Wave 2 value if it is a valid value, or takes the Wave 1 value if the Wave 2 value is marked as not applicable because they have not changed job since Wave 1
gen W2ffwpcjag = wpcjag
replace W2ffwpcjag = W1wpcjag if wpcjag == -1 & (W1wpactw == 1 | W1wpactw == 2) & (wpactw == 1 | wpactw == 2) & wpstj == 1 & wpemp != 2

gen W2ffwpcjdi = wpcjdi
replace W2ffwpcjdi = W1wpcjdi if wpcjdi == -1 & (W1wpactw == 1 | W1wpactw == 2) & (wpactw == 1 | wpactw == 2) & wpstj == 1 & wpemp != 2

gen W2ffwpcjbu = wpcjbu
replace W2ffwpcjbu = W1wpcjbu if wpcjbu == -1 & (W1wpactw == 1 | W1wpactw == 2) & (wpactw == 1 | wpactw == 2) & wpstj == 1 & wpemp != 2

gen W2ffwpcjpa = wpcjpa
replace W2ffwpcjpa = W1wpcjpa if wpcjpa == -1 & (W1wpactw == 1 | W1wpactw == 2) & (wpactw == 1 | wpactw == 2) & wpstj == 1 & wpemp != 2

gen W2ffwpcjse = wpcjse
replace W2ffwpcjse = W1wpcjse if wpcjse == -1 & (W1wpactw == 1 | W1wpactw == 2) & (wpactw == 1 | wpactw == 2) & wpstj == 1 & wpemp != 2

gen W2ffwpcjsc = wpcjsc
replace W2ffwpcjsc = W1wpcjsc if wpcjsc == 1 & (W1wpactw == 1 | W1wpactw == 2) & (wpactw == 1 | wpactw == 2) & wpstj == 1 & wpemp != 2

gen W2ffwpcjfr = wpcjfr
replace W2ffwpcjfr = W1wpcjfr if wpcjfr == -1 & (W1wpactw == 1 | W1wpactw == 2) & (wpactw == 1 | wpactw == 2) & wpstj == 1 & wpemp != 2

gen W2ffwpcj96 = wpcj96
replace W2ffwpcj96 = W1wpcj96 if wpcj96 == -1 & (W1wpactw == 1 | W1wpactw == 2) & (wpactw == 1 | wpactw == 2) & wpstj == 1 & wpemp != 2

rename wpactw W2wpactw

gen W2ffwperp = wperp
replace W2ffwperp = W1wperp if (W1wperp >= -1 & W1wperp < .) & (wperp <= -1 | wperp >= .) 

// Keep the relevant variables
keep idauniq W1wpcj* W1wperp W2ffwp* *wpactw

// For Waves 3 to 9, merge in the job variables for that wave and create a fed-forward version of each based on the previous waves
forval cw = 3/9 {

	merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave `cw'.dta", keepusing(idauniq /// id variable
		wpdes /// self-report of current activity status
		wpactw /// derived activity status
		wpsal /// 
		wpes ///
		wpcjag wpcjdi wpcjbu wpcjpa wpcjse wpcjsc wpcjfr wpcj96 /// type of non-employee work (asked if self-employed or if employed but not paid a salary directly by an employer)
		wpstj /// whether  in same job as before
		wpemp /// whether working for sample employer as before
		wperp) // whether retired on reduced pension 
		
	
	foreach suf in ag di bu pa se sc fr 96 {
				
		gen lastffwpcj`suf' = .

		forval x = 1/`cw' {

			local pw = `cw'-`x'
			if `pw' > 1 {
				replace lastffwpcj`suf' = W`pw'ffwpcj`suf' if lastffwpcj`suf' == .
			}
			if `pw' == 1 {
				replace lastffwpcj`suf' = W1wpcj`suf' if lastffwpcj`suf' == .
			}
			
		}
		
	}


	gen lastwpactw = .

	forval x = 1/`cw' {

		local pw = `cw'-`x'

		if `pw' > 1 {
			replace lastwpact = W`pw'wpactw if lastwpact == .
		}
		if `pw' == 1 {
			replace lastwpactw = W1wpact if lastwpactw == .
		}

	}
	
	gen lastffwperp = .

	forval x = 1/`cw' {

		local pw = `cw'-`x'
		if `pw' > 1 {
			replace lastffwperp = W`pw'ffwperp if lastffwperp == .
		}
		if `pw' == 1 {
			replace lastffwperp = W1wperp if lastffwperp == .
		}
		
	}



	gen W`cw'ffwpcjag = wpcjag
	replace W`cw'ffwpcjag = lastffwpcjag if wpcjag == -1 & (lastwpactw == 1 | lastwpactw == 2) & (wpactw == 1 | wpactw == 2) & wpstj == 1 & wpemp != 2

	gen W`cw'ffwpcjdi = wpcjdi
	replace W`cw'ffwpcjdi = lastffwpcjdi if wpcjdi == -1 & (lastwpactw == 1 | lastwpactw == 2) & (wpactw == 1 | wpactw == 2) & wpstj == 1 & wpemp != 2

	gen W`cw'ffwpcjbu = wpcjbu
	replace W`cw'ffwpcjbu = lastffwpcjbu if wpcjbu == -1 & (lastwpactw == 1 | lastwpactw == 2) & (wpactw == 1 | wpactw == 2) & wpstj == 1 & wpemp != 2

	gen W`cw'ffwpcjpa = wpcjpa
	replace W`cw'ffwpcjpa = lastffwpcjpa if wpcjpa == -1 & (lastwpactw == 1 | lastwpactw == 2) & (wpactw == 1 | wpactw == 2) & wpstj == 1 & wpemp != 2

	gen W`cw'ffwpcjse = wpcjse
	replace W`cw'ffwpcjse = lastffwpcjse if wpcjse == -1 & (lastwpactw == 1 | lastwpactw == 2) & (wpactw == 1 | wpactw == 2) & wpstj == 1 & wpemp != 2

	gen W`cw'ffwpcjsc = wpcjsc
	replace W`cw'ffwpcjsc = lastffwpcjsc if wpcjsc == 1 & (lastwpactw == 1 | lastwpactw == 2) & (wpactw == 1 | wpactw == 2) & wpstj == 1 & wpemp != 2

	gen W`cw'ffwpcjfr = wpcjfr
	replace W`cw'ffwpcjfr = lastffwpcjfr if wpcjfr == -1 & (lastwpactw == 1 | lastwpactw == 2) & (wpactw == 1 | wpactw == 2) & wpstj == 1 & wpemp != 2

	gen W`cw'ffwpcj96 = wpcj96
	replace W`cw'ffwpcj96 = lastffwpcj96 if wpcj96 == -1 & (lastwpactw == 1 | lastwpactw == 2) & (wpactw == 1 | wpactw == 2) & wpstj == 1 & wpemp != 2
	
	gen W`cw'ffwperp = wperp
	replace W`cw'ffwperp = lastffwperp if wperp == -1 & !missing(lastffwperp)

	
	
	tab wpcjag W`cw'ffwpcjag

	rename wpactw W`cw'wpactw

	keep idauniq W1wpcj* W1wperp *ffwp* *wpactw

	drop last*

}

// Keep the relevant variables
keep idauniq *wpcj* *ffwperp

// Save the data
save "..\..\Data\Processed Data\Fed Forward Employment and Retirement Variables.dta", replace