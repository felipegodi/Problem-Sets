/*******************************************************************************
*                   Semana 5: Variables Instrumentales 

*                          Universidad de San Andrés
*                              Economía Aplicada
*	    		                      2022							           
*******************************************************************************/
*      Bronstein         García Vassallo            López             Riottini
/*******************************************************************************
Este archivo sigue la siguiente estructura:

0) Configurar el entorno

*******************************************************************************/
* 0) Configurar el entorno
*==============================================================================*

global main "C:/Users/Milton/Documents/UDESA/Economía Aplicada/Problem-Sets/PS 5"
global input "$main/input"
global output "$main/output"

cd "$main"

use "$input/microcredit.dta", clear

*Transformamos los valores de la variable year

replace year = 1991 if year == 0
replace year = 1998 if year == 1

* 1) Variable "Expenditure"

gen ln_exptot = ln(exptot)

* 2) MCO

label var ln_exptot "log del expenditure"

label var dfmfd "female participation"

reg ln_exptot dfmfd

outreg2 using "$output/regs.tex", ctitle(MCO) dec(4) label  addtext(Village fixed effects, No, Household fixed effects, No, Year fixed effects, No, Village x Year fixed effects, No, Household x Year fixed effects, No, Controls, No) replace

* 3) Fixed Effects

* 3.1) Household fixed effects

xtset nh year
xtreg ln_exptot dfmfd, fe i(nh)

outreg2 using "$output/regs.tex", append ctitle(FE1) dec(4) label  addtext(Village fixed effects, No, Household fixed effects, Yes, Year fixed effects, No, Village x Year fixed effects, No, Household x Year fixed effects, No, Controls, No)

* 3.2) Year fixed effects

xtreg ln_exptot dfmfd, fe i(year)

outreg2 using "$output/regs.tex", append ctitle(FE2) dec(4) label  addtext(Village fixed effects, No, Household fixed effects, No, Year fixed effects, Yes, Village x Year fixed effects, No, Household x Year fixed effects, No, Controls, No)

* 3.3) Village fixed effects

xtreg ln_exptot dfmfd, fe i(village)

outreg2 using "$output/regs.tex", append ctitle(FE3) dec(4) label  addtext(Village fixed effects, Yes, Household fixed effects, No, Year fixed effects, No, Village x Year fixed effects, No, Household x Year fixed effects, No, Controls, No)

* 3.4) Village and household fixed effects

reghdfe ln_exptot dfmfd, absorb(village nh)

outreg2 using "$output/regs.tex", append ctitle(FE4) dec(4) label  addtext(Village fixed effects, Yes, Household fixed effects, Yes, Year fixed effects, No, Village x Year fixed effects, No, Household x Year fixed effects, No, Controls, No)

* 3.5) Household and year fixed effects

reghdfe ln_exptot dfmfd, absorb(nh year)

outreg2 using "$output/regs.tex", append ctitle(FE5) dec(4) label  addtext(Village fixed effects, No, Household fixed effects, Yes, Year fixed effects, Yes, Village x Year fixed effects, No, Household x Year fixed effects, No, Controls, No)

* 3.6) Village and year fixed effects

reghdfe ln_exptot dfmfd, absorb(village year)

outreg2 using "$output/regs.tex", append ctitle(FE6) dec(4) label  addtext(Village fixed effects, Yes, Household fixed effects, No, Year fixed effects, Yes, Village x Year fixed effects, No, Household x Year fixed effects, No, Controls, No)

* 3.7) Village x year fixed effects
gen vill_year = village*year

reghdfe ln_exptot dfmfd, absorb(vill_year)

outreg2 using "$output/regs.tex", append ctitle(FE7) dec(4) label  addtext(Village fixed effects, No, Household fixed effects, No, Year fixed effects, No, Village x Year fixed effects, Yes, Household x Year fixed effects, No, Controls, No)

* 3.8) Household x year fixed effects
gen hous_year = nh*year

capture

reghdfe ln_exptot dfmfd, absorb(hous_year)

outreg2 using "$output/regs.tex", append ctitle(FE8) dec(4) label  addtext(Village fixed effects, No, Household fixed effects, No, Year fixed effects, No, Village x Year fixed effects, No, Household x Year fixed effects, Yes, Controls, No)

* 3.9) Village x year fixed effects y household fixed effects

reghdfe ln_exptot dfmfd, absorb(vill_year nh)

outreg2 using "$output/regs.tex", append ctitle(FE9) dec(4) label  addtext(Village fixed effects, No, Household fixed effects, Yes, Year fixed effects, No, Village x Year fixed effects, Yes, Household x Year fixed effects, No, Controls, No)

*Exportar a pdf

translate "$main/programs/PS 5.do" "$output/PS 5 do-file.pdf", translator(txt2pdf) replace

