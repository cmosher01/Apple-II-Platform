                               ;
                               ; Zero Bank Switched Random Access Memory
                               ;
                               ; February 1988
                               ;



               ORG  $0300



STZ            EQU  $9E        ; STZ $FFFF,X

STOR80OF       EQU  $C000
STOR80ON       EQU  $C001
RDMNRAM        EQU  $C002
RDAXRAM        EQU  $C003
WTMNRAM        EQU  $C004
WTAXRAM        EQU  $C005
MNBSR          EQU  $C008
AXBSR          EQU  $C009
RAMROMD2       EQU  $C080
ROMRAMD2       EQU  $C081
ROMROMD2       EQU  $C082
RAMRAMD2       EQU  $C083
RAMROMD1       EQU  $C088
ROMRAMD1       EQU  $C089
ROMROMD1       EQU  $C08A
RAMRAMD1       EQU  $C08B



               STA  MNBSR
               LDA  RAMRAMD1
               LDA  RAMRAMD1

               LDX  #0
LP1            DFB  STZ,$00,$D0
               INX
               BNE  LP1
               INC  LP1+2
               BNE  LP1

SK1            LDA  RAMRAMD2
               LDA  RAMRAMD2

LP2            DFB  STZ,$00,$D0
               INX
               BNE  LP2
               INC  LP2+2
               LDA  LP2+2
               CMP  #$E0
               BNE  LP2

               STA  AXBSR
               LDA  RAMRAMD1
               LDA  RAMRAMD1

LP3            DFB  STZ,$00,$D0
               INX
               BNE  LP3
               INC  LP3+2
               BNE  LP3

SK2            LDA  RAMRAMD2
               LDA  RAMRAMD2

LP4            DFB  STZ,$00,$D0
               INX
               BNE  LP4
               INC  LP4+2
               LDA  LP4+2
               CMP  #$E0
               BNE  LP4

               STA  MNBSR
               LDA  ROMROMD1
               JMP  $FF69
