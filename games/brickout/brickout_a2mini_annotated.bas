BREAKOUT

Written by Steve Wozniak, 1977.



Annotated by Chris Mosher, 2009.

This is an APPLE ][ Integer BASIC program.

This is the earliest version I have been able
to find so far. This one is from an original
version of the Apple ][ Reference Manual, entitled
"APPLE II MINI MANUAL" from some time in 1977.

Bugs and anomalies:
1. At line 205, "IF P>Q" should be "IF P>=Q".
2. At line 35, there is also one redundant piece of
   code: "X=19" appears twice on that line.
3. At line 35, also, the initialization of X and Y
   to 19 here is anomalous; it will cause the PLOT on
   line 40 to unnecessarily plot the background color
   at pixel (19,6). These initializations could instead
   simply be 0, which would be equally harmless.
4. At line 200, there is also an unnecessary check for
	Q<0. The calculation of Q in the previous statement
	will always leave Q between 0 and 41 inclusive.
5. There is a logic error in that the user can choose
   the same color for the background as one of the other
   objects, which can cause some strange game-play.
   A. If the even or odd brick color is chosen the same
      as the background color, the game cannot be won.
      For example, if the user chooses 1 (red) for the
      background and the even bricks (and chooses something
      else for the other colors) the game will start with
      only half the bricks appearing (because the half that
      are drawn red blend in with the background). You will
      never be able to hit these bricks, because the program
      checks the color (on line 60) "IF SCRN(I,K) = A" to see
      if you hit a brick. So you could clear all the visible
      bricks and have a score of only 360, half what you need
      to win the game. So the game will never end.
      You can get to this point right at the beginning of
      the game if BOTH bricks are chosen the same as
      the background color (your score will forever be 0).
   B. If the paddle is chosen the same as the background
      color, then the paddle will never hit the ball (even
      in demo. mode).
   C. If the ball is chosen the same as the background color,
      then you cannot see it, so it will be hard to hit it
      (although demo. mode works... if you can turn it on).
   Other object combinations of the same color are OK, such
   as even and odd bricks the same color, or the paddle the
   same color as the ball.
6. The program will crash with an error message of ""
   if the user enters a number between -32753 and -32767, inclusive,
   when entering a value for a custom color number. This is
   due to the IF statement on line 100.
   "IF E < 0 OR E > 15 THEN 99" should be
   "IF E < 0 THEN 99 : IF E > 15 THEN 99"
7. Entering more than 20 characters as a response to any question
   causes the program to abort with the error message
   "*** STR OVFL ERR" (string overflow).












First the original version, which can be pasted into an emulator (while
running Integer BASIC, of course):
--------------------------------------ORIGINAL VERSION-----------------------------------------------
5 TEXT: CALL -936: VTAB 4: TAB 10: PRINT "*** BREAKOUT GAME ***": PRINT
7 PRINT "  OBJECT IS TO DESTROY ALL BRICKS WITH 5 BALLS": FOR N=1 TO 7000: NEXT N
10 DIM A$(20),B$(20): GR: PRINT: INPUT "HI, WHAT'S YOUR NAME? ",A$:A=1:B=13:C=9:D=6:E=15: PRINT "STANDARD COLORS, "; A$;
20 INPUT "? ",B$: IF B$#"N" AND B$#"NO" THEN 30: FOR I=0 TO 39: COLOR=I/2*(I<32): VLIN 0,39 AT I
25 NEXT I: POKE 34,20: PRINT: PRINT: PRINT: FOR I=0 TO 15: VTAB 21+I MOD 2: TAB I+I+1: PRINT I;: NEXT I: POKE 34,22: VTAB 24: PRINT: PRINT "BACKGROUND";
27 GOSUB 100: A=E: PRINT "EVEN BRICK";: GOSUB 100: B=E: PRINT "ODD BRICK";: GOSUB 100: C=E: PRINT "PADDLE";: GOSUB 100: D=E : PRINT "BALL";: GOSUB 100
30 POKE34,20:COLOR=A:FORI=0TO39:VLIN0,39ATI:NEXTI:FOR I=20TO34STEP2:TAB I+1:PRINT I/2-9;:COLOR=B:VLIN 0,39 AT I:COLOR=C:FOR J=I MOD 4 TO 39 STEP4
35 VLIN J,J+1 AT I: NEXT J,I: TAB 5: PRINT "SCORE = 0": PRINT: PRINT: POKE 34,21: S=0: P=S: L=S: X=19: Y=19: X=19
40 COLOR=A:PLOTX,Y/3:X=19:Y=RND(120):V=-1:W=RND(5)-2:L=L+1:IFL>5THEN140:TAB6:PRINT"BALL #";L:PRINT:FORI=1TO100:GOSUB200:NEXTI:M=1:N=0
50 J=Y+W: IF J>=0 AND J<120 THEN 60: W=-W: J=Y: FOR I=1 TO 6: K=PEEK(-16336): NEXT I
55 IF PEEK(-16287)>127 THEN SW=1-SW
60 I=X+V: IF I<0 THEN 400: GOSUB 200: COLOR=A: K=J/3: IF I>39 THEN 70: IF SCRN(I,K)=A THEN 90: IF I THEN 120: N=N+1: V=(N>9)+1: W=(K-P)*2-5: M=1
65 Z = PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336): GOTO 90
70 FOR I=1 TO 6: M=PEEK(-16336): NEXT I: I=X: M=0
80 V=-V
90 PLOT X,Y/3: COLOR=E: PLOT I,K: X=I: Y=J: GOTO 50
99 PRINT "INVALID.  REENTER";
100 INPUT " COLOR (0 TO 15)",E: IF E<0 OR E>15 THEN 99: RETURN
120 IF M THEN V=ABS(V): VLIN K/2*2,K/2*2+1 AT I: S=S+I/2-9: VTAB 21: TAB 13: PRINT S
123 Q = PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)
124 IF S<720 THEN 80
130 PRINT "CONGRATULATIONS, YOU WIN.": GOTO 150
140 PRINT "YOUR SCORE OF ";S;" IS ";: GOTO 141+S/100
141 PRINT "TERRIBLE!": GOTO 150
142 PRINT "LOUSY.": GOTO 150
143 PRINT "POOR.": GOTO 150
144 PRINT "FAIR.": GOTO 150
145 PRINT "GOOD.": GOTO 150
146 PRINT "VERY GOOD.": GOTO 150
147 PRINT "EXCELLENT.": GOTO 150
148 PRINT "NEARLY PERFECT."
150 PRINT "SAME COLORS";: GOTO 20
200 IF SW THEN 220: Q=(PDL(0)-5)/6: IF Q<0 THEN Q=0
205 IF Q>=34 THEN Q=34: COLOR=D: VLIN Q,Q+5 AT 0: COLOR=A: IF P>Q THEN 210: IF Q THEN VLIN 0,Q-1 AT 0: P=Q: RETURN
210 IF P=Q THEN RETURN: IF Q#34 THEN VLIN Q+6,39 AT 0: P=Q: RETURN
220 Q=(Y-5)/3+RND(3)*SGN(W)*(X<10 AND V<0): IF Q<0 THEN Q=0: GOTO 205
400 FOR I=1 TO 80: Q=PEEK(-16336): NEXT I: GOTO 40
--------------------------------------END OF ORIGINAL VERSION-----------------------------------------------





Now the same code with full comments added by me:




Variables used:

A$ username
B$ user input value
A  color of background
B  color of even bricks
C  color of odd bricks
D  color of paddle
E  color of ball
I  X coord of next ball pos
J  Y coord of next ball pos * 3
K  Y coord of next ball pos (J/3, plottable Y coord)
L  current ball number (1-5)
M  indicates if we have not just hit the back wall
   (is usually 1, but is 0 when coming off the back wall until next hit)
N  count of paddle hits for the current ball
P  paddle position (Y coord of top pixel of paddle)
Q  temporary value
S  score
SW are we in demo. mode? (1 = yes, auto paddle movement; 0 = no, user moves paddle)
V  ball X movement (V<0 means left, V>0 means right, ABS(V) is speed)
W  ball Y movement (W<0 means up,   W>0 means down,  ABS(W) is speed/angle)
X  ball X position (0-39) (0 is at paddle, 39 is at back wall)
Y  ball Y position * 3 (0-119) (0 is top, 119 is bottom)

Implementation notes:

To make the ball "bounce," change the sign of one of the coordinates
of movement. For example, when the ball is approaching the paddle,
V (the X movement) is negative; to make the ball bounce away toward
the right, set V = -V, which makes V positive, thus making the ball bounce.

Note that all calculations on the Y coordinate are done internally at
a three times scale. Then only upon drawing is the Y coordinate divided
by three (and rounded down). This allows for a precision of one third pixel
(even though we are not using floating point numbers).

Bricks in the first column are 1 point; bricks in the second column are
2 points; etc. up to 8 points per brick in the eighth column. Each brick
is two pixels tall, so there are 20 bricks in each column. That makes
a total of 720 points for all the bricks.

While playing the game, if the paddle button is depressed while the ball
is bouncing off the top or bottom of the screen, it will toggle "demo"
mode. If demo mode is on, then the game controller is ignored, and instead
the program automatically moves the paddle on the screen to hit the ball.




--------------------COMMENTED PROGRAM------------------
5 TEXT : text mode
CALL -936 : clear screen

display title
VTAB 4 : TAB 10 : PRINT "*** BREAKOUT GAME ***" : PRINT

display instructions
7 PRINT "  OBJECT IS TO DESTROY ALL BRICKS WITH 5 BALLS" :

wait a few seconds
FOR N = 1 TO 7000 : NEXT N

10 DIM
A$(20),  username (20 chars maximum)
B$(20) : user input string (20 chars maximum)

GR : low resolution graphics mode (40x40 pixels)

get username
PRINT : INPUT "HI, WHAT'S YOUR NAME? ",A$ :





set default colors:
A=1  : background (red)
B=13 : even brick (yellow)
C=9  : odd brick  (orange)
D=6  : paddle     (blue)
E=15 : ball       (white)


if user wants default colors, skip next section (goto 30)
PRINT "STANDARD COLORS, "; A$;
20 INPUT "? ", B$ : IF B$#"N" AND B$#"NO" THEN 30 : 

Here we display color bars and ask the user to choose a
color for each of the displayed elements of the game.

display color bars
FOR I = 0 TO 39 : 
    COLOR = I/2*(I<32) : 
    VLIN 0, 39 AT I
25
NEXT I : 
set four-line window at bottom of screen:
POKE 34, 20 : PRINT : PRINT : PRINT : 
display color numbers
FOR I = 0 TO 15 : 
    VTAB 21+I MOD 2 : 
    TAB I+I+1 : 
    PRINT I; : 
NEXT I :
set two-line window at bottom of screen:
POKE 34, 22 : 
ask user each color, and put into vars A-E
VTAB 24 : PRINT :

PRINT "BACKGROUND";
27                    GOSUB 100 : A=E : 
PRINT "EVEN BRICK"; : GOSUB 100 : B=E : 
PRINT  "ODD BRICK"; : GOSUB 100 : C=E : 
PRINT     "PADDLE"; : GOSUB 100 : D=E : 
PRINT       "BALL"; : GOSUB 100





new game starts here (after optionally picking colors)
30 
set 4-line text window at bottom
POKE 34, 20 :

draw background
COLOR = A : FOR I = 0 TO 39 : VLIN 0, 39 AT I : NEXT I :

draw bricks and column numbers (points)
FOR I = 20 TO 34 STEP 2 :
    TAB I+1 : PRINT I/2-9; :
    COLOR = B : VLIN 0, 39 AT I :
    COLOR = C :
    FOR J = I MOD 4 TO 39 STEP 4
35      VLIN J, J+1 AT I :
    NEXT J,
I :

display score
TAB 5 : PRINT "SCORE = 0" : PRINT : PRINT :

set 3-line window at bottom
POKE 34, 21 : 

S =  0 : score (col n brick is n points; 720 is full game all bricks)
P =  S : paddle position (Y coord of top pixel of paddle)
L =  S : current ball # (1-5)
X = 19 : ball X position
Y = 19 : ball Y position * 3
X = 19   (BUG: redundant)

Note that X must start out less than 20 so it does not
erase a brick in the PLOT at line 40.

new ball starts here
40
COLOR = A : PLOT X, Y/3 : erase any previous ball

set initial ball postion (X,Y) and movement vectors (V,W)
X = 19 :       (at the bricks)
Y = RND(120) : (random 0-39 * 3)
V = -1 :       ball X movement (V<0 means left, V>0 means right, ABS(V) is speed)
W = RND(5)-2 : ball Y movement (W<0 means up,   W>0 means down,  ABS(W) is speed/angle)

L = L+1 : next ball

IF L > 5 THEN 140 : if we just missed our last ball, game over (goto 140)

display ball number
TAB 6 : PRINT "BALL #"; L : PRINT : 

do not start the game yet, wait a while (but still let the user
move the paddle, thus GOSUB 200)
FOR I = 1 TO 100 : GOSUB 200 : NEXT I : 

M = 1 : we did not just bounce off the back wall
N = 0   count of paddle hits for the current ball



here we MOVE THE BALL:
first move the Ypos (and check if we hit top or bottom)
50 J = Y+W : calc next Ypos of ball (new Ypos = old Ypos + Ymovement)
IF J >= 0 AND J < 120 THEN 60 : new value did not go off top or bottom, so go to 60 (move Xpos)
else, the ball hit the top or bottom, so we need to bounce off
W = -W : set new Ymovement (if was moving up, then set to down; if was moving down, then set to up)
J = Y : restore Ypos (this keeps the ball at the top or bottom edge; it will bounce on the next iteration)
FOR I = 1 TO 6 : K = PEEK(-16336) : NEXT I  make a sound to indicate bounce
55 IF PEEK(-16287) > 127 THEN SW = 1-SW if paddle button depressed, toggle demo. mode

next, move the Xpos
60 I = X+V : calc next Xpos of ball (new Xpos = old Xpos + Xmovement)

if we went off the left edge, the user missed the ball, so make a sound and goto 40
IF I < 0 THEN 400 : 
else (ball still in play somewhere)

GOSUB 200 : (move displayed paddle based on user control, if necessary)

COLOR = A : set to background color (to prepare for erasing a hit brick)

K = J/3 :  calc plottable Y pos (into K)
IF I > 39 THEN 70 : if we hit the back wall (behind the bricks) goto 70

check what is on the screen at the position of the ball (that is, what did we hit?)
IF SCRN(I,K) = A THEN 90 : if we did not hit anything (background color) goto 90

else, we must have hit a brick or the paddle
we can tell which one by checking the X pos of the ball:
IF I THEN 120 :  if Xpos is > 0, then we hit a brick, so goto 120
else, we must have hit the paddle
N = N+1 : increment count of paddle hits for this ball

set Xmovement to positive (towards the bricks), and at a speed of 1 (i.e., slow)
if we have had less than 10 hits this ball, or 2 (i.e., fast) if we have had 10
or more hits.
V = (N>9)+1 :

set Ymovement
the pos of the ball on the paddle is K-P, which should be 0 to 5,
0 being the top of the paddle, and 5 being the bottom. The sets of possible
values of the terms in the calculation of W, below, as shown here:
 K-P = { 0,  1,  2,  3,  4,  5 }
  *2 = { 0,  2,  4,  6,  8, 10 }
  -5 = {-5, -3, -1,  1,  3,  5 }
these represent the angle (up or down) that the ball bounces
off the paddle. So striking near the middle of the paddle sends the
ball straighter, and striking near the edge of the paddle sends the
ball at a more oblique angle, up (for positive W) or down (for negative W)
W = (K-P)*2-5 : 

M = 1 we did not just bounce off the back wall


make a sound
65 Z = PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336) : 
GOTO 90


(we come here if the ball has hit the back wall)
make a sound
70 FOR I = 1 TO 6 : M = PEEK(-16336) : NEXT I :

I = X :  restore Xpos (keep ball at back wall, instead of off the screen)
M = 0  indicate that we have hit the back wall


80 V = -V   ball bounces off of back wall or a brick so toggle X direction

erase previous ball position (plot background color)
90 PLOT X, Y/3 : 


display the ball (new ball position I,K)
COLOR = E : PLOT I, K :

X = I :  new Xpos of ball
Y = J :  new Ypos of ball

GOTO 50








function to ask user for a color (0-15)
	output: E - the color
99 PRINT "INVALID.  REENTER";
100 INPUT " COLOR (0 TO 15)", E : IF E < 0 OR E > 15 THEN 99 : RETURN







(come here if we have hit a brick)

Fix the ball direction.
We do this by making sure the sign of V is correct.
Negative V means move left, and positive V means move right.
However, we will later be toggling the sign (at line 80),
so here we set it to the opposite of what we need it to be.
Usually, when we hit a brick we want to move left after that,
so set V positive here (and it will become negative at line 80).
However there is a special case; after we hit the back wall,
we want the ball to be able to bounce off the back side of the
bricks and go towards the back wall again. So if we have just
hit the back wall (indicated by M being zero), then leave
V as negative (and it will switch to positive at line 80, so
the ball will move right, towards the back wall again).
120 IF M THEN V = ABS(V) : 

erase the whole brick (each brick is two pixels tall)
VLIN K/2*2, K/2*2+1 AT I : 

increase score
S = S+I/2-9 :
display score
VTAB 21 : TAB 13 : PRINT S

make a sound
123 Q = PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-
        PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)

if user has not cleared all the bricks yet, then continue playing (goto 80)
124 IF S < 720 THEN 80
else the user won, so fall through:





game over (win enters at 130, loss enters at 140)
130 PRINT "CONGRATULATIONS, YOU WIN." : GOTO 150   score 720 (only)

140 PRINT "YOUR SCORE OF "; S; " IS "; : GOTO 141+S/100

141 PRINT       "TERRIBLE!" : GOTO 150   score 000-099
142 PRINT          "LOUSY." : GOTO 150   score 100-199
143 PRINT           "POOR." : GOTO 150   score 200-299
144 PRINT           "FAIR." : GOTO 150   score 300-399
145 PRINT           "GOOD." : GOTO 150   score 400-499
146 PRINT      "VERY GOOD." : GOTO 150   score 500-599
147 PRINT      "EXCELLENT." : GOTO 150   score 600-699
148 PRINT "NEARLY PERFECT."              score 700-719




go back to let user pick colors and restart the game
150 PRINT "SAME COLORS"; : GOTO 20






function to move displayed paddle based on user control
  in/out: P on input,  previous position (0-34)
            on output, current  position (0-34)
            (position is Y coord of top-most pixel of paddle)
  in: A background color
      D paddle color
      SW demo. mode (1 or 0)
      if in demo. mode, then also input:
      V ball X movement
      W ball Y movement
      X ball X position
      Y ball Y position

if in demo. mode, then 220
200 IF SW THEN 220 : 

get paddle postion (Q) (top end of paddle)
   PDL(0) paddle 0 --> 0 to 255
   -5  -->  -5 to 250
   /6  -->  0 to 41
   constrain  -->  0 to 34
Q = (PDL(0)-5)/6 : 
IF Q < 0 THEN Q = 0   (unnecessary check; Q cannot be less then zero)
205 IF Q >= 34 THEN Q = 34 : 

draw paddle 6 pixels tall, possible positions: (0,5 to 34,39)
COLOR = D : VLIN Q, Q+5 AT 0 : 

erase old paddle
COLOR = A :
IF P > Q THEN 210 :   BUG! P>Q, should be P>=Q
paddle moved down, so erase area above paddle, and return
IF Q THEN VLIN 0, Q-1 AT 0 :
P = Q : RETURN
paddle did not move, so just return
210 IF P = Q THEN RETURN :
paddle moved up, so erase area below paddle, and return
IF Q # 34 THEN VLIN Q+6, 39 AT 0 :
P = Q : RETURN

demo. mode: ignore real paddle, instead automatically position the
paddle so it hits the ball
if the ball is coming towards the paddle (V<0), and
is close to the paddle (X<10), then add some random wiggle to the paddle
220 Q = (Y-5)/3  +  RND(3)*SGN(W)*(X<10 AND V<0) : IF Q < 0 THEN Q = 0 :
GOTO 205




make a sound, goto 40
400 FOR I = 1 TO 80 : Q = PEEK(-16336) : NEXT I : GOTO 40
--------------------END OF COMMENTED PROGRAM------------------








Finally, a version with fixes for bugs 1-6 described above.
--------------------------------------BUGFIX VERSION-----------------------------------------------
5 TEXT: CALL -936: VTAB 4: TAB 10: PRINT "*** BREAKOUT GAME ***": PRINT
7 PRINT "  OBJECT IS TO DESTROY ALL BRICKS WITH 5 BALLS": FOR N=1 TO 7000: NEXT N
10 DIM A$(20),B$(20): GR: PRINT: INPUT "HI, WHAT'S YOUR NAME? ",A$:A=1:B=13:C=9:D=6:E=15: PRINT "STANDARD COLORS, "; A$;
20 INPUT "? ",B$: IF B$#"N" AND B$#"NO" THEN 30: FOR I=0 TO 39: COLOR=I/2*(I<32): VLIN 0,39 AT I
25 NEXT I: POKE 34,20: PRINT: PRINT: PRINT: FOR I=0 TO 15: VTAB 21+I MOD 2: TAB I+I+1: PRINT I;: NEXT I: POKE 34,22: VTAB 24: PRINT: PRINT "BACKGROUND";
27 A=16:GOSUB 100: A=E: PRINT "EVEN BRICK";: GOSUB 100: B=E: PRINT "ODD BRICK";: GOSUB 100: C=E: PRINT "PADDLE";: GOSUB 100: D=E : PRINT "BALL";: GOSUB 100
30 POKE34,20:COLOR=A:FORI=0TO39:VLIN0,39ATI:NEXTI:FOR I=20TO34STEP2:TAB I+1:PRINT I/2-9;:COLOR=B:VLIN 0,39 AT I:COLOR=C:FOR J=I MOD 4 TO 39 STEP4
35 VLIN J,J+1 AT I: NEXT J,I: TAB 5: PRINT "SCORE = 0": PRINT: PRINT: POKE 34,21: S=0: P=0: L=0: X=0: Y=0
40 COLOR=A:PLOTX,Y/3:X=19:Y=RND(120):V=-1:W=RND(5)-2:L=L+1:IFL>5THEN140:TAB6:PRINT"BALL #";L:PRINT:FORI=1TO100:GOSUB200:NEXTI:M=1:N=0
50 J=Y+W: IF J>=0 AND J<120 THEN 60: W=-W: J=Y: FOR I=1 TO 6: K=PEEK(-16336): NEXT I
55 IF PEEK(-16287)>127 THEN SW=1-SW
60 I=X+V: IF I<0 THEN 400: GOSUB 200: COLOR=A: K=J/3: IF I>39 THEN 70: IF SCRN(I,K)=A THEN 90: IF I THEN 120: N=N+1: V=(N>9)+1: W=(K-P)*2-5: M=1
65 Z = PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336): GOTO 90
70 FOR I=1 TO 6: M=PEEK(-16336): NEXT I: I=X: M=0
80 V=-V
90 PLOT X,Y/3: COLOR=E: PLOT I,K: X=I: Y=J: GOTO 50
99 PRINT "INVALID.  REENTER";
100 INPUT " COLOR (0 TO 15)",E: IF E<0 THEN 99 : IF E>15 THEN 99: IF E=A THEN 99 : RETURN
120 IF M THEN V=ABS(V): VLIN K/2*2,K/2*2+1 AT I: S=S+I/2-9: VTAB 21: TAB 13: PRINT S
123 Q = PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)-PEEK(-16336)
124 IF S<720 THEN 80
130 PRINT "CONGRATULATIONS, YOU WIN.": GOTO 150
140 PRINT "YOUR SCORE OF ";S;" IS ";: GOTO 141+S/100
141 PRINT "TERRIBLE!": GOTO 150
142 PRINT "LOUSY.": GOTO 150
143 PRINT "POOR.": GOTO 150
144 PRINT "FAIR.": GOTO 150
145 PRINT "GOOD.": GOTO 150
146 PRINT "VERY GOOD.": GOTO 150
147 PRINT "EXCELLENT.": GOTO 150
148 PRINT "NEARLY PERFECT."
150 PRINT "SAME COLORS";: GOTO 20
200 IF SW THEN 220: Q=(PDL(0)-5)/6
205 IF Q>=34 THEN Q=34: COLOR=D: VLIN Q,Q+5 AT 0: COLOR=A: IF P>=Q THEN 210: IF Q THEN VLIN 0,Q-1 AT 0: P=Q: RETURN
210 IF P=Q THEN RETURN: IF Q#34 THEN VLIN Q+6,39 AT 0: P=Q: RETURN
220 Q=(Y-5)/3+RND(3)*SGN(W)*(X<10 AND V<0): IF Q<0 THEN Q=0: GOTO 205
400 FOR I=1 TO 80: Q=PEEK(-16336): NEXT I: GOTO 40
--------------------------------------END OF BUGFIX VERSION-----------------------------------------------
