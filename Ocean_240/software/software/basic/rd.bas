10 REM ************  Programm READ  ***************
20 CLS 2:SCRN 0,0:INPUT "READ: FILE-1 OR MEMORI-0";R
30 DIM A$(32),N(16):PRINT CHR$(31):IF R=0 GOTO 110
40 INPUT "FILE";FIL$:OPEN "I",#1,FIL$:REM ** READ FILE **
50 FOR I=1 TO 16:A$=INPUT$(1,#1):B=B+1
60 A=ASC(A$):IF A<16 THEN PRINT "0"; ELSE PRINT HEX$(A);
70 IF A$>CHR$(32) THEN 80 ELSE A$=" "
80 IF A$>CHR$(127) AND A$<CHR$(160) THEN A$=" "
90 A$(I)=A$:NEXT I:PRINT "   ";
100 FOR I=1 TO 16:PRINT A$(I);:NEXT I:PRINT:GOTO 50
110 INPUT "ADRES";A:REM    **** READ MEMORI ****
120 PRINT HEX$(A);"* *";:FOR I=1 TO 16:N(I)=PEEK(A)
130 PRINT USING "\\";HEX$(N(I));:A=A+1:NEXT:PRINT "* *";
140 FOR I=1 TO 16:IF N(I)<32 THEN N(I)=0
150 IF N(I)>127 AND N(I)<160 THEN N(I)=0
160 IF CHR$(N(I))<" " THEN PRINT " "; ELSE PRINT CHR$(N(I));
