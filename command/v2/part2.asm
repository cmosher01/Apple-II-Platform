                               ;
                               ; The Command Interpreter System.
                               ;
                               ; Part Two.  The Program.
                               ;
                               ; January 1988
                               ;
                               ; Christopher A. Mosher
                               ;



                               ; page $00 locations
temp           equ  $FB        ; temporary register
addr           equ  $FC        ; temporary address register (lo hi)
addr2          equ  $FE        ; temporary address register (lo hi)

inptbufr       equ  $0200      ; buffer for line of input

softev         equ  $03F2      ; vector for reset (lo hi)
pwredup        equ  $03F4      ; powered up determination byte

                               ; ProDOS system global page
                               ;
                               ; jump vectors
                               ;
mli            equ  $BF00      ; jump to machine language interface
jspare         equ  $BF03      ; jump to system death handler
datetime       equ  $BF06      ; jump to date/time routine
syserr         equ  $BF09      ; jump to system error handler
sysdeath       equ  $BF0C      ; jump to system death handler
serr           equ  $BF0F      ; system error number
                               ;
                               ; device information
                               ;
                               ; device driver address for device in:
                               ; slot  drive
devadr01       equ  $BF10      ;   0
devadr11       equ  $BF12      ;   1     1
devadr21       equ  $BF14      ;   2     1
devadr31       equ  $BF16      ;   3     1
devadr41       equ  $BF18      ;   4     1
devadr51       equ  $BF1A      ;   5     1
devadr61       equ  $BF1C      ;   6     1
devade71       equ  $BF1E      ;   7     1
devadr02       equ  $BF20      ;   0
devadr12       equ  $BF22      ;   1     2
devadr22       equ  $BF24      ;   2     2
devadr32       equ  $BF26      ;   3     2    (/RAM)
devadr42       equ  $BF28      ;   4     2
devadr52       equ  $BF2A      ;   5     2
devadr62       equ  $BF2C      ;   6     2
devadr72       equ  $BF2E      ;   7     2
devnum         equ  $BF30      ; slot and drive of last device (dsss....)
devcnt         equ  $BF31      ; count (minus 1) of active devices
devlst         equ  $BF32      ; list of active devices (dsssiiii)
copyrght       equ  $BF40      ; copyright notice
irqxitx        equ  $BF50      ; call irq handler at $ffd8 (main BSR)
tempirq        equ  $BF56      ; temporary storage for irq code
bitmap         equ  $BF58      ; bit map of available memory (pages $00-$BF)
buffer1        equ  $BF70      ; open file 1 buffer address
buffer2        equ  $BF72      ; open file 2 buffer address
buffer3        equ  $BF74      ; open file 3 buffer address
buffer4        equ  $BF76      ; open file 4 buffer address
buffer5        equ  $BF78      ; open file 5 buffer address
buffer6        equ  $BF7A      ; open file 6 buffer address
buffer7        equ  $BF7C      ; open file 7 buffer address
buffer8        equ  $BF7E      ; open file 8 buffer address
                               ;
                               ; interrupt information
                               ;
intrupt1       equ  $BF80      ; interrupt handler address (highest priority)
intrupt2       equ  $BF82      ; interrupt handler address
intrupt3       equ  $BF84      ; interrupt handler address
intrupt4       equ  $BF86      ; interrupt handler address (lowest priority)
intareg        equ  $BF88      ; storage for a register
intxreg        equ  $BF89      ; storage for x register
intyreg        equ  $BF8A      ; storege for y register
intsreg        equ  $BF8B      ; storage for s register
intpreg        equ  $BF8C      ; storage for p register
intbnkid       equ  $BF8D      ; bank identification byte
intaddr        equ  $BF8E      ; interrupt return address
                               ;
                               ; general system information
                               ;
date           equ  $BF90      ; date (yyyyyyym mmmddddd)
time           equ  $BF92      ; time (...hhhhh .mmmmmm.)
level          equ  $BF94      ; current file level
bubit          equ  $BF95      ; backup bit
spare1         equ  $BF96      ; (spare)
machid         equ  $BF98      ; machine identification byte:
                               ; value    meaning        _
                               ; 00..0... ][              |
                               ; 01..0... ][plus          |
                               ; 10..0... //e             |
                               ; 11..0... III emulation   |_  type of
                               ; 00..1...                 |   Apple
                               ; 01..1...                 |
                               ; 10..1... //c             |
                               ; 11..1...                _|
                               ; ..00.... (unused)        |
                               ; ..01.... 48k             |_  amount of
                               ; ..10.... 64k             |   RAM available
                               ; ..11.... 128k           _|
                               ; .....x.. (reserved)
                               ; ......x. 80 column card flag
                               ; .......x clock flag
sltbyt         equ  $BF99      ; slot ROM map
pfixptr        equ  $BF9A      ; prefix flag
mliactv        equ  $BF9B      ; mli active flag
cmdadr         equ  $BF9C      ; last mli call return address
savex          equ  $BF9E      ; storage for x register for mli calls
savey          equ  $BF9F      ; storage for y register for mli calls
                               ;
                               ; bank switched RAM routines
                               ;
exit           equ  $BFA0      ; exit routine (main BSR)
exit1          equ  $BFAA      ; exit routine (main BSR)
exit2          equ  $BFB5      ; exit routine (main BSR)
mlient1        equ  $BFB7      ; mli entry
                               ;
                               ; interrupt routines
                               ;
irqxit         equ  $BFD0      ; irq interrupt exit routine
irqxit1        equ  $BFDF      ; irq interrupt exit routine
irqxit2        equ  $BFE2      ; irq interrupt exit routine
romxit         equ  $BFE7      ; exit routine
irqent         equ  $BFEB      ; irq interrupt entry
                               ;
                               ; data
                               ;
bnkbyt1        equ  $BFF4      ; storage for $e000
bnkbyt2        equ  $BFF5      ; storage for $d000
jdeath         equ  $BFF6      ; jump to system death handler (main BSR)
                               ;
                               ; version information
                               ;
ibakver        equ  $BFFC      ; minimum version of kernel for interpreter
iversion       equ  $BFFD      ; version number of interpreter
kbakver        equ  $BFFE      ; minimum version of compatible kernel
kversion       equ  $BFFF      ; version number of kernel
version        equ  $01        ; version number of ProDOS kernel used for
                               ;   this interpreter system
bakver         equ  $00        ; minimum ProDOS kernel version number that
                               ;   is compatible with this interpreter system

                               ; slot ROM locations
set80          equ  $CDBE      ; set up 80 columns
hookup         equ  $CE20      ; set up 80 column hooks
boot           equ  $C600      ; boot disk in slot 6

                               ; Applesoft basic locations
basic          equ  $E000      ; entry point

                               ; monitor ROM locations
init           equ  $FB2F      ; initialize screen
home           equ  $FC58      ; home screen
setkbd         equ  $FE89      ; initialize input as slot 0
setvid         equ  $FE93      ; initialize output as slot 0
getln1         equ  $FD6F      ; get line of input (no prompt)
prbyte         equ  $FDDA      ; print a in hexadecimal
cout           equ  $FDED      ; standard character output subroutine
monitor        equ  $FF69      ; monitor entry point

                               ; mli routines
alloc_int                      equ $40
dealloc_int                    equ $41
quit                           equ $65
read_block                     equ $80
write_block                    equ $81
get_time                       equ $82
create                         equ $C0
destroy                        equ $C1
rename                         equ $C2
set_file_info                  equ $C3
get_file_info                  equ $C4
online                         equ $C5
set_prefix                     equ $C6
get_prefix                     equ $C7
open                           equ $C8
newline                        equ $C9
read                           equ $CA
write                          equ $CB
close                          equ $CC
flush                          equ $CD
set_mark                       equ $CE
get_mark                       equ $CF
set_eof                        equ $D0
get_eof                        equ $D1
set_buf                        equ $D2
get_buf                        equ $D3



cmdtbl         equ  $A000      ; command table



               org  $B000
                               ; global table
coldentr       jmp  comsys     ; cold entry point
warmentr       jmp  mainloop   ; warm entry point
resetent       jmp  reset      ; reset handler entry point
                               ;
frstpag        dfb  >coldentr  ; first page used by system
lastpag        dfb  >last-1    ; last page used by system
                               ;
prompt                         ; prompt string (maximum length, 8 bytes)
                               ; (terminated with 0)
               asc             "$ "
               dfb  $00        ;
               ds   $06        ; filler
                               ;
comtbl         ds   $02        ; address of start of command table for srchtbl
edcomtbl       ds   $02        ; address of end of command table for srchtbl
                               ;
databuf        dfb  $00,$20    ; address of data buffer for command directory
                               ;
pthad                          ; address of default pathname
               dfb  <pth,>pth
                               ;
inpthad                        ; address of current input pathname
               dfb  <inpth,>inpth
                               ;
otpthad                        ; address of current output pathname
               dfb  <otpth,>otpth
                               ;
parms                          ; parameter list for mli calls
               ds   $20        ; maximum of $20 bytes
                               ;
mlipth                         ; storage for pathname for mli calls
               ds   $40        ; maximum of $40 bytes
                               ;
cmddirfl       dfb  $00        ; command directory file reference number
                               ;
               asc             "Command System"
               asc             "Christopher A. Mosher"



endglb         ds   $B100-endglb
kbuf           dfb  $00        ; one kilobyte buffer must be page-alligned !!!
               ds   $03FF



pth                            ; current default pathname
                               ; (maximum length, $3f bytes)
                               ; (terminated with 0)
                               ; (initially commands subdirectory)
               asc             "/command/commands"
               dfb  $00
               ds   $2E



inpth                          ; current input pathname
                               ; (maximum length, $3f bytes)
                               ; (terminated with 0)
                               ; (initially the keyboard)
               asc             "/keyboard"
               dfb  $00
               ds   $36



otpth                          ; current output pathname
                               ; (maximum length, $3f bytes)
                               ; (terminated with 0)
                               ; (initially the screen)
               asc             "/screen"
               dfb  $00
               ds   $38



comsys                         ; command interpreter system

               lda  mli        ; insure ProDOS is active
               cmp  #$4C
               beq  initstk
               jmp  boot

initstk        ldx  #$FF       ; initialize stack
               txs

               lda  #<resetent ; initialize reset vector
               sta  softev
               lda  #>resetent
               sta  softev+1
               eor  #$A5
               sta  pwredup

               sec             ; allocate interpreter in system memory map
               lda  lastpag
               sbc  frstpag
               tax
               inx
               lda  frstpag
               jsr  allocpgs
               bcc  initver
               jmp  boot

initver        lda  #version   ; initialize version numbers
               sta  iversion
               lda  #bakver
               sta  ibakver

               jsr  setkbd     ; initialize screen
               jsr  setvid
               jsr  init
               jsr  home
               jsr  chkset80

               jsr  prtapl     ; print initial message
               jsr  print
               asc             "Professional Disk Operating System."
               hex             8D
               asc             "Command System."
               hex             8D8D00

                               ; start processing
               jsr  readcmds   ; read command filenames from disk
                               ; jsr initcom ; execute initial command file
mainloop       jsr  getcom     ; get a command
               jsr  proccom    ; process the command
               jmp  mainloop



                               ;
                               ; allocate memory pages.
                               ; input : a: starting page number
                               ;         x: length (pages)
                               ;
                               ; output: c: set  : page already allocated
                               ;            clear: successfully allocated
                               ;
allocpgs       clc
alp1           dex
               bmi  exapgs
               dfb  $DA        ; phx
               pha
               jsr  allocpg
               pla
               dfb  $1A        ; ina
               dfb  $FA        ; plx
               bcc  alp1
exapgs         rts
allocpg        pha             ; abcdefgh (bit map)
               and  #7         ; 00000fgh (number of bit in byte)
               tay
               ldx  mask,y
               pla             ; abcdefg
               lsr             ; 0abcdefg
               lsr             ; 00abcdef
               lsr             ; 000abcde (number of byte in bitmap table)
               tay
               txa
               and  bitmap,y
               bne  erapg
               txa
               ora  bitmap,y
               sta  bitmap,y
               clc
               dfb  $89        ; bit absorbs sec
erapg          sec
               rts
mask           hex             8040201008040201



chkset80                       ; set 80 column text screen if available.
               lda  machid
               lsr
               lsr
               bcc  ers80
               jsr  hookup
               jsr  set80
               jsr  home
ers80          rts



prtapl                         ; print machine type and RAM size.
               lda  #$08
               bit  machid
               beq  pask1
               bpl  unknown
               bvs  unknown
               jsr  print
               asc             "Apple //c with "
               dfb             0
               jmp  prtmem
pask1          bpl  erpa
               bvs  a3
               jsr  print
               asc             "Apple //e with "
               dfb             0
               lda  #0
               beq  prtmem
a3             jsr  print
               asc             "Apple III emulation with "
               dfb             0
               lda  #0
               jsr  prtmem
unknown        jsr  print
               asc             "Unknown type of machine with "
               dfb             0
               lda  #0
               beq  prtmem
erpa           jsr  print
               asc             "Incompatible type of machine."
               dfb             0
               jmp  boot
prtmem         lda  machid
               asl
               asl
               asl
               bcc  m48
               asl
               bcs  m128
               jsr  print
               asc             "64"
               dfb             0
               lda  #0
               beq  prtrst
m48            jsr  print
               asc             "48"
               dfb             0
               lda  #0
               beq  prtrst
m128           jsr  print
               asc             "128"
               dfb             0
prtrst         jsr  print
               asc             " kilobytes of random access memory."
               hex             8D00
               rts



print          pla
               sta  addr
               pla
               sta  addr+1
               ldy  #$01
prl1           lda  (addr),y
               beq  prs1
               jsr  cout
               iny
               bne  prl1
prs1           clc
               tya
               adc  addr
               tay
               lda  #$00
               adc  addr+1
               pha
               dfb  $FA        ; phy
               rts



reset                          ; handle reset button press.
               jsr  setkbd
               jsr  setvid
               jsr  init
               jsr  home
               jsr  chkset80
               jmp  mainloop



comfile                        ; execute command file
               rts



prtprom                        ; print prompt
               ldy  #0
pplp1          lda  prompt,y
               beq  expp
               jsr  cout
               iny
               bne  pplp1
expp           rts



getcom                         ; get a command
               jsr  inpth?
               asc             "/keyboard"
               dfb  $00
               bcs  getkbd
               brk             ; get from file
getkbd         jsr  prtprom
               jsr  getln1
               rts



proccom                        ; process the command
                               ; input : inptbufr: command string terminated
                               ;                   with $8d or $0d
                               ; output: none

               jsr  downcase   ; downcase command string
               lda  #<mainct
               sta  comtbl
               lda  #>mainct
               sta  comtbl+1
               lda  #<edmainct
               sta  edcomtbl
               lda  #>edmainct
               sta  edcomtbl+1
               jsr  srchtbl    ; search the command table mainct
               jsr  srchfil    ; search for pathname (and execute)
               jsr  print
               asc             "Unknown command."
               hex             8D00
               rts

downcase                       ; downcase the input buffer
               ldy  #0
dclp1          lda  inptbufr,y
               beq  exdc
               and  #$80       ; high bit on
               cmp  #$C1
               bcc  dcsk1
               cmp  #$BD
               bcs  dcsk1
               and  #$20       ; downcase
               sta  inptbufr,y
dcsk1          iny
               bne  dclp1
exdc           rts

srchtbl                        ; search for command in table (and execute)
                               ; input : inptbufr: command string, terminated
                               ;                   with $8d, and same case as
                               ;                   entries in command table
                               ;         comtbl  : address (lo hi) of command
                               ;                   table
                               ;         edcomtbl: address (lo hi) of end of
                               ;                   command table
                               ; output: if command found, then executed,
                               ;         otherwise return
               ldx  comtbl
               ldy  comtbl+1
stlp2          cpx  edcomtbl
               bne  stsk2
               cpy  edcomtbl+1
               beq  exst
stsk2          stx  addr
               sty  addr+1
               ldy  #2
               ldx  #$FF
               lda  (addr),y   ; number of required bytes for match
               clc
               adc  #3
               sta  temp       ; offset of last req. byte
stlp1          iny
               inx
               cpy  temp       ; last req. byte
               beq  chkrest
               lda  inptbufr,x
               cmp  (addr),y
               bne  nxtentr
               cmp  #$8D
               beq  nxtentr
               bne  stlp1
chkrest        lda  inptbufr,x
               cmp  #$8D
               beq  fndentr
               cmp  (addr),y
               bne  nxtentr
               iny
               inx
               bne  chkrest
nxtentr        lda  (addr),y
               beq  stsk1
               iny
               bne  nxtentr
stsk1          iny
               clc
               tya
               adc  addr
               tax
               lda  #0
               adc  addr+1
               tay
               bcc  stlp2      ; bra
fndentr        ldy  #0
               lda  (addr),y
               sta  temp
               iny
               lda  (addr),y
               sta  addr+1
               lda  temp
               sta  addr
               jmp  (addr)
exst           rts

srchfil                        ; search for pathname (and execute)
               rts



direct                         ; directory command
               rts



readcmds                       ; read command filenames from disk
               lda  #3         ; 3 parameters
               sta  parms
               lda  #<mlipth   ; address of pathname
               sta  parms+1
               lda  #>mlipth
               sta  parms+2
               ldx  #0         ; pathname
movepth        lda  pth,x
               beq  storlen
               sta  mlipth+1,x
               inx
               bne  movepth
storlen        stx  mlipth
               lda  #<kbuf     ; must be $00 (page-alligned)
               sta  parms+3
               lda  #>kbuf
               sta  parms+4
               jsr  mli        ; open command directory
               dfb  open
               dfb  <parms,>parms
               bcc  rdcmsk1    ; if no error
               brk             ; if cannot open
rdcmsk1        lda  parms+5    ; reference number
               sta  cmddirfl   ; command directory file (reference number)
               lda  #0
               sta  rdblks     ; number of blocks read
               lda  #$04       ; 4 parameters
               sta  parms
               lda  cmddirfl   ; command directory file
               sta  parms+1
               lda  databuf    ; address of data buffer
               sta  addr
               sta  parms+2
               lda  databuf+1
               sta  addr+1
               sta  parms+3
               lda  #$00       ; length (1 block, or $0200 bytes)
               sta  parms+4
               lda  #$02
               sta  parms+5
rdcmlp1        jsr  mli        ; read 1 block from command directory file
               dfb  read
               dfb  <parms,>parms
               bcc  rdcmsk2    ; if no error
               brk             ; if error
rdcmsk2        inc  rdblks     ; number of blocks read
               lda  databuf+2  ; ptr to next block (lo)
               bne  rdcmsk3
               lda  databuf+3  ; ptr to next block (hi)
               beq  setupcmd
rdcmsk3        inc  databuf+1  ; increment data buffer address (hi)
               inc  databuf+1
               lda  databuf
               sta  parms+2
               lda  databuf+1
               sta  parms+3
               bne  rdcmlp1
setupcmd                       ; set up command table
               ldx  rdblks     ; number of blocks read
               txa
               tay
rdcmlp2        dey
               beq  rdcmsk4
               dec  databuf+1
               dec  databuf+1
               bne  rdcmlp2





initcom                        ; execute initial command file
                               ; input : initaddr: address of filename
               ldy  #0
               lda  #<initaddr
               sta  addr
               lda  #>initaddr
               sta  addr+1
iclp1          lda  (addr),y
               beq  icsk1
               sta  inptbufr,y
               iny
               bne  iclp1
icsk1          lda  #$8D
               sta  inptbufr,y
               jsr  srchfil
               rts             ; if not found, just return



inpth?                         ; check current input pathname
                               ; input : string following jsr inpth?
                               ;         inpthad: address of current
                               ;                  input pathname
                               ; output: c: set  : equal
                               ;            clear: not equal
               pla
               sta  addr
               pla
               sta  addr+1
               clc
               lda  addr
               adc  #1
               sta  addr
               lda  addr+1
               adc  #0
               sta  addr+1
               lda  inpthad
               sta  addr2
               lda  inpthad+1
               sta  addr2+1
               ldy  #0
sdlp1          lda  (addr),y
               cmp  (addr2),Y
               bne  ersd
               cmp  #0
               beq  exsd
               iny
               bne  sdlp1
ersd           clc
               ror  temp
               bpl  exsd2      ; bra
exsd           sec
               ror  temp
exsd2          lda  (addr),y
               beq  sdsk1
               iny
               bne  exsd2
sdsk1          clc
               tya
               adc  addr
               sta  addr
               lda  #0
               adc  addr+1
               pha
               lda  addr
               pha
               rol  temp
               rts



last                           ; last address used (plus one)
