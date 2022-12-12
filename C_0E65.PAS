(*
Escape From Delirium 
	by Virtual X-Perience 1995
	decompiled by ergonomy_joe in 2019
*)
{$G+}
UNIT C_0E65;{palette animation}

INTERFACE

{C_0E65_0000}PROCEDURE AnimatePalette;

IMPLEMENTATION

USES BSS;

CONST
	D_00CC:BOOLEAN = TRUE;

{C_0E65_0000}PROCEDURE AnimatePalette;
VAR
	_i:BYTE;
	_____:BYTE;
	bp_06:tPal;
BEGIN
	IF D_00CC = FALSE
	THEN BEGIN{else 00A8}
		bp_06 := D_0F62[D_0BB2];
		FOR _i := D_0BB2 + 1 TO D_0BB3
		DO D_0F62[_i - 1] := D_0F62[_i];
		D_0F62[D_0BB3] := bp_06;
	END ELSE BEGIN
		bp_06 := D_0F62[D_0BB3];
		FOR _i := D_0BB3 - 1 DOWNTO D_0BB2
		DO D_0F62[_i + 1] := D_0F62[_i];
		D_0F62[D_0BB2] := bp_06;
	END;
	PORT[$3c8] := D_0BB2;
	FOR _i := D_0BB2 TO D_0BB3
	DO BEGIN
		PORT[$3c9] := D_0F62[_i].f_red;
		PORT[$3c9] := D_0F62[_i].f_blue;
		PORT[$3c9] := D_0F62[_i].f_green;
	END;
END;

END.
