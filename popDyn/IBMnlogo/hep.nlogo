; Model definition for a hep-DEB-structured population in a generalized stirred reactor for NetLogo 6.2.0
; Author: Bas Kooijman
; date: 2021/01/15

extensions [matrix]

; ==========================================================================================================================================
; ========================== DEFINITION OF PARAMETERS AND VARIABLES ========================================================================
; ==========================================================================================================================================

globals[
  tTC      ; (d,-), (n,2)-matrix of spline-knots with time, temperature correction factor
  tJX      ; (d,mol/d), (n,2)-matrix of spline-knots with time, food supply rate to the reactor
  eaLE     ; (-,d,cm,J), (n,4)-matrix of spline-knots with scaled reserve density, age and structural length at birth, initial reserve
  n_eaLE   ; -, number of rows of eaLE

  time     ; d, current time
  tTC_i    ; -, current lower row-index for tTC, so tTC(tTC_i,0) < time < tTC(tTC_i+1,0)
  TC       ; -, current temperature correction factor
  tJX_i    ; -, current lower row-index for tJX, so tJX(tJX_i,0) < time < tJX(tJX_i+1,0)
  JX       ; mol/d, current food supply rate to the reactor
  X        ; Mol, food density
  eaten    ; mol/d, food that is eaten
  r        ; 1/d, specific growth rate of individual
  p_C      ; J/d, reserve mobilisation rate
  spawn-number ;  #, list with positive number of eggs per female
  spawn-quality ; #, list with scaled reserve density at birth for laying female

  ; compound parameters
  K        ; Mol, half saturation coefficient for females
  K_male   ; Mol, half saturation coefficient for males (cannot be called K_m, since NetLogo makes no difference with k_M)
  J_XAm    ; mol/d.cm^2, max spec food intake rate for females
  J_XAmm   ; mol/d.cm^2, max spec food intake rate for males
  L_m      ; cm, max structural length for females
  L_mm     ; cm, max structural length for males
  E_m      ; J/cm^3, reserve capacity for females
  E_mm     ; J/cm^3, reserve capacity for males
  g        ; - , energy investment ratio for females
  g_m      ; - , energy investment ratio for males
  k_M      ; 1/d, somatic maintenance rate coefficient

  ; globals set through inputboxes (here just for presenting units and descriptions)
  ; t_R      ; d, time for imago's to lay all eggs
  ; h_B0b    ; 1/d, background hazard between 0 and b
  ; h_Bbp    ; 1/d, background hazard between b and p
  ; h_Bpi    ; 1/d, background hazard between p and i
  ; h_J      ; 1/d, hazard due to rejuvenation
  ; thin     ; 0 or 1, hazard for thinning. If 1 it changes in time for each turtle
  ; mu_X     ; J/mol, chemical potential of food
  ; F_m      ; L/d.cm^2, specific searching rate
  ; kap_X    ; -, digestion efficiency
  ; p_Am     ; J/d^.cm^2, max specific assimilation rate of females
  ; p_Amm    ; J/d^.cm^2, max specific assimilation rate of males
  ; v        ; cm/d, energy conductance
  ; p_M      ; J/d.cm^3, specific somatic maintenance
  ; E_G      ; J/cm^3, cost for structure
  ; k_J      ; 1/d, maturity maintenance rate coefficient
  ; k_JX     ; 1/d, rejuvenation rate
  ; h_a      ; 1/d^2, Weibull aging acceleration
  ; s_G      ; -, Gompertz, stress coefficient
  ; kap_G    ; -, growth efficiency
  ; kap_R    ; -, reproduction efficiency
  ; ome      ; -, specific contribution of reserve to wet weight
  ; E_Hb     ; J, maturity at birth
  ; E_Hp     ; J, maturity at puberty of females
  ; E_Hpm    ; J, maturity at puberty of males
]

; ------------------------------------------------------------------------------------------------------------------------------------------

turtles-own[
  a        ; d, age
  t_spawn  ; d, time since last spawning
  s_M      ; -, acceleration factor >= 1
  L        ; cm, structural length
  ee       ; -, scaled reserve density; DEB notation is e, but NetLogo takes this to be exponent
  E_H      ; J, maturity
  E_Hmax   ; J, max maturity reached
  E_R      ; J, reproduction buffer, but for imago's it becomes number of eggs
  q        ; 1/d^2, ageing acceleration
  h_age    ; 1/d, hazard rate due to aging
  h_thin   ; 1/d, hazard rate due to thinning
  h_rejuv  ; 1/d, hazard rate due to rejuvenation

  gender   ; -, 0 (female) 1 (male) 2 (female fresh imago) 3 (female initiated imago)
  a_b      ; d, age at birth at 20 C (set at creation)
  Ki       ; Mol, half saturation coefficient (female or male value)
  p_Ami    ; J/d.cm^2, max spec assimilation rate  (female or male value)
  J_XAmi   ; mol/d.cm^2, max spec food intake rate  (female or male value)
  E_Hpi    ; J, maturity at puberty  (female or male value)
  L_b      ; cm, structural length at birth
  L_mi     ; cm, max structural length  (female or male value)
  E_mi     ; J/cm^3, max reserve density  (female or male value)
  gi       ; -, energy investment ratio  (female or male value)
]

; ==========================================================================================================================================
; ========================== SETUP PROCEDURE FOR INITIAL CONDITIONS ========================================================================
; ==========================================================================================================================================

to setup

  clear-all
  file-close-all

  ; read matrix tJX with time, food supply
  set tJX (list) ; initiate list
  file-open "spline_JX.txt"    ; knots with time, food input into the reactor
  while [file-at-end? = false] [
    let row (list) ; empty list
    set row insert-item 0 row file-read ; t
    set row insert-item 1 row file-read ; JX
    set tJX lput row tJX ; new row is added to list
  ]
  file-close
  set tJX matrix:from-row-list tJX ; convert list to matrix
  set tJX_i 0 ; current row-index of tJX

  ; read matrix tTC with time, temperature correction factors
  set tTC (list) ; initiate list
  file-open "spline_TC.txt"    ; knots with time, temperature correction factor
  while [file-at-end? = false] [
    let row (list) ; empty list
    set row insert-item 0 row file-read ; t
    set row insert-item 1 row file-read ; TC
    set tTC lput row tTC ; new row is added to list
  ]
  file-close
  set tTC matrix:from-row-list tTC ; convert list to matrix
  set tTC_i 0 ; current row-index of tTC

  ; read matrix eaLE with embryo settings
  set eaLE (list) ; empty list
  file-open "eaLE.txt" ; knots with embryo settings
  while [file-at-end? = false] [
    let row (list) ; empty list
    set row insert-item 0 row file-read ; eb
    set row insert-item 1 row file-read ; ab
    set row insert-item 2 row file-read ; Lb
    set row insert-item 3 row file-read ; E0
    set eaLE lput row eaLE ; new row is added to list
  ]
  file-close
  set eaLE matrix:from-row-list eaLE ; convert list to matrix
  set n_eaLE item 0 matrix:dimensions eaLE ; number of rows in matrix eaLE

  ; read parameters from file
  if file-exists? "set_pars.txt" [
    file-open "set_pars.txt" ; parameter settings that overwrite inputboxes of graphical interface
    while [file-at-end? = false] [run file-read] ; set parameter-name, value
    file-close
  ]
  set X X_0 ; Mol, initial value for food density

  ; frequently-used compound-parameters
  set K p_Am / kap_X / mu_X / F_m       ;  Mol, half saturation coefficient for females
  set K_male p_Amm / kap_X / mu_X / F_m ;  Mol, half saturation coefficient for males
  set J_XAm p_Am / kap_X / mu_X         ;  mol/d.cm^2 max spec food intake rate for females
  set J_XAmm p_Amm / kap_X / mu_X       ;  mol/d.cm^2 max spec food intake rate for males
  set E_m p_Am / v                      ;  J/cm^3, reserve capacity for females
  set E_mm p_Amm / v                    ;  J/cm^3, reserve capacity for males
  set g E_G / E_m / kap                 ;  - , energy investment ratio for females
  set g_m E_G / E_mm / kap              ;  - , energy investment ratio for males
  set L_m kap * p_Am / p_M              ;  cm, max structural length for females
  set L_mm kap * p_Amm / p_M            ;  cm, max structural length for males
  set k_M p_M / E_G                     ;  1/d, somatic maintenance rate coefficient

  ; initiate output file tNL23W.txt
  if file-exists? "txNL23W.txt" [file-delete "txNL23W.txt"]
  file-open "txNL23W.txt"    ; append to an empty file

  create-turtles 1 [set-embryo 1 0] ; female embryo with e_b=1

  reset-ticks

end

; ==========================================================================================================================================
; ========================== GO PROCEDURE: RUNNING THE MODEL ===============================================================================
; ==========================================================================================================================================

to go

  set time ticks / tickRate ; d, time

  ; get current temperature correction factor
  if time > matrix:get tTC (tTC_i + 1) 0 and t_max < matrix:get tTC (tTC_i + 1) 0 [set tTC_i tTC_i + 1]
  let w (time - matrix:get tTC tTC_i 0) / (matrix:get tTC (tTC_i + 1) 0 - matrix:get tTC tTC_i 0)
  set TC w * matrix:get tTC (tTC_i + 1) 1 + (1  - w) * matrix:get tTC tTC_i 1

  ; get current food input into reactor
  if time > matrix:get tJX (tJX_i + 1) 0 and t_max < matrix:get tJX (tJX_i + 1) 0 [set tJX_i tJX_i + 1]
  set w (time - matrix:get tJX tJX_i 0) / (matrix:get tJX (tJX_i + 1) 0 - matrix:get tJX tJX_i 0)
  set JX w * matrix:get tJX (tJX_i + 1) 1 + (1  - w) * matrix:get tJX tJX_i 1

  ; birth
  ask turtles with [(a > a_b / TC) and (E_H = E_Hb)] [set E_H E_Hb + 0.0001] ; embryo becomes juvenile and starts feeding, growing, developing

  ; food density in the reactor
  set eaten 0 ; mol/d, initiate food disappearence rate
  ask turtles with [E_H > E_Hb] [set eaten eaten + TC * X / (X + Ki) * J_XAmi * L * L] ; Mol/d, food consumption
  set X X + (JX / V_X - h_X * X - eaten / V_X) / tickRate ; Mol, food density
  if X < 0 [set X 0] ; do not allow negative food

  ; state variables of turtles
  ask turtles with [E_H = E_Hb] [set a a + 1 / tickRate] ; d, age (only active role for embryos to trigger birth)
  ask turtles with [E_H > E_Hb] [
    if E_H < E_Hpi [set s_M L / L_b] ; -, acceleration factor
    set ee ee + (X / (X + Ki) - ee) * TC * s_M * v / L / tickRate ; -, scaled reserve density
    if ee > 1 [set ee 1] ; do not allow that ee exceeds 1
    if ee < 0 [set ee 0] ; do not allow that ee becomes negative
    ifelse ee >= L / L_mi / s_M
      [set r TC * s_M * v * (ee / L - 1 / L_mi / s_M) / (ee + gi)] ; 1/d, positive spec growth rate
      [set r TC * s_M * v * (ee / L - 1 / L_mi / s_M) / (ee + kap_G * gi)] ; 1/d, negative spec growth rate (shrinking)
    set L L + L * r / 3 / tickRate ; cm, structural length
    set p_C ee * E_mi * L * L * L * (TC * s_M * v / L - r) ; J/d, reserve mobilisation rate
    ifelse (1 - kap) * p_C >= TC * k_J * E_H
      [set E_H E_H + ((1 - kap) * p_C - TC * k_J * E_H) / tickRate] ; J, maturition
      [set E_H E_H - TC * k_JX * (E_H - (1 - kap) * p_C / k_J / TC) / tickRate] ; J, rejuvenation
    if E_H < E_Hmax [set E_Hmax E_H]
    if E_H > E_Hpi [
      set E_H E_Hpi ; J, do not allow maturity to exceed puberty level
      set E_Hmax E_Hpi ; J, keep both maturities equal
    ]
    if E_H < E_Hb [set E_H E_Hb] ; J, do not allow maturity to pass birth level during rejuvenation
    ifelse E_H < E_Hmax [set h_rejuv TC * h_J * (1 - (1 - kap) * p_C / k_J / E_Hmax)] [set h_rejuv 0] ; 1/d, hazard due to rejuvenation
    set q q + ((q * L * L * L / L_mi / L_mi / L_mi / s_M / s_M / s_M * s_G + TC * TC * h_a) * ee * (TC * s_M * v / L - r) - r * q) / tickRate ; 1/d^2, aging acceleration
    set h_age h_age + (q - r * h_age) / tickRate ; 1/d, aging hazard
    (ifelse (thin = 1) and (E_H < E_Hpi) [set h_thin r]  ; thinning during acceleration
    (thin = 1) and (E_H >= E_Hpi) [set h_thin r * 2 / 3] ; thinning after acceleration
    [set h_thin 0]) ; 1/d, hazard rate due to thinning
    if E_R / L / L / L > E_Rj [set gender 2] ; change female larva to fresh imago stage (males have E_R=0)
    if E_H = E_Hp and gender = 0 [ ; update reproduction buffer and time-since-spawning in adult females
      set E_R E_R + ((1 - kap) * p_C - TC * k_J * E_Hp) / tickRate ; J, reproduction buffer
      if E_R < 0 [set E_R 0] ; do not allow negative reprod buffer
    ]
  ]

  ; spawning events for female imago's which empty E_R in period t_R. When ready to spawn, gender becomes 2 and, when 2, it becomes 3
  set spawn-number (list)  ; create a list for egg numbers
  set spawn-quality (list) ; create a list for egg scaled reserve density at birth
  ask turtles with [gender = 2][ ; check fresh female imago's
    let E_0 get_E0 ee ; J, cost of egg
    set E_R floor(kap_R * E_R / E_0) ; #, number of eggs to spawn. Notice that E_R is now an integer, no longer energy
    set t_R t_R / E_R ; d, period between eggs. Notice that t_R changed from total egg-laying period  to time between eggs
    set gender 3 ; fresh female imago becomes initiated imago
    set t_spawn 0 
  ] 
  ask turtles with [(gender = 3) and (E_R > 0)] [ ; egg to spawn for initiated imago
    ifelse t_spawn > t_R [ 
      set spawn-number insert-item 0 spawn-number 1 ; prepend number of eggs to list
      set spawn-quality insert-item 0 spawn-quality ee ; prepend scaled reserve density to list
      set E_R E_R - 1 ; #, reduce eggs-to-spawn
      set t_spawn 0 ; d, reset time since last spawning
    ][set t_spawn t_spawn + 1 / tickRate]
  ]
  if length spawn-number > 0 [spawn spawn-number spawn-quality] ; create new turtles

  ; death events
  ask turtles with [E_H = E_Hb] [if h_B0b / tickRate > random-float 1 [ die ]]
  ask turtles with [(E_H > E_Hb) and (E_H < E_Hpi)] [if (h_Bbp + h_thin + h_age + h_rejuv) / tickRate > random-float 1 [ die ]]
  ask turtles with [E_H = E_Hpi] [if (h_Bpi + h_thin + h_age + h_rejuv) / tickRate > random-float 1 [ die ]]
  ask turtles with [L < L_b] [ die ]

  ; write daily population state to output matrix tNL23W.txt
  if ticks mod tickRate = 0 [ ; only at full days, not at each tick
    let totL 0
    let totL2 0
    let totL3 0
    let totW 0
    let totN count turtles with [E_H > E_Hb] ; #, number of post-natals
    ask turtles with [E_H > E_Hb] [
      set totL totL + L ; total structural length
      set totL2 totL2 + L * L ; total structural surface area
      set totL3 totL3 + L * L * L ; total structural volume
      set totW totW + L * L * L * (1 + ee * ome) ; total weight
    ]
    file-write time   ; d, time
    file-write X / K  ; -, scaled food density
    file-write totN   ; #,  total number of post-natals
    file-write totL   ; cm, total length of post-natals
    file-write totL2  ; cm, total length^2 of post-natals
    file-write totL3  ; cm, total length^3 of post-natals
    file-write totW   ; g,  total weight of post-natals
    file-print " "    ; new line
  ]

  if count turtles = 0 or time > t_max [
    file-close-all
    stop
  ]

  tick

end

; ==========================================================================================================================================
; ========================== PROCEDURES to interpolate in eaLE table for embryo-settings  ==================================================
; ==========================================================================================================================================

to-report get_ab [eei]
  (ifelse eei = 1 [
    report  matrix:get eaLE (n_eaLE - 1) 1
  ] eei <= matrix:get eaLE 0 0 [
    report  matrix:get eaLE 0 1
  ][
    let i 0
    while [matrix:get eaLE i 0 < eei] [set i i + 1]
    let w (eei - matrix:get eaLE (i - 1) 0) / (matrix:get eaLE i 0 - matrix:get eaLE (i - 1) 0)
    report w * matrix:get eaLE i 1 + (1  - w) * matrix:get eaLE  (i - 1) 1 ; d, age at birth
  ])
end

to-report get_Lb [eei]
  (ifelse eei = 1 [
    report  matrix:get eaLE (n_eaLE - 1) 2
  ] eei <= matrix:get eaLE 0 0 [
    report  matrix:get eaLE 0 2
  ][
    let i 0
    while [matrix:get eaLE i 0 < eei] [set i i + 1]
    let w (eei - matrix:get eaLE (i - 1) 0) / (matrix:get eaLE i 0 - matrix:get eaLE (i - 1) 0)
    report w * matrix:get eaLE i 2 + (1  - w) * matrix:get eaLE  (i - 1) 2 ; cm, structural length at birth
  ])
end

to-report get_E0 [eei]
  (ifelse eei = 1 [
    report  matrix:get eaLE (n_eaLE - 1) 3
  ] eei <= matrix:get eaLE 0 0 [
    report  matrix:get eaLE 0 3
  ][
    let i 0
    while [matrix:get eaLE i 0 < eei] [set i i + 1]
    let w (eei - matrix:get eaLE (i - 1) 0) / (matrix:get eaLE i 0 - matrix:get eaLE (i - 1) 0)
    report w * matrix:get eaLE i 3 + (1  - w) * matrix:get eaLE  (i - 1) 3 ; J, initial reserve
  ])
end

; ==========================================================================================================================================
; ========================== PROCEDURE to set embryo-states  ==============================================================================
; ==========================================================================================================================================

to set-embryo [eei genderi]
  set a 0 ; d, age
  set a_b get_ab eei ; d, age at birth at 20 C (used to trigger birth)
  set t_spawn 0 ; d, time since last spawning (only plays an active role in adult females)
  set s_M 1     ; -, acceleration factor 
  set ee eei ; -, scaled reserve density at birth (starts to change after birth)
  set L get_Lb eei ; cm, structural length (starts to change after birth)
  set E_H E_Hb ; J, maturity (starts to change after birth)
  set E_Hmax E_Hb ; J, max maturity (starts to change after birth)
  set E_R 0 ; J, empty reproduction buffer (only plays an active role in adult females)
  set q 0 ; 1/d^2, aging acceleration (starts to change after birth)
  set h_age 0 ; 1/d, no aging hazard (starts to change after birth)
  set h_thin 0 ; 1/d, no thinning (starts to change after birth if thin = 1)
  set h_rejuv 0 ; 1/d, no rejuvenation hazard (might change after birth)

  set gender genderi
  ifelse gender = 0 [ ; female setting
    set Ki K ; Mol, half saturation coefficient
    set p_Ami p_Am ; J/d.cm^2, max spec assim rate
    set J_XAmi J_XAm ; mol/d.cm^2, max spec food intake rate
    set E_Hpi E_Hp ; J, maturity at puberty
    set L_b L ; cm, structural length at birth
    set L_mi L_m ; cm, max structural length
    set E_mi E_m ; J/cm^3, max reserve density
    set gi g ; -, energy investment ratio
  ][ ; male setting
    set Ki K_male ; Mol, half saturation coefficient
    set p_Ami p_Amm ; J/d.cm^2, max spec assim rate
    set J_XAmi J_XAmm ; mol/d.cm^2, max spec food intake rate
    set E_Hpi E_Hpm ; J, maturity at puberty
    set L_b L ; cm, structural length at birth
    set L_mi L_mm ; cm, max structural length
    set E_mi E_mm ; J/cm^3, max reserve density
    set gi g_m ; -, energy investment ratio
  ]
end

; ==========================================================================================================================================
; ========================== PROCEDURE for spawning  =======================================================================================
; ==========================================================================================================================================

to spawn [list-n list-eb] ; both lists should be eqally long
  let n length list-n
  let i 0
  let gendere 0 ; gender of new embryo
  while [i < n] [
    create-turtles item i list-n [
      ifelse fProb > random-float 1 [set gendere 0] [set gendere 1]
      set-embryo (item i list-eb) gendere
    ]
    set i i + 1
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
50
30
83
64
-1
-1
25.0
1
10
1
1
1
0
1
1
1
0
0
0
0
1
1
1
ticks
30.0

BUTTON
170
30
280
80
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
290
30
400
80
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
410
30
520
90
tickRate
0
1
0
Number

INPUTBOX
50
90
160
150
t_max
0
1
0
Number

INPUTBOX
170
90
280
150
X_0
0
1
0
Number

INPUTBOX
290
90
400
150
V_X
0
1
0
Number

INPUTBOX
410
90
520
150
mu_X
0
1
0
Number

INPUTBOX
50
150
160
210
h_X
0
1
0
Number

INPUTBOX
170
150
280
210
h_B0b
0
1
0
Number

INPUTBOX
290
150
400
210
h_Bbp
0
1
0
Number

INPUTBOX
410
150
520
210
h_Bpi
0
1
0
Number

INPUTBOX
50
210
160
270
thin
0
1
0
Number

INPUTBOX
170
210
280
270
h_J
0
1
0
Number

INPUTBOX
290
210
400
270
h_a
0
1
0
Number

INPUTBOX
410
210
520
270
s_G
0
1
0
Number

INPUTBOX
50
270
160
330
E_Hb
0
1
0
Number

INPUTBOX
170
270
280
330
E_Hp
0
1
0
Number

INPUTBOX
290
270
400
330
E_Hpm
0
1
0
Number

INPUTBOX
410
270
520
330
E_Rj
0
1
0
Number

INPUTBOX
50
330
160
390
fProb
0
1
0
Number

INPUTBOX
170
330
280
390
kap
0
1
0
Number

INPUTBOX
290
330
400
390
kap_X
0
1
0
Number

INPUTBOX
410
330
520
390
kap_G
0
1
0
Number

INPUTBOX
50
390
160
450
kap_R
0
1
0
Number

INPUTBOX
170
390
280
450
t_R
0
1
0
Number

INPUTBOX
290
390
400
450
F_m
0
1
0
Number

INPUTBOX
410
390
520
450
p_Am
0
1
0
Number

INPUTBOX
50
450
160
510
p_Amm
0
1
0
Number

INPUTBOX
170
450
280
510
v
0
1
0
Number

INPUTBOX
290
450
400
510
p_M
0
1
0
Number

INPUTBOX
410
450
520
510
k_J
0
1
0
Number

INPUTBOX
50
510
160
570
k_JX
0
1
0
Number

INPUTBOX
170
510
280
570
E_G
0
1
0
Number

INPUTBOX
290
510
400
560
ome
0
1
0
Number

PLOT
535
208
1218
358
number of post natals
time, d
#
0.0
10.0
0.0
5
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy time count turtles with [E_H > E_Hb]"

PLOT
538
391
1223
541
food density
time, d
Mol
0.0
10.0
0.0
0.1
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy time X"

PLOT
534
28
1218
178
numbers in stage classes
time, d
#
0.0
10.0
0.0
5
true
true
"" ""
PENS
"juvFemales" 1.0 0 -1069655 true "" "plotxy time count turtles with [(E_H > E_Hb) and (E_H < E_Hp) and (gender = 0)]"
"adFemales" 1.0 0 -2674135 true "" "plotxy time count turtles with [(E_H = E_Hp) and ((gender = 0) or (gender > 1))]"
"juvMales" 1.0 0 -5516827 true "" "plotxy time count turtles with [(E_H > E_Hb) and (E_H < E_Hpm) and (gender = 1)]"
"adMales" 1.0 0 -13791810 true "" "plotxy time count turtles with [(E_H = E_Hpm) and (gender = 1)]"

TEXTBOX
480
35
520
50
1/d
11
0.0
1

TEXTBOX
120
95
160
110
d
11
0.0
1

TEXTBOX
240
95
280
110
Mol
11
0.0
1

TEXTBOX
360
95
400
110
L
11
0.0
1

TEXTBOX
480
95
520
110
J/mol
11
0.0
1

TEXTBOX
120
155
160
170
1/d
11
0.0
1

TEXTBOX
240
155
280
170
1/d
11
0.0
1

TEXTBOX
360
155
400
170
1/d
11
0.0
1

TEXTBOX
480
155
520
170
1/d
11
0.0
1

TEXTBOX
120
215
160
230
-
11
0.0
1

TEXTBOX
240
215
280
230
1/d
11
0.0
1

TEXTBOX
360
215
400
230
1/d2
11
0.0
1

TEXTBOX
480
215
520
230
-
11
0.0
1

TEXTBOX
120
275
160
290
J
11
0.0
1

TEXTBOX
240
275
280
290
J
11
0.0
1

TEXTBOX
360
275
400
290
J
11
0.0
1

TEXTBOX
480
275
520
290
J/cm3
11
0.0
1

TEXTBOX
120
335
150
350
-
11
0.0
1

TEXTBOX
240
335
280
350
-
11
0.0
1

TEXTBOX
360
335
400
350
-
11
0.0
1

TEXTBOX
480
335
520
350
-
11
0.0
1

TEXTBOX
120
395
160
410
-
11
0.0
1

TEXTBOX
240
395
480
410
d
11
0.0
1

TEXTBOX
360
395
400
410
L/d.cm2
11
0.0
1

TEXTBOX
480
395
520
410
J/d.cm2
11
0.0
1

TEXTBOX
120
455
160
470
J/d.cm2
11
0.0
1

TEXTBOX
240
455
280
470
cm/d
11
0.0
1

TEXTBOX
360
455
400
470
J/d.cm3
11
0.0
1

TEXTBOX
480
455
520
470
1/d
11
0.0
1

TEXTBOX
120
515
160
530
1/d
11
0.0
1

TEXTBOX
240
515
280
530
J/cm3
11
0.0
1

TEXTBOX
360
515
400
530
-
11
0.0
1

@#$#@#$#@
MODEL DESCRIPTION: hep DEB model	
-----------

This model simulates the trajectory of a hep-DEB-structured population in a well-stirred generalized reactor, starting from a single newly-produced embryo.

Food supply (in mol/d) to the reactor of volume V_X is specified by a spline with knots tJX.
Except for being eaten, food disappears from the reactor with hazard h_X.
Effects of temperature on physiology are specified via a spline with knots tTC, with time and temperature correction factors.
Feeding and changes in state variable of individuals depend on temperature, but food in- and output or background hazards for individuals do not depend on temperature. 
The reactor is homogeneous in terms of food and population density, so this model does not work with patches.
The population starts with a single embryo of age 0 from a well-fed mother and food density X_0.

Apart from aging, individuals are subjected to stage-specific hazards (h_B0b, h_Bbp, h_Bpi) and, optionally, to thinning (with a hazard equal to the specific growth rate times 2/3).
Thinning never applies to embryos; it exactly compensates the increase of total food intake by a cohort due to growth, by a reduction in numbers. 
Food intake and use follow the rules of the standard DEB model (see AmP website). 
Male and female embryos are identical, but juveniles and adults can differ by max specific assimilation and maturity levels at puberty.
Spawning, i.e. the instantaneous conversion of the reproduction-buffer of females to eggs, follows a choice of 3 rules:
(1) produce an egg as soon as the buffer allows (t_R = 0) (2) accumulate the buffer over an incubation period (t_R = 1) (3) accumulate the buffer over a fixed time period (t_R not equal to 0 or 1).
Method (1) compares the content of the reproduction buffer with the cost of an egg at the current reserve density, method (2) compares the predicted incubation time with temperature-corrected time since last spawning, method (3) compares the time since last spawning with the required time (not depending on temperature).
If you want to accumulate the reproduction buffer for 1 day, give t_R a value that is very close, but not equal, to 1 day, e.g. t_R = 1.001.
Energy that was not sufficient to make an egg remains in the buffer for the next spawning event.

Since the pre-natal states (maturity, reserve and structure), change much faster than post-natal, they are set at birth-values, till age passes age-at-birth.
Embryos do not eat and the DEB rule applies for maternal effects:  neonate reserve density equals that of the mother at egg-laying.
Gender is assigned at egg-production (gender 0 for female and 1 for male); fertilisation is for sure.
Rejuvenation, due to failing to pay maturity maintenance costs, affects reproduction and survival.
Shrinking, due to failure to pay somatic maintenance costs, can occur till structural length zero.  

For a general background, see the tab "population dynamics" of the AmP website. 

USER MANUAL
-----------

Run terminates if all individuals died or time exceeds t_max.
Output file txNL23W.txt is written with time (d), scaled food density (-), and for post-natals: total number, structural length to the power 1, 2, 3 (in cm, cm^2, cm^3) and total wet weight (in g).
Food density is scaled with the half-saturation coefficient for females.
The weights do not include contributions from reproduction buffers (in adult females).
See Matlab function DEBtool_M/animal/IBM for the use of this NetLogo model. 
This Matlab function sets the parameter values (via the files set_pars.txt, spline_TC.txt, spline_JX.txt and eaLE.txt), using the AmP collection.
DEBtool_M is available via the add_my_pet website.

This NetLogo model is meant to run from the command-line under Matlab in the powershell with command "netlogo-headless.bat --model hep.nlogo --experiment experiment".
Please make sure that paths have been set to NetLogo and java.exe.
The file "set_pars.txt" is used to overwrite the settings in the graphical interface in the setup-procedure.
This is specifically meant for running the model via the command-line.
Each line should exist of "set var val" (including the quotes), where var is the name of a parameter, and val its value, e.g. "set X_0 0.321".

The model can also be run directly under NetLogo and its gui (simply load hep.nlogo in NetLogo).
Apart from the globals set in the interface, matrices food input tJX, temperature correction factors tTC and embryo-settings eaLE are read from txt-files.
Make sure that files spline_JX.txt, spline_TC.txt and eaLE.txt exist in the same directory as hep.nlogo. 
The easiest way to proceed is first run IBM via Matlab to set the parameters (you can suppress its call to NetLogo), then start NetLogo and hit setup.
Change parameter values in the file set_pars.txt, not in NetLogo's interface, since these values are overwriiten at hitting setup.
Be aware, however, that the parameters E_Hb, v, p_Am, kap, p_M, k_J and E_G should affect the embryo-settings in eaLE.txt, and p_Am and v should affect parameter ome.
So any change in their values makes it necessary to update eaLE, as is done by Matlab function IBM.

The descriptions of the parameters in the interface are given in the code (with the declarations), and reported by the Malab function IBM in an html-page.

Notice that names of variables and parameters are case-insensitive in NetLogo and that e stands for exponent.
Any edits in code within NetLogo leads automatically to an overwrite of the stored model-definition hep.nlogo, 
adding a large section with code for shape-definitions to move shapes across the screen, even if these shapes are not used (like in this model).

ZOOM
---

Depending on the resolution of the display you are using with your computer, you might not be able to see all elements of the Interface. In that case, please either use the scoll bars are the "Zoom" option in the menu.

SPEED
-----

You can speed up the program by deactivating the "view updates" option on the Interface tab.

EXPORT DATA
------

To export model output:
- Use the file output primitives of NetLogo
- Right-click on the plots to export the data displayed to files
@#$#@#$#@
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
