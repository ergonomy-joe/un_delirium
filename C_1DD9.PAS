(*
Escape From Delirium 
	by Virtual X-Perience 1995
	decompiled by ergonomy_joe in 2019
*)
{$G+}
UNIT C_1DD9;{resources}

INTERFACE

TYPE
	STRING_04 = STRING[4];

{C_1DD9_008D}PROCEDURE RES_start;
{C_1DD9_0180}PROCEDURE RES_find(_name:STRING_04; VAR _vOffset,_vSize:LONGINT);

IMPLEMENTATION

USES DOS,
	BSS;

{map memory into page frame?}
PROCEDURE C_0000(_handle,bp06:WORD; bp04:BYTE);
BEGIN
	ASM
		MOV	AH,$44
		MOV	AL,bp04
		MOV	BX,bp06
		MOV	DX,_handle
		INT	$67
	END;
END;

{C_001B}FUNCTION Decrypt(_str:STRING):STRING;
VAR _i:INTEGER;
BEGIN
	FOR _i := 1 TO LENGTH(_str)
	DO _str[_i] := CHR(ORD(_str[_i]) XOR $fc);
	Decrypt := _str;
END;

{C_1DD9_008D}PROCEDURE RES_start;
VAR _i:WORD;
BEGIN
	C_0000(EMSHandle,$f,0);{map memory into page frame?}
	D_2AF2 := ptTOC(PTR(EMSSegment,$988));
	D_2C8A := SIZEOF(tTOC);
	BLOCKREAD(RES_handle,D_2AF2^,D_2C8A);
	FOR _i := 1 TO D_2AF2^.f_count
	DO D_2AF2^.f_aEntry[_i].f_name := Decrypt(D_2AF2^.f_aEntry[_i].f_name);
END;

{C_1DD9_0180}PROCEDURE RES_find(_name:STRING_04; VAR _vOffset,_vSize:LONGINT);
VAR _i:WORD;
BEGIN
	C_0000(EMSHandle,$f,0);{map memory into page frame?}
	_vOffset := -1;
	FOR _i := 1 TO D_2AF2^.f_count
	DO IF D_2AF2^.f_aEntry[_i].f_name = _name
	THEN BEGIN
		WITH D_2AF2^.f_aEntry[_i]
		DO BEGIN
			_vOffset := f_offset + D_2C8C;
			_vSize := f_size;
		END;
		_i := D_2AF2^.f_count;
	END;
	IF _vOffset = -1
	THEN BEGIN
		D_2AF6 :=
			'Resourcefiles in DELIRIUM.EXE are damaged!'#10#13 +
			'Sorry, but I have to stop the game...'#10
		;
		ASM
			INT	$23	{Ctrl-Break?}
		END;
		EXIT;
	END;
	SEEK(RES_handle,_vOffset);
END;

END.
