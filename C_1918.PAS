(*
Escape From Delirium 
	by Virtual X-Perience 1995
	decompiled by ergonomy_joe in 2019
*)
{$G+}
{$X+}
{ DEFINE FRENCH}
UNIT C_1918;

INTERFACE
CONST
	D_01F2:BYTE = 0;
	{-- animation related --}
	{D_01F4}AnimFrames:ARRAY[0..2,1..9] OF BYTE = (
		($1F,$1E,$06,$05,$04,$03,$02,$01,$07),{right to left}
		($0D,$0E,$0F,$10,$00,$00,$00,$00,$11),{coming}
		($08,$09,$0A,$0B,$00,$00,$00,$00,$0C){going away}
	);
	{D_0210}AnimSteps:ARRAY[0..2] OF BYTE = (8,4,4);
	{-- --}
	D_0214:ARRAY[0..1] OF STRING[$24] = (
		'ABCDEFGHIJKLMNOPQRSTUVWXYZ?,.-!90''()',
		'abcdefghijklmnopqrstuvwxyz":12345678'
	);
{$IFDEF FRENCH}
	D_0214_bis:STRING[$24] =
		#$83#$85#$87#$82#$88#$89#$8a#$8b#$8c' '#$93#$94#$96#$97
	;
{$ENDIF}
	D_025E:BOOLEAN = TRUE;{do shrink transion(2)?}

{C_1918_0000}PROCEDURE GuessAnimType(_frame:BYTE; VAR _vAnimType:BYTE);
{C_1918_005A}FUNCTION C_1918_005A:BOOLEAN;
PROCEDURE C_1918_0124;
PROCEDURE C_1918_01D8(bp06:STRING);
{C_1918_022F}PROCEDURE ScriptFetchArray(VAR bp08; bp06:WORD);
{C_1918_0274}FUNCTION BufferFetchByte(VAR bp06:POINTER):BYTE;
{C_1918_02B5}FUNCTION BuffetFetchWord(VAR bp06:POINTER):WORD;
{C_1918_02F7}PROCEDURE GetMouseXY(VAR _x,_y:INTEGER);
{C_1918_0526}PROCEDURE ShowMouse(_show:BOOLEAN);
{C_1918_0555}PROCEDURE SetMouseImage(_p:POINTER; _width,_height,bp08,bp06:BYTE);
{C_1918_05A6}PROCEDURE SetMouseShape(_actionId:BYTE);
{C_1918_060C}PROCEDURE EMSDoMapping(_handle,bp08:WORD; bp06:BYTE);
{C_1918_0657}PROCEDURE DrawLine(_x_0,_y_0,_x_1,_y_1:INTEGER; _color:BYTE);
{C_1918_095D}PROCEDURE StartEMS;
{C_1918_0A01}PROCEDURE Stretch2Screen(_src,_dst_ignored:POINTER; _left,_top,_right,_bottom:INTEGER);
{C_1918_0ABB}PROCEDURE StopEMS;
{C_1918_0AD0}PROCEDURE EMS2Pointer(VAR bp0a; VAR _ptr:POINTER);
{C_1918_0B57}PROCEDURE EMSStart_00;
{C_1918_0B93}PROCEDURE EMSStart_13;
{C_1918_0BCF}PROCEDURE EMSStart_0B;
{C_1918_0C1A}PROCEDURE EMSStart_0A;
{C_1918_0C56}PROCEDURE EMSStart_04;
PROCEDURE C_1918_0C92;
PROCEDURE C_1918_0D50(bp06:BYTE);
PROCEDURE C_1918_0E19(VAR _src,_dst; _width,_height,_x,_y,bp06:INTEGER);
PROCEDURE C_1918_0E60(VAR _src,_dst; bp14:INTEGER; bp12:BYTE; bp10,bp0e,bp0c,bp0a,bp08,bp06:INTEGER);
{C_1918_0EC6}PROCEDURE ParseResourceA(bp06:STRING);
PROCEDURE C_1918_1369(_p06:STRING);
PROCEDURE C_1918_15AD;
PROCEDURE C_1918_15EB;
PROCEDURE C_1918_1825(
	_srcX,_srcY,_srcStride,
	_dstX,_dstY,_dstStride,
	_width:INTEGER; _height:BYTE;
	VAR _src,_dst
);
PROCEDURE C_1918_1878(
	_srcX,_srcY,_srcStride,
	_dstX,_dstY,_dstStride,
	_width:INTEGER; _height:BYTE;
	VAR _src,_dst; bp08,_color:BYTE
);
PROCEDURE C_1918_18DD(bp06:BYTE);
PROCEDURE C_1918_1920(VAR _src,_dst; bp16,bp14,bp12,bp10,bp0e,bp0c,bp0a:WORD; bp08:INTEGER; bp06:BYTE);
PROCEDURE C_1918_1AB4(VAR _src,_dst; bp16,bp14,bp12,bp10,bp0e,bp0c:WORD; bp0a,bp08:INTEGER; bp06:BYTE);
PROCEDURE C_1918_1BB1(bp06:BYTE);
PROCEDURE C_1918_2A16;
{C_1918_2D69}PROCEDURE PutString_1(_str:STRING; _x,_y:INTEGER; _color:BYTE);
{C_1918_302E}PROCEDURE PutString_2(_str:STRING; _x,_y:INTEGER);
{C_1918_3207}PROCEDURE RefreshState(_stateId:WORD);
PROCEDURE C_1918_34BC(_src:POINTER);

PROCEDURE C_1918_34F9;

IMPLEMENTATION

USES DOS,CRT,
	C_1D7C,
	C_1D8E,
	C_1DD9,
	C_1E02,
	C_1E06,
	BSS;

{$L C_1_34F9}
{$L C_1_35F9}
{$L C_1_3869}
{$L C_1_3A79}
{$L C_1_3D97}
{$L C_1_4061}
{$L C_1_41FF}
{$L C_1_440C}

PROCEDURE C_1918_34F9; EXTERNAL;
PROCEDURE C_1918_35F9; EXTERNAL;
PROCEDURE C_1918_3869; EXTERNAL;
PROCEDURE C_1918_3A79; EXTERNAL;
PROCEDURE C_1918_3D97; EXTERNAL;
PROCEDURE C_1918_4061; EXTERNAL;
PROCEDURE C_1918_41FF; EXTERNAL;
PROCEDURE C_1918_440C; EXTERNAL;

{C_1918_0000}PROCEDURE GuessAnimType(_frame:BYTE; VAR _vAnimType:BYTE);
VAR _i,_j:BYTE;
BEGIN
	_vAnimType := 0;
	FOR _i := 0 TO 2
	DO FOR _j := 1 TO 9
	DO IF AnimFrames[_i][_j] = _frame
	THEN _vAnimType := _i;
END;

{mouse:start/detect?}
{C_1918_005A}FUNCTION C_1918_005A:BOOLEAN;
BEGIN
	C_1918_005A := FALSE;
	{-- --}
	GETINTVEC($33,D_279A);
	IF (D_279A = nil)
	THEN EXIT;
	IF (BYTE(D_279A^) = $cf)
	THEN EXIT;
	{-- --}
	IF MEM[$40:$49] = 7
	THEN MEM[$40:$49] := 6;
	{-- reset/query driver presence --}
	Regs.AX := 0;
	INTR($33,Regs);
	C_1918_005A := (Regs.AX <> 0);
	{-- hide pointer --}
	Regs.AX := 2;
	INTR($33,Regs);
	{-- --}
	D_27B4 := FALSE;
END;

{"Error-Handler"?}
PROCEDURE C_1918_0124;
BEGIN
	ASM
		MOV	AX,$0003
		INT	$10
	END;
	TEXTBACKGROUND(BLACK);
	TEXTCOLOR(LIGHTGRAY);
	CLRSCR;
	TEXTCOLOR(WHITE);
	IF TIMER_isOn
	THEN TIMER_stop;
	IF (D_2A38 <> 0) AND D_2A35
	THEN BEGIN
		IF D_2A34
		THEN MUSIC_stopSong;
		MUSIC_clean;
	END;
	IF D_01F2 <> 0
	THEN StopEMS;
	C_1918_005A;
	RELEASE(D_288E);
	PORT[$21] := PORT[$21] AND $fd;
	WRITELN('� Error-Handler 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴');
	TEXTCOLOR(LIGHTRED);
	WRITELN;
	EXITPROC := D_288A;
END;

PROCEDURE C_1918_01D8(bp06:STRING);
BEGIN
	C_1918_0124;{"Error-Handler"?}
	WRITELN(bp06,#10);
	HALT(1);
END;

{C_1918_022F}PROCEDURE ScriptFetchArray(VAR bp08; bp06:WORD);
VAR bp_04:^BYTE;
BEGIN
	FastMove(D_27E0^,bp08,bp06);
	bp_04 := D_27E0;
	INC(bp_04,bp06);
	D_27E0 := bp_04;
END;

{C_1918_0274}FUNCTION BufferFetchByte(VAR bp06:POINTER):BYTE;
VAR bp_06:^BYTE;
BEGIN
	bp_06 := bp06;
	BufferFetchByte := bp_06^;
	INC(bp_06);
	bp06 := bp_06;
END;

{C_1918_02B5}FUNCTION BuffetFetchWord(VAR bp06:POINTER):WORD;
VAR bp_06:^WORD;
BEGIN
	bp_06 := bp06;
	BuffetFetchWord := bp_06^;
	INC(bp_06);
	bp06 := bp_06;
END;

{C_1918_02F7}PROCEDURE GetMouseXY(VAR _x,_y:INTEGER);
BEGIN
	{-- query position & buttons --}
	Regs.AX := 3;
	INTR($33,Regs);
	_y := Regs.DX;
	_x := Regs.CX;
END;

{C_0329}PROCEDURE _MouseOn;
VAR _mouseX,_mouseY:INTEGER;
BEGIN
	GetMouseXY(_mouseX,_mouseY);
	D_27B5 := TRUE;
	{-- horizontal position --}
	D_279E := (_mouseX SHR 1) - D_2798;
	IF D_279E < 0
	THEN D_27A2 := -D_279E
	ELSE D_27A2 := 0;
	IF (D_27B2 + D_279E) > 319
	THEN D_27A4 := D_27B2 + D_279E - 320
	ELSE D_27A4 := 0;
	{-- vertical position --}
	D_27A0 := _mouseY - D_2799;
	IF D_27A0 < 0
	THEN D_27A6 := -D_27A0
	ELSE D_27A6 := 0;
	IF (D_27B3 + D_27A0) > 199
	THEN D_27A8 := D_27B3 + D_27A0 - 200
	ELSE D_27A8 := 0;
	{-- --}
	C_1918_1825(
		D_279E + D_27A2,D_27A0 + D_27A6,320,
		D_27A2,D_27A6,D_27B2,
		D_27B2 - D_27A4 - D_27A2,D_27B3 - D_27A6 - D_27A8,
		PTR($a000,0)^,D_27AA^
	);
	C_1918_0E60(
		D_27AE^,PTR($a000,0)^,
		D_27B2 - D_27A4 - D_27A2,D_27B3 - D_27A6 - D_27A8,
		D_279E + D_27A2,D_27A0 + D_27A6,
		D_27A2,D_27A6,
		320,D_27B2
	);
	D_27B4 := TRUE;
END;

{C_04AB}PROCEDURE _MouseOff;
BEGIN
	D_27B4 := FALSE;
	{-- --}
	IF D_27B5
	THEN C_1918_1825(
		D_27A2,D_27A6,D_27B2,
		D_279E + D_27A2,D_27A0 + D_27A6,320,
		D_27B2 - D_27A4 - D_27A2,D_27B3 - D_27A6 - D_27A8,
		D_27AA^,PTR($a000,0)^
	);
END;

{C_1918_0526}PROCEDURE ShowMouse(_show:BOOLEAN);
BEGIN
	CASE _show OF
		TRUE: IF NOT D_27B4 THEN _MouseOn;
		FALSE: IF D_27B4 THEN _MouseOff;
	END;
END;

{C_1918_0555}PROCEDURE SetMouseImage(_p:POINTER; _width,_height,bp08,bp06:BYTE);
BEGIN
	ShowMouse(FALSE);
	D_27B2 := _width; D_27B3 := _height;
	D_2798 := bp08; D_2799 := bp06;
	FastMove(_p^,D_27AE^,_width * _height);
	ShowMouse(TRUE);
END;

{C_1918_05A6}PROCEDURE SetMouseShape(_actionId:BYTE);
CONST
	D_0260:ARRAY[1..7,0..1] OF BYTE = (
		($1A,$18),
		($18,$16),
		($26,$15),
		($22,$15),
		($17,$12),
		($18,$17),
		($19,$15)
	);
	D_026E:ARRAY[1..7] OF POINTER = (
		@C_1918_35F9,
		@C_1918_3869,
		@C_1918_3A79,
		@C_1918_3D97,
		@C_1918_4061,
		@C_1918_440C,
		@C_1918_41FF
	);
BEGIN
	IF (_actionId > 0) AND (_actionId < 8)
	THEN SetMouseImage(D_026E[_actionId],D_0260[_actionId][0],D_0260[_actionId][1],1,1)
	ELSE SetMouseImage(@C_1918_34F9,16,16,7,7);
END;

{C_1918_060C}PROCEDURE EMSDoMapping(_handle,bp08:WORD; bp06:BYTE);
BEGIN
	ASM
		MOV	AH,$44	{map memory into page frame}
		MOV	AL,bp06
		MOV	BX,bp08
		MOV	DX,_handle
		INT	$67
	END;
END;

{C_1918_0657}PROCEDURE DrawLine(_x_0,_y_0,_x_1,_y_1:INTEGER; _color:BYTE);
VAR
	_error:INTEGER;
	_delta_x,_delta_y:INTEGER;
	_incr_1:INTEGER;
	_incr_2:INTEGER;
	_incr_x,_incr_y:INTEGER;
	_x,_y:INTEGER;
	_voffset:INTEGER;
	_p_16:INTEGER;
	{-- --}
	{INNER_0627}PROCEDURE INNER_Swap(VAR bbp0a,bbp06:INTEGER);
	VAR bbp_02:INTEGER;
	BEGIN
		bbp_02 := bbp06;
		bbp06 := bbp0a;
		bbp0a := bbp_02;
	END;
	{-- --}
BEGIN
	IF ABS(_x_1 - _x_0) < ABS(_y_1 - _y_0)
	THEN BEGIN{else 076B}
		IF _y_0 > _y_1
		THEN BEGIN{else 06A8}
			INNER_Swap(_x_0,_x_1);
			INNER_Swap(_y_0,_y_1);
		END;
		IF _x_1 > _x_0
		THEN _incr_x := 1
		ELSE _incr_x := -1;
		_delta_y := _y_1 - _y_0;
		_delta_x := ABS(_x_1 - _x_0);
		_error := (_delta_x SHL 1) - _delta_y;
		_incr_1 := (_delta_x - _delta_y) SHL 1;
		_incr_2 := _delta_x SHL 1;
		_x := _x_0;
		_y := _y_0;
		_voffset := _x + _y * 320;
		MEM[$a000:_voffset] := _color;
		FOR _y := (_y_0 + 1) TO _y_1
		DO BEGIN
			IF _error >= 0
			THEN BEGIN
				INC(_x,_incr_x);
				INC(_error,_incr_1);
			END ELSE BEGIN
				INC(_error,_incr_2);
			END;
			_voffset := _x + _y * 320;
			MEM[$a000:_voffset] := _color;
		END;
	END ELSE BEGIN
		IF _x_0 > _x_1
		THEN BEGIN{else 078F}
			INNER_Swap(_x_0,_x_1);
			INNER_Swap(_y_0,_y_1);
		END;
		IF _y_1 > _y_0
		THEN _incr_y := 1
		ELSE _incr_y := -1;
		_delta_x := _x_1 - _x_0;
		_delta_y := ABS(_y_1 - _y_0);
		_error := (_delta_y SHL 1) - _delta_x;
		_incr_1 := (_delta_y - _delta_x) SHL 1;
		_incr_2 := _delta_y SHL 1;
		_x := _x_0;
		_y := _y_0;
		_voffset := _x + _y * 320;
		MEM[$a000:_voffset] := _color;
		FOR _x := (_x_0 + 1) TO _x_1
		DO BEGIN
			IF _error >= 0
			THEN BEGIN
				INC(_y,_incr_y);
				INC(_error,_incr_1);
			END ELSE BEGIN
				INC(_error,_incr_2);
			END;
			_voffset := _x + _y * 320;
			MEM[$a000:_voffset] := _color;
		END;
	END;
END;

{C_1918_095D}PROCEDURE StartEMS;
VAR bp_04:STRING[3];
BEGIN
	IF NOT EMS_detect
	THEN C_1918_01D8('No EXPANDED-Memorymanager installed. (Put EMM386 in your CONFIG.SYS)!');
	IF EMS_getSize < 50
	THEN C_1918_01D8('Not enough EMS-memory available. This game needs 800kB! EMS');
	EMSSegment := EMS_getSegment;
	IF EMSSegment = -1
	THEN C_1918_01D8(
		'Can''t use this EMS-Frame-segment! Use'#10#13 +
		'DEVICE=EMM386.EXE RAM D=48 in your CONFIG.SYS'
	);
	EMSHandle := EMS_alloc(50);
	IF EMSHandle = -1
	THEN BEGIN
		STR(D_2FB2,bp_04);
		C_1918_01D8(
			'An error occured getting the EMS-Pages!'#13#10 +
			'Error #: ' + bp_04
		);
	END;
	D_01F2 := 1;
	CurEMSPage := $17;
	CurEMSOffset := 0;
END;

{C_1918_0A01}PROCEDURE Stretch2Screen(_src,_dst_ignored:POINTER; _left,_top,_right,_bottom:INTEGER);
LABEL C_0A55,C_0A68,C_0A6B,C_0A73,C_0A7C,C_0A87,C_0A92,C_0AA1;
VAR
	_p_01:BYTE;
	bp_02:BYTE;
	bp_04:WORD;
BEGIN
	ASM
		MOV	BX,$FF

		{bp_02 := ((_bottom - _top) * $ff) DIV 200;}
		MOV	AX,_bottom
		SUB	AX,_top
		XOR	DX,DX
		MUL	BX
		MOV	CX,200
		DIV	CX
		MOV	bp_02,AL

		{ch := ((_right - _left) * $ff) DIV 320;}
		MOV	AX,_right
		SUB	AX,_left
		MUL	BX
		MOV	CX,320
		DIV	CX
		MOV	CH,AL

		CLD	
		MOV	AX,$A000
		MOV	ES,AX
		XOR	DI,DI

		PUSH	DS
		LDS	SI,_src
		MOV	AX,_top
		MOV	BX,320
		MUL	BX
		ADD	AX,_left
		ADD	SI,AX
		MOV	bp_04,SI

		MOV	BL,200
		XOR	BH,BH
		INC	BH
C_0A55:
		ADD	BH,bp_02
		JNB	C_0A68
		INC	BH
		MOV	SI,bp_04
		ADD	SI,320
		MOV	bp_04,SI
		JMP	C_0A6B
C_0A68:
		MOV	SI,bp_04
C_0A6B:
		MOV	CL,$50
		MOV	AL,[SI]
		XOR	AH,AH
		INC	AH
C_0A73:
		ADD	AH,CH
		JNB	C_0A7C
		INC	AH
		MOV	AL,[SI]
		INC	SI
C_0A7C:
		MOV	DL,AL
		ADD	AH,CH
		JNB	C_0A87
		INC	AH
		MOV	AL,[SI]
		INC	SI
C_0A87:
		MOV	DH,AL
		ADD	AH,CH
		JNB	C_0A92
		INC	AH
		MOV	AL,[SI]
		INC	SI
C_0A92:
		DB	$66
		ROR	DX,$10
		MOV	DL,AL
		ADD	AH,CH
		JNB	C_0AA1
		INC	AH
		MOV	AL,[SI]
		INC	SI
C_0AA1:
		MOV	DH,AL
		DB	$66
		ROR	DX,$10
		DB	$66
		MOV	ES:[DI],DX
		ADD	DI,4
		DEC	CL
		JNZ	C_0A73
		DEC	BL
		JNZ	C_0A55
		POP	DS
	END;
END;

{C_1918_0ABB}PROCEDURE StopEMS;
BEGIN
	EMS_free(EMSHandle);
END;

{C_1918_0AD0}PROCEDURE EMS2Pointer(VAR bp0a; VAR _ptr:POINTER);
VAR
	_emsPtr:tEMSPtr;
	_i:BYTE;
	_p_0a:ARRAY[1..3] OF BYTE;
BEGIN
	_emsPtr := tEMSPtr(bp0a);
	IF _emsPtr.f_pageCount = 0
	THEN BEGIN
		_ptr := Actors[2]^.f_pData;
	END ELSE BEGIN
		FOR _i := 0 TO (_emsPtr.f_pageCount - 1)
		DO EMSDoMapping(EMSHandle,_emsPtr.f_firstPage + _i,_i);
		_ptr := PTR(EMSSegment,_emsPtr.f_offset);
	END;
END;

{C_1918_0B57}PROCEDURE EMSStart_00;
BEGIN
	EMSDoMapping(EMSHandle,0,0);
	EMSDoMapping(EMSHandle,1,1);
	EMSDoMapping(EMSHandle,2,2);
	EMSDoMapping(EMSHandle,3,3);
END;

{C_1918_0B93}PROCEDURE EMSStart_13;
BEGIN
	EMSDoMapping(EMSHandle,$13,0);
	EMSDoMapping(EMSHandle,$14,1);
	EMSDoMapping(EMSHandle,$15,2);
	EMSDoMapping(EMSHandle,$16,3);
END;

{C_1918_0BCF}PROCEDURE EMSStart_0B;
BEGIN
	EMSDoMapping(EMSHandle,$d,0);
	EMSDoMapping(EMSHandle,$e,1);
	EMSDoMapping(EMSHandle,$f,2);
	D_27D8 := PTR(EMSSegment,0);
	D_27DC := PTR(EMSSegment,$44c0);
END;

{C_1918_0C1A}PROCEDURE EMSStart_0A;
BEGIN
	EMSDoMapping(EMSHandle,$a,0);
	EMSDoMapping(EMSHandle,$b,1);
	EMSDoMapping(EMSHandle,$c,2);
	EMSDoMapping(EMSHandle,$12,3);
END;

{C_1918_0C56}PROCEDURE EMSStart_04;
BEGIN
	EMSDoMapping(EMSHandle,4,0);
	EMSDoMapping(EMSHandle,5,1);
	EMSDoMapping(EMSHandle,6,2);
	EMSDoMapping(EMSHandle,7,3);
END;

PROCEDURE C_1918_0C92;
BEGIN
	EMSStart_0A;
	ASM
		PUSH	DS
		MOV	ES,EMSSegment
		XOR	DI,DI
		MOV	AX,$A000
		MOV	DS,AX
		CLD	
		XOR	SI,SI
		MOV	CX,$3E80
		REPZ	
		DB	$66
		MOVSW	
		POP	DS
	END;
END;

{C_0CB8}PROCEDURE _EMSAlloc(VAR bp08:tEMSPtr; _size:LONGINT);
BEGIN
	WITH bp08
	DO BEGIN
		f_firstPage := CurEMSPage;
		f_offset := CurEMSOffset;
		f_pageCount := 1;
		WHILE _size >= ($4000 - CurEMSOffset)
		DO BEGIN
			_size := (_size - $4000) + CurEMSOffset;
			INC(CurEMSPage);
			INC(f_pageCount);
			CurEMSOffset := 0;
		END;
	END;
	CurEMSOffset := CurEMSOffset + _size;
	EMS2Pointer(bp08,D_27D8);
END;

PROCEDURE C_1918_0D50(bp06:BYTE);
BEGIN
	WITH Actors[bp06]^
	DO BEGIN
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

PROCEDURE C_1918_0E19(VAR _src,_dst; _width,_height,_x,_y,bp06:INTEGER);
LABEL C_0E45,C_0E4A,C_0E52,C_0E53;
BEGIN
	ASM
		PUSH	DS
		LES	DI,_dst
		LDS	SI,_src
		XOR	DX,DX
		XOR	CX,CX
		CLD	
		MOV	AX,_y
		MOV	BX,bp06
		MUL	BX
		ADD	AX,_x
		ADD	DI,AX
		MOV	BX,bp06
		SUB	BX,_width
		MOV	DH,BYTE(_height)
C_0E45:
		INC	DL
		MOV	CX,_width
C_0E4A:
		LODSB	
		CMP	AL,1
		JZ	C_0E52
		STOSB	
		JMP	C_0E53
C_0E52:
		INC	DI
C_0E53:
		LOOP	C_0E4A
		ADD	DI,BX
		CMP	DL,DH
		JNZ	C_0E45
		POP	DS
	END;
END;

PROCEDURE C_1918_0E60(VAR _src,_dst; bp14:INTEGER; bp12:BYTE; bp10,bp0e,bp0c,bp0a,bp08,bp06:INTEGER);
LABEL C_0EA6,C_0EAB,C_0EB3,C_0EB4;
VAR bp_02:INTEGER;
BEGIN
	bp_02 := bp06 - bp14;
	ASM
		PUSH	DS

		LES	DI,_dst
		LDS	SI,_src
		XOR	DX,DX
		XOR	CX,CX
		CLD	
		MOV	AX,bp0e
		MOV	BX,bp08
		MUL	BX
		ADD	AX,bp10
		ADD	DI,AX
		MOV	AX,bp0a
		MOV	BX,bp06
		MUL	BX
		ADD	AX,bp0c
		ADD	SI,AX
		MOV	BX,bp08
		SUB	BX,bp14
		MOV	DH,bp12
C_0EA6:
		INC	DL
		MOV	CX,bp14
C_0EAB:
		LODSB	
		CMP	AL,1
		JZ	C_0EB3
		STOSB	
		JMP	C_0EB4
C_0EB3:
		INC	DI
C_0EB4:
		LOOP	C_0EAB
		ADD	DI,BX
		ADD	SI,bp_02
		CMP	DL,DH
		JNZ	C_0EA6

		POP	DS
	END;
END;

{C_1918_0EC6}PROCEDURE ParseResourceA(bp06:STRING);
VAR
	_i:BYTE;
	_ptr:POINTER;
BEGIN
	IF bp06 <> '-'
	THEN RES_find(bp06,D_2770,D_2774);
	INC(D_2946);
	NEW(Actors[D_2946]);
	WITH Actors[D_2946]^
	DO BEGIN
		IF bp06 <> '-'
		THEN BEGIN{else 1117}
			BLOCKREAD(RES_handle,f_count,1);
			BLOCKREAD(RES_handle,f_scriptSize,2);
			GETMEM(f_pScriptTop,f_scriptSize);
			f_pScriptCur := f_pScriptTop;
			BLOCKREAD(RES_handle,f_pScriptTop^,f_scriptSize);
			BLOCKREAD(RES_handle,f_f9,1);
			FOR _i := 1 TO f_count
			DO BEGIN
				BLOCKREAD(RES_handle,f_aFrameWidth[_i],1);
				BLOCKREAD(RES_handle,f_aFrameHeight[_i],1);
				_EMSAlloc(f_emsPtr[_i],f_aFrameWidth[_i] * f_aFrameHeight[_i]);
				BLOCKREAD(RES_handle,D_27D8^,f_aFrameWidth[_i] * f_aFrameHeight[_i]);
			END;
			{goto 1325}
		END ELSE BEGIN
			f_count := BufferFetchByte(D_27E0);
			f_scriptSize := BuffetFetchWord(D_27E0);
			GETMEM(f_pScriptTop,f_scriptSize);
			f_pScriptCur := f_pScriptTop;
			ScriptFetchArray(f_pScriptTop^,f_scriptSize);
			f_f9 := BufferFetchByte(D_27E0);
			FOR _i := 1 TO f_count
			DO BEGIN
				f_aFrameWidth[_i] := BufferFetchByte(D_27E0);
				f_aFrameHeight[_i] := BufferFetchByte(D_27E0);
				GETMEM(_ptr,f_aFrameWidth[_i] * f_aFrameHeight[_i]);
				ScriptFetchArray(_ptr^,f_aFrameWidth[_i] * f_aFrameHeight[_i]);
				_EMSAlloc(f_emsPtr[_i],f_aFrameWidth[_i] * f_aFrameHeight[_i]);
				FastMove(_ptr^,D_27D8^,f_aFrameWidth[_i] * f_aFrameHeight[_i]);
				FREEMEM(_ptr,f_aFrameWidth[_i] * f_aFrameHeight[_i]);
				EMSStart_00;
			END;
		END;
		f_pScriptCur := f_pScriptTop;
		f_fa := 0;
		f_scale := $ff;
		f_aFrameWidth[0] := 1;
		f_aFrameHeight[0] := 1;
	END;
END;

PROCEDURE C_1918_1369(_p06:STRING);
VAR
	_i:BYTE;
	_dummy:ARRAY[1..$81] OF BYTE;
	bpfe7a:^BYTE;
	bpfe76:POINTER;
BEGIN
	EMSStart_00;
	D_27E0 := PTR(EMSSegment,0);
	BLOCKREAD(RES_handle,D_27E0^,HeadR.f_04);
	D_2947 := BufferFetchByte(D_27E0);
	FOR _i := 1 TO D_2947
	DO BEGIN
		NEW(D_28E2[_i]);
		ScriptFetchArray(D_28E2[_i]^,9);
	END;
	FOR _i := 1 TO D_2947
	DO WITH D_28E2[_i]^
	DO BEGIN
		GETMEM(bpfe76,f_width * f_height);
		ScriptFetchArray(bpfe76^,f_width * f_height);
		_EMSAlloc(f_emsPtr,(f_width SHL 1) * f_height);
		FastMove(bpfe76^,D_27D8^,f_width * f_height);
		FREEMEM(bpfe76,f_width * f_height);

		bpfe7a := D_27D8;
		INC(bpfe7a,f_width * f_height);
		D_27D8 := bpfe7a;

		C_1918_1825(
			f_x,f_y,320,
			0,0,f_width,
			f_width,f_height,
			PTR($a000,0)^,D_27D8^
		);
		EMSStart_00;
	END;
END;

PROCEDURE C_1918_15AD;
VAR _i:BYTE;
BEGIN
	FOR _i := D_2947 DOWNTO 1
	DO DISPOSE(D_28E2[_i]);
END;

PROCEDURE C_1918_15EB;
VAR _i:BYTE;
BEGIN
	FOR _i := D_2946 DOWNTO 4
	DO BEGIN
		IF _i <> 3
		THEN WITH Actors[_i]^
		DO FREEMEM(f_pScriptTop,f_scriptSize);
		DISPOSE(Actors[_i]);
	END;
END;

FUNCTION C_17E2(bp06,bp04:BYTE):BOOLEAN;
	{-- --}
	FUNCTION INNER_165B(bbp08,bbp06:BYTE):BOOLEAN;
	VAR
		bbp_04:INTEGER;
		bbp_06:INTEGER;
		bbp_08:INTEGER;
		bbp_0a:INTEGER;
		bbp_0c:INTEGER;
		bbp_0e:INTEGER;
		bbp_10:INTEGER;
		bbp_12:INTEGER;
	BEGIN
		WITH Actors[bp06]^
		DO BEGIN
			bbp_04 := f_aX[bbp08] - (f_aWidth[bbp08] SHR 1);
			bbp_06 := f_aY[bbp08] - f_aHeight[bbp08];
			bbp_08 := bbp_04 + f_aWidth[bbp08];
			bbp_0a := f_aY[bbp08];
		END;
		WITH Actors[bp04]^
		DO BEGIN
			bbp_0c := f_aX[bbp06] - (f_aWidth[bbp06] SHR 1);
			bbp_0e := f_aY[bbp06] - f_aHeight[bbp06];
			bbp_10 := bbp_0c + f_aWidth[bbp06];
			bbp_12 := f_aY[bbp06];
		END;
		IF
			(
				((bbp_08 >= bbp_0c) AND (bbp_04 <= bbp_10)) OR
				((bbp_08 <= bbp_0c) AND (bbp_04 >= bbp_10))
			) AND (
				((bbp_0e <= bbp_0a) AND (bbp_12 >= bbp_06)) OR
				((bbp_0e <= bbp_0a) AND (bbp_12 >= bbp_06))
			)
		THEN INNER_165B := TRUE
		ELSE INNER_165B := FALSE;
	END;
	{-- --}
BEGIN
	IF INNER_165B(1,1) OR INNER_165B(1,0) OR INNER_165B(0,1)
	THEN C_17E2 := TRUE
	ELSE C_17E2 := FALSE;
END;

PROCEDURE C_1918_1825(
	_srcX,_srcY,_srcStride,
	_dstX,_dstY,_dstStride,
	_width:INTEGER; _height:BYTE;
	VAR _src,_dst
);
LABEL C_1864;
BEGIN
	ASM
		PUSH	DS
		LES	DI,_dst
		LDS	SI,_src
		XOR	DX,DX
		XOR	CX,CX
		CLD	
		MOV	AX,_dstY
		MOV	BX,_dstStride
		MUL	BX
		ADD	AX,_dstX
		ADD	DI,AX
		MOV	AX,_srcY
		MOV	BX,_srcStride
		MUL	BX
		ADD	AX,_srcX
		ADD	SI,AX
		MOV	BX,_dstStride
		SUB	BX,_width
		MOV	AX,_srcStride
		SUB	AX,_width
		MOV	DH,_height
C_1864:
		INC	DL
		MOV	CX,_width
		REPZ	MOVSB	
		ADD	DI,BX
		ADD	SI,AX
		CMP	DL,DH
		JNZ	C_1864
		POP	DS
	END;
END;

PROCEDURE C_1918_1878(
	_srcX,_srcY,_srcStride,
	_dstX,_dstY,_dstStride,
	_width:INTEGER; _height:BYTE;
	VAR _src,_dst; bp08,_color:BYTE
);
LABEL C_18BE,C_18C3,C_18CC;
VAR bp_02:WORD;
BEGIN
	bp_02 := _srcStride - _width;
	ASM
		PUSH	DS
		LES	DI,_dst
		LDS	SI,_src
		XOR	DX,DX
		XOR	CX,CX
		CLD	
		MOV	AX,_dstY
		MOV	BX,_dstStride
		MUL	BX
		ADD	AX,_dstX
		ADD	DI,AX
		MOV	AX,_srcY
		MOV	BX,_srcStride
		MUL	BX
		ADD	AX,_srcX
		ADD	SI,AX
		MOV	BX,_dstStride
		SUB	BX,_width
		MOV	DH,_height
C_18BE:
		INC	DL
		MOV	CX,_width
C_18C3:
		LODSB	
		CMP	AL,bp08
		JNZ	C_18CC
		MOV	AL,_color
C_18CC:
		STOSB	
		LOOP	C_18C3
		ADD	DI,BX
		ADD	SI,bp_02
		CMP	DL,DH
		JNZ	C_18BE
		POP	DS
	END;
END;

PROCEDURE C_1918_18DD(bp06:BYTE);
BEGIN
	WITH Actors[bp06]^
	DO BEGIN
		f_fb := TRUE;
		f_fc := FALSE;
		D_2804 := f_mirrorX;
	END;
END;

PROCEDURE C_1918_1920(VAR _src,_dst; bp16,bp14,bp12,bp10,bp0e,bp0c,bp0a:WORD; bp08:INTEGER; bp06:BYTE);
LABEL C_19A5,C_19A9,C_19D3,C_19D4;
VAR
	bp_02,bp_04,bp_06,bp_08:WORD;
	bp_0a:WORD;
BEGIN
	bp_06 := (bp16 * bp06) SHR 7;
	bp_08 := (bp14 * bp06) SHR 7;
	bp_02 := (bp0a - bp_06) + 1;
	bp_04 := bp08 - bp16;
	IF (bp_06 > 0) AND (bp_08 > 0)
	THEN ASM
		PUSH	DS
		LES	DI,_dst
		LDS	SI,_src
		XOR	DX,DX
		XOR	CX,CX
		CLD	
		MOV	AX,bp10
		MOV	BX,bp0a
		MUL	BX
		ADD	AX,bp12
		ADD	DI,AX
		XOR	DX,DX
		MOV	AX,bp0c
		MOV	BX,bp08
		MUL	BX
		ADD	AX,bp0e
		ADD	SI,AX
		ADD	SI,bp16
		DEC	SI
		MOV	bp_0a,SI
		XOR	BX,BX
C_19A5:
		MOV	CX,bp_06
		DEC	CX
C_19A9:
		XOR	DX,DX
		MOV	AX,BX
		MUL	Word Ptr bp14
		XOR	DX,DX
		DIV	Word Ptr bp_08
		MUL	Word Ptr bp08
		MOV	SI,AX
		XOR	DX,DX
		MOV	AX,CX
		MUL	Word Ptr bp16
		XOR	DX,DX
		DIV	Word Ptr bp_06
		SUB	SI,AX
		ADD	SI,bp_0a
		LODSB	
		CMP	AL,1
		JZ	C_19D3
		STOSB	
		JMP	C_19D4
C_19D3:
		INC	DI
C_19D4:
		LOOP	C_19A9
		ADD	DI,bp_02
		INC	BX
		CMP	BX,bp_08
		JNZ	C_19A5
		POP	DS
	END;
END;

PROCEDURE C_19E4(VAR _src,_dst; bp14,bp12,bp10,bp0e,_p0c,bp0a,bp08:WORD; bp06:INTEGER; bp04:BYTE);
LABEL C_1A77,C_1A7B,C_1AA3,C_1AA4;
VAR
	bp_02,bp_04,bp_06,bp_08:WORD;
	bp_0a:WORD;
BEGIN
	IF bp04 <> $ff
	THEN BEGIN
		bp_06 := (bp14 * bp04) SHR 7;
		bp_08 := (bp12 * bp04) SHR 7;
	END ELSE BEGIN
		bp_06 := bp14 - 1;
		bp_08 := bp12;
	END;
	bp_02 := (bp08 - bp_06) + 1;
	bp_04 := bp06 - bp14;
	IF (bp_06 > 0) AND (bp_08 > 0)
	THEN ASM
		PUSH	DS
		LES	DI,_dst
		LDS	SI,_src
		XOR	DX,DX
		XOR	CX,CX
		CLD	
		MOV	AX,bp0e
		MOV	BX,bp08
		MUL	BX
		ADD	AX,bp10
		ADD	DI,AX
		XOR	DX,DX
		MOV	AX,bp0a
		MOV	BX,bp06
		MUL	BX
		ADD	SI,AX
		MOV	bp_0a,SI
		XOR	BX,BX
C_1A77:
		MOV	CX,bp_06
		DEC	CX
C_1A7B:
		XOR	DX,DX
		MOV	AX,BX
		MUL	Word Ptr bp12
		DIV	Word Ptr bp_08
		MUL	Word Ptr bp06
		MOV	SI,AX
		XOR	DX,DX
		MOV	AX,CX
		MUL	Word Ptr bp14
		XOR	DX,DX
		DIV	Word Ptr bp_06
		ADD	SI,AX
		ADD	SI,bp_0a
		LODSB	
		CMP	AL,1
		JZ	C_1AA3
		STOSB	
		JMP	C_1AA4
C_1AA3:
		INC	DI
C_1AA4:
		LOOP	C_1A7B
		ADD	DI,bp_02
		INC	BX
		CMP	BX,bp_08
		JNZ	C_1A77
		POP	DS
	END;
END;

{h-mirror of C_1918_0E19}
PROCEDURE C_1918_1AB4(VAR _src,_dst; bp16,bp14,bp12,bp10,bp0e,bp0c:WORD; bp0a,bp08:INTEGER; bp06:BYTE);
LABEL C_1B3D,C_1B50,C_1B5E,C_1B63,C_1B64,C_1B6C;
VAR bp_02,bp_04:WORD;
BEGIN
	bp_02 := (bp0a - bp16) + (bp16 DIV bp06);
	bp_04 := (bp16 SHL 1 + bp08) - bp16;
	ASM
		PUSH	DS
		LES	DI,_dst
		LDS	SI,_src
		XOR	DX,DX
		XOR	CX,CX
		CLD	
		MOV	AX,bp10
		MOV	BX,bp0a
		MUL	BX
		ADD	AX,bp12
		ADD	DI,AX
		MOV	AX,bp0c
		MOV	BX,bp08
		MUL	BX
		ADD	AX,bp08
		SUB	AX,bp0e
		ADD	SI,AX
		MOV	BH,bp06
C_1B3D:
		INC	DL
		MOV	BL,bp06
		MOV	CX,bp16
		DEC	BH
		JNZ	C_1B50
		MOV	BH,bp06
		ADD	SI,CX
		JMP	C_1B6C
C_1B50:
		DEC	SI
		MOV	AL,[SI]
		DEC	BL
		JZ	C_1B5E
		CMP	AL,1
		JZ	C_1B63
		STOSB	
		JMP	C_1B64
C_1B5E:
		MOV	BL,bp06
		JMP	C_1B64
C_1B63:
		INC	DI
C_1B64:
		LOOP	C_1B50
		ADD	DI,bp_02
		ADD	SI,bp_04
C_1B6C:
		CMP	DL,BYTE(bp14)
		JNZ	C_1B3D
		POP	DS
	END;
END;

PROCEDURE C_1918_1BB1(bp06:BYTE);
VAR
	_dst:POINTER;
	_clipCount:BYTE;
	bp_06:BYTE;
	_buffer:POINTER;
	_bufSz:WORD;
	_clipRight,_clipBottom,_clipLeft,_clipTop:INTEGER;
	_halfWidth0,_halfWidth1:BYTE;
	_scale:BYTE;
	_someX,_someY:INTEGER;
	_someWidth,_someHeight:WORD;
	_x0,_x1,_y0,_y1,_width0,_width1,_height0,_height1:INTEGER;
	_curWidth:WORD;
	bp_33:BOOLEAN;
	_clpX,_clpWidth,_clpY,_clpHeight:BYTE;
	{-- --}
	{INNER_1B76}FUNCTION INNER_Clamp(_min,_max,_val:INTEGER):INTEGER;
	BEGIN
		IF _min > _val
		THEN INNER_Clamp := _min
		ELSE IF _max <= _val
		THEN INNER_Clamp := _max
		ELSE INNER_Clamp := _val;
	END;
	{-- --}
BEGIN
	FOR GlobalI := 1 TO $14
	DO D_2932[GlobalI] := 0;
	_clipRight := 319; _clipLeft := 0;
	_clipBottom := 199; _clipTop := 0;
	_clipCount := 0;
	{-- --}
	FOR GlobalI := 1 TO D_2946
	DO BEGIN
		IF Actors[GlobalI]^.f_fa = bp06
		THEN BEGIN{else 1D86}
			WITH Actors[GlobalI]^
			DO BEGIN
				_x0 := f_aX[0];
				_x1 := f_aX[1];
				_y1 := f_aY[1];
				_y0 := f_aY[0];
				_width0 := f_aWidth[0];
				_width1 := f_aWidth[1];
				_height1 := f_aHeight[1];
				_height0 := f_aHeight[0];
				_halfWidth0 := _width0 SHR 1;
				_halfWidth1 := _width1 SHR 1;
			END;
			IF _clipRight > (_x1 - _halfWidth1)
			THEN _clipRight := _x1 - _halfWidth1;
			IF _clipRight > (_x0 - _halfWidth0)
			THEN _clipRight := _x0 - _halfWidth0;
			IF _clipLeft < (_x1 - _halfWidth1 + _width1)
			THEN _clipLeft := _x1 - _halfWidth1 + _width1;
			IF _clipLeft < (_x0 - _halfWidth0 + _width0)
			THEN _clipLeft := _x0 - _halfWidth0 + _width0;
			IF _clipBottom > (_y1 - _height1)
			THEN _clipBottom := _y1 - _height1;
			IF _clipBottom > (_y0 - _height0)
			THEN _clipBottom := _y0 - _height0;
			IF _y1 > _clipTop
			THEN _clipTop := _y1;
			IF _y0 > _clipTop
			THEN _clipTop := _y0;
			INC(_clipCount);
			D_2932[_clipCount] := GlobalI;
		END;
	END;
	{-- --}
	IF D_2A10[bp06] > 0
	THEN FOR GlobalI := 1 TO D_2A10[bp06]
	DO BEGIN
		INC(_clipCount);
		D_2932[_clipCount] := D_2948[bp06][GlobalI];
	END;
	{-- swap? --}
	FOR GlobalI := 1 TO _clipCount
	DO FOR GlobalJ := GlobalI TO _clipCount
	DO BEGIN
		IF
			(Actors[D_2932[GlobalJ]]^.f_aY[1] + Actors[D_2932[GlobalJ]]^.f_f9) <
			(Actors[D_2932[GlobalI]]^.f_aY[1] + Actors[D_2932[GlobalI]]^.f_f9)
		THEN BEGIN
			bp_06 := D_2932[GlobalI];
			D_2932[GlobalI] := D_2932[GlobalJ];
			D_2932[GlobalJ] := bp_06;
		END;
	END;
	{-- --}
	_bufSz := (_clipLeft - _clipRight + 1) * (_clipTop - _clipBottom + 1);
	GETMEM(_buffer,_bufSz);
	FILLCHAR(_buffer^,_bufSz,1);
	EMSStart_0A;
	D_27D8 := PTR(EMSSegment,0);
	{-- --}
	FOR GlobalI := 1 TO _clipCount
	DO WITH Actors[D_2932[GlobalI]]^
	DO IF f_fb
	THEN BEGIN{else 2083}
		_halfWidth0 := f_aWidth[0] SHR 1;
		_x0 := f_aX[0] - _halfWidth0;
		_y0 := f_aY[0] - f_aHeight[0];
		IF _x0 < 0
		THEN _clpX := -_x0
		ELSE _clpX := 0;
		IF (f_aWidth[0] + _x0) > 319
		THEN _clpWidth := f_aWidth[0] + _x0 - 320
		ELSE _clpWidth := 0;
		IF _y0 < 0
		THEN _clpY := -_y0
		ELSE _clpY := 0;
		IF f_aY[0] > 199
		THEN _clpHeight := f_aY[0] - 200
		ELSE _clpHeight := 0;
		C_1918_1825(
			_clpX + _x0,_clpY + _y0,320,
			(_x0 - _clipRight) + _clpX,(_y0 - _clipBottom) + _clpY,_clipLeft - _clipRight + 1,
			f_aWidth[0] - _clpX - _clpWidth,f_aHeight[0] - _clpY - _clpHeight,
			D_27D8^,_buffer^
		);
	END;
	{-- --}
	FOR GlobalI := 1 TO _clipCount
	DO BEGIN
		WITH Actors[D_2932[GlobalI]]^
		DO BEGIN
			_x0 := f_aX[0]; _x1 := f_aX[1];
			_y0 := f_aY[0]; _y1 := f_aY[1];
			_width0 := f_aWidth[0]; _width1 := f_aWidth[1];
			_height0 := f_aHeight[0]; _height1 := f_aHeight[1];
			_curWidth := f_aFrameWidth[f_curFrame];
			bp_33 := f_fb;
			_scale := f_scale;
			f_fc := FALSE;
		END;
		IF Actors[D_2932[GlobalI]]^.f_curFrame > 0
		THEN BEGIN{else 2404}
			_halfWidth0 := _width0 SHR 1;
			_halfWidth1 := _width1 SHR 1;
			{-- --}
			IF NOT bp_33
			THEN BEGIN{else 21EE}
				_someX := INNER_Clamp(_clipRight,_clipLeft,_x1 - _halfWidth1);
				_someY := INNER_Clamp(_clipBottom,_clipTop,_y1 - _height1);
				_someWidth := INNER_Clamp(_clipRight,_clipLeft,_x1 - _halfWidth1 + _width1) - _someX;
				_someHeight := INNER_Clamp(_clipBottom,_clipTop,_y1) - _someY;
			END ELSE BEGIN
				_someX := _x1 - _halfWidth1;
				_someY := _y1 - _height1;
				_someWidth := _curWidth;
				_someHeight := Actors[D_2932[GlobalI]]^.f_aFrameHeight[Actors[D_2932[GlobalI]]^.f_curFrame];
			END;
			bp_33 := FALSE;{NOTE:useless?}
			{-- --}
			WITH Actors[D_2932[GlobalI]]^
			DO BEGIN
				f_fb := FALSE;
				EMS2Pointer(f_emsPtr[f_curFrame],D_27D8);
			END;
			IF (_someWidth > 0) AND (_someHeight > 0)
			THEN BEGIN{else 2402}
				IF Actors[D_2932[GlobalI]]^.f_mirrorX
				THEN BEGIN{else 2365}
					IF _scale = $ff
					THEN C_1918_1AB4(
						D_27D8^,_buffer^,
						_someWidth,_someHeight,
						_someX - _clipRight,_someY - _clipBottom,
						(_someX - _x1) + _halfWidth1,(_someY - _y1) + _height1,
						_clipLeft - _clipRight + 1,_curWidth,_scale
					) ELSE C_19E4(
						D_27D8^,_buffer^,
						_someWidth,_someHeight,
						_someX - _clipRight,_someY - _clipBottom,
						(_someX - _x1) + _halfWidth1,(_someY - _y1) + _height1,
						_clipLeft - _clipRight + 1,_curWidth,_scale
					);
					{goto 2402}
				END ELSE BEGIN
					IF _scale = $ff
					THEN C_1918_0E60(
						D_27D8^,_buffer^,
						_someWidth,_someHeight,
						_someX - _clipRight,_someY - _clipBottom,
						(_someX - _x1) + _halfWidth1,(_someY - _y1) + _height1,
						_clipLeft - _clipRight + 1,_curWidth
					) ELSE C_1918_1920(
						D_27D8^,_buffer^,
						_someWidth,_someHeight,
						_someX - _clipRight,_someY - _clipBottom,
						(_someX - _x1) + _halfWidth1,(_someY - _y1) + _height1,
						_clipLeft - _clipRight + 1,_curWidth,_scale
					);
				END;
				{goto 241D}
			END;
		END ELSE BEGIN
			Actors[D_2932[GlobalI]]^.f_fb := FALSE;
		END;
		WITH Actors[D_2932[GlobalI]]^
		DO BEGIN
			f_aX[0] := _x1;
			f_aY[0] := _y1;
			f_aWidth[0] := _width1;
			f_aHeight[0] := _height1;
			f_prevFrame := f_curFrame;
		END;
	END;
	{-- display buffer --}
	IF _clipRight < 0
	THEN _clpX := -_clipRight
	ELSE _clpX := 0;
	IF _clipLeft > 319
	THEN _clpWidth := _clipLeft - 319
	ELSE _clpWidth := 0;
	IF _clipBottom < 0
	THEN _clpY := -_clipBottom
	ELSE _clpY := 0;
	IF _clipTop > 199
	THEN _clpHeight := _clipTop - 199
	ELSE _clpHeight := 0;
	ShowMouse(FALSE);
	IF D_27C2
	THEN BEGIN
		_dst := PTR(EMSSegment,0);
		EMSStart_13;
	END ELSE BEGIN
		_dst := PTR($a000,0);
	END;
	C_1918_0E60(
		_buffer^,_dst^,
		_clipLeft - _clpWidth - (_clpX + _clipRight) + 1,
		_clipTop - _clpHeight - (_clpY + _clipBottom) + 1,
		_clpX + _clipRight,
		_clpY + _clipBottom,
		_clpX,_clpY,
		320,_clipLeft - _clipRight + 1
	);
	ShowMouse(TRUE);
	{-- --}
	FREEMEM(_buffer,_bufSz);
END;

PROCEDURE C_1918_2A16;
VAR
	bp_01:BOOLEAN;
	bp_02:BYTE;
	bp_03:BYTE;
	_dummy:STRING;
	{-- --}
	FUNCTION INNER_257B(bbp08,bbp06:BYTE):BOOLEAN;
	VAR bbp_02:BYTE;
	BEGIN
		INNER_257B := FALSE;
		FOR bbp_02 := 1 TO D_2A10[bbp08]
		DO IF D_2948[bbp08][bbp_02] = bbp06
		THEN INNER_257B := TRUE;
	END;
	{-- --}
	PROCEDURE INNER_25D7(bbp08,bbp06:BYTE);
	BEGIN
		IF NOT INNER_257B(bbp08,bbp06)
		THEN BEGIN
			INC(D_2A10[bbp08]);
			Actors[bbp06]^.f_fc := TRUE;
			D_2948[bbp08][D_2A10[bbp08]] := bbp06;
		END;
	END;
	{-- --}
	PROCEDURE INNER_2636(bbp08,bbp06:BYTE);
	BEGIN
		FOR D_27D2 := 1 TO D_2A10[bbp08]
		DO BEGIN
			IF NOT INNER_257B(bbp06,D_2948[bbp08][D_27D2])
			THEN BEGIN
				INC(D_2A10[bbp06]);
				D_2948[bbp06][D_2A10[bbp06]] := D_2948[bbp08][D_27D2];
			END;
			D_2948[bbp08][D_27D2] := 0;
		END;
		D_2A10[bbp08] := 0;
	END;
	{-- --}
	PROCEDURE INNER_26EE(bbp08,bbp06:BYTE);
	BEGIN
		INNER_2636(bbp08,bbp06);
		FOR D_27D2 := 1 TO D_2946
		DO BEGIN
			IF Actors[D_27D2]^.f_fa = bbp08
			THEN Actors[D_27D2]^.f_fa := bbp06;
		END;
		FOR D_27D2 := 1 TO D_2946
		DO BEGIN
			IF Actors[D_27D2]^.f_fa > bbp08
			THEN DEC(Actors[D_27D2]^.f_fa);
		END;
		DEC(D_27D6);
	END;
	{-- --}
	PROCEDURE INNER_27A1;
	VAR
		_bp_02:INTEGER;
		bbp_03,bbp_04:BYTE;
		bbp_05,bbp_06:BOOLEAN;
	BEGIN
		{-- --}
		bbp_03 := Actors[GlobalI]^.f_fa;
		bbp_04 := Actors[GlobalJ]^.f_fa;
		bbp_05 := Actors[GlobalI]^.f_fb;
		bbp_06 := Actors[GlobalJ]^.f_fb;
		{-- --}
		IF (bbp_03 <> 0) AND (bbp_04 <> 0)
		THEN BEGIN{else 288A}
			IF bbp_03 <> bbp_04
			THEN BEGIN{else 2887}
				IF bbp_03 > bbp_04
				THEN BEGIN{else 2853}
					INNER_26EE(bbp_03,bbp_04);
					bbp_03 := Actors[GlobalI]^.f_fa;
					bbp_04 := Actors[GlobalJ]^.f_fa;
					{goto 2887}
				END ELSE BEGIN
					INNER_26EE(bbp_04,bbp_03);
					bbp_03 := Actors[GlobalI]^.f_fa;
					bbp_04 := Actors[GlobalJ]^.f_fa;
				END;
			END;
			{goto 291C}
		END ELSE IF bbp_03 <> 0
		THEN BEGIN{else 28E5}
			IF bbp_06 OR (Actors[GlobalJ]^.f_scale <> $ff)
			THEN BEGIN{else 28D5}
				bbp_04 := bbp_03;
				IF NOT bbp_06
				THEN BEGIN{else 28D3}
					bbp_06 := TRUE;
					IF GlobalJ <= GlobalI
					THEN D_27D4 := GlobalJ - 1
					ELSE bp_02 := 0;
				END;
				{goto 28E3}
			END ELSE BEGIN
				INNER_25D7(bbp_03,GlobalJ);
			END;
			{goto 291C}
		END ELSE IF bbp_04 <> 0
		THEN BEGIN{else 291C}
			IF bbp_05 OR (Actors[GlobalI]^.f_scale <> $ff)
			THEN BEGIN{else 291C}
				bbp_03 := bbp_04;
				IF NOT bbp_05
				THEN BEGIN
					bbp_06 := TRUE;
					bp_02 := 0;
				END;
			END;
		END;
		IF (bbp_03 = 0) AND (bbp_04 = 0)
		THEN BEGIN{else 29C6}
			INC(D_27D6);
			IF bbp_05 OR (Actors[GlobalI]^.f_scale <> $ff)
			THEN BEGIN{else 2965}
				bbp_03 := D_27D6;
				IF NOT bbp_05
				THEN BEGIN
					bbp_05 := TRUE;
					bp_02 := 0;
				END;
				{goto 2973}
			END ELSE BEGIN
				INNER_25D7(D_27D6,GlobalI);
			END;
			IF bbp_06 OR (Actors[GlobalJ]^.f_scale <> $ff)
			THEN BEGIN{else 29B8}
				bbp_04 := D_27D6;
				IF NOT bbp_06
				THEN BEGIN{else 29B6}
					bbp_06 := TRUE;
					IF GlobalJ <= GlobalI
					THEN D_27D4 := GlobalJ - 1
					ELSE bp_02 := 0;
				END;
			END ELSE BEGIN
				INNER_25D7(D_27D6,GlobalJ);
			END;
		END;
		{-- --}
		Actors[GlobalI]^.f_fa := bbp_03;
		Actors[GlobalJ]^.f_fa := bbp_04;
		Actors[GlobalI]^.f_fb := bbp_05;
		Actors[GlobalJ]^.f_fb := bbp_06;
		{-- --}
	END;
	{-- --}
BEGIN
	FOR GlobalI := 1 TO $14
	DO D_2A10[GlobalI] := 0;
	D_2A10[GlobalI] := 0;
	FOR GlobalI := 1 TO D_2946
	DO Actors[GlobalI]^.f_fa := 0;
	D_27D6 := 0;
	GlobalI := 0;
	REPEAT
		INC(GlobalI);
		D_27D4 := GlobalI;
		bp_01 := TRUE;
		bp_02 := 0;
		REPEAT
			{-- --}
			GlobalJ := bp_02;
			INC(GlobalJ);
			bp_02 := GlobalJ;
			{-- --}
			IF GlobalJ <> GlobalI
			THEN BEGIN{else 2B66}
				IF Actors[GlobalI]^.f_fb OR Actors[GlobalJ]^.f_fb
				THEN BEGIN{else 2AF8}
					IF C_17E2(GlobalI,GlobalJ)
					THEN BEGIN
						INNER_27A1;
						bp_01 := FALSE;
					END;
					{goto 2B66}
				END ELSE IF Actors[GlobalI]^.f_fc
				THEN BEGIN
					IF C_17E2(GlobalI,GlobalJ)
					THEN BEGIN{else 2B66}
						FOR bp_03 := 1 TO D_27D6
						DO BEGIN
							IF (INNER_257B(bp_03,GlobalI) = TRUE) AND (INNER_257B(bp_03,GlobalJ) = FALSE)
							THEN INNER_25D7(bp_03,GlobalJ);
						END;
					END;
				END;
			END;
		UNTIL D_2946 = GlobalJ;
		IF bp_01 AND (Actors[GlobalI]^.f_fa = 0) AND Actors[GlobalI]^.f_fb
		THEN BEGIN
			INC(D_27D6);
			Actors[GlobalI]^.f_fa := D_27D6;
		END;
		GlobalI := D_27D4;
	UNTIL D_2946 = GlobalI;
	{-- --}
	IF (Actors[D_2946]^.f_fa = 0) AND Actors[D_2946]^.f_fb
	THEN BEGIN
		INC(D_27D6);
		Actors[D_2946]^.f_fa := D_27D6;
	END;
END;

{C_1918_2D69}PROCEDURE PutString_1(_str:STRING; _x,_y:INTEGER; _color:BYTE);
VAR
	_aStr:ARRAY[1..5] OF STRING[$1e];
	_ch:CHAR;
	bpfe62:BYTE;
	bpfe61:BYTE;
	{-- --}
	{INNER_2C14}PROCEDURE INNER_PutOneLine;
	VAR
		_i:BYTE;
		_srcX:BYTE;
		_dummy:BYTE;
	BEGIN
		_x := (GlobalJ - LENGTH(_aStr[GlobalI]) * 7) SHR 1;
		FOR _i := 1 TO LENGTH(_aStr[GlobalI])
		DO BEGIN
			_ch := _aStr[GlobalI][_i];
			if _ch <> ' '
			THEN BEGIN{else 2D5A}
				D_27D4 := 0;
				_srcX := POS(_ch,D_0214[0]);
				IF _srcX = 0
				THEN BEGIN{else 2CEC}
					_srcX := POS(_ch,D_0214[1]);
					D_27D4 := 10;
				END;
{$IFDEF FRENCH}
				IF _srcX = 0
				THEN BEGIN
					_srcX := POS(_ch,D_0214_bis);
					D_27D4 := 20;
				END;
{$ENDIF}
				DEC(_srcX);
				EMS2Pointer(Actors[2]^.f_emsPtr[1],D_27D8);
				C_1918_1878(
					_srcX * 7,D_27D4,Actors[2]^.f_aFrameWidth[1],
					_x + (_i - 1) * 7,(GlobalI - 1) * 10,GlobalJ,
					7,10,
					D_27D8^,Actors[2]^.f_pData^,
					2,_color
				);
			END;
		END;
	END;
	{-- --}
BEGIN
	GlobalJ := 0;
	D_27D2 := 1;
	FOR GlobalI := 1 TO 5
	DO _aStr[GlobalI][0] := #0;
	GlobalI := 0;
	bpfe61 := 0;
	bpfe62 := 30;
	REPEAT
		INC(GlobalI);
		INC(bpfe61);
		IF (_str[GlobalI] = ' ') OR (LENGTH(_str) = GlobalI)
		THEN BEGIN{else 2EA3}
			IF (GlobalJ + bpfe61) > bpfe62
			THEN BEGIN{else 2E40}
				IF _aStr[D_27D2][LENGTH(_aStr[D_27D2])] = ' '
				THEN DELETE(_aStr[D_27D2],LENGTH(_aStr[D_27D2]),1);
				INC(D_27D2);
				GlobalJ := bpfe61;
				{goto 2E4A}
			END ELSE BEGIN
				INC(GlobalJ,bpfe61);
			END;
			_aStr[D_27D2] := _aStr[D_27D2] + COPY(_str,GlobalI - bpfe61 + 1,bpfe61);
			bpfe61 := 0;
		END;
	UNTIL GlobalI = LENGTH(_str);
	IF _y < D_27D2 * 10
	THEN _y := D_27D2 * 10;
	GlobalJ := 0;
	FOR GlobalI := 1 TO D_27D2
	DO BEGIN
		IF GlobalJ < LENGTH(_aStr[GlobalI])
		THEN GlobalJ := LENGTH(_aStr[GlobalI]);
	END;
	GlobalJ := GlobalJ * 7;
	GlobalI := GlobalJ SHR 1;
	IF _x < GlobalI
	THEN _x := GlobalI;
	IF _x > (319 - GlobalI)
	THEN _x := 319 - GlobalI;
	C_1918_18DD(2);
	WITH Actors[2]^
	DO BEGIN
		f_emsPtr[2].f_pageCount := 0;
		GETMEM(f_pData,GlobalJ * D_27D2 * 10);
		FILLCHAR(f_pData^,GlobalJ * D_27D2 * 10,1);
		f_aX[1] := _x; f_aY[1] := _y;
		f_aFrameWidth[2] := GlobalJ; f_aFrameHeight[2] := D_27D2 * 10;
		f_aWidth[1] := f_aFrameWidth[2]; f_aHeight[1] := f_aFrameHeight[2];
		f_curFrame := 2;
		f_scale := $ff;
		f_f9 := $ff;

		FOR GlobalI := 1 TO D_27D2
		DO INNER_PutOneLine;
	END;
END;

{C_1918_302E}PROCEDURE PutString_2(_str:STRING; _x,_y:INTEGER);
VAR
	_ch:CHAR;
	_srcY:INTEGER;
	_i:BYTE;
	_srcX:BYTE;
	_buf:POINTER;
	_bufSz:INTEGER;
BEGIN
	EMS2Pointer(Actors[2]^.f_emsPtr[1],D_27D8);
	_bufSz := LENGTH(_str) * 7 * 10;
	GETMEM(_buf,_bufSz);
	FILLCHAR(_buf^,_bufSz,1);
	FOR _i := 1 TO LENGTH(_str)
	DO BEGIN
		_ch := _str[_i];
		IF _ch <> ' '
		THEN BEGIN{else 31A4}
			_srcY := 0;
			_srcX := POS(_ch,D_0214[0]);
			IF _srcX = 0
			THEN BEGIN
				_srcX := POS(_ch,D_0214[1]);
				_srcY := 10;
			END;
{$IFDEF FRENCH}
			IF _srcX = 0
			THEN BEGIN
				_srcX := POS(_ch,D_0214_bis);
				_srcY := 20;
			END;
{$ENDIF}
			DEC(_srcX);
			C_1918_1878(
				_srcX * 7,_srcY,Actors[2]^.f_aFrameWidth[1],
				(_i - 1) * 7,0,LENGTH(_str) * 7,
				7,10,
				D_27D8^,_buf^,
				2,$ff
			);
			C_1918_1878(
				0,0,LENGTH(_str) * 7,
				0,0,LENGTH(_str) * 7,
				LENGTH(_str) * 7,10,
				_buf^,_buf^,
				0,1
			);
		END;
	END;
	ShowMouse(FALSE);
	C_1918_0E60(
		_buf^,PTR($a000,0)^,
		LENGTH(_str) * 7,10,
		_x,_y,
		0,0,
		320,LENGTH(_str) * 7
	);
	ShowMouse(TRUE);
	FREEMEM(_buf,_bufSz);
END;

{C_1918_3207}PROCEDURE RefreshState(_stateId:WORD);
VAR
	_i:BYTE;
	_state1,_state2:BOOLEAN;
	_stateId1,_stateId2:WORD;
	bp_0c:POINTER;
	bp_10:POINTER;
	_size:WORD;
	bp_16:^BYTE;
BEGIN
	{}
	FOR _i := 1 TO D_2947
	DO BEGIN
		WITH D_28E2[_i]^
		DO BEGIN
			_stateId1 := f_stateId1;
			_stateId2 := f_stateId2;
		END;
		IF
			(_stateId1 = _stateId) OR (_stateId2 = _stateId) OR
			(($ffff - _stateId1) = _stateId) OR (($ffff - _stateId2) = _stateId)
		THEN BEGIN
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
					CLD	
					MOV	CX,_size
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
			WITH Actors[3]^
			DO BEGIN
				f_aX[0] := D_28E2[_i]^.f_x + D_28E2[_i]^.f_width SHR 1;
				f_aY[0] := D_28E2[_i]^.f_y + D_28E2[_i]^.f_height;
				f_aWidth[0] := D_28E2[_i]^.f_width;
				f_aHeight[0] := D_28E2[_i]^.f_height;
				f_aX[1] := f_aX[0];
				f_aY[1] := f_aY[0];
				f_aWidth[1] := 1;
				f_aHeight[1] := 1;
				f_curFrame := 0;
				f_fb := TRUE;
			END;
		END;
	END;
END;

PROCEDURE C_1918_34BC(_src:POINTER);
BEGIN
	ASM
		PUSH	DS
		MOV	AX,$A000
		MOV	ES,AX
		MOV	DI,$B540
		LDS	SI,_src
		CLD
		MOV	CX,$1130
		REPZ
		DB	$66
		MOVSW
		POP	DS
	END;
END;

BEGIN
	D_27F9 := FALSE;
	D_27F8 := FALSE;
	D_2808 := FALSE;
END.
