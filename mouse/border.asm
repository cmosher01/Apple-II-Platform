CV             EQU  $25
CH             EQU  $057B
HOME           EQU  $FC58
NEWVTAB        EQU  $FC86
COUT           EQU  $FDED
ALTCSON        EQU  $C00F
WNDLFT         EQU  $20
WNDWDTH        EQU  $21
WNDTOP         EQU  $22
WNDBTM         EQU  $23
INVFLG         EQU  $32
PCL            EQU  $FE
PCH            EQU  $FF
L              EQU  $CC
O              EQU  $CF
P              EQU  $D0
Q              EQU  $D1
R              EQU  $D2
Z              EQU  $DA
\              EQU  $DC
_              EQU  $DF

ENTRY          JMP  MOUSBORD
COL            DS   1
END            DS   1

MOUTON         LDA  #$3F
               STA  INVFLG
               LDA  #$1B
               JSR  COUT
               RTS

MOUTOFF        LDA  #$18
               JSR  COUT
               LDA  #$FF
               STA  INVFLG
               RTS

PRVLIN         JSR  MOUTON
               LDA  #0
               STA  CV
VERTLP         JSR  NEWVTAB
               LDX  #76
               STX  CH
               LDA  #_
               JSR  COUT
               INC  CV
               LDA  CV
               CMP  #20
               BNE  VERTLP
               JSR  MOUTOFF
               RTS

PRHLIN         LDA  #0
               STA  CH
               LDA  #19
               STA  CV
               JSR  NEWVTAB
               LDX  #0
HORZLP         LDA  #_
               JSR  COUT
               INX
               CPX  #76
               BNE  HORZLP
               RTS

PRHBOX         PLA
               STA  PCL
               PLA
               STA  PCH
               JSR  MOUTON
               LDY  #1
               LDA  (PCL),Y
               STA  CV
               JSR  NEWVTAB
               LDY  #2
               LDA  (PCL),Y
               STA  CH
               LDA  #Z
               JSR  COUT
               LDA  #O
               JSR  COUT
               LDY  #3
               LDA  (PCL),Y
               STA  END
               DEC  END
HBOXLP         LDA  #\
               JSR  COUT
               LDA  CH
               CMP  END
               BNE  HBOXLP
               LDA  #P
               JSR  COUT
               LDA  #_
               JSR  COUT
               JSR  MOUTOFF
               LDA  PCL
               CLC
               ADC  #3
               STA  PCL
               LDA  PCH
               ADC  #0
               PHA
               LDA  PCL
               PHA
               RTS

PRVBOX         PLA
               STA  PCL
               PLA
               STA  PCH
               LDY  #1
               LDA  (PCL),Y    ; column
               STA  COL        ;
               LDX  COL
               INX
               STX  CH
               LDY  #2
               LDA  (PCL),Y    ; start row
               STA  CV
               JSR  NEWVTAB
               LDA  #_
               JSR  COUT
               JSR  MOUTON
               LDA  COL
               STA  CH
               INC  CV
               JSR  NEWVTAB
               LDA  #Z
               JSR  COUT
               LDA  #R
               JSR  COUT
               LDY  #3
               LDA  (PCL),Y    ; end row
               STA  END
               DEC  END
               INC  CV
VBOXLP         JSR  NEWVTAB
               LDA  COL
               STA  CH
               LDA  #Z
               JSR  COUT
               LDA  #Z
               JSR  COUT
               INC  CV
               LDA  CV
               CMP  END
               BNE  VBOXLP
               JSR  NEWVTAB
               LDA  COL
               STA  CH
               LDA  #Z
               JSR  COUT
               LDA  #Q
               JSR  COUT
               LDX  COL
               INX
               STX  CH
               INC  CV
               JSR  NEWVTAB
               LDA  #L
               JSR  COUT
               JSR  MOUTOFF
               LDA  PCL
               CLC
               ADC  #3
               STA  PCL
               LDA  PCH
               ADC  #0
               PHA
               LDA  PCL
               PHA
               RTS

INTRO          JSR  HOME
               STA  ALTCSON
               RTS

CLOSING        LDA  #75
               STA  WNDWDTH
               LDA  #19
               STA  WNDBTM
               LDA  #1
               STA  CV
               JSR  NEWVTAB
               RTS

MOUSBORD       JSR  INTRO
               JSR  PRVLIN
               JSR  PRHLIN
               JSR  PRHBOX     ; Print horizontal box
               DFB  21,40,74   ; at row 21, columns 40 through 74
               JSR  PRVBOX     ; Print vertical box
               DFB  77,2,18    ; at column 77, rows 2 through 18
               JSR  CLOSING
               RTS
