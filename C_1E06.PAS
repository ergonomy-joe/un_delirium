(*
Escape From Delirium 
	by Virtual X-Perience 1995
	decompiled by ergonomy_joe in 2019
*)
{$G+}
UNIT C_1E06;{EMS}

INTERFACE
{C_1E06_0000}FUNCTION EMS_detect:BOOLEAN;
{C_1E06_005B}FUNCTION EMS_getSize:INTEGER;
{C_1E06_0097}FUNCTION EMS_getSegment:INTEGER;
{C_1E06_00D3}FUNCTION EMS_alloc(bp06:INTEGER):INTEGER;
{C_1E06_0117}FUNCTION EMS_free(bp06:INTEGER):BOOLEAN;

IMPLEMENTATION

USES DOS,
	BSS;

{C_1E06_0000}FUNCTION EMS_detect:BOOLEAN;
TYPE tBOBO = ARRAY[0..7] OF CHAR;
CONST D_028E:ARRAY[0..7] OF CHAR = 'EMMXXXX0';
VAR _regs:REGISTERS;
BEGIN
	_regs.AX := $3567;{get int vector $67}
	MSDOS(_regs);
	EMS_detect := (tBOBO(PTR(_regs.ES,$a)^) = D_028E);
END;

{C_1E06_005B}FUNCTION EMS_getSize:INTEGER;
VAR _regs:REGISTERS;
BEGIN
	_regs.AH := $42;{get memory}
	INTR($67,_regs);
	IF _regs.AH <> 0
	THEN BEGIN
		D_2FB2 := _regs.AH;
		EMS_getSize := -1;
	END ELSE BEGIN
		EMS_getSize := _regs.BX;
	END;
END;

{C_1E06_0097}FUNCTION EMS_getSegment:INTEGER;
VAR _regs:REGISTERS;
BEGIN
	_regs.AH := $41;
	INTR($67,_regs);
	IF _regs.AH <> 0
	THEN BEGIN
		D_2FB2 := _regs.AH;
		EMS_getSegment := -1;
	END ELSE BEGIN
		EMS_getSegment := _regs.BX;
	END;
END;

{C_1E06_00D3}FUNCTION EMS_alloc(bp06:INTEGER):INTEGER;
VAR _regs:REGISTERS;
BEGIN
	_regs.AH := $43;{open handle/allocate pages}
	_regs.BX := bp06;
	INTR($67,_regs);
	IF _regs.AH <> 0
	THEN BEGIN
		D_2FB2 := _regs.AH;
		EMS_alloc := -1;
	END ELSE BEGIN
		EMS_alloc := _regs.DX;
	END;
END;

{C_1E06_0117}FUNCTION EMS_free(bp06:INTEGER):BOOLEAN;
VAR _regs:REGISTERS;
BEGIN
	_regs.AH := $45;{close handle/free pages}
	_regs.DX := bp06;
	INTR($67,_regs);
	D_2FB2 := _regs.AH;
	EMS_free := (_regs.AH = 0);
END;

END.
