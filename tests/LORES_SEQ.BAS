NEW

REM LO-RES COLORS IN HUE SEQUENCE

  1  GR 

  4  P = 3
  5  FOR X = 0 TO 15
 10    READ C
 20    COLOR = C
 30    VLIN 0,39 AT P
 40    P = P+1
 50    VLIN 0,39 AT P
 60    P = P+1
 70  NEXT X

100  DATA 1,11,3,2,7,6,4,14,12,8,13,9,5,10,15,0

RUN
