(*
Escape From Delirium 
	by Virtual X-Perience 1995
	decompiled by ergonomy_joe in 2019
*)
{$G+}
{$X+}
UNIT C_0C16;{manage R files}

INTERFACE

{C_0C16_0000}PROCEDURE R_init;
{C_0C16_012A}PROCEDURE R_start;
{C_0C16_018F}PROCEDURE R_execute;
{C_0C16_0667}PROCEDURE R_end;

IMPLEMENTATION

USES
	C_1E02,
	C_1DD9,
	C_1D8E,
	C_1D7C,
	C_1918,
	C_18B8,
	C_183E,
	C_16C2,
	C_14C8,
	C_149C,
	C_1031,
	C_1018,
	C_0C8B,
	BSS;

{C_0C16_0000}PROCEDURE R_init;
BEGIN
	D_27E8 := CurEMSPage;
	D_27EE := CurEMSOffset;
END;

{parse resources A}
{C_001A}PROCEDURE C_001A;
VAR _dummy:ARRAY[1..$82] OF BYTE;
BEGIN
	CurEMSPage := D_27E8;
	CurEMSOffset := D_27EE;
	D_0491 := BufferFetchByte(D_27E0);
	D_2946 := 3;
	FOR D_046E := 4 TO (D_0491 + 2)
	DO BEGIN
		ParseResourceA('-');
		WITH Actors[D_046E]^
		DO BEGIN
			f_prevFrame := 0;
			f_curFrame := 0;
			f_aWidth[0] := 2; f_aWidth[1] := 1;
			f_aHeight[0] := 2; f_aHeight[1] := 1;
			f_aX[1] := 160; f_aY[1] := 100;
			f_aX[0] := 160; f_aY[0] := 100;
			f_delay := 0;
			f_fb := TRUE;
			f_fc := FALSE;
			f_scale := $ff;
			f_mirrorX := FALSE;
		END;
	END;
END;

{C_0C16_012A}PROCEDURE R_start;
BEGIN
	RES_find('R' + D_27C4,D_2C7E,D_2C82);
	BLOCKREAD(RES_handle,HeadR,SIZEOF(tHeadR));
	IF HeadR.f_songId = 0
	THEN HeadR.f_songId := CurSong;
END;

{C_0C16_018F}PROCEDURE R_execute;
VAR
	bp_0e:STRING[$c];
	bp_0f:BYTE;
BEGIN
	D_0496 := FALSE;
	LoadPCX(RES_handle,HeadR.f_pcxSize);
	EMSStart_00;
	D_27E0 := PTR(EMSSegment,0);
	BLOCKREAD(RES_handle,D_27E0^,HeadR.f_soundCount + HeadR.f_ASize);
	{-- load music/sound files --}
	D_2C82 := FILEPOS(RES_handle);
	IF (HeadR.f_songId <> CurSong) AND (CurSong <> $80)
	THEN BEGIN{else 034C}
		{-- --}
		IF CurSong <> 0
		THEN BEGIN
			TIMER_stop;
			MUSIC_stopSong;
		END;
		STR(HeadR.f_songId,bp_0e);
		RES_find('S' + bp_0e,RES_offset,RES_size);
		MUSIC_loadSong(@RES_handle,ROUND(D_27C0[1] / 100.0 * 255.0));
		{-- --}
		SFXCount := HeadR.f_soundCount;
		FOR D_046E := 1 TO HeadR.f_soundCount
		DO BEGIN
			EMSDoMapping(EMSHandle,0,0);
			bp_0f := BufferFetchByte(D_27E0);
			STR(bp_0f,bp_0e);
			RES_find('E' + bp_0e,RES_offset,RES_size);
			ASFXHandle[D_046E] := MUSIC_loadSFX(@RES_handle,RES_size);
		END;
		{-- --}
		MUSIC_playSong;
		TIMER_start;
		CurSong := HeadR.f_songId;
	END ELSE BEGIN
		FOR D_046E := 1 TO HeadR.f_soundCount
		DO BufferFetchByte(D_27E0);
	END;
	SEEK(RES_handle,D_2C82);
	{-- --}
	EMSStart_00;
	C_001A;{parse resources A}
	WITH Actors[2]^
	DO BEGIN
		f_curFrame := 0;
		f_aX[1] := 160; f_aY[1] := 1;
		f_aWidth[1] := 1; f_aHeight[1] := 1;
	END;
	C_18B8_0000(D_27C4);
	ZoneLinkParse(D_27C4);
	{-- --}
	ShowMouse(FALSE);
	C_1918_0C92;
	C_1918_1369(D_27C4);
	ShowMouse(TRUE);
	PlayerIsMoving := FALSE;
	D_0478 := -1;
	D_047A := -1;
	Actors[1]^.f_fb := TRUE;
	D_1A52 := nil;
	D_27CB := FALSE;
	D_1A84 := 0;
	IF D_27C3
	THEN BEGIN
		Actors[1]^.f_aX[1] := Save.f_x;
		Actors[1]^.f_aY[1] := Save.f_y;
		Actors[1]^.f_curFrame := Save.f_curFrame;
		Actors[1]^.f_scale := Save.f_scale;
		Actors[1]^.f_mirrorX := Save.f_mirrorX;
		D_27BC[3] := Save.f_07.f_02;
		D_27C3 := FALSE;
		D_025E := FALSE;
		D_0176 := FALSE;
	END ELSE BEGIN
		C_16C2_00E8(D_27C4,D_27CA);
		C_1031_1391;
	END;
	RefreshAllStates;
	WITH Actors[1]^
	DO WITH Zones[FindZoneAt(f_aX[1],f_aY[1])]^
	DO BEGIN
		{-- --}
		IF f_type = 2{set state}
		THEN BEGIN
			State[f_stateId] := 1;
			RefreshState(f_stateId);
		END ELSE IF Zones[D_1A37]^.f_type = 3{reset state}
		THEN BEGIN
			State[f_stateId] := 0;
			RefreshState(f_stateId);
		END;
		{-- --}
		IF ff_scale = 0
		THEN f_scale := Scale(f_aY[1],f_top,f_bottom,HI(f_stateId),LO(f_stateId))
		ELSE f_scale := ff_scale;
		{-- --}
	END;
	C_1918_0D50(1);
	WITH Actors[1]^
	DO BEGIN
		f_aWidth[0] := 1; f_aHeight[0] := 1;
		f_aX[0] := f_aX[1]; f_aY[0] := f_aY[1];
		f_delay := 0;
		f_fc := FALSE;
	END;
	IF D_27C2
	THEN BEGIN
		EMSStart_13;
		ShowMouse(FALSE);
		FastMove(PTR($a000,0)^,PTR(EMSSegment,0)^,$fa00);
		ShowMouse(TRUE);
	END;
	C_1031_14F5;
	{-- --}
	C_1918_2A16;
	IF D_27D6 > 0
	THEN FOR D_046E := 1 TO D_27D6
	DO C_1918_1BB1(D_046E);
	{-- --}
	IF NOT D_025E
	THEN BEGIN
		C_0C8B_02C0;
		C_1918_34BC(D_27D8);
		InventoryRender;
	END;
	IF D_0170 = 0
	THEN SetPCXPalette
	ELSE D_0170 := 0;
	C_0C8B_11A2;
END;

{C_0C16_0667}PROCEDURE R_end;
BEGIN
	STR(D_27C9,D_27C4);
	IF D_27C9 <> 0
	THEN R_start
	ELSE HeadR.f_songId := 0;
	ShowMouse(FALSE);
	IF NOT D_0176
	THEN BEGIN
		ShrinkTransition(D_27C0[1]);
	END ELSE IF (HeadR.f_songId <> CurSong) AND (CurSong <> $80)
	THEN BEGIN{else 071D}
		FOR D_046E := 10 DOWNTO 1
		DO BEGIN
			D_0470 := ROUND((25 * D_046E) * D_27C0[1] / 100.0);
			MUSIC_setVolumes(D_0470,D_0470);
			WHILE D_2A28 = 0
			DO;
			D_2A28 := 0;
		END;
	END;
	D_0176 := D_025E;
	ZoneLinkRelease;
	C_18B8_00B4;
	C_1918_15EB;
	C_1918_15AD;
END;

{C_0C16_0739}
BEGIN
	CurSong := 0;
END.
