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

global main "C:/Users/Milton/Documents/UDESA/Economía Aplicada/Problem-Sets/PS 3"
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
gen inteligencia=int(invnormal(uniform())*20+100)

*Generar mismo dataset

gen education2=int(inteligencia/10+invnormal(uniform())*1)
corr education2 inteligencia

gen a2=int(invnormal(uniform())*2+10)
gen b2=int(invnormal(uniform())*1+5)
gen u2=int(invnormal(uniform())*1+7)
gen wage2=3*inteligencia+a2+2*b2+u2

*Segunda regresión
reg wage2 inteligencia a2 b2
predict y_hat_2

est store ols12

*Comparar ambas regresiones

esttab ols11 ols12
suest ols11 ols12

*Exportar regresiones a tex REVISAR

esttab ols11 ols12 using "$output/Ej1_1.tex", se replace noobs noabbrev wrap ///
keep(treat, relax) style(tex) ///
cells(b(fmt(3) star) se(par fmt(3))) ///
stats(N r2, fmt(0 2) labels("N" "R-Squared")) 

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

gen u3=int(invnormal(uniform())*5+7)
gen wage3=3*intelligence+a+2*b+u3


*Tercera regresión
reg wage3 intelligence a b
predict y_hat_3

est store ols13

*Comparar ambas regresiones

esttab ols11 ols13
suest ols11 ols13



* Include education that is not in the Data Generating Process and it is highly correlated with intelligence. Note that coefficients and SE for a and b do not change, but the SE for the coefficient of intelligence changes, and a lot.
reg wage education intelligence a b
predict y_hat_2

* Store the results under the name ols12.
est store ols12

* They predict the same y_hat
corr y_hat_1 y_hat_2  

* Using the commands suest and esttab we can compare the results of the two ols exercise
esttab ols11 ols12
suest ols11 ols12
*suest ols11 ols12, robust

* Tests
test [ols11_mean]intelligence=[ols12_mean]intelligence
test [ols11_mean]a=[ols12_mean]a
test [ols11_mean]b=[ols12_mean]b


/* When multicollinearity is high, a small change of an observation can produce a large change on the coefficients. 
Let's see an example. */
reg wage education intelligence a b

* The command estimates store name saves the current (active) estimation results under the name ols21.
est store ols21

* We can replace the value of the first observation 
replace intelligence = intelligence+10 in 1 

* We now estimate the same equation and store the results under the name ols22.
reg wage education intelligence a b
est store ols22

* Using the commands suest and esttab we can compare the results of the two ols exercise
esttab ols21 ols22
suest ols21 ols22

* Tests
test [ols21_mean]intelligence=[ols22_mean]intelligence
test [ols21_mean]a=[ols22_mean]a
test [ols21_mean]b=[ols22_mean]b

* All coefficients are significantly different between both regressions.


