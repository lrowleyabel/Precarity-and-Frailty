/*

GENERATING LAST RECORDED INCOME AND BENEFIT VARIABLES

Laurence Rowley-Abel, University of Edinburgh
lrowley@ed.ac.uk

Description: This file creates variables for each wave indicating respondents' total household income (excl. benefits) and income from benefits at their previous interview. This is so we can compare current and previous income and identify substantial drops in income.

*/

// Clear environment
clear

// Set maximum number of variables
set maxvar 20000

// Set working directory to current file's location (ammend as necessary)
cd "C:\Users\lrowley\OneDrive - University of Edinburgh\Published Paper GitHub Repositories\New Frailty and Social Risks\Data Preparation\Calculating Social Risks"



// Read in Harmonised ELSA dataset
use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\h_elsa_g3.dta", clear

// For waves 1 to 9, read in the IFS Finicial data and calculate the income equivalised to household size
forval W = 1/9 {
	
	merge 1:1 idauniq using "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Financial Wave `W'.dta", keepusing(idauniq totinc_bu_s beninc_bu_s bueq)
	drop if _merge == 2
	drop _merge
	
	mvdecode totinc_bu_s beninc_bu_s, mv(-999 -998 -995)
	
	gen income_w`W' = totinc_bu_s
	
	gen eq_income_w`W' = income_w`W' / bueq

	drop totinc_bu_s beninc_bu_s bueq
}


// For waves 2 to 9, create a variable indicating the last recorded non-missing income variable
forval W = 2/9 {
	
	gen W`W'_last_income_report = .
	
	forval x = 1/`W' {
		
		local pw = `W' - `x'
		
		if `pw' > 0 {
				replace W`W'_last_income_report = eq_income_w`pw' if W`W'_last_income_report >= .
	
		}
			
	}
	
	
}

// For waves 2 to 9, create a variable indicating the last recorded non-missing benefit income (benefit income is the sum of rWissdi [dissability benefits and social assistance pension] and rWigxfr [other government transfers] from the Harmonised data)
forval W = 2/9 {
	
	di `W'
	
	gen W`W'_last_benefits_report = .
	
	forval x = 1/`W' {
		
		local pw = `W' - `x'
		
		if `pw' > 0 {
				replace W`W'_last_benefits_report = r`pw'issdi + r`pw'igxfr if W`W'_last_benefits_report >= .
	
		}
			
	}
	
	
}

// Keep relevant variables
keep idauniq W*last*

save "..\..\Data\Processed Data\Last Recorded Income and Benefits Variables.dta", replace