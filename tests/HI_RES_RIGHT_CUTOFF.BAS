NEW



  10 HGR



 REM WHITE (NORMAL)
  20 HCOLOR = 3 : Y = 0 : GOSUB 1000

 REM GREEN (NORMAL)
  30 HCOLOR = 1 : Y = 2 : GOSUB 1000

 REM CUT OFF ORANGE TO PRODUCE DARK-BROWN
  40 HCOLOR = 5 : Y = 4 : GOSUB 1000

 REM VIOLET (NORMAL)
  50 HCOLOR = 2 : Y = 6 : GOSUB 1000

 REM BLUE (NORMAL)
  60 HCOLOR = 6 : Y = 8 : GOSUB 1000

 REM CUT OFF WHITE TO PRODUCE LIGHT BLUE-GREEN
  70 HCOLOR = 7 : Y =10 : GOSUB 1000



  80 END



1000 HPLOT 278,Y TO 279,Y
1010 RETURN



RUN
