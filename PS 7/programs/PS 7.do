/*******************************************************************************
*                     Semana 7: Cluster robust inference

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

global main "C:/Users/Milton/Documents/UDESA/Economía Aplicada/Problem-Sets/PS 7"
global input "$main/input"
global output "$main/output"

cd "$main"

use "$input/base01.dta", clear

********************************************************************************

* Variable dependiente = zakaibag
* Variable de interés = treated
* Variables de control = semarab semrel y efectos fijos por grupo (si se puede)

* Separo por grupos
gen group = 1
replace group = 2 if pair == 2 | pair == 4
replace group = 3 if pair == 5 | pair == 8
replace group = 4 if pair == 7
replace group = 5 if pair == 9 | pair == 10
replace group = 6 if pair == 11
replace group = 7 if pair == 12 | pair == 13
replace group = 8 if pair == 14 | pair == 15
replace group = 9 if pair == 16 | pair == 17
replace group = 10 if pair == 18 | pair == 20
replace group = 11 if pair == 19

* REGRESIONES
eststo clear

* Robust
eststo white: xtreg zakaibag treated semarab semrel, fe i(group) vce(robust)

* Clusters
eststo clust: xtreg zakaibag treated semarab semrel, fe i(group) cluster(group)

* Wild-bootstrap
xtreg zakaibag treated semarab semrel, fe i(group) cluster(group)
eststo boo: boottest treated, boottype(wild) cluster(group) robust seed(69) nograph
mat p2=(r(p))
mat colnames p2= treated
estadd matrix p2

*ARTs

do "$main/programs/art.ado"

art zakaibag treated semarab semrel, cluster(group) m(regress) report(treated)
mat p3=(r(pvalue_joint))
mat colnames p3= treated
eststo ar: xtreg zakaibag treated semarab semrel, fe i(group) cluster(group)
estadd matrix p3

esttab white clust boo ar using "$output/Regresiones.tex", replace label keep(treated, relax) ///
cells(b(fmt(3) pvalue(p2) star) se(par fmt(2)) p(par({ })) p2(par([ ])) p3(par(< >))) ///
addnotes("standard errors in parenthesis, clustered p-value in braces, Wild-bootstrap based p-values in brackets, ART-based p-values in arrows")

* ssc install boottest

********************************************************************************
*Exportar a pdf

translate "$main/programs/PS 7.do" "$output/PS 7 do-file.pdf", translator(txt2pdf) replace




















