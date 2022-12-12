(*
Escape From Delirium 
	by Virtual X-Perience 1995
	decompiled by ergonomy_joe in 2019
*)
{$S-}
{$G+}
{$X+}
PROGRAM DELIRIUM;

USES
	CRT,DOS,GRAPH,
	C_1E06,{EMS}
	C_1E02,{FastMove}
	C_1DD9,{resources}
	C_1D8E,{musix/sfx}
	C_1D7C,{Timer}
	C_1918,
	C_18DC,{some mouse functions}
	C_18B8,
	C_183E,{inventory?}
	C_1765,{conversations?}
	C_1751,
	C_16DC,
	C_16C2,
	C_14C8,{movement?}
	C_149C,{PCX}
	C_11B0,{helper for C_1196}
	C_1196,{shareware commercial}
	C_1031,{scene script?}
	C_1018,
	C_0E7F,{game menu}
	C_0E65,{palette animation}
	C_0E4C,{helper for ending credits}
	C_0C8B,
	C_0C16,{manage R files}
	C_0BFF,{helper for ending credits}
	C_0BD2,{ending credits}
	BSS;

PROCEDURE CB_0AB7_00C7;
	{-- make 2 digit hex string --}
	FUNCTION INNER_0000(bbp06:BYTE):STRING;
	CONST D_0002:ARRAY[0..$f] OF CHAR = '0123456789ABCDEF';
	BEGIN
		INNER_0000 := D_0002[bbp06 SHR 4] + D_0002[bbp06 AND $f];
	END;
	{-- make 4 digit hex string --}
	FUNCTION INNER_004D(bbp06:INTEGER):STRING;
	BEGIN
		INNER_004D := INNER_0000(bbp06 SHR 8) + INNER_0000(bbp06 AND $ff);
	END;
	{-- --}
BEGIN
	C_1918_0124;{"Error-Handler"?}
	IF ExitCode <> $ff
	THEN BEGIN
		WRITELN('Fehlernummer : ',ExitCode);
		WRITELN('Fehleradresse: ',INNER_004D(SEG(ErrorAddr^)),':',INNER_004D(OFS(ErrorAddr^)),#10);
	END ELSE BEGIN
		WRITELN(D_2AF6,#10#13,'or EMS-Mapping failed'#10);
	END;
	HALT(ExitCode);
END;

{C_019D}PROCEDURE _Error(bp04:STRING);
BEGIN
	WRITELN(#10 + bp04 + #10);
	ExitProc := D_288A;
	HALT;
END;

{C_0307}PROCEDURE _ParseSoundCfg;
CONST
	D_0012:ARRAY[0..9] OF BYTE = (2,2,5,3,4,4,1,1,0,0);
	D_001C:ARRAY[0..7] OF BYTE = (2,3,5,7,10,11,12,0);{IRQ}
	D_0024:ARRAY[0..5] OF BYTE = (0,1,3,5,6,7);{DMA channel}
	D_002A:ARRAY[0..14] OF INTEGER = (
		$210,$220,$230,$240,$250,$260,$270,$280,$388,$384,$38C,$288,$280,$284,$28C
	);{PORT}
	D_0048:ARRAY[0..4] OF WORD = (11000,16000,22222,33333,44100);{rate}
VAR
	bp_04:LONGINT;
	bp_10:ARRAY[0..5] OF INTEGER;
	bp_11:BYTE;
	bp___:ARRAY[0..$a1] OF BYTE;
	_regs:REGISTERS;
BEGIN
	bp_11 := 0;
	{-- --}
	ASSIGN(D_280A,D_02E4);
	{$I-}RESET(D_280A,1);{$I+}
	IF IORESULT <> 0
	THEN BEGIN
		C_1918_01D8(
			#$FE' Please run SETUP.EXE to set your sound configuration!'#10#13+
			#$FE' Please make sure, your -CFG: parameter is set correct!'
		);
	END ELSE BEGIN
		WRITELN('... reading SOUND.CFG: ');
	END;
	SEEK(D_280A,$9d);
	BLOCKREAD(D_280A,bp_10,$c);
	CLOSE(D_280A);
	{-- --}
	Language := bp_10[5];
	D_2A38 := D_0012[bp_10[0]];
	D_2A3A := D_0024[bp_10[1]];
	D_2A39 := D_001C[bp_10[2]];
	D_2A3C := D_002A[bp_10[3]];
	D_028C := D_0048[bp_10[4]];
	CASE D_2A38 OF
		0: bp_04 := 0;
		1: bp_04 := $e;
		2,3,4,5: bp_04 := $145;
	END;
	{-- check available memory --}
	_regs.AH := $48;{alloc memory}
	_regs.BX := bp_04 * $40;
	INTR($21,_regs);
	IF (_regs.Flags AND 1) = 1
	THEN BEGIN
		_Error(
			'Not enough free memory! Try optimizing your systems conventional'#10#13+
			'memory or try running with no music/sound enabled!'
		);
	END ELSE BEGIN
		_regs.ES := _regs.AX;
		_regs.AH := $49;{free memory}
		INTR($21,_regs);
	END;
	{-- --}
END;

{C_0490}PROCEDURE _InitMusic;
BEGIN
	_ParseSoundCfg;
	WRITELN('... loading and initialising music-player');
	MUSIC_init;
	MUSIC_setVolumes($ff,$ff);
END;

{C_04C1}PROCEDURE _StopMusic;
BEGIN
	MUSIC_stopSong;
	MUSIC_clean;
END;

{init "A1" "A2" "A3"?}
PROCEDURE C_04D2;
BEGIN
	D_2946 := 0;
	FOR D_03E4 := 1 TO 3
	DO BEGIN
		STR(D_03E4,D_0402);
		IF D_03E4 <> 3
		THEN BEGIN
			ParseResourceA('A' + D_0402);
		END ELSE BEGIN
			INC(D_2946);
			NEW(Actors[D_2946]);
		END;
		WITH Actors[D_03E4]^
		DO BEGIN
			f_pData := nil;
			f_prevFrame := 0;
			f_curFrame := 0;
			f_aWidth[0] := 1; f_aWidth[1] := 1;
			f_aHeight[0] := 1; f_aHeight[1] := 1;
			f_aX[1] := 160; f_aY[1] := 144;
			f_aX[0] := f_aX[1]; f_aY[0] := f_aY[1];
			f_delay := 0;
			f_fb := FALSE;
			f_fc := FALSE;
			f_mirrorX := FALSE;
		END;
	END;
END;

{C_0627}PROCEDURE _InitResources;
VAR
	_lastSecSz:WORD;
	_secCnt:WORD;
	_dummy:ARRAY[1..$80] OF BYTE;
BEGIN
	ASSIGN(RES_handle,PARAMSTR(0));
	RESET(RES_handle,1);
	D_02D8 := FILESIZE(RES_handle);
	{-- skip to relocation entries --}
	SEEK(RES_handle,$1c);
	{-- # of relocation entries --}
	BLOCKREAD(RES_handle,D_02E0,4);
	{-- --}
	SEEK(RES_handle,2);
	{-- last sector size --}
	BLOCKREAD(RES_handle,_lastSecSz,2);
	{-- # sectors --}
	BLOCKREAD(RES_handle,_secCnt,2);
	{-- compute exe size-> VX file offset --}
	IF _lastSecSz <> 0
	THEN D_2C8C := (LONGINT(_secCnt) * $200) + LONGINT(_lastSecSz) - $200
	ELSE D_2C8C := LONGINT(_secCnt) * $200 + LONGINT(_lastSecSz);
	{-- --}
	IF FILESIZE(RES_handle) <= D_2C8C
	THEN BEGIN{else 0795}
		{-- open "delirium.vx" --}
		D_2C8C := 0;
		CLOSE(RES_handle);
		ASSIGN(RES_handle,'delirium.vx');
		{$I-}RESET(RES_handle,1);{$I+}
		IF IORESULT <> 0
		THEN C_1918_01D8('Maindatafile DELIRIUM.VX not found.');
	END ELSE BEGIN
		{-- archive is at the end of exe --}
		SEEK(RES_handle,D_2C8C);
	END;
END;

{C_08C3}PROCEDURE _ParseCommandLine;
VAR
	bpff00:STRING;
	bpfed4:SEARCHREC;
BEGIN
	IsRegistered := TRUE;
	D_0BC2[0] := #0;
	D_02E4 := 'sound.cfg';
	FOR D_03E4 := 1 TO PARAMCOUNT
	DO BEGIN
		bpff00 := PARAMSTR(D_03E4);
		FOR D_03E6 := 1 TO LENGTH(bpff00)
		DO bpff00[D_03E6] := UPCASE(bpff00[D_03E6]);
		IF bpff00 = '-DIFFICULT'
		THEN BEGIN
			IsDifficult := TRUE;
		END ELSE IF bpff00 = '-BW'
		THEN BEGIN
			IsBW := TRUE;
		END ELSE IF COPY(bpff00,1,6) = '-SDIR:'
		THEN BEGIN{else 0A6C}
			D_0BC2 := COPY(bpff00,7,LENGTH(bpff00) - 6);
			IF D_0BC2[LENGTH(D_0BC2)] <> '\'
			THEN D_0BC2 := D_0BC2 + '\';
			bpfed4.Name[0] := #0;
			FINDFIRST(D_0BC2 + '.',DIRECTORY,bpfed4);
			IF bpfed4.Name[0] = #0
			THEN _Error('SAVE-GAME directory (' + D_0BC2 + ') not valid!');
		END ELSE IF COPY(bpff00,1,5) = '-CFG:'
		THEN BEGIN
			D_02E4 := COPY(bpff00,6,LENGTH(bpff00) - 5);
		END ELSE BEGIN
			TEXTBACKGROUND(0);
			TEXTCOLOR(7);
			CLRSCR;
			_Error(
				'ESCAPE FROM DELIRIUM!'#10#10#13+
				'  DELIRIUM.EXE [options] [-CFG:Path+Filename] [-SDIR:Path]'#10#13+
				'    Options: -BW  use black-white-mode'#10#13+
				'    -CFG   : Path to config-file+filename'#10#13+
				'    -SDIR  : Path to savegames'#10#13
			);
		END;
	END;
END;

{load TXT[E|G] resource?}
PROCEDURE C_0B95;
	{-- parse one string? --}
	PROCEDURE INNER_0AE5(VAR bbp06:STRING_3C);
	VAR
		bbp_04:LONGINT;
		bbp_05:BYTE;
	BEGIN
		bbp_04 := FILEPOS(RES_handle);
		bbp06[0] := #$3c;
		BLOCKREAD(RES_handle,PTR(SEG(bbp06[1]),OFS(bbp06[1]))^,SIZEOF(bbp06) + 1);
		bbp_05 := POS(#13#10,bbp06);
		bbp06 := COPY(bbp06,1,bbp_05 - 1);
		SEEK(RES_handle,bbp_05 + bbp_04 + 1);
	END;
	{-- --}
BEGIN
	IF Language = 0
	THEN RES_find('TXTE',RES_offset,RES_size)
	ELSE RES_find('TXTG',RES_offset,RES_size);
	FOR D_03E4 := 1 TO 6
	DO FOR D_03E6 := 1 TO 5
	DO INNER_0AE5(D_1A88[D_03E4][D_03E6]);
END;

{main}
BEGIN
	FILEMODE := 0;
	CHECKBREAK := FALSE;
	MARK(D_288E);
	D_288A := ExitProc;
	ExitProc := @CB_0AB7_00C7;
	D_0BB2 := $B0;
	D_0BB3 := $BF;
	D_0BB4 := $B0;
	RANDOMIZE;
	IsDifficult := FALSE;
	IsBW := FALSE;
	D_27C2 := FALSE;
	Language := 0;
	CLRSCR;
	WRITELN('<<VIRTUAL X-PERIENCE>>');
	WRITELN('Loading ESCAPE FROM DELIRIUM:');
	WRITELN;
	{-- --}
	D_27CB := C_1918_005A;{mouse:start/detect?}
	IF NOT D_27CB
	THEN _Error(
		'Sorry, this game needs a mouse. Please make sure, your'#10#13+
		'mouse is connected to your PC and the driver ist loaded'#10#13+
		'into memory.'#10#13+
		'>> Please consult READ.ME for additional help. <<'
	);
	{-- --}
	_ParseCommandLine;
	{-- --}
	WRITELN('... getting EMS-Pages');
	StartEMS;
	{-- --}
	_InitResources;
	RES_start;
	_InitMusic;
	C_0B95;{load TXT[E|G] resource?}
	{-- --}
	WRITELN('... installing new INT 08h');
	{...?}
	{-- --}
	WRITELN('... switching to graphics-mode');
	ASM
		MOV	AX,$0013
		INT	$10
	END;
	{-- --}
	MOUSE_setRange(0,0,639,199);
	MOUSE_start;
	SetMouseImage(@D_0172,2,2,1,1);
	ShowMouse(FALSE);
	InventoryInit;
	InventoryLoadIcon;
	C_1031_0113;
	ObjCount := 0;
	D_27C9 := 93;{first scene}
	D_27CA := 1;
	D_27C3 := FALSE;
	D_27C0[1] := 93;{volume}
	D_27C0[2] := 65;{text speed}
	D_2806 := 0;
	D_03F2 := MEMAVAIL;
	C_0C8B_0261;
	MenuInit;
	C_04D2;{init "A1" "A2" "A3"?}
	R_init;
	D_27C4 := '93';{first scene}
	R_start;
	D_0CD6 := $ff;
	{---------------}
	{-- game loop --}
	REPEAT
		R_execute;
		R_end;
	UNTIL D_27C9 = 0;
	{--   --}
	{-------}
	FOR D_03E4 := ObjCount DOWNTO 1
	DO DISPOSE(Inventory[D_03E4]);
	ReleaseObject;
	D_0408 := MEMAVAIL;
	MOUSE_stop;
	IF CurSong <> 0
	THEN BEGIN
		TIMER_stop;
		MUSIC_stopSong;
	END;
	RES_find('S11',RES_offset,RES_size);
	MUSIC_loadSong(@RES_handle,ROUND((D_27C0[1] / 100.0) * 255.0));
	MUSIC_playSong;
	TIMER_start;
	{-- --}
	IF NOT IsRegistered
	THEN BEGIN
		IF Language = 0
		THEN RES_find('LE',RES_offset,RES_size)
		ELSE RES_find('LG',RES_offset,RES_size)
	END;
	{-- --}
	EndingCredits;
	{-- --}
	C_149C_0000(3);
	{-- --}
	IF NOT IsRegistered
	THEN SEEK(RES_handle,RES_offset);
	{-- --}
	TEXTCOLOR(LIGHTGRAY);
	TEXTBACKGROUND(BLACK);
	CLRSCR;
	{-- --}
	IF NOT IsRegistered
	THEN BEGIN
		{-- shareware version --}
		BLOCKREAD(RES_handle,PTR($B800,0)^,$1f40);
		GOTOXY(1,24);
	END ELSE BEGIN
		{-- registered version --}
		WRITELN(
			'Escape from Delirium!'#10#13+
			'Copyright ViRTUAL X-PERIENCE!'#10#13,
			'THIS GAME IS REGISTERED!!!'#10#13,
			'DISTRIBUTION IS STRICTLY FORBIDDEN!'#10
		);
	END;
	{-- --}
	MenuClean;
	TIMER_stop;
	_StopMusic;
	InventoryClean;
	{-- --}
	WHILE KEYPRESSED
	DO READKEY;
	{-- --}
	StopEMS;
	CLOSE(RES_handle);
	{-- --}
	EXITPROC := D_288A;
END.
