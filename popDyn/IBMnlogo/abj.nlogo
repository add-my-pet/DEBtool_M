; Model definition for an abj-DEB-structured population in a generalized stirred reactor for NetLogo 6.2.0
; Author: Bas Kooijman
; date: 2021/01/12

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
  ; t_R      ; d, time between spawns
  ; h_B0b    ; 1/d, background hazard between 0 and b
  ; h_Bbj    ; 1/d, background hazard between b and j
  ; h_Bjp    ; 1/d, background hazard between j and p
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
  ; E_Hb     ; J, maturity at birth (start acceleration)
  ; E_Hj     ; J, maturity at end acceleration
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
  E_R      ; J, reproduction buffer
  q        ; 1/d^2, ageing acceleration
  h_age    ; 1/d, hazard rate due to aging
  h_thin   ; 1/d, hazard rate due to thinning
  h_rejuv  ; 1/d, hazard rate due to rejuvenation

  gender   ; -, 0 (female) 1 (male)
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
    if E_H < E_Hj [set s_M L / L_b] ; keep s_M fixed otherwise at L_j/ L_b, where L_j = L at E_Hj
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
    (ifelse (thin = 1) and (E_H < E_Hj) [set h_thin r]   ; thinning during acceleration
    (thin = 1) and (E_H >= E_Hj) [set h_thin r * 2 / 3]  ; thinning after acceleration
    [set h_thin 0]) ; 1/d, hazard rate due to thinning
    if E_H = E_Hp and gender = 0 [ ; update reproduction buffer and time-since-spawning in adult females
      set E_R E_R + ((1 - kap) * p_C - TC * k_J * E_Hp) / tickRate ; J, reproduction buffer
      if E_R < 0 [set E_R 0] ; do not allow negative reprod buffer
      set t_spawn t_spawn + 1 / tickRate ; d, time since last spawning
    ]
  ]

  ; spawning events
  set spawn-number (list)  ; create a list for egg numbers
  set spawn-quality (list) ; create a list for egg scaled reserve density at birth
  ask turtles with [(E_H = E_Hp) and (gender = 0) and (E_R > 0)][ ; check adult females with positive reprod buffer
    let E_0 get_E0 ee ; J, cost of egg
    (ifelse t_R = 0 [ ; spawn as soon as reprod buffer allows
      if E_R >= E_0 / kap_R [ ; reprod buffer allows one egg
        let n_spawn floor (kap_R * E_R / E_0) ; number of eggs to spawn (should be 1 if tickRate is not too small)
        set spawn-number insert-item 0 spawn-number n_spawn ; prepend number of eggs to list
        set spawn-quality insert-item 0 spawn-quality ee ; prepend scaled reserve density to list
        set E_R E_R - n_spawn * E_0 / kap_R ; empty reprod buffer
        set t_spawn 0 ; reset time since last spawn
      ]
    ] t_R = 1 [ ; spawn if reprod buffer accumulation time exceeds incubation time
      set a_b get_ab ee
      if E_R >= E_0 / kap_R and t_spawn > a_b / TC [ ; reprod buffer has at least 1 egg
        let n_spawn floor (kap_R * E_R / E_0) ; number of eggs to spawn
        set spawn-number insert-item 0 spawn-number n_spawn ; prepend number of eggs to list
        set spawn-quality insert-item 0 spawn-quality ee ; prepend scaled reserve density to list
        set E_R E_R - n_spawn * E_0 / kap_R ; empty reprod buffer
        set t_spawn 0 ; reset time since last spawn
      ]
    ] [ ; spawn if reprod buffer accumulation time exceeds t_R
      if E_R > E_0 / kap_R and t_spawn > t_R [ ; reprod buffer has at least 1 egg
        let n_spawn floor (kap_R * E_R / E_0) ; number of eggs to spawn
        set spawn-number insert-item 0 spawn-number n_spawn ; prepend number of eggs to list
        set spawn-quality insert-item 0 spawn-quality ee ; prepend scaled reserve density to list
        set E_R E_R - n_spawn * E_0 / kap_R ; empty reprod buffer
        set t_spawn 0 ; reset time since last spawn
      ]
    ])
  ]
  if length spawn-number > 0 [spawn spawn-number spawn-quality] ; create new turtles

  ; death events
  ask turtles with [E_H = E_Hb] [if h_B0b / tickRate > random-float 1 [ die ]]
  ask turtles with [(E_H > E_Hb) and (E_H < E_Hj)] [if (h_Bbj + h_thin + h_age + h_rejuv) / tickRate > random-float 1 [ die ]]
  ask turtles with [(E_H > E_Hj) and (E_H < E_Hpi)] [if (h_Bjp + h_thin + h_age + h_rejuv) / tickRate > random-float 1 [ die ]]
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
; ========================== PROCEDURE to set embryo-states  ===============================================================================
; ==========================================================================================================================================

to set-embryo [eei genderi]
  set a 0 ; d, age
  set a_b get_ab eei ; d, age at birth at 20 C (used to trigger birth)
  set t_spawn 0 ; d, time since last spawning (only plays an active role in adult females)
  set ee eei ; -, scaled reserve density at birth (starts to change after birth)
  set s_M 1 ; -, acceleration factor
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
    set L_b L ; cm, structural length at birth (remains fixed)
    set L_mi L_m ; cm, max structural length
    set E_mi E_m ; J/cm^3, max reserve density
    set gi g ; -, energy investment ratio
  ][ ; male setting
    set Ki K_male ; Mol, half saturation coefficient
    set p_Ami p_Amm ; J/d.cm^2, max spec assim rate
    set J_XAmi J_XAmm ; mol/d.cm^2, max spec food intake rate
    set E_Hpi E_Hpm ; J, maturity at puberty
    set L_b L ; cm, structural length at birth (remains fixed)
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
48.0
1
0
Number

INPUTBOX
50
90
160
150
t_max
54750.0
1
0
Number

INPUTBOX
170
90
280
150
X_0
20.0
1
0
Number

INPUTBOX
290
90
400
150
V_X
22730.0
1
0
Number

INPUTBOX
410
90
520
150
mu_X
525000.0
1
0
Number

INPUTBOX
50
150
160
210
h_X
0.01
1
0
Number

INPUTBOX
170
150
280
210
h_B0b
1.0E-80
1
0
Number

INPUTBOX
290
150
400
210
h_Bbj
1.0E-80
1
0
Number

INPUTBOX
410
150
520
210
h_Bjp
1.0E-60
1
0
Number

INPUTBOX
50
210
160
270
h_Bpi
1.0E-80
1
0
Number

INPUTBOX
170
210
280
270
thin
0.0
1
0
Number

INPUTBOX
290
210
400
270
h_J
1.0E-4
1
0
Number

INPUTBOX
410
210
520
270
h_a
5.773E-46
1
0
Number

INPUTBOX
50
270
160
330
s_G
0.0184
1
0
Number

INPUTBOX
170
270
280
330
E_Hb
0.9367
1
0
Number

INPUTBOX
290
270
400
330
E_Hj
0.9368
1
0
Number

INPUTBOX
410
270
520
330
E_Hp
6211.0
1
0
Number

INPUTBOX
50
330
160
390
E_Hpm
6211.0
1
0
Number

INPUTBOX
170
330
280
390
fProb
0.5
1
0
Number

INPUTBOX
290
330
400
390
kap
0.5599
1
0
Number

INPUTBOX
410
330
520
390
kap_X
0.8
1
0
Number

INPUTBOX
50
390
160
450
kap_G
0.8019
1
0
Number

INPUTBOX
170
390
280
450
kap_R
0.95
1
0
Number

INPUTBOX
290
390
400
450
t_R
0.0
1
0
Number

INPUTBOX
410
390
520
450
F_m
6.5
1
0
Number

INPUTBOX
50
450
160
510
p_Am
617.8
1
0
Number

INPUTBOX
170
450
280
510
p_Amm
617.8
1
0
Number

INPUTBOX
290
450
400
510
v
0.03463
1
0
Number

INPUTBOX
410
450
520
510
p_M
56.67
1
0
Number

INPUTBOX
50
510
160
570
k_J
0.002
1
0
Number

INPUTBOX
170
510
280
570
k_JX
2.0E-5
1
0
Number

INPUTBOX
290
510
400
570
E_G
5218.0
1
0
Number

INPUTBOX
410
510
520
570
ome
3.875
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
5.0
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
5.0
true
true
"" ""
PENS
"juvFemales" 1.0 0 -1069655 true "" "plotxy time count turtles with [(E_H > E_Hb) and (E_H < E_Hp) and (gender = 0)]"
"adFemales" 1.0 0 -2674135 true "" "plotxy time count turtles with [(E_H = E_Hp) and (gender = 0)]"
"juvMales" 1.0 0 -5516827 true "" "plotxy time count turtles with [(E_H > E_Hb) and (E_H < E_Hpm) and (gender = 1)]"
"adMales" 1.0 0 -13791810 true "" "plotxy time count turtles with [(E_H = E_Hpm) and (gender = 1)]"

TEXTBOX
480
35
520
53
1/d
11
0.0
1

TEXTBOX
120
95
160
113
d
11
0.0
1

TEXTBOX
240
95
280
113
Mol
11
0.0
1

TEXTBOX
360
95
400
113
L
11
0.0
1

TEXTBOX
480
95
520
113
J/mol
11
0.0
1

TEXTBOX
120
155
160
173
1/d
11
0.0
1

TEXTBOX
240
155
280
173
1/d
11
0.0
1

TEXTBOX
360
155
400
173
1/d
11
0.0
1

TEXTBOX
480
155
520
173
1/d
11
0.0
1

TEXTBOX
120
215
160
233
1/d
11
0.0
1

TEXTBOX
240
215
280
233
-
11
0.0
1

TEXTBOX
360
215
400
233
1/d
11
0.0
1

TEXTBOX
480
215
520
233
1/d2
11
0.0
1

TEXTBOX
120
275
160
293
-
11
0.0
1

TEXTBOX
240
275
280
293
J
11
0.0
1

TEXTBOX
360
275
400
293
J
11
0.0
1

TEXTBOX
480
275
520
293
J
11
0.0
1

TEXTBOX
120
335
150
353
J
11
0.0
1

TEXTBOX
240
335
280
353
-
11
0.0
1

TEXTBOX
360
335
400
353
-
11
0.0
1

TEXTBOX
480
335
520
353
-
11
0.0
1

TEXTBOX
120
395
160
413
-
11
0.0
1

TEXTBOX
240
395
480
413
-
11
0.0
1

TEXTBOX
360
395
400
413
-,d
11
0.0
1

TEXTBOX
480
395
520
413
L/d.cm2
11
0.0
1

TEXTBOX
120
455
160
473
J/d.cm2
11
0.0
1

TEXTBOX
240
455
280
473
J/d.cm2
11
0.0
1

TEXTBOX
360
455
400
473
cm/d
11
0.0
1

TEXTBOX
480
455
520
473
J/d.cm3
11
0.0
1

TEXTBOX
120
515
160
533
1/d
11
0.0
1

TEXTBOX
240
515
280
533
1/d
11
0.0
1

TEXTBOX
360
515
400
533
J/cm3
11
0.0
1

TEXTBOX
480
515
520
533
-
11
0.0
1

@#$#@#$#@
MODEL DESCRIPTION: abj DEB model	
-----------

This model simulates the trajectory of an abj-DEB-structured population in a well-stirred generalized reactor, starting from a single newly-produced embryo.

Food supply (in mol/d) to the reactor of volume V_X is specified by a spline with knots tJX.
Except for being eaten, food disappears from the reactor with hazard h_X.
Effects of temperature on physiology are specified via a spline with knots tTC, with time and temperature correction factors.
Feeding and changes in state variable of individuals depend on temperature, but food in- and output or background hazards for individuals do not dependent on temperature. 
The reactor is homogeneous in terms of food and population density, so this model does not work with patches.
The population starts with a single embryo of age 0 from a well-fed mother and food density X_0.

Apart from aging, individuals are subjected to stage-specific hazards (h_B0b, h_Bbj, h_Bjp, h_Bpi) and, optionally, to thinning (with a hazard equal to the specific growth rate during acceleration and times 2/3 after acceleration).
Thinning never applies to embryos; it exactly compensates the increase of total food intake by a cohort due to growth, by a reduction in numbers. 
Food intake and use follow the rules of the abj DEB model (see AmP website). 
Male and female embryos are identical, but juveniles and adults can differ by max specific assimilation and maturity levels at puberty.
Spawning, i.e. the instantaneous conversion of the reproduction-buffer of females to eggs, follows a choice of 3 rules:
(1) produce an egg as soon as the buffer allows (t_R = 0) (2) accumulate the buffer over an incubation period (t_R = 1) (3) accumulate the buffer over a fixed time period (t_R not equal to 0 or 1).
Method (1) compares the content of the reproduction buffer with the cost of an egg at the current reserve density, method (2) compares the predicted incubation time with temperature-corrected time since last spawning, method (3) compares the time since last spawning with the required time (not depending on temperature).
If you want to accumulate the reproduction buffer for 1 day, give t_R a value that is very close, but not equal, to 1 day, e.g. t_R = 1.001.
Energy that was not sufficient to make an egg remains in the buffer for the next spawning event.

Since the pre-natal states (maturity, reserve and structure), change much faster than post-natal, they are set at birth-values, till age passes age-at-birth.
Embryos do not eat and the DEB rule applies for maternal effects: neonate reserve density equals that of the mother at egg-laying.
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

This NetLogo model is meant to run from the command-line under Matlab in the powershell with command "netlogo-headless.bat --model std.nlogo --experiment experiment".
Please make sure that paths have been set to NetLogo and java.exe.
The file "set_pars.txt" is used to overwrite the settings in the graphical interface in the setup-procedure.
This is specifically meant for running the model via the command-line.
Each line should exist of "set var val" (including the quotes), where var is the name of a parameter, and val its value, e.g. "set X_0 0.321".

The model can also be run directly under NetLogo and its gui (simply load abj.nlogo in NetLogo).
Apart from the globals set in the interface, matrices food input tJX, temperature correction factors tTC and embryo-settings eaLE are read from txt-files.
Make sure that files spline_JX.txt, spline_TC.txt and eaLE.txt exist in the same directory as abj.nlogo. 
The easiest way to proceed is first run IBM via Matlab to set the parameters (you can suppress its call to NetLogo), then start NetLogo and hit setup.
Change parameter values in the file set_pars.txt, not in NetLogo's interface, since these values are overwriiten at hitting setup.
Be aware, however, that the parameters E_Hb, v, p_Am, kap, p_M, k_J and E_G should affect the embryo-settings in eaLE.txt, and p_Am and v should affect parameter ome.
So any change in their values makes it necessary to update eaLE, as is done by Matlab function IBM.

The descriptions of the parameters in the interface are given in the code (with the declarations), and reported by the Malab function IBM in an html-page.

Notice that names of variables and parameters are case-insensitive in NetLogo and that e stands for exponent.
Any edits in code within NetLogo leads automatically to an overwrite of the stored model-definition abj.nlogo, 
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
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
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
