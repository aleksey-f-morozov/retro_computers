;----------------------------------------------------------------------------
; MXOS NC.COM
; ��������� ������
;
; 2013-12-18 ����������������� vinxru
;----------------------------------------------------------------------------

draw:		; ������ 5 ���� �� HL � A, HL, C, B. 
		; ��� ���� DE = HL+5
		mov	a, m
		inx	h
		mov	e, m
		inx	h
		mov	d, m
		inx	h
		mov	c, m
		inx	h
		mov	b, m
		inx	h		
		xchg

		; ���� a=0 (������ ����), �� �����
		ana	a
		rz

		; ���� �� ���������� 7-�� ��� � �������� ������ ������, �� X += 192
		jm	draw_0
		call	activePanelPos
draw_0:	

		; ���� A&0xF==3, �� ��������� C ���� ������ ������ B
		ani	0Fh
		cpi	3
		jz	draw3

		; ���� A&0xF==1, �� ���������� ������������� �����
		; B-������ ����, C-������� �����, *DE++ - ��������� ���� 
		cpi	1
		jz	draw1

		; ���������� ����
		call	draw_window

draw_next:	; HL=DE � ��������� ����
		xchg
		jmp	draw

; ---------------------------------------------------------------------------
; ��������� C ���� ������ ������ B

draw3:		mov	a, b
		call	memset_hl_a_c
		jmp	draw_next

; ---------------------------------------------------------------------------
; ����� HL-�����, B-������ ����, C-������� �����, *DE++ - ��������� ���� 

draw1:		; *hl++ |= b
		mov	a, b
		ora	m
		mov	m, a
		inr	h
		
loc_D9F3:       mvi	m, 0FFh
		inr	h
		dcr	c
		jnz	loc_D9F3

		; hl |= *de++
		ldax	d
		inx	d
		ora	m
		mov	m, a

		jmp	draw_next

; ---------------------------------------------------------------------------
; ���� �������� ������ ������, �������� ����� �� ��� ������

activePanelPos:	push	psw
		lda	activePanel
		ana	a
		jz	loc_DA0B
		mvi	a, 24
loc_DA0B:	add	h
		mov	h, a
		pop	psw
		ret

; ---------------------------------------------------------------------------
; ������ ���� (b=������-2, �=������-6)

draw_window:	; ���� h - 90h + b >= 0x2F, �� ���� X + B + 2 > ������ ������, �� �����
		mov	a, h
		sui	90h
		add	b
		cpi	2Fh
		rnc

		; ��������� ��������
		push	h
		push	b
		push	d

		; �����
		lxi	d, v_window
		call	line313

		; ������ B ���
draw_window_2:	push	d
		call	line313
		dcr	b
		jz	draw_window_3
		pop	d		
		jmp	draw_window_2

; ---------------------------------------------------------------------------

draw_window_3:	pop	psw

		; �����
		call	line313

		; ������������ �������� � �����
		pop	d
		pop	b
		pop	h
		ret

; ---------------------------------------------------------------------------
; ������������ �����. �������� ��� ������� �����, ����������� � ��� ������

line313:	; ��������� ��������
		push	b
		push	h

		; �������� 3 ����� (������-����)
		call	memcpy_hl_de_3

		; 4 �� ���� ��������� �-��� (������-����)
		ldax	d
		call	memset_hl_a_c
		inx	d

		; �������� 3 ����� (������-����)
		call	memcpy_hl_de_3
		 	
		; �������������� ��������
		pop	h
		pop	b

		; ������
		inr	h
		ret