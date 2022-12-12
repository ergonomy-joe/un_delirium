(*
Escape From Delirium 
	by Virtual X-Perience 1995
	decompiled by ergonomy_joe in 2019
*)
{$G+}
UNIT C_1E02;

INTERFACE
{C_1E02_0000}PROCEDURE FastMove(VAR _src,_dst; _size:WORD);

IMPLEMENTATION

{C_1E02_0000}PROCEDURE FastMove(VAR _src,_dst; _size:WORD);
LABEL C_0023,C_002E;
BEGIN
	ASM
		CLD	
		XOR	DX,DX
		PUSH	DS
		LES	DI,_dst
		LDS	SI,_src
		MOV	BX,_size
		MOV	CX,BX
		SHR	CX,2
		JZ	C_0023
		MOV	DX,CX
		REPZ
		DB	$66
		MOVSW
C_0023:
		SHL	DX,02
		SUB	BX,DX
		JZ	C_002E
		MOV	CX,BX
		REPZ	MOVSB
C_002E:
		POP	DS
	END;
END;

END.
