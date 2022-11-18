/*******************************************************************************
*                             Semana 11: Matching

*                          Universidad de San Andrés
*                              Economía Aplicada
*	    		                      2022							           
*******************************************************************************/
*      Bronstein         García Vassallo            López             Riottini
/*******************************************************************************
Este archivo sigue la siguiente estructura:

0) Configurar el entorno

1) Analizo balance de variables observables

2) Propensity score

3) Graph of pscores

4) Common support

5) Gen matches

6) Graph of pscores conditional on matches

7) Balance de observables condicional en matches

*******************************************************************************/
* 0) Configurar el entorno
*==============================================================================*

global main "C:\Users\felip\Documents\UdeSA\Maestría\Aplicada\Problem-Sets\PS 11"
global input "$main/input"
global output "$main/output"

cd "$main"

use "$input/base_censo.dta", clear

*******************************************************************************/
* 1) Analizo balance de variables observables
*==============================================================================*

* Hago test de medias por tratamiento
ttest pobl_1999, by(treated)
ttest via1, by(treated)
ttest ranking_pobr, by(treated)

*******************************************************************************/
* 2) Propensity score
*==============================================================================*

* Dropeo variables con missings
foreach var of varlist _all { 
drop if `var'==.
}

* Calculo el propensity score
probit treated ind_abs_pobr ldens_pob prov_cap pob_1 pob_2 pob_3 pob_4 ///
km_cap_prov via3 via5 via7 via9 region_2 region_3 laltitud /// 
tdesnutr deficit_post deficit_aulas
predict p_score

*******************************************************************************/
* 3) Graph of pscores
*==============================================================================*

twoway (kdensity p_score if treated==1,lwidth(thick) lpattern(solid) lcolor(black)) ///
(kdensity p_score if treated==0, lwidth(thick) lpattern("_####_####") lcolor(black)) ///
, scheme(s1mono) legend(lab(1 "Treated") lab(2 "Not treated")) ///
xtitle("Propensity Score") ytitle("Density") 
graph export "$output/distrib_prop.png", replace

*******************************************************************************/
* 4) Common support
*==============================================================================*

bysort treated: summ p_score
egen x = min(p_score) if treated==1
egen psmin = min(x)
egen y = max(p_score) if treated==0
egen psmax=max(y)
drop x y
gen common_sup=1 if (p_score>=psmin & p_score<=psmax) & p_score!=.
replace common_sup=0 if common_sup==.

*******************************************************************************/
* 5) Gen matches
*==============================================================================*

psmatch2 treated if common_sup==1, p(p_score) noreplacement
gen matches=_weight
replace matches=0 if matches==.

*******************************************************************************/
* 6) Graph of pscores conditional on matches
*==============================================================================*

twoway (kdensity p_score if treated==1 & matches==1,lwidth(thick) lpattern(solid) lcolor(black)) ///
(kdensity p_score if treated==0 & matches==1, lwidth(thick) lpattern("_####_####") lcolor(black)) ///
, scheme(s1mono) legend(lab(1 "Treated") lab(2 "Not treated")) ///
xtitle("Propensity Score") ytitle("Density") 
graph export "$output/distrib_prop2.png", replace

*******************************************************************************/
* 7) Balance de observables condicional en matches
*==============================================================================*

* Hago test de medias por tratamiento
ttest pobl_1999 if matches==1, by(treated)
ttest via1 if matches==1, by(treated)
ttest ranking_pobr if matches==1, by(treated)





