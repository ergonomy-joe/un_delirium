(*
Escape From Delirium 
	by Virtual X-Perience 1995
	decompiled by ergonomy_joe in 2019
*)
{$G+}
UNIT C_1018;

INTERFACE
{C_1018_0000}PROCEDURE FillRect(_x,_y,_width,_height:WORD; _color:BYTE; VAR _dst; _stride:WORD);
{C_1018_0091}PROCEDURE ShrinkTransition(bp06:BYTE);

IMPLEMENTATION

USES
	C_1D8E,
	C_1918,
	BSS;

{C_1018_0000}PROCEDURE FillRect(_x,_y,_width,_height:WORD; _color:BYTE; VAR _dst; _stride:WORD);
LABEL C_0032;
BEGIN
	ShowMouse(FALSE);
	ASM
		LES	DI,_dst
		CLD	
		MOV	AX,_y
		MOV	BX,_stride
		MUL	BX
		ADD	AX,_x
		ADD	DI,AX
		MOV	AL,_color
		MOV	AH,_color
		MOV	BX,_stride
		SUB	BX,_width
		MOV	DX,_height
		INC	DX
C_0032:
		MOV	CX,_width
		SHR	CX,1
		REPZ	STOSW	
		ADD	DI,BX
		DEC	DL
		JNZ	C_0032
	END;
	ShowMouse(TRUE);
END;

PROCEDURE C_004A(_scrOfs,bp08:WORD; VAR _src);
LABEL C_0067;
BEGIN
	ASM
		CLD	

		MOV	AX,$A000
		MOV	ES,AX
		MOV	DI,_scrOfs

		XOR	AX,AX
		MOV	CX,640
		REPZ	STOSW

		XOR	BX,BX
		PUSH	DS
C_0067:
		LDS	SI,_src
		MOV	AX,$90
		MUL	BX
		DIV	Word Ptr bp08
		MOV	CX,320
		MUL	CX
		ADD	SI,AX
		MOV	CX,$50
		REPZ	
		DB	$66
		MOVSW	
		INC	BX
		CMP	BX,bp08
		JNZ	C_0067

		XOR	AX,AX
		MOV	CX,800
		REPZ	STOSW	

		POP	DS
	END;
END;

{C_1018_0091}PROCEDURE ShrinkTransition(bp06:BYTE);
VAR
	_i:BYTE;
	_src:POINTER;
	_scrOffset:INTEGER;
	bp_0a:INTEGER;
	bp_0b:BOOLEAN;
	_vol:INTEGER;
BEGIN
	{-- --}
	bp_0b := FALSE;
	IF (HeadR.f_songId <> CurSong) AND (CurSong <> $80)
	THEN bp_0b := TRUE;
	{-- --}
	bp_0a := D_2A32;
	D_2A32 := bp_0a SHR 2;
	EMSStart_00;
	_src := PTR(EMSSegment,0);
	MOVE(PTR($a000,0)^,_src^,$b400);
	_scrOffset := 0;
	FOR _i := 17 DOWNTO 1
	DO BEGIN
		IF bp_0b <> FALSE
		THEN BEGIN
			_vol := ROUND((3 * _i) * bp06 / 100.0);
			MUSIC_setVolumes(_vol,_vol);
		END;
		C_004A(_scrOffset,_i SHL 3,_src^);
		INC(_scrOffset, $500);
		{-- tempo --}
		WHILE D_2A28 = 0
		DO;
		D_2A28 := 0;
		{-- --}
	END;
	FILLCHAR(PTR($a000,$5500)^,$a00,0);
	D_2A32 := bp_0a;
END;

END.
