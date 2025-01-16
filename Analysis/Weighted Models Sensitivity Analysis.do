/*

HYBRID PANEL REGRESSION MODELS

Laurence Rowley-Abel, University of Edinburgh

lrowley@ed.ac.uK

This file runs a series of hybrid panel regressions that model the relationship between frailty and several social exposure measures across eight time points in ELSA.

*/


//// SET UP ////

// Set working directory
cd "C:\Users\lrowley\University of Strathclyde\SIPBS_MRC Ageing Project - General\ELSA\Analysis\ELSA Precarity and Frailty Paper Code"

// Clear environment
clear all

// Read in long-format ELSA data with frailty and social exposure measures
import delimited "C:\Users\lrowley\University of Strathclyde\SIPBS_MRC Ageing Project - General\ELSA\Data\CSV\ELSA Subset with Elastic Net Precarity Index.csv", clear

// Merge in the wealth variable
merge 1:1 idauniq wave using "../../Data/Dta/Processed Data/ELSA Frailty and Precarity Analysis Dataset.dta", keepusing(idauniq wave hatotb)
keep if _merge == 3
drop _merge

// Drop individuals under 50
drop if age < 50


// Z-transform age, wealth and precartiy
summarize age
replace age = (age-r(mean))/r(sd)

summarize hatotb
replace hatotb = (hatotb-r(mean))/r(sd)

summarize precarity
replace precarity = (precarity-r(mean))/r(sd)

// Create an age squared variable from the z-transformed age variable
drop agesqrd
gen agesqrd = age*age


// For each time varying variable, generate variables with each individual's mean value and their deviation from their person-sepcific mean at each time point

mark nonmiss
markout nonmiss frailty precarity age female

egen mprecarity = mean(precarity) if nonmiss == 1, by(idauniq)
generate dprecarity = precarity - mprecarity

egen mage = mean(age) if nonmiss == 1, by(idauniq)
generate dage = age - mage

egen magesqrd = mean(agesqrd) if nonmiss == 1, by(idauniq)
generate dagesqrd = agesqrd - magesqrd

egen mhatotb = mean(hatotb) if nonmiss == 1, by(idauniq)
generate dhatotb = hatotb - mhatotb

