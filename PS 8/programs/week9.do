/*******************************************************************************
                         Semana 9: Control sintético

                          Universidad de San Andrés
                              Economía Aplicada
							       2022							           
*******************************************************************************/

/*******************************************************************************
Este archivo sigue la siguiente estructura:

0) Set up environment

1) Abadie, Diamante, y Hainmueller (2010)

2) Ejemplo país vasco

*******************************************************************************/


* 0) Set up environment
*==============================================================================*

global main "C:\Users\Franco\Documents\GitHub\Problem-Sets\PS 8"
global output "$main/outputs"
global input "$main/input"

cd "$output"

* 1) Abadie, Diamante, y Hainmueller (2010)
*==============================================================================*
	
/*
Este conjunto de datos panel contiene información para los 39 estados de los EEUU para los 
años 1970-2000 (ver Abadie, Diamante, y Hainmueller (2010) para más detalles). */

use "$input/smoking.dta", clear

* Aclarar a Stata que es un panel
tsset state year

* Instalar el comando
ssc install synth

* Ejemplo 1.a
synth cigsale beer(1984(1)1988) lnincome retprice age15to24 cigsale(1988) cigsale(1980) cigsale(1975), trunit(3) trperiod(1989) nested fig

/* En este ejemplo, la unidad afectada por la intervención es la unidad número 3 (California) 
en el año 1989. 

Los "donors" son por defecto las unidades 1,2,4,5, ..., 39; es decir, los otros 38 estados del 
conjunto de datos. Si se desea especificar los donors se debe utilizar la opción counit ().  

Dado que no se especifíca xperiod (), las variables retprice, lnincome y age15to24 se promedian sobre el 
todo el periodo de pre-intervención hasta el año de la intervención (1970,1981, ..., 1988). 

La variable beer tiene el periodo de tiempo (1984 (1) 1988) especificado, lo que significa que es 
un promedio de los periodos 1984,1985, ..., 1988. 

La variable cigsale se utiliza tres veces como un predictor usando los valores de 
periodos 1988, 1980 y 1975 respectivamente. 

El MSPE se minimiza sobre todo el periodo de pretratamiento, porque mspeperiod () no se proporciona. 

Por defecto, los resultados son muestra para el período comprendido entre 1970,1971, ..., 2000 
(todo el periodo). 

Siempre usar NESTED: will lead to better performance, however, at the expense of additional computing time.

Alternativamente, el usuario puede también especificar la opción "allopt" para asignar una matriz V para iniciar la optimización que puede mejorar el ajuste incluso más (requiere aún más tiempo de cálculo). 

*/

* Los outputs de los comandos generalmente se guardan en matrices en la memoria de Stata. 

eret list

* En e(W_weights) se guardan los pesos de cada unidad

mat list e(W_weights)

* En e(X_balance) se guarda la matriz con las medias de las variables de control para el sintético y el verdadero

mat list e(X_balance)

* Hay un comando muy útil para exportar matrices a tablas.

ssc install frmttable 

* Lo uso para exportar las matrices

frmttable , statmat(e(W_weights)) sdec(0,2)

* Puede ser que no me interese la primera columna

mat weights = e(W_weights)[1..38,2]

frmttable using "$output/state_weights.rtf", statmat(weights) sdec(2) ctitle("State", "Weight")

* Ahora exporto la matriz de balances

frmttable using "$output/variables_balance.rtf" , statmat(e(X_balance)) sdec(2,2) ctitle("Variable", "Treated", "Synthetic") rtitle("Beer consumption pc 1984-1998" \ "log(Income)" \ "Cigarette retail price" \ "% Pop age 15 to 24" \ "Cigarette sales in 1988" \ "Cigarette sales in 1980" \ "Cigarette sales in 1975")

* Ejemplo 1.b  
synth cigsale beer lnincome(1980&1985) retprice cigsale(1988) cigsale(1980) cigsale(1975), trunit(3) trperiod(1989) fig nested

/* Este ejemplo es similar al ejemplo 1.a, pero ahora beer se promedia sobre todo el 
periodo de pretratamiento mientras lnincome sólo se promedia entre los periodos 1980 y 1985.
Ya que no hay datos disponibles para beer antes de 1984, synth informará al usuario de que hay 
falta de datos para esta variable y que los valores que faltan son ignorados en el cálculo del 
promedio. */

* Ejemplo 1.c
synth cigsale retprice cigsale(1970) cigsale(1979) , trunit(33) counit(1(1)20) trperiod(1980) fig resultsperiod(1970(1)1990) nested
       		
/* En este ejemplo, la unidad afectada por la intervención es el estado número 33, y el 
grupo de donantes potenciales de unidades de control se limita a estados no 1,2, ..., 20. 
La intervención se produce en 1980, y los resultados se obtienen para el periodo 
1970,1971, ..., 1990. */

* Ejemplo 1.d
synth cigsale retprice cigsale(1970) cigsale(1979) , trunit(33) counit(1(1)20) trperiod(1980) resultsperiod(1970(1)1990) keep(resout1) nested

/* Este ejemplo es similar al ejemplo 1.b pero se especifica la opción "resout" y por lo tanto 
el comando synth guardará un conjunto de datos denominado resout.dta, que se ubicará en el actual 
directorio de trabajo de Stata.
 
Este conjunto de datos contiene el resultado desde el ajuste actual y se puede utilizar para su 
posterior procesamiento. 
Además de acceder fácilmente a resultados se puede utilizar el comando ereturn list para acceder a 
todas las matrices de resultados. */

* Ejemplo 1.e
synth cigsale beer lnincome retprice age15to24 cigsale(1988) cigsale(1980) cigsale(1975) , trunit(3) trperiod(1989) xperiod(1980(1)1988) nested keep(resout2) fig 

/* Se especifica laopción "xperiod()" lo que indica que los predictores se promedian para el 
periodo 1980,1981, ..., 1988. 
*/

matrix gaps=e(Y_treated) -e(Y_synthetic)
matrix Y_treated=e(Y_treated)
matrix Y_synthetic=e(Y_synthetic)
keep year 
svmat gaps
svmat Y_treated
svmat Y_synthetic

twoway (line Y_treated1 year) (line Y_synthetic1 year) (scatter gaps1 year, yaxis(2)), legend(col(3)) xline(1989)

*A continuación se muestra un ejemplo para correr un placebo con todos los otros estados como tratados

use "$input/smoking.dta", clear
tsset state year 

tempname resmat
        local i 3
        qui synth cigsale retprice cigsale(1988) cigsale(1980) cigsale(1975) , trunit(`i') trperiod(1989) xperiod(1980(1)1988) keep(resout`i', replace)	
        matrix `resmat' = nullmat(`resmat') \ e(RMSPE)
        local names `"`names' `"`i'"'"'
        mat colnames `resmat' = "RMSPE"
        mat rownames `resmat' = `names'
        matlist `resmat' , row("Treated Unit")
		
		drop if state==3
		
        forvalues i = 1/31 {
		if `i'==3 { 
		continue
		}
        qui synth cigsale retprice cigsale(1988) cigsale(1980) cigsale(1975) , trunit(`i') trperiod(1989) xperiod(1980(1)1988) keep(resout`i', replace)	
        matrix `resmat' = nullmat(`resmat') \ e(RMSPE)
        local names `"`names' `"`i'"'"'
        }
		
        mat colnames `resmat' = "RMSPE"
        mat rownames `resmat' = `names'
        matlist `resmat' , row("Treated Unit")

forvalues i = 1/31 {
use "$output/resout`i'.dta", clear
ren _Y_synthetic _Y_synthetic_`i'
ren _Y_treated _Y_treated_`i'
gen _Y_gap_`i'=_Y_treated_`i'-_Y_synthetic_`i'
save "$output/resout`i'.dta", replace
}

use "$output/resout1.dta", clear
forvalues i = 2/31 {
merge 1:1 _Co_Number _time using "$output/resout`i'.dta", nogen
}

*twoway (line _Y_synthetic_1 _time, lcolor(gray)) (line _Y_synthetic_2 _time, lcolor(gray)) (line _Y_treated_3 _time, lcolor(black) lwidth(thick)) (line _Y_synthetic_4 _time, lcolor(gray)) (line _Y_synthetic_5 _time, lcolor(gray)) (line _Y_synthetic_6 _time, lcolor(gray)) (line _Y_synthetic_7 _time, lcolor(gray)) (line _Y_synthetic_8 _time, lcolor(gray)) (line _Y_synthetic_9 _time, lcolor(gray)) (line _Y_synthetic_10 _time, lcolor(gray)) (line _Y_synthetic_11 _time, lcolor(gray)) (line _Y_synthetic_12 _time, lcolor(gray)) (line _Y_synthetic_13 _time, lcolor(gray)) (line _Y_synthetic_14 _time, lcolor(gray)) (line _Y_synthetic_15 _time, lcolor(gray)) (line _Y_synthetic_16 _time, lcolor(gray)) (line _Y_synthetic_17 _time, lcolor(gray)) (line _Y_synthetic_18 _time, lcolor(gray)) (line _Y_synthetic_19 _time, lcolor(gray)) (line _Y_synthetic_20 _time, lcolor(gray)) (line _Y_synthetic_21 _time, lcolor(gray)) (line _Y_synthetic_22 _time, lcolor(maroon)) (line _Y_synthetic_23 _time, lcolor(gray)) (line _Y_synthetic_24 _time, lcolor(gray)) (line _Y_synthetic_25 _time, lcolor(gray)) (line _Y_synthetic_26 _time, lcolor(gray)) (line _Y_synthetic_27 _time, lcolor(gray)) (line _Y_synthetic_28 _time, lcolor(gray)) (line _Y_synthetic_29 _time, lcolor(gray)) (line _Y_synthetic_30 _time, lcolor(gray)) (line _Y_synthetic_31 _time, lcolor(gray)), xline(1989) legend(off) name(gg1, replace)
	
twoway (line _Y_gap_1 _time, lcolor(gray)) (line _Y_gap_2 _time, lcolor(gray)) (line _Y_gap_4 _time, lcolor(gray)) (line _Y_gap_5 _time, lcolor(gray)) (line _Y_gap_6 _time, lcolor(gray)) (line _Y_gap_7 _time, lcolor(gray)) (line _Y_gap_8 _time, lcolor(gray)) (line _Y_gap_9 _time, lcolor(gray)) (line _Y_gap_10 _time, lcolor(gray)) (line _Y_gap_11 _time, lcolor(gray)) (line _Y_gap_12 _time, lcolor(gray)) (line _Y_gap_13 _time, lcolor(gray)) (line _Y_gap_14 _time, lcolor(gray)) (line _Y_gap_15 _time, lcolor(gray)) (line _Y_gap_16 _time, lcolor(gray)) (line _Y_gap_17 _time, lcolor(gray)) (line _Y_gap_18 _time, lcolor(gray)) (line _Y_gap_19 _time, lcolor(gray)) (line _Y_gap_20 _time, lcolor(gray)) (line _Y_gap_21 _time, lcolor(gray)) (line _Y_gap_22 _time, lcolor(maroon)) (line _Y_gap_23 _time, lcolor(gray)) (line _Y_gap_24 _time, lcolor(gray)) (line _Y_gap_25 _time, lcolor(gray)) (line _Y_gap_26 _time, lcolor(gray)) (line _Y_gap_27 _time, lcolor(gray)) (line _Y_gap_28 _time, lcolor(gray)) (line _Y_gap_29 _time, lcolor(gray)) (line _Y_gap_30 _time, lcolor(gray)) (line _Y_gap_31 _time, lcolor(gray)) (line _Y_gap_3 _time, lcolor(black) lwidth(thick)), xline(1989) legend(off) name(gg2,replace)

* Leave one out	
use "$input/smoking.dta", clear
tsset state year 

tempname resmat
        local i 3
        qui synth cigsale retprice cigsale(1988) cigsale(1980) cigsale(1975) , trunit(`i') trperiod(1989) xperiod(1980(1)1988) keep(loo-resout`i', replace)	
		
		forvalues j=1/31 {
		if `j'==3 { 
		continue
		}
		use "$input/smoking.dta", clear
		tsset state year 
		drop if state==`j'
        qui synth cigsale retprice cigsale(1988) cigsale(1980) cigsale(1975), trunit(3) trperiod(1989) xperiod(1980(1)1988) keep(loo-resout`j', replace)	
        }
		

forvalues i = 1/31 {
use "$output/loo-resout`i'.dta", clear
ren _Y_synthetic _Y_synthetic_`i'
ren _Y_treated _Y_treated_`i'
gen _Y_gap_`i'=_Y_treated_`i'-_Y_synthetic_`i'
save "$output/loo-resout`i'.dta", replace
}

use "$output/loo-resout1.dta", clear
forvalues i = 2/31 {
merge 1:1 _Co_Number _time using "$output/loo-resout`i'.dta", nogen
}

twoway (line _Y_synthetic_1 _time, lcolor(gray)) (line _Y_synthetic_2 _time, lcolor(gray)) (line _Y_synthetic_4 _time, lcolor(gray)) (line _Y_synthetic_5 _time, lcolor(gray)) (line _Y_synthetic_6 _time, lcolor(gray)) (line _Y_synthetic_7 _time, lcolor(gray)) (line _Y_synthetic_8 _time, lcolor(gray)) (line _Y_synthetic_9 _time, lcolor(gray)) (line _Y_synthetic_10 _time, lcolor(gray)) (line _Y_synthetic_11 _time, lcolor(gray)) (line _Y_synthetic_12 _time, lcolor(gray)) (line _Y_synthetic_13 _time, lcolor(gray)) (line _Y_synthetic_14 _time, lcolor(gray)) (line _Y_synthetic_15 _time, lcolor(gray)) (line _Y_synthetic_16 _time, lcolor(gray)) (line _Y_synthetic_17 _time, lcolor(gray)) (line _Y_synthetic_18 _time, lcolor(gray)) (line _Y_synthetic_19 _time, lcolor(gray)) (line _Y_synthetic_20 _time, lcolor(gray)) (line _Y_synthetic_21 _time, lcolor(gray)) (line _Y_synthetic_22 _time, lcolor(gray)) (line _Y_synthetic_23 _time, lcolor(gray)) (line _Y_synthetic_24 _time, lcolor(gray)) (line _Y_synthetic_25 _time, lcolor(gray)) (line _Y_synthetic_26 _time, lcolor(gray)) (line _Y_synthetic_27 _time, lcolor(gray)) (line _Y_synthetic_28 _time, lcolor(gray)) (line _Y_synthetic_29 _time, lcolor(gray)) (line _Y_synthetic_30 _time, lcolor(gray)) (line _Y_synthetic_31 _time, lcolor(gray)) (line _Y_treated_3 _time, lcolor(black) lwidth(thick)) (line _Y_synthetic_3 _time, lcolor(black)), xline(1989) legend(off)
	
*twoway (line _Y_gap_1 _time, lcolor(gray)) (line _Y_gap_2 _time, lcolor(gray)) (line _Y_gap_4 _time, lcolor(gray)) (line _Y_gap_5 _time, lcolor(gray)) (line _Y_gap_6 _time, lcolor(gray)) (line _Y_gap_7 _time, lcolor(gray)) (line _Y_gap_8 _time, lcolor(gray)) (line _Y_gap_9 _time, lcolor(gray)) (line _Y_gap_10 _time, lcolor(gray)) (line _Y_gap_11 _time, lcolor(gray)) (line _Y_gap_12 _time, lcolor(gray)) (line _Y_gap_13 _time, lcolor(gray)) (line _Y_gap_14 _time, lcolor(gray)) (line _Y_gap_15 _time, lcolor(gray)) (line _Y_gap_16 _time, lcolor(gray)) (line _Y_gap_17 _time, lcolor(gray)) (line _Y_gap_18 _time, lcolor(gray)) (line _Y_gap_19 _time, lcolor(gray)) (line _Y_gap_20 _time, lcolor(gray)) (line _Y_gap_21 _time, lcolor(gray)) (line _Y_gap_22 _time, lcolor(maroon)) (line _Y_gap_23 _time, lcolor(gray)) (line _Y_gap_24 _time, lcolor(gray)) (line _Y_gap_25 _time, lcolor(gray)) (line _Y_gap_26 _time, lcolor(gray)) (line _Y_gap_27 _time, lcolor(gray)) (line _Y_gap_28 _time, lcolor(gray)) (line _Y_gap_29 _time, lcolor(gray)) (line _Y_gap_30 _time, lcolor(gray)) (line _Y_gap_31 _time, lcolor(gray)) (line _Y_gap_3 _time, lcolor(black) lwidth(thick)), xline(1989) legend(off)		
	
* In-time placebo	
tempname resmat
use "$input/smoking.dta", clear
tsset state year
        forvalues t = 1980/1989 {
        qui synth cigsale retprice cigsale(1988) cigsale(1980) cigsale(1975) , trunit(3) trperiod(`t') keep(resout`t', replace)		
        }
		
forvalues t = 1980/1989 {
use "$output/resout`t'.dta", clear
ren _Y_synthetic _Y_synthetic_`t'
ren _Y_treated _Y_treated_`t'
gen _Y_gap_`t'=_Y_treated_`t'-_Y_synthetic_`t'
save "$output/resout`t'.dta", replace
}

use "$output/resout1980.dta", clear
forvalues t = 1981/1989 {
merge 1:1 _Co_Number _time using "$output/resout`t'.dta", nogen
}

*twoway (line _Y_gap_1981 _time , lcolor(gray) ) (line _Y_gap_1982 _time , lcolor(gray)) (line _Y_gap_1983 _time , lcolor(gray)) (line _Y_gap_1984 _time , lcolor(gray)) (line _Y_gap_1985 _time , lcolor(gray)) (line _Y_gap_1986 _time , lcolor(gray)) (line _Y_gap_1987 _time , lcolor(gray)) (line _Y_gap_1988 _time , lcolor(gray)) (line _Y_gap_1989 _time, lcolor(black) lwidth(thick)), legend(off) xline(1989)
		
twoway (line _Y_synthetic_1981 _time , lcolor(gray) ) (line _Y_synthetic_1982 _time , lcolor(gray)) (line _Y_synthetic_1983 _time , lcolor(gray)) (line _Y_synthetic_1984 _time , lcolor(gray)) (line _Y_synthetic_1985 _time , lcolor(gray)) (line _Y_synthetic_1986 _time , lcolor(gray)) (line _Y_synthetic_1987 _time , lcolor(gray)) (line _Y_synthetic_1988 _time , lcolor(gray)) (line _Y_treated_1989 _time, lcolor(black) lwidth(thick)), legend(off) xline(1989)
		
* Para cross validation of V ver Abadie, A., Diamond, A., & Hainmueller, J. (2015). Comparative politics and the synthetic control method. American Journal of Political Science, 59(2), 495-510.		
		
		
* 2) Ejemplo País Vasco
*==============================================================================*
	
use "$input/basque.compl.dta", clear

/* El conjunto de datos contiene información de 1955 a 1997 de 17 regiones españolas. 
Fue utilizado por Abadie y Gardeazabal (2003), que estudiaron los efectos económicos del 
conflicto, utilizando el conflicto terrorista en el País Vasco como un estudio de caso.
Este paper utiliza una combinación de otras regiones españolas para construir una región sintética 
de control que se asemeja a muchas características económicas relevantes del País Vasco antes de la 
aparición del terrorismo político en la década de 1970. Los datos contienen el PIB per cápita 
(la variable de resultado), así como la densidad de poblacional, la producción sectorial, 
la inversión y el capital humano (las variables predictoras) para los años pertinentes.

El panel está compuesto de 18 unidades: 1 tratada (el País Vasco que es la unidad 17) y 16 de 
control de las regiones (de las unidades 2 a 16). 
La unidad región número 1 es la media para todo el país (España). 
La variable de resultado es gdpcap. 
Hay 13 variables predictoras: 
- 6 acciones sectoriales de producción, 
- 6 categorías más altas de logro educacional, 
- densidad de población, 
- y la tasa de inversión.

Los nombres de las regiones y los números se almacenan en regionno y regionName. 
Hay 42 periodos de tiempo (1955 - 1997). 
*/

tsset regionno year

synth gdpcap school_illit school_prim school_med school_high school_post_high invest gdpcap(1960(1)1969) sec_agriculture(1961(2)1969) sec_energy(1961(2)1969) sec_industry(1961(2)1969) sec_construction(1961(2)1969) sec_services_venta(1961(2)1969) sec_services_nv(1961(2)1969) popdens(1969), trunit(17) trperiod (1970) counit(2(1)16, 18) xperiod (1960(1)1969) resultsperiod (1955(1)1997) mspeperiod(1960(1)1969) fig keep(resout2)

matrix gaps=e(Y_treated) -e(Y_synthetic)
matrix Y_treated=e(Y_treated)
matrix Y_synthetic=e(Y_synthetic)
keep year 
keep if year>1954 & year<1998
svmat gaps
svmat Y_treated
svmat Y_synthetic

twoway (rline Y_treated1 Y_synthetic1 year) (scatter gaps1 year, yaxis(2))

* Se realiza un placebo con Catalunya
use "$input/basque.compl.dta", clear

tsset regionno year

synth gdpcap school_illit school_prim school_med school_high school_post_high invest gdpcap(1960(1)1969) sec_agriculture(1961(2)1969) sec_energy(1961(2)1969) sec_industry(1961(2)1969) sec_construction(1961(2)1969) sec_services_venta(1961(2)1969) sec_services_nv(1961(2)1969) popdens(1969), trunit(10) trperiod (1970) counit(2(1)9, 11(1)17, 18) xperiod (1960(1)1969) mspeperiod(1964(1)1969) resultsperiod (1955(1)1997)  fig 

/*
References

Abadie, A., Diamond, A., and J. Hainmueller. 2010. Synthetic Control
        Methods for Comparative Case Studies: Estimating the Effect of
        California's Tobacco Control Program.  Journal of the American
        Statistical Association 105(490): 493-505.

Abadie, A. and Gardeazabal, J. 2003. Economic Costs of Conflict:  A Case
        Study of the Basque Country. American Economic Review 93(1): 113-132.
*/

