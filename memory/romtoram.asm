                               ;
                               ;
                               ;
                               ; ROM to RAM
                               ; Version V01.00
                               ; Copyright 1988, by Christopher A. Mosher
                               ;
                               ; This program copies ROM ($D000 - $FFFF)
                               ; to main bank switched RAM, and then
                               ; enters the System Monitor.
                               ;
                               ;
                               ;



ADDR           =    $D000      ; address being copied (first is $D000)
MAINSYS        =    $C008
ROMRAM1        =    $C089
RAMRAM1        =    $C08B
MONITOR        =    $FF69



               ORG  $2000

               STA  MAINSYS    ; use main RAM: pages $00-$01, $D0-$FF
               LDA  ROMRAM1    ; read ROM, write RAM, use $D000 bank 1
               LDA  ROMRAM1

               LDX  #0         ; copy $D000 through $FFFF
:LDA           LDA  ADDR,X
               STA  ADDR,X
               INX
               BNE  :LDA
               INC  :LDA+2
               INC  :LDA+5
               BNE  :LDA

               LDA  RAMRAM1    ; read RAM, write RAM, use $D000 bank 1
               LDA  RAMRAM1

               JMP  MONITOR    ; enter System Monitor
