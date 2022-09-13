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

4) Replicación de Tabla 7 y 8

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
label variable distkmDF "Distance to Mexico City (km)"
label variable mindistcosta "Distance to closest port"
label variable Impuestos_pc_mun "Per capita tax revenue"
label variable chinos1930hoy "Chinese population"
label variable pob1930cabec "Population in 1930"
label variable capestado "Head of state"

* Ahora hago el summ de las variables de interes

estpost summarize cartel2010 cartel2005 chinese_pres chinos1930hoy IM_2015 Impuestos_pc_mun dalemanes suitability distancia_km distkmDF mindistcosta capestado POB_TOT_2015 superficie_km TempMed_Anual PrecipAnual_med pob1930cabec, listwise
esttab using "$output/Table 1.tex", cells("mean(fmt(2)) sd(fmt(2)) min max") ///
collabels("Mean" "SD" "Min" "Max") nomtitle nonumber replace label

* Dropeo las obs que sean de distrito federal
drop if estado=="Distrito Federal"

* 3) Replicación de regresiones
*==============================================================================*

reg cartel2010 chinese_pres, cluster(id_estado)
est store ols1

reg cartel2010 chinese_pres dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)
est store ols2

reg cartel2005 chinese_pres, cluster(id_estado)
est store ols3

reg cartel2005 chinese_pres dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)
est store ols4

* 4) Replicación de Tabla 7
*==============================================================================*

ivregress 2sls IM_2015 (cartel2010=chinese_pres), cluster(id_estado)
est store iv1

ivregress 2sls IM_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)
est store iv2

ivregress 2sls IM_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado if distancia_km<100, cluster(id_estado)
est store iv3

ivregress 2sls IM_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado if estado!="Sinaloa", cluster(id_estado) 
est store iv4

ivregress 2sls IM_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado growthperc, cluster(id_estado)
est store iv5

* Replicación Tabla 8

ivregress 2sls ANALF_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)
est store iv6

ivregress 2sls SPRIM_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)
est store iv7

ivregress 2sls OVSDE_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)
est store iv8

ivregress 2sls OVSEE_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)
est store iv9

ivregress 2sls OVSAE_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)
est store iv10

ivregress 2sls VHAC_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)
est store iv11

ivregress 2sls OVPT_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)
est store iv12

ivregress 2sls PL5000_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)
est store iv13

ivregress 2sls PO2SM_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)
est store iv14

* 5) Testear exogenenidad del instrumento
*==============================================================================*

ivregress 2sls IM_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)
predict resid, residual

reg resid dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado chinese_pres, cluster(id_estado)

ereturn list
display chi2tail(1,e(N)*e(r2))

* 6) Test de sobreidentificación
*==============================================================================*

ivregress 2sls IM_2015 (cartel2010=chinese_pres dalemanes) suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)
predict resid1, residual

reg resid1 suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado chinese_pres dalemanes, cluster(id_estado)

test chinese_pres=dalemanes=0

return list
ereturn list

display chi2tail(1,2*r(F))

ivreg2 IM_2015 (cartel2010=chinese_pres dalemanes) suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)