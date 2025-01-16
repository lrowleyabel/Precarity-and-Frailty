/*

FILE SETUP

Laurence Rowley-Abel, University of Edinburgh
lrowley@ed.ac.uk

Description: This file saves copies of some of the ELSA data files so that they have consistent naming across waves. This makes them easier to work with when looping code across waves.

*/

// Clear environment
clear

// Set maximum number of variables
set maxvar 20000

// Set working directory to current file's location (ammend as necessary)
cd ""

// Make a directory to hold the main data

mkdir "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data"

// Save copies of the main interview dta files in the new directory with a standardised name format

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_1_core_data_v3.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 1 Data.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_2_core_data_v4.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 2 Data.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_elsa_data_v4.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 3 Data.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_4_elsa_data_v3.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 4 Data.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_5_elsa_data_v4.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 5 Data.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_6_elsa_data_v2.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 6 Data.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_7_elsa_data.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 7 Data.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_8_elsa_data_eul_v2.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 8 Data.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_9_elsa_data_eul_v1.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Main Data\ELSA Wave 9 Data.dta"

// Make a directory to hold the IFS derived variables data and the IFS financial variables data

mkdir "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data"

// Save copies of the IFS derived variables dta files in the new directory with a standardised name format

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_1_ifs_derived_variables.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Wave 1.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_2_ifs_derived_variables.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Wave 2.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_ifs_derived_variables.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Wave 3.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_4_ifs_derived_variables.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Wave 4.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_5_ifs_derived_variables.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Wave 5.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_6_ifs_derived_variables.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Wave 6.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_7_ifs_derived_variables.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Wave 7.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_8_elsa_ifs_dvs_eul_v1.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Wave 8.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_9_ifs_derived_variables.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Wave 9.dta"

// Save copies of the IFS financial variables dta files in the new directory with a standardised name format

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_1_financial_derived_variables.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Finaicial Wave 1.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_2_financial_derived_variables.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Finaicial Wave 2.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_financial_derived_variables.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Finaicial Wave 3.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_4_financial_derived_variables.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Finaicial Wave 4.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_5_financial_derived_variables.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Finaicial Wave 5.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_6_financial_derived_variables.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Finaicial Wave 6.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_7_financial_derived_variables.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Finaicial Wave 7.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_8_elsa_financial_dvs_eul_v1.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Finaicial Wave 8.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_9_financial_derived_variables.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\IFS Data\ELSA IFS Finaicial Wave 9.dta"

// Make directory to hold the pensions data

mkdir "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Pensions Data"

// Save copies of the pensions grid dta files in the new directory with a standardised name format

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_1_pension_grid.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Pensions Data\ELSA Pensions Grid Wave 1.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_2_pension_grid_v3.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Pensions Data\ELSA Pensions Grid Wave 2.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_3_pensiongrid_v4.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Pensions Data\ELSA Pensions Grid Wave 3.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_4_pension_grid_v1.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Pensions Data\ELSA Pensions Grid Wave 4.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_5_pension_grid_v3.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Pensions Data\ELSA Pensions Grid Wave 5.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_6_pensiongrid_archive_v1.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Pensions Data\ELSA Pensions Grid Wave 6.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_7_pensiongrid_archive_v2_final.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Pensions Data\ELSA Pensions Grid Wave 7.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_8_elsa_pensiongrid_eul_v1.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Pensions Data\ELSA Pensions Grid Wave 8.dta"

use "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\wave_9_elsa_pensiongrid_eul_v2.dta", clear
save "..\..\Data\Raw Data\UKDA-5050-stata\stata\stata13_se\Pensions Data\ELSA Pensions Grid Wave 9.dta"
