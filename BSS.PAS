(*
Escape From Delirium 
	by Virtual X-Perience 1995
	decompiled by ergonomy_joe in 2019
*)
UNIT BSS;

INTERFACE

USES DOS;

CONST
	ACTION_0 = 0;
	ACTION_1 = 1;
	ACTION_2 = 2;
	ACTION_3 = 3;{use?}
	ACTION_4 = 4;
	ACTION_5 = 5;
	ACTION_6 = 6;
	ACTION_7 = 7;
	ACTION_8 = 8;
	ACTION_9 = 9;

TYPE
	tPal = RECORD{x3}
		f_red,f_green,f_blue:BYTE;
	END;
	tZoneLink = RECORD{x5}
		{f_00}f_count:BYTE;
		{f_01}pZones:POINTER;
	END;
	tPortal = RECORD{x6}
		{f_00,f_01}f_zoneId1,f_zoneId2:BYTE;
		{f_02,f_04}f_x,f_y:INTEGER;
	END;
	pt1A = ^t1A;
	t1A = RECORD{x1A}
		{f_00}f_zoneId:BYTE;
		{f_01}f_index:BYTE;{index in f_02}
		f_02:ARRAY[1..$14] OF BYTE;
		{f_16}f_pNext:pt1A;
	END;
	tEMSPtr = RECORD{x5}
		{f_00}f_firstPage:WORD;
		{f_02}f_offset:WORD;
		{f_04}f_pageCount:BYTE;
	END;
	t0E = RECORD{xE}
		{-- record size 9? --}
		{f_00,f_02}f_stateId1,f_stateId2:INTEGER;
		{f_04,f_05}f_width,f_height:BYTE;
		{f_06,f_08}f_x:INTEGER; f_y:BYTE;
		{-- --}
		{f_09}f_emsPtr:tEMSPtr;
	END;
	tActor = RECORD{xFF}
		{f_00}f_count:BYTE;
		{f_01}f_scriptSize:WORD;
		{f_03}f_pScriptTop:POINTER;
		{f_07}f_pData:POINTER;
		{f_0b}f_pScriptCur:POINTER;
		{f_0f,f_13}f_aX,f_aY:ARRAY[0..1] OF INTEGER;
		{f_17}f_emsPtr:ARRAY[1..$1f] OF tEMSPtr;
		{f_b2,f_d2}f_aFrameWidth,f_aFrameHeight:ARRAY[0..$1f] OF BYTE;
		{f_f2,f_f4}f_aWidth,f_aHeight:ARRAY[0..1] OF BYTE;
		{f_f6}f_scale:BYTE;
		{f_f7,f_f8}f_prevFrame,f_curFrame:BYTE;
		f_f9:BYTE;{height related?}
		f_fa:BYTE;{z?layer?}
		f_fb:BOOLEAN;
		f_fc:BOOLEAN;
		{f_fd}f_mirrorX:BOOLEAN;
		{f_fe}f_delay:BYTE;
	END;
	tHeadR = RECORD{xC}
		{f_00}f_pcxSize:WORD;{2778}
		{f_02}f_ASize:INTEGER;{277A}
		f_04:INTEGER;{277C}
		{f_06}f_scriptOfs:LONGINT;{277E}
		{f_0a}f_songId:BYTE;{2782}
		{f_0b}f_soundCount:BYTE;{2783}
	END;
	tConfig = RECORD{3}
		f_00,f_01,f_02:BOOLEAN;
	END;
	tSave = RECORD{xC}
		{f_00,f_02}f_x:WORD; f_y:BYTE;{D_0BB6,D_0BB8}
		{f_03}f_mirrorX:BOOLEAN;{D_0BB9}
		{f_04}f_curFrame:BYTE;{D_0BBA}
		{f_05}f_scale:BYTE;{D_0BBB}
		f_06:BYTE;{D_0BBC}
		f_07:tConfig;{D_0BBD}
		f_0a:WORD;{D_0BC0}
	END;
	t_3D = RECORD{x3D}
		{f_00,f_02}f_left:WORD; f_top:BYTE;
		{f_03,f_05}f_right:WORD; f_bottom:BYTE;
		{f_06}f_objId:INTEGER;{goes to D_1A70}
		f_08,f_0a:WORD;{f_stateId1,f_stateId2}
		{f_0c,f_21}f_strE,f_strG:STRING[$14];{english(default)/german}
		{f_36,f_38}f_x:INTEGER; f_y:BYTE;
		f_39:BYTE;
		{f_3a}f_defaultIcon:BYTE;
		f_3b:BYTE;{f_curFrame?}
		f_3c:BOOLEAN;{f_mirrorX?}
	END;
	tZone = RECORD{xF}
		{ff_00,ff_02,ff_04,ff_06}f_left,f_top,f_right,f_bottom:INTEGER;
		{ff_08}ff_scale:BYTE;
		ff_09,ff_0a:BYTE;
		{ff_0b}f_type:BYTE;
		{ff_0c}f_stateId:WORD;{or two bytes, depending on f_type?}
		___0e:BYTE;
	END;
	t55 = RECORD{x55}
		f_00:STRING[$50];
		f_51:LONGINT;{offset}
	END;
	tObject = RECORD{x1B}
		{f_00}f_objId:INTEGER;
		{f_02}f_name:STRING[$14];
		{f_17}f_pImg:POINTER;
	END;
	t59 = RECORD{x59}
		f_00:BYTE;{D_0DF4}
		f_01:BYTE;{D_0DF5}
		f_02:STRING[$50];{D_0DF6}
		f_53,f_55:WORD;{x,y}{D_0E47,D_0E49}
		f_57:WORD;{size of picture}{D_0E4B}
	END;
	t10 = RECORD{x10}
		f_00:LONGINT;
		f_04:ARRAY[1..4] OF BYTE;
		f_08:POINTER;
		f_0c:LONGINT;
	END;
	tTOC = RECORD{x32D2}
		{__00}f_magic:ARRAY[1..8] OF BYTE;{= 'VX V1.00'}
		{f_08}f_count:INTEGER;
		{f_0a}f_aEntry:ARRAY[1..$3e8] OF RECORD{xd}
			{f_00}f_name:STRING[4];
			{f_05}f_size:LONGINT;
			{f_09}f_offset:LONGINT;
		END;
	END;
	ptTOC = ^tTOC;
	STRING_0B = STRING[$b];
	STRING_3C = STRING[$3c];
	pSTRING_3C = ^STRING_3C;
	tSetOfChar = SET OF CHAR;

VAR
	D_02D8:LONGINT;
__02DC:LONGINT;
	D_02E0:LONGINT;
	D_02E4:STRING;
	D_03E4:INTEGER;
	D_03E6:INTEGER;
__03E8:ARRAY[1..$a] OF BYTE;
	D_03F2:LONGINT;{memory before main loop}
__03F6:ARRAY[1..$c] OF BYTE;
	D_0402:STRING[3];
__0406:WORD;
	D_0408:LONGINT;{memory after main loop}
__040C:WORD;
	D_040E:INTEGER;
	D_0410:INTEGER;
__0412:ARRAY[1..6] OF BYTE;
	D_0418:BYTE;

	D_041A:POINTER;
	D_041E:INTEGER;
	D_0420:INTEGER;
	D_0422:INTEGER;
	D_0424:INTEGER;
	D_0426:ARRAY[1..$20] OF WORD;
__0466:WORD;
	D_0468:INTEGER;
	D_046A:INTEGER;
	D_046C:INTEGER;
	D_046E:INTEGER;
	D_0470:INTEGER;
__0472:ARRAY[1..6] OF BYTE;
	D_0478:INTEGER;
	D_047A:INTEGER;
__047C:ARRAY[1..$15] OF BYTE;
	D_0491:BYTE;
	D_0492:POINTER;
	D_0496:BOOLEAN;

	{D_0498,D_049A}MouseX,MouseY:INTEGER;
	{D_049C,D_049E}PrevMouseX,PrevMouseY:INTEGER;
__04A0:ARRAY[1..$102] OF BYTE;
	D_05A2:BYTE;
	D_05A3:BYTE;
	D_05A4:BYTE;
	D_05A5:BYTE;
__05A6:BYTE;
	D_05A7:BYTE;
	D_05A8:BYTE;
	D_05A9:BOOLEAN;
	D_05AA:CHAR;

	D_05AC:POINTER;
	D_05B0:WORD;
	D_05B2:ARRAY[1..$300] OF BYTE;{WORD?}
	__08B2:ARRAY[1..$300] OF BYTE;
	D_0BB2:BYTE;
	D_0BB3:BYTE;
	D_0BB4:BYTE;

	{D_0BB6}Save:tSave;
	D_0BC2:STRING;
	D_0CC2:BYTE;
	D_0CC3:BYTE;
	D_0CC4:POINTER;
	D_0CC8:POINTER;
	{D_0CCC,D_0CCE}MenuX,MenuY:INTEGER;
	D_0CD0:BYTE;
	D_0CD1:BOOLEAN;
__0CD2:ARRAY[1..4] OF BYTE;
	D_0CD6:BYTE;
	D_0CD7:BYTE;
	{D_0CD8}DoShakeScreen:BOOLEAN;

	D_0CDA:WORD;
	D_0CDC:BYTE;
	D_0CDD:BYTE;
	D_0CDE:BYTE;
	D_0CDF:BOOLEAN;
	D_0CE0:BOOLEAN;
	D_0CE1:CHAR;
	D_0CE2:BYTE;
	D_0CE3:BYTE;
	D_0CE4,D_0CE6,D_0CE8,D_0CEA:WORD;{stretch:left,top,right,bottom}
	D_0CEC:LONGINT;
__0CF0:ARRAY[1..$104] OF BYTE;
	D_0DF4:t59;

__0E4E:	ARRAY[1..$114] OF BYTE;
	D_0F62:ARRAY[0..$ff] OF tPal;
	D_1262:WORD;
	D_1264:POINTER;
	D_1268:WORD;
	{D_126A}PalRegs:REGISTERS;
	D_127E:ARRAY[0..18,0..1] OF INTEGER;{cos,sin}
	D_12CA:BOOLEAN;
	D_12CB:BYTE;
	D_12CC:BYTE;
	{D_12CD}AnimStep:BYTE;
	{D_12CE}AnimType:BYTE;

	{D_12D0}ZoneLinks:ARRAY[1..$ff] OF ^tZoneLink;
	{D_16CC}ZoneDistances:ARRAY[1..$14] OF INTEGER;
__16F4:ARRAY[1..$64] OF BYTE;	
	{D_1758}ZoneGraph:ARRAY[1..$14] OF RECORD{5}
		{f_00}f_zoneId:BYTE;
		{f_01,f_03}f_x,f_y:INTEGER;
	END;
	{D_17BC}Portals:ARRAY[1..$64] OF ^tPortal;
	D_194C:BYTE;
	D_194D:BYTE;{count for ZoneGraph}
	{D_194E}PortalsCount:BYTE;

	D_1950:INTEGER;
	D_1952:INTEGER;
	{D_1954,D_1958}List_1,List_2:pt1A;
	{D_195C}Zones:ARRAY[1..$34] OF ^tZone;
	{D_1A2C}ZonesCount:BYTE;

	{D_1A2E,D_1A30}MovDestX,MovDestY:INTEGER;
__1A32:ARRAY[1..5] OF BYTE;
	D_1A37:BYTE;{index in Zones}
	{D_1A38,D_1A39}DestZoneId,OrigZoneId:BYTE;
	{D_1A3A}PlayerIsMoving:BOOLEAN;
	D_1A3B:BYTE;
	{D_1A3C,D_1A3E}MovSrcX,MovSrcY:INTEGER;
	{D_1A40,D_1A46}MovSin,MovCos:REAL;
	{D_1A4C}MovDistance:INTEGER;
	{D_1A4E}MovCurDist:WORD;
	{D_1A50}MovSpeed:BYTE;

	D_1A52:POINTER;
	D_1A56:WORD;
	D_1A58:BYTE;

	D_1A5A:^BYTE;
	D_1A5E:INTEGER;
	D_1A60:BYTE;
	D_1A61:BYTE;
	{D_1A62}PScriptTop:POINTER;
	{D_1A66}PScriptEnd:POINTER;
	{D_1A6A}PScriptCur:POINTER;
	{D_1A6E}ActionId:BYTE;

	D_1A70:ARRAY[1..2] OF WORD;
	D_1A74:ARRAY[1..2] OF BOOLEAN;
	D_1A76:BYTE;

	D_1A78:POINTER;{scriptTop}
	D_1A7C:POINTER;{scriptCur}
	D_1A80:POINTER;{scriptEnd}
	D_1A84:BYTE;
	{D_1A85,D_1A86}IconCur,IconPrev:BYTE;
	D_1A87:BYTE;
	D_1A88:ARRAY[1..6,1..5] OF STRING_3C;{D_191A+16e}
	D_21AE:^t10;
	D_21B2:POINTER;{^t10?}
	D_21B6:POINTER;
	D_21BA:ARRAY[1..4] OF t55;
	D_230E:ARRAY[1..5] OF STRING[$50];
	D_24A3:BYTE;
__24A4:ARRAY[1..$80] OF BYTE;
	D_2524:LONGINT;
	D_2528:^BYTE;
	D_252C:BYTE;
	D_252D:BYTE;
	D_252E:BYTE;
	D_252F:BYTE;
	D_2530:BYTE;

	D_2532:POINTER;
	D_2536:LONGINT;
	D_253A:BYTE;

	{D_253C}CurObjId:INTEGER;
	{D_253E}CurObj:RECORD
		{D_253E}f_name:STRING[$14];
		{-- --}
		{D_2553}f_aScriptLen:ARRAY[1..7] OF WORD;
		{D_2561}f_apScript:ARRAY[1..7] OF POINTER;
		{-- --}
		{D_257D}f_script2Count:BYTE;
		{D_257E}f_aScript2Info:ARRAY[1..$a] OF RECORD
			f_00:INTEGER;
			{f_02}f_len:WORD;
		END;
		{D_25A6}f_apScript2:ARRAY[1..$a] OF POINTER;
		{-- --}
		{D_25CE}f_hasIcon:BYTE;
		{D_25CF}f_conversationId:BYTE;
	END;
	{D_25D0}Inventory:ARRAY[1..$50] OF ^tObject;
	D_2710:BYTE;
__2711,__2712,__2713:BYTE;
	D_2714:BYTE;
__2716:WORD;
	D_2718:LONGINT;
	D_271C:ARRAY[1..$14] OF ^t_3D;
	D_276C:BYTE;
	D_276D:BOOLEAN;
	{D_276E}Language:BYTE;{english/german flag}

	D_2770:LONGINT;
	D_2774:LONGINT;
	{D_2778}HeadR:tHeadR;
	{D_2784}Regs:REGISTERS;
	D_2798,D_2799:BYTE;
	D_279A:POINTER;{points to "int $33"}
	D_279E,D_27A0:INTEGER;
	D_27A2:WORD;
	D_27A4:WORD;
	D_27A6:WORD;
	D_27A8:WORD;
	D_27AA:POINTER;
	D_27AE:POINTER;{mouse image}
	D_27B2,D_27B3:BYTE;{mouse image width,height}
	D_27B4,D_27B5:BOOLEAN;{mouse flags}
	{D_27B6}IsDifficult:BOOLEAN;
__27B7:BYTE;
	D_27B8:BYTE;
__27B9:BYTE;
	D_27BA:BYTE;
	{D_27BB}DefaultIcon:BYTE;
	D_27BC:ARRAY[1..3] OF BOOLEAN;

	D_27C0:ARRAY[1..2] OF BYTE;{volume/speed}
	D_27C2:BOOLEAN;{render offscreen?}
	D_27C3:BOOLEAN;
	D_27C4:STRING[4];{current scene name}
	D_27C9:BYTE;{current scene #}
	D_27CA:BYTE;
	D_27CB:BOOLEAN;{quit flag?}
	D_27CC:BYTE;
	D_27CD:BYTE;
	{D_27CE,D_27D0}GlobalI,GlobalJ:INTEGER;
	D_27D2:INTEGER;
	D_27D4:INTEGER;
	D_27D6:BYTE;

	D_27D8:POINTER;
	D_27DC:POINTER;
	D_27E0:POINTER;
	{D_27E4}CurEMSPage,D_27E6,D_27E8:INTEGER;{+backups}
	{D_27EA}CurEMSOffset,D_27EC,D_27EE:WORD;{+backups}
	D_27F0:BYTE;
	D_27F1:BYTE;
	D_27F2:BOOLEAN;

	D_27F4:WORD;
	D_27F6:WORD;
	D_27F8:BOOLEAN;
	D_27F9:BOOLEAN;
	D_27FA:BYTE;
	D_27FB:BYTE;
__27FC:WORD;
	D_27FE:ARRAY[1..4] OF BYTE;
	D_2802:BYTE;
	D_2803:BYTE;
	D_2804:BOOLEAN;{previous f_mirrorX}
	{D_2805}ObjCount:BYTE;
	D_2806:BYTE;
	D_2807:BYTE;
	D_2808:BOOLEAN;

	D_280A:FILE;
	D_288A:POINTER;
	D_288E:POINTER;
	{D_2892}Actors:ARRAY[1..$14] OF ^tActor;
	D_28E2:ARRAY[1..$14] OF ^t0E;
	D_2932:ARRAY[1..$14] OF BYTE;
	D_2946:BYTE;
	D_2947:BYTE;
	D_2948:ARRAY[1..$14,1..$a] OF BYTE;
	D_2A10:ARRAY[1..$14] OF BYTE;
	D_2A24:POINTER;
	D_2A28:BYTE;

	D_2A2A:INTEGER;
	D_2A2C:INTEGER;
	D_2A2E:INTEGER;
	D_2A30:WORD;
	D_2A32:INTEGER;
	D_2A34:BOOLEAN;
	D_2A35:BOOLEAN;
	{D_2A36}CurSong:INTEGER;
	D_2A38:BYTE;{sound device}
	D_2A39:BYTE;{IRQ}
	D_2A3A:BYTE;{dma channel}

	D_2A3C:INTEGER;{i/o port}
__2A3E:WORD;
	{D_2A40}SFXCount:BYTE;{SFX count}

	{D_2A42}ASFXHandle:ARRAY[1..5] OF INTEGER;
	D_2A4C:RECORD
		f_00:WORD;{i/o port}
		f_02:BYTE;{dma channel}
		f_03:BYTE;{IRQ}
		f_04:WORD;{rate}
		f_06:BYTE;
		f_07:BYTE;
		f_08:BYTE;
		f_09:BYTE;
		f_0a:BYTE;
		f_0b:BYTE;
		f_0c:BYTE;
		f_0d:BYTE;
		{__2A5A	...}
		__0e:ARRAY[1..6] OF BYTE;
		{__2A60	...}
		__14:ARRAY[1..$80] OF BYTE;
	END;
	{-- --}
	D_2AE0:POINTER;{mod driver pointer}
__2AE4:WORD;
	D_2AE6:WORD;{mod driver segment}
	D_2AE8:WORD;{mod driver size}
	D_2AEA:WORD;
	D_2AEC:WORD;
	D_2AEE:WORD;
	D_2AF0:WORD;
	{-- --}
	D_2AF2:ptTOC;
	D_2AF6:STRING;
	{D_2BF6}RES_handle:FILE;
	{D_2C76}RES_offset:LONGINT;
	{D_2C7A}RES_size:LONGINT;
	D_2C7E:LONGINT;
	D_2C82:LONGINT;
	{D_2C86}EMSSegment:INTEGER;
	{D_2C88}EMSHandle:INTEGER;
	D_2C8A:INTEGER;
	D_2C8C:LONGINT;
	{D_2C90}State:ARRAY[0..$31f] OF BYTE;
__2FB0:WORD;
	D_2FB2:BYTE;{ems error code?}
__2FB3:ARRAY[1..$a] OF BYTE;
IMPLEMENTATION

END.
