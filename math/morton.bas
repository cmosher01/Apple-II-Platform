 10  GOSUB 60000: REM Initialize
 90  REM 
 91  REM 
 92  REM Main selection loop for MSRSS
 93  REM         This loop gets the user's selection from the main
 94  REM         menu, and executes the proper subroutine.
 95  REM 
 100  GOSUB 3000: REM Display the main menu.
 110  GOSUB 1000: REM Use the mouse to get a selection.
 120  GOSUB 2000: REM Read the selection off the screen.
 130  IF L% = 0 THEN 110: REM If nothing was selected then try again.
 200  IF ST$ = "draw a region" THEN  GOSUB 10000: GOTO 100
 210  IF ST$ = "view encoding of the region" THEN  GOSUB 20000: GOTO 100
 215  IF ST$ = "view the region" THEN  GOSUB 50000: GOTO 100
 220  IF ST$ = "store the region" THEN  GOSUB 30000: GOTO 100
 230  IF ST$ = "retrieve a region" THEN  GOSUB 40000: GOTO 100
 240  IF ST$ = "list all stored regions" THEN  GOSUB 35000: GOTO 100
 250  IF ST$ = "exit" THEN 9000: REM Exit the main loop.
 260  GOTO 110: REM Otherwise, an improper selection; try again.
 990  REM 
 991  REM 
 992  REM Mouse cursor subroutine
 993  REM         This subroutine calls a machine language subroutine
 994  REM         that turns on the mouse, and displays a movable
 995  REM         cursor.  It waits for the buttonpress.
 996  REM 
 1000  POKE RA%,R%: POKE CA%,C%: CALL MN%: WAIT BT%,T7%,T7%: WAIT BT%,T7%: CALL MF%:R% =  PEEK (RA%):C% =  PEEK (CA%): RETURN 
 1990  REM 
 1991  REM 
 1992  REM Screen read subroutine
 1993  REM         This subroutine reads a phrase off of the screen.
 1994  REM 
 2000  POKE RA%,R%: POKE CA%,C%: CALL SR%:L% =  PEEK (LA%):RB% =  PEEK (RA%):CB% =  PEEK (CA%):ST$ = "": IF L% > 0 THEN  FOR I = 0 TO L% - 1:ST$ = ST$ +  CHR$ ( PEEK (SA% + I) - T7%): NEXT 
 2001  RETURN 
 2990  REM 
 2991  REM 
 2992  REM Main menu display
 2993  REM         This subroutine displays the main menu on the screen.
 2994  REM 
 3000  HOME : VTAB 5: HTAB 8: PRINT "main menu:"
 3010  VTAB 8: HTAB 16: PRINT "draw a region"
 3015  PRINT : HTAB 16: PRINT "view encoding of the region"
 3020  PRINT : HTAB 16: PRINT "view the region"
 3025  PRINT : HTAB 16: PRINT "store the region"
 3030  PRINT : HTAB 16: PRINT "retrieve a region"
 3035  PRINT : HTAB 16: PRINT "list all stored regions"
 3040  PRINT : HTAB 16: PRINT "exit"
 3050  RETURN 
 3990  REM 
 3991  REM 
 3992  REM Region window display
 3993  REM         This subroutine displays the region window, a 16x16
 3994  REM         blank area with a border.
 3995  REM 
 4000  VTAB 5: HTAB 8: PRINT "________________"
 4010  PRINT  CHR$ (27) CHR$ (15);: FOR I = 1 TO 16: HTAB 7: PRINT "Z";: HTAB 24: PRINT "_": NEXT : PRINT  CHR$ (14) CHR$ (24);
 4020  VTAB 21: HTAB 8: PRINT "________________"
 4030  POKE 33,40: POKE 32,40: VTAB 6: RETURN 
 8990  REM  
 8991  REM 
 8992  REM Exit
 8993  REM         This routine ends the program. 
 8994  REM 
 9000  TEXT : HOME : END 
 9990  REM 
 9991  REM 
 9992  REM Draw a region
 9993  REM         This subroutine lets the user draw a region, and then
 9994  REM         encodes the data into Morton numbers with sizes.
 9995  REM 
 10000  HOME : GOSUB 4000: PRINT "Draw a region"
 10210  PRINT : PRINT : PRINT "Use the mouse to draw an inverse"
 10215  PRINT "region in the window to the left."
 10220  PRINT "Slowly move the mouse, using"
 10225  PRINT "the button to control the pen-up"
 10230  PRINT "and pen-down actions."
 10235  PRINT : PRINT "Press <space> when finished.": TEXT 
 10300  POKE RA%,5: POKE CA%,9: CALL DN%: REM Turn on the mouse drawer
 10305  POKE CK%,0: WAIT KB%,T7%: GET K$:K% =  ASC (K$): IF K% <  > 32 THEN 10305: REM Wait for <space> while drawing with the mouse
 10307  POKE CK%,0: CALL DF%: REM Turn off the mouse drawer
 10310  POKE 34,7: POKE 33,40: POKE 32,40: HOME : PRINT "Wait";
 10350 SL% =  PEEK (SK%) + ( PEEK (SH%) > T7%) * 256: IF SL% = 0 THEN 10999
 10400  POKE CD%,1: POKE LM% + 1, INT (SL% / 256): POKE LM%,SL% -  PEEK (LM% + 1) * 256
 10410  FOR I = 1 TO SL%: POKE RM% + I - 1, PEEK (RS% + I - 1) - 5: POKE CM% + I - 1, PEEK (CS% + I - 1) - 7: HTAB 6: PRINT 2 * SL% - I". ";: NEXT 
 10420  CALL MZ%: REM Mortonizer: code and compress
 10430 I% = 1: FOR I = 1 TO SL%:Z% =  PEEK (SM% + I - 1): IF Z% < 255 THEN M%(I%,1) =  PEEK (MM% + I - 1):M%(I%,2) = Z%:I% = I% + 1
 10440  HTAB 6: PRINT SL% - I". ";: NEXT :NM% = I% - 1
 10999  TEXT : POKE 34,2: RETURN 
 19990  REM 
 19991  REM 
 19992  REM View encoding of the region
 19993  REM         This subroutine displays the Morton numbers and
 19994  REM         corresponding sizes of the current region.
 19995  REM 
 20000  HOME : VTAB 24: PRINT "#=Morton  s=size";
 20010  FOR I = 1 TO (NM% - 1) / 20 + 1
 20015  VTAB 3: HTAB (I - 1) * 8 + 3: PRINT "#-s"
 20020  FOR J = (I - 1) * 20 + 1 TO I * 20: IF J > NM% THEN 20035
 20025 A% = M%(J,1):B% = M%(J,2)
 20030  HTAB (I - 1) * 8 + 1: PRINT  SPC( (A% < 100) + (A% < 10))A%"-"B%
 20035  NEXT : NEXT : GOSUB 62000: RETURN 
 29990  REM 
 29991  REM 
 29992  REM Store the region
 29993  REM         This subroutine writes the current encoded region
 29994  REM         onto the disk.
 29995  REM 
 30000  HOME : VTAB 5: HTAB 8: PRINT "Store the region"
 30010  VTAB 7: HTAB 16: PRINT "Enter the name of the region: ...............";: HTAB 46: INPUT "";F$:F$ =  LEFT$ (F$,15)
 30011  IF F$ = "" THEN 30999
 30015  VTAB 7: HTAB 16: CALL  - 958: PRINT F$
 30020 A% = AD%: FOR I = 1 TO NM%: POKE A%,M%(I,1):A% = A% + 1: POKE A%,M%(I,2):A% = A% + 1: NEXT 
 30025  ONERR  GOTO 30035
 30030  PRINT D$"bsave /msrss/regions/"F$",a"AD%",l"A% - AD%: POKE 216,0: GOTO 30040
 30035  POKE 216,0: VTAB 7: HTAB 16: PRINT "Error trying to store file.": HTAB 16: PRINT "Try a different name.": GOSUB 62000: GOSUB 30000: GOTO 100
 30040  GOSUB 62000
 30999  RETURN 
 34990  REM 
 34991  REM 
 34992  REM List all stored regions
 34993  REM         This subroutine displays the names of all the
 34994  REM         regions that have been stored on the disk. 
 34995  REM 
 35000  HOME : PRINT : PRINT D$"catalog /msrss/regions": GOSUB 62000: RETURN 
 35990  REM 
 35991  REM 
 35992  REM Retrieve a region
 35993  REM         This subroutine lets the user retrieve a previously
 35994  REM         stored region from the disk.
 35995  REM 
 40000  HOME : VTAB 5: HTAB 8: PRINT "Retrieve a region"
 40010  VTAB 7: HTAB 16: PRINT "Enter the name of the region: ...............";: HTAB 46: INPUT "";F$:F$ =  LEFT$ (F$,15)
 40012  IF F$ = "" THEN 40040
 40015  VTAB 7: HTAB 16: CALL  - 958: PRINT F$
 40017  ONERR  GOTO 40025
 40020  PRINT D$"bload /msrss/regions/"F$: POKE 216,0: GOTO 40030
 40025  POKE 216,0: VTAB 7: HTAB 16: IF  PEEK (222) = 6 THEN  PRINT F$" not found.": GOTO 40028
 40026  PRINT "Error loading file."
 40028  HTAB 16: PRINT "Try again.": GOSUB 62000: GOSUB 40000: GOTO 100
 40030 A% = AD%:NM% = ( PEEK (48840) +  PEEK (48841) * 256) / 2: FOR I = 1 TO NM%:M%(I,1) =  PEEK (A%):A% = A% + 1:M%(I,2) =  PEEK (A%):A% = A% + 1: NEXT 
 40040  GOSUB 62000: RETURN 
 49990  REM 
 49991  REM 
 49992  REM View the region
 49993  REM         This subroutine display the current region.
 49994  REM 
 50000  HOME : GOSUB 4000: PRINT "View the region"
 50010  PRINT : PRINT : PRINT "The current region is in"
 50015  PRINT "the window to the left."
 50020  PRINT : PRINT "Wait."
 50100  FOR I = 1 TO NM%: POKE MM% + I - 1,M%(I,1): POKE SM% + I - 1,M%(I,2): NEXT : POKE SM% + NM%,255
 50200  POKE CD%,0: CALL MZ%: REM Mortonizer: decompress and decode
 50210 SL% =  PEEK (LM%) +  PEEK (LM% + 1) * 256: TEXT : IF SL% = 0 THEN 50350
 50300  INVERSE : FOR I = 1 TO SL%: VTAB  PEEK (RM% + I - 1) + 6: HTAB  PEEK (CM% + I - 1) + 8: PRINT " ";: NEXT : NORMAL : REM Print an inverse space for each row and column pair.
 50350  VTAB 12: HTAB 41: PRINT "Press the mouse button to continue."
 50360  WAIT BT%,T7%,T7%: WAIT BT%,T7%: POKE 34,2: RETURN 
 59990  REM 
 59991  REM 
 59992  REM Initialize
 59993  REM         This routine initializes the variables.
 59994  REM 
 60000  DIM M%(192,2)
 60010 I = 0:J = 0:NM% = 0:I% = 0:R% = 4:C% = 21:RB% = 0:CB% = 0
 60012 A% = 0:B% = 0:L% = 0:SL$ = ""
 60015 T7% = 128:LA% = 253:RA% = 254:CA% = 255:SA% = 512
 60020 DN% = 16384:DF% = 16387:RS% = 16391:CS% = 16647:SK% = 16903
 60030 SH% = 16904:MZ% = 20480:CD% = 20483:LM% = 20484:RM% = 20486
 60040 CM% = 20742:MM% = 20998:SM% = 21254:MN% = 24576:MF% = 24579
 60050 SR% = 25010:AD% = 28672
 60060 BT% =  - 16285:CK% =  - 16368:KB% =  - 16384:D$ = ""
 61000  VTAB 9: CALL  - 958: GOSUB 62000: RETURN 
 61990  REM 
 61991  REM 
 61992  REM Wait for button
 61993  REM         This subroutine waits for the user to press the
 61994  REM         mouse button.
 61995  REM 
 62000  VTAB 24: HTAB 23: PRINT "Press the mouse button to continue.";
 62010  WAIT BT%,T7%,T7%: WAIT BT%,T7%: RETURN 
