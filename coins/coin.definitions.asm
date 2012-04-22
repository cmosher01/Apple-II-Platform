                               ;
                               ; Coin Inventory (Definitions)
                               ;
               lst  off
                               ; Copyright 1988 by Christopher A. Mosher
                               ;



               org  $6000      ; after coin.system program



                               ; list of addrs
defs
               da   coinl      ; $0
               da   denl       ; $1
               da   subjl      ; $2
               da   inscl      ; $3
               da   inscchrl   ; $4
               da   desgl      ; $5
               da   edgel      ; $6
               da   weightl    ; $7
               da   diaml      ; $8
               da   compl      ; $9
               da   compml     ; $A
               da   lastbyte-1 ; $B



coinl                          ; coin list
                               ;   list of:
                               ;     +$0: denomination
                               ;     +$1: obv subject
                               ;     +$2: obv inscription
                               ;     +$3: obv designer
                               ;     +$4: rev subject
                               ;     +$5: rev inscription
                               ;     +$6: rev designer
                               ;     +$7: edge
                               ;     +$8: weight
                               ;     +$9: diameter
                               ;     +$A: composition

               hex  0200       ; number of coins in list

*                   000102030405060708090A
               hex  0000000001010000000001                             ; coin 0
               hex  0102020103030100010102                             ; coin 1



denl                           ; denomination list
                               ;   list of addrs; list of strings

               dfb  $02        ; number of addrs

               da   den0,den1

den0           asc             "cent"
               dfb  0
den1           asc             "five-cent piece"
               dfb  0



subjl                          ; subject list
                               ;   list of addrs; list of strings

               dfb  $04        ; number of addrs

               da   sb0,sb1,sb2,sb3

sb0            asc             "Lincoln"
               dfb  0
sb1            asc             "wheat stalks"
               dfb  0
sb2            asc             "Jefferson"
               dfb  0
sb3            asc             "Monticello"
               dfb  0



inscl                          ; inscription list
                               ;   list of addrs; list of insc.strs

               dfb  $04        ; number of addrs

               da   in0,in1,in2,in3

in0                            ; "IN GOD WE TRUST  LIBERTY  [date][mm]"
               dfb  8          ; length
               hex  05         ; IN GOD WE TRUST
               asc             "  "
               hex  03         ; LIBERTY
               asc             "  "
               hex  0001       ; [date][mm]

in1                            ; "E.PLURIBUS UNUM  ONE CENT  UNITED STATES OF
                               ;  AMERICA"
               dfb  7
               hex  02         ; E.PLURIBUS UNUM
               asc             "  "
               hex  06         ; ONE CENT
               asc             "  "
               hex  07         ; UNITED STATES OF AMERICA

in2                            ; "IN GOD WE TRUST  LIBERTY.[date]"
               dfb  6
               hex  05         ; IN GOD WE TRUST
               asc             "  "
               hex  03         ; LIBERTY
               asc             "."
               hex  00         ; [date]

in3                            ; "E PLURIBUS UNUM  [mm]  MONTICELLO  FIVE CENTS
                               ;  UNITED STATES OF AMERICA"
               dfb  $16
               hex  08         ; E PLURIBUS UNUM
               asc             "  "
               hex  01         ; [mm]
               asc             "  MONTICELLO  "
               hex  09         ; FIVE CENTS
               asc             "  "
               hex  07         ; UNITED STATES OF AMERICA



inscchrl                       ; inscription characters
                               ;   list of addrs; list of strings

               dfb  $0A        ; number of addrs

               da   inc0,inc1  ; date and mm
               da   inc2,inc3,inc4,inc5,inc6,inc7,inc8,inc9

inc0           asc             "[date]"
               dfb  0
inc1           asc             "[mm]"
               dfb  0
inc2           asc             "E.PLURIBUS UNUM"
               dfb  0
inc3           asc             "LIBERTY"
               dfb  0
inc4           asc             "******"
               dfb  0
inc5           asc             "IN GOD WE TRUST"
               dfb  0
inc6           asc             "ONE CENT"
               dfb  0
inc7           asc             "UNITED STATES OF AMERICA"
               dfb  0
inc8           asc             "E PLURIBUS UNUM"
               dfb  0
inc9           asc             "FIVE CENTS"
               dfb  0



desgl                          ; designer list
                               ;   list of addrs; list of names

               dfb  $02        ; number of addrs

               da   dg0,dg1

dg0            asc             "Victor D. Brenner"
               dfb  0
dg1            asc             "Felix Schlag"
               dfb  0



edgel                          ; edge list
                               ;   list of addrs; list of edges

               dfb  $03        ; number of addrs

               da   ed0,ed1,ed2

ed0            asc             "[plain]"
               dfb  0
ed1            asc             "[reeded]"
               dfb  0
ed2            asc             "TWO HUNDRED FOR A DOLLAR"
               dfb  0



weightl                        ; weight list

               dfb  $02        ; number of weights in list

               hex  027000     ; 02.7000 g
               hex  050000     ; 05.0000 g



diaml                          ; diameter list

               dfb  $02        ; number of diameters in list

               hex  1900       ; 19.00 mm
               hex  2120       ; 21.20 mm



compl                          ; composition list
                               ;   list of addrs; list of comps

               dfb  $03        ; length of list of addrs

               da   cm0,cm1,cm2

cm0            dfb  0          ; indicate no clad or plating
               dfb  1          ; 1 metal
               hex  000000     ; 1.0000 copper

cm1            dfb  2          ; plat
               dfb  1          ; 1 metal in plat
               hex  000003     ; 1.0000 zinc
               dfb  1          ; 1 metal in cntr
               hex  000002     ; 1.0000 steel

cm2            dfb  0          ; no clad or plat
               dfb  3          ; 3 metals
               hex  560000     ;  .5600 copper
               hex  350005     ;  .3500 silver
               hex  090004     ;  .0900 manganese



compml                         ; composition metals list
                               ;   list of addrs; list of strings

               dfb  $06        ; number of addrs

               da   cmm0,cmm1,cmm2,cmm3,cmm4,cmm5

cmm0           asc             "copper"
               dfb  0
cmm1           asc             "nickel"
               dfb  0
cmm2           asc             "steel"
               dfb  0
cmm3           asc             "zinc"
               dfb  0
cmm4           asc             "manganese"
               dfb  0
cmm5           asc             "silver"
               dfb  0



lastbyte



               sav  COIN.DEFINITIONS
