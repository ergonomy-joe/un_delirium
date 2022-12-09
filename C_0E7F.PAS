{$G+}
{$X+}
{ DEFINE FRENCH}
UNIT C_0E7F;{game menu}

INTERFACE
USES BSS;

PROCEDURE C_0E7F_004E;
{C_0E7F_00B6}PROCEDURE UpdateSoundFlags;
{C_0E7F_028C}PROCEDURE MenuRender;
{C_0E7F_0858}PROCEDURE SaveGame(bp06:BYTE);
{C_0E7F_0C54}PROCEDURE LoadGame(bp06:BYTE);
{C_0E7F_0EBE}PROCEDURE MenuInit;
{C_0E7F_0FBC}PROCEDURE MenuClean;
{C_0E7F_150D}FUNCTION DialogBox(_str:STRING; bp06:tSetOfChar):CHAR;
{C_0E7F_16B0}PROCEDURE GameMenu;

IMPLEMENTATION

USES
	CRT,
	C_1018,
	C_1031,
	C_149C,
	C_1D8E,
	C_183E,
	C_18DC,
	C_1918,
	C_1DD9;

CONST
	D_00CE:ARRAY[1..$13,0..3] OF INTEGER = (
		($05,$05,$2E,$15),
		($32,$05,$5B,$15),
		($5F,$05,$88,$15),
		($8D,$05,$BF,$15),
		($C4,$05,$ED,$15),
		($88,$18,$92,$31),
		($88,$48,$92,$61),
		($9A,$1C,$C7,$23),
		($9A,$23,$C7,$2A),
		($9A,$2A,$C7,$37),
		($D1,$1D,$DE,$5F),
		($DE,$1D,$EB,$5F),
		($07,$1A,$86,$24),
		($07,$24,$86,$2E),
		($07,$2E,$86,$38),
		($07,$38,$86,$42),
		($07,$42,$86,$4C),
		($07,$4C,$86,$56),
		($07,$56,$86,$60)
	);

{restart game}
PROCEDURE C_0E7F_004E;
BEGIN
	{-- confirm --}
	IF D_27BC[3]
	THEN BEGIN
		IF Language = 0
		THEN BEGIN
{$IFDEF FRENCH}
			IF DialogBox('Recommencer ? (O,N)',[#27,'N','O']) <> 'O'
{$ELSE}
			IF DialogBox('Restart game? (Y,N)',[#27,'N','Y']) <> 'Y'
{$ENDIF}
			THEN EXIT;
		END ELSE BEGIN
			IF DialogBox('Spiel neu beginnen? (Y,N)',[#27,'N','Y']) <> 'Y'
			THEN EXIT;
		END;
	END;
	{-- --}
	D_27CB := TRUE;
	D_27C9 := 93;
	D_27CA := 1;
	SCRIPT_52;
	C_1031_0113;
	InventoryEmpty;
	CurSong := $81;
END;

{C_0E7F_00B6}PROCEDURE UpdateSoundFlags;
VAR _flags:BYTE;
BEGIN
	IF NOT D_27BC[1]
	THEN _flags := 2
	ELSE _flags := 0;

	IF NOT D_27BC[2]
	THEN INC(_flags);

	MUSIC_setFlags(_flags);
END;

{C_00EA}FUNCTION _MenuItemAt(_x,_y:WORD):BYTE;
BEGIN
	_MenuItemAt := 0;
	FOR GlobalI := 1 TO $13
	DO BEGIN
		IF
			(_x >= D_00CE[GlobalI][0]) AND (_x <= D_00CE[GlobalI][2]) AND
			(_y >= D_00CE[GlobalI][1]) AND (_y <= D_00CE[GlobalI][3])
		THEN _MenuItemAt := GlobalI;
	END;
END;

{C_019B}PROCEDURE RenderCheckbox(bp06:BYTE; bp04:BOOLEAN);
BEGIN
	ShowMouse(FALSE);
	IF bp04
	THEN BEGIN
		C_1918_1825(
			0,0,6,
			D_00CE[bp06][0] + $1f,D_00CE[bp06][1] + $1f,320,
			6,5,
			D_0CC4^,PTR($a000,0)^
		);
	END ELSE BEGIN
		EMSDoMapping(EMSHandle,8,0);
		EMSDoMapping(EMSHandle,9,1);
		D_27D8 := PTR(EMSSegment,0);
		C_1918_1825(
			D_00CE[bp06][0] + 1,D_00CE[bp06][1] + 1,243,
			D_00CE[bp06][0] + $1f,D_00CE[bp06][1] + $1f,320,
			6,5,
			D_27D8^,PTR($a000,0)^
		);
	END;
	ShowMouse(TRUE);
END;

{C_0E7F_028C}PROCEDURE MenuRender;
BEGIN
	EMSDoMapping(EMSHandle,8,0);
	EMSDoMapping(EMSHandle,9,1);
	D_27D8 := PTR(EMSSegment,0);
	ShowMouse(FALSE);
	C_1918_1825(
		0,0,243,
		30,30,320,
		243,103,
		D_27D8^,PTR($a000,0)^
	);
	{-- --}
	FOR GlobalI := 1 TO 3
	DO RenderCheckbox(GlobalI + 7,D_27BC[GlobalI]);
	{-- gauges --}
	FOR GlobalI := $b TO $c
	DO BEGIN
		GlobalJ := ROUND(((100 - D_27C0[GlobalI - $a]) / 100.0) * 54.0) + $3e;
		C_1918_1825(
			0,0,4,
			D_00CE[GlobalI][0] + 8 + 30,GlobalJ,320,
			4,7,
			D_0CC8^,PTR($a000,0)^
		);
	END;
	{-- --}
	ShowMouse(TRUE);
END;

{C_04A0}FUNCTION EditFilename(_x,_y,_maxLen:WORD; VAR _str:STRING):BOOLEAN;
VAR
	_srcY:INTEGER;
	_i:BYTE;
	_srcX:BYTE;
	bp_0a:POINTER;
	_p_0c:INTEGER;
	_ch:CHAR;
	_cursorOn:BOOLEAN;
	{-- --}
	{INNER_03A8}PROCEDURE INNER_PutCharAt(bbp0a:CHAR; _dstX,_dstY:INTEGER);
	BEGIN
		IF bbp0a = ' '
		THEN EXIT;
		_srcY := 0;
		_srcX := POS(bbp0a,D_0214[0]);
		IF _srcX = 0
		THEN BEGIN
			_srcX := POS(bbp0a,D_0214[1]);
			_srcY := 10;
		END;
		DEC(_srcX);
		C_1918_1878(
			_srcX * 7,_srcY,Actors[2]^.f_aFrameWidth[1],
			0,0,7,
			7,10,
			D_27D8^,bp_0a^,
			2,$ff
		);
		ShowMouse(FALSE);
		C_1918_0E60(
			bp_0a^,PTR($a000,0)^,
			7,10,
			_dstX,_dstY,
			0,0,
			320,7
		);
		ShowMouse(TRUE);
	END;
	{-- --}
BEGIN
	EMS2Pointer(Actors[2]^.f_emsPtr[1],D_27D8);
	GETMEM(bp_0a,$46);
	_i := 0;
	{-- --}
	FOR _i := 1 TO LENGTH(_str)
	DO INNER_PutCharAt(_str[_i],(_i - 1) * 7 + _x,_y);
	{-- --}
	_ch := ' ';
	REPEAT
		IF KEYPRESSED
		THEN BEGIN{else 069E}
			_ch := READKEY;
			IF _ch = #0
			THEN _ch := READKEY
			ELSE CASE _ch OF
				'A'..'Z','a'..'z','0'..'9',
				'(',')','.',',','-','!','"','?',' ','$',':': BEGIN
					IF _i < _maxLen
					THEN BEGIN{else 0609}
						FillRect(_i * 7 + _x + 1,_y + 6,6,2,1,PTR($a000,0)^,320);
						INC(_i);
						INNER_PutCharAt(_ch,(_i - 1) * 7 + _x,_y);
						_str := _str + _ch;
					END;
				END;
				#8: BEGIN
					IF _i > 0
					THEN BEGIN{else 069e}
						IF _i < _maxLen
						THEN FillRect(_i * 7 + _x + 1,_y + 6,6,2,1,PTR($a000,0)^,320);
						FillRect((_i - 1) * 7 + _x,_y,8,9,1,PTR($a000,0)^,320);
						DEC(_i);
						_str := COPY(_str,1,_i);
					END;
				END;
			END;
		END;
		{-- blinking cursor --}
		IF D_2A28 <> 0
		THEN BEGIN{else 071C}
			D_2A28 := 0;
			_cursorOn := NOT _cursorOn;
			IF _i < _maxLen
			THEN BEGIN{else 071C}
				IF _cursorOn
				THEN FillRect(_i * 7 + _x + 1,_y + 6,6,2,0,PTR($a000,0)^,320)
				ELSE FillRect(_i * 7 + _x + 1,_y + 6,6,2,1,PTR($a000,0)^,320)
			END;
		END;
		{-- --}
	UNTIL (_ch = #13) OR (_ch = #27);
	EditFilename := (_ch = #13);
	IF _i < _maxLen
	THEN FillRect(_i * 7 + _x + 1,_y + 6,6,2,1,PTR($a000,0)^,320);
	FREEMEM(bp_0a,$46);
END;

{C_0E7F_0858}PROCEDURE SaveGame(bp06:BYTE);
VAR
	bp_04:STRING[2];
	_f:FILE;
	_i:WORD;
	_buf:POINTER;
	_p:^BYTE;
	_word:INTEGER;
	_byte:BYTE;
	_j:BYTE;
	_title:STRING;
BEGIN
	STR(bp06 + D_2806 * 7 ,bp_04);
	IF LENGTH(bp_04) = 1
	THEN bp_04 := '0' + bp_04;
	ASSIGN(_f,D_0BC2 + 'SAVEGAME.V' + bp_04);
	_title[0] := #0;
	{$I-}RESET(_f,1);{$I+}
	IF IORESULT = 0
	THEN BEGIN{else 0965}
		BLOCKREAD(_f,_title,16);
		WHILE _title[LENGTH(_title)] = ' '
		DO _title := COPY(_title,1,LENGTH(_title) - 1);
		CLOSE(_f);
	END;
	IF EditFilename(58,bp06 * 10 + 46,15,_title)
	THEN BEGIN{else 0C3F}
		WHILE LENGTH(_title) < 15
		DO _title := _title + ' ';
		IF _title = '               '
		THEN _title := '-- untitled --';
		{$I-}
		REWRITE(_f,1);
		IF IORESULT <> 0
		THEN BEGIN{else 0A22}
			MenuRender;
			CASE Language OF
				0: DialogBox('WARNING:    CAN''T CREATE FILE !!!',[#13,#27,' ']);
				1: DialogBox('WARNUNG:  DATEI NICHT ANLEGBAR !!!',[#13,#27,' ']);
			END;
			EXIT;
		END;
		BLOCKWRITE(_f,_title,16);
		{-- state data --}
		_word := 100;{800 DIV 8}
		BLOCKWRITE(_f,_word,2);
		GETMEM(_buf,_word);
		_p := _buf;
		FOR _i := 0 TO (_word - 1)
		DO BEGIN
			_byte := 0;
			FOR _j := 1 TO 8
			DO BEGIN
				_byte := _byte SHL 1;
				_byte := _byte + State[_i * 8 + _j];
			END;
			_p^ := _byte;
			INC(_p);
		END;
		BLOCKWRITE(_f,_buf^,_word);
		FREEMEM(_buf,_word);
		{-- --}
		Save.f_x := Actors[1]^.f_aX[1];
		Save.f_y := Actors[1]^.f_aY[1];
		Save.f_mirrorX := Actors[1]^.f_mirrorX;
		Save.f_curFrame := Actors[1]^.f_curFrame;
		Save.f_scale := Actors[1]^.f_scale;
		Save.f_06 := D_27C9;
		Save.f_07 := tConfig(D_27BC);
		Save.f_0a := WORD(D_27C0);
		BLOCKWRITE(_f,Save,SIZEOF(tSave));
		{-- --}
		BLOCKWRITE(_f,ObjCount,1);
		FOR _i := 1 TO ObjCount
		DO BLOCKWRITE(_f,Inventory[_i]^,2);
		BLOCKWRITE(_f,D_27BC,3);
		CLOSE(_f);
		{$I+}
		IF IORESULT <> 0
		THEN BEGIN{else 0C3F}
			MenuRender;
			CASE Language OF
				0: DialogBox('WARNING: FILE WRITE ERROR      !!!',[#13,#27,' ']);
				1: DialogBox('WARNUNG: SCHREIBFEHLER         !!!',[#13,#27,' ']);
			END;
			EXIT;
		END;
	END;
	MenuRender;
END;

{C_0E7F_0C54}PROCEDURE LoadGame(bp06:BYTE);
VAR
	bp_04:STRING[2];
	_f:FILE;
	_word:WORD;
	_i:WORD;
	_buf:POINTER;
	_p:^BYTE;
	_j:BYTE;
	_byte:BYTE;
BEGIN
	STR(bp06,bp_04);
	IF LENGTH(bp_04) = 1
	THEN bp_04 := '0' + bp_04;
	ASSIGN(_f,D_0BC2 + 'SAVEGAME.V' + bp_04);
	{$I-}RESET(_f,1);{$I+}
	IF IORESULT <> 0
	THEN EXIT;
	SEEK(_f,16);
	{-- state data --}
	BLOCKREAD(_f,_word,2);
	GETMEM(_buf,_word);
	BLOCKREAD(_f,_buf^,_word);
	_p := _buf;
	FOR _i := 0 TO (_word - 1)
	DO BEGIN
		_byte := _p^;
		FOR _j := 8 DOWNTO 1
		DO BEGIN
			State[_i * 8 + _j] := _byte AND 1;
			_byte := _byte SHR 1;
		END;
		INC(_p);
	END;
	IF NOT IsRegistered
	THEN State[$cd] := 1
	ELSE State[$cd] := 0;
	FREEMEM(_buf,_word);
	{-- --}
	BLOCKREAD(_f,Save,SIZEOF(tSave));
	BLOCKREAD(_f,_byte,1);
	InventoryEmpty;
	D_2710 := 1;
	FOR _i := 1 TO _byte
	DO BEGIN
		BLOCKREAD(_f,_word,2);
		LoadObject(_word);
		InventoryAdd(_word,FALSE);
	END;
	CLOSE(_f);
	D_27C3 := TRUE;
	D_27C9 := Save.f_06;
	D_0CD1 := TRUE;
	CurSong := $81;
END;

{C_0E7F_0EBE}PROCEDURE MenuInit;
BEGIN
	IF Language = 0
	THEN RES_find('SAVE',RES_offset,RES_size)
	ELSE RES_find('SAVG',RES_offset,RES_size);
	LoadPCX(RES_handle,RES_size);
	EMSDoMapping(EMSHandle,8,0);
	EMSDoMapping(EMSHandle,9,1);
	D_27D8 := PTR(EMSSegment,0);
	C_1918_1825(
		0,0,320,
		0,0,243,
		243,$77,
		PTR($a000,0)^,D_27D8^
	);
	GETMEM(D_0CC8,$1c);
	C_1918_1825(
		243,0,320,
		0,0,4,
		4,7,
		PTR($a000,0)^,D_0CC8^
	);
	GETMEM(D_0CC4,$1e);
	C_1918_1825(
		243,7,320,
		0,0,6,
		6,5,
		PTR($a000,0)^,D_0CC4^
	);
END;

{C_0E7F_0FBC}PROCEDURE MenuClean;
BEGIN
	FREEMEM(D_0CC8,$1b);{note:should be $1c}
	FREEMEM(D_0CC4,$1e);
END;

{C_0FE6}PROCEDURE HighlightItem(bp04:BYTE);
VAR _x,_y,_width,_height:INTEGER;
BEGIN
	_x := D_00CE[bp04][0];
	_y := D_00CE[bp04][1];
	_width := D_00CE[bp04][2] - _x;
	_height := D_00CE[bp04][3] - _y;
	ShowMouse(FALSE);
	C_1918_1878(
		_x + 30,_y + 30,320,
		_x + 30,_y + 30,320,
		_width,_height,
		PTR($a000,0)^,PTR($a000,0)^,
		9,1
	);
	ShowMouse(TRUE);
END;

{C_1092}PROCEDURE LowlightItem(bp04:BYTE);
VAR _x,_y,_width,_height:INTEGER;
BEGIN
	_x := D_00CE[bp04][0];
	_y := D_00CE[bp04][1];
	_width := D_00CE[bp04][2] - _x;
	_height := D_00CE[bp04][3] - _y;
	ShowMouse(FALSE);
	C_1918_1878(
		_x + 30,_y + 30,320,
		_x + 30,_y + 30,320,
		_width,_height,
		PTR($a000,0)^,PTR($a000,0)^,
		1,9
	);
	ShowMouse(TRUE);
END;

{C_113E}PROCEDURE UpdateGauge(bp04:BYTE);
VAR
	_mouseY:INTEGER;
	_prevY:INTEGER;
BEGIN
	ShowMouse(FALSE);
	_prevY := ROUND(((100 - D_27C0[bp04 - $a]) / 100.0) * 54.0) + $3e;
	REPEAT
		GetMouseXY(MenuX,_mouseY);
		IF _mouseY < $3e
		THEN _mouseY := $3e;
		IF _mouseY > $73
		THEN _mouseY := $73;
		IF _mouseY <> _prevY
		THEN BEGIN{else 130B}
			EMSDoMapping(EMSHandle,8,0);
			EMSDoMapping(EMSHandle,9,1);
			D_27D8 := PTR(EMSSegment,0);
			IF _prevY > 0
			THEN C_1918_1825(
				D_00CE[bp04][0] + 8,_prevY - 30,243,
				D_00CE[bp04][0] + 8 + 30,_prevY,320,
				4,7,
				D_27D8^,PTR($a000,0)^
			);
			C_1918_1825(
				0,0,4,
				D_00CE[bp04][0] + 8 + 30,_mouseY,320,
				4,7,
				D_0CC8^,PTR($a000,0)^
			);
			_prevY := _mouseY;
			{-- refresh sound volume --}
			IF bp04 = $b
			THEN BEGIN{else 130B}
				D_27C0[bp04 - $a] := ROUND(100.0 - ((_mouseY - $3e) / 54.0) * 100.0);
				MUSIC_setVolumes(ROUND((D_27C0[1] / 100.0) * 255.0),$ff);
			END;
			{-- --}
		END;
	UNTIL MOUSE_getButtons = 0;
	D_27C0[bp04 - $a] := ROUND(100.0 - ((_mouseY - $3e) / 54.0) * 100.0);
	ShowMouse(TRUE);
END;

{C_137D}PROCEDURE RenderFileList;
VAR
	bp_04:STRING[2];
	bpff7c:FILE;
	__ff7a:WORD;
	bpff78:WORD;
	_title:STRING[$18];
BEGIN
	EMSDoMapping(EMSHandle,8,0);
	EMSDoMapping(EMSHandle,9,1);
	D_27D8 := PTR(EMSSegment,0);
	ShowMouse(FALSE);
	C_1918_1825(
		5,25,243,
		35,55,320,
		131,73,
		D_27D8^,PTR($a000,0)^
	);
	ShowMouse(TRUE);
	FOR bpff78 := 1 TO 7
	DO BEGIN
		STR(D_2806 * 7 + bpff78,bp_04);
		IF LENGTH(bp_04) = 1
		THEN bp_04 := '0' + bp_04;
		ASSIGN(bpff7c,D_0BC2 + 'SAVEGAME.V' + bp_04);
		PutString_2(bp_04,38,bpff78 * 10 + 46);
		{$I-}RESET(bpff7c,1);{$I+}
		IF IORESULT = 0
		THEN BEGIN{else 14D9}
			BLOCKREAD(bpff7c,_title,16);
			PutString_2(_title,58,bpff78 * 10 + 46);
			CLOSE(bpff7c);
		END;
	END;
END;

{file list for load}
PROCEDURE C_14E5;
BEGIN
	RenderFileList;
	D_0CD0 := 2;
END;

{file list for save}
PROCEDURE C_14F9;
BEGIN
	RenderFileList;
	D_0CD0 := 1;
END;

{C_0E7F_150D}FUNCTION DialogBox(_str:STRING; bp06:tSetOfChar):CHAR;
VAR bpfedd:CHAR;
BEGIN
	{-- backup screen --}
	EMSStart_00;
	D_27D8 := PTR(EMSSegment,$EA6A);
	ShowMouse(FALSE);
	C_1918_1825(
		38,65,320,
		0,0,243,
		243,16,
		PTR($a000,0)^,D_27D8^
	);
	{-- --}
	EMSDoMapping(EMSHandle,9,0);
	C_1918_1825(
		$21c5,0,243,
		38,65,320,
		243,16,
		PTR(EMSSegment,0)^,PTR($a000,0)^
	);
	PutString_2(_str,$2a,$44);
	REPEAT
		bpfedd := READKEY;
		bpfedd := UPCASE(bpfedd);
	UNTIL bpfedd IN bp06;
	DialogBox := bpfedd;
	{-- restore screen --}
	EMSStart_00;
	D_27D8 := PTR(EMSSegment,$EA6A);
	ShowMouse(FALSE);
	C_1918_1825(
		0,0,243,
		38,65,320,
		243,16,
		D_27D8^,PTR($a000,0)^
	);
	{-- --}
	ShowMouse(TRUE);
	D_27D8 := PTR(EMSSegment,0);
END;

{C_0E7F_16B0}PROCEDURE GameMenu;
VAR
	bp_01:BOOLEAN;
	_p___:ARRAY[1..$102] OF BYTE;
BEGIN
	{-- backup screen --}
	EMSStart_00;
	D_27D8 := PTR(EMSSegment,0);
	ShowMouse(FALSE);
	C_1918_1825(
		30,30,320,
		0,0,243,
		243,103,
		PTR($a000,0)^,D_27D8^
	);
	ShowMouse(TRUE);
	{-- --}
	D_0CD0 := 0;
	D_0CD1 := FALSE;
	MenuRender;
	bp_01 := FALSE;
	D_0CC3 := 0;
	D_0CC2 := 0;
	REPEAT
		IF KEYPRESSED AND (READKEY = #27)
		THEN D_0CD1 := TRUE;
		GetMouseXY(MenuX,MenuY);
		MenuX := ROUND(MenuX / 2.0);
		D_0CC3 := _MenuItemAt(MenuX - 30,MenuY - 30);
		{-- hilight item --}
		IF D_0CC3 <> D_0CC2
		THEN BEGIN
			IF D_0CC2 > 0
			THEN LowlightItem(D_0CC2);
			IF D_0CC3 > 0
			THEN HighlightItem(D_0CC3);
			D_0CC2 := D_0CC3;
		END;
		{-- --}
		IF MOUSE_getButtons = 1
		THEN BEGIN{else 191D}
			IF NOT bp_01
			THEN BEGIN{else 191B}
				bp_01 := TRUE;
				CASE D_0CC3 OF
					8..$a{checkboxes}: BEGIN
						D_27BC[D_0CC3 - 7] := (NOT D_27BC[D_0CC3 - 7]);
						ShowMouse(FALSE);
						RenderCheckbox(D_0CC3,D_27BC[D_0CC3 - 7]);
						ShowMouse(TRUE);
						HighlightItem(D_0CC3);
						{-- music,sound --}
						IF D_0CC3 < $a
						THEN UpdateSoundFlags;
						{-- --}
					END;
					$b..$c{gauges}: UpdateGauge(D_0CC3);
					5{quit}: BEGIN
						D_27CB := TRUE;
						D_27C9 := 0;
						D_0CD1 := TRUE;
					END;
					3{play}: D_0CD1 := TRUE;
					2{load}: C_14E5;
					1{save}: BEGIN
						IF NOT D_0179
						THEN BEGIN
							C_14F9
						END ELSE BEGIN
							IF Language = 0
{$IFDEF FRENCH}
							THEN DialogBox('Tu ne peux pas sauver ici !',[#13,#27,' '])
{$ELSE}
							THEN DialogBox('Sorry, you can''t save here!',[#13,#27,' '])
{$ENDIF}
							ELSE DialogBox('Hier kann man nicht speichern!',[#13,#27,' ']);
						END;
					END;
					4{restart}: BEGIN
						C_0E7F_004E;
						D_0CD1 := TRUE;
					END;
					$d..$13{file}: BEGIN
						CASE D_0CD0 OF
							2: LoadGame(D_0CC3 - $c + D_2806 * 7);
							1: SaveGame(D_0CC3 - $c);
						END;
					END;
					7{scroll list down}: BEGIN
						IF (D_0CD0 > 0) AND (D_2806 < $d)
						THEN BEGIN
							INC(D_2806);
							RenderFileList;
						END;
					END;
					6{scroll list up}: BEGIN
						IF (D_0CD0 > 0) AND (D_2806 > 0)
						THEN BEGIN
							DEC(D_2806);
							RenderFileList;
						END;
					END;
				END;
			END;
			{goto 1921}
		END ELSE BEGIN
			bp_01 := FALSE;
		END;
	UNTIL D_0CD1;
	{-- restore screen --}
	EMSStart_00;
	D_27D8 := PTR(EMSSegment,0);
	ShowMouse(FALSE);
	C_1918_1825(
		0,0,243,
		30,30,320,
		243,103,
		D_27D8^,PTR($a000,0)^
	);
	ShowMouse(TRUE);
	{-- --}
END;

BEGIN
	FILLCHAR(D_27BC,3,1);
END.
