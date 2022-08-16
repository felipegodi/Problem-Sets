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

* Me fijo los missings y si alguno tiene más del 5% (punto 2)
mdesc

* Hago un loop para los problemas de números escritos
qui ds *, has(type string)
local varlist `r(varlist)'
foreach v of local varlist {
		replace `v'="1" if `v'=="one"
		replace `v'="2" if `v'=="two"
		replace `v'="3" if `v'=="three"
		replace `v'="4" if `v'=="four"
		replace `v'="5" if `v'=="five"
		drop if `v'==".b"
}

* Divido el tamaño de cadera y gastos
split hipsiz
split totexpr
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

* Ordeno la data como pide el punto 4
order id site female totexpr
gsort -totexpr

* Fijarse si hay data irregular
sum, d

* Hay totexpr negativos, no sé cuanto es un valor razonable para la cintura, 
* valores negativos de HH income (tincm_r)
