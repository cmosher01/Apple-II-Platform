                               ;
                               ; Mouse Handler (Apple //c)
                               ;
                               ; by Christopher A. Mosher
                               ;
                               ; May, 1987 (updated for ProDOS)
                               ; June, 1986
                               ;
                               ;    This program handles the mouse for use
                               ; by other programs.  It displays a cursor on
                               ; the eighty-column text screen, which the user
                               ; controls with the mouse.
                               ;    The program has three main parts: Mouon,
                               ; Mouoff, and Irqhndl.  Mouon installs the
                               ; interrupt handler's entry address in the
                               ; interrupt vector table in the ProDOS System
                               ; Global Page; and then enables the mouse's
                               ; movement interrupts.  Mouoff will deallocate
                               ; the interrupt and disable the mouse.  Irqhndl
                               ; is the interrupt request handler.  It's
                               ; address is the one installed in the Global
                               ; Page, and it gets control at each interrupt.
                               ;



                               ; page $00 locations
bas            equ  $FA        ; text screen base address ($FA-$FB)
oldbas         equ  $08        ; old text screen base address ($08-$09)
row            equ  $FE        ; storage for row
col            equ  $FF        ; storage for column

                               ; screen hole locations
minl           equ  $0478      ; Clamping minimum to set (low)
minh           equ  $0578      ; Clamping minimum to set (high)
maxl           equ  $04F8      ; Clamping maximum to set (low)
maxh           equ  $05F8      ; Clamping maximum to set (high)
mouxl          equ  $047C      ; X coordinate (low)
mouxh          equ  $057C      ; X coordinate (high)
mouyl          equ  $04FC      ; Y coordinate (low)
mouyh          equ  $05FC      ; Y coordinate (high)
moustat        equ  $077C      ; Mouse status byte:
                               ; bit      meaning
                               ; x....... button down
                               ; .x...... button down still
                               ; ..x..... movement since last read
                               ; ...x.... (reserved)
                               ; ....x... VBL interrupt has occurred
                               ; .....x.. button interrupt has occurred
                               ; ......x. movement interrupt has occurred
                               ; .......x (reserved)

                               ; ProDOS global page
mli            equ  $BF00      ; Machine Language Interface entry
alloc_int      equ  $40
dealloc_int    equ  $41

                               ; I/O ROM locations
page2?         equ  $C01C      ; page two switch
page1          equ  $C054      ;   off: page1 (or main memory)
page2          equ  $C055      ;   on : page2 (or auxiliary memory)

                               ; slot ROM locations
mtable         equ  $C412      ; Start of mouse ROM table
setm           equ  $00        ; Set up mouse mode
servem         equ  $01        ; Set up carry flag and MOUSTAT
posm           equ  $04        ; Set mouse to X and Y coodinates
clampm         equ  $05        ; Set clamping boundaries:
initm          equ  $07        ; Set default values



               org  $9700
               jmp  mouon      ; turn on the mouse
               jmp  mouoff     ; turn off the mouse

cursor         dfb  $42        ; mouse cursor

parms                          ; parameter list for MLI calls
               dfb  2
               dfb  $00
               dfb  <irqhndl,>irqhndl

mouse          dfb  $00,$C4    ; address of mouse routine
mouxls         dfb  $00        ; storage for X coordinate (low)
mouxhs         dfb  $00        ; storage for X coordinate (high)
mouyls         dfb  $00        ; storage for Y coordinate (low)
moustats       dfb  $00        ; storage for mouse status
oldchr         dfb  $00        ; old character value
oldp2s         dfb  $00        ; old page two switch setting
oldy           dfb  $00        ; old Y register value



mouon                          ; turn on the mouse
               lda  #2         ; allocate interrupt
               sta  parms
               jsr  mli
               dfb  alloc_int
               dfb  <parms,>parms
               ldx  #initm     ; set default values
               jsr  mouser
               lda  #$3C       ; set clamping boundaries for X
               sta  maxl
               lda  #$01
               sta  maxh
               lda  #$00
               sta  minl
               sta  minh
               ldx  #clampm
               jsr  mouser
               lda  #$B8       ; set clamping boundaries for Y
               sta  maxl
               lda  #$00
               sta  maxh
               lda  #$01
               ldx  #clampm
               jsr  mouser
               lda  #$03       ; set mouse to movement mode
               ldx  #setm
               jsr  mouser
               lda  row        ; set X and Y coordinates
               asl
               asl
               asl
               sta  mouyl
               lda  #$00
               sta  mouyh
               lda  col
               asl
               asl
               sta  mouxl
               lda  #$00
               rol
               sta  mouxh
               ldx  #posm
               jsr  mouser
               bit  page2?     ; store page2
               php
               jsr  newcur     ; output new cursor and restore and save values
               sta  page1      ; restore page2
               plp
               bpl  exint
               sta  page2
exint          cli             ; enable interrupts
               rts



mouoff                         ; turn off the mouse
               lda  #$00       ; set mouse to off mode
               ldx  #setm
               jsr  mouser
               bit  page2?     ; store page2
               php
               sta  page1      ; remove cursor
               bit  oldp2s
               bpl  l7
               sta  page2
l7             ldy  oldy
               lda  oldchr
               sta  (oldbas),y
               sta  page1      ; restore page2
               plp
               bpl  l9
               sta  page2
l9             lda  mouyls     ; calculate ROW
               lsr
               lsr
               lsr
               sta  row
               lsr  mouxhs     ; calculate COL
               ror  mouxls
               lsr  mouxhs
               ror  mouxls
               lda  mouxls
               sta  col
               lda  #1
               sta  parms
               jsr  mli        ; deallocate interrupt
               dfb  dealloc_int
               dfb  <parms,>parms
               rts

mouser         pha
               lda  mtable,x
               sta  mouse
               pla
               php
               sei
               jsr  domsub
               ror  mouse
               lda  mouxl
               sta  mouxls
               lda  mouxh
               sta  mouxhs
               lda  mouyl
               sta  mouyls
               lda  moustat
               sta  moustats
               plp
               asl  mouse
               rts
domsub         ldx  #$C4
               ldy  #$40
               jmp  (mouse)



irqhndl                        ; interrupt handler
               cld             ;
               ldx  #servem    ;
               jsr  mouser     ; service mouse interrupt
               bcs  erirq      ; if not mouse interrupt then exit
               lda  moustats   ; get mouse status
               lsr             ;
               lsr             ; put movement bit in carry
               bcc  erirq      ; if no movement then exit
               bit  page2?     ; store page2
               php
               jsr  mvehndl    ; handle movement
               sta  page1      ; restore page2
               plp
               bpl  exirq
               sta  page2
exirq          clc
               dfb  $89        ; bit absorbs sec
erirq          sec
               rts

mvehndl                        ; movement handler
               sta  page1      ; remove old cursor
               lda  #$80
               bit  oldp2s
               bpl  l1
               sta  page2
l1             ldy  oldy
               lda  oldchr
               sta  (oldbas),y
               lda  mouyls     ; calculate ROW
               lsr
               lsr
               lsr
               sta  row
               lsr  mouxhs     ; calculate COL
               ror  mouxls
               lsr  mouxhs
               ror  mouxls
               lda  mouxls
               sta  col
newcur         lda  row        ; calculate base address
               jsr  bascalc
               sta  page1      ; choose main/aux memory
               lda  col
               lsr
               bcs  l3
               sta  page2
l3             tay             ; output cursor and save old values
               sty  oldy
               lda  (bas),y
               sta  oldchr
               lda  cursor
               sta  (bas),y
               lda  page2?
               sta  oldp2s
               lda  bas
               sta  oldbas
               lda  bas+1
               sta  oldbas+1
               rts



bascalc        pha             ; text screen base address calculator (ROM)
               lsr
               and  #3
               ora  #4
               sta  bas+1
               pla
               and  #$18
               bcc  bcs1
               adc  #$7F
bcs1           sta  bas
               asl
               asl
               ora  bas
               sta  bas
               rts
