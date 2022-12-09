{$G+}
UNIT C_183E;{inventory?}

INTERFACE
CONST
	D_01F0:INTEGER = 0;{"held" object}

{C_183E_0237}PROCEDURE ReleaseObject;
{C_183E_02B8}PROCEDURE LoadObject(_objId:WORD);
{C_183E_0334}PROCEDURE InventoryRender;
{C_183E_049E}PROCEDURE InventoryAdd(_objId:INTEGER; bp06:BOOLEAN);
{C_183E_0576}PROCEDURE InventoryRemove(_objId:INTEGER);
{C_183E_0679}PROCEDURE InventoryEmpty;
{C_183E_06C5}PROCEDURE InventoryLoadIcon;
{C_183E_06E5}PROCEDURE InventoryClean;
{C_183E_06F1}PROCEDURE InventoryLeft;
{C_183E_070D}PROCEDURE InventoryRight;
{C_183E_0735}PROCEDURE InventoryInit;

IMPLEMENTATION

USES
	C_1918,
	C_1DD9,
	BSS;

{C_0000}PROCEDURE _LoadObject;
VAR _i:BYTE;
BEGIN
	BLOCKREAD(RES_handle,CurObj.f_conversationId,1);
	BLOCKREAD(RES_handle,CurObj.f_name,$15);
	FOR _i := 1 TO 7
	DO BLOCKREAD(RES_handle,CurObj.f_aScriptLen[_i],2);
	FOR _i := 1 TO 7
	DO BEGIN
		GETMEM(CurObj.f_apScript[_i],CurObj.f_aScriptLen[_i]);
		BLOCKREAD(RES_handle,CurObj.f_apScript[_i]^,CurObj.f_aScriptLen[_i]);
	END;
	{-- german patch --}
	IF Language = 1
	THEN IF (CurObj.f_aScriptLen[4] > 0) AND (CurObj.f_aScriptLen[4] <= $14)
	THEN BEGIN{else 015E}
		CurObj.f_name[0] := #0;
		FOR _i := 1 TO CurObj.f_aScriptLen[4]
		DO CurObj.f_name := CurObj.f_name + CHAR(MEM[SEG(CurObj.f_apScript[4]^):OFS(CurObj.f_apScript[4]^) + _i - 1]);
	END;
	{-- --}
	BLOCKREAD(RES_handle,CurObj.f_script2Count,1);
	_i := 0;
	WHILE _i < CurObj.f_script2Count
	DO BEGIN
		INC(_i);
		BLOCKREAD(RES_handle,CurObj.f_aScript2Info[_i],4);
	END;
	_i := 0;
	WHILE _i < CurObj.f_script2Count
	DO BEGIN
		INC(_i);
		GETMEM(CurObj.f_apScript2[_i],CurObj.f_aScript2Info[_i].f_len);
		BLOCKREAD(RES_handle,CurObj.f_apScript2[_i]^,CurObj.f_aScript2Info[_i].f_len);
	END;
	{-- --}
	BLOCKREAD(RES_handle,CurObj.f_hasIcon,1);
END;

{C_183E_0237}PROCEDURE ReleaseObject;
VAR _i:BYTE;
BEGIN
	IF CurObjId <> 0
	THEN BEGIN
		FOR _i := 7 DOWNTO 1
		DO FREEMEM(CurObj.f_apScript[_i],CurObj.f_aScriptLen[_i]);
		_i := 0;
		WHILE _i < CurObj.f_script2Count
		DO BEGIN
			INC(_i);
			FREEMEM(CurObj.f_apScript2[_i],CurObj.f_aScript2Info[_i].f_len);
		END;
	END;
END;

{C_183E_02B8}PROCEDURE LoadObject(_objId:WORD);
VAR _offset:LONGINT;
BEGIN
	SEEK(RES_handle,D_2718 + ((_objId - 1) * 4 + 2));
	BLOCKREAD(RES_handle,_offset,4);
	SEEK(RES_handle,_offset + D_2718);
	ReleaseObject;
	_LoadObject;
	CurObjId := _objId;
END;

{C_183E_0334}PROCEDURE InventoryRender;
VAR
	_buf:POINTER;
	_i:WORD;
	_screenY:BYTE;
	bp_0a:WORD;
BEGIN
	IF NOT D_025E
	THEN BEGIN{else 049C}
		GETMEM(_buf,$1383);
		EMSStart_0B;
		C_1918_1825(
			165,17,320,
			0,0,135,
			135,37,
			D_27D8^,_buf^
		);
		EMSStart_04;
		FOR _i := 1 TO 8
		DO BEGIN
			bp_0a := (D_2710 + _i) - 1;
			IF ObjCount >= bp_0a
			THEN BEGIN{else 0450}
				IF (_i MOD 2) = 0
				THEN _screenY := 20
				ELSE _screenY := 1;
				C_1918_0E60(
					Inventory[bp_0a]^.f_pImg^,_buf^,
					31,16,((_i - 1) SHR 1) * 34 + 1,
					_screenY,0,0,
					135,31
				);
				{-- highlight held object(bugged?) --}
				IF D_01F0 = bp_0a
				THEN C_1918_1878(
					((_i - 1) SHR 1) * 34 + 1,_screenY,135,
					((_i - 1) SHR 1) * 34 + 1,_screenY,135,
					31,16,
					_buf^,_buf^,
					9,1
				);
				{-- --}
			END;
		END;
		{-- --}
		ShowMouse(FALSE);
		C_1918_1825(
			0,0,135,
			165,162,320,
			135,37,
			_buf^,PTR($a000,0)^
		);
		ShowMouse(TRUE);
		{-- --}
		FREEMEM(_buf,$1383);
	END;
END;

{C_183E_049E}PROCEDURE InventoryAdd(_objId:INTEGER; bp06:BOOLEAN);
BEGIN
	INC(ObjCount);
	NEW(Inventory[ObjCount]);
	WITH Inventory[ObjCount]^
	DO BEGIN
		f_pImg := PTR(EMSSegment,(ObjCount - 1) * $1f0);
		EMSStart_04;
		IF CurObj.f_hasIcon = 1
		THEN BLOCKREAD(RES_handle,f_pImg^,$1f0);
		f_objId := _objId;
		f_name := CurObj.f_name;
		IF bp06
		THEN BEGIN
			IF ObjCount > (D_2710 + 7)
			THEN D_2710 := (ObjCount - 8) SHR 1 SHL 1 + 3;
			InventoryRender;
		END;
	END;
END;

{C_183E_0576}PROCEDURE InventoryRemove(_objId:INTEGER);
VAR bp_02,_i:WORD;
BEGIN
	bp_02 := 1;
	WHILE (Inventory[bp_02]^.f_objId <> _objId) AND (ObjCount >= bp_02)
	DO INC(bp_02);
	IF ObjCount < bp_02
	THEN EXIT;
	EMSStart_04;
	ASM
		PUSH	DS
		XOR	AH,AH
		MOV	AL,ObjCount
		SUB	AX,bp_02
		MOV	BX,$7C
		MUL	BX
		MOV	CX,AX
		MOV	ES,EMSSegment
		MOV	DS,EMSSegment
		MOV	AX,bp_02
		MOV	BX,$1F0
		MUL	BX
		MOV	SI,AX
		MOV	DI,SI
		SUB	DI,$1F0
		CLD	
		REPZ	
		DB	$66
		MOVSW	
		POP	DS
	END;
	IF bp_02 < ObjCount
	THEN FOR _i := bp_02 TO (ObjCount - 1)
	DO BEGIN
		Inventory[_i]^ := Inventory[_i + 1]^;
		Inventory[_i]^.f_pImg := PTR(EMSSegment,(_i - 1) * $1f0);
	END;
	DISPOSE(Inventory[ObjCount]);
	DEC(ObjCount);
	InventoryRender;
END;


{C_183E_0679}PROCEDURE InventoryEmpty;
VAR _i:WORD;
BEGIN
	FOR _i := ObjCount DOWNTO 1
	DO DISPOSE(Inventory[_i]);
	D_2710 := 1;
	ObjCount := 0;
END;

{C_183E_06C5}PROCEDURE InventoryLoadIcon;
BEGIN
	RES_find('ICON',D_2718,RES_size);
END;

{C_183E_06E5}PROCEDURE InventoryClean;
BEGIN
END;

{C_183E_06F1}PROCEDURE InventoryLeft;
BEGIN
	IF D_2710 > 2
	THEN BEGIN
		DEC(D_2710,2);
		InventoryRender;
	END;
END;

{C_183E_070D}PROCEDURE InventoryRight;
BEGIN
	IF (D_2710 + 7) < ObjCount
	THEN BEGIN
		INC(D_2710,2);
		InventoryRender;
	END;
END;

{C_183E_0735}PROCEDURE InventoryInit;
BEGIN
	ObjCount := 0;
	CurObjId := 0;
	FOR GlobalI := 1 TO 7
	DO CurObj.f_aScriptLen[GlobalI] := 0;
	FOR GlobalJ := 1 TO 5 {error:should be GlobalI?}
	DO CurObj.f_aScript2Info[GlobalI].f_len := 0;
	CurObj.f_script2Count := 0;
	D_2714 := 0;
	D_2710 := 1;
END;

END.
