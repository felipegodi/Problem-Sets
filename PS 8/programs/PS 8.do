/*******************************************************************************
                         Semana 9: Control sintético

                          Universidad de San Andrés
                              Economía Aplicada
							       2022							           
*******************************************************************************/
*      Bronstein         García Vassallo            López             Riottini
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

cd "$output"* 

* 1) Freire, Danilo (2018)
*==============================================================================*

use "$input\Datos_PS8\homicides-sp-synth-master\data\homicide-rates.csv", clear

import delimited "$main\input\Datos_PS8\homicides-sp-synth-master\data\homicide-rates.csv", delimiter(comma) encoding(UTF-8) clear

drop v24

