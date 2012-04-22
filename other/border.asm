*
*        Border
*
*        For use with the Portal program.
*
*        Prints a border in the text window:
*
*         _____________
*        |             |
*        |             |
*        |             |
*        |_____________|
*
*

               ORG  $BCD3
CURRT          EQU  $FBF4
CURUP          EQU  $FC1A
COUT           EQU  $FDED
CROUT          EQU  $FD8E
WWID           EQU  $21
WTOP           EQU  $22
WBOT           EQU  $23
HOME           EQU  $FC58

BORDER         JSR  HOME       Print a border in the text window.
               JSR  CURRT
               JSR  HORIZ
               JSR  CROUT
               JSR  SIDES
               JSR  VBOUT
               JSR  HORIZ
               JSR  VBOUT
               JSR  CURUP
               JSR  CURUP
               JSR  CURRT
               JSR  CURRT
               RTS

VBOUT          LDA  #$FC       Print "|".
               JSR  COUT
               RTS

HORIZ          LDX  #$02       Print horizontal bar.
               LDA  #$DF       "_"
L1             JSR  COUT
               INX
               CPX  WWID
               BNE  L1
               RTS

SIDES          LDY  WTOP       Print vertical sides.
               INY
               INY
               INY
L2             JSR  VBOUT
               LDX  #$01
L3             JSR  CURRT
               INX
               CPX  WWID
               BNE  L3
               JSR  VBOUT
               INY
               CPY  WBOT
               BNE  L2
               RTS
