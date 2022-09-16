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

global main "C:\Users\felip\Documents\UdeSA\Maestría\Aplicada\Problem-Sets\PS 4"
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

reg cartel2010 chinese_pres i.id_estado, cluster(id_estado)
est store ols1

reg cartel2010 chinese_pres dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
est store ols2

reg cartel2005 chinese_pres i.id_estado, cluster(id_estado)
est store ols3

reg cartel2005 chinese_pres dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
est store ols4

* Exporto tabla a Latex
esttab ols1 ols2 ols3 ols4 using "$output/EJ_3.tex", replace label keep(chinese_pres)

* 4) Replicación de Tabla 7
*==============================================================================*

ivregress 2sls IM_2015 (cartel2010=chinese_pres) i.id_estado, cluster(id_estado)
est store iv1
qui testparm*
estadd scalar p_value = r(p)
estat firststage
mat fstat = r(singleresults)
estadd scalar fs = fstat[1,4]

ivregress 2sls IM_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
est store iv2
qui testparm*
estadd scalar p_value = r(p)
estat firststage
mat fstat = r(singleresults)
estadd scalar fs = fstat[1,4]

ivregress 2sls IM_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado if distancia_km<100, cluster(id_estado)
est store iv3
qui testparm*
estadd scalar p_value = r(p)
estat firststage
mat fstat = r(singleresults)
estadd scalar fs = fstat[1,4]

ivregress 2sls IM_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado if estado!="Sinaloa", cluster(id_estado) 
est store iv4
qui testparm*
estadd scalar p_value = r(p)
estat firststage
mat fstat = r(singleresults)
estadd scalar fs = fstat[1,4]

ivregress 2sls IM_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado growthperc i.id_estado, cluster(id_estado)
est store iv5
qui testparm*
estadd scalar p_value = r(p)
estat firststage
mat fstat = r(singleresults)
estadd scalar fs = fstat[1,4]

*Exporto tabla a Latex
esttab iv1 iv2 iv3 iv4 iv5 using "$output/EJ_4.a.tex", replace label keep(cartel2010) scalar(F p_value) stats(fs p_value N, fmt(2 3 0))

* Replicación Tabla 8

ivregress 2sls ANALF_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
est store iv6

ivregress 2sls SPRIM_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
est store iv7

ivregress 2sls OVSDE_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
est store iv8

ivregress 2sls OVSEE_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
est store iv9

ivregress 2sls OVSAE_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
est store iv10

ivregress 2sls VHAC_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
est store iv11

ivregress 2sls OVPT_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
est store iv12

ivregress 2sls PL5000_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
est store iv13

ivregress 2sls PO2SM_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
est store iv14

*Exporto tabla a Latex
esttab iv6 iv7 iv8 iv9 iv10 iv11 iv12 iv13 iv14 using "$output/EJ_4.b.tex", replace label keep(cartel2010)

* 5) Testear exogenenidad del instrumento (test de Hausman)
*==============================================================================*

*Estimaciones por IV
ivregress 2sls IM_2015 (cartel2010=chinese_pres) dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado
est store ivh

*Estimaciones por OLS
reg IM_2015 cartel2010 dalemanes suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado
est store olsh

*Test de Hausman (bajo hipótesis nula IV es consitente)
hausman ivh olsh
 

* 6) Test de sobreidentificación
*==============================================================================*

ivregress 2sls IM_2015 (cartel2010=chinese_pres dalemanes) suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
predict resid1, residual

reg resid1 suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado chinese_pres dalemanes i.id_estado, cluster(id_estado)

test chinese_pres=dalemanes=0

return list
ereturn list

display chi2tail(1,2*r(F))

ivreg2 IM_2015 (cartel2010=chinese_pres dalemanes) suitability TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado, cluster(id_estado)

*Exportar do-file a pdf
translate "$main/programs/PS 4.do" "$output/PS 4 do-file.pdf", translator(txt2pdf) replace
