{$G+}
UNIT C_149C;{PCX}

INTERFACE
CONST
	{D_018A}IsBW:BOOLEAN = FALSE;
	{__018B	db 0}
	D_018C:POINTER = PTR($a000,0);

PROCEDURE C_149C_0000(_mode:INTEGER);
PROCEDURE C_149C_0025(VAR bp06);
PROCEDURE C_149C_0093(VAR bp08:FILE; _pcxSize:WORD);
{C_149C_0254}PROCEDURE LoadPCX(VAR bp08:FILE; _pcxSize:WORD);
{C_149C_028D}PROCEDURE SetPCXPalette;

IMPLEMENTATION

USES DOS,
	C_1918,
	BSS;

PROCEDURE C_149C_0000(_mode:INTEGER);
BEGIN
	PalRegs.AH := 0;
	PalRegs.AL := _mode;
	INTR($10,PalRegs);
END;

{set vga palette?}
PROCEDURE C_149C_0025(VAR bp06);
BEGIN
	PalRegs.AH := $10;
	PalRegs.AL := $12;
	PalRegs.ES := SEG(bp06);
	PalRegs.DX := OFS(bp06);
	PalRegs.BX := 0;
	PalRegs.CX := $100;
	INTR($10,PalRegs);
{	INLINE(
		$90/$90/$90/$90/
		$90/$90/$90/$90/
		$90/$90/$90/$90
	);}
END;

{C_0064}PROCEDURE _InflatePCXData; ASSEMBLER;
LABEL C_0076,C_008A,C_008D,C_0091;
ASM
	LES	DI,D_018C
	XOR	CX,CX
	MOV	BX,D_1268
	PUSH	DS
	LDS	SI,D_1264
	ADD	BX,SI
	CLD	
C_0076:
	CMP	SI,BX
	JZ	C_0091
	LODSB	
	CMP	CL,0
	JG	C_008D
	CMP	AL,$C0
	JB	C_008A
	XOR	AL,$C0
	MOV	CL,AL
	JMP	C_0076
C_008A:
	STOSB	
	JMP	C_0076
C_008D:
	REPZ	STOSB
	JMP	C_0076
C_0091:
	POP	DS
END;

PROCEDURE C_149C_0093(VAR bp08:FILE; _pcxSize:WORD);
VAR
	_i:BYTE;
	_p_02:BYTE;
	bp_03:BYTE;
	_____:ARRAY[1..$85] OF BYTE;
	bpff74:LONGINT;
	____2:ARRAY[1..$4] OF BYTE;
BEGIN
	EMSStart_00;
	D_1264 := PTR(EMSSegment,0);
	SEEK(bp08,FILEPOS(bp08) + $80);
	BLOCKREAD(bp08,D_1264^,_pcxSize - $80);
	bpff74 := $80;
	D_1268 := _pcxSize - $80 - $301;
	INC(bpff74,D_1268);
	_InflatePCXData;
	{-- --}
	MOVE(PTR(SEG(D_1264^),OFS(D_1264^) + D_1268 + 1)^,D_0F62,$300);
	FOR _i := 0 TO $ff
	DO WITH D_0F62[_i]
	DO BEGIN
		f_red := f_red SHR 2;
		f_green := f_green SHR 2;
		f_blue := f_blue SHR 2;
		{-- make B&W palette --}
		IF IsBW
		THEN BEGIN
			bp_03 := ROUND(f_red * 0.3 + f_green * 0.59 + f_blue * 0.11);
			FILLCHAR(D_0F62[_i],3,bp_03);
		END;
		{-- --}
	END;
	{-- --}
END;

{C_149C_0254}PROCEDURE LoadPCX(var bp08:FILE; _pcxSize:WORD);
VAR bpfd00:ARRAY[0..$ff] OF tPal;
BEGIN
	FILLCHAR(bpfd00,$300,0);
	C_149C_0025(bpfd00);{set vga palette?}
	C_149C_0093(bp08,_pcxSize);
END;

{C_149C_028D}PROCEDURE SetPCXPalette;
BEGIN
	C_149C_0025(D_0F62);{set vga palette?}
END;

BEGIN
	D_1262 := $a000;
END.
