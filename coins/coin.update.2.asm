fldmenu                        ; field menu
                               ; i: a (as prfld: $1-$A only)
                               ;    x (which one to start at)
                               ; o: c clear: x (chosen entry)
                               ;    c set  : none (<esc> was pressed)
               cmp  #7
               beq  fms1
               cmp  #8
               beq  fms1
               cmp  #9
               bne  fms2
fms1           ora  #$10       ; change $7,$8,$9 to $17,$18,$19
fms2           sta  asto       ; asto : for prfld ($1-$6, $17-$19, or $A)
               stx  asto2      ; asto2: current entry in the data block
               and  #$0F
               jsr  getfldsz
               sta  size       ; size : field size (# of entries)

               jsr  ttlhome

               lda  #11        ; output "->" cursor
               sta  vtab
               jsr  bc
               ldy  #0
               lda  #"-"
               jsr  cout
               lda  #">"
               jsr  cout

               lda  asto2      ; get starting x value
               pha             ; save it (for after fmdspfls)
               cmp  #7         ; if it is < 7 then do special beginning
               blt  fmspec

                               ; do regular beginning
               lda  #4
               sta  vtab       ; vtab := 4
               lda  asto2
               sbc  #7         ; (c set from blt) a := current entry # - 7
               bge  fmdspfls   ; go display the fields (asto2 >= 7)

fmspec         lda  #12        ; do special beginning
               sbc  asto2      ; (c clear from blt)
               sta  vtab       ; vtab := 11 - starting entry #
               lda  #0         ; a := 0 (first entry in list)

                               ; display the fields
                               ; input: vtab, a (starting ent # to dsp)
fmdspfls       tax             ; for prfld (a already in x for future
                               ; interations of the loop (see note below)
fmdl           pha             ; save current entry # to display
               jsr  bc         ; use vtab to calculate bas
               lda  asto       ; a for prfld
               pha             ; save
               ldy  #3
               jsr  prfld
               pla
               sta  asto       ; restore asto
               pla             ; get entry # of entry just displayed
               tax
               inc  vtab
               lda  vtab
               cmp  #20        ; if next vtab is 20,
               beq  fml1x      ; then we're done; exit loop
               inx             ; inc x to next entry # to display
               txa             ; so we can pha during the next interation
                               ; the x value is correct for the prfld call
                               ; in the next iteration, thus no tax before it
               cmp  size
               blt  fmdl       ; if entry to dsp is < size then repeat

fml1x          pla
               sta  asto2      ; restore asto2

                               ; for each command routine called:
                               ;   asto, asto2, size are avail.
                               ;   it must preserve these three
fmcmdl         jsr  fetch      ; command loop for field menu
               cmp  #$88       ; <left-arrow>
               bne  fmcs1
               jmp  fmsup      ; up (jmps to fmcmdl)
fmcs1          cmp  #$8B       ; <up-arrow>
               bne  fmcs2
               jmp  fmsup      ; up (jmps to fmcmdl)
fmcs2          cmp  #$8A       ; <down-arrow>
               bne  fmcs3
               jmp  fmsdw      ; down (jmps to fmcmdl)
fmcs3          cmp  #$95       ; <right-arrow>
               bne  fmcs4
               jmp  fmsdw      ; down (jmps to fmcmdl)
fmcs4          cmp  #$8D       ; <return>
               bne  fmcs5
               jmp  fmsret     ; done (rtss out of fldmenu)
fmcs5          cmp  #$9B       ; <esc>
               bne  fmcs6
               jmp  fmsesc     ; quit (rtss out of fldmenu)
fmcs6          cmp  #$89       ; <tab>
               bne  fmcmdl
               jmp  fmsadd     ; add (jmps to fldmenu)



fmsup          lda  asto2      ; current entry #
               beq  fmux       ; if it is zero then we can't move up; exit
               jsr  scrolldw   ; scroll lines 4-19 down (don't clear line 4)
               dec  asto2      ; we are going to the previous entry
               lda  #4
               sta  vtab       ; vtab 4
               jsr  bc
               ldy  #3         ; htab 3
               lda  asto2
               pha             ; save asto2 (for the end)
               sbc  #6         ; (c clr form bc) a := new entry # to display
               bge  fmus1      ; if a was >= 6 then it's now okay; display it
               cmp  #-1        ; if the new entry would be -1,
               beq  fmus3      ; then we need to clear line 4
               bne  fmus2      ; otherwise just exit (line 4 is already clear)
fmus1          tax             ; display new entry  (x := new ent #)
               lda  asto       ; get a for prfld
               pha             ; save it
               jsr  prfld
               pla
               sta  asto       ; restore asto
               cpy  #80
               beq  fmus2
fmus3          jsr  esce
fmus2          pla
               sta  asto2      ; restore asto2
fmux           jmp  fmcmdl



fmsdw          lda  asto2      ; current entry #
               tax
               inx
               cpx  size       ; if the next entry #
               bge  fmux       ; is >= size then we can't move down; exit
               jsr  scrollup   ; scroll lines 4-19 up (don't clear line 19)
               inc  asto2      ; we are going to the next entry
               lda  #19
               sta  vtab       ; vtab 19
               jsr  bc
               ldy  #3         ; htab 3
               lda  asto2
               pha             ; save asto2 (for the end)
               adc  #8         ; (c clr form bc) a := new entry # to display
               bcs  fmds1      ; so we don't wrap around to beginning of list
               cmp  size
               blt  fmus1      ; if it is < size then its okay; display it
fmds1          beq  fmus3      ; or else we need to clear line 19 (if it's 0)
               bne  fmus2      ; or else just exit (line 19 is already clear)



fmsret         ldx  asto2
               clc
               rts



fmsesc         sec
               rts



fmsadd         lda  size
               cmp  #255       ; if there are already 255 entries
               beq  fmfull     ; then print message and jmp fmcmdl
               lda  asto
               pha             ; save asto
               jsr  getadent   ; get entry and add it (or handle <esc>)
               pla
               and  #$0F       ; $17-$19 --> $7-$9
               ldx  asto2
               jmp  fldmenu    ; reenter field menu (using asto2 for x)

fmfull                         ; field is full!
               lda  #11        ; clear existing "->"
               sta  vtab
               jsr  bc
               ldy  #0
               lda  #$A0
               jsr  cout
               lda  #$A0
               jsr  cout
               lda  #22        ; print message
               sta  vtab
               jsr  bc
               ldy  #0
               jsr  prmess
               asc             "-> Cannot add to this list; "
               asc             "there are 255 entries."
               dfb  0
               jsr  waitkey
               ldy  #0
               jsr  esce
               lda  #11        ; reprint original "->"
               sta  vtab
               jsr  bc
               ldy  #0
               lda  #"-"
               jsr  cout
               lda  #">"
               jsr  cout
               jmp  fmcmdl
