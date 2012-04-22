                               ;  ____________________________________________
                               ; |                                            |
                               ; |                Screen  Edit                |
                               ; |____________________________________________|
                               ;

               ORG  $4000

CV             EQU  $25
INVFLG         EQU  $32
CH             EQU  $057B
KBD            EQU  $C000
KBDSTRB        EQU  $C010
NEWVTAB        EQU  $FC86
WAIT           EQU  $FCA8
COUT           EQU  $FDED
CROUT          EQU  $FD8E
ALTCSON        EQU  $C00F
RDBTN0         EQU  $C061
RDBTN1         EQU  $C062
PICKY          EQU  $CC1D
GETCUR2        EQU  $CCAD

ENTRY          JMP  SCRNEDIT
STCHR          DS   1          ; Storage for character
CURSOR         DFB  $DF        ; Cursor
CURCHAR        DS   1          ; Cursor/Character print indicator

SCRNEDIT       JSR  INTRO
               STA  ALTCSON
SCRNLOOP       JSR  PICKY
               STA  STCHR
               LDA  CURSOR
               JSR  COUT
               LDA  #$88
               JSR  COUT
               CLC
               ROR  CURCHAR    ; Clear CURCHAR (CHAR)
WAITKBD        BIT  KBD        ; Check for keypress
               BMI  GOTKEY
               BIT  CURCHAR
               BMI  WAL1
               LDA  STCHR
               BMI  WL1
               JSR  MOUT
WL1            JSR  COUT
               LDA  #$88
               JSR  COUT
               SEC
               ROR  CURCHAR    ; Set CURCHAR (CUR)
               JSR  PAUSE
               JMP  WAITKBD
WAL1           LDA  CURSOR
               JSR  COUT
               LDA  #$88
               JSR  COUT
               CLC
               ROR  CURCHAR    ; Clear CURCHAR (CHAR)
               JSR  PAUSE
               JMP  WAITKBD
GOTKEY         LDA  STCHR
               BMI  GL1
               JSR  MOUT
GL1            JSR  COUT
               LDA  #$88
               JSR  COUT
               LDA  KBD
               BIT  KBDSTRB
               ORA  #$80
               CMP  #$8D       ; <cr>
               BNE  SL1
               JMP  CR
SL1            CMP  #$89       ; up
               BNE  SL2
               JMP  UP
SL2            CMP  #$8B       ; down
               BNE  SL3
               JMP  DOWN
SL3            CMP  #$8A       ; left
               BNE  SL4
               JMP  LEFT
SL4            CMP  #$8C       ; right
               BNE  SL5
               JMP  RIGHT
SL5            CMP  #$88       ; <bs>
               BNE  SL6
               JSR  COUT
               JMP  SCRNLOOP
SL6            CMP  #$95       ; -->
               BNE  SL7
               JMP  RETYPE
SL7            CMP  #$A0
               BPL  SL8        ; if other control then ignore
               JMP  SCRNLOOP
SL8            BIT  RDBTN0
               BPL  SL9
               BMI  MOU
SL9            BIT  RDBTN1
               BPL  NOMOU
MOU            JSR  MOUSECHK
NOMOU          JSR  COUT
               JMP  SCRNLOOP

UP             DEC  CV
               LDA  CV
               BPL  EXUP
               LDA  #23
               STA  CV
EXUP           JSR  NEWVTAB
               JMP  SCRNLOOP

DOWN           INC  CV
               LDA  CV
               CMP  #24
               BMI  EXDOWN
               LDA  #0
               STA  CV
EXDOWN         JSR  NEWVTAB
               JMP  SCRNLOOP

LEFT           LDY  CH
               DEY
               BPL  EXLEFT
               LDY  #79
EXLEFT         JSR  GETCUR2
               JMP  SCRNLOOP

RIGHT          LDY  CH
               INY
               CPY  #80
               BMI  EXRIGHT
               LDY  #0
EXRIGHT        JSR  GETCUR2
               JMP  SCRNLOOP

CR             LDA  STCHR
               BMI  CRL1
               JSR  MOUT
CRL1           JSR  COUT
               RTS

INTRO          LDA  #12
               STA  CV
               JSR  CROUT
               LDA  #40
               STA  CH
               RTS

RETYPE         LDA  STCHR
               BMI  RNOMOU
               JSR  MOUT
RNOMOU         JSR  COUT
               JMP  SCRNLOOP

PAUSE          LDA  #$25
               JSR  WAIT
               RTS

MOUSECHK       CMP  #$C0
               BMI  EXMOUT
               AND  #$DF
MOUT           ORA  #$80
               PHA
               LDA  #$3F
               STA  INVFLG
               LDA  #$1B
               JSR  COUT
               PLA
               JSR  COUT
               LDA  #$FF
               STA  INVFLG
               LDA  #$18
EXMOUT         RTS
