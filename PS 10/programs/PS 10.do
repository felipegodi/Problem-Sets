/*******************************************************************************
                         Semana 11: Regression Discontinuity

                          Universidad de San Andrés
                              Economía Aplicada
							       2022							           
*******************************************************************************/
*      Bronstein         García Vassallo            López             Riottini
/*******************************************************************************
Este archivo sigue la siguiente estructura:

0) Set up environment

1) Install packages

2) Plot RD

3) Falsification tests

4) Run regression 

5) Change bandwidth

6) Change cutoff

7) Using local randomization with triangular kernel

*******************************************************************************/
* 0) Set up environment
*==============================================================================*

global main "C:/Users/Milton/Documents/UDESA/Economía Aplicada/Problem-Sets/PS 10"
global output "$main/output"
global input "$main/input"

cd "$main"

use "$input/data_elections.dta", clear

*******************************************************************************/
* 1) Install packages
*******************************************************************************/

net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace
net install rdlocrand, from(https://raw.githubusercontent.com/rdpackages/rdlocrand/master/stata) replace
net install rddensity, from(https://raw.githubusercontent.com/rdpackages/rddensity/master/stata) replace
net install lpdensity, from(https://raw.githubusercontent.com/nppackages/lpdensity/master/stata) replace

*******************************************************************************/
* 2) Plot RD
*******************************************************************************/

gen demwon=0
replace demwon=1 if vote_share_democrats>0.5

global y lne
global x vote_share_democrats
global covs "unemplyd union urban veterans"

rdplot $y $x, c(0.5) p(1) graph_options(graphregion(color(white)) ///
							xtitle(Democrats vote share) ///
							ytitle(Log FED expenditure) name(g$y, replace)) 
							
graph export "$output/polinomio1.png", replace
							
rdplot $y $x, c(0.5) p(2) graph_options(graphregion(color(white)) ///
							xtitle(Democrats vote share) ///
							ytitle(Log FED expenditure) name(g$y, replace)) 

graph export "$output/polinomio2.png", replace
							
							
*******************************************************************************/
* 3) Falsification tests 
*******************************************************************************/

* Density discontinuity test

rddensity $x, plot c(0.5)
graph export "$output/falsification1.png", replace

* Placebo tests on pre-determined covariates

foreach var of global covs {
	rdrobust `var' $x, c(0.5)
	qui rdplot `var' $x, c(0.5) p(1) graph_options(graphregion(color(white)) ///
													  xlabel(0.2(0.1)1) ///
													  ytitle(`var') name(g`var', replace)) 
	graph export "$output/falsification_`var'.png", replace
}

local num: list sizeof global(covs)
mat def pvals = J(`num',1,.)
local row = 1

foreach var of global covs {
    qui rdrobust `var' $x, c(0.5)
    mat pvals[`row',1] =  e(pv_rb)
    local row = `row'+1
	}
frmttable using "$output/pvals", statmat(pvals) replace tex

*******************************************************************************/
* 4) Run regression 
*******************************************************************************/

rdrobust $y $x, masspoints(off) stdvars(on) c(0.5) p(1)

rdrobust $y $x, covs($covs) masspoints(off) stdvars(on) c(0.5) p(1)

*******************************************************************************/
* 5) Change bandwidth
*******************************************************************************/

rdrobust $y $x, covs($covs) masspoints(off) stdvars(on) c(0.5) p(1) h(0.025)

rdrobust $y $x, covs($covs) masspoints(off) stdvars(on) c(0.5) p(1) h(0.15)

rdrobust $y $x, covs($covs) masspoints(off) stdvars(on) c(0.5) p(1) h(0.25)

*******************************************************************************/
* 6) Change cutoff
*******************************************************************************/

rdrobust $y $x, covs($covs) masspoints(off) stdvars(on) c(0.4) p(1)

rdplot $y $x, c(0.4) p(1) graph_options(graphregion(color(white)) ///
							xtitle(Democrats vote share) ///
							ytitle(Log FED expenditure) name(g$y, replace)) 

rdrobust $y $x, covs($covs) masspoints(off) stdvars(on) c(0.6) p(1)

rdplot $y $x, c(0.6) p(1) graph_options(graphregion(color(white)) ///
							xtitle(Democrats vote share) ///
							ytitle(Log FED expenditure) name(g$y, replace)) 

*******************************************************************************/
* 7) Using local randomization with triangular kernel
*******************************************************************************/

rdwinselect $x $covs, wmin(0.05) wstep(0.01) nwindows(20) seed(444) plot graph_options(xtitle(Half window length) ytitle(Minimum p-value across all covariates) graphregion(color(white))) c(0.5) kernel(triangular)

rdrandinf $y $x, wl(0.32) wr(0.68) reps(1000) seed(444) c(0.5)

*******************************************************************************/
*Export to PDF
*******************************************************************************/
translate "$main/programs/PS 10.do" "$output/PS 10 do-file.pdf", translator(txt2pdf) replace




