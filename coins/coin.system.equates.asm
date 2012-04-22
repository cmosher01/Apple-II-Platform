                               ; opcodes
phy            }    $5A        ; phy
ply            }    $7A        ; ply
bit            }    $24        ; bit  $FF

                               ; page $00 addresses
vtab           }    $E0        ; line number for printing
invmask        }    $E1        ; inverse "and" mask
asto           }    $E2        ; storage register
asto2          }    $E3
asto3          }    $E4
htab           }    $E5
htaborg        }    $E6
size           }    $E7
bas            }    $F0        ; base address register for printing ($F0-$F1)
addr           }    $F2
addr2          }    $F4
coin           }    $F6
numcoins       }    $F8        ; number of coins
coinnum        }    $FA        ; coin number
addr3          }    $FC

                               ; page $02
inbufr         }    $0300      ; input buffer

                               ; page $03 locations
resetv         }    $03F2      ; reset vector
reseteor       }    $A5

defs           }    $6000      ; coin definitions

                               ; ProDOS Global Page
mli            }    $BF00      ; machine language interface entry
quit           }    $65
bitmap         }    $BF58      ; bit map of low 48K of memory (pages $00-$BF)
ibakver        }    $BFFC
iversion       }    $BFFD
kbakver        }    $00
kversion       }    $00
machid         }    $BF98      ; machine identification byte

                               ; I/O ROM
page1          }    $C054      ; RW page1 (or main memory)
page2          }    $C055      ; RW page2 (or auxiliary memory)
readkbd        }    $C000      ; R  keyboard (sddddddd)
clearkbd       }    $C010      ; RW clear keyboard strobe
etyentry       }    $C300      ; eighty column (card) entry point
