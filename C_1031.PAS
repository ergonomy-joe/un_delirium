{$G+}
{$X+}
UNIT C_1031;{scene script?}

INTERFACE
CONST
	{D_0166}IsRegistered:BOOLEAN = FALSE;
__0167:BYTE = 0;
	D_0168:BYTE = 0;
	D_0169:BYTE = 0;{stretch related?}
	D_016A:BYTE = 0;{stretch related?}
	D_016B:BYTE = 0;{stretch related?}
__016C:WORD = 0;
	D_016E:INTEGER = 1;{stretch related?}
	D_0170:BYTE = 0;
	D_0172:ARRAY[0..3] OF BYTE = (
		1,1,
		1,1
	);
	D_0176:BOOLEAN = TRUE;{do shrink transition?}
	D_0177:BOOLEAN = FALSE;
	D_0178:BOOLEAN = FALSE;
	D_0179:BOOLEAN = FALSE;

PROCEDURE C_1031_008D;
{C_1031_00E7}PROCEDURE ScreenOffset(bp06:WORD);
PROCEDURE C_1031_0113;
{C_1031_0143}PROCEDURE RefreshAllStates;
{C_1031_071E}PROCEDURE SCRIPT_52;
{C_1031_0746}PROCEDURE SCRIPT_46;
PROCEDURE C_1031_0785;
PROCEDURE C_1031_0E84;
PROCEDURE C_1031_1391;
PROCEDURE C_1031_14F5;

IMPLEMENTATION

USES
	CRT,
	C_1196,
	C_14C8,
	C_16C2,
	C_16DC,
	C_183E,
	C_1918,
	C_1D7C,
	C_1D8E,
	C_1DD9,
	C_1E02,
	BSS;

CONST
	D_017A:ARRAY[0..2,1..4] OF BYTE = (
		($16,$17,$18,$07),
		($19,$1A,$1B,$11),
		($1C,$1D,$0C,$00)
	);
	D_0186:ARRAY[0..2] OF BYTE = (4,4,3);

{C_0000}FUNCTION _ScriptFetchByte:BYTE;
BEGIN
	_ScriptFetchByte := BufferFetchByte(PScriptCur);
END;

{C_0020}FUNCTION _ScriptFetchWord:WORD;
BEGIN
	_ScriptFetchWord := BuffetFetchWord(PScriptCur);
END;

{C_0040}PROCEDURE _ScriptSkipString;
BEGIN
	_ScriptFetchWord;
	WHILE CHAR(_ScriptFetchByte) <> '^'{x5e}
	DO;
END;

{C_0058}PROCEDURE _SetPaletteAlpha(_alpha:BYTE);
LABEL C_0076,C_0086;
BEGIN
	ASM
		MOV	SI,OFFSET D_0F62
		MOV	CX,$300
		MOV	DX,$3C8
		XOR	AL,AL
		OUT	DX,AL
		MOV	DX,$3C9
		MOV	BL,_alpha
		XOR	BH,BH
C_0076:
		XOR	AH,AH
		LODSB	
		MUL	BL
		SHR	AX,07
		CMP	AX,$3F
		JBE	C_0086
		MOV	AX,$3F
C_0086:
		OUT	DX,AL
		LOOP	C_0076
	END;
END;

PROCEDURE C_1031_008D;
BEGIN
	WITH Actors[2]^
	DO BEGIN
		FREEMEM(f_pData,f_aFrameWidth[2] * f_aFrameHeight[2]);
		f_curFrame := 0;
		f_fb := TRUE;
	END;
	D_0178 := FALSE;
END;

{C_1031_00E7}PROCEDURE ScreenOffset(bp06:WORD);
BEGIN
	PORTW[$3d4] := HI(bp06) SHL 8 + $c;
	PORTW[$3d4] := LO(bp06) SHL 8 + $d;
END;

PROCEDURE C_1031_0113;
VAR _dummy:WORD;
BEGIN
	FILLCHAR(State,$320,0);
	State[0] := 1;
	{-- shareware patch --}
	IF NOT IsRegistered
	THEN State[$cd] := 1;
	{-- --}
END;

{C_1031_0143}PROCEDURE RefreshAllStates;
VAR
	_i:BYTE;
	_stateId1,_stateId2:WORD;
	_state1,_state2:BOOLEAN;
	bp_0c,bp_10:POINTER;
	_size:WORD;
	bp_16:^BYTE;
BEGIN
	ShowMouse(FALSE);
	FOR _i := 1 TO D_2947
	DO BEGIN
		WITH D_28E2[_i]^
		DO BEGIN
			_stateId1 := f_stateId1;
			_stateId2 := f_stateId2;
		END;
		{}
		{}
		{}
		{}
			IF _stateId1 > $7fff
			THEN _state1 := (State[$ffff - _stateId1] = 0)
			ELSE _state1 := (State[_stateId1] = 1);
			IF _stateId2 > $7fff
			THEN _state2 := (State[$ffff - _stateId2] = 0)
			ELSE _state2 := (State[_stateId2] = 1);
			EMS2Pointer(D_28E2[_i]^.f_emsPtr,bp_0c);
			WITH D_28E2[_i]^
			DO BEGIN
				_size := f_width * f_height;
				IF (NOT _state1) OR (NOT _state2)
				THEN BEGIN
					bp_16 := bp_0c;
					INC(bp_16,_size);
					bp_0c := bp_16;
				END;
				GETMEM(bp_10,_size);
				ASM
					PUSH	DS
					LDS	SI,bp_0c
					LES	DI,bp_10
					MOV	CX,_size
					CLD	
					REPZ	MOVSB	
					POP	DS
				END;
				EMSStart_0A;
				bp_0c := PTR(EMSSegment,0);
				C_1918_1825(
					0,0,f_width,
					f_x,f_y,320,
					f_width,f_height,
					bp_10^,bp_0c^
				);
				FREEMEM(bp_10,_size);
			END;
	END;
	EMSStart_0A;
	bp_0c := PTR(EMSSegment,0);
	ASM
		PUSH	DS
		LDS	SI,bp_0c
		MOV	AX,$A000
		MOV	ES,AX
		XOR	DI,DI
		MOV	CX,$2D00
		CLD	
		REPZ	
		DB	$66
		MOVSW	
		POP	DS
	END;
	ShowMouse(TRUE);
END;

{"load" bitmap?}
{C_031E}PROCEDURE _SCRIPT_4C;
BEGIN
	IF D_0CDD = 0
	THEN BEGIN
		C_1918_18DD(D_0CDC);
		D_0CDD := 1;
	END;
	Actors[D_0CDC]^.f_curFrame := _ScriptFetchByte;
	D_0CE0 := TRUE;
END;

{"put" current bitmap?}
{C_035C}PROCEDURE _SCRIPT_50(bp04:BYTE);
BEGIN
	IF D_0CDD = 0
	THEN BEGIN
		C_1918_18DD(D_0CDC);
		D_0CDD := 1;
	END;
	WITH Actors[bp04]^
	DO BEGIN
		f_aX[1] := _ScriptFetchWord;
		f_aY[1] := _ScriptFetchByte;
	END;
	D_0CE0 := TRUE;
END;

{game variable on}
{C_03B2}PROCEDURE _SCRIPT_53;
VAR bp_02:INTEGER;
BEGIN
	bp_02 := _ScriptFetchWord;
	State[bp_02] := 1;
	RefreshState(bp_02);
	D_0CDF := FALSE;
END;

{game variable off}
{C_03DD}PROCEDURE _SCRIPT_54;
VAR bp_02:INTEGER;
BEGIN
	bp_02 := _ScriptFetchWord;
	State[bp_02] := 0;
	RefreshState(bp_02);
	D_0CDF := FALSE;
END;

{reset script}
{C_0408}PROCEDURE _SCRIPT_57;
BEGIN
	PScriptCur := PScriptTop;
END;

{C_0422}PROCEDURE _SCRIPT_4D;
BEGIN
	IF D_0CDD = 0
	THEN BEGIN
		C_1918_18DD(D_0CDC);
		D_0CDD := 1;
	END;
	Actors[D_0CDC]^.f_mirrorX := TRUE;
	D_0CDF := FALSE;
END;

{C_045C}PROCEDURE _SCRIPT_25;
BEGIN
	IF D_0CDD = 0
	THEN BEGIN
		C_1918_18DD(D_0CDC);
		D_0CDD := 1;
	END;
	Actors[D_0CDC]^.f_scale := _ScriptFetchByte;
	D_0CDF := FALSE;
END;

{C_049A}PROCEDURE _SCRIPT_4E;
BEGIN
	IF D_0CDD = 0
	THEN BEGIN
		C_1918_18DD(D_0CDC);
		D_0CDD := 1;
	END;
	Actors[D_0CDC]^.f_mirrorX := FALSE;
	D_0CDF := FALSE;
END;

{main character frame?}
{C_04D4}PROCEDURE _SCRIPT_4F;
VAR bp_01:BYTE;
BEGIN
	bp_01 := _ScriptFetchByte;
	IF bp_01 <> $80
	THEN BEGIN{else 0528}
		IF D_0CDE = 0
		THEN BEGIN
			C_1918_18DD(1);
			D_0CDE := 1;
		END;
		IF bp_01 <> $ff
		THEN Actors[1]^.f_curFrame := bp_01
		ELSE Actors[1]^.f_curFrame := D_1A87;
		D_0CE0 := TRUE;
	END ELSE BEGIN
		D_0170 := 1;
		D_0CDF := FALSE;
	END;
END;

{main character position?}
{C_0534}PROCEDURE _SCRIPT_51;
BEGIN
	IF D_0CDE = 0
	THEN BEGIN
		C_1918_18DD(1);
		D_0CDE := 1;
	END;
	WITH Actors[1]^
	DO BEGIN
		f_aX[1] := _ScriptFetchWord;
		f_aY[1] := _ScriptFetchByte;
		D_1A37 := FindZoneAt(f_aX[1],f_aY[1]);
	END;
	C_14C8_07A2;
END;

{C_0592}PROCEDURE _SCRIPT_47;
BEGIN
	D_12CB := 0;
	ActionId := ACTION_0;
	D_12CC := 0;
	PlayerGoesTo(_ScriptFetchWord,_ScriptFetchByte);
	D_1A58 := 1;
END;

{soundFX}
{C_05C1}PROCEDURE _SCRIPT_4B;
VAR _soundId,bp_02,bp_03,_vol:BYTE;
BEGIN
	_soundId := _ScriptFetchByte;
	bp_02 := _ScriptFetchByte;
	bp_03 := _ScriptFetchByte;
	_vol := _ScriptFetchByte;
	MUSIC_setVolumes(ROUND((D_27C0[1] / 100.0) * 255.0),_vol);
	IF _soundId <= SFXCount
	THEN MUSIC_playSFX(ASFXHandle[_soundId],bp_02 * 117,bp_03);
END;

{shake or song?}
{C_0648}PROCEDURE _SCRIPT_55;
VAR bp_01:BYTE;
BEGIN
	bp_01 := _ScriptFetchByte;
	IF bp_01 = 1
	THEN BEGIN
		DoShakeScreen := TRUE;
		EXIT;
	END;
	IF bp_01 = 0
	THEN BEGIN
		DoShakeScreen := FALSE;
		ScreenOffset(0);
		EXIT;
	END;
	DEC(bp_01);
	IF (bp_01 > $80) AND (D_2A38 <> 0)
	THEN BEGIN
		D_0177 := TRUE;
		D_0CE2 := C_1D8E_00A6;
		D_0CE3 := bp_01 - $80;
	END ELSE BEGIN
		C_1D8E_00DA(bp_01);
	END;
END;

{empty?}
{C_06B1}PROCEDURE _SCRIPT_2B;
BEGIN
	_ScriptFetchByte;
END;

{get object?}
{C_06C0}PROCEDURE _SCRIPT_49;
VAR _objId:INTEGER;
BEGIN
	_objId := _ScriptFetchWord;
	IF CurObjId <> _objId
	THEN LoadObject(_objId);
	InventoryAdd(_objId,TRUE);
END;

{remove object?}
{C_06F0}PROCEDURE _SCRIPT_4A;
VAR _objId:INTEGER;
BEGIN
	_objId := _ScriptFetchWord;
	IF CurObjId <> _objId
	THEN LoadObject(_objId);
	InventoryRemove(_objId);
END;

{C_1031_071E}PROCEDURE SCRIPT_52;
BEGIN
	D_025E := TRUE;
	D_0176 := TRUE;
	SetMouseImage(@D_0172,2,2,1,1);
END;

{C_1031_0746}PROCEDURE SCRIPT_46;
BEGIN
	D_025E := FALSE;
	SetMouseImage(@C_1918_34F9,16,16,7,7);
	InventoryRender;
	D_0176 := FALSE;
END;

{C_0776}PROCEDURE _SCRIPT_43;
BEGIN
	_ScriptFetchByte;
END;

PROCEDURE C_1031_0785;
BEGIN
	EMSStart_13;
	D_0169 := D_016A;
	ShowMouse(FALSE);
	FastMove(PTR(EMSSegment,0)^,PTR($a000,0)^,$fa00);
	ShowMouse(TRUE);
	D_27C2 := FALSE;
END;

{C_07CB}PROCEDURE _ScriptSkipBytes(_count:BYTE);
VAR _i:BYTE;
BEGIN
	FOR _i := 1 TO _count
	DO _ScriptFetchByte;
END;

{set stretch infos?}
PROCEDURE C_07FD;
BEGIN
	D_27C2 := TRUE;
	D_0CE4 := _ScriptFetchWord;
	D_0CE6 := _ScriptFetchByte;
	D_0CE8 := _ScriptFetchWord;
	D_0CEA := _ScriptFetchByte;
	D_016B := _ScriptFetchByte;
	IF D_016E = 1
	THEN BEGIN
		D_0169 := 0;
		D_016A := D_016B;
	END ELSE BEGIN
		D_016A := 1;
		D_0169 := D_016B;
	END;
	IF D_016B = 0
	THEN C_1031_0785
	ELSE D_2A32 := D_2A32 SHR 1;
END;

{sub op?}
{C_086C}PROCEDURE _SCRIPT_26;
VAR
	bp_04:STRING[2];
	bp_05:BYTE;
	_ch:CHAR;
	_opcode:BYTE;
	_vol:BYTE;
	bp_0c:STRING[3];
	_____:WORD;
BEGIN
	_opcode := _ScriptFetchByte;
	EMSStart_13;
	CASE _opcode OF
		0: BEGIN
			D_016E := 1;
			ShowMouse(FALSE);
			FastMove(PTR($a000,0)^,PTR(EMSSegment,0)^,$fa00);
			ShowMouse(TRUE);
			C_07FD;{set stretch infos?}
		END;
		1: BEGIN
			D_016E := -1;
			C_07FD;{set stretch infos?}
		END;
		2: BEGIN
			D_0179 := TRUE;
			SetMouseImage(@C_1918_34F9,16,16,7,7);
			_ScriptSkipBytes(7);
		END;
		3: BEGIN
			D_0179 := FALSE;
			{-- --}
			IF D_0178
			THEN C_1031_008D;
			{-- --}
			_ScriptSkipBytes(7);
		END;
		4: BEGIN
			D_0CD6 := _ScriptFetchWord;
			D_0CD7 := _ScriptFetchByte;
			_ScriptSkipBytes(4);
		END;
		5: BEGIN
			_ScriptSkipBytes(7);
			D_0168 := 1;
		END;
		6: BEGIN
			CurSong := _ScriptFetchWord;
			_vol := _ScriptFetchByte;
			IF (CurSong <> $80) AND (CurSong <> $81)
			THEN BEGIN{else 09FD}
				TIMER_stop;
				MUSIC_stopSong;
				{-- --}
				STR(CurSong,bp_0c);
				RES_find('S' + bp_0c,RES_offset,RES_size);
				SFXCount := 0;
				MUSIC_loadSong(@RES_handle,ROUND((D_27C0[1] / 100.0) * _vol));
				MUSIC_playSong;
				TIMER_start;
			END;
			_ScriptSkipBytes(4);
		END;
		7: BEGIN
			_vol := _ScriptFetchWord;
			_ScriptSkipBytes(5);
			GlobalJ := ROUND((D_27C0[1] / 100.0) * _vol);
			MUSIC_setVolumes(GlobalJ,GlobalJ);
		END;
		8: BEGIN{shareware version:slide show}
			ShowMouse(FALSE);
			_ScriptSkipBytes(7);
			bp_05 := 1;
			REPEAT
				STR(bp_05,bp_04);
				CASE Language OF
					0: C_1196_009D('IN' + bp_04);
					1: C_1196_009D('GE' + bp_04);
				END;
				GlobalJ := bp_05;
				REPEAT
					_ch := READKEY;
					CASE _ch OF
						#0: BEGIN
							_ch := READKEY;
							CASE _ch OF
								#$4d,#$50: IF bp_05 < 12 THEN INC(bp_05);
								#$4b,#$48: IF bp_05 > 1 THEN DEC(bp_05);
							END;
						END;
						#13,' ': INC(bp_05);
					END;
				UNTIL (bp_05 <> GlobalJ) OR (_ch = #27);
				EMSStart_0A;
				FastMove(PTR(EMSSegment,0)^,PTR($a000,0)^,$fa00);
			UNTIL _ch = #27;
			ShowMouse(TRUE);
		END;
	END;
	D_0CDF := FALSE;
END;

{load resource A}
{C_0B73}PROCEDURE _SCRIPT_41;
VAR bpff00:STRING;
BEGIN
	D_27E6 := CurEMSPage;
	D_27EC := CurEMSOffset;
	STR(_ScriptFetchWord,bpff00);
	ParseResourceA('A' + bpff00);
	WITH Actors[D_2946]^
	DO BEGIN
		f_aWidth[1] := f_aFrameWidth[1]; f_aHeight[1] := f_aFrameHeight[1];
		f_aWidth[0] := f_aWidth[1]; f_aHeight[0] := f_aHeight[1];
		f_prevFrame := 1;
		f_curFrame := 1;
		f_aX[1] := 160; f_aY[1] := 100;
		f_aX[0] := f_aX[1]; f_aY[0] := f_aY[1];
		f_delay := 0;
		f_fb := TRUE;
		f_fc := FALSE;
		f_scale := $ff;
		f_mirrorX := FALSE;
	END;
	D_1A60 := 1;
	D_2807 := 1;
END;

{go to other script/R file}
{C_0CA9}PROCEDURE _SCRIPT_2D;
BEGIN
	D_27CB := TRUE;
	D_27C9 := _ScriptFetchByte;
	D_27CA := _ScriptFetchByte;
END;

{C_0CC6}PROCEDURE _SCRIPT_5A;
VAR bp_01:BYTE;
BEGIN
	bp_01 := _ScriptFetchByte;
	FREEMEM(D_1A5A,D_1A5E);
	C_16C2_00E8(D_27C4,bp_01);
END;

{conditionnal code?}
{C_0CFB}PROCEDURE _SCRIPT_42;
VAR
	_stateId:WORD;
	_op:CHAR;
	_first:BOOLEAN;
	_ignore:BOOLEAN;
	_state:BOOLEAN;
BEGIN
	_ignore := FALSE;
	REPEAT
		{-- --}
		_stateId := _ScriptFetchWord;
		IF _stateId > $7fff
		THEN _state := (State[$ffff - _stateId] = 0)
		ELSE _state := (State[_stateId] = 1);
		{-- --}
		IF _state AND (NOT _ignore)
		THEN BEGIN
			D_0CDF := FALSE;
			EXIT;
		END;
		{-- skip code until next condition? --}
		_ignore := FALSE;
		_op := #0;
		_first := TRUE;
		WHILE (PScriptCur <> PScriptEnd) AND (_op <> 'B')
		DO BEGIN
			_op := CHAR(_ScriptFetchByte);
			CASE _op OF
				'L','D','U','+','C','Z','O','%','H': _ScriptSkipBytes(1);
				'S','T','I','J','A','-','>': _ScriptSkipBytes(2);
				'P','Q','G': _ScriptSkipBytes(3);
				'K': _ScriptSkipBytes(4);
				'&': _ScriptSkipBytes(8);
				'W','M','N','E','R','F': ;
				'V',#$99: _ScriptSkipString;
			END;
			IF _first AND (_op = 'B')
			THEN _ignore := TRUE;
			_first := FALSE;
		END;
		{-- --}
	UNTIL PScriptCur = PScriptEnd;
	IF _op = 'E'
	THEN D_0CE1 := 'E';
END;

{palette set alpha}
{C_0E62}PROCEDURE _SCRIPT_48;
VAR _alpha:BYTE;
BEGIN
	_alpha := _ScriptFetchByte;
	D_0CDF := FALSE;
	_SetPaletteAlpha(_alpha);
END;

PROCEDURE C_1031_0E84;
BEGIN
	D_2807 := 0;
	DEC(D_2946);
	WITH Actors[D_2946 + 1]^
	DO FREEMEM(f_pScriptTop,f_scriptSize);
	DISPOSE(Actors[D_2946 + 1]);
	CurEMSPage := D_27E6;
	CurEMSOffset := D_27EC;
END;

{C_0EF0}PROCEDURE _SCRIPT_45;
BEGIN
	PScriptCur := PScriptEnd;
	IF (D_1A60 <> 0) AND (D_0CDC = D_2946)
	THEN D_1A60 := 0;
END;

{C_0F1F}PROCEDURE _SCRIPT_3E;
BEGIN
	IF _ScriptFetchWord <> D_1A70[2]
	THEN PScriptCur := PScriptEnd;
END;

{string/text}
{C_0F42}PROCEDURE _SCRIPT_56;
VAR
	_color:BYTE;
	_str:STRING;
	_ch:CHAR;
	_dummy0:BYTE;
	_dummy1:BYTE;
	_curFrame:BYTE;
BEGIN
	D_27B8 := _ScriptFetchByte;
	_color := _ScriptFetchByte;
	_str[0] := #0;
	REPEAT
		_ch := CHAR(_ScriptFetchByte);
		IF _ch <> '^'{x5e}
		THEN _str := _str + _ch;
	UNTIL _ch = '^'{x5e};
	{-- --}
	IF D_0178
	THEN C_1031_008D;
	{-- --}
	WITH Actors[D_27B8]^
	DO PutString_1(_str,f_aX[1],f_aY[1] - f_aHeight[1] - 10,_color);
	D_27F2 := TRUE;
	IF D_27B8 = 1
	THEN BEGIN
		IF PlayerIsMoving
		THEN C_14C8_0A5B;
		_curFrame := Actors[1]^.f_curFrame;
		GuessAnimType(_curFrame,D_27CD);
	END;
	D_27F4 := 0;
	D_27F6 := ROUND((LENGTH(_str) * (110 - D_27C0[2])) / 50.0);
END;

PROCEDURE C_10C2(bp04:BOOLEAN);
VAR
	bp_01:BYTE;
	bp_06:POINTER;
	{-- --}
	{wait?}
	{INNER_106A}PROCEDURE _SCRIPT_44;
	BEGIN
		IF bp04
		THEN Actors[D_0CDC]^.f_delay := _ScriptFetchByte
		ELSE D_27CC := _ScriptFetchByte;
	END;
	{-- --}
BEGIN
	REPEAT
		D_0CDF := TRUE;
		D_0CE0 := FALSE;
		IF PScriptCur <> PScriptEnd
		THEN BEGIN
			bp_01 := _ScriptFetchByte;
			D_0CE1 := CHAR(bp_01);
			CASE D_0CE1 OF
				'&'{x26}: _SCRIPT_26;{sub op?}
				'%'{x25}: _SCRIPT_25;
				'L'{x4c}: _SCRIPT_4C;{"load" bitmap?}
				'P'{x50}: _SCRIPT_50(D_0CDC);{"put" current bitmap?}
				'D'{x44}: _SCRIPT_44;{wait?}
				'S'{x53}: _SCRIPT_53;{game variable on}
				'T'{x54}: _SCRIPT_54;{game variable off}
				'W'{x57}: _SCRIPT_57;{reset script}
				'B'{x42}: _SCRIPT_42;{conditionnal code?}
				'M'{x4d}: _SCRIPT_4D;
				'N'{x4e}: _SCRIPT_4E;
				'O'{x4f}: _SCRIPT_4F;{main character frame?}
				'Q'{x51}: _SCRIPT_51;{main character position?}
				'G'{x47}: _SCRIPT_47;
				'K'{x4b}: _SCRIPT_4B;{soundFX}
				'E'{x45}: _SCRIPT_45;
				'U'{x55}: _SCRIPT_55;{shake or song?}
				'+'{x2b}: _SCRIPT_2B;{empty?}
				'I'{x49}: _SCRIPT_49;{get object?}
				'J'{x4a}: _SCRIPT_4A;{remove object?}
				'V'{x56}: BEGIN{english string}
					IF Language = 0
					THEN BEGIN
						_SCRIPT_56;{string/text}
					END ELSE BEGIN
						_ScriptSkipString;
						D_0CDF := FALSE;
					END;
				END;
				#$99: BEGIN{german string}
					IF Language = 1
					THEN BEGIN
						_SCRIPT_56;{string/text}
					END ELSE BEGIN
						_ScriptSkipString;
						D_0CDF := FALSE;
					END;
				END;
				'R'{x52}: SCRIPT_52;
				'F'{x46}: SCRIPT_46;
				'C'{x43}: _SCRIPT_43;
				'A'{x41}: _SCRIPT_41;{load resource A}
				'-'{x2d}: _SCRIPT_2D;{go to other script/R file}
				'Z'{x5a}: _SCRIPT_5A;
				'>'{x3e}: _SCRIPT_3E;
				'H'{x48}: _SCRIPT_48;{palette set alpha}
			END;
		END;
		{-- loop script? --}
		IF (PScriptEnd = PScriptCur) AND bp04 AND (D_0CE1 <> 'E')
		THEN BEGIN
			_SCRIPT_57;{reset script}
			D_0CDF := TRUE;
		END;
		{-- --}
		IF D_0CE0
		THEN BEGIN
			bp_06 := PScriptCur;
			IF CHAR(_ScriptFetchByte) IN ['+','A','D','E','K','P','Q','S','T','U','W']
			THEN D_0CDF := FALSE;
			PScriptCur := bp_06;
		END;
		{-- --}
	UNTIL D_0CDF;
END;

PROCEDURE C_12B3;
BEGIN
	{-- --}
	IF D_0CDD = 1
	THEN BEGIN
		WITH Actors[D_0CDC]^
		DO IF
			(f_curFrame = f_prevFrame) AND
			(f_mirrorX = D_2804) AND
			(f_aY[1] = f_aY[0]) AND
			(f_aX[1] = f_aX[0])
		THEN f_fb := FALSE;
		C_1918_0D50(D_0CDC);
	END;
	{-- --}
	IF D_0CDE = 1
	THEN BEGIN
		WITH Actors[1]^
		DO IF
			(f_curFrame = f_prevFrame) AND
			(f_mirrorX = D_2804) AND
			(f_aY[1] = f_aY[0]) AND
			(f_aX[1] = f_aX[0])
		THEN f_fb := FALSE;
		C_1918_0D50(1);
	END;
	{-- --}
END;

PROCEDURE C_1031_1391;
VAR
	bp_01:BYTE;
	bp_02:BYTE;
BEGIN
	D_0CDC := 1;
	IF NOT D_27F2
	THEN BEGIN{else 1430}
		IF D_1A60 = 0
		THEN BEGIN{else 142D}
			PScriptTop := D_1A78;
			PScriptCur := D_1A7C;
			PScriptEnd := D_1A80;
			D_0CDE := 0;
			D_0CDD := 0;
			C_10C2(FALSE);
			D_1A7C := PScriptCur;
			IF PScriptCur = PScriptEnd
			THEN BEGIN
				D_1A84 := 0;
				FREEMEM(PScriptTop,D_1A5E);
				D_2808 := FALSE;
			END;
			C_12B3;
		END;
		{goto 14F3}
	END ELSE BEGIN
		IF D_27F4 > 0
		THEN BEGIN
			DEC(D_27F4);
			{goto 14E1}
		END ELSE BEGIN
			D_27F4 := RANDOM(3) + 1;
			C_1918_18DD(D_27B8);
			WITH Actors[D_27B8]^
			DO BEGIN
				bp_01 := f_curFrame;
				IF D_27B8 = 1
				THEN BEGIN{else 14AB}
					REPEAT
						bp_02 := D_017A[D_27CD][RANDOM(D_0186[D_27CD]) + 1];
					UNTIL bp_02 <> bp_01;
				END ELSE IF BP_02 = f_count
				THEN BEGIN
					bp_02 := f_count - 1;
				END ELSE BEGIN
					bp_02 := f_count;
				END;
				f_curFrame := bp_02;
			END;
			C_1918_0D50(D_27B8);
		END;
		IF D_27F6 > 0
		THEN DEC(D_27F6)
		ELSE C_16DC_0000;
	END;
END;

PROCEDURE C_1031_14F5;
VAR
	_i:BYTE;
	bp_06:^BYTE;
BEGIN
	FOR _i := 4 TO D_2946
	DO BEGIN
		D_0CDD := 0;
		D_0CDE := 0;
		D_0CDC := _i;
		IF Actors[_i]^.f_delay > 0
		THEN BEGIN
			DEC(Actors[_i]^.f_delay)
			{goto 161F}
		END ELSE IF (_i = D_27FA) AND D_27F8
		THEN BEGIN
		END ELSE BEGIN
			PScriptTop := Actors[_i]^.f_pScriptTop;
			PScriptCur := Actors[_i]^.f_pScriptCur;

			bp_06 := PScriptTop;
			INC(bp_06,Actors[_i]^.f_scriptSize);
			PScriptEnd := bp_06;

			IF PScriptCur <> PScriptEnd
			THEN C_10C2(TRUE)
			ELSE IF (D_2807 <> 0) AND (_i = D_2946)
			THEN C_1031_0E84;
			Actors[_i]^.f_pScriptCur := PScriptCur;
		END;
		C_12B3;
	END;
END;

{C_1031_162F}
BEGIN
	D_1A84 := 0;
	DoShakeScreen := FALSE;
END.
