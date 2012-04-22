                               ;
                               ; ProDOS System Global Page
                               ;

                               ; Jump vectors
mli            }    $BF00      ; machine language interface entry
alloc_int      }    $40
dealloc_int    }    $41
quit           }    $65
read_block     }    $80
write_block    }    $81
get_time       }    $82
create         }    $C0
destroy        }    $C1
rename         }    $C2
set_file_info  }    $C3
get_file_info  }    $C4
online         }    $C5
set_prefix     }    $C6
get_prefix     }    $C7
open           }    $C8
newline        }    $C9
read           }    $CA
write          }    $CB
close          }    $CC
flush          }    $CD
set_mark       }    $CE
get_mark       }    $CF
set_eof        }    $D0
get_eof        }    $D1
set_buf        }    $D2
get_buf        }    $D3
jspare         }    $BF03      ; Jump to system death handler
datetime       }    $BF06      ; Jump to Date/Time routine
syserr         }    $BF09      ; Jump to system error handler
sysdeath       }    $BF0C      ; Jump to system death handler
sysern         }    $BF0F      ; System error number

                               ; Device information
                               ; Device driver address for device in:
                               ; slot  drive
devadr01       }    $BF10      ;   0
devadr11       }    $BF12      ;   1     1
devadr21       }    $BF14      ;   2     1
devadr31       }    $BF16      ;   3     1
devadr41       }    $BF18      ;   4     1
devadr51       }    $BF1A      ;   5     1
devadr61       }    $BF1C      ;   6     1
devadr71       }    $BF1E      ;   7     1
devadr02       }    $BF20      ;   0
devadr12       }    $BF22      ;   1     2
devadr22       }    $BF24      ;   2     2
devadr32       }    $BF26      ;   3     2    (/RAM)
devadr42       }    $BF28      ;   4     2
devadr52       }    $BF2A      ;   5     2
devadr62       }    $BF2C      ;   6     2
devadr72       }    $BF2E      ;   7     2
devnum         }    $BF30      ; Slot and drive of last device (dsss....)
devcnt         }    $BF31      ; Count (minus 1) of active devices
devlst         }    $BF32      ; List of active devices (dsssiiii)
copyrght       }    $BF40      ; Copyright notice
irqxitx        }    $BF50      ; Call IRQ handler at $FFD8 (Main BSR)
temp           }    $BF56      ; Temporary storage for IRQ code
bitmap         }    $BF58      ; Bit map of low 48K of memory
buffer1        }    $BF70      ; Open file 1 buffer address
buffer2        }    $BF72      ; Open file 2 buffer address
buffer3        }    $BF74      ; Open file 3 buffer address
buffer4        }    $BF76      ; Open file 4 buffer address
buffer5        }    $BF78      ; Open file 5 buffer address
buffer6        }    $BF7A      ; Open file 6 buffer address
buffer7        }    $BF7C      ; Open file 7 buffer address
buffer8        }    $BF7E      ; Open file 8 buffer address

                               ; Interrupt information
intrupt1       }    $BF80      ; Interrupt handler address (highest priority)
intrupt2       }    $BF82      ; Interrupt handler address
intrupt3       }    $BF84      ; Interrupt handler address
intrupt4       }    $BF86      ; Interrupt handler address (lowest priority)
intareg        }    $BF88      ; Storage for A register
intxreg        }    $BF89      ; Storage for X register
intyreg        }    $BF8A      ; Storege for Y register
intsreg        }    $BF8B      ; Storage for S register
intpreg        }    $BF8C      ; Storage for P register
intbnkid       }    $BF8D      ; Bank identification byte
intaddr        }    $BF8E      ; Interrupt return address

                               ; General system information
date           }    $BF90      ; Date (yyyyyyym mmmddddd)
time           }    $BF92      ; Time (...hhhhh .mmmmmm.)
level          }    $BF94      ; Current file level
bakbit         }    $BF95      ; Backup bit
spare1         }    $BF96      ; (Spare)
machid         }    $BF98      ; Machine identification byte:
                               ; value    meaning        _
                               ; 00..0... ][              |
                               ; 01..0... ][+             |
                               ; 10..0... //e             |
                               ; 11..0... III emulation   |_  Type of
                               ; 00..1...                 |   Apple
                               ; 01..1...                 |
                               ; 10..1... //c             |
                               ; 11..1...                _|
                               ; ..00.... (unused)        |
                               ; ..01.... 48K             |_  Amount of
                               ; ..10.... 64K             |   RAM available
                               ; ..11.... 128K           _|
                               ; .....x.. (reserved)
                               ; ......x. 80 column card flag
                               ; .......x Clock flag
sltbyt         }    $BF99      ; Slot ROM map
pfixptr        }    $BF9A      ; Prefix flag
mliactv        }    $BF9B      ; MLI active flag
cmdaddr        }    $BF9C      ; Last MLI call return address
savex          }    $BF9E      ; Storage for X register for MLI calls
savey          }    $BF9F      ; Storage for Y register for MLI calls

                               ; Bank switched RAM routines
exit0          }    $BFA0      ; Exit routine (Main BSR)
exit1          }    $BFAA      ; Exit routine (Main BSR)
exit2          }    $BFB5      ; Exit routine (Main BSR)
mlient1        }    $BFB7      ; MLI entry

                               ; Interrupt routines
irqxit         }    $BFD0      ; IRQ interrupt exit routine
irqxit1        }    $BFDF      ; IRQ interrupt exit routine
irqxit2        }    $BFE2      ; IRQ interrupt exit routine
romxit         }    $BFE7      ; Exit routine
irqent         }    $BFEB      ; IRQ interrupt entry

                               ; Data
bnkbyt1        }    $BFF4      ; Storage for $E000
bnkbyt2        }    $BFF5      ; Storage for $D000
jdeath         }    $BFF6      ; Jump to system death handler (Main BSR)

                               ; Version information
ibakver        }    $BFFC      ; Minimum version of Kernel for interpreter
iversion       }    $BFFD      ; Version number of interpreter
gbakver        }    $BFFE      ; Minimum version of compatible Kernel
gversion       }    $BFFF      ; Version number of Kernel
