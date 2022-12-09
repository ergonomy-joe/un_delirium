{$G+}
UNIT C_11B0;

INTERFACE
PROCEDURE C_11B0_00A9(_str:STRING; bp08,bp06:WORD);

IMPLEMENTATION

{$L BFONT}
PROCEDURE C_11B0_01F6; EXTERNAL;

FUNCTION C_0000(_str:STRING):STRING;
VAR _i:INTEGER;
BEGIN
	FOR _i := 1 TO LENGTH(_str)
	DO _str[_i] := UPCASE(_str[_i]);
	C_0000 := _str;
END;

PROCEDURE C_11B0_00A9(_str:STRING; bp08,bp06:WORD);
CONST C_0076 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'#$8E#$99#$9A#$E1'.,:;-)(!?0123456789 ';
VAR
	_i,_j,_k:WORD;
	_offset:WORD;
	_b:BYTE;
BEGIN
	_str := C_0000(_str);
	FOR _i := 1 TO LENGTH(_str)
	DO BEGIN
		_offset :=
			$111 * (((POS(_str[_i],C_0076) - 1) DIV 21) * 14) +
			((POS(_str[_i],C_0076) - 1) MOD 21) * 13
		;
		FOR _j := 0 TO 13
		DO FOR _k := 0 TO 12
		DO BEGIN
			_b := MEM[SEG(C_11B0_01F6):OFS(C_11B0_01F6) + _j * $111 + _k + _offset];
			IF _b <> 0
			THEN MEM[$a000:bp08 + bp06 * 320 + _j * 320 + _k + (_i - 1) * 14] := _b;
		END;
	END;
END;

END.
