/*******************************************************************************
                         Semana 9: Control sintético

                          Universidad de San Andrés
                              Economía Aplicada
							       2022							           
*******************************************************************************/
*      Bronstein         García Vassallo            López             Riottini
/*******************************************************************************
Este archivo sigue la siguiente estructura:

0) Set up environment

1) Abadie, Diamante, y Hainmueller (2010)

2) Ejemplo país vasco

*******************************************************************************/


* 0) Set up environment
*==============================================================================*

global main "C:\Users\felip\Documents\UdeSA\Maestría\Aplicada\Problem-Sets\PS 8"
global output "$main/output"
global input "$main/input"

cd "$main"

* 1) Empiezo a replicar

* Uso el csv en forma de panel
import delimited "$input/df.csv", encoding(UTF-8) clear

* Defino el panel
tsset code year

* Instalo el paquete para controles sintéticos
*ssc install synth

line homiciderates year

collapse (mean) homiciderates if code!=35, by(year)

gen code=1

save "$input/brasil.dta", replace

import delimited "$input/df.csv", encoding(UTF-8) clear

append using "$input/brasil.dta"

twoway (line homiciderates year if code==1, lcolor(grey) lpattern(dash)) (line homiciderates year if code==35, lcolor(black)), ytitle("Homicide Rates") xtitle("Year") xline(1999, lpattern(shortdash) lcolor(grey)) legend(label(1 "Sao Paulo") label(2 "Brazil (average)"))
graph export "$output/1.png", replace

* Gráfico 2

drop if code==1

synth homiciderates yearsschoolingimp stategdpcapita homiciderates proportionextremepoverty giniimp populationprojectionln stategdpgrowthpercent, trunit(35) trperiod(1999) nested fig
graph export "$output/2.png", replace

* Gráfico 3

matrix gaps=e(Y_treated) -e(Y_synthetic)
matrix Y_treated=e(Y_treated)
matrix Y_synthetic=e(Y_synthetic)
keep year 
svmat gaps
svmat Y_treated
svmat Y_synthetic

twoway (line gaps1 year, lcolor(black)), xline(1999,lpattern(shortdash) lcolor(grey)) yline(0, lpattern(dash) lcolor(black)) ytitle("Gap in Homicide Rates") xtitle("Year")
graph export "$output/3.png", replace

* Gráfico 4

import delimited "$input/df.csv", encoding(UTF-8) clear

tsset code year

synth homiciderates yearsschoolingimp stategdpcapita homiciderates proportionextremepoverty giniimp populationprojectionln stategdpgrowthpercent, trunit(35) trperiod(1995) resultsperiod(1990(1)1998) nested fig
graph export "$output/4.png", replace

* Gráfico 5














