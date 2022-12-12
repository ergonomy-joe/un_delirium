(*
Escape From Delirium 
	by Virtual X-Perience 1995
	decompiled by ergonomy_joe in 2019
*)
{$G+}
UNIT C_1D7C;{Timer}

INTERFACE
CONST
	{D_028A}TIMER_isOn:BOOLEAN = FALSE;

{C_1D7C_0042}PROCEDURE TIMER_start;
{C_1D7C_00F5}PROCEDURE TIMER_stop;

IMPLEMENTATION

USES DOS,BSS;

{new int 8}
PROCEDURE C_0000(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP:WORD);
INTERRUPT;
LABEL C_0021,C_0032;
BEGIN
	{-- counter 1 --}
	DEC(D_2A2A);
	ASM
		JNZ	C_0021;
	END;
		D_2A2A := D_2A32;
		D_2A28 := 1;
C_0021:
	{-- counter 2 --}
	DEC(D_2A2C);
	ASM
		JNZ	C_0032;
	END;
		D_2A2C := D_2A2E;
		{-- call original int 8 --}
		ASM
			PUSHF	
			CALL	DWORD PTR D_2A24
		END;
C_0032:
	{-- --}
	ASM
		MOV	DX,$20
		MOV	AX,DX
		OUT	DX,AL
	END;
END;

{C_1D7C_0042}PROCEDURE TIMER_start;
VAR bp_02:INTEGER;
BEGIN
	CASE D_2A38 OF
		0: BEGIN
			D_2A30 := $6D;
			D_2A32 := $12;
			D_2A2E := $c;
		END;
		4: BEGIN
			D_2A30 := $21c;
			D_2A32 := $58;
			D_2A2E := 1;
		END;
		ELSE BEGIN
			D_2A30 := $200;
			D_2A32 := $54;
			D_2A2E := 1;
		END;
	END;
	D_2A2A := D_2A32;
	D_2A2C := D_2A2E;
	bp_02 := ROUND(1193180.0 / (D_2A30 SHL 1));
	PORT[$40] := LO(bp_02);
	PORT[$40] := HI(bp_02);
	GETINTVEC(8,D_2A24);
	SETINTVEC(8,@C_0000);
	TIMER_isOn := TRUE;
END;

{C_1D7C_00F5}PROCEDURE TIMER_stop;
BEGIN
	PORT[$40] := $ff;
	PORT[$40] := $ff;
	SETINTVEC(8,D_2A24);
	TIMER_isOn := FALSE;
END;

END.
