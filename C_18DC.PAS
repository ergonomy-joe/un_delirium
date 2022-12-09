{$G+}
UNIT C_18DC;{some mouse functions}

INTERFACE
{C_18DC_01FC}PROCEDURE MOUSE_start;
{C_18DC_02AC}PROCEDURE MOUSE_stop;
{C_18DC_02E9}FUNCTION MOUSE_getButtons:INTEGER;
PROCEDURE C_18DC_0314(VAR bp0a,bp06:INTEGER);{swap}
{C_18DC_0344}PROCEDURE MOUSE_setRange(bp0c,bp0a,bp08,bp06:INTEGER);

IMPLEMENTATION

USES DOS,
	C_1918,
	BSS;

{mouse user defined subtourine}
PROCEDURE C_18DC_0000(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP:WORD);INTERRUPT;
BEGIN
	IF D_27B4 <> FALSE
	THEN BEGIN;
		IF D_27B5 <> FALSE
		THEN C_1918_1825(
			D_27A2,D_27A6,D_27B2,
			D_279E + D_27A2,D_27A0 + D_27A6,$140,
			D_27B2 - D_27A4 - D_27A2,D_27B3 - D_27A6 - D_27A8,
			D_27AA^,PTR($a000,0)^
		);
		D_27B5 := TRUE;
		{-- horizontal position --}
		D_279E := (CX SHR 1) - D_2798;
		IF D_279E < 0
		THEN D_27A2 := -D_279E
		ELSE D_27A2 := 0;
		IF (D_27B2 + D_279E) > $13f
		THEN D_27A4 := D_27B2 + D_279E - $140
		ELSE D_27A4 := 0;
		{-- vertical position --}
		D_27A0 := DX - D_2799;
		IF D_27A0 < 0
		THEN D_27A6 := -D_27A0
		ELSE D_27A6 := 0;
		IF (D_27B3 + D_27A0) > $c7
		THEN D_27A8 := D_27B3 + D_27A0 - $c8
		ELSE D_27A8 := 0;
		{-- --}
		C_1918_1825(
			D_279E + D_27A2,D_27A0 + D_27A6,$140,
			D_27A2,D_27A6,D_27B2,
			D_27B2 - D_27A4 - D_27A2,D_27B3 - D_27A6 - D_27A8,
			PTR($a000,0)^,D_27AA^
		);
		C_1918_0E60(
			D_27AE^,PTR($a000,0)^,
			D_27B2 - D_27A4 - D_27A2,D_27B3 - D_27A6 - D_27A8,
			D_279E + D_27A2,D_27A0 + D_27A6,
			D_27A2,D_27A6,
			$140,D_27B2
		);
	END;
	ASM
		MOV	SP,BP
		POP	BP
		POP	ES
		POP	DS
		POP	DI
		POP	SI
		POP	DX
		POP	CX
		POP	BX
		POP	AX
		RETF
	END;
END;

{C_18DC_01FC}PROCEDURE MOUSE_start;
BEGIN
	D_27B2 := $10;
	D_27B3 := $10;
	D_2798 := 7;
	D_2799 := 7;
	D_27B4 := FALSE;
	D_27B5 := FALSE;

	D_279E := 0;
	D_27A0 := 0;
	D_27A2 := 0;
	D_27A4 := 0;
	D_27A6 := 0;
	D_27A8 := 0;
	GETMEM(D_27AA,$400);
	FILLCHAR(D_27AA^,$400,0);
	GETMEM(D_27AE,$400);
	MOVE(@C_1918_34F9^,D_27AE^,$100);
	{-- set event handler --}
	Regs.AX := $c;
	Regs.CX := 1;
	Regs.ES := SEG(C_18DC_0000);
	Regs.DX := OFS(C_18DC_0000);
	INTR($33,Regs);
END;

{C_18DC_02AC}PROCEDURE MOUSE_stop;
BEGIN
	FREEMEM(D_27AE,$400);
	FREEMEM(D_27AA,$400);
	Regs.AX := 0;{reset/query driver presence}
	INTR($33,Regs);
END;

{C_18DC_02E9}FUNCTION MOUSE_getButtons:INTEGER;
BEGIN
	Regs.AX := 3;{query position & buttons}
	INTR($33,Regs);
	MOUSE_getButtons := Regs.BX;
END;

{swap}
PROCEDURE C_18DC_0314(VAR bp0a,bp06:INTEGER);
VAR bp_02:INTEGER;
BEGIN
	bp_02 := bp0a;
	bp0a := bp06;
	bp06 := bp_02;
END;

{C_18DC_0344}PROCEDURE MOUSE_setRange(bp0c,bp0a,bp08,bp06:INTEGER);
BEGIN
	IF bp0c > bp08
	THEN C_18DC_0314(bp0c,bp08);{swap}
	IF bp0a > bp06
	THEN C_18DC_0314(bp0a,bp06);{swap}
	{-- set horizontal range --}
	Regs.AX := 7;
	Regs.CX := bp0c;
	Regs.DX := bp08;
	INTR($33,Regs);
	{-- set vectical range --}
	Regs.AX := 8;
	Regs.CX := bp0a;
	Regs.DX := bp06;
	INTR($33,Regs);
END;

END.
