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

*******************************************************************************
* CORRECTIONS
*******************************************************************************

eststo clear

scalar hyp=6

scalar signif=0.05

*******************************************************************************
* Holm correction for first part
*******************************************************************************

scalar i = 1
mat p_values=J(6,1,.)
local bayley "b_tot_cog b_tot_lr b_tot_le b_tot_mf"
foreach y of local bayley{
local append append 
if "`y'"=="b_tot_cog" local append replace 
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_eva , cluster(cod_dane)
	eststo: test treat = 0
	mat p_values[i,1]=r(p)
scalar i = i + 1
} 

local macarthur "mac_words mac_phrases"
foreach y of local macarthur{
	cap drop V*
	reg `y'1_st treat mac_words0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	mat p_values[i,1]=r(p)
scalar i = i + 1
}

preserve
clear
svmat p_values
gen outcome = _n
rename p_values1 pval
save "$output/pvals1.dta", replace
sort pval

gen alpha_corr=signif/(hyp+1-_n)

sort outcome
save "$output/holmqvals1.dta", replace
restore

mat q_values = [0.0083333, 0.01, 0.05, 0.0166667, 0.0125, 0.025]

*******************************************************************************
* Benjamini, Krieger and Yekutieli correction for first part
*******************************************************************************

**** Use Michael Anderson's code for sharpened q-values
preserve

use "$output/pvals1.dta", clear
version 10
set more off

* Collect the total number of p-values tested
quietly sum pval
local totalpvals = r(N)

* Sort the p-values in ascending order and generate a variable that codes each p-value's rank
quietly gen int original_sorting_order = _n
quietly sort pval
quietly gen int rank = _n if pval~=.

* Set the initial counter to 1 
local qval = 1

* Generate the variable that will contain the BKY (2006) sharpened q-values
gen bky06_qval = 1 if pval~=.

* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.

while `qval' > 0 {
	* First Stage
	* Generate the adjusted first stage q level we are testing: q' = q/1+q
	local qval_adj = `qval'/(1+`qval')
	* Generate value q'*r/M
	gen fdr_temp1 = `qval_adj'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q'*r/M
	gen reject_temp1 = (fdr_temp1>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank1 = reject_temp1*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected1 = max(reject_rank1)

	* Second Stage
	* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
	local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))
	* Generate value q_2st*r/M
	gen fdr_temp2 = `qval_2st'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q_2st*r/M
	gen reject_temp2 = (fdr_temp2>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank2 = reject_temp2*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected2 = max(reject_rank2)

	* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
	replace bky06_qval = `qval' if rank <= total_rejected2 & rank~=.
	* Reduce q by 0.001 and repeat loop
	drop fdr_temp* reject_temp* reject_rank* total_rejected*
	local qval = `qval' - .001
}
	

quietly sort original_sorting_order
pause off
set more on

display "Code has completed."
display "Benjamini Krieger Yekutieli (2006) sharpened q-vals are in variable 'bky06_qval'"
display	"Sorting order is the same as the original vector of p-values"

keep outcome pval bky06_qval
save "$output/sharpenedqvals1.dta", replace

restore

mat q_values_t = [0.001, 0.018, 0.508, 0.29, 0.29, 0.338]

*******************************************************************************
* Bonferroni Correction and export all corrections for first part
*******************************************************************************

eststo clear
scalar i = 1
local bayley "b_tot_cog b_tot_lr b_tot_le b_tot_mf"
foreach y of local bayley{
local append append 
if "`y'"=="b_tot_cog" local append replace 
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_eva , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value=r(p)
	estadd scalar bon_p_value=min(1,r(p)*hyp)
	estadd scalar holm_p_value=q_values[1,i]
	estadd scalar bky_p_value=q_values_t[1,i]
scalar i = i + 1
} 

local macarthur "mac_words mac_phrases"
foreach y of local macarthur{
	cap drop V*
	reg `y'1_st treat mac_words0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value=r(p)
	estadd scalar bon_p_value=min(1,r(p)*hyp)
	estadd scalar holm_p_value=q_values[1,i]
	estadd scalar bky_p_value=q_values_t[1,i]
scalar i = i + 1
}

esttab using "$output/Tabla 2_1_corregida.tex", p se replace label noobs ///
keep(treat, relax) noabbrev ///
cells(b(fmt(3) star) se(par fmt(3))) ///
stats(p_value bon_p_value holm_p_value bky_p_value blank N r2, fmt(3 3 3 3 0 2) labels("P-value" "Bonf p-value" "Holm p_value" "BKY p_value"  " "  "Number of Observations" "R-Squared"))

*******************************************************************************
* Holm for second part
*******************************************************************************

eststo clear

scalar hyp=5

scalar signif=0.05

scalar i = 1
mat p_values=J(5,1,.)
local bates "bates_difficult bates_unsociable bates_unstoppable" 
foreach y of local bates{
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_ent, cl(cod_dane)
	eststo: test treat = 0
	mat p_values[i,1]=r(p)
scalar i = i + 1
} 

local roth "roth_inhibit roth_attention" 
foreach y of local roth{
	cap drop V*
	reg `y'1_st treat bates_difficult0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	mat p_values[i,1]=r(p)
scalar i = i + 1
} 

preserve
clear
svmat p_values
gen outcome = _n
rename p_values1 pval
save "$output/pvals2.dta", replace
sort pval

gen alpha_corr=signif/(hyp+1-_n)

sort outcome
save "$output/holmqvals2.dta", replace
restore

mat q_values = [0.01, 0.0166667, 0.025, 0.05, 0.0125]


*******************************************************************************
* Benjamini, Krieger and Yekutieli correction for second part
*******************************************************************************

eststo clear
**** Now use Michael Anderson's code for sharpened q-values
preserve

use "$output/pvals2.dta", clear
version 10
set more off

* Collect the total number of p-values tested
quietly sum pval
local totalpvals = r(N)

* Sort the p-values in ascending order and generate a variable that codes each p-value's rank
quietly gen int original_sorting_order = _n
quietly sort pval
quietly gen int rank = _n if pval~=.

* Set the initial counter to 1 
local qval = 1

* Generate the variable that will contain the BKY (2006) sharpened q-values
gen bky06_qval = 1 if pval~=.

* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.

while `qval' > 0 {
	* First Stage
	* Generate the adjusted first stage q level we are testing: q' = q/1+q
	local qval_adj = `qval'/(1+`qval')
	* Generate value q'*r/M
	gen fdr_temp1 = `qval_adj'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q'*r/M
	gen reject_temp1 = (fdr_temp1>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank1 = reject_temp1*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected1 = max(reject_rank1)

	* Second Stage
	* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
	local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))
	* Generate value q_2st*r/M
	gen fdr_temp2 = `qval_2st'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q_2st*r/M
	gen reject_temp2 = (fdr_temp2>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank2 = reject_temp2*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected2 = max(reject_rank2)

	* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
	replace bky06_qval = `qval' if rank <= total_rejected2 & rank~=.
	* Reduce q by 0.001 and repeat loop
	drop fdr_temp* reject_temp* reject_rank* total_rejected*
	local qval = `qval' - .001
}
	

quietly sort original_sorting_order
pause off
set more on

display "Code has completed."
display "Benjamini Krieger Yekutieli (2006) sharpened q-vals are in variable 'bky06_qval'"
display	"Sorting order is the same as the original vector of p-values"

keep outcome pval bky06_qval
save "$output/sharpenedqvals2.dta", replace

restore

mat q_values_t = [0.517, 0.744, 0.744, 1, 0.517]

*******************************************************************************
* Bonferroni Correction and export all corrections for second part
*******************************************************************************

eststo clear
scalar i = 1
local bates "bates_difficult bates_unsociable bates_unstoppable" 
foreach y of local bates{
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_ent, cl(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value=r(p)
	estadd scalar bon_p_value=min(1,r(p)*hyp)
	estadd scalar holm_p_value=q_values[1,i]
	estadd scalar bky_p_value=q_values_t[1,i]	
scalar i = i + 1
} 

local roth "roth_inhibit roth_attention" 
foreach y of local roth{
	cap drop V*
	reg `y'1_st treat bates_difficult0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value=r(p)
	estadd scalar bon_p_value=min(1,r(p)*hyp)
	estadd scalar holm_p_value=q_values[1,i]
	estadd scalar bky_p_value=q_values_t[1,i]
scalar i = i + 1
} 

esttab using "$output/Tabla 2_2_corregida.tex", p se replace label noobs ///
keep(treat, relax) noabbrev ///
cells(b(fmt(3) star) se(par fmt(3))) ///
stats(p_value bon_p_value holm_p_value bky_p_value blank N r2, fmt(3 3 3 3 0 2) labels("P-value" "Bonf p-value" "Holm p_value" "BKY p_value"  " "  "Number of Observations" "R-Squared"))

*******************************************************************************
* Holm for third part
*******************************************************************************

eststo clear

scalar hyp=5

scalar signif=0.05

scalar i = 1
mat p_values=J(5,1,.)
local fcimat "fci_play_mat_type Npaintbooks Nthingsmove Ntoysshape Ntoysbought"
foreach y of local fcimat{
	cap drop V*
	reg `y'1_st treat fci_play_mat_type0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	mat p_values[i,1]=r(p)
scalar i = i + 1
} 

preserve
clear
svmat p_values
gen outcome = _n
rename p_values1 pval
save "$output/pvals3.dta", replace
sort pval

gen alpha_corr=signif/(hyp+1-_n)

sort outcome
save "$output/holmqvals3.dta", replace
restore

mat q_values = [0.0125, 0.0166667, 0.025, 0.01, 0.05]


*******************************************************************************
* Benjamini, Krieger and Yekutieli correction for third part
*******************************************************************************

eststo clear
**** Now use Michael Anderson's code for sharpened q-values
preserve

use "$output/pvals3.dta", clear
version 10
set more off

* Collect the total number of p-values tested
quietly sum pval
local totalpvals = r(N)

* Sort the p-values in ascending order and generate a variable that codes each p-value's rank
quietly gen int original_sorting_order = _n
quietly sort pval
quietly gen int rank = _n if pval~=.

* Set the initial counter to 1 
local qval = 1

* Generate the variable that will contain the BKY (2006) sharpened q-values
gen bky06_qval = 1 if pval~=.

* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.

while `qval' > 0 {
	* First Stage
	* Generate the adjusted first stage q level we are testing: q' = q/1+q
	local qval_adj = `qval'/(1+`qval')
	* Generate value q'*r/M
	gen fdr_temp1 = `qval_adj'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q'*r/M
	gen reject_temp1 = (fdr_temp1>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank1 = reject_temp1*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected1 = max(reject_rank1)

	* Second Stage
	* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
	local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))
	* Generate value q_2st*r/M
	gen fdr_temp2 = `qval_2st'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q_2st*r/M
	gen reject_temp2 = (fdr_temp2>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank2 = reject_temp2*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected2 = max(reject_rank2)

	* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
	replace bky06_qval = `qval' if rank <= total_rejected2 & rank~=.
	* Reduce q by 0.001 and repeat loop
	drop fdr_temp* reject_temp* reject_rank* total_rejected*
	local qval = `qval' - .001
}
	

quietly sort original_sorting_order
pause off
set more on

display "Code has completed."
display "Benjamini Krieger Yekutieli (2006) sharpened q-vals are in variable 'bky06_qval'"
display	"Sorting order is the same as the original vector of p-values"

keep outcome pval bky06_qval
save "$output/sharpenedqvals3.dta", replace

restore

mat q_values_t = [0.002, 0.029, 0.293, 0.001, 0.429]

*******************************************************************************
* Bonferroni Correction and export all corrections for third part
*******************************************************************************

eststo clear
scalar i = 1
local fcimat "fci_play_mat_type Npaintbooks Nthingsmove Ntoysshape Ntoysbought"
foreach y of local fcimat{
	cap drop V*
	reg `y'1_st treat fci_play_mat_type0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value=r(p)
	estadd scalar bon_p_value=min(1,r(p)*hyp)
	estadd scalar holm_p_value=q_values[1,i]
	estadd scalar bky_p_value=q_values_t[1,i]	
scalar i = i + 1
} 


esttab using "$output/Tabla 2_3_corregida.tex", p se replace label noobs ///
keep(treat, relax) noabbrev ///
cells(b(fmt(3) star) se(par fmt(3))) ///
stats(p_value bon_p_value holm_p_value bky_p_value blank N r2, fmt(3 3 3 3 0 2) labels("P-value" "Bonf p-value" "Holm p_value" "BKY p_value"  " "  "Number of Observations" "R-Squared"))

*******************************************************************************
* Holm for fourth part
*******************************************************************************

eststo clear

scalar hyp=5

scalar signif=0.05

scalar i = 1
mat p_values=J(5,1,.)
local fcitime "fci_play_act home_stories home_read home_toys home_name"
foreach y of local fcitime{
	cap drop V*
	reg `y'1_st treat fci_play_act0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	mat p_values[i,1]=r(p)
scalar i = i + 1
} 

preserve
clear
svmat p_values
gen outcome = _n
rename p_values1 pval
save "$output/pvals4.dta", replace
sort pval

gen alpha_corr=signif/(hyp+1-_n)

sort outcome
save "$output/holmqvals4.dta", replace
restore

mat q_values = [0.0125, 0.05, 0.01, 0.0166667, 0.025]


*******************************************************************************
* Benjamini, Krieger and Yekutieli correction for fourth part
*******************************************************************************

eststo clear
**** Now use Michael Anderson's code for sharpened q-values
preserve

use "$output/pvals4.dta", clear
version 10
set more off

* Collect the total number of p-values tested
quietly sum pval
local totalpvals = r(N)

* Sort the p-values in ascending order and generate a variable that codes each p-value's rank
quietly gen int original_sorting_order = _n
quietly sort pval
quietly gen int rank = _n if pval~=.

* Set the initial counter to 1 
local qval = 1

* Generate the variable that will contain the BKY (2006) sharpened q-values
gen bky06_qval = 1 if pval~=.

* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.

while `qval' > 0 {
	* First Stage
	* Generate the adjusted first stage q level we are testing: q' = q/1+q
	local qval_adj = `qval'/(1+`qval')
	* Generate value q'*r/M
	gen fdr_temp1 = `qval_adj'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q'*r/M
	gen reject_temp1 = (fdr_temp1>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank1 = reject_temp1*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected1 = max(reject_rank1)

	* Second Stage
	* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
	local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))
	* Generate value q_2st*r/M
	gen fdr_temp2 = `qval_2st'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q_2st*r/M
	gen reject_temp2 = (fdr_temp2>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank2 = reject_temp2*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected2 = max(reject_rank2)

	* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
	replace bky06_qval = `qval' if rank <= total_rejected2 & rank~=.
	* Reduce q by 0.001 and repeat loop
	drop fdr_temp* reject_temp* reject_rank* total_rejected*
	local qval = `qval' - .001
}
	

quietly sort original_sorting_order
pause off
set more on

display "Code has completed."
display "Benjamini Krieger Yekutieli (2006) sharpened q-vals are in variable 'bky06_qval'"
display	"Sorting order is the same as the original vector of p-values"

keep outcome pval bky06_qval
save "$output/sharpenedqvals4.dta", replace

restore

mat q_values_t = [0.001, 0.005, 0.001, 0.003, 0.003]

*******************************************************************************
* Bonferroni Correction and export all corrections for fourth part
*******************************************************************************

eststo clear
scalar i = 1
local fcitime "fci_play_act home_stories home_read home_toys home_name"
foreach y of local fcitime{
	cap drop V*
	reg `y'1_st treat fci_play_act0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value=r(p)
	estadd scalar bon_p_value=min(1,r(p)*hyp)
	estadd scalar holm_p_value=q_values[1,i]
	estadd scalar bky_p_value=q_values_t[1,i]	
scalar i = i + 1
} 


esttab using "$output/Tabla 2_4_corregida.tex", p se replace label noobs ///
keep(treat, relax) noabbrev ///
cells(b(fmt(3) star) se(par fmt(3))) ///
stats(p_value bon_p_value holm_p_value bky_p_value blank N r2, fmt(3 3 3 3 0 2) labels("P-value" "Bonf p-value" "Holm p_value" "BKY p_value"  " "  "Number of Observations" "R-Squared"))
