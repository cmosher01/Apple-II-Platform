CV             EQU  $25
CH             EQU  $057B
KBD            EQU  $C000      ; R   keyboard (sdddddd):
                               ;       s     : strobe status
                               ;       dddddd: data read
KBDSTRB        EQU  $C010      ; RW  clear strobe
AKD            EQU  $C010      ; R7  any key down status:
                               ;       off: no
                               ;       on : yes
SPEAKER        EQU  $C030      ; R   toggle the state of the speaker
PRBYTE         EQU  $FDDA
PRHEX          EQU  $FDE3
COUT           EQU  $FDED
                               ;
ENTRY          JMP  INTERVAL
COUNT2         DS   1
COUNT1         DS   1
COUNTD         DFB  195
                               ;
INTERVAL       LDA  #$00
               STA  COUNT1
               STA  COUNT2
ILOOP          BIT  KBD        ; 4
               BMI  KEY        ; 2 (no branch)
               SED             ; 2
               LDA  COUNT1     ; 4
               CLC
               ADC  #$01       ; 2
               STA  COUNT1     ; 4  18
               BNE  DELLP      ; 2  20 (no branch)  3  21 (branch)
               LDA  COUNT2     ; 4
               CLC
               ADC  #$01       ; 2
               STA  COUNT2     ; 4
DELLP          CLD
               LDX  COUNTD     ; 4    _
IL1            DEX             ; 2     |
               BNE  IL1        ; 3  5 _|-  5 x 195 - 1 = 974  978
                               ;
               JMP  ILOOP      ; 3 1002  1013  1024
                               ;
PRINT          LDA  #$0E
               STA  CH
               LDA  COUNT2
               LSR
               LSR
               LSR
               LSR
               JSR  PRHEX
               LDA  #$AE
               JSR  COUT
               LDA  COUNT2
               JSR  PRHEX
               LDA  COUNT1
               JSR  PRBYTE
               RTS
                               ;
KEY            LDA  KBD
               AND  #$7F
               CMP  #$03
               BEQ  EXINT
               JSR  PRINT
               BIT  KBDSTRB
               JMP  INTERVAL
                               ;
EXINT          BIT  KBDSTRB
               RTS
