{$G+}
UNIT C_0BFF;{helper for ending credits}

INTERFACE
PROCEDURE C_0BFF_0000(_ch:CHAR; _x,_y:INTEGER);
PROCEDURE C_0BFF_0055(_str:STRING; _y:INTEGER);

IMPLEMENTATION

USES
	C_0E4C,
	BSS;

PROCEDURE C_0BFF_0000(_ch:CHAR; _x,_y:INTEGER);
CONST D_0052:STRING[$20] = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ.,-"* ';
BEGIN
	_ch := UPCASE(_ch);
	C_0E4C_0151(_y * $50 + _x,D_0426[POS(_ch,D_0052)] + $bb80,7,$1b);
END;

PROCEDURE C_0BFF_0055(_str:STRING; _y:INTEGER);
VAR
	_i:WORD;
	_x:WORD;
BEGIN
	_i := LENGTH(_str) * 7;
	_x := ROUND(40.0 - (_i / 2.0)) - 7;
	FOR _i := 1 TO LENGTH(_str)
	DO C_0BFF_0000(_str[_i],_i * 7 + _x,_y);
END;

{C_0BFF_0102}
BEGIN
	FOR D_0420 := 1 TO $20
	DO D_0426[D_0420] := ((D_0420 - 1) DIV 11) * $28 * $50 + ((D_0420 - 1) MOD 11) * 7;
	D_0420 := 0;
	D_0422 := 0;
	D_0424 := $32;
	D_0468 := 1;
	D_046A := 1;
	D_046C := 0;
END.
