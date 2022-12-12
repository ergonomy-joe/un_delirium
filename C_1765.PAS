(*
Escape From Delirium 
	by Virtual X-Perience 1995
	decompiled by ergonomy_joe in 2019
*)
{$G+}
UNIT C_1765;{conversations?}

INTERFACE
PROCEDURE C_1765_007F;
PROCEDURE C_1765_0490(bp06:BYTE);
PROCEDURE C_1765_072F(bp06:BYTE);
PROCEDURE C_1765_087E;
PROCEDURE C_1765_0BFD(_mouseX,_mouseY:INTEGER);

IMPLEMENTATION

USES
	C_183E,
	C_18DC,
	C_1918,
	C_1DD9,
	BSS;

PROCEDURE C_0000(bp04:POINTER);
VAR _i:BYTE;
BEGIN
	NEW(D_21AE);
	WITH D_21AE^
	DO BEGIN
		FOR _i := 1 TO 4
		DO f_04[_i] := 0;
		f_08 := bp04;
		f_0c := 0;
		f_00 := FILEPOS(RES_handle);
	END;
END;

PROCEDURE C_1765_007F;
VAR _dummy:INTEGER;
BEGIN
	WITH Actors[D_27FA]^
	DO PutString_1(COPY(D_230E[D_252F],2,LENGTH(D_230E[D_252F]) - 1),f_aX[1],f_aY[1] - f_aHeight[1] - 10,D_24A3);
	D_27F8 := TRUE;
	D_252D := 0;
	D_252E := ROUND((LENGTH(D_230E[D_252F]) * ($6e - D_27C0[2])) / 50.0);
END;

{C_013B}PROCEDURE _EMSStart_10;
BEGIN
	EMSDoMapping(EMSHandle,$10,0);
	EMSDoMapping(EMSHandle,$11,1);
END;

PROCEDURE C_0161;
VAR _i:BYTE;
BEGIN
	EMSStart_0B;
	ShowMouse(FALSE);
	C_1918_34BC(D_27DC);
	ShowMouse(TRUE);
	FOR _i := 1 TO D_252C
	DO PutString_2(COPY(D_21BA[_i].f_00,2,LENGTH(D_21BA[_i].f_00) - 1),10,$87 + _i * 13);
	ShowMouse(FALSE);
	_EMSStart_10;
	D_2532 := PTR(EMSSegment,0);
	ASM
		PUSH	DS
		LES	DI,D_2532
		MOV	AX,$A000
		MOV	DS,AX
		MOV	SI,$B540
		MOV	CX,$1130
		CLD	
		REPZ	
		DB	$66
		MOVSW	
		POP	DS
	END;
	ShowMouse(TRUE);
	FOR _i := 1 TO D_252C
	DO IF D_21AE^.f_04[_i] <> 0
	THEN BEGIN
		ShowMouse(FALSE);
		C_1918_1878(
			0,(_i - 1) * 13,320,
			0,$91 + (_i - 1) * 13,320,
			320,13,
			D_2532^,PTR($a000,0)^,
			$ff,7
		);
		ShowMouse(TRUE);
	END;
END;

PROCEDURE C_029A;
VAR _i:BYTE;
BEGIN
	D_252C := 0;
	FOR _i := 1 TO 4
	DO BEGIN
		D_21BA[_i].f_00[0] := #0;
		D_21BA[_i].f_51 := 0;
	END;
	REPEAT
		INC(D_252C);
		D_2528 := @D_21BA[D_252C];
		BLOCKREAD(RES_handle,_i,1);
		D_2528^ := _i;
		INC(D_2528);
		BLOCKREAD(RES_handle,D_2528^,_i);
		BLOCKREAD(RES_handle,D_21BA[D_252C].f_51,4);
	UNTIL D_21BA[D_252C].f_00[1] <> 'F';
	DEC(D_252C);
	FOR _i := (D_252C + 1) TO 4
	DO D_21AE^.f_04[_i] := 1;
END;

PROCEDURE C_039E;
BEGIN
	D_27F8 := FALSE;
	INC(D_252F);
	WITH Actors[2]^
	DO FREEMEM(f_pData,f_aFrameWidth[2] * f_aFrameHeight[2]);
	IF D_252F <= D_27F0
	THEN BEGIN
		C_1765_007F;
		EXIT;
	END;
	C_1918_18DD(2);
	WITH Actors[2]^
	DO BEGIN
		f_curFrame := 0;
		f_aWidth[1] := 1;
		f_aHeight[1] := 1;
	END;
	IF D_2803 <> 0
	THEN BEGIN
		IF (D_21AE^.f_0c = 0) AND (D_21AE <> D_21B6)
		THEN BEGIN
			D_21B2 := D_21AE;
			C_0000(D_21B2);
		END ELSE BEGIN
			D_21AE^.f_0c := 0;
		END;
		C_029A;
		C_0161;
		D_21B6 := D_21AE;
	END;
	D_2530 := 0;
END;

PROCEDURE C_1765_0490(bp06:BYTE);
VAR
	_strlen:BYTE;
	bp_04:INTEGER;
	_i:BYTE;
	_stateId:WORD;
	bp_0c:LONGINT;
	_finish:BOOLEAN;
BEGIN
	D_252F := 1;
	D_2803 := 0;
	D_27F0 := 0;
	SEEK(RES_handle,RES_offset + D_21BA[bp06].f_51);
	_finish := FALSE;
	REPEAT
		bp_0c := FILEPOS(RES_handle);
		INC(D_27F0);
		{-- load string --}
		D_2528 := @D_230E[D_27F0];
		BLOCKREAD(RES_handle,_strlen,1);
		D_2528^ := _strlen;
		INC(D_2528);
		BLOCKREAD(RES_handle,D_2528^,_strlen);
		{-- --}
		CASE D_230E[D_27F0][1] OF
			'A': BEGIN
				IF D_27F0 > 1
				THEN BEGIN{else 0604}
					_finish := FALSE;
					D_2803 := 1;
					FOR _i := 1 TO 4
					DO IF D_21AE^.f_04[_i] = 0
					THEN _finish := TRUE;
					IF NOT _finish
					THEN WHILE D_21AE^.f_08 <> nil
					DO BEGIN
						D_21B2 := D_21AE;
						D_21AE := D_21AE^.f_08;
						FREEMEM(D_21B2,$10);
					END;
					bp_0c := D_21AE^.f_00;
					D_21B6 := D_21AE;
					_finish := TRUE;
				END;
			END;
			'F': BEGIN
				IF D_27F0 > 1
				THEN _finish := TRUE;
				D_21B6 := nil;
				D_2803 := 1;
			END;
			'Q': BEGIN
				_finish := TRUE;
				D_2802 := 1;
				bp_0c := FILEPOS(RES_handle);
				WHILE D_21AE^.f_08 <> nil
				DO BEGIN
					D_21B2 := D_21AE;
					D_21AE := D_21AE^.f_08;
					FREEMEM(D_21B2,$10);
				END;
				DISPOSE(D_21AE);
			END;
			'S': BEGIN
				VAL(COPY(D_230E[D_27F0],2,LENGTH(D_230E[D_27F0]) - 1),_stateId,bp_04);
				IF _stateId > $7fff
				THEN State[$ffff - _stateId] := 0
				ELSE State[_stateId] := 1;
				RefreshState(_stateId);
				DEC(D_27F0);
			END;
		END;
	UNTIL _finish;
	DEC(D_27F0);
	SEEK(RES_handle,bp_0c);
END;

PROCEDURE C_1765_072F(bp06:BYTE);
VAR dummy:INTEGER;
BEGIN
	IF Language = 0
	THEN RES_find('SPKE',RES_offset,RES_size)
	ELSE RES_find('SPKG',RES_offset,RES_size);
	SEEK(RES_handle,RES_offset + (bp06 - 1) * 4 + 1);
	BLOCKREAD(RES_handle,D_2524,4);
	SEEK(RES_handle,RES_offset + D_2524);
	BLOCKREAD(RES_handle,D_27FA,1);
	BLOCKREAD(RES_handle,D_24A3,1);
	BLOCKREAD(RES_handle,D_27FE,4);
	D_2536 := FILEPOS(RES_handle);
	C_0000(nil);
	D_21B6 := D_21AE;
	C_029A;
	C_0161;
	D_2802 := 0;
	D_27F9 := TRUE;
	D_27F8 := FALSE;
	D_27FB := Actors[D_27FA]^.f_curFrame;
	D_2530 := 1;
END;

PROCEDURE C_1765_087E;
VAR _curFrame,_nextFrame:BYTE;
BEGIN
	IF D_252D > 0
	THEN BEGIN
		DEC(D_252D);
		{goto 0993}
	END ELSE BEGIN
		D_252D := RANDOM(3);
		C_1918_18DD(D_27FA);
		WITH Actors[D_27FA]^
		DO BEGIN
			{-- --}
			_curFrame := f_curFrame;
			REPEAT
				_nextFrame := D_27FE[RANDOM(4) + 1];
			UNTIL _nextFrame <> _curFrame;
			f_curFrame := _nextFrame;
			{-- --}
			IF f_scale <> $ff
			THEN BEGIN
				f_aWidth[1] := (f_aFrameWidth[f_curFrame] * f_scale) SHR 7;
				f_aHeight[1] := (f_aFrameHeight[f_curFrame] * f_scale) SHR 7;
			END ELSE BEGIN
				f_aWidth[1] := f_aFrameWidth[f_curFrame];
				f_aHeight[1] := f_aFrameHeight[f_curFrame];
			END;
		END;
	END;
	IF D_252E > 0
	THEN DEC(D_252E)
	ELSE C_039E;
END;

FUNCTION C_09A5(_x,_y,_left,_top,_right,_bottom:WORD):BOOLEAN;
BEGIN
	IF
		(_x >= _left) AND (_x <= _right) AND
		(_y >= _top) AND (_y <= _bottom)
	THEN C_09A5 := TRUE
	ELSE C_09A5 := FALSE;
END;

PROCEDURE C_09E4(bp04:STRING);
VAR
	_pfefc:WORD;
	bpfefd:BYTE;
BEGIN
	WITH Actors[1]^
	DO PutString_1(bp04,f_aX[1],f_aY[1] - f_aHeight[1] - $a,2);
	D_27B8 := 1;
	D_27F2 := TRUE;
	bpfefd := Actors[1]^.f_curFrame;
	GuessAnimType(bpfefd,D_27CD);
	D_27CC := 0;
	D_27F4 := 0;
	D_27F6 := ROUND((LENGTH(bp04) * ($6e - D_27C0[2])) / 50.0);
END;

PROCEDURE C_0AA7(bp04:BYTE);
BEGIN
	_EMSStart_10;
	ShowMouse(FALSE);
	IF D_21AE^.f_04[bp04] <> 0
	THEN C_1918_1878(
		0,(bp04 - 1) * 13,320,
		0,$91 + (bp04 - 1) * 13,320,
		320,13,
		D_2532^,PTR($a000,0)^,
		$ff,1
	) ELSE C_1918_1878(
		0,(bp04 - 1) * 13,320,
		0,$91 + (bp04 - 1) * 13,320,
		320,13,
		D_2532^,PTR($a000,0)^,
		9,1
	);
	ShowMouse(TRUE);
END;

PROCEDURE C_0B54(bp04:BYTE);
BEGIN
	_EMSStart_10;
	ShowMouse(FALSE);
	IF D_21AE^.f_04[bp04] <> 0
	THEN C_1918_1878(
		0,(bp04 - 1) * 13,320,
		0,$91 + (bp04 - 1) * 13,320,
		320,13,
		D_2532^,PTR($a000,0)^,
		$ff,7
	) ELSE C_1918_1825(
		0,(bp04 - 1) * 13,320,
		0,$91 + (bp04 - 1) * 13,320,
		320,13,
		D_2532^,PTR($a000,0)^
	);
	ShowMouse(TRUE);
END;

PROCEDURE C_1765_0BFD(_mouseX,_mouseY:INTEGER);
VAR bp_01:BYTE;
BEGIN
	IF (NOT D_27F8) AND (NOT D_27F2)
	THEN BEGIN{else 0D52}
		{-- --}
		D_27F1 := 0;
		FOR bp_01 := 1 TO D_252C
		DO IF C_09A5(_mouseX,_mouseY,0,133 + bp_01 * 13,319,150 + bp_01 * 13)
		THEN D_27F1 := bp_01;
		IF D_27F1 <> D_2530
		THEN BEGIN
			IF D_2530 > 0
			THEN C_0B54(D_2530);
			IF D_27F1 > 0
			THEN C_0AA7(D_27F1);
			D_2530 := D_27F1;
		END;
		{-- --}
		IF MOUSE_getButtons = 1
		THEN BEGIN{else 0D1A}
			IF (D_27F1 > 0) AND (D_253A = 0)
			THEN BEGIN{else 0D18}
				D_21AE^.f_04[D_27F1] := 1;
				EMSStart_0B;
				ShowMouse(FALSE);
				C_1918_34BC(D_27DC);
				ShowMouse(TRUE);
				C_09E4(COPY(D_21BA[D_27F1].f_00,2,LENGTH(D_21BA[D_27F1].f_00) - 1));
				D_253A := 1;
			END;
			{goto 0D1F}
		END ELSE BEGIN
			D_253A := 0;
		END;
		{-- --}
		IF D_2802 <> 0
		THEN BEGIN{else 0D50}
			D_27F9 := FALSE;
			EMSStart_0B;
			ShowMouse(FALSE);
			C_1918_34BC(D_27D8);
			ShowMouse(TRUE);
			InventoryRender;
		END;
		{goto 0D85}
	END ELSE BEGIN
		IF MOUSE_getButtons = 1
		THEN BEGIN{else 0D80}
			IF D_253A = 0
			THEN BEGIN{else 0D7E}
				IF D_27F8
				THEN C_039E;
				IF D_27F2
				THEN D_27F6 := 0;
				D_253A := 1;
			END;
		END ELSE BEGIN
			D_253A := 0;
		END;
	END;
END;

END.
