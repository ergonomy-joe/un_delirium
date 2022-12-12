(*
Escape From Delirium 
	by Virtual X-Perience 1995
	decompiled by ergonomy_joe in 2019
*)
{$G+}
{$X+}
{ DEFINE FRENCH}
UNIT C_0C8B;

INTERFACE
PROCEDURE C_0C8B_0261;
PROCEDURE C_0C8B_02C0;
PROCEDURE C_0C8B_11A2;

IMPLEMENTATION

USES
	CRT,
	C_0E65,
	C_0E7F,
	C_1031,
	C_149C,
	C_14C8,
	C_16DC,
	C_1765,
	C_183E,
	C_18B8,
	C_18DC,
	C_1918,
	C_1D8E,
	C_1DD9,
	C_1E02,
	BSS;

CONST
	{-- inventory scroll buttons --}
	D_0074:ARRAY[1..2,1..4] OF INTEGER = (
		(146,146,162,197),
		(303,146,319,197)
	);
	D_0084:ARRAY[1..8] OF BYTE = (1,1,2,1,2,1,1,0);
	{-- buttons --}
	D_008C:ARRAY[1..8,1..4] OF WORD = (
		($A5,$A2,$C5,$B3),
		($A5,$B5,$C5,$C4),
		($C7,$A2,$E7,$B3),
		($C7,$B5,$E7,$C4),
		($E9,$A2,$109,$B3),
		($E9,$B5,$109,$C4),
		($10B,$A2,$12B,$B3),
		($10B,$B5,$12B,$C4)
	);

{-- binoculars shapes --}

{$L C_0_19BD}
PROCEDURE C_0C8B_19BD; EXTERNAL;
{$L C_0_1A59}
PROCEDURE C_0C8B_1A59; EXTERNAL;
{$L C_0_1AE0}
PROCEDURE C_0C8B_1AE0; EXTERNAL;
{$L C_0_1B7C}
PROCEDURE C_0C8B_1B7C; EXTERNAL;

{right-click extra functions}
PROCEDURE C_0000(_mouseX,_mouseY:INTEGER);
LABEL C_00CE,C_00D3,C_00DF;
VAR _x,_y:INTEGER;
BEGIN
	EMSStart_00;
	{-- clamp --}
	_x := _mouseX - 35;
	_y := _mouseY - 13;
	IF _x < 0 THEN _x := 0;
	IF _x > 251 THEN _x := 251;
	IF _y < 0 THEN _y := 0;
	IF _y > 118 THEN _y := 118;
	{-- inventory scroll --}
	IF NOT D_0496
	THEN BEGIN
		IF (MouseY > 145) AND (MouseX > 160) AND (MouseX < 232)
		THEN BEGIN
			InventoryLeft;
			EXIT;
		END;
		IF (MouseY > 145) AND (MouseX < 320) AND (MouseX > 231)
		THEN BEGIN
			InventoryRight;
			EXIT;
		END;
		D_0496 := TRUE;
	END;
	{-- --}
	PrevMouseX := MouseX;
	PrevMouseY := MouseY;
	{-- --}
	ShowMouse(FALSE);
	{-- zoom --}
	ASM
		PUSH	DS
		MOV	ES,EMSSegment
		MOV	AX,$A000
		MOV	DS,AX
		MOV	AX,_y
		MOV	BX,320
		MUL	BX
		ADD	AX,_x
		MOV	SI,AX
		XOR	DI,DI
		MOV	BX,$1B
		CLD	
C_00CE:
		MOV	DX,DI
		MOV	CX,$44
C_00D3:
		LODSB	
		MOV	AH,AL
		STOSW	
		LOOP	C_00D3
		SUB	SI,$44
		MOV	CX,$44
C_00DF:
		LODSB	
		MOV	AH,AL
		STOSW	
		LOOP	C_00DF
		ADD	SI,$FC
		DEC	BX
		JNZ	C_00CE
		POP	DS
	END;
	{-- binoculars shape --}
	D_27D8 := PTR(EMSSegment,0);
	C_1918_0E19(@C_0C8B_19BD^,D_27D8^,13,12,0,0,136);{top left}
	C_1918_0E19(@C_0C8B_1AE0^,D_27D8^,13,12,0,41,136);{bottom left}
	C_1918_0E19(@C_0C8B_1A59^,D_27D8^,15,9,58,0,136);{top middle}
	C_1918_0E19(@C_0C8B_1B7C^,D_27D8^,15,9,58,44,136);{bottom middle}
	C_1918_1AB4(@C_0C8B_19BD^,D_27D8^,13,12,123,0,0,0,136,13,$ff);{top right}
	C_1918_1AB4(@C_0C8B_1AE0^,D_27D8^,13,12,123,41,0,0,136,13,$ff);{bottom right}
	C_1918_1825(
		0,0,136,
		165,146,320,
		136,53,
		PTR(EMSSegment,0)^,PTR($a000,0)^
	);
	{-- --}
	ShowMouse(TRUE);
END;

PROCEDURE C_01F7;
BEGIN
	IF ActionId > 0
	THEN BEGIN
		ActionId := ACTION_0;
		SetMouseImage(@C_1918_34F9,16,16,7,7);
	END;
END;

PROCEDURE C_0224;
BEGIN
	InventoryRender;
	C_01F7;
	IF IconCur > 0
	THEN IconOff(IconCur);
	IconCur := 0;
	IconPrev := 0;
	D_12CC := 0;
	D_12CB := 0;
END;

PROCEDURE C_0C8B_0261;
BEGIN
	RES_find('PANL',RES_offset,RES_size);
	LoadPCX(RES_handle,RES_size);
	EMSStart_0B;
	FastMove(PTR($a000,0)^,D_27D8^,$44c0);
	FastMove(PTR($a000,$44c0)^,D_27DC^,$44c0);
END;

PROCEDURE C_0C8B_02C0;
BEGIN
	EMSStart_0B;
	ShowMouse(FALSE);
	FastMove(PTR($a000,$b540)^,D_27D8^,$44c0);
	ShowMouse(TRUE);
END;

{C_02F5}PROCEDURE _HightligtCurrentIcon(bp04:BYTE);
VAR _x,_y,_width,_height:INTEGER;
BEGIN
	_x := IconInfo[bp04][1];
	_y := IconInfo[bp04][2];
	_width := IconInfo[bp04][3] - _x;
	_height := IconInfo[bp04][4] - _y;
	EMSStart_0B;
	ShowMouse(FALSE);
	C_1918_1878(_x,_y - 145,320,_x,_y,320,_width,_height,D_27D8^,PTR($a000,0)^,9,1);
	DrawLine(_x,_y,_x + _width,_y,14);
	DrawLine(_x,_y + 1,_x,_y + _height,14);
	DrawLine(_x + _width,_y + 1,_x + _width,_y + _height,7);
	DrawLine(_x + 1,_y + _height,_x + _width - 1,_y + _height,7);
	ShowMouse(TRUE);
END;

{C_0403}FUNCTION _GetActionIcon:BYTE;
BEGIN
	_GetActionIcon := 0;
	FOR GlobalI := 1 TO 8
	DO IF
		(MouseX >= IconInfo[GlobalI][1]) AND (MouseX <= IconInfo[GlobalI][3]) AND
		(MouseY >= IconInfo[GlobalI][2]) AND (MouseY <= IconInfo[GlobalI][4])
	THEN _GetActionIcon := GlobalI;
END;

PROCEDURE C_046B;
BEGIN
	IconCur := _GetActionIcon;
	IF IconCur <> IconPrev
	THEN BEGIN
		ShowMouse(FALSE);
		IF IconPrev <> 0
		THEN IconOff(IconPrev);
		IF IconCur <> 0
		THEN IconOn(IconCur);
		ShowMouse(TRUE);
	END;
	IconPrev := IconCur;
END;

PROCEDURE C_04BA;
BEGIN
	IF D_01F0 > 0
	THEN BEGIN
		D_01F0 := 0;
		SetMouseImage(@C_1918_34F9,16,16,7,7);
	END;
END;

PROCEDURE C_04E7;
BEGIN
	DefaultIcon := D_271C[D_27BA]^.f_defaultIcon;
	IF NOT D_0179
	THEN BEGIN
		C_04BA;
		InventoryRender;
	END;
	IF ((D_1A76 = 1) AND (NOT D_1A74[1])) OR (ActionId = ACTION_5)
	THEN BEGIN
		D_12CB := D_27BA;
		D_12CC := 1;
		PlayerGoesTo(D_271C[D_27BA]^.f_x,D_271C[D_27BA]^.f_y);
	END ELSE IF D_1A76 = 2
	THEN BEGIN
		C_16DC_03E2;
	END ELSE IF D_1A74[1]
	THEN BEGIN
		IF (ActionId <> ACTION_2) AND (ActionId <> ACTION_4) AND (ActionId <> ACTION_7)
		THEN BEGIN
			C_16DC_03E2;
		END ELSE BEGIN
			C_04BA;
			{-- --}
			IF NOT IsDifficult
			THEN C_0224;
			{-- --}
		END;
	END;
END;

{C_05A3}FUNCTION C_05A3(_x,_y:WORD):BYTE;
VAR _i:INTEGER;
BEGIN
	C_05A3 := 0;
	FOR _i := 1 TO 8
	DO IF
		(_x > D_008C[_i][1]) AND (_x < D_008C[_i][3]) AND
		(_y > D_008C[_i][2]) AND (_y < D_008C[_i][4])
	THEN C_05A3 := _i;
END;

PROCEDURE C_060E;
BEGIN
	LoadObject(D_1A70[D_1A76]);
	D_05A8 := 2;
	IF
		(CurObj.f_script2Count > 0) AND
		(CurObj.f_aScript2Info[1].f_00 = 0)
	THEN D_05A8 := 1;
END;

{C_0644}PROCEDURE C_0644(_x,_y:WORD);
VAR bp_01:BYTE;
BEGIN
	bp_01 := 0;
	D_1A61 := 0;
	FOR GlobalI := 1 TO 2
	DO IF
		(_x > D_0074[GlobalI][1]) AND (_x < D_0074[GlobalI][3]) AND
		(_y > D_0074[GlobalI][2]) AND (_y < D_0074[GlobalI][4])
	THEN BEGIN
		bp_01 := GlobalI;
		D_1A61 := 1;
	END;
	CASE bp_01 OF
		1: InventoryLeft;
		2: InventoryRight;
	END;
END;

PROCEDURE C_0713;
BEGIN
	IF (ActionId = ACTION_3) AND (D_05A8 = 1)
	THEN C_060E;
	IF D_1A76 = D_05A8
	THEN C_04E7;
	D_05A2 := D_27BA;
END;

{stretch2Screen?}
PROCEDURE C_0742(_src,_dst_ignored:POINTER; _left,_top,_right,_bottom:WORD; bp06,bp04:BYTE);
VAR dummy:INTEGER;
BEGIN
	EMSStart_13;
	ShowMouse(FALSE);
	Stretch2Screen(
		_src, _dst_ignored,
		ROUND((_left * bp06) / bp04),
		ROUND((_top * bp06) / bp04),
		320 - ROUND((320 - _right) * bp06 / bp04),
		200 - ROUND((200 - _bottom) * bp06 / bp04)
	);
	ShowMouse(TRUE);
END;

PROCEDURE C_0C8B_11A2;
VAR
	bp_01:BOOLEAN;
	_buttons:BYTE;
	_____:ARRAY[1..$100] OF BYTE;
	{-- --}
	PROCEDURE INNER_0850;
	VAR _srcX,_srcY:INTEGER;
	BEGIN
		D_05A9 := TRUE;
		IF D_27F2
		THEN BEGIN
			C_16DC_0000;
			EXIT;
		END;
		IF D_2808 AND (NOT D_0179)
		THEN EXIT;
		{-- --}
		IF NOT D_0179
		THEN C_0644(MouseX,MouseY);
		{-- --}
		IF (MouseY > 145) AND (MouseX < 143) AND (NOT D_0179)
		THEN BEGIN{else 0932}
			C_046B;
			IF IconCur = 0
			THEN BEGIN
				C_01F7;
				{goto 0932};
			END ELSE IF ActionId <> IconInfo[IconCur][5]
			THEN BEGIN {else 092F}
				ActionId := IconInfo[IconCur][5];
				SetMouseShape(ActionId);
				_HightligtCurrentIcon(IconCur);
				IF ActionId <> ACTION_3
				THEN D_05A8 := D_0084[ActionId]
				ELSE D_05A8 := 1;
				D_1A76 := 0;
				D_05A2 := 0;
				D_05A5 := 0;
				D_12CB := 0;
				D_12CC := 0;
			END ELSE BEGIN
				C_0224;
			END;
		END;
		IF (MouseY < 145) OR D_0179
		THEN BEGIN{else 0957}
			bp_01 := TRUE;
			IF D_27BA = 0
			THEN D_12CC := 0;
		END ELSE BEGIN
			bp_01 := FALSE;
		END;
		IF ActionId > 0
		THEN BEGIN{else 0B6B}
			bp_01 := FALSE;
			{-- --}
			IF MouseY < 145
			THEN BEGIN{else 0AB9}
				IF (D_27BA = 0) AND (D_1A61 = 0)
				THEN BEGIN{else 099F}
					{-- --}
					IF NOT IsDifficult
					THEN BEGIN
						C_04BA;
						C_0224;
					END;
					{-- --}
					bp_01 := TRUE;
				END;
				IF (D_27BA > 0) AND (D_27BA <> D_05A2) AND ((ActionId <> ACTION_5) OR (D_1A76 <> 0))
				THEN BEGIN{else 0AB9}
					INC(D_1A76);
					D_1A70[D_1A76] := D_271C[D_27BA]^.f_objId;
					{-- capture detail->mouse image? --}
					IF ActionId = ACTION_3
					THEN BEGIN{else 0A8A}
						_srcX := MouseX - 15;
						IF _srcX < 0
						THEN _srcX := 0;
						IF _srcX > 289
						THEN _srcX := 289;
						_srcY := MouseY - 10;
						IF _srcY < 0
						THEN _srcY := 0;
						IF _srcY > 124
						THEN _srcY := 124;
						ShowMouse(FALSE);
						FILLCHAR(D_27AE^,$258,$ff);
						C_1918_1825(
							_srcX,_srcY,320,
							1,1,30,
							28,18,
							PTR($a000,0)^,D_27AE^
						);
						D_27B2 := 30; D_27B3 := 20;
						D_2798 := 15; D_2799 := 10;
						ShowMouse(TRUE);
					END;
					{-- --}
					IF D_1A70[D_1A76] = 0
					THEN BEGIN
						bp_01 := TRUE;
						C_04BA;
						C_0224;
					END ELSE BEGIN
						D_1A74[D_1A76] := FALSE;
						C_0713;
					END;
				END;
			END;
			{-- --}
			IF (MouseY >= 145) AND (MouseX >= 165) AND (NOT D_0179)
			THEN BEGIN{else 0b69}
				IF (D_05A7 = 0) AND (D_1A61 = 0)
				THEN BEGIN
					C_04BA;
					C_0224;
				END;
				IF (D_05A7 > 0) AND (D_05A7 <> D_05A5) AND (D_05A7 <= ObjCount)
				THEN BEGIN{else 0B69}
					D_01F0 := D_05A7;
					EMSStart_04;
					SetMouseImage(Inventory[D_01F0]^.f_pImg,31,15,16,8);
					InventoryRender;
					INC(D_1A76);
					D_1A70[D_1A76] := Inventory[D_05A7]^.f_objId;
					D_1A74[D_1A76] := TRUE;
					C_0713;
				END;
			END;
			{goto 0BC2}
		END ELSE IF
			(MouseY >= 145) AND (MouseX >= 165) AND
			(NOT D_0179) AND
			(D_05A7 > 0) AND (D_05A7 <= ObjCount)
		THEN BEGIN{else 0BC2}
			_HightligtCurrentIcon(1);
			D_1A76 := 1;
			D_1A70[1] := Inventory[D_05A7]^.f_objId;
			D_1A74[1] := TRUE;
			ActionId := ACTION_1;
			IconCur := 1;
			C_04E7;
		END;
		{-- --}
		IF NOT bp_01
		THEN EXIT;
		{-- --}
		IF D_27BA > 0
		THEN BEGIN{else 0C5F}
			D_12CB := D_27BA;
			IF NOT D_0179
			THEN BEGIN
				C_04BA;
				InventoryRender;
				C_01F7;
			END;
			D_1A76 := 1;
			D_1A70[1] := D_271C[D_27BA]^.f_objId;
			D_1A74[1] := FALSE;
			D_12CC := D_271C[D_27BA]^.f_39;
			IF D_276D
			THEN D_12CC := 2;
			PlayerGoesTo(D_271C[D_27BA]^.f_x,D_271C[D_27BA]^.f_y);
			{goto 0C9A}
		END ELSE BEGIN
			IF PlayerIsMoving
			THEN C_14C8_0A5B;
			IF Distance(Actors[1]^.f_aX[1],Actors[1]^.f_aY[1],MouseX,MouseY) > 10
			THEN PlayerGoesTo(MouseX,MouseY);
		END;
		D_12CB := D_27BA;
	END;
	{-- --}
	{select icon?}
	PROCEDURE INNER_0CA4(bbp06:INTEGER);
	BEGIN
		IF (NOT D_2808) AND (bbp06 > 0) AND (ActionId <> IconInfo[bbp06][5])
		THEN BEGIN
			IF (ActionId > 0) OR (IconPrev <> 0)
			THEN BEGIN
				IconOff(IconPrev);
				D_12CC := 0;
				D_12CB := 0;
			END;
			ActionId := IconInfo[bbp06][5];
			SetMouseShape(ActionId);
			_HightligtCurrentIcon(bbp06);
			IconCur := bbp06;
			IconPrev := bbp06;
			IF ActionId <> ACTION_3
			THEN D_05A8 := D_0084[ActionId]
			ELSE D_05A8 := 1;
			D_1A76 := 0;
			D_05A2 := 0;
			D_05A5 := 0;
			D_12CB := 0;
			D_12CC := 0;
		END;
	END;
	{-- --}
	PROCEDURE INNER_0D54;
	BEGIN
		EMSStart_0B;
		ShowMouse(FALSE);
		C_1918_1825(
			170,3,320,
			170,148,320,
			120,9,
			D_27D8^,PTR($a000,0)^
		);
		ShowMouse(TRUE);
	END;
	{-- --}
	PROCEDURE INNER_0D9D;
	BEGIN
		D_27BA := C_18B8_00F2(MouseX,MouseY);
		IF D_27BA <> D_05A3
		THEN BEGIN{else 0E67}
			DefaultIcon := D_271C[D_27BA]^.f_defaultIcon;
			INNER_0D54;
			{-- --}
			IF (D_27BA <> 0) AND (NOT IsDifficult)
			THEN BEGIN{else 0E61}
				PutString_2(D_271C[D_27BA]^.f_strE,170,148);
				WITH D_271C[D_27BA]^
				DO BEGIN
					IF (f_defaultIcon > 0) AND (ActionId = ACTION_0)
					THEN BEGIN{else 0E61}
						IF IconPrev <> 0
						THEN IconOff(IconPrev);
						IconCur := f_defaultIcon;
						IconOn(f_defaultIcon);
						IconPrev := IconCur;
					END;
				END;
			END;
			{-- --}
			D_05A3 := D_27BA;
		END;
	END;
	{-- --}
	PROCEDURE INNER_0E6B;
	VAR _i:BYTE;
	BEGIN
		{-- --}
		IF DoShakeScreen
		THEN BEGIN
			IF D_0CDA > 0
			THEN D_0CDA := 0
			ELSE D_0CDA := RANDOM(5) * 80;
			ScreenOffset(D_0CDA);
		END;
		{-- --}
		D_2A28 := 0;
		C_1031_14F5;
		IF (D_1A60 = 0) AND (D_2807 <> 0)
		THEN C_1031_1391;
		{-- --}
		C_1918_2A16;
		IF D_27D6 > 0
		THEN FOR _i := 1 TO D_27D6
		DO C_1918_1BB1(_i);
		{-- --}
		WITH Actors[3]^
		DO BEGIN
			f_prevFrame := 0;
			f_aX[0] := 160; f_aY[0] := 144;
			f_aWidth[0] := 2; f_aHeight[0] := 2;
			f_aX[1] := 160; f_aY[1] := 144;
			f_aWidth[1] := 2; f_aHeight[1] := 2;
		END;
		IF PlayerIsMoving
		THEN MoveRefresh;
		IF D_27C2 AND (D_0169 = D_016A)
		THEN BEGIN
			EMSStart_13;
			ShowMouse(FALSE);
			Stretch2Screen(PTR(EMSSegment,0),PTR($a000,0),D_0CE4,D_0CE6,D_0CE8,D_0CEA);
			ShowMouse(TRUE);
		END;
		{-- patch for scene '29' --}
		IF D_27C9 = 29
		THEN AnimatePalette;
		{-- --}
		IF (D_1A84 <> 0) OR D_27F2
		THEN IF (D_1A58 = 0) AND (NOT D_0177)
		THEN BEGIN
			IF D_27CC > 0
			THEN DEC(D_27CC)
			ELSE C_1031_1391;
		END;
		IF D_27F8 AND D_27F9
		THEN C_1765_087E;
		IF D_0496
		THEN C_0000(MouseX,MouseY);
	END;
	{-- --}
	PROCEDURE INNER_1002;
	BEGIN
		D_1A60 := 0;
		IF D_2807 <> 0
		THEN C_1031_0E84;
		D_27CC := 0;
		IF PlayerIsMoving
		THEN C_14C8_0A5B;
		IF D_27F2
		THEN C_16DC_0000;
		IF D_1A84 <> 0
		THEN BEGIN
			D_1A84 := 0;
			FREEMEM(D_1A78,D_1A5E);
			D_2808 := FALSE;
		END;
		DoShakeScreen := FALSE;
		ScreenOffset(0);
		IF D_27C2
		THEN BEGIN
			D_27C2 := FALSE;
			D_016A := D_0169;
			D_2A32 := D_2A32 * 2;
		END;
	END;
	{-- --}
BEGIN
	D_1A58 := 0;
	D_27BA := 0;
	D_05A7 := 0;
	D_05A3 := 0;
	D_05A4 := 0;
	D_12CB := 0;
	D_2807 := 0;
	REPEAT
		{-- --}
		IF D_0177 AND (C_1D8E_00A6 <> D_0CE2)
		THEN BEGIN
			C_1D8E_00DA(D_0CE3);
			D_0177 := FALSE;
		END;
		{-- --}
		GetMouseXY(MouseX,MouseY);
		MouseX := MouseX SHR 1;
		_buttons := MOUSE_getButtons;
		{-- --}
		IF D_0179
		THEN BEGIN{else 1365}
			IF (MouseX <> PrevMouseX) OR (MouseY <> PrevMouseY)
			THEN BEGIN{else 1349}
				D_27BA := C_18B8_00F2(MouseX,MouseY);
				IF (D_27BA <> D_05A3) AND (NOT D_27F2)
				THEN BEGIN{else 1300}
					DefaultIcon := D_271C[D_27BA]^.f_defaultIcon;
					D_05A3 := D_27BA;
					{-- --}
					IF (D_27BA <> 0) AND (NOT IsDifficult)
					THEN BEGIN{else 12EB}
						IF D_0178
						THEN WITH Actors[2]^
						DO FREEMEM(f_pData,f_aFrameWidth[2] * f_aFrameHeight[2]);
						PutString_1(D_271C[D_27BA]^.f_strE,MouseX,MouseY - 10,$ff);
						D_0178 := TRUE;
					END;
					{-- --}
					IF (D_27BA = 0) AND D_0178
					THEN C_1031_008D;
					{goto 133D}
				END ELSE IF D_0178 AND (NOT D_27F2)
				THEN BEGIN{else 133D}
					WITH Actors[2]^
					DO BEGIN
						f_aX[1] := MouseX;
						f_aY[1] := MouseY - 10;
						f_fb := TRUE;
					END;
				END;
				PrevMouseX := MouseX;
				PrevMouseY := MouseY;
			END;
			IF (MOUSE_getButtons = 1) AND (NOT D_05A9)
			THEN INNER_0850
			ELSE D_05A9 := FALSE;
		END;
		{-- --}
		IF NOT D_025E
		THEN BEGIN{else 15CB}
			{-- --}
			IF NOT D_27F9
			THEN CASE _buttons OF
				1{left click}: IF (NOT D_05A9) AND (NOT D_0496)
				THEN BEGIN
					INNER_0850;
					IF ActionId = ACTION_9
					THEN BEGIN
						C_04BA;
						C_0224;
						GameMenu;
						D_05A9 := TRUE;
					END;
				END;
				2{right click}: BEGIN
					IF (IconCur > 0) AND (NOT D_0496) AND (NOT IsDifficult)
					THEN BEGIN{else 1434}
						IF NOT D_05A9
						THEN BEGIN{else 1432}
							INNER_0D9D;
							IF IconCur > 0
							THEN BEGIN{else 1432}
								ActionId := IconInfo[IconCur][5];
								SetMouseShape(ActionId);
								_HightligtCurrentIcon(IconCur);
								IF ActionId <> ACTION_3
								THEN D_05A8 := D_0084[ActionId]
								ELSE D_05A8 := 1;
								D_1A76 := 0;
								D_05A2 := 0;
								D_05A5 := 0;
								D_12CB := 0;
								D_12CC := 0;
								INNER_0850;
							END;
						END;
						{goto 1499}
					END ELSE BEGIN
						{-- --}
						IF IsDifficult AND (NOT D_05A9) AND (ActionId > 0)
						THEN BEGIN{else 146E}
							D_05A2 := IconCur;
							INC(D_05A2);
							IF D_05A2 > 7
							THEN D_05A2 := 1;
							INNER_0CA4(D_05A2);{select icon?}
							D_05A9 := TRUE;
						END;
						{-- --}
						IF (MouseX <> PrevMouseX) OR (MouseY <> PrevMouseY) OR (NOT D_0496)
						THEN IF NOT D_05A9
						THEN C_0000(MouseX,MouseY);
					END;
				END;
				0{no click}: BEGIN
					D_05A9 := FALSE;
					IF D_0496
					THEN BEGIN{else 14C7}
						D_0496 := FALSE;
						EMSStart_0B;
						C_1918_34BC(D_27D8);
						InventoryRender;
					END;
				END;
				3{left|right click}: IF IsDifficult AND (ActionId > 0)
				THEN C_0224;
			END;
			{-- --}
			IF NOT D_0496
			THEN BEGIN{else 15CB}
				IF NOT D_27F9
				THEN BEGIN {else 15BE}
					IF (MouseX <> PrevMouseX) OR (MouseY <> PrevMouseY)
					THEN BEGIN{else 15BC}
						IF MouseY > 144
						THEN BEGIN{else 1584}
							IF ActionId = ACTION_0
							THEN C_046B;
							D_05A7 := C_05A3(MouseX,MouseY);
							IF D_05A7 > 0
							THEN D_05A7 := D_05A7 + D_2710 - 1;
							IF D_05A7 <> D_05A4
							THEN BEGIN{else 1582}
								INNER_0D54;
								IF (D_05A7 > 0) AND (D_05A7 <= ObjCount)
								THEN PutString_2(Inventory[D_05A7]^.f_name,170,148);
								D_05A4 := D_05A7;
							END;
							{goto 15B0}
						END ELSE BEGIN
							INNER_0D9D;
							IF (IconCur <> 0) AND (ActionId = ACTION_0) AND (D_27BA = 0)
							THEN BEGIN
								IconOff(IconCur);
								IconCur := 0;
								IconPrev := 0;
							END;
						END;
						PrevMouseX := MouseX;
						PrevMouseY := MouseY;
					END;
					{goto 15CB}
				END ELSE BEGIN
					C_1765_0BFD(MouseX,MouseY);
				END;
			END;
			{-- --}
		END;
		{-- --}
		IF D_2A28 <> 0
		THEN BEGIN{else 165B}
			IF D_0169 <> D_016A
			THEN BEGIN{else 163C}
				IF ODD(D_0169)
				THEN INNER_0E6B;
				D_0169 := D_0169 + D_016E;
				C_0742(PTR(EMSSegment,0),PTR($a000,0),D_0CE4,D_0CE6,D_0CE8,D_0CEA,D_0169,D_016B);{stretch2Screen?}
				IF D_0169 = D_016A
				THEN BEGIN{else 163A}
					D_2A32 := D_2A32 SHL 1;
					IF D_016E = -1
					THEN C_1031_0785;
				END;
				{goto 1640}
			END ELSE BEGIN
				INNER_0E6B;
			END;
			D_2A28 := 0;
			IF D_0168 > 0
			THEN BEGIN{else 165B}
				D_0168 := 0;
				GameMenu;
				D_05A9 := TRUE;
			END;
		END;
		{-- --}
		IF KEYPRESSED
		THEN BEGIN{else 1916}
			D_05AA := READKEY;
			{-- ESC --}
			IF (D_05AA = #27) AND (D_0CD6 <> $ff)
			THEN BEGIN{else 16D0}
				D_27CB := TRUE;
				D_27C9 := D_0CD6;
				D_27CA := D_0CD7;
				IF (D_27C9 = 0) AND (D_27CA <> 0)
				THEN BEGIN{else 16C0}
{$IFDEF FRENCH}
					IF DialogBox('Veux-tu reellement quitter? (O,N)',[#27,'N','O']) <> 'O'
{$ELSE}
					IF DialogBox('Do you really want to quit? (Y,N)',[#27,'N','Y']) <> 'Y'
{$ENDIF}
					THEN BEGIN
						D_27CB := FALSE;
						D_27C9 := 1;
					END ELSE BEGIN
						D_27CA := 0;
					END;
				END;
				IF D_27CB
				THEN BEGIN
					D_0CD6 := $ff;
					INNER_1002;
				END;
			END;
			{-- --}
			D_05AA := UPCASE(D_05AA);
			{-- pause --}
			CASE D_05AA OF
				' ': BEGIN
					Save.f_07 := tConfig(D_27BC);
					FILLCHAR(D_27BC,2,0);
					UpdateSoundFlags;
{$IFDEF FRENCH}
					DialogBox('          Jeu en pause',[#13,' ']);
{$ELSE}
					DialogBox('           Game paused',[#13,' ']);
{$ENDIF}
					tConfig(D_27BC) := Save.f_07;
					UpdateSoundFlags;
				END;
			END;
			{-- special keys --}
			IF D_05AA = #0
			THEN BEGIN{else 18AC}
				D_05AA := READKEY;
				CASE D_05AA OF
					#$2f{ALT+V}: BEGIN
						IF NOT IsRegistered
						THEN DialogBox('  ESCAPE FROM DELIRIUM shareware',[#13,#27,' '])
						ELSE DialogBox(' ESCAPE FROM DELIRIUM registered',[#13,#27,' ']);
						DialogBox(' ViRTUAL X-PERiENCE SOFTWARE 1996',[#13,#27,' ']);
{$IFDEF FRENCH}
						DialogBox('        Version Fran'#$87'aise        ',[#13,#27,' ']);
{$ENDIF}
					END;
					#$2d{ALT+X}: BEGIN
						INNER_1002;
						D_27CB := TRUE;
						D_27C9 := 0;
					END;
					#$49{PgUp -- volume up}: BEGIN
						IF (D_27C0[1] + 5) <= 100
						THEN INC(D_27C0[1],5)
						ELSE D_27C0[1] := 100;
						MUSIC_setVolumes(ROUND((D_27C0[1] / 100.0) * 255.0),$ff);
					END;
					#$51{PgDn -- volume down}: BEGIN
						IF (D_27C0[1] - 5) >= 0
						THEN DEC(D_27C0[1],5)
						ELSE D_27C0[1] := 0;
						MUSIC_setVolumes(ROUND((D_27C0[1] / 100.0) * 255.0),$ff);
					END;
					#$3B{F1 -- music on/off}: BEGIN
						D_27BC[1] := NOT D_27BC[1];
						UpdateSoundFlags;
					END;
					#$3C{F2 -- sound on/off}: BEGIN
						D_27BC[2] := NOT D_27BC[2];
						UpdateSoundFlags;
					END;
					ELSE IF (NOT D_2808) AND (NOT D_27F9)
					THEN BEGIN{else 18AA}
						CASE D_05AA OF
							#$3F{F5 -- file menu}: BEGIN
								C_0224;
								GameMenu;
								D_05A9 := TRUE;
							END;
							#$42{F8 -- restart}: C_0E7F_004E;
							#$4B{LEFT}: InventoryLeft;
							#$4D{RIGHT}: InventoryRight;
						END;
					END;
				END;
				{goto 1916}
			END ELSE IF (NOT D_2808) AND (NOT D_27F9) AND (NOT D_0179)
			THEN BEGIN{else 1916}
				CASE D_05AA OF
					'Q': INNER_0CA4(1);{select icon?}
					'W': INNER_0CA4(2);{select icon?}
					'E': INNER_0CA4(3);{select icon?}
					'R': INNER_0CA4(4);{select icon?}
					'A': INNER_0CA4(5);{select icon?}
					'S': INNER_0CA4(6);{select icon?}
					'D': INNER_0CA4(7);{select icon?}
				END;
			END;
		END;
		{-- --}
		IF (D_27C9 = 0) AND D_27BC[3] AND (D_27CA <> 0)
		THEN BEGIN{else 1972}
			CASE Language OF
{$IFDEF FRENCH}
				0: IF DialogBox('Veux-tu reellement quitter? (O,N)',[#27,'N','O']) <> 'O'
{$ELSE}
				0: IF DialogBox('Do you really want to quit? (Y,N)',[#27,'N','Y']) <> 'Y'
{$ENDIF}
				THEN BEGIN
					D_27CB := FALSE;
					D_27C9 := 1;
				END;
				1: IF DialogBox('Wirklich zurueck zu DOS? (Y,N)',[#27,'N','Y']) <> 'Y'
				THEN BEGIN
					D_27CB := FALSE;
					D_27C9 := 1;
				END;
			END;
		END;
		{-- --}
	UNTIL D_27CB OR D_27C3;
	D_0179 := FALSE;
	{-- --}
	IF D_0178
	THEN C_1031_008D;
	{-- --}
END;

BEGIN
	D_0492 := PTR($A000,0);
	IconCur := 0;
	IconPrev := 0;
	ActionId := ACTION_0;
END.
