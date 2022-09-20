/*******************************************************************************
                           Semana 6: Efectos fijos 

                          Universidad de San Andrés
                              Economía Aplicada
							       2022							           
*******************************************************************************/

* 0) Set up environment
*==============================================================================*
clear all

global main "G:\Mi unidad\Clases\Tutoriales Aplicada 2022\Clases\6. Efectos fijos\Replication folder"
global output "$main/output"
global input "$main/input"

use "$input/microcredit.dta", clear
replace year = 1991 if year==0
replace year = 1998 if year==1
xtset nh year // set panel
*==============================================================================*


* 1) Baseline specification
*==============================================================================*
gen l_exptot = log(exptot)
label var l_exptot "Log Expenditure"
label var dfmfd "Female participation"
reg l_exptot dfmfd
outreg2 using "$output/base_spec.rtf", dec(3) label  addtext(Village fixed effects, No, Household fixed effects, No, Year fixed effects, No, Controls, No) replace
*==============================================================================*

* 2) Village fixed effects
*==============================================================================*
* 1:
reg l_exptot dfmfd i.village
* 2: 
xtreg l_exptot dfmfd, fe i(village) 
* 3:
areg l_exptot dfmfd, absorb(village) 
* 4:
ssc install reghdfe
reghdfe l_exptot dfmfd, absorb(village) 
*==============================================================================*

* 3) Village and year fixed effects
*==============================================================================*
reghdfe l_exptot dfmfd, absorb(village year) 
*==============================================================================*

* 4) Village x year fixed effects
*==============================================================================*
gen village_year = village*year
reghdfe l_exptot dfmfd, absorb(village_year) 
*==============================================================================*