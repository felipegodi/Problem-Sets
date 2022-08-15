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

* Me fijo los missings
mdesc

* Ordeno la data como pide el punto 4
order id site sex
gsort -totexpr

