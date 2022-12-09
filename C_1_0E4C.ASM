;----------------------------------------
;helper functions for modules C_0BD2
; and C_0BFF: ending credits
;----------------------------------------
PORT_3C4 EQU 3C4h
PORT_3C8 EQU 3C8h
PORT_3CE EQU 3CEh
PORT_3D4 EQU 3D4h
PORT_3DA EQU 3DAh
;----------------------------------------
;x386 support
ENTER	MACRO a,b
	db 0C8h
	dw a
	db b
ENDM
;----
LEAVE	MACRO
	DB 0C9h
ENDM
;----
REPZ_OUTSB	MACRO
	db 0F3h,6Eh
ENDM
;----------------------------------------
DATA	SEGMENT WORD PUBLIC
	EXTRN D_05AC:DWORD
	EXTRN D_05B0:WORD
	EXTRN D_05B2:WORD
DATA	ENDS
;----------------------------------------
CODE	SEGMENT BYTE PUBLIC
	ASSUME CS:CODE,DS:DATA
;----------------------------------------
PUBLIC __0E4C_000C
__0E4C_000C:
	;-- Start Address High&Low Register --
	MOV	BX,D_05B0
	MOV	DX,PORT_3D4
	MOV	AL,0Ch
	MOV	AH,BH
	OUT	DX,AX
	INC	AL
	MOV	AH,BL
	OUT	DX,AX
	;-- --
	CMP	BX,3E80h
	JZ	C_002A
	MOV	D_05B0,3E80h
	RETF	
C_002A:
	MOV	D_05B0,0
	RETF	
;----------------------------------------
PUBLIC C_0E4C_0031
C_0E4C_0031:
	MOV	AX,(0 SHL 8) OR 13h
	INT	10h
	;-- --
	MOV	DX,PORT_3C4
	MOV	AL,4
	OUT	DX,AL
	INC	DX
	IN	AL,DX
	AND	AL,0F7h
	OR	AL,4
	OUT	DX,AL
	;-- map mask register --
	DEC	DX
	MOV	AX,(0Fh SHL 8) OR 2
	OUT	DX,AX
	;-- --
	MOV	AX,0A000h
	MOV	ES,AX
	XOR	DI,DI
	XOR	AX,AX
	MOV	CX,0FFFFh
	CLD	
	REPZ	STOSW
	;-- Underline Location Register --
	MOV	DX,PORT_3D4
	MOV	AL,14h
	OUT	DX,AL
	INC	DX
	IN	AL,DX
	AND	AL,NOT 40h	;0BFh
	OUT	DX,AL
	;-- CRTC Mode Control Register --
	DEC	DX
	MOV	AL,17h
	OUT	DX,AL
	INC	DX
	IN	AL,DX
	OR	AL,40h
	OUT	DX,AL
	;-- --
	RETF	
;----------------------------------------
C_006C	db 0
C_006D	dw 0
;----------------------------------------
PUBLIC C_0E4C_006F
C_0E4C_006F:
	ENTER	0000,00
	;-- Graphics Mode Register --
	MOV	DX,PORT_3CE
	MOV	AX,(40h SHL 8) OR 5
	OUT	DX,AX
	;-- --
	MOV	CS:C_006C,1

	PUSH	DS
	LDS	SI,D_05AC
	MOV	CS:C_006D,SI
	MOV	AX,0A000h
	MOV	ES,AX
	MOV	DI,[BP+08]
	MOV	CX,[BP+06]
C_0095:	;-- map mask register --
	MOV	AL,2
	MOV	AH,CS:[C_006C]
	MOV	DX,PORT_3C4
	OUT	DX,AX
C_00A0:	;-- --
	MOVSB	
	ADD	SI,3
	LOOP	C_00A0
	MOV	DI,[BP+08]
	INC	CS:C_006D
	MOV	SI,CS:C_006D
	MOV	CX,[BP+06]
	SHL	CS:C_006C,1
	CMP	CS:C_006C,10h
	JNZ	C_0095
	POP	DS

	LEAVE
	RETF	4
;----------------------------------------
PUBLIC C_0E4C_00C8
C_0E4C_00C8:
	ENTER	0000,00

	MOV	DX,PORT_3D4
	;-- Start Address High Register --
	MOV	AL,0Ch
	MOV	AH,[BP+07]
	OUT	DX,AX
	;-- Start Address Low Register --
	MOV	AL,0Dh
	MOV	AH,[BP+06]
	OUT	DX,AX
	;-- --
	LEAVE
	RETF	2
;----------------------------------------
;wait VBLANK?
PUBLIC __0E4C_00DF
__0E4C_00DF:
	MOV	DX,PORT_3DA
C_00E2:
	IN	AL,DX
	TEST	AL,8
	JNZ	C_00E2
C_00E7:
	IN	AL,DX
	TEST	AL,8
	JZ	C_00E7

	RETF	
;----------------------------------------
PUBLIC __0E4C_00ED
__0E4C_00ED:
	ENTER	0000,00
	;-- map mask register --
	MOV	AL,2
	MOV	AH,[BP+06]
	MOV	DX,PORT_3C4
	OUT	DX,AX
	;-- --
	MOV	AX,0A000h
	MOV	ES,AX

	MOV	DI,D_05B0
	XOR	AX,AX
	MOV	CX,1F40h
	REPZ	STOSW	

	LEAVE
	RETF	2
;----------------------------------------
PUBLIC C_0E4C_010E
C_0E4C_010E:
	ENTER	0000,00
	;-- map mask register --
	MOV	DX,PORT_3C4
	MOV	AX,(0Fh SHL 8) OR 2
	OUT	DX,AX
	;-- Graphics Mode Register --
	MOV	DX,PORT_3CE
	MOV	AX,(41h SHL 8) OR 5
	OUT	DX,AX
	;-- --
	PUSH	DS
	MOV	AX,0A000h
	MOV	ES,AX
	MOV	DS,AX
	MOV	SI,[BP+06]
	MOV	DI,[BP+08]
	MOV	CX,3E80h
	REPZ	MOVSB	
	POP	DS
	;-- Graphics Mode Register --
	MOV	DX,PORT_3CE
	MOV	AX,(40h SHL 8) OR 5
	OUT	DX,AX
	;-- --
	LEAVE
	RETF	4
;----------------------------------------
;send palette to DAC?
PUBLIC __0E4C_013F
__0E4C_013F:
	PUSH	SI

	MOV	SI,OFFSET DATA:D_05B2
	MOV	CX,300h
	XOR	AL,AL
	MOV	DX,PORT_3C8
	OUT	DX,AL
	INC	DX
	REPZ_OUTSB

	POP	SI
	RETF	
;----------------------------------------
PUBLIC C_0E4C_0151
C_0E4C_0151:
	ENTER	0002,00
	;-- Graphics Mode Register --
	MOV	DX,PORT_3CE
	MOV	AX,(41h SHL 8) OR 5
	OUT	DX,AX
	;-- map mask register --
	MOV	DX,PORT_3C4
	MOV	AX,(0Fh SHL 8) OR 2
	OUT	DX,AX
	;-- --
	PUSH	DS
	MOV	AX,0A000h
	MOV	ES,AX
	MOV	DS,AX
	MOV	SI,[BP+0Ah]
	MOV	DI,[BP+0Ch]
	MOV	DX,[BP+06]
	MOV	AX,50h
	SUB	AX,[BP+08]
	MOV	[BP-02],AX
C_017D:
	MOV	CX,[BP+08]
	REPZ	MOVSB	
	ADD	SI,[BP-02]
	ADD	DI,[BP-02]
	DEC	DX
	JNZ	C_017D
	POP	DS

	LEAVE
	RETF	8
;----------------------------------------
CODE	ENDS
;----------------------------------------
END
