(*
Escape From Delirium 
	by Virtual X-Perience 1995
	decompiled by ergonomy_joe in 2019
*)
{$G+}
UNIT C_16C2;

INTERFACE
PROCEDURE C_16C2_0000(_p08:STRING; bp06:BYTE);
PROCEDURE C_16C2_00E8(bp08:STRING; bp06:BYTE);

IMPLEMENTATION

USES
	DOS,
	BSS;

PROCEDURE C_16C2_0000(_p08:STRING; bp06:BYTE);
VAR _size:LONGINT;
BEGIN
	SEEK(RES_handle,D_2C7E + HeadR.f_scriptOfs + (bp06 - 1) SHL 2 + 1);
	BLOCKREAD(RES_handle,_size,4);
	SEEK(RES_handle,D_2C7E + HeadR.f_scriptOfs + _size);
	BLOCKREAD(RES_handle,D_1A56,2);
	GETMEM(D_1A52,D_1A56);
	BLOCKREAD(RES_handle,D_1A52^,D_1A56);
END;

PROCEDURE C_16C2_00E8(bp08:STRING; bp06:BYTE);
VAR bpfefc:^BYTE;
BEGIN
	C_16C2_0000(bp08,bp06);
	D_1A84 := 1;
	D_2808 := TRUE;
	D_1A5E := D_1A56;
	PScriptTop := D_1A52;
	D_1A78 := PScriptTop;
	PScriptCur := PScriptTop;

	bpfefc := PScriptTop;
	INC(bpfefc,D_1A5E);
	PScriptEnd := bpfefc;

	D_1A80 := PScriptEnd;
	D_1A7C := PScriptCur;
	D_27CC := 0;
END;


END.
