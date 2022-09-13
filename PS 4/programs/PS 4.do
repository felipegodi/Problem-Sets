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

1) Generar variable "Chinese presence"

2) Estadística descriptiva

3) Replicación de regresiones Tabla 5

4) Replicación de Tabla 7

5) Testear exogenenidad del instrumento

6) Test de sobreidentificación

*******************************************************************************/


* 0) Configurar el entorno
*==============================================================================*

global main "C:/Users/felip/Documents/UdeSA/Maestría/Aplicada/Problem-Sets/PS 4"
global input "$main/input"
global output "$main/output"

cd "$main"

use "$input/poppy.dta", clear

* 1) Variable "Chinese presence"
*==============================================================================*

gen chinese_pres= chinos1930hoy>0
replace chinese_pres=. if chinos1930hoy==.

* 2) Estadística descriptiva
*==============================================================================*

* Primero pongo bien las labels

label variable cartel2005 "Cartel presence 2005"
label variable cartel2010 "Cartel presence 2010"
label variable chinese_pres "Chinese presence"
label variable suitability "Poppy suitability"
label variable distancia_km "Distance to U.S. (km)"
label variable distkmDF "Distance to Mexivo City (km)"
label variable mindistcosta "Distance to closest port"
label variable Impuestos_pc_mun "Per capita tax revenue"
label variable chinos1930hoy "Chinese population"
label variable pob1930cabec "Population in 1930"

* Ahora hago el summ de las variables de interes

estpost summarize cartel2010 cartel2005 chinese_pres chinos1930hoy IM_2015 Impuestos_pc_mun dalemanes suitability distancia_km distkmDF mindistcosta POB_TOT_2015 superficie_km TempMed_Anual PrecipAnual_med pob1930cabec, listwise
esttab using "$output/Table 1.tex", cells("mean(fmt(2)) sd(fmt(2)) min max") ///
collabels("Mean" "SD" "Min" "Max") nomtitle nonumber replace label

* 3) Replicación de regresiones
*==============================================================================*

reg cartel2010 chinese_pres, cluster(id_estado)

reg cartel2010 chinese_pres dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta, cluster(id_estado)

reg cartel2005 chinese_pres, cluster(id_estado)

reg cartel2005 chinese_pres dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta, cluster(id_estado)

* 4) Replicación de Tabla 7
*==============================================================================*




























