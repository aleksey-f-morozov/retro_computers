; RS232 - программа приёма и передачи данных по COM порту.

.RADIX 16
RLAT	SET	0BFEC
SYMB	EQU	0E2E9
KL	EQU	0E18F
INV	EQU	0E850
STAT	SET	0E113
MEMH	SET	04000
MEMO	SET	MEMH+10
MEMS	SET	MEMH+20
MONTR	SET	0E003
	JMP MAIN
DGRF:	DB "*** INPUT,OUTPUT Data RS232 V1.0 ***",0
INFO:	DB "1- Input data",0D,0A
	DB "2- Continue input",0D,0A
	DB "3- Output data",0D,0A
	DB "    [ ]",8,8,0
TABL:	DB "( SBROS - to EXIT )",0D,0A,0A
	DB "Addr  HexCod   Voltage  P/Num  Times",0D,0A,0
MAIN:	MVI C,1F
	CALL SYM
	LXI D,010A
	CALL SCRN
	LXI D,DGRF
	CALL PRINT
	LXI D,0300
	CALL SCRN
	LXI D,INFO
	CALL PRINT
	LXI H,MEMS
	LDA MEMO
	CPI "A"
	JNZ INPUT
	LDA MEMO+1
	CPI "Z"
	JNZ INPUT
INKE:	CALL KLV
	CPI 03
	JZ MONTR
	CPI "3"
	JZ OUTD
	CPI "2"
	JZ CONT
	CPI "1"
	JNZ INKE
INPUT:	MVI C,"1"
	CALL SYM
	SHLD MEMH
	LXI H,0
	SHLD MEMO+6
	SHLD MEMO+8
	SHLD MEMO+0A
	LHLD MEMH
INPU:	LXI D,0800
	CALL SCRN
	LXI D,TABL
	CALL PRINT
INPA:	CALL INP
	JZ INPO
	CALL KLV
	CPI 03
	JNZ INPA
	JMP EXIT
INPO:	CALL A0D
	CALL HEXH
	CALL PRB
	MVI C,3
	LXI D,MEMO+4
IPIN:	LDAX D
	MOV M,A
	CALL HEX
	INX H
	DCX D
	MOV A,H
	CPI 0B0
	JZ XIT
	DCR C
	JNZ IPIN
	SHLD MEMH
	CALL PRB
	CALL VOLT
	CALL PRB
	LHLD MEMO+6	;SCHETCHIK
	INX H
	SHLD MEMO+6
	CALL DVD
	CALL DVDPR
	CALL PRB
	LHLD MEMO+8	;E-8,D-9,L-A,H-B
	XCHG
	LHLD MEMO+0A
	INR E
	MOV A,E
	CPI 1E
	JNZ TIM2
	MVI E,0
	INR L
	INR D
	MOV A,D
	ANI 03
	JZ TIM1
	INR E
TIM1:	MOV A,D
	CPI 1D
	JNZ TIM2
	DCR E
	MVI D,0
TIM2:	MOV A,L
	CPI 3C
	JNZ TIM3
	INR H
	MVI L,0
TIM3:	SHLD MEMO+0A
	XCHG
	SHLD MEMO+8
	CALL TIME
INU:	LHLD MEMH
	JMP INPA
CONT:	CALL SYM
	LHLD MEMH
	JMP INPU

VOLT:	PUSH H
	PUSH D
	LDA MEMO+2
	MOV E,A
	LDA MEMO+3
	MOV D,A
	LDA MEMO+4
	MVI C,"-"
	ANI 08
	JZ VL1
	MVI C,"+"
VL1:	CALL SYM
	LDA MEMO+4
	ANI 07
	MOV B,A
	CALL DVDES
	MOV A,E
	ANI 0F0
	RRC
	RRC
	RRC
	RRC
	CALL HE1
	MVI C,"."
	CALL SYM
	MOV A,E
	ANI 0F
	CALL HE1
	CALL HEXH
	POP D
	POP H
	RET

TIME:	LXI H,0
	LDA MEMO+0B
	MOV L,A
	CALL DVD
	MOV A,E
	CALL HEX
	MVI C,":"
	CALL SYM
	LDA MEMO+0A
	MOV L,A
	CALL DVD
	MOV A,E
	JMP HEX

DVDES:	LXI H,0		;>B,D,E< <E,H,L>
	MOV C,H
DV0:	MOV A,B
	RRC
	RRC
	RRC
	RLC
	MOV B,A
	CALL DV2
	MOV A,B
	RLC
	MOV B,A
	CALL DV2
	MOV A,B
	RLC
	MOV B,A
	CALL DV2
	MVI B,10
DV1:	MOV A,E
	RLC
	MOV E,A
	MOV A,D
	RAL
	MOV D,A
	CALL DV2
	DCR B
	JNZ DV1
	MOV E,C
	RET	;END
DV2:	MOV A,L
	ADC L
	DAA
	MOV L,A
	MOV A,H
	ADC H
	DAA
	MOV H,A
	MOV A,C
	ADC C
	DAA
	MOV C,A
	RET

INP:	CALL STAT
	ORA A
	RNZ
	LXI B,0003
	LXI D,MEMO+2
IN0:	IN 0A1
	ANI 02
	JNZ IN1
	DCR B
	JZ INP
	JMP IN0
IN1:	IN 0A0
	STAX D
	DCR C
	RZ
	INX D
	JMP IN0

OUTD:	CALL SYM
	LXI D,0700
	CALL SCRN
	LXI D,OUFO
	CALL PRINT
	LHLD MEMO+6
	CALL DVD
	CALL DVDPR
	LXI D,OUTO
	CALL PRINT
	XCHG
	LXI H,MEMS
RP0:	MVI B,3
RP1:	IN 0A1
	CPI 1
	JZ RP1
	MOV A,M
	OUT 0A0
	INX H
	DCR B
	JNZ RP1
	DCX D
	PUSH D
	XCHG
	CALL A0D
	CALL DVD
	CALL DVDPR
	POP D
	MOV A,E
	ORA D
	JZ QUIT
	JMP RP0

DVD:	PUSH H
	LXI D,0		;>H,L< <A,D,E>
	MOV C,D
	MVI B,10
DS0:	MOV A,L
	RLC
	MOV L,A
	MOV A,H
	RAL
	MOV H,A
	CALL DS1
	DCR B
	JNZ DS0
	POP H
	RET
DS1:	MOV A,E
	ADC E
	DAA
	MOV E,A
	MOV A,D
	ADC D
	DAA
	MOV D,A
	MOV A,C
	ADC C
	DAA
	MOV C,A
	RET

DVDPR:	MVI C,0
	MOV B,A
	CALL DP2
	MOV B,D
	CALL DP1
	MOV B,E
DP1:	MOV A,B
	ANI 0F0
	RRC
	RRC
	RRC
	RRC
	CALL DP3
DP2:	MOV A,B
	ANI 0F
DP3:	JNZ DP4
	CMP C
	JNZ HE1
	MVI A,10
	JMP HE1
DP4:	MVI C,1
	JMP HE1

HEXD:	XCHG
	CALL HEXH
	XCHG
	RET
HEXH:	MOV A,H
	CALL HEX
	MOV A,L
HEX:	PUSH PSW
	ANI 0F0
	RRC
	RRC
	RRC
	RRC
	CALL HE1
	POP PSW
	PUSH PSW
	ANI 0F
	CALL HE1
	POP PSW
	RET
HE1:	PUSH H
	PUSH B
	LXI H,DANN
	MOV C,A
	MVI B,0
	DAD B
	MOV C,M
	CALL SYM
	POP B
	POP H
	RET
DANN:	DB "0123456789ABCDEF ",0

BEEP:	MVI B,0A0
BE0:	MVI A,0F
	OUT 0E2
	MOV A,B
BE1:	DCR A
	JNZ BE1
	OUT 0E2
	MOV A,B
BE2:	DCR A
	JNZ BE2
	DCR B
	JNZ BE0
	RET

CRLF:	MVI C,0A
	CALL SYM
CRD0:	CALL A0D
	CALL HEXH
PRB:	MVI C,20
	CALL SYM
	JMP SYM

D0A:	MVI C,0A
	CALL SYM
A0D:	MVI C,0D
	JMP SYM

SYM:	MOV A,C
	ANI 80
	JZ RUS
	MVI A,01
RUS:	STA RLAT
	CALL SYMB
	RET

KLV:	PUSH H
	PUSH D
	PUSH B
	LXI H,0
KL1:	CALL STAT
	ORA A
	JNZ KL0
KL2:	DCR A
	JNZ KL2
	DCR H
	JNZ KL1
	CALL INV
	INR L
	JMP KL1
KL0:	MOV A,L
	ANI 01
	CNZ INV
	POP B
	POP D
	POP H
	CALL KL
	RET

CURC:	MOV C,E
CURS:	CALL SYM
	DCR D
	RZ
	JMP CURS

SCRN:	MVI C,0C
	CALL SYM	;TAB PRINT
	MOV A,D
	ORA A
	MVI C,0A
SCR0:	JZ SCR1
	CALL SYM
	DCR D
	JNZ SCR0
SCR1:	MOV A,E
	MVI C,18
	ORA A
	RZ
SCR2:	CALL SYM
	DCR E
	JNZ SCR2
	RET

PRIND:	CALL D0A
PRINT:	MVI B,10
PRNT:	LDAX D
	ORA A
	RZ
	CPI 0D
	JNZ PPRI
	DCR B
	JNZ PPRI
	CALL KLV
	MVI B,10
	LDAX D
PPRI:	MOV C,A
	CALL SYM
	INX D
	JMP PRNT

OUFO:	DB "Output data to RS232",0D,0A,0
OUTO:	DB "  Point",0D,0A,0
PRO1:	DB "OUT MEMORY -",0
XIT:	LXI D,0E00
	CALL SCRN
	LXI D,PRO1
	CALL PRINT
	CALL HEXH
EXIT:	LHLD MEMO+6
	MOV A,L
	ORA H
	JZ EXIN
	LXI H,"ZA"
EXIN:	SHLD MEMO
QUIT:	CALL BEEP
	LXI D,1000
	CALL SCRN
	LXI D,PS
	CALL PRINT
	CALL KLV
	MVI C,0C
	CALL SYM
	JMP MAIN

PS:	DB "(C) Alexey Zelenov Chernogolovka",0D,0A
	DB " Moskow region 16.02.94  t.51-24",0D,0A,0A
	DB "O'key",0
.PRINTX "END FILE"

	END
