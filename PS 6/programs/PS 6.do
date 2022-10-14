/*******************************************************************************
*                     Semana 6: Difference in Difference

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

global main "C:/Users/Milton/Documents/UDESA/Economía Aplicada/Problem-Sets/PS 6"
global input "$main/input"
global output "$main/output"

cd "$main"

use "$input/castle.dta", clear

* net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
set scheme cleanplots
* ssc install bacondecomp

* define global macros
global crime1 jhcitizen_c jhpolice_c murder homicide robbery assault burglary larceny motor robbery_gun_r 
global demo blackm_15_24 whitem_15_24 blackm_25_44 whitem_25_44 //demographics
global lintrend trend_1-trend_51 //state linear trend
global region r20001-r20104  //region-quarter fixed effects
global exocrime l_larceny l_motor // exogenous crime rates
global spending l_exp_subsidy l_exp_pubwelfare
global xvar l_police unemployrt poverty l_income l_prisoner l_lagprisoner $demo $spending
*gen region=1 if northeast==1
*replace region=2 if midwest==1
*replace region=3 if south==1
*replace region=4 if west==1
label var post "Castle Doctrine Law"
label var l_burglary "Log(Burglary Rate)"
label var l_assault "Log(Aggravated Assault Rate)"
label var l_robbery "Log(Robbery Rate)"
label var pre2_cdl "0 to 2 years before adoption of castle doctrine law"
********************************************************************************
* Ejercicio 1
* PANEL A

eststo clear
* 1

* Solo state y year fixed effects
eststo: xtreg l_burglary post i.year [aweight=popwt], fe vce(cluster sid)

* 2

* Le agrego region por año
eststo: xtreg l_burglary post i.year $region [aweight=popwt], fe vce(cluster sid)

* 3

* Controles variables en el tiempo
eststo: xtreg l_burglary post i.year $region $xvar [aweight=popwt], fe vce(cluster sid)

* 4 

* Le agrego un control por 2 años previos
eststo: xtreg l_burglary post pre2_cdl i.year $region $xvar [aweight=popwt], fe vce(cluster sid)

* 5 

* Agrego las variables de crimen contemporáneas
eststo: xtreg l_burglary post i.year $exocrime $region $xvar [aweight=popwt], fe vce(cluster sid)

* 6 

* Variables lineales en el tiempo de los estados
eststo: xtreg l_burglary post i.year $lintrend $region $xvar [aweight=popwt], fe vce(cluster sid)

* 7 

eststo: xtreg l_burglary post i.year, fe vce(cluster sid)

* 8 

* Le agrego region por año
eststo: xtreg l_burglary post i.year $region, fe vce(cluster sid)

* 9 

* Controles variables en el tiempo
eststo: xtreg l_burglary post i.year $region $xvar, fe vce(cluster sid)

* 10 

* Le agrego un control por 2 años previos
eststo: xtreg l_burglary post pre2_cdl i.year $region $xvar, fe vce(cluster sid)

* 11 

* Agrego las variables de crimen contemporáneas
eststo: xtreg l_burglary post i.year $exocrime $region $xvar, fe vce(cluster sid)

* 12 

* Variables lineales en el tiempo de los estados
eststo: xtreg l_burglary post i.year $lintrend $region $xvar, fe vce(cluster sid)

esttab using "$output/Tabla4_A.tex", se replace label noobs noabbrev ///
keep(post pre2_cdl, relax) cells(b(fmt(4) star) se(par fmt(4)))
********************************************************************************
* PANEL B

eststo clear
* 1

* Solo state y year fixed effects
eststo: xtreg l_robbery post i.year [aweight=popwt], fe vce(cluster sid)

* 2

* Le agrego region por año
eststo: xtreg l_robbery post i.year $region [aweight=popwt], fe vce(cluster sid)

* 3

* Controles variables en el tiempo
eststo: xtreg l_robbery post i.year $region $xvar [aweight=popwt], fe vce(cluster sid)

* 4 

* Le agrego un control por 2 años previos
eststo: xtreg l_robbery post pre2_cdl i.year $region $xvar [aweight=popwt], fe vce(cluster sid)

* 5 

* Agrego las variables de crimen contemporáneas
eststo: xtreg l_robbery post i.year $exocrime $region $xvar [aweight=popwt], fe vce(cluster sid)

* 6 

* Variables lineales en el tiempo de los estados
eststo: xtreg l_robbery post i.year $lintrend $region $xvar [aweight=popwt], fe vce(cluster sid)

* 7 

eststo: xtreg l_robbery post i.year, fe vce(cluster sid)

* 8 

* Le agrego region por año
eststo: xtreg l_robbery post i.year $region, fe vce(cluster sid)

* 9 

* Controles variables en el tiempo
eststo: xtreg l_robbery post i.year $region $xvar, fe vce(cluster sid)

* 10 

* Le agrego un control por 2 años previos
eststo: xtreg l_robbery post pre2_cdl i.year $region $xvar, fe vce(cluster sid)

* 11 

* Agrego las variables de crimen contemporáneas
eststo: xtreg l_robbery post i.year $exocrime $region $xvar, fe vce(cluster sid)

* 12 

* Variables lineales en el tiempo de los estados
eststo: xtreg l_robbery post i.year $lintrend $region $xvar, fe vce(cluster sid)

esttab using "$output/Tabla4_B.tex", se replace label noobs noabbrev ///
keep(post pre2_cdl, relax) cells(b(fmt(4) star) se(par fmt(4)))

********************************************************************************
* PANEL C 

eststo clear
* 1

* Solo state y year fixed effects
eststo: xtreg l_assault post i.year [aweight=popwt], fe vce(cluster sid)

* 2

* Le agrego region por año
eststo: xtreg l_assault post i.year $region [aweight=popwt], fe vce(cluster sid)

* 3

* Controles variables en el tiempo
eststo: xtreg l_assault post i.year $region $xvar [aweight=popwt], fe vce(cluster sid)

* 4 

* Le agrego un control por 2 años previos
eststo: xtreg l_assault post pre2_cdl i.year $region $xvar [aweight=popwt], fe vce(cluster sid)

* 5 

* Agrego las variables de crimen contemporáneas
eststo: xtreg l_assault post i.year $exocrime $region $xvar [aweight=popwt], fe vce(cluster sid)

* 6 

* Variables lineales en el tiempo de los estados
eststo: xtreg l_assault post i.year $lintrend $region $xvar [aweight=popwt], fe vce(cluster sid)

* 7 

eststo: xtreg l_assault post i.year, fe vce(cluster sid)

* 8 

* Le agrego region por año
eststo: xtreg l_assault post i.year $region, fe vce(cluster sid)

* 9 

* Controles variables en el tiempo
eststo: xtreg l_assault post i.year $region $xvar, fe vce(cluster sid)

* 10 

* Le agrego un control por 2 años previos
eststo: xtreg l_assault post pre2_cdl i.year $region $xvar, fe vce(cluster sid)

* 11 

* Agrego las variables de crimen contemporáneas
eststo: xtreg l_assault post i.year $exocrime $region $xvar, fe vce(cluster sid)

* 12 

* Variables lineales en el tiempo de los estados
eststo: xtreg l_assault post i.year $lintrend $region $xvar, fe vce(cluster sid)

esttab using "$output/Tabla4_C.tex", se replace label noobs noabbrev ///
keep(post pre2_cdl, relax) cells(b(fmt(4) star) se(par fmt(4))) ///
indicate("State and Year Fixed Effects = *.year" "Region-by-Year Fixed Effects = *r20001" "Time-Varying Controls = *l_police" "Contemporaneous Crime Rates = *l_larceny" "State-Specific Linear Time Trends = *trend_1") ///
stats(N, fmt(0) labels("Observations"))


********************************************************************************
* Exporto en paneles la Tabla 4

include "https://raw.githubusercontent.com/steveofconnell/PanelCombine/master/PanelCombine.do"

cd "$output"

panelcombine, use(Tabla4_A.tex Tabla4_B.tex Tabla4_C.tex)  columncount(12) paneltitles("Burglary" "Robbery" "Aggravated Assault") save(Tabla4.tex)

cd "$main"

********************************************************************************
* Ejercicio 2

*ssc install csdid
*ssc install drdid
*ssc install bacondecomp

bys state: gen treat = year if cdl>0 & cdl<1
bys state: egen treated = max(treat)
replace treated = 0 if treated == .

csdid l_assault post i.year i.sid [weight=popwt], ivar(sid) time(year) gvar(treated) method(reg) notyet

* Pretrends test

estat pretrend

* Average ATT

estat simple

estat event
csdid_plot

csdid_plot, group(2006) name(m1,replace) title("Group 2006")
csdid_plot, group(2007) name(m2,replace) title("Group 2007")
csdid_plot, group(2008) name(m3,replace) title("Group 2008")
csdid_plot, group(2009) name(m4,replace) title("Group 2009")
graph combine m1 m2 m3 m4, xcommon scale(0.8)


********************************************************************************
* Ejercicio 3

bacondecomp l_burglary post , stub(Bacon_) ddetail








