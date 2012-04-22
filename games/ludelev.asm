STRINGL        EQU  $06
STRINGH        EQU  $07
LENG           EQU  $08
HMAX           EQU  $09
ESC            EQU  $0A
LEVEL          EQU  $0B
PROMPTLN       EQU  $0C
NUML           EQU  $0D
NUMH           EQU  $0E
NUM            EQU  $0F
VTAB           EQU  $25
HTAB           EQU  $24
TMEML          EQU  $1B
TMEMH          EQU  $1C
ASCII          EQU  $1E
ATEMP          EQU  $45
XTEMP          EQU  $46
YTEMP          EQU  $47
PTEMP          EQU  $48
STEMP          EQU  $49
IREG           EQU  $0200
RWTS           EQU  $03D9
BEEP           EQU  $FF3A
START          JSR  CLS
               CLD
               LDA  #$B0
               STA  I1
               STA  I2
               STA  I3
ST1            LDA  #$06
               STA  VTAB
               LDA  #$00
               STA  HTAB
               JSR  PRINT
               ASC  "SOURCE START LEVEL: \"
               JSR  INPUT
               LDA  LEVEL
               STA  L1
               LDA  ESC
               BEQ  ST2
               RTS
ST2            LDA  #$09
               STA  VTAB
               LDA  #$00
               STA  HTAB
               JSR  PRINT
               ASC  "SOURCE END LEVEL: \"
               JSR  INPUT
               LDA  LEVEL
               STA  L2
               LDA  ESC
               BNE  ST1
               LDA  #$0C
               STA  VTAB
               LDA  #$00
               STA  HTAB
               JSR  PRINT
               ASC  "DESTINATION LEVEL: \"
               JSR  INPUT
               LDA  LEVEL
               STA  L3
               LDA  ESC
               BNE  ST2
               LDA  L2
               CMP  L1
               BPL  Q1
               JMP  ST1
Q1             LDA  L1
               STA  LEVEL
               JSR  DKCALC
               LDA  TR
               STA  TR1
               LDA  S
               STA  S1
               LDA  L2
               STA  LEVEL
               JSR  DKCALC
               LDA  TR
               STA  TR2
               LDA  S
               STA  S2
               LDA  L3
               STA  LEVEL
               JSR  DKCALC
               LDA  TR
               STA  TR3
               LDA  S
               STA  S3
               LDA  L2
               SEC
               SBC  L1
               CLC
               ADC  L3
               STA  L4
               STA  LEVEL
               JSR  DKCALC
               LDA  TR
               STA  TR4
               LDA  S
               STA  S4
               LDA  #<DCT
               STA  IOB6
               LDA  #>DCT
               STA  IOB7
               LDA  #$10
               STA  IOB9
               LDA  #$00
               STA  IOB8
               LDA  #$01
               STA  IOBC
               LDA  #$0F
               STA  VTAB
               LDA  #$00
               STA  HTAB
               JSR  PRINT
               ASC  "PRESS <SPACE> TO READ         \"
Q11            JSR  KEYIN
               CMP  #$A0
               BNE  Q11
               LDA  TR1
               STA  IOB4
               LDA  S1
               STA  IOB5
Q2             LDY  #<IOB
               LDA  #>IOB
               JSR  RWTS
               LDA  IOB4
               CMP  TR2
               BNE  Q21
               LDA  IOB5
               CMP  S2
               BNE  Q21
               JMP  Q3
Q21            INC  IOB5
               LDA  IOB5
               CMP  #$10
               BMI  Q22
               INC  IOB4
               LDA  #$00
               STA  IOB5
Q22            INC  IOB9
               LDA  IOB9
               CMP  #$74
               BMI  Q2
               LDA  #$0F
               STA  VTAB
               LDA  #$00
               STA  HTAB
               JSR  PRINT
               ASC  "?OUT OF MEMORY ERROR          \"
               JSR  KEYIN
               JMP  START
Q3             LDA  #$0F
               STA  VTAB
               LDA  #$00
               STA  HTAB
               JSR  PRINT
               ASC  "PRESS <SPACE> TO WRITE        \"
Q33            JSR  KEYIN
               CMP  #$A0
               BNE  Q33
               LDA  #$02
               STA  IOBC
               LDA  #$10
               STA  IOB9
               LDA  TR3
               STA  IOB4
               LDA  S3
               STA  IOB5
Q4             LDY  #<IOB
               LDA  #>IOB
               JSR  RWTS
               LDA  IOB4
               CMP  TR4
               BMI  Q41
               LDA  IOB5
               CMP  S4
               BMI  Q41
               JMP  Q5
Q41            INC  IOB5
               LDA  IOB5
               CMP  #$10
               BMI  Q42
               INC  IOB4
               LDA  #$00
               STA  IOB5
Q42            INC  IOB9
               JMP  Q4
Q5             JMP  START
* DKCALC
* INPUT=LEVEL
* OUTPUT=TR,S
DKCALC         LDA  #$03
               STA  TR
               LDA  #$00
               STA  S
DKC1           DEC  LEVEL
               BEQ  DKEND
               LDA  S
               CLC
               ADC  #$01
               STA  S
               CMP  #$10
               BMI  DKC1
               LDA  #$00
               STA  S
               INC  TR
               JMP  DKC1
DKEND          RTS
* CINIT
* INPUT=VTAB
* OUTPUT=TMEML,TMEMH
CINIT          STA  ATEMP
               STY  YTEMP
               LDA  VTAB
               ASL
               TAY
               LDA  F1,Y
               STA  TMEMH
               INY
               LDA  F1,Y
               STA  TMEML
               LDA  ATEMP
               LDY  YTEMP
               RTS
* COUT
* INPUT=TMEML,TMEMH,A
* (PUTS A ON SCREEN)
COUT           STA  ATEMP
               STY  YTEMP
               LDY  HTAB
               LDA  ATEMP
               STA  (TMEML),Y
               LDY  YTEMP
               RTS
* PRINT
* INPUT=ASCII STRING STORED AFTER
*       JSR CMD WITH \ AT END
* (OUTPUTS IT TO SCREEN)
PRINT          STA  ATEMP
               STY  YTEMP
               PLA
               STA  STRINGL
               PLA
               STA  STRINGH
               JSR  CINIT
               LDY  #$01
PRLOOP         LDA  (STRINGL),Y
               CMP  #$DC
               BEQ  PREND
               JSR  COUT
               INY
               LDA  HTAB
               CLC
               ADC  #$01
               STA  HTAB
               JMP  PRLOOP
PREND          TYA
               CLC
               ADC  STRINGL
               STA  STRINGL
               LDA  STRINGH
               ADC  #$00
               PHA
               LDA  STRINGL
               PHA
               LDA  ATEMP
               LDY  YTEMP
               RTS
* PRINT STRING
* INPUT=ASCII STRING AT (STRINGL)
* (FIRST BYTE IS LENGTH)
PRTSTR         STA  ATEMP
               STY  YTEMP
               JSR  CINIT
               LDY  #$00
               LDA  (STRINGL),Y
               STA  LENG
               INY
PRTLP          LDA  (STRINGL),Y
               JSR  COUT
               TYA
               CMP  LENG
               BPL  PRTEND
               INY
               LDA  HTAB
               CLC
               ADC  #$01
               STA  HTAB
               JMP  PRTLP
PRTEND         LDY  HTAB
               INY
               STY  HTAB
               LDA  ATEMP
               LDY  YTEMP
               RTS
* PRTNUM
* INPUT=NUM
* SPLITS DIGITS AND PRINTS
PRTNUM         STA  ATEMP
               STY  YTEMP
               JSR  CINIT
               LDA  NUM
               LSR
               LSR
               LSR
               LSR
               CLC
               ADC  #$B0
               JSR  COUT
               LDY  HTAB
               INY
               STY  HTAB
               LDA  NUM
               AND  #$0F
               CLC
               ADC  #$B0
               JSR  COUT
               LDY  HTAB
               INY
               STY  HTAB
               LDA  ATEMP
               LDY  YTEMP
               RTS
* TONUM
* INPUT=NUML,NUMH
* OUTPUT=NUM,A (BOTH SAME)
* (COMBINES DIGITS)
TONUM          LDA  NUMH
               ASL
               ASL
               ASL
               ASL
               CLC
               ADC  NUML
               STA  NUM
               RTS
* TONUMA
* INPUT=NUML,NUMH
* OUTPUT=NUM,A (SAME)
* (COMBINES ASCII DIGITS)
TONUMA         LDA  NUMH
               SEC
               SBC  #$B0
               STA  NUMH
               CMP  #$0A
               BMI  TO2
               SBC  #$07
               STA  NUMH
TO2            LDA  NUML
               SBC  #$B0
               STA  NUML
               CMP  #$0A
               BMI  TO3
               SBC  #$07
               STA  NUML
TO3            JMP  TONUM
* FRNUM
* INPUT=NUM
* OUTPUT=NUMH,NUML
* (SPLITS DIGITS)
FRNUM          STA  ATEMP
               LDA  NUM
               LSR
               LSR
               LSR
               LSR
               STA  NUMH
               LDA  NUM
               AND  #$0F
               STA  NUML
               LDA  ATEMP
               RTS
* FRNUMA
* INPUT=NUM
* OUTPUT=NUMH,NUML
* (SPLITS DIGITS TO ASCII)
FRNUMA         STA  ATEMP
               JSR  FRNUM
               LDA  NUML
               CLC
               ADC  #$B0
               STA  NUML
               CMP  #$BA
               BMI  FR2
               ADC  #$07
               STA  NUML
FR2            LDA  NUMH
               ADC  #$B0
               STA  NUMH
               CMP  #$BA
               BMI  FR3
               ADC  #$07
               STA  NUMH
FR3            LDA  ATEMP
               RTS
* KEYIN
* OUTPUT=ASCII,A (BOTH KEYPRESS)
* (WAITS FOR KEYPRESS)
KEYIN          LDA  $C000
               CMP  #$80
               BMI  KEYIN
               STA  $C010
               STA  ASCII
               RTS
* INPUT
* INPUT=HMAX,CURSOR,PROMPTLN,IREG
* OUTPUT=IN IREG
INPUT          STA  ATEMP
               STY  YTEMP
               JSR  CINIT
               LDA  #$00
               STA  ESC
               JSR  INPSUB
I1CURS         LDA  I1
               SEC
               SBC  #$80
               JSR  COUT
I1LOOP         JSR  KEYIN
               CMP  #$8D
               BNE  I1KY
               JMP  RET
I1KY           CMP  #$9B
               BEQ  TOIESC
               CMP  #$B0
               BMI  I1LOOP
               CMP  #$BA
               BPL  I1LOOP
               STA  I1
               JSR  COUT
               INC  HTAB
I2CURS         LDA  I2
               SEC
               SBC  #$80
               JSR  COUT
I2LOOP         JSR  KEYIN
               CMP  #$8D
               BNE  I2KY
               DEC  HTAB
               JMP  RET
I2KY           CMP  #$88
               BNE  I2KZ
               LDA  I2
               JSR  COUT
               DEC  HTAB
               JMP  I1CURS
I2KZ           CMP  #$9B
               BNE  I2KW
               DEC  HTAB
TOIESC         JMP  IESC
I2KW           CMP  #$B0
               BMI  I2LOOP
               CMP  #$BA
               BPL  I2LOOP
               STA  I2
               JSR  COUT
               INC  HTAB
I3CURS         LDA  I3
               SEC
               SBC  #$80
               JSR  COUT
I3LOOP         JSR  KEYIN
               CMP  #$8D
               BNE  I3KY
               DEC  HTAB
               DEC  HTAB
               JMP  RET
I3KY           CMP  #$88
               BNE  I3KZ
               LDA  I3
               JSR  COUT
               DEC  HTAB
               JMP  I2CURS
I3KZ           CMP  #$9B
               BNE  I3KW
               DEC  HTAB
               DEC  HTAB
               JMP  IESC
I3KW           CMP  #$B0
               BMI  I3LOOP
               CMP  #$BA
               BPL  I3LOOP
               STA  I3
               JMP  I3CURS
IESC           LDA  #$FF
               STA  ESC
               JSR  INPSUB
               JMP  RET4
RET            JSR  INPSUB
               LDA  #$00
               STA  LEVEL
               LDA  I1
               SEC
               SBC  #$AF
               STA  J1
               LDA  I2
               SEC
               SBC  #$AF
               STA  J2
               LDA  I3
               SEC
               SBC  #$AF
               STA  J3
RET1           DEC  J1
               BEQ  RET2
               LDA  LEVEL
               CLC
               ADC  #$64
               STA  LEVEL
               BCC  RET1
               JSR  BEEP
               JMP  INPUT
RET2           DEC  J2
               BEQ  RET3
               LDA  LEVEL
               CLC
               ADC  #$0A
               STA  LEVEL
               BCC  RET2
               JSR  BEEP
               JMP  INPUT
RET3           DEC  J3
               BEQ  RET4
               LDA  LEVEL
               CLC
               ADC  #$01
               STA  LEVEL
               BCC  RET3
               JSR  BEEP
               JMP  INPUT
RET4           LDA  ATEMP
               LDY  YTEMP
               RTS
INPSUB         LDA  I1
               JSR  COUT
               INC  HTAB
               LDA  I2
               JSR  COUT
               INC  HTAB
               LDA  I3
               JSR  COUT
               DEC  HTAB
               DEC  HTAB
               RTS
CLS            LDA  #$00
               STA  VTAB
               STA  HTAB
               JSR  CINIT
CLSLOOP        LDA  #$A0
               JSR  COUT
               LDA  HTAB
               CLC
               ADC  #$01
               STA  HTAB
               CMP  #$28
               BMI  CLSLOOP
               LDA  #$00
               STA  HTAB
               JSR  CINIT
               LDA  VTAB
               CLC
               ADC  #$01
               STA  VTAB
               CMP  #$18
               BMI  CLSLOOP
               RTS
F1             HEX  04000480050005800600068007000780
               HEX  042804A8052805A8062806A8072807A8
               HEX  045004D0055005D0065006D0075007D0
I1             HEX  00
I2             HEX  00
I3             HEX  00
J1             HEX  00
J2             HEX  00
J3             HEX  00
L1             HEX  00
L2             HEX  00
L3             HEX  00
L4             HEX  00
IOB            HEX  016001FE
IOB4           HEX  03
IOB5           HEX  00
IOB6           HEX  00
IOB7           HEX  00
IOB8           HEX  00
IOB9           HEX  000000
IOBC           HEX  0000FE6001
TR             HEX  00
S              HEX  00
TR1            HEX  00
S1             HEX  00
TR2            HEX  00
S2             HEX  00
TR3            HEX  00
S3             HEX  00
TR4            HEX  00
S4             HEX  00
DCT            HEX  0001D8EF
