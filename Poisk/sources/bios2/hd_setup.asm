;----------------------------------------------------------------------;
;                              ;
;                                  ;
;    :                                                   ;
;  -     INT 13H  INT 40H.                 ;
;      13H     .    ;
;  -             ;
;        HF_TBL_VEC.                               ;
;               (2).;
;----------------------------------------------------------------------;

DISK_SETUP	label	NEAR

;------   WDC

	MOV	DX,HD_PORT
	MOV	AL,0
	OUT	DX,AL
	MOV	DL,(WDC_PORT+2) and 0FFH
	MOV	AL,0AAH
WDC_TST:
	OUT	DX,AL
	MOV	AH,AL
	IN	AL,DX
	CMP	AL,AH			; WDC ฏเจแใโแโขใฅโ ?
	JE	WDC_TST_0
	STC				; ฅโ, ขฎงขเ โ
HD_PRES:	
	RET
WDC_TST_0:
	SHR	AX,1
	JNC	WDC_TST
;
;------ WDC ฏเจแใโแโขใฅโ
;
	XOR	AX,AX
	MOV	DS,AX

	Assume	DS:abs0

	CLI

;
;------  ฏจแ์   13H ข 40H
;	

	MOV	AX,Word ptr [ORG_VECTOR]
	;----   BIOS HARD
	CMP	AX,0EC59H
	JNE	HD_PRES
	;--------------------------------
	MOV	Word ptr [DISK_VECTOR],AX
	MOV	AX,Word ptr [ORG_VECTOR+2]
	MOV	Word ptr [DISK_VECTOR+2],AX

;------ แโ ญฎขช  ญฎขฎฃฎ 13H
	MOV	Word ptr [ORG_VECTOR],Offset DISK_IO
;------ แโ ญฎขช  ฏเฅเ๋ข ญจ๏ ฆฅแโชฎฃฎ คจแช 
	MOV	Word ptr [HDISK_VEC],Offset HD_INT
;-------------------------------------------------------
;    CMOS
;--------------------------------------------------------
	PUSH	AX
	XOR	AX,AX
	XOR	CX,CX
	CALL	CMOS_DIAG1
	JNZ	TAB_2
;---  
	MOV	AL,12H
	OUT	CMOS_PORT,AL
	IN	AL,CMOS_PORT+1

;ฏฅpฅขฎค DEC ข HEX
	CMP	AL,09D
	JBE	DEC_1
	SUB	AL,6D

;ข๋็จแซฅญจฅ  คเฅแ  โ กซจๆ๋
DEC_1:	XCHG	AX,CX
	MOV	AX,Offset FD_TBL
	CMP	CX,1
	JE	OFFS_1
	dec	cx
OFFS:	ADD	AX,10H
	LOOP	OFFS
OFFS_1: MOV	Word ptr [HF_TBL_VEC],AX	; 41H
	POP	AX
	JMP	SHORT TAB_N

;------ แโ ญฎขช  โ กซจๆ๋ ฏ เ ฌฅโเฎข

TAB_2:	POP	AX
        MOV	Word ptr [HF_TBL_VEC],Offset FD_TBL2	; 41H
TAB_N:	MOV	Word ptr [HF_TBL_VEC+2],ax
        MOV	FD_NUM,1
	STI
	MOV	DX,80H
	XOR	AX,AX
	INT	13H
        MOV     CX,LLC3
        MOV     SI,OFFSET HARD_TITL
        CALL    STR_PRINT
SETUP_RET:
	CLC
	RET		                	; return to caller
;---------------------------------------------------------------
;								;
;		   		;
;---------------------------------------------------------------
ST225_tbl:
FD_TBL:
; DRIVE TYPE 01
	DW	0306D		;CYLINDERS
	DB	04D		;HEADS
	DW	0
	DW	0128D		;WRITE PRE-COMPENSATION CYL
	DB	0
	DB	0		;CONTROL BYTE
	DB	0,0,0
	DW	0305D		;LANDING ZONE
	DB	17D		;SECTORS/TRACK
	DB	0
; DRIVE TYPE 02
FD_TBL2:
        DW	0615D		;CYLINDERS
	DB	04D		;HEADS
	DW	0
	DW	0300D		;WRITE PRE-COMPENSATION CYL
	DB	0
	DB	0		;CONTROL BYTE
	DB	0,0,0
	DW	0615D		;LANDING ZONE
	DB	17D		;SECTORS/TRACK
	DB	0
; DRIVE TYPE 03
	DW	0615D		;CYLINDERS
	DB	06D		;HEADS
	DW	0
	DW	0300D		;WRITE PRE-COMPENSATION CYL
	DB	0
	DB	0		;CONTROL BYTE
	DB	0,0,0
	DW	0615D		;LANDING ZONE
	DB	17D		;SECTORS/TRACK
	DB	0
; DRIVE TYPE 04
	DW	0940D		;CYLINDERS
	DB	08D		;HEADS
	DW	0
	DW	0512D		;WRITE PRE-COMPENSATION CYL
	DB	0
	DB	0		;CONTROL BYTE
	DB	0,0,0
	DW	0940D		;LANDING ZONE
	DB	17D		;SECTORS/TRACK
	DB	0
; DRIVE TYPE 05
	DW	0940D		;CYLINDERS
	DB	06D		;HEADS
	DW	0
	DW	0512D		;WRITE PRE-COMPENSATION CYL
	DB	0
	DB	0		;CONTROL BYTE
	DB	0,0,0
	DW	0940D		;LANDING ZONE
	DB	17D		;SECTORS/TRACK
	DB	0
; DRIVE TYPE 06
	DW	1023       ;615D		;CYLINDERS
	DB	08d         ;04D		;HEADS
	DW	0
	DW	0FFFFH		;WRITE PRE-COMPENSATION CYL
	DB	0
	DB	0		;CONTROL BYTE
	DB	0,0,0
	DW	1023d      ;615D		;LANDING ZONE
	DB	17D		;SECTORS/TRACK
	DB	0
; DRIVE TYPE 07
	DW	0462D		;CYLINDERS
	DB	08D		;HEADS
	DW	0
	DW	0256D		;WRITE PRE-COMPENSATION CYL
	DB	0
	DB	0		;CONTROL BYTE
	DB	0,0,0
	DW	0511D		;LANDING ZONE
	DB	17D		;SECTORS/TRACK
	DB	0
; DRIVE TYPE 08
	DW	0733D		;CYLINDERS
	DB	05D		;HEADS
	DW	0
	DW	0FFFFH		;NO WRITE PRE-COMPENSATION CYL
	DB	0
	DB	0		;CONTROL BYTE
	DB	0,0,0
	DW	0733D		;LANDING ZONE
	DB	17D		;SECTORS/TRACK
	DB	0
; DRIVE TYPE 09
	DW	0900D		;CYLINDERS
	DB	15D		;HEADS
	DW	0
	DW	0FFFFH		;NO WRITE PRE-COMPENSATION CYL
	DB	0
	DB	008H		;CONTROL BYTE
	DB	0,0,0
	DW	0901D		;LANDING ZONE
	DB	17D		;SECTORS/TRACK
	DB	0
; DRIVE TYPE 10
	DW	0820D		;CYLINDERS
	DB	03D		;HEADS
	DW	0
	DW	0FFFFH		;NO WRITE PRE-COMPENSATION CYL
	DB	0
	DB	0		;CONTROL BYTE
	DB	0,0,0
	DW	0820D		;LANDING ZONE
	DB	17D		;SECTORS/TRACK
	DB	0
; DRIVE TYPE 11
	DW	0855D		;CYLINDERS
	DB	05D		;HEADS
	DW	0
	DW	0FFFFH		;NO WRITE PRE-COMPENSATION CYL
	DB	0
	DB	0		;CONTROL BYTE
	DB	0,0,0
	DW	0855D		;LANDING ZONE
	DB	17D		;SECTORS/TRACK
	DB	0
; DRIVE TYPE 12
	DW	0855D		;CYLINDERS
	DB	07D		;HEADS
	DW	0
	DW	0FFFFH		;NO WRITE PRE-COMPENSATION CYL
	DB	0
	DB	0		;CONTROL BYTE
	DB	0,0,0
	DW	0855D		;LANDING ZONE
	DB	17D		;SECTORS/TRACK
	DB	0
; DRIVE TYPE 13
	DW	0306D		;CYLINDERS
	DB	08D		;HEADS
	DW	0
	DW	0128D		;WRITE PRE-COMPENSATION CYL
	DB	0
	DB	0		;CONTROL BYTE
	DB	0,0,0
	DW	0319D		;LANDING ZONE
	DB	17D		;SECTORS/TRACK
	DB	0
; DRIVE TYPE 14
;	DW	0733D		;CYLINDERS
;	DB	07D		;HEADS
;	DW	0
;	DW	0FFFFH		;WRITE PRE-COMPENSATION CYL
;	DB	0
;	DB	0		;CONTROL BYTE
;	DB	0,0,0
;	DW	0733D		;LANDING ZONE
;	DB	17D		;SECTORS/TRACK
;	DB	0
; DRIVE TYPE 14
	DW	0820D		;CYLINDERS
	DB	06D		;HEADS
	DW	0
	DW	0820d		;WRITE PRE-COMPENSATION CYL
	DB	0
	DB	0		;CONTROL BYTE
	DB	0,0,0
	DW	0820D		;LANDING ZONE
	DB	17D		;SECTORS/TRACK
	DB	0


; DRIVE TYPE 15 RESERVED     *** DO NOT USE ***
	DW	0000D		;CYLINDERS
	DB	00D		;HEADS
	DW	0
	DW	0000D		;NO WRITE PRE-COMPENSATION CYL
	DB	0
	DB	0		;CONTROL BYTE
	DB	0,0,0
	DW	0000D		;LANDING ZONE
	DB	00D		;SECTORS/TRACK
	DB	0



;---------------------------------------------------------------
;
;----- INT 19 --------------------------------------------------
;								;
; INTERRUPT 19   				;
;								;
;  -	็จโ๋ข ฅโ แ แจแโฅฌญฎฉ คจแชฅโ๋ ฏเฎฃเ ฌฌใ ง ฃเใง็จช 	;
;	เ งฌฅ้ฅญญใ๎ ญ  0 คฎเฎฆชฅ ข ฏฅเขฎฌ แฅชโฎเฅ
;  -	ฎแซฅคฎข โฅซ์ญฎแโ์ ง ฃเใงชจ:				;
;	  > ฏฎฏ๋โช  ง ฃเใงชจ แ คจแชฅโ๋ ฏเฎฃเ ฌฌ๋ ง ฃเใง็จช  ข   ;
;	    ฎกซ แโ์  (0000:7C00) จ ชฎญโเฎซ์ ํโฎฃฎ          	;
;	  > ฏเจ ใค ็ฅ ฏฅเฅค ็  ใฏเ ขซฅญจ๏ ง ฃเใง็จชใ            ;
;	    ฅแซจ ญฅใค ็ , โฎ ง ฃเใงช  แ ฆฅแโชฎฃฎ คจแช         	;
;	  > ฅแซจ ฎ่จกช , โฎ ขฎงขเ โ ข ข๋ง๋ข ๎้ใ๎         	;
;---------------------------------------------------------------
BOOT_STRAPR:
	call	set_tod                 ;ใแโ ญฎขช  ข ๏็ฅฉชจ DOS ขเฅฌฅญจ จง 

;
;------    
;
	XOR	AX,AX
	MOV	DS,AX
	MOV	CX,3			; ใแโ ญฎขช  แ็ฅโ็จช  ฏฎฏ๋โฎช
H1:
	PUSH	CX
	XOR	DX,DX			; คจแชฎขฎค 0
	XOR	AX,AX			; แกเฎแ ชฎญโเฎซซฅเ 
	INT	13H
	MOV	AX,0201H		; ็โฅญจฅ ฎคญฎฃฎ แฅชโฎเ 
	XOR	DX,DX                   ; ใแโ ญฎขช  ES:[BX]
	MOV	ES,DX
	MOV	BX,Offset BOOT_LOCN
	JC	H2			; ฅแซจ ฎ่จกช , โฎ ฏฎขโฎเ
	MOV	CX,1			; SECTOR 1,  TRACK 0
	INT	13H
H2:
	POP	CX
	JNC	H4			; ฏฅเฅๅฎค ฏเจ ใแฏฅๅฅ
	CMP	AH,080H			; ฅแซจ TIME_OUT, โฎ ญฅ ฏฎขโฎเ๏ฅฌ
	JE	H5			; ฏฎขโฎเจโ์ แ FIXED DISK
	LOOP	H1			; ฏฎขโฎเ
        JMP     short H5		; ญฅขฎงฌฎฆญฎแโ์ ง ฃเใงชจ แ คจแชฅโ๋
H4:					; ง ฃเใงช  ก๋ซ  ใแฏฅ่ญฎฉ
	MOV	AX,3			; 80x25 color
	INT	10H			; Clear screen
	
	MOV	BX,806H
	CALL	BEEPER
	JMP 	BOOT_LOCN 		; (OK)
;
;------ Attempt BOOTSTRAP from FIXED DISK
;
H5:
;------
H5_CONT:
	XOR	AX,AX			; RESET 
	INT	13H
	MOV	AH,10H			; โฅแโ ็โฅญจ๏     
	MOV	DL,80H                  ; FIXED DISK 0
	INT	13H
	JC	H9			; ญฅ ็จโ ฅฌ
	MOV	CX,3			; ใแโ ญฎขช  แ็ฅโ็จช  ฏฎขโฎเฅญจฉ
H6:
	PUSH	CX			;                  
	XOR	AX,AX			; RESET ไจชแจเฎข ญญฎฃฎ คจแช 
	INT	13H			;                           
	JC	H7			; ฅแซจ ฎ่จกช , โฎ ฏฎขโฎเจโ์ แญฎข 
	MOV	AX,0201H		; ็โฅญจฅ ฎคญฎฃฎ แฅชโฎเ     
	MOV	CL,1			; SECTOR 1,  TRACK 0
	INT	13H			;              
H7:
	POP	CX			                     
	JC	H8
	CMP	Word ptr [BOOT_LOCN]+510D,0AA55H ; โฅแโ ญ ซจ็จ๏ ง ฃเใง็จช     
	JZ	H4
H8:
	LOOP	H6		                               
H9:
	MOV	BX,404H
	PUSH	BX
	CALL	BEEPER
	MOV	CH,40H			; แโ ญฎขช  150 mS
H10:
	LOOP	H10
	POP	BX
	CALL	BEEPER
	JMP     BOOT_STRAPR		
;
;------ ฎงค ญจฅ งขใช 
;
BEEPER	proc	near
	MOV	AL,10110110B		
	OUT	43H,AL			
	OUT	42H,AL			
	MOV	AL,BH			
	OUT	42H,AL			
	IN	AL,61H			
	PUSH	AX			
	OR	AL,3			
	OUT	61H,AL
BEEP_LOOP:
	MOV	CH,20H			
BEEP_0:
	LOOP	BEEP_0
	DEC	BL			
	JNZ	BEEP_LOOP
	POP	AX			
	OUT	61H,AL
	RET
BEEPER	EndP
;---------------------------------------------------------------
