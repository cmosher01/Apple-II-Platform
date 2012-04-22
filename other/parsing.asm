               ORG  $300
TOK1           EQU  $4FFD
TOK2           EQU  $4FFE
NUMERR         EQU  $4FFF
TBL1           EQU  $5000
TBL2           EQU  $5100
TBL3           EQU  $5200
               LDA  #$00
               PHA
               LDA  #$02
               STA  TOK2
               LDA  #$FF
               LDY  #$91
               STA  $FC
               STY  $FD
RESTART        STA  $FA
               STY  $FB
               LDA  #$01
               STA  TOK1
               LDA  $FC
               LDX  $FD
               JSR  FNDNXT
               STA  $FC
               STX  $FD
RSTRT1         LDY  #$00
EQ?            LDA  ($FC),Y
               SEC
               SBC  ($FA),Y
               AND  #$7F
               BNE  ADVSUB
               LDA  ($FA),Y
               BMI  ERR
               LDA  ($FC),Y
               BMI  POSSERR
               INY
               BNE  EQ?
ERR            PLA
               TAX
               LDA  TOK1
               STA  TBL1,X
               LDA  TOK2
               STA  TBL2,X
               INY
CONT           TYA
               STA  TBL3,X
               INX
               TXA
               PHA
ADVSUB         PLA
               TAX
               LDA  #$00
               STA  TBL1,X
               TXA
               PHA
               INC  TOK1
               LDA  TOK1
               CMP  TOK2
               BCC  NXTSUB
               INC  TOK2
               LDA  TOK2
               CMP  #$6C
               BCS  EXIT
               LDA  #$FF
               LDY  #$91
               BNE  RESTART
NXTSUB         LDA  $FA
               LDX  $FB
               JSR  FNDNXT
               STA  $FA
               STX  $FB
               JMP  RSTRT1
EXIT           PLA
               STA  NUMERR
               RTS
FNDNXT         STA  $FE
               STX  $FF
               LDY  #$FF
AGIN           INY
               LDA  ($FE),Y
               BPL  AGIN
               INY
               TYA
               CLC
               ADC  $FE
               BCC  FIN
               INX
FIN            RTS
POSSERR        INY
               LDA  ($FA),Y
               AND  #$7F
               CMP  #$5B
               BCS  ADVSUB
               CMP  #$41
               BCC  ADVSUB
               PLA
               TAX
               LDA  TOK2
               STA  TBL1,X
               LDA  TOK1
               STA  TBL2,X
               BNE  CONT
