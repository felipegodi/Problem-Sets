/*******************************************************************************
                   Semana 4: Fuentes de sesgo e imprecisión 

                          Universidad de San Andrés
                              Economía Aplicada
							                      2022							           
*******************************************************************************/
      Bronstein         García Vasallo            Lopez             Riottini
/*******************************************************************************
Este archivo sigue la siguiente estructura:

0) Configurar el entorno

1) Multicolinearidad

2) Ejemplo ficticio de variable omitida

*******************************************************************************/


* 0) Configurar el entorno
*==============================================================================*

global main "C:\Users\Milton\Documents\UDESA\Economía Aplicada\Problem-Sets\PS 3"
global input "$main/input"
global output "$main/output"

cd "$main"

* 1) Multicolinearidad
*==============================================================================*

* Usamos un ejemplo ficticio

clear
set obs 100
set seed 1234
gen intelligence=int(invnormal(uniform())*20+100)

/* We set the standard error of this variable so the correlation between education and intelligence is high (0.90 approximate).*/

gen education=int(intelligence/10+invnormal(uniform())*1)
corr education intelligence

gen a=int(invnormal(uniform())*2+10)
gen b=int(invnormal(uniform())*1+5)
gen u=int(invnormal(uniform())*1+7)
gen wage=3*intelligence+a+2*b+u

* Two different regressions
reg wage intelligence a b
predict y_hat_1

* The command estimates est store saves the current (active) estimation results.
est store ols11

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


