/*******************************************************************************
*                   Semana 4: Fuentes de sesgo e imprecisión 

*                          Universidad de San Andrés
*                              Economía Aplicada
*	    		                      2022							           
*******************************************************************************/
*      Bronstein         García Vassallo            López             Riottini
/*******************************************************************************
Este archivo sigue la siguiente estructura:

0) Configurar el entorno

1) Multicolinearidad

2) Ejemplo ficticio de variable omitida

*******************************************************************************/


* 0) Configurar el entorno
*==============================================================================*

global main "C:/Users/felip/Documents/UdeSA/Maestría/Aplicada/Problem-Sets/PS 3"
global input "$main/input"
global output "$main/output"

cd "$main"

* 1) Multicolinearidad
*==============================================================================*

* Usamos un ejemplo ficticio

clear
set obs 100
set seed 69
gen intelligence=int(invnormal(uniform())*20+100)

/* Setear desvío estándar de intelligence tal que la correlación entre education e intelligence sea alta (0.90 aproximadamente)*/

gen education=int(intelligence/10+invnormal(uniform())*1)
corr education intelligence

gen a=int(invnormal(uniform())*2+10)
gen b=int(invnormal(uniform())*1+5)
gen u=int(invnormal(uniform())*1+7)
gen wage=3*intelligence+a+2*b+u

* Armar dos regresiones para comparar
reg wage intelligence a b
predict y_hat_1

* Guardar la regresión ols11
est store ols11

* Setear observaciones de nuevo y definir variable de inteigencia
set obs 1000
set seed 69
replace intelligence=int(invnormal(uniform())*20+100)

*Generar mismo dataset

replace education=int(intelligence/10+invnormal(uniform())*1)
corr education intelligence

replace a=int(invnormal(uniform())*2+10)
replace b=int(invnormal(uniform())*1+5)
replace u=int(invnormal(uniform())*1+7)
replace wage=3*intelligence+a+2*b+u

*Segunda regresión
reg wage intelligence a b
predict y_hat_2

est store ols12

*Comparar ambas regresiones

esttab ols11 ols12
suest ols11 ols12

*Exportar regresiones a tex REVISAR

esttab ols11 ols12 using "$output/EJ1_1.tex", replace se stats(N r2, labels("Observations" "R-squared"))

*EJ 1.2

clear

* Setear observaciones de nuevo y definir variable de inteigencia
set obs 100
set seed 69
gen intelligence=int(invnormal(uniform())*20+100)

/* Setear desvío estándar de intelligence tal que la correlación entre education e intelligence sea alta (0.90 aproximadamente)*/

gen education=int(intelligence/10+invnormal(uniform())*1)
corr education intelligence

gen a=int(invnormal(uniform())*2+10)
gen b=int(invnormal(uniform())*1+5)
gen u=int(invnormal(uniform())*1+7)
gen wage=3*intelligence+a+2*b+u

* Armar dos regresiones para comparar
reg wage intelligence a b
predict y_hat_1

* Guardar la regresión ols11
est store ols11

*Cambiar varianza del error

replace u=int(invnormal(uniform())*5+7)
replace wage=3*intelligence+a+2*b+u


*Tercera regresión
reg wage intelligence a b
predict y_hat_3

est store ols13

*Comparar ambas regresiones

esttab ols11 ols13
suest ols11 ols13

esttab ols11 ols13 using "$output/EJ1_2.tex", replace se stats(N r2, labels("Observations" "R-squared"))

* 1.3
set seed 69
replace intelligence=int(invnormal(uniform())*50+100)

reg wage intelligence a b
predict y_hat_4

est store ols14

esttab ols11 ols14
suest ols11 ols14

esttab ols11 ols14 using "$output/EJ1_3.tex", replace se stats(N r2, labels("Observations" "R-squared"))

* 1.6

reg wage intelligence education a b 
predict y_hat_5

br wage y_hat_1 y_hat_5

* 1.7

replace intelligence = intelligence+100 in 1 

reg wage intelligence a b 
predict y_hat_6

est store ols16

esttab ols11 ols16
suest ols11 ols16

esttab ols11 ols16 using "$output/EJ1_7.tex", replace se stats(N r2, labels("Observations" "R-squared"))

gen c=int(invnormal(uniform())*1+7)

set seed 69
replace intelligence=int(invnormal(uniform())*20+100)
replace intelligence=intelligence+c

reg wage intelligence a b
predict y_hat_7

est store ols17

esttab ols11 ols17
suest ols11 ols17

esttab ols11 ols17 using "$output/EJ1_7_2.tex", replace se stats(N r2, labels("Observations" "R-squared"))

* 1.8

replace wage = wage+100 in 1 

reg wage intelligence a b
predict y_hat_8

est store ols18

esttab ols11 ols18
suest ols11 ols18

esttab ols11 ols18 using "$output/EJ1_8.tex", replace se stats(N r2, labels("Observations" "R-squared"))