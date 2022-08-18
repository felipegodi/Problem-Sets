/*******************************************************************************
*                             ECONOMIA APLICADA                                *
*                               PROBLEM SET 1                                  *
*           BRONSTEIN, GARCIA VASSALLO, LOPEZ MOSKOVITS Y RIOTTINI             *
*******************************************************************************/

* 0 PATH

* Borro por si quedó algo
clear all

* Establezco las rutas para trabajar (c/u cambia su ruta del main)
global main "C:\Users\felip\Documents\UdeSA\Maestría\Aplicada\Problem-Sets\PS 1"
global input "$main/input"
global output "$main/output"

* Importo la data a usar
use "$input/data_russia", clear

* 1 LIMPIEZA

summarize

* Hago una dummy de sexo
encode sex, gen(female)
replace female=0 if female==2
label variable female "Woman"
drop sex

*hago una dummy de obesidad
encode obese, gen(obeso)
replace obeso=0 if obeso==2
replace obeso=. if obeso==1
replace obeso=1 if obeso==3
drop obese

* Cambio los smokes por número
replace smokes="1" if smokes=="Smokes"

* Miro que diferentes valores toma econrk
levelsof econrk

* Hago un loop para los problemas de números escritos
qui ds *, has(type string)
local varlist `r(varlist)'
foreach v of local varlist {
		replace `v'="1" if `v'=="one"
		replace `v'="2" if `v'=="two"
		replace `v'="3" if `v'=="three"
		replace `v'="4" if `v'=="four"
		replace `v'="5" if `v'=="five"
		replace `v'="." if `v'==".b"
		*drop if `v'==".b"
}

* Divido el tamaño de cadera y gastos
split hipsiz
split totexpr
label variable totexpr3 "HH Expenditures Real"
label variable hipsiz3 "Hip Circumference"
drop hipsiz hipsiz1 hipsiz2 totexpr totexpr1 totexpr2


* Cambio las comas por puntos para que me deje hacer el loop
foreach v of varlist tincm_r hipsiz3 totexpr3 {
	replace `v'="." if `v'==","
}

* Paso las variables a número 
qui ds *, has(type string)
local varlist `r(varlist)'
foreach v of local varlist {
	destring `v', replace dpcomma
}

destring monage, replace
destring waistc, replace

* Me fijo los missings y si alguno tiene más del 5% (punto 2)
mdesc
* htself (si dropeo los de .b no), obese, tincm_r, totexpr y monage

* Ordeno la data como pide el punto 4
order id site female totexpr
gsort -totexpr

* Fijarse si hay data irregular
sum, d

* Hay totexpr negativos, no sé cuanto es un valor razonable para la cintura, 
* valores negativos de HH income (tincm_r)
replace totexpr3=. if totexpr3<0
replace tincm_r=. if tincm_r<0

* 2 ESTADÍSTICA DESCRIPTIVA

* Genero variable de años de edad
gen years=int(monage/12)
label variable years "Age in years"

* Quiero hacer de las siguientes variables satlif years female waistc totexpr3
* ssc install estout, replace
estpost summarize satlif years female waistc totexpr3, listwise
esttab using "$output/Table 1.tex", cells("mean sd min max") ///
collabels("Mean" "SD" "Min" "Max") nomtitle nonumber replace label

* Miro las correlaciones entre las variables
pwcorr, star(.01)

* Gráfico que compara distribución de hombres contra mujeres
twoway (hist hipsiz3 if female==1, start(30) width(5) lcolor(grey%50) fcolor(pink%30)) ///
	   (hist hipsiz3 if female==0, start(30) width(5) lcolor(grey%50) fcolor(blue%30)), ///
			legend(order(1 "Female" 2 "Male"))
graph export "$output/hipsize_histogram.png", replace

* Test de medias
ttest hipsiz3, by(female)

* Gráficos para pensar resultados
graph box years, over(satlif) title("Satisfaction with Life", position(6) color(black) size(10pt))
graph export "$output/Felicidad-Edad.png", replace

graph box satlif, over(satecc) title("Satisfaction with Economic Condition", position(6) color(black) size(10pt))
graph export "$output/Felicidad-Economia.png", replace

graph box totexpr3 if totexpr3<50000, over(satlif) title("Satisfaction with Life", position(6) color(black) size(10pt)) yscale(range(0 50000))
graph export "$output/Felicidad-Gastos.png", replace

* 3 REGRESIONES

reg satlif female years height hattac marsta1 obeso belief highsc satecc alclmo work0 totexpr3
outreg2 using "$output/regresion 1.tex", replace label

* Genero una variable de años cuadrática
gen years2=years*years
label var years2 "Age in years^2"

reg satlif female years years2 height hattac marsta1 obeso belief highsc satecc alclmo work0 totexpr3
outreg2 using "$output/regresion 2.tex", replace label