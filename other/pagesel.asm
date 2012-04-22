               ORG  $7000
                               ;    _
ADSTORE        EQU  $C018      ; R7  |  eighty store switch:
ADSTOROF       EQU  $C000      ; W   |    off:  PAGE2 (page1/page2)
ADSTORON       EQU  $C001      ; W  _|    on :  PAGE2 (main /aux  )
                               ;    _
ALTCS          EQU  $C01E      ; R7  |  alternate character set switch:
ALTCSOFF       EQU  $C00E      ; W   |    off: display primary characters
ALTCSON        EQU  $C00F      ; W  _|    on : display alternative characters
                               ;    _
PAGE2          EQU  $C01C      ; R7  |  page 2 switch:
PAGE2OFF       EQU  $C054      ; RW  |    off: page1 (or main memory)
PAGE2ON        EQU  $C055      ; RW _|    on : page2 (or auxiliary memory)
                               ;
RD63           EQU  $C063      ; R7  mouse button status:
                               ;       off: up
                               ;       on : down
                               ;
NUML           EQU  $F9
NUMH           EQU  $FA
PAGEH          EQU  $FB
PAGEL          EQU  $FC
ROW            EQU  $FE
COL            EQU  $FF
MOUON          EQU  $83A2
MOUOFF         EQU  $83A5
                               ;         2
                               ;       5A  + 27A + 26
WAIT           EQU  $FCA8      ; Delay -------------- microseconds
                               ;             2
                               ;
                               ;
                               ;
SELECT         PHP
               BIT  ADSTORE
               PHP
               BIT  PAGE2
               PHP
               BIT  ALTCS
               PHP
               JSR  NUMPAGE
               JSR  PRTCMDS
               JSR  PRTPAGE
LL1            JSR  MOUON
BUTTONDN       BIT  RD63       ; Wait for button to be pressed
               BMI  BUTTONDN
               LDA  #$80
               JSR  WAIT
               JSR  MOUOFF
               LDA  #$00
               STA  FAST?
               LDA  #$09
               STA  REPT
CHECKIDG       LDX  COL
               LDY  ROW
               CPY  #$11
               BNE  LL4
               CPX  #$35
               BEQ  INC
               CPX  #$37
               BEQ  GO
               CPX  #$38
               BEQ  GO         ; if Z = 0 (NE) then fall through to BUTTONUP
LL4            CPY  #$12
               BNE  BUTTONUP
               CPX  #$35
               BEQ  DEC
BUTTONUP       BIT  RD63       ; Wait for button to be released
               BPL  BUTTONUP
               BMI  LL1        ; (branch always)
                               ;
GO             BIT  RD63       ; Wait for button to be released
               BPL  GO
               JMP  EXIT
                               ;
INC            LDX  NUML
               LDY  NUMH
               CPX  #$EE
               BNE  L5
               CPY  #$02
               BEQ  BUTTONUP   ; if PAGE = 750 then do not increment
L5             INX
               BNE  L6
               INY
L6             STX  NUML
               STY  NUMH
               LDA  PAGEL
               SED
               CLC
               ADC  #$01       ; Decimal mode
               BNE  LL7
               LDA  PAGEH
               CLC
               ADC  #$01       ; Decimal mode
               STA  PAGEH
               LDA  #$00
LL7            STA  PAGEL
               CLD
               JSR  PRTPAGE
               BIT  RD63
               BPL  PAUSE
               JMP  LL1
                               ;
PAUSE          BIT  FAST?
               BMI  FASTUP
RDBT           BIT  RD63       ; If button is released then
               BPL  L18        ; then branch
               JMP  LL1
L18            NOP             ; Pause
               LDA  #$70
               JSR  WAIT
               DEC  REPT
               BNE  RDBT
               LDA  #$80
               STA  FAST?
FASTUP         LDA  #$80
               JSR  WAIT
               JMP  CHECKIDG
                               ;
DEC            LDX  NUML
               LDY  NUMH
               BNE  LL8
               CPX  #$00
               BEQ  BUTTONUP
LL8            DEX
               CPX  #$FF
               BNE  L9
               DEY
L9             STX  NUML
               STY  NUMH
               LDA  PAGEL
               SED
               SEC
               SBC  #$01       ; Decimal mode
               CMP  #$99
               BNE  L10
               LDA  PAGEH
               SEC
               SBC  #$01       ; Decimal mode
               STA  PAGEH
               LDA  #$99
L10            STA  PAGEL
               CLD
               JSR  PRTPAGE
               BIT  RD63
               BPL  PAUSE
               JMP  LL1
                               ;
PRTPAGE        LDA  PAGEH
               AND  #$0F       ; 0000dddd
               PHA
               BEQ  L20        ; if 00000000 then branch
               ORA  #$B0       ; 1011dddd (chr of number)
               BNE  L21        ; (branch always)
L20            LDA  #$A0       ; <sp>
L21            STA  $4E7
               LDA  PAGEL
               AND  #$F0       ; dddd0000
               BEQ  L22        ; if 00000000 then branch
               HEX  FA         ; PLX
               LSR             ; 0dddd000
               LSR             ; 00dddd00
               LSR             ; 000dddd0
               LSR             ; 0000dddd
               ORA  #$B0       ; 1011dddd (chr of number)
               BNE  L23        ; (branch always)
L22            PLA
               BNE  L24
               LDA  #$A0
               BNE  L23        ; (branch always)
L24            LDA  #$B0
L23            STA  PAGE2ON
               STA  $4E8
               STA  PAGE2OFF
               LDA  PAGEL
               AND  #$0F       ; 0000dddd
               ORA  #$B0       ; 1011dddd (chr of number)
               STA  $4E8
               RTS

PRTCMDS        STA  ADSTORON
               STA  PAGE2OFF
               STA  ALTCSON
               LDA  #$4B
               STA  $4EA
               LDA  #$4A
               STA  $56A
               LDA  #$EF
               STA  $4EB
               STA  PAGE2ON
               LDA  #$EB
               STA  $4EC
               STA  PAGE2OFF
               RTS
                               ;
EXIT           STA  ALTCSOFF
               PLP
               BPL  L15
               STA  ALTCSON
L15            STA  PAGE2OFF
               PLP
               BPL  L16
               STA  PAGE2ON
L16            STA  ADSTOROF
               PLP
               BPL  L17
               STA  ADSTORON
L17            PLP
               RTS
                               ;
NUMPAGE        LDA  #$00
               STA  PAGEH
               LDA  NUML       ; A = LO
               LDX  NUMH       ; X = HI
               BEQ  LOW        ; if HI is 0 then branch
               CPX  #$02       ;   else  A = adjusted LO
               BNE  L7
               CMP  #$90
               BCC  L8
               CLC
               ADC  #$A8
               LDX  #$06
               STX  PAGEH
               BNE  LOW
L8             CLC
               ADC  #$70
               LDX  #$04
               STX  PAGEH
               BNE  LOW
L7             CMP  #$C8
               BCS  L8
               ADC  #$38
               LDX  #$02
               STX  PAGEH
                               ;
LOW            LDY  #$00
L1             CMP  #$64
               BCC  L2
               SBC  #$64
               INY
               BCS  L1         ; (branch always)
L2             LDX  #$00
L3             CMP  #$0A
               BCC  L4
               SBC  #$0A
               INX
               BCS  L3         ; (branch always)
L4             STA  PAGEL      ; 0000llll
               TXA             ; 0000hhhh
               ASL             ; 000hhhh0
               ASL             ; 00hhhh00
               ASL             ; 0hhhh000
               ASL             ; hhhh0000
               ORA  PAGEL      ; hhhhllll
               STA  PAGEL
               TYA
               CLC
               ADC  PAGEH
               STA  PAGEH
               RTS
                               ;
REPT           DS   1
FAST?          DS   1
