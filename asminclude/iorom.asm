                               ; Video display
                               ;    _
etysto?        }    $C018      ; R7  |  eighty store switch:
ftysto         }    $C000      ; W   |    off:  page2 (page1/page2)
etysto         }    $C001      ; W  _|    on :  page2 (main /aux  )
                               ;    _
etycol?        }    $C01F      ; R7  |  eighty columns switch:
ftycol         }    $C00C      ; W   |    off:  forty column display
etycol         }    $C00D      ; W  _|    on :  eighty column display
                               ;    _
                               ;altcs? } $C01E ; R7  |  alternate character set switch:
                               ;prmcs } $C00E ; W   |    off: display primary characters
                               ;altcs } $C00F ; W  _|    on : display alternative characters
                               ;    _
                               ;text? } $C01A ; R7  |  text switch:
                               ;graphics } $C050 ; RW  |    off: graphics mode
                               ;text } $C051 ; RW _|    on : text mode
                               ;    _
mixed?         }    $C01B      ; R7  |  mixed switch:
fullscrn       }    $C052      ; RW  |    off: full screen mode
mixed          }    $C053      ; RW _|    on : mixed text/graphics mode
                               ;    _
page2?         }    $C01C      ; R7  |  page 2 switch:
page1          }    $C054      ; RW  |    off: page1 (or main memory)
page2          }    $C055      ; RW _|    on : page2 (or auxiliary memory)
                               ;    _
hires?         }    $C01D      ; R7  |  high resolution switch:
lores          }    $C056      ; RW  |    off: low resolution mode
hires          }    $C057      ; RW _|    on : high resolution mode
                               ;    _
dhires?        }    $C07F      ; R7  |  double width resolution switch: |ioudis
shires         }    $C05F      ; RW  |    off: normal resolution mode   |must
dhires         }    $C05E      ; RW _|    on : double resolution mode   |be on
                               ;    _
ioudis?        }    $C07E      ; R7  |  IOU disable access switch:
iouen          }    $C07F      ; W   |    off: IOU enabled, dhires disabled
ioudis         }    $C07E      ; W  _|    on : IOU disabled, dhires enabled



                               ; Memory management
                               ;                             _
                               ;        bank  read  write     |
romromd1       }    $C08A      ; R       1    ROM   ROM       |
romramd1       }    $C089      ; RR      1    ROM   RAM       |
ramromd1       }    $C088      ; R       1    RAM   ROM       |
ramramd1       }    $C08B      ; RR      1    RAM   RAM       |
romromd2       }    $C082      ; R       2    ROM   ROM       |
romramd2       }    $C081      ; RR      2    ROM   RAM       |
ramromd2       }    $C080      ; R       2    RAM   ROM       |_  bank switched
ramramd2       }    $C083      ; RR      2    RAM   RAM       |   RAM
                               ;                              |
d2?            }    $C011      ; R7     bank 2 status:        |
                               ;          off: bank 1         |
                               ;          on : bank 2         |
                               ;                              |
rom?           }    $C012      ; R7     read RAM/ROM status:  |
                               ;          off: read RAM       |
                               ;          on : read ROM      _|
                               ;    _
rdaxram?       }    $C013      ; R7  |  read auxiliary RAM switch:
rdmnram        }    $C002      ; W   |    off: read main RAM
rdaxram        }    $C003      ; W  _|    on : read auxiliary RAM
                               ;    _
wtaxram?       }    $C014      ; R7  |  write auxiliary RAM switch:
wtmnram        }    $C004      ; W   |    off: write main RAM
wtaxram        }    $C005      ; W  _|    on : write auxiliary RAM
                               ;    _
axzp?          }    $C016      ; R7  |  alternate zero page and BSR switch:
mnzp           }    $C008      ; W   |    off: enable main memory
axzp           }    $C009      ; W  _|    on : enable auxiliary memory



                               ; Interrupts
                               ;                      _
vbl?           }    $C041      ; R7  off: disabled     |
                               ;     on : enabled      |
vbldis         }    $C05A      ; RW  disable *         |_  VBL
vblen          }    $C05B      ; RW  enable *          |   interrupt
vblint?        }    $C019      ; R7  off: not occurred |
                               ;     on : occurred     |
vblclr         }    $C070      ; R   clear condition  _|
                               ;                      _
xy?            }    $C040      ; R7  off: disabled     |
                               ;     on : enabled      |
falx?          }    $C042      ; R7  off: rising X0    |
                               ;     on : falling X0   |
faly?          }    $C043      ; R7  off: rising Y0    |
                               ;     on : falling Y0   |
xydis          }    $C058      ; RW  disable *         |
xyen           }    $C059      ; RW  enable *          |_  mouse X0/Y0 edge
risx           }    $C05C      ; RW  rising X0 *       |   interrupt
falx           }    $C05D      ; RW  falling X0 *      |
risy           }    $C05E      ; RW  rising Y0 *       |
faly           }    $C05F      ; RW  falling Y0 *      |
xint?          }    $C015      ; R7  off: not occurred |
                               ;     on : occurred     |
yint?          }    $C017      ; R7  off: not occurred |
                               ;     on : occurred     |
xyclr          }    $C048      ; R   clear condition  _|
                               ;
                               ; * ioudis must be off to access these switches.



                               ; Keyboard
                               ;
readkbd        }    $C000      ; R   keyboard (sddddddd):
                               ;       s      : strobe status
                               ;       ddddddd: data read
clearkbd       }    $C010      ; RW  clear strobe
akd?           }    $C010      ; R7  any key down status:
                               ;       off: no
                               ;       on : yes



                               ; Buttons
                               ;
fty?           }    $C060      ; R7  80/40 switch status:
                               ;       off: up
                               ;       on : down
                               ;
opnapl?        }    $C061      ; R7  push button 0 (open-apple) status:
                               ;       off: up
                               ;       on : down
                               ;
sldapl?        }    $C062      ; R7  push button 1 (solid-apple) status:
                               ;       off: up
                               ;       on : down
                               ;
mousbtn?       }    $C063      ; R7  mouse button status:
                               ;       off: up
                               ;       on : down



                               ; Movement
                               ;
pdl0           }    $C064      ; R7  game controller 0 timer status:
                               ;       off: timed out
                               ;       on : not timed out
                               ;
pdl1           }    $C065      ; R7  game controller 1 timer status:
                               ;       off: timed out
                               ;       on : not timed out
                               ;
pdlrst         }    $C070      ; R   reset game controller timer
                               ;
xright?        }    $C066      ; R7  mouse X0 edge status:
                               ;       off: not right
                               ;       on : right
                               ;
yup?           }    $C067      ; R7  mouse Y0 edge status:
                               ;       off: not up
                               ;       on : up



                               ; Speaker
                               ;
speaker        }    $C030      ; R   toggle the state of the speaker



                               ; Disk drive
                               ;          _
drvp0off       }    $C080      ; R   off   |_  stepper
drvp0on        }    $C081      ; R   on   _|   phase 0  (Q0)
                               ;          _
drvp1off       }    $C082      ; R   off   |_  stepper
drvp1on        }    $C083      ; R   on   _|   phase 1  (Q1)
                               ;          _
drvp2off       }    $C084      ; R   off   |_  stepper
drvp2on        }    $C085      ; R   on   _|   phase 2  (Q2)
                               ;          _
drvp3off       }    $C086      ; R   off   |_  stepper
drvp3on        }    $C087      ; R   on   _|   phase 3  (Q3)
                               ;          _
drvoff         }    $C088      ; RW  off   |_  drive
drvon          }    $C089      ; RW  on   _|   motor    (Q4)
                               ;          _
drvsl1         }    $C08A      ; RW  1     |_  drive
drvsl2         }    $C08B      ; RW  2    _|   select   (Q5)
                               ;          _                  _
drvrd          }    $C08C      ; RW  shift |_  data           |
drvwr          }    $C08D      ; RW  load _|   register (Q6)  |_ four way
                               ;          _                   |  switches *
drvrdm         }    $C08E      ; RW  read  |_  set            |
drvwrm         }    $C08F      ; RW  write_|   mode     (Q7) _|
                               ;
                               ; * four way Q6/Q7 switches:
                               ;     rd rdm  Enable read sequencing.
                               ;     rd wrm  Shift data register every four
                               ;             cycles while writing.
                               ;     wr rdm  Check write protect and
                               ;             inititalize sequencer for writing.
                               ;     wr wrm  Load data register every four
                               ;             cycles while writing.
                               ;
                               ; access:
                               ;   ldx  #$s0        ; s: slot
                               ;   lda  drv.....,x  ; drv.....: switch
                               ;
                               ; addresses:
                               ;   slot      range
                               ;    0    $C080 - $C08F
                               ;    1    $C090 - $C09F
                               ;    2    $C0A0 - $C0AF
                               ;    3    $C0B0 - $C0BF
                               ;    4    $C0C0 - $C0CF
                               ;    5    $C0D0 - $C0DF
                               ;    6    $C0E0 - $C0EF
                               ;    7    $C0F0 - $C0FF
