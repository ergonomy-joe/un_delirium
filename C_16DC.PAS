{$G+}
UNIT C_16DC;

INTERFACE
CONST
	{x,y,width,height,actionId}
	{D_0190}IconInfo:ARRAY[1..8,1..5] OF INTEGER = (
		(  1,146, 34,171,{ACTION_}1),
		( 36,146, 70,171,{ACTION_}2),
		( 72,146,106,171,{ACTION_}3),
		(108,146,142,171,{ACTION_}4),
		(  1,173, 34,198,{ACTION_}5),
		( 36,173, 70,198,{ACTION_}7),
		( 72,173,106,198,{ACTION_}6),
		(108,173,142,198,{ACTION_}9)
	);
PROCEDURE C_16DC_0000;
{C_16DC_015F}PROCEDURE IconOn(_iconId:BYTE);
{C_16DC_01FA}PROCEDURE IconOff(_iconId:BYTE);
PROCEDURE C_16DC_03E2;

IMPLEMENTATION

USES
	C_1751,
	C_1765,
	C_183E,
	C_1918,
	BSS;

CONST
	D_01E0:ARRAY[0..7] OF BYTE = (0,1,2,3,4,5,6,7);

PROCEDURE C_16DC_0000;
BEGIN
	D_27F2 := FALSE;
	IF D_27B8 = 1
	THEN BEGIN{else 00E7}
		WITH Actors[1]^
		DO BEGIN
			f_fb := TRUE;
			f_curFrame := AnimFrames[D_27CD][9];
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
	WITH Actors[2]^
	DO FREEMEM(f_pData,f_aFrameWidth[2] * f_aFrameHeight[2]);
	IF D_27F9
	THEN BEGIN
		C_1765_0490(D_27F1);
		C_1765_007F;
	END ELSE BEGIN
		C_1918_18DD(2);
		WITH Actors[2]^
		DO BEGIN
			f_curFrame := 0;
			f_aWidth[1] := 1;
			f_aHeight[1] := 1;
		END;
	END;
END;

{C_16DC_015F}PROCEDURE IconOn(_iconId:BYTE);
VAR _x,_y,_width,_height:INTEGER;
BEGIN
	_x := IconInfo[_iconId][1];
	_y := IconInfo[_iconId][2];
	_width := IconInfo[_iconId][3] - _x;
	_height := IconInfo[_iconId][4] - _y;
	EMSStart_0B;
	ShowMouse(FALSE);
	C_1918_1878(
		_x,_y - 145,320,
		_x,_y,320,
		_width,_height,
		D_27D8^,PTR($a000,0)^,
		9,1
	);
	ShowMouse(TRUE);
END;

{C_16DC_01FA}PROCEDURE IconOff(_iconId:BYTE);
BEGIN
	EMSStart_0B;
	ShowMouse(FALSE);
	C_1918_1825(
		IconInfo[_iconId][1],IconInfo[_iconId][2] - 145,320,
		IconInfo[_iconId][1],IconInfo[_iconId][2],320,
		IconInfo[_iconId][3] - IconInfo[_iconId][1] + 1,IconInfo[_iconId][4] - IconInfo[_iconId][2] + 1,
		D_27D8^,PTR($a000,0)^
	);
	ShowMouse(TRUE);
END;

PROCEDURE C_16DC_03E2;
VAR
	bp_01:BYTE;
	bp_06:^BYTE;
	bp_07:BYTE;
	bp_0a,bp_0c:INTEGER;
	bp_0d:BYTE;
	bp_4a:STRING[$3c];
	bp_4b:BOOLEAN;
	{-- --}
	PROCEDURE INNER_02A0;
	BEGIN
		D_1A87 := Actors[1]^.f_curFrame;
		D_1A84 := 1;
		bp_4a := C_1751_0002(ActionId,CurObj.f_name);
		D_1A5E := LENGTH(bp_4a) + 3;
		GETMEM(D_1A5A,D_1A5E);
		IF Language = 0
		THEN D_1A5A^ := $56
		ELSE D_1A5A^ := $99;
		WORD(PTR(SEG(D_1A5A^),OFS(D_1A5A^) + 1)^) := $201;
		MOVE(PTR(SEG(bp_4a[1]),OFS(bp_4a[1]))^,PTR(SEG(D_1A5A^),OFS(D_1A5A^)+3)^,D_1A5E - 3);
		PScriptTop := D_1A5A;
		D_1A78 := PScriptTop;
		PScriptCur := PScriptTop;

		bp_06 := PScriptTop;
		INC(bp_06,D_1A5E);
		PScriptEnd := bp_06;

		D_1A80 := PScriptEnd;
		D_1A7C := PScriptCur;
		D_27CC := 0;
	END;
	{-- --}
BEGIN
	C_1918_2A16;
	IF D_27D6 > 0
	THEN FOR bp_01 := 1 TO D_27D6
	DO C_1918_1BB1(bp_01);
	IF ActionId <> ACTION_3
	THEN LoadObject(D_1A70[1]);
	IF (D_1A76 > 1) AND (ActionId <> ACTION_5)
	THEN BEGIN
		IF D_1A70[2] < D_1A70[1]
		THEN BEGIN
			LoadObject(D_1A70[2]);
			bp_0a := D_1A70[2];
			bp_0c := D_1A70[1];
		END ELSE BEGIN
			bp_0a := D_1A70[1];
			bp_0c := D_1A70[2];
		END;
	END ELSE BEGIN
		bp_0c := 0;
	END;
	IF ActionId <> ACTION_7
	THEN BEGIN{else 0696}
		IF ActionId <> ACTION_3
		THEN BEGIN{else 0574}
			bp_0d := D_01E0[ActionId] + 1;
			IF CurObj.f_aScriptLen[bp_0d] > 0
			THEN BEGIN{else 056D}
				D_2808 := TRUE;
				D_1A87 := Actors[1]^.f_curFrame;
				D_1A84 := 1;
				D_1A5E := CurObj.f_aScriptLen[bp_0d];
				GETMEM(D_1A5A,D_1A5E);
				MOVE(CurObj.f_apScript[bp_0d]^,D_1A5A^,D_1A5E);
				PScriptTop := D_1A5A;
				D_1A78 := PScriptTop;
				PScriptCur := PScriptTop;

				bp_06 := PScriptTop;
				INC(bp_06,D_1A5E);
				PScriptEnd := bp_06;
				
				D_1A80 := PScriptEnd;
				D_1A7C := PScriptCur;
				D_27CC := 0;
				{else 0571}
			END ELSE BEGIN
				INNER_02A0;
			END;
			{goto 0694}
		END ELSE BEGIN
			bp_4b := FALSE;
			FOR bp_07 := 1 TO CurObj.f_script2Count
			DO IF
				(CurObj.f_aScript2Info[bp_07].f_00 = bp_0c) AND
				(CurObj.f_aScript2Info[bp_07].f_len > 0)
			THEN BEGIN{else 067F}
				D_2808 := TRUE;
				bp_4b := TRUE;
				D_1A87 := Actors[1]^.f_curFrame;
				D_1A84 := 1;
				D_1A5E := CurObj.f_aScript2Info[bp_07].f_len;
				GETMEM(D_1A5A,D_1A5E);
				MOVE(CurObj.f_apScript2[bp_07]^,D_1A5A^,D_1A5E);
				PScriptTop := D_1A5A;
				D_1A78 := PScriptTop;
				PScriptCur := PScriptTop;

				bp_06 := PScriptTop;
				INC(bp_06,D_1A5E);
				PScriptEnd := bp_06;

				D_1A80 := PScriptEnd;
				D_1A7C := PScriptCur;
				D_27CC := 0;
			END;
			IF NOT bp_4b
			THEN INNER_02A0;
		END;
		{goto 06AC}
	END ELSE BEGIN
		IF CurObj.f_conversationId > 0
		THEN C_1765_072F(CurObj.f_conversationId)
		ELSE INNER_02A0;
	END;
	{-- --}
	IF (NOT IsDifficult) OR (ActionId = ACTION_3)
	THEN BEGIN{ese 072D}
		IF (ActionId > 0)
		THEN IF (ActionId <> ACTION_7) OR (CurObj.f_conversationId = 0)
		THEN IF IconCur > 0
		THEN IconOff(IconCur);
		SetMouseImage(@C_1918_34F9,16,16,7,7);
		IF D_27BA > 0
		THEN BEGIN{else 071E}
			IconCur := DefaultIcon;
			IF (DefaultIcon > 0) AND (ActionId <> ACTION_7)
			THEN IconOn(DefaultIcon);
			IconPrev := IconCur;
		END ELSE BEGIN
			IconCur := 0;
			IconPrev := 0;
		END;
		ActionId := ACTION_0;
	END;
	{-- --}
	D_1A76 := 0;
END;

{C_16DC_0734}
BEGIN
	D_27F2 := FALSE;
	D_1A60 := 0;
END.
