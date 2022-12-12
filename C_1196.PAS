(*
Escape From Delirium 
	by Virtual X-Perience 1995
	decompiled by ergonomy_joe in 2019
*)
{$G+}
UNIT C_1196;{shareware commercial}

INTERFACE
PROCEDURE C_1196_009D(bp06:STRING);

IMPLEMENTATION

USES
	C_11B0,
	C_1918,
	C_1DD9,
	BSS;

PROCEDURE C_0000(_x,_y:WORD);
VAR
	_width,_height:WORD;
	_____:ARRAY[1..$142] OF BYTE;
BEGIN
	BLOCKREAD(RES_handle,_width,2);
	BLOCKREAD(RES_handle,_height,2);
	EMSStart_00;
	D_27D8 := PTR(EMSSegment,0);
	BLOCKREAD(RES_handle,D_27D8^,_width * _height);
	C_1918_0E19(D_27D8^,PTR($a000,0)^,_width,_height - 1,_x,_y,320);
END;

{parse IN/GE resource}
PROCEDURE C_1196_009D(bp06:STRING);
BEGIN
	RES_find(bp06,D_2770,D_2774);
	D_0CEC := 0;
	WHILE D_0CEC < D_2774
	DO BEGIN
		BLOCKREAD(RES_handle,D_0DF4,SIZEOF(t59));
		D_0CEC := SIZEOF(t59) + D_0CEC + D_0DF4.f_57;
		IF D_0DF4.f_01 <> 0
		THEN BEGIN
			CASE D_0DF4.f_00 OF
				2: C_11B0_00A9(D_0DF4.f_02,D_0DF4.f_53,D_0DF4.f_55);
				1: C_0000(D_0DF4.f_53,D_0DF4.f_55);
			END;
		END ELSE BEGIN
			SEEK(RES_handle,FILEPOS(RES_handle) + D_0DF4.f_57);
		END;
	END;
END;

END.
