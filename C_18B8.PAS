(*
Escape From Delirium 
	by Virtual X-Perience 1995
	decompiled by ergonomy_joe in 2019
*)
{$G+}
UNIT C_18B8;

INTERFACE
PROCEDURE C_18B8_0000(_p06:STRING);
PROCEDURE C_18B8_00B4;
FUNCTION C_18B8_00F2(_x,_y:WORD):BYTE;

IMPLEMENTATION

USES
	C_1918,
	BSS;

PROCEDURE C_18B8_0000(_p06:STRING);
VAR
	_dummy1:ARRAY[1..$80] OF BYTE;
	_count:BYTE;
	_dummy2:ARRAY[1..4] OF BYTE;
BEGIN
	D_276C := 0;
	_count := BufferFetchByte(D_27E0);
	WHILE _count > 0
	DO BEGIN
		DEC(_count);
		INC(D_276C);
		NEW(D_271C[D_276C]);
		ScriptFetchArray(D_271C[D_276C]^,SIZEOF(t_3D));
		IF Language = 1
		THEN D_271C[D_276C]^.f_strE := D_271C[D_276C]^.f_strG;
	END;
END;

PROCEDURE C_18B8_00B4;
VAR _i:BYTE;
BEGIN
	FOR _i := D_276C DOWNTO 1
	DO DISPOSE(D_271C[_i]);
END;

FUNCTION C_18B8_00F2(_x,_y:WORD):BYTE;
VAR
	_i:WORD;
	_state1,_state2:BOOLEAN;
	bp_07:BYTE;
	bp_08:BYTE;
BEGIN
	bp_07 := 0;
	D_276D := FALSE;
	FOR _i := 1 TO D_276C
	DO WITH D_271C[_i]^
	DO IF
		(_x >= f_left) AND (_x <= f_right) AND
		(_y >= f_top) AND (_y <= f_bottom)
	THEN BEGIN{else 0216}
		{-- --}
		IF f_08 > $7fff
		THEN _state1 := (State[$ffff - f_08] = 0)
		ELSE _state1 := (State[f_08] = 1);
		{-- --}
		IF f_0a > $7fff
		THEN _state2 := (State[$ffff - f_0a] = 0)
		ELSE _state2 := (State[f_0a] = 1);
		{-- --}
		IF f_08 = $ffff
		THEN BEGIN
			D_276D := TRUE;
			bp_08 := _i;
			bp_07 := _i;
		END ELSE IF _state1 AND _state2
		THEN BEGIN
			bp_07 := _i;
		END;
	END;
	{note:bp_08 may be uninitialized}
	IF bp_08 <> bp_07
	THEN D_276D := FALSE;
	{-- --}
	C_18B8_00F2 := bp_07;
END;

END.
