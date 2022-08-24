/*******************************************************************************
*                             ECONOMIA APLICADA                                *
*                               PROBLEM SET 2                                  *
*           BRONSTEIN, GARCIA VASSALLO, LOPEZ MOSKOVITS Y RIOTTINI             *
*******************************************************************************/


* Source: https://www.aeaweb.org/articles?id=10.1257/app.20200204


/*******************************************************************************
Este archivo sigue la siguiente estructura:

0) Set up environment and globals

1) Regressions

*******************************************************************************/



* 0) Set up environment
*==============================================================================*

gl main "C:\Users\felip\Documents\UdeSA\Maestría\Aplicada\Problem-Sets\PS 2"
gl input "$main/input"
gl output "$main/output"

* Open data set

use "$input/measures.dta", clear 

* Global with control variables

global covs_eva	"male i.eva_fu" 
global covs_ent	"male i.ent_fu"



* 1) Regressions

label var b_tot_cog1_st "Bayley: Cognitive"
label var b_tot_lr1_st "Bayley: Receptive language"
label var b_tot_le1_st "Bayley: Expressive language"
label var b_tot_mf1_st "Bayley: Fine motor"
label var mac_words1_st "MacArthur: Words the child can say"
label var mac_phrases1_st "MacArthur: Complex phrases the child can say"
label var bates_difficult1_st "ICQ: Difficult (-)"
label var bates_unsociable1_st "ICQ: Unsociable (-)"
label var bates_unstoppable1_st "ICQ: Unstoppable (-)"
label var roth_inhibit1_st "ECBQ: Inhibitory control"
label var roth_attention1_st "ECBQ: Attentional focusing"
label var fci_play_mat_type1_st "FCI: N° of types of play materials"
label var Npaintbooks1_st "FCI: N° of coloring and drawing books"
label var Nthingsmove1_st "FCI: N° of toys to learn movement"
label var Ntoysshape1_st "FCI: N° of toys to learn shapes"
label var Ntoysbought1_st "FCI: N° of shop-bought toys"
label var fci_play_act1_st "FCI: N° of types of play activities in last 3 days"
label var home_stories1_st "FCI: N° of times told a story to child in last 3 days"
label var home_read1_st "FCI: N° of times read to child in last 3 days"
label var home_toys1_st "N° of times played with toys in last 3 days"
label var home_name1_st "N° of times named things to child in last 3 days"

*==============================================================================*

******************************************************************************* 
* PANEL A (Child's cognitive skills at follow up) 
******************************************************************************* 
eststo clear
local bayley "b_tot_cog b_tot_lr b_tot_le b_tot_mf"
foreach y of local bayley{
local append append 
if "`y'"=="b_tot_cog" local append replace 
	cap drop V*
	eststo: reg `y'1_st treat `y'0_st $covs_eva , cluster(cod_dane)
} 

local macarthur "mac_words mac_phrases"
foreach y of local macarthur{
	cap drop V*
	eststo: reg `y'1_st treat mac_words0_st $covs_ent , cluster(cod_dane)
}

cap gen cognitive=(b_tot_cog1_st + b_tot_lr1_st + b_tot_le1_st + b_tot_mf1_st + mac_words1_st + mac_phrases1_st)/6
label var cognitive "Cognitive factor"

eststo: reg cognitive treat b_tot_cog0_st b_tot_lr0_st b_tot_le0_st b_tot_mf0_st mac_words0_st $covs_eva $covs_ent , cluster(cod_dane)

*esttab using "$output/Tabla 2_1.tex", se replace label noobs noabbrev wrap ///
*keep(treat, relax) style(tex) ///
*cells(b(fmt(3) star) se(par fmt(3))) ///
*stats(N r2, fmt(0 2) labels("N" "R-Squared"))

******************************************************************************* 
* PANEL B (Child's socio-emotional skills at follow up) 
******************************************************************************* 
* Descomentar para tener solo esta parte
*eststo clear

local bates "bates_difficult bates_unsociable bates_unstoppable" 
foreach y of local bates{
	cap drop V*
	eststo: reg `y'1_st treat `y'0_st $covs_ent, cl(cod_dane)
} 

local roth "roth_inhibit roth_attention" 
foreach y of local roth{
	cap drop V*
	eststo: reg `y'1_st treat bates_difficult0_st $covs_ent , cluster(cod_dane)
} 

cap gen socioe=(bates_difficult1_st + bates_unsociable1_st + bates_unstoppable1_st + roth_inhibit1_st + roth_attention1_st)/5
label var socioe "Socio-emotional factor"

eststo: reg socioe treat bates_difficult0_st bates_unsociable0_st bates_unstoppable0_st $covs_ent , cluster(cod_dane)

*esttab using "$output/Tabla 2_2.tex", se replace label noobs noabbrev ///
*keep(treat, relax) ///
*cells(b(fmt(3) star) se(par fmt(3))) ///
*stats(N r2, fmt(0 2) labels("N" "R-Squared"))

******************************************************************************* 
* PANEL C (Material investments)  
******************************************************************************* 
* Descomentar para tener solo esta parte
*eststo clear

local fcimat "fci_play_mat_type Npaintbooks Nthingsmove Ntoysshape Ntoysbought"
foreach y of local fcimat{
	cap drop V*
	eststo: reg `y'1_st treat fci_play_mat_type0_st $covs_ent , cluster(cod_dane)
}

cap gen material=(fci_play_mat_type1_st + Npaintbooks1_st + Nthingsmove1_st + Ntoysshape1_st + Ntoysbought1_st)/5
label var material "Material investment factor"

eststo: reg material treat fci_play_mat_type0_st $covs_ent , cluster(cod_dane)

*esttab using "$output/Tabla 2_3.tex", se replace label noobs noabbrev ///
*keep(treat, relax) ///
*cells(b(fmt(3) star) se(par fmt(3))) ///
*stats(N r2, fmt(0 2) labels("N" "R-Squared"))

******************************************************************************* 
* PANEL D (Time investments)  
******************************************************************************* 
* Descomentar para tener solo esta parte
*eststo clear

local fcitime "fci_play_act home_stories home_read home_toys home_name"
foreach y of local fcitime{
	cap drop V*
	eststo: reg `y'1_st treat fci_play_act0_st $covs_ent , cluster(cod_dane)
} 

cap gen time=(fci_play_act1_st + home_stories1_st + home_read1_st + home_toys1_st + home_name1_st)/5
label var time "Time investment factor"

eststo: reg time treat fci_play_act0_st $covs_ent , cluster(cod_dane)

*esttab using "$output/Tabla 2_4.tex", se replace label noobs noabbrev ///
*keep(treat, relax) ///
*cells(b(fmt(3) star) se(par fmt(3))) ///
*stats(N r2, fmt(0 2) labels("N" "R-Squared"))

esttab using "$output/Tabla 2.tex", se replace label noobs noabbrev ///
keep(treat, relax) ///
cells(b(fmt(3) star) se(par fmt(3))) ///
stats(N r2, fmt(0 2) labels("N" "R-Squared"))