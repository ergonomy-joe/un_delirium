{$G+}
UNIT C_1751;

INTERFACE
FUNCTION C_1751_0002(_actionId:BYTE; bp06:STRING):STRING;

IMPLEMENTATION

USES BSS;

FUNCTION C_1751_0002(_actionId:BYTE; bp06:STRING):STRING;
CONST D_01E8:ARRAY[1..7] OF BYTE = (1,1,2,3,4,6,5);
VAR
	_str:STRING[$3c];
	_result:STRING[$3c];
	_i:BYTE;
BEGIN
	_str := D_1A88[D_01E8[_actionId]][RANDOM(5) + 1];
	_result[0] := #0;
	FOR _i := 1 TO LENGTH(_str)
	DO BEGIN
		IF _str[_i] <> '%'
		THEN _result := _result + _str[_i]
		ELSE _result := _result + bp06;
	END;
	_result := _result + '^';
	C_1751_0002 := _result;
END;

END.
