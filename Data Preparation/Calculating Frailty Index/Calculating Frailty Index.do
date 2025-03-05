/*


CALCULATING FRAILTY INDEX

Laurence Rowley-Abel, University of Edinburgh
lrowley@ed.ac.uk

Description: This file creates a deficit-based Frailty Index in the English Longitudinal Study of Ageing (ELSA). It uses the harmonised version of ELSA provided by the Gateway to Global Aging Data (g2aging.org/hrd/overview), which is available in the data files provided when dowloading the standard ELSA data (Study Number 5050) from the UK Data Service. The data is in wide-format.
The Frailty Index builds on a previous index established in ELSA by Marshall et al. 2015 (doi.org/10.1136/jech-2014-204655) and follows the standard procedure set out by Searle et al. 2008 (doi.org/10.1186/1471-2318-8-24).


*/

// Clear the environment
clear all

// Set maximum number of variables
set maxvar 20000

// Set the working directory to current file's location (ammend as necessary)
cd "C:\Users\lrowley\OneDrive - University of Edinburgh\Published Paper GitHub Repositories\New Frailty and Social Risks\Data Preparation\Calculating Frailty Index"

// Read in the Harmonised ELSA Dataset
use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\h_elsa_g3.dta", clear

// Loop through the Waves

forval W = 1/9 {
    
    // Step 1: Recode deficits that are not already coded as 0 = good outcome, 1 = bad outcome
    
            // Reverse the orientation variables

            recode r`W'dy (0 = 1) (1 = 0)
            recode r`W'mo (0 = 1) (1 = 0)
            recode r`W'yr (0 = 1) (1 = 0)
            recode r`W'dw (0 = 1) (1 = 0)

            // Reverse the positive psychological variables

            recode r`W'whappy (0 = 1) (1 = 0)
            recode r`W'enlife (0 = 1) (1 = 0)

            // Scale the self-rated health variable to between 0 and 1 (note that Wave 3 uses a different variable with slightly different response options)
			
			if `W' != 3 {
				gen r`W'shlt_scaled = .
				replace r`W'shlt_scaled = 0 if r`W'shlt == 1
				replace r`W'shlt_scaled = 0.25 if r`W'shlt == 2
				replace r`W'shlt_scaled = 0.5 if r`W'shlt == 3
				replace r`W'shlt_scaled = 0.75 if r`W'shlt == 4
				replace r`W'shlt_scaled = 1 if r`W'shlt == 5
			}
			else {
				gen r`W'shlt_scaled = .
				replace r`W'shlt_scaled = 0 if r`W'shlta == 1
				replace r`W'shlt_scaled = 0.25 if r`W'shlta == 2
				replace r`W'shlt_scaled = 0.5 if r`W'shlta == 3
				replace r`W'shlt_scaled = 0.75 if r`W'shlta == 4
				replace r`W'shlt_scaled = 1 if r`W'shlta == 5
			}
            

            // Scale the self-rated sight variable to between 0 and 1

            gen r`W'sight_scaled = .
            replace r`W'sight_scaled = 0 if r`W'sight == 1
            replace r`W'sight_scaled = 0.2 if r`W'sight == 2
            replace r`W'sight_scaled = 0.4 if r`W'sight == 3
            replace r`W'sight_scaled = 0.6 if r`W'sight == 4
            replace r`W'sight_scaled = 0.8 if r`W'sight == 5
            replace r`W'sight_scaled = 1 if r`W'sight == 6

            // Scale the self-rated hearing variable to between 0 and 1

            gen r`W'hearing_scaled = .
            replace r`W'hearing_scaled = 0 if r`W'hearing == 1
            replace r`W'hearing_scaled = 0.25 if r`W'hearing == 2
            replace r`W'hearing_scaled = 0.5 if r`W'hearing == 3
            replace r`W'hearing_scaled = 0.75 if r`W'hearing == 4
            replace r`W'hearing_scaled = 1 if r`W'hearing == 5

            // Calculate quintiles for the cognitive test scores and scale to between 0 and 1
            
            xtile r`W'imrc_quintile = r`W'imrc, nquantile(5)
            xtile r`W'dlrc_quintile = r`W'dlrc, nquantile(5)
    
            gen r`W'imrc_quintile_scaled = .
            replace r`W'imrc_quintile_scaled = 1 if r`W'imrc_quintile == 1
            replace r`W'imrc_quintile_scaled = 0.75 if r`W'imrc_quintile == 2
            replace r`W'imrc_quintile_scaled = 0.5 if r`W'imrc_quintile == 3
            replace r`W'imrc_quintile_scaled = 0.25 if r`W'imrc_quintile == 4
            replace r`W'imrc_quintile_scaled = 0 if r`W'imrc_quintile == 5
    
    
            gen r`W'dlrc_quintile_scaled = .
            replace r`W'dlrc_quintile_scaled = 1 if r`W'dlrc_quintile == 1
            replace r`W'dlrc_quintile_scaled = 0.75 if r`W'dlrc_quintile == 2
            replace r`W'dlrc_quintile_scaled = 0.5 if r`W'dlrc_quintile == 3
            replace r`W'dlrc_quintile_scaled = 0.25 if r`W'dlrc_quintile == 4
            replace r`W'dlrc_quintile_scaled = 0 if r`W'dlrc_quintile == 5
    
    // Step 2: Calculate the proportion of deficits that are present
    
            // Calculate number of deficits with non-missing data for each respondent
            
            egen denominator_wave_`W' = rownonmiss(r`W'walk100a ///
                                          r`W'sita ///
                                          r`W'chaira ///
                                          r`W'climsa ///
                                          r`W'clim1a ///
                                          r`W'stoopa ///
                                          r`W'armsa ///
                                          r`W'pusha ///
                                          r`W'lifta ///
                                          r`W'dimea ///
                                          r`W'dy ///
                                          r`W'mo ///
                                          r`W'yr ///
                                          r`W'dw ///
                                          r`W'imrc_quintile_scaled ///
                                          r`W'dlrc_quintile_scaled ///
                                          r`W'dressa ///
                                          r`W'walkra ///
                                          r`W'batha ///
                                          r`W'eata ///
                                          r`W'beda ///
                                          r`W'toilta ///
                                          r`W'mapa ///
                                          r`W'mealsa ///
                                          r`W'shopa ///
                                          r`W'phonea ///
                                          r`W'medsa ///
                                          r`W'housewka ///
                                          r`W'moneya ///
                                          r`W'hibpe ///
                                          r`W'angine ///
                                          r`W'hrtatte ///
                                          r`W'conhrtfe ///
                                          r`W'hrtrhme ///
                                          r`W'diabe ///
                                          r`W'stroke ///
                                          r`W'lunge ///
                                          r`W'asthmae ///
                                          r`W'arthre ///
                                          r`W'osteoe ///
                                          r`W'cancre ///
                                          r`W'parkine ///
                                          r`W'psyche ///
                                          r`W'alzhe ///
                                          r`W'demene ///
                                          r`W'depres ///
                                          r`W'effort ///
                                          r`W'sleepr ///
                                          r`W'whappy ///
                                          r`W'flone ///
                                          r`W'enlife ///
                                          r`W'fsad ///
                                          r`W'going ///
                                          r`W'shlt_scaled ///
                                          r`W'sight_scaled ///
                                          r`W'hearing_scaled)
    
    egen frailty_index_wave_`W' = rowmean(r`W'walk100a ///
                                          r`W'sita ///
                                          r`W'chaira ///
                                          r`W'climsa ///
                                          r`W'clim1a ///
                                          r`W'stoopa ///
                                          r`W'armsa ///
                                          r`W'pusha ///
                                          r`W'lifta ///
                                          r`W'dimea ///
                                          r`W'dy ///
                                          r`W'mo ///
                                          r`W'yr ///
                                          r`W'dw ///
                                          r`W'imrc_quintile_scaled ///
                                          r`W'dlrc_quintile_scaled ///
                                          r`W'dressa ///
                                          r`W'walkra ///
                                          r`W'batha ///
                                          r`W'eata ///
                                          r`W'beda ///
                                          r`W'toilta ///
                                          r`W'mapa ///
                                          r`W'mealsa ///
                                          r`W'shopa ///
                                          r`W'phonea ///
                                          r`W'medsa ///
                                          r`W'housewka ///
                                          r`W'moneya ///
                                          r`W'hibpe ///
                                          r`W'angine ///
                                          r`W'hrtatte ///
                                          r`W'conhrtfe ///
                                          r`W'hrtrhme ///
                                          r`W'diabe ///
                                          r`W'stroke ///
                                          r`W'lunge ///
                                          r`W'asthmae ///
                                          r`W'arthre ///
                                          r`W'osteoe ///
                                          r`W'cancre ///
                                          r`W'parkine ///
                                          r`W'psyche ///
                                          r`W'alzhe ///
                                          r`W'demene ///
                                          r`W'depres ///
                                          r`W'effort ///
                                          r`W'sleepr ///
                                          r`W'whappy ///
                                          r`W'flone ///
                                          r`W'enlife ///
                                          r`W'fsad ///
                                          r`W'going ///
                                          r`W'shlt_scaled ///
                                          r`W'sight_scaled ///
                                          r`W'hearing_scaled) ///
                                          if denominator_wave_`W' >= 30
}

// Loop through the waves and check the number of missing values for each deficit

forval W = 1/9 {

	di "MISSING VALUES FOR WAVE `W'"
	
	mdesc r`W'walk100a ///
		  r`W'sita ///
		  r`W'chaira ///
		  r`W'climsa ///
		  r`W'clim1a ///
		  r`W'stoopa ///
		  r`W'armsa ///
		  r`W'pusha ///
		  r`W'lifta ///
		  r`W'dimea ///
		  r`W'dy ///
		  r`W'mo ///
		  r`W'yr ///
		  r`W'dw ///
		  r`W'imrc_quintile_scaled ///
		  r`W'dlrc_quintile_scaled ///
		  r`W'dressa ///
		  r`W'walkra ///
		  r`W'batha ///
		  r`W'eata ///
		  r`W'beda ///
		  r`W'toilta ///
		  r`W'mapa ///
		  r`W'mealsa ///
		  r`W'shopa ///
		  r`W'phonea ///
		  r`W'medsa ///
		  r`W'housewka ///
		  r`W'moneya ///
		  r`W'hibpe ///
		  r`W'angine ///
		  r`W'hrtatte ///
		  r`W'conhrtfe ///
		  r`W'hrtrhme ///
		  r`W'diabe ///
		  r`W'stroke ///
		  r`W'lunge ///
		  r`W'asthmae ///
		  r`W'arthre ///
		  r`W'osteoe ///
		  r`W'cancre ///
		  r`W'parkine ///
		  r`W'psyche ///
		  r`W'alzhe ///
		  r`W'demene ///
		  r`W'depres ///
		  r`W'effort ///
		  r`W'sleepr ///
		  r`W'whappy ///
		  r`W'flone ///
		  r`W'enlife ///
		  r`W'fsad ///
		  r`W'going ///
		  r`W'shlt_scaled ///
		  r`W'sight_scaled ///
		  r`W'hearing_scaled if inw`W' == 1

}



// Recode/calculate/tidy up some common socio-demographic variables

forval W = 1/9 {

    rename r`W'agey age_w`W'
    rename r`W'mstath marstat_w`W'
    
    
    gen age_group_w`W' = 1 if age_w`W' >= 50 & age_w`W' < 55
    replace age_group_w`W' = 2 if age_w`W' >= 55 & age_w`W' < 60
    replace age_group_w`W' = 3 if age_w`W' >= 60 & age_w`W' < 65
    replace age_group_w`W' = 4 if age_w`W' >= 65 & age_w`W' < 70
    replace age_group_w`W' = 5 if age_w`W' >= 70 & age_w`W' < 75
    replace age_group_w`W' = 6 if age_w`W' >= 75 & age_w`W' < 80
    replace age_group_w`W' = 7 if age_w`W' >= 80 & age_w`W' < 85
    replace age_group_w`W' = 8 if age_w`W' >= 85 & age_w`W' < 90
    replace age_group_w`W' = 9 if age_w`W' >= 90 & age_w`W' < 95
    
    label define age_groups 1 "50-54" 2 "55-59" 3 "60-64" 4 "65-69" 5 "70-74" 6 "75-79" 7 "80-84" 8 "85-89" 9 "90+", replace
    label values age_group_w`W' age_groups
    
}

rename ragender gender
rename raracem race
rename raeducl education
rename rabplace pob


// Keep the ID variable, the calculated Frailty Index, the common socio-demographic variables and the longitudinal weights for Wave 9
keep idauniq ///
     frailty_index_wave_* ///
     gender age_w* age_group_w* race h*itot h*atotb education pob marstat* ///
     r9lwtresp

order idauniq ///
	  frailty_index_wave_* ///
      gender age_w* age_group_w* race h*itot h*atotb education pob marstat* ///
      r9lwtresp
	 
// Save the dataset
save "..\..\Data\Processed Data\Harmonised ELSA Dataset with Frailty Index.dta", replace