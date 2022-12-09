{$G+}
UNIT C_0BD2;{ending credits}

INTERFACE
{C_0BD2_00DA}PROCEDURE EndingCredits;

IMPLEMENTATION

USES
	DOS,CRT,
	C_1DD9,
	C_1918,
	C_149C,
	C_0E4C,
	C_0BFF,
	BSS;

PROCEDURE C_0000(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP:WORD);INTERRUPT;
BEGIN
	DEC(D_041E);
	IF D_041E = 0
	THEN BEGIN
		D_0418 := 1;
		D_041E := $13;
	END;
	{-- call original int 8 --}
	ASM
		PUSHF	
		CALL	DWORD PTR D_041A
	END;
END;

{C_0035}PROCEDURE _Temporization;
BEGIN
	D_0418 := 0;
	WHILE ((PORT[$3da] AND 8) = 8) AND (D_0418 = 0)
	DO;
	WHILE ((PORT[$3da] AND 8) = 0) AND (D_0418 = 0)
	DO;
	IF D_0418 = 0
	THEN D_041E := $13
	ELSE D_0418 := 0;
END;

{C_0080}PROCEDURE _TimerStart;
BEGIN
	{-- backup int 8 --}
	GETINTVEC(8,D_041A);
	{-- --}
	D_0418 := 0;
	D_041E := $13;
	_Temporization;
	{-- set new int 8 --}
	SETINTVEC(8,@C_0000);
END;

{C_00B5}PROCEDURE _TimerStop;
BEGIN
	SETINTVEC(8,D_041A);
END;

{C_0BD2_00DA}PROCEDURE EndingCredits;
VAR
	_pStr:^STRING_0B;
	_str:STRING[$b];
	_strlen:BYTE;
	_resSize:LONGINT;
BEGIN
	C_0E4C_0031;
	GETMEM(D_05AC,$fa00);
	D_018C := D_05AC;

	RES_find('TFNT',_resSize,D_2774);
	LoadPCX(RES_handle,D_2774);

	D_018C := PTR($a000,0);
	C_0E4C_006F($bb80,$3e80);
	FREEMEM(D_05AC,$FA00);
	EMSStart_00;

	D_27D8 := PTR(EMSSegment,0);
	RES_find('SCRL',_resSize,D_2774);
	BLOCKREAD(RES_handle,D_27D8^,_resSize);

	_TimerStart;
	D_040E := 0;
	D_0410 := 0;
	D_0422 := 4;
	SetPCXPalette;
	REPEAT
		_Temporization;
		C_0E4C_00C8(D_040E * $50);
		INC(D_040E);
		{-- --}
		IF D_0422 < 14
		THEN BEGIN{else 0265}
			INC(D_0422);
			INC(D_0410);
			_pStr := PTR(EMSSegment,D_0410 * 12 - 12);
			_str := _pStr^;
			_strlen := LENGTH(_str);
			WHILE _str[_strlen] = ' '
			DO DEC(_strlen);
			C_0BFF_0055(COPY(_str,1,_strlen),D_0422 * 40);
			IF ROUND(D_2774 / 12.0) = D_0410
			THEN D_0410 := 0;
		END ELSE IF D_0422 = 20
		THEN BEGIN
			{PORTW[$3c4] := $f02;}
			ASM
				{-- Map Mask Register --}
				MOV	DX,$03C4
				MOV	AX,$0F02
				OUT	DX,AX
				{-- --}
				MOV	AX,$A000
				MOV	ES,AX
				MOV	DI,$3E80
				DB	$66
				XOR	AX,AX
				MOV	CX,$1F40
				CLD	
				DB	$66
				REPZ	STOSW	
			END;
			D_0422 := 4;
		END;
		{-- --}
		IF D_040E >= 400
		THEN BEGIN
			C_0E4C_010E(0,$7d00);
			C_0E4C_00C8(0);
			D_0422 := 20;
			D_040E := 1;
		END;
		{-- --}
	UNTIL KEYPRESSED;
	_TimerStop;
END;

END.
