(*
Escape From Delirium 
	by Virtual X-Perience 1995
	decompiled by ergonomy_joe in 2019
*)
{$G+}
UNIT C_14C8;{movement?}

INTERFACE
{C_14C8_0000}FUNCTION Scale(_y,_top1,_bottom1,_top2,_bottom2:WORD):BYTE;
{C_14C8_0071}FUNCTION FindPathBetween(_zoneId1,_zoneId2:BYTE):BYTE;
{C_14C8_00F2}PROCEDURE StartMove(_x1,_y1,_x2,_y2:INTEGER; _resetAnim:BOOLEAN);
{C_14C8_04E1}PROCEDURE ZoneLinkParse(_p06:STRING);{parse tZoneLink array?}
{C_14C8_0652}PROCEDURE ZoneLinkRelease;
PROCEDURE C_14C8_07A2;
PROCEDURE C_14C8_0A5B;
{C_14C8_1126}FUNCTION Distance(x1,y1,x2,y2:INTEGER):INTEGER;
{C_14C8_186B}PROCEDURE ComputePath(_zoneId1,_zoneId2:BYTE);
{C_14C8_1931}FUNCTION FindZoneAt(_x,_y:INTEGER):BYTE;
{C_14C8_1A5D}PROCEDURE PlayerGoesTo(_x,_y:INTEGER);
{C_14C8_1C03}PROCEDURE MoveRefresh;

IMPLEMENTATION

USES CRT,
	C_16C2,
	C_16DC,
	C_1918,
	BSS;

{C_14C8_0000}FUNCTION Scale(_y,_top1,_bottom1,_top2,_bottom2:WORD):BYTE;
BEGIN
	IF (_bottom1 - _top1) <> 0
	THEN Scale := ROUND((_y - _top1) * (_bottom2 - _top2) / (_bottom1 - _top1) + _top2)
	ELSE Scale := 255;
END;

{C_14C8_0071}FUNCTION FindPathBetween(_zoneId1,_zoneId2:BYTE):BYTE;
VAR
	bp_02:BYTE;
	_i:BYTE;
BEGIN
	{-- swap --}
	IF _zoneId1 > _zoneId2
	THEN BEGIN
		bp_02 := _zoneId1;
		_zoneId1 := _zoneId2;
		_zoneId2 := bp_02;
	END;
	{-- --}
	FindPathBetween := 0;
	FOR _i := 1 TO PortalsCount
	DO WITH Portals[_i]^
	DO IF (f_zoneId1 = _zoneId1) AND (f_zoneId2 = _zoneId2)
	THEN FindPathBetween := _i;
END;

{C_14C8_00F2}PROCEDURE StartMove(_x1,_y1,_x2,_y2:INTEGER; _resetAnim:BOOLEAN);
VAR
	_angle:REAL;
	_deltaX,_deltaY:LONGINT;
	_newFrame:BYTE;
	_prevAnimType:BYTE;
	_mirrorX:BOOLEAN;
BEGIN
	GuessAnimType(Actors[1]^.f_curFrame,_prevAnimType);
	_mirrorX := Actors[1]^.f_mirrorX;
	MovSrcX := _x1;
	MovSrcY := _y1;
	MovSin := 0.0;
	MovCos := 0.0;
	MovCurDist := 0;
	IF _x1 = _x2
	THEN BEGIN{else 01A6}
		IF _y2 > _y1
		THEN BEGIN
			MovSin := 1.0;
			AnimType := 1;
		END ELSE BEGIN
			MovSin := -1.0;
			AnimType := 2;
		END;
		MovDistance := ABS(_y2 - _y1);
		{goto 0320}
	END ELSE IF _y1 = _y2
	THEN BEGIN{else 01F7}
		IF _x2 > _x1
		THEN BEGIN
			MovCos := 1.0;
			AnimType := 0;
		END ELSE BEGIN
			MovCos := -1.0;
			AnimType := 0;
		END;
		MovDistance := ABS(_x2 - _x1);
		{goto 0320}
	END ELSE BEGIN
		_deltaX := _x2 - _x1;
		_deltaY := _y2 - _y1;
		_angle := ARCTAN(ABS(_deltaY / _deltaX));
		MovSin := SIN(_angle);
		IF _angle > 0.698132	{(PI / 4.5)?}
		THEN AnimType := 1
		ELSE AnimType := 0;
		IF _y1 > _y2
		THEN BEGIN{else 02B2}
			MovSin := -MovSin;
			IF AnimType = 1
			THEN AnimType := 2;
		END;
		MovCos := COS(_angle);
		IF _x1 > _x2
		THEN MovCos := -MovCos;
		MovDistance := ROUND(SQRT(SQR(_deltaY) + SQR(_deltaX)));
	END;
	IF MovDistance < 5
	THEN BEGIN{else 0360}
		AnimType := _prevAnimType;
		IF MovDistance = 0
		THEN BEGIN{else 0360}
			IF _mirrorX
			THEN MovCos := 1.0
			ELSE MovCos := -1.0;
		END;
	END;
	{-- --}
	IF _resetAnim
	THEN AnimStep := 0;
	{-- --}
	IF
		(
			((AnimType = 1) AND (_prevAnimType = 2)) OR
			((AnimType = 2) AND (_prevAnimType = 1))
		) AND (_prevAnimType <> AnimType)
	THEN _newFrame := $07
	ELSE IF (NOT _mirrorX) AND (MovCos > 0) AND (_prevAnimType = AnimType) AND (AnimType = 0)
	THEN _newFrame := $11
	ELSE IF _mirrorX AND (MovCos < 0) AND (_prevAnimType = AnimType) AND (AnimType = 0)
	THEN _newFrame := $11
	ELSE _newFrame := 0;
	{-- --}
	WITH Actors[1]^
	DO BEGIN
		f_fb := TRUE;
		IF _newFrame > 0
		THEN f_curFrame := _newFrame
		ELSE f_curFrame := AnimFrames[AnimType][9];
		IF f_scale <> 255
		THEN BEGIN
			f_aWidth[1] := (f_aFrameWidth[f_curFrame] * f_scale) SHR 7;
			f_aHeight[1] := (f_aFrameHeight[f_curFrame] * f_scale) SHR 7;
		END ELSE BEGIN
			f_aWidth[1] := f_aFrameWidth[f_curFrame];
			f_aHeight[1] := f_aFrameHeight[f_curFrame];
		END;
	END;
END;

{C_14C8_04E1}PROCEDURE ZoneLinkParse(_p06:STRING);
BEGIN
	{-- --}
	ZonesCount := BufferFetchByte(D_27E0);
	FOR GlobalI := 1 TO ZonesCount
	DO BEGIN
		NEW(Zones[GlobalI]);
		ScriptFetchArray(Zones[GlobalI]^,SIZEOF(tZone));
	END;
	FOR GlobalI := 1 TO ZonesCount
	DO BEGIN
		NEW(ZoneLinks[GlobalI]);
		WITH ZoneLinks[GlobalI]^
		DO BEGIN
			f_count := BufferFetchByte(D_27E0);
			GETMEM(pZones,f_count);
			ScriptFetchArray(pZones^,f_count);
		END;
	END;
	{-- --}
	PortalsCount := BufferFetchByte(D_27E0);
	FOR GlobalI := 1 TO PortalsCount
	DO BEGIN
		NEW(Portals[GlobalI]);
		ScriptFetchArray(Portals[GlobalI]^,SIZEOF(tPortal));
	END;
	{-- --}
END;

{C_14C8_0652}PROCEDURE ZoneLinkRelease;
BEGIN
	FOR GlobalI := 1 TO ZonesCount
	DO BEGIN
		DISPOSE(Zones[GlobalI]);
		WITH ZoneLinks[GlobalI]^
		DO FREEMEM(pZones,f_count);
		DISPOSE(ZoneLinks[GlobalI]);
	END;
	{-- --}
	FOR GlobalI := 1 TO PortalsCount
	DO DISPOSE(Portals[GlobalI]);
END;

PROCEDURE C_0710;
BEGIN
	MovSpeed := ROUND(SQRT(
		SQR(Zones[D_1A37]^.ff_09 * MovCos) +
		SQR(Zones[D_1A37]^.ff_0a * MovSin)
	));
	IF MovSpeed < 1
	THEN MovSpeed := 1;
END;

PROCEDURE C_14C8_07A2;
BEGIN
	WITH Actors[1]^
	DO WITH Zones[D_1A37]^
	DO BEGIN
		IF ff_scale = 0
		THEN f_scale := Scale(f_aY[1],f_top,f_bottom,HI(f_stateId),LO(f_stateId))
		ELSE f_scale := ff_scale;
	END;
END;

{C_0820}PROCEDURE _FindZoneNear(_x,_y:INTEGER; VAR _newX,_newY:INTEGER);
VAR
	_radius:LONGINT;
	_i:BYTE;
	___0a:ARRAY[1..5] OF BYTE;
	_cos,_sin:LONGINT;
BEGIN
	_radius := 0;
	_newX := -1;
	_newY := -1;
	REPEAT
		INC(_radius,2);
		FOR _i := 0 TO 18
		DO BEGIN
			_cos := (D_127E[_i][1] * _radius) SHR $f;
			_sin := (D_127E[_i][0] * _radius) SHR $f;
			IF FindZoneAt(_x + _cos,_y + _sin) > 0
			THEN BEGIN{else 08F0}
				_newX := _x + _cos;
				_newY := _y + _sin;
				_i := $12;
			END ELSE IF FindZoneAt(_x - _cos,_y + _sin) > 0
			THEN BEGIN
				_newX := _x - _cos;
				_newY := _y + _sin;
				_i := $12;
			END ELSE IF FindZoneAt(_x - _cos,_y - _sin) > 0
			THEN BEGIN
				_newX := _x - _cos;
				_newY := _y - _sin;
				_i := $12;
			END ELSE IF FindZoneAt(_x + _cos,_y - _sin) > 0
			THEN BEGIN
				_newX := _x + _cos;
				_newY := _y - _sin;
				_i := $12;
			END;
		END;
	UNTIL (_newX <> -1) OR (_newY <> -1) OR (_radius = 318);
END;

PROCEDURE C_09ED;
VAR _newX,_newY:INTEGER;
BEGIN
	D_1A37 := FindZoneAt(Actors[1]^.f_aX[1],Actors[1]^.f_aY[1]);
	IF D_1A37 = 0
	THEN BEGIN
		_FindZoneNear(Actors[1]^.f_aX[1],Actors[1]^.f_aY[1],_newX,_newY);
		Actors[1]^.f_aX[1] := _newX;
		Actors[1]^.f_aY[1] := _newY;
		D_1A37 := FindZoneAt(_newX,_newY);
	END;
END;

PROCEDURE C_14C8_0A5B;
BEGIN
	PlayerIsMoving := FALSE;
	WITH Actors[1]^
	DO BEGIN
		f_fb := TRUE;
		f_curFrame := AnimFrames[AnimType][9];
	END;
	C_09ED;
	C_14C8_07A2;
	C_1918_0D50(1);
END;

{C_0AA5}FUNCTION _IsZoneActiveAt(_x,_y,_zoneId:INTEGER):BOOLEAN;
VAR bp_02:BOOLEAN;
BEGIN
	_IsZoneActiveAt := FALSE;
	WITH Zones[_zoneId]^
	DO IF
		(_x >= f_left) AND (_x <= f_right) AND
		(_y >= f_top) AND (_y <= f_bottom)
	THEN BEGIN{else 0B4A}
		IF f_type <> 1{get state}
		THEN BEGIN
			_IsZoneActiveAt := TRUE;
		END ELSE BEGIN
			IF f_stateId > $7fff
			THEN bp_02 := (State[$ffff - f_stateId] = 0)
			ELSE bp_02 := (State[f_stateId] = 1);
			IF bp_02
			THEN _IsZoneActiveAt := TRUE;
		END;
	END;
END;

{C_0B51}PROCEDURE _FindNearZone(_x,_y,_zoneId:INTEGER; VAR _newX,_newY:INTEGER);
VAR
	bp_4c:ARRAY [0..18,1..4] OF BOOLEAN;
	_radius:LONGINT;
	_i:BYTE;
	___56:ARRAY[1..4] OF BYTE;
	_cos,_sin:LONGINT;
BEGIN
	{-- --}
	IF D_1A37 = _zoneId
	THEN BEGIN
		MovDestX := ZoneGraph[D_1A3B].f_x;
		MovDestY := ZoneGraph[D_1A3B].f_y;
		SOUND(1000);
		DELAY(1000);
		NOSOUND;
		EXIT;
	END;
	{-- --}
	FOR _radius := 0 TO 18
	DO FOR _i := 1 TO 4
	DO bp_4c[_radius][_i] := FALSE;
	{-- --}
	_radius := 0;
	_newX := -1;
	_newY := -1;
	REPEAT
		INC(_radius,2);
		FOR _i := 0 TO 18
		DO BEGIN
			_cos := (_radius * D_127E[_i][1]) SHR $f;
			_sin := (_radius * D_127E[_i][0]) SHR $f;
			IF (NOT bp_4c[_i][1]) AND _IsZoneActiveAt(_x + _cos,_y + _sin,_zoneId)
			THEN BEGIN
				_newX := _x + _cos;
				_newY := _y + _sin;
				EXIT;
			END;
			IF (NOT bp_4c[_i][2]) AND _IsZoneActiveAt(_x - _cos,_y + _sin,_zoneId)
			THEN BEGIN
				_newX := _x - _cos;
				_newY := _y + _sin;
				EXIT;
			END;
			IF (NOT bp_4c[_i][3]) AND _IsZoneActiveAt(_x - _cos,_y - _sin,_zoneId)
			THEN BEGIN
				_newX := _x - _cos;
				_newY := _y - _sin;
				EXIT;
			END;
			IF (NOT bp_4c[_i][4]) AND _IsZoneActiveAt(_x + _cos,_y - _sin,_zoneId)
			THEN BEGIN
				_newX := _x + _cos;
				_newY := _y - _sin;
				EXIT;
			END;
			IF NOT _IsZoneActiveAt(_x + _cos,_y + _sin,D_1A37)
			THEN bp_4c[_i][1] := TRUE;
			IF NOT _IsZoneActiveAt(_x - _cos,_y + _sin,D_1A37)
			THEN bp_4c[_i][2] := TRUE;
			IF NOT _IsZoneActiveAt(_x - _cos,_y - _sin,D_1A37)
			THEN bp_4c[_i][3] := TRUE;
			IF NOT _IsZoneActiveAt(_x + _cos,_y - _sin,D_1A37)
			THEN bp_4c[_i][4] := TRUE;
		END;
	UNTIL (_newX <> -1) OR (_newY <> -1) OR (_radius = 100);
END;

{C_0EA9}PROCEDURE MoveStop;
VAR
	_p_04:ARRAY[1..4] OF BYTE;
	_i:BYTE;
BEGIN
	PlayerIsMoving := FALSE;
	IF D_1A3B < D_194D
	THEN BEGIN{else 101B}
		INC(D_1A3B);
		D_1A37 := ZoneGraph[D_1A3B].f_zoneId;
		MovDestX := -1;
		IF D_1A3B < D_194D
		THEN _FindNearZone(
			Actors[1]^.f_aX[1],Actors[1]^.f_aY[1],
			ZoneGraph[D_1A3B + 1].f_zoneId,
			MovDestX,MovDestY
		);
		IF (MovDestX = -1) OR (MovDestY = -1)
		THEN BEGIN
			MovDestX := ZoneGraph[D_1A3B].f_x;
			MovDestY := ZoneGraph[D_1A3B].f_y;
		END;
		StartMove(Actors[1]^.f_aX[1],Actors[1]^.f_aY[1],MovDestX,MovDestY,FALSE);
		C_14C8_07A2;
		C_1918_0D50(1);
		PlayerIsMoving := TRUE;
		{-- --}
		IF Zones[D_1A37]^.f_type = 2{set state}
		THEN BEGIN
			State[Zones[D_1A37]^.f_stateId] := 1;
			RefreshState(Zones[D_1A37]^.f_stateId);
		END ELSE IF Zones[D_1A37]^.f_type = 3{reset state}
		THEN BEGIN
			State[Zones[D_1A37]^.f_stateId] := 0;
			RefreshState(Zones[D_1A37]^.f_stateId);
		END;
		{-- --}
		C_0710;
	END ELSE BEGIN
		WITH Actors[1]^
		DO BEGIN
			D_1A58 := 0;
			f_fb := TRUE;
			IF D_12CB > 0
			THEN BEGIN
				f_curFrame := D_271C[D_12CB]^.f_3b;
				f_mirrorX := D_271C[D_12CB]^.f_3c;
			END ELSE BEGIN
				f_curFrame := AnimFrames[AnimType][9];
			END;
		END;
		C_09ED;
		C_14C8_07A2;
		C_1918_0D50(1);
		INC(AnimStep);
		IF AnimSteps[AnimType] < AnimStep
		THEN AnimStep := 1;
		CASE D_12CC OF
			1: C_16DC_03E2;
			2: BEGIN
				C_1918_2A16;
				IF D_27D6 > 0
				THEN FOR _i := 1 TO D_27D6
				DO C_1918_1BB1(_i);
				D_27CB := TRUE;
				D_27C9 := HI(D_271C[D_12CB]^.f_0a);
				D_27CA := LO(D_271C[D_12CB]^.f_0a);
			END;
		END;
		D_12CC := 0;
	END;
END;

{C_14C8_1126}FUNCTION Distance(x1,y1,x2,y2:INTEGER):INTEGER;
VAR _deltaX,_deltaY:LONGINT;
BEGIN
	_deltaX := ABS(x2 - x1);
	_deltaY := ABS(y2 - y1);
	Distance := ROUND(SQRT(SQR(_deltaX) + SQR(_deltaY)));
END;

{C_14C8_186B}PROCEDURE ComputePath(_zoneId1,_zoneId2:BYTE);
VAR
	_distance:INTEGER;
	_zoneId:BYTE;
	_reachedDistance:BOOLEAN;
	{-- --}
	{INNER_118F}PROCEDURE INNER_ResetDistance;
	BEGIN
		FOR GlobalI := 1 TO $14
		DO ZoneDistances[GlobalI] := 0;
	END;
	{-- --}
	{INNER_11BC}PROCEDURE INNER_ResetList(VAR __pHead:pt1A; __zoneId:INTEGER);
	VAR _pNewNode:pt1A;
	BEGIN
		NEW(__pHead);
		NEW(_pNewNode);
		__pHead^.f_pNext := _pNewNode;
		WITH _pNewNode^
		DO BEGIN
			f_pNext := nil;
			f_index := 0;
			f_zoneId := __zoneId;
		END;
	END;
	{-- --}
	{INNER_1227}PROCEDURE INNER_FillList(VAR bbp0c:pt1A; VAR _vReachedDistance:BOOLEAN; __distance:INTEGER);
	VAR
		_pCurNode,_pPrevNode,_pHead,_pNewNode:pt1A;
		_i:BYTE;
		__p_16:array[1..5] OF BYTE;
		_pZones:^BYTE;
		_active:BOOLEAN;
	BEGIN
		_vReachedDistance := FALSE;
		_pCurNode := bbp0c;
		NEW(bbp0c);
		_pHead := bbp0c;
		REPEAT
			_pPrevNode := _pCurNode;
			_pCurNode := _pCurNode^.f_pNext;
			DISPOSE(_pPrevNode);
			_i := 0;
			_pZones := ZoneLinks[_pCurNode^.f_zoneId]^.pZones;
			WHILE _i < ZoneLinks[_pCurNode^.f_zoneId]^.f_count
			DO BEGIN
				INC(_i);
				_active := TRUE;
				IF Zones[_pZones^]^.f_type = 1{get state}
				THEN BEGIN{else 135B}
					IF Zones[_pZones^]^.f_stateId > $7fff
					THEN _active := (State[$ffff - Zones[_pZones^]^.f_stateId] = 0)
					ELSE _active := (State[Zones[_pZones^]^.f_stateId] = 1);
				END;
				IF (ZoneDistances[_pZones^] = 0) OR (__distance = ZoneDistances[_pZones^])
				THEN IF _active
				THEN BEGIN{else 1423}
					NEW(_pNewNode);
					_pHead^.f_pNext := _pNewNode;
					_pNewNode^.f_zoneId := _pZones^;
					_pNewNode^.f_02 := _pCurNode^.f_02;
					_pNewNode^.f_index := _pCurNode^.f_index + 1;
					_pNewNode^.f_02[_pNewNode^.f_index] := _pZones^;
					IF ZoneDistances[_pZones^] = __distance
					THEN _vReachedDistance := TRUE;
					_pHead := _pNewNode;
				END;
				INC(_pZones);
			END;
		UNTIL _pCurNode^.f_pNext = nil;
		DISPOSE(_pCurNode);
		_pHead^.f_pNext := nil;
		IF bbp0c^.f_pNext = nil
		THEN _vReachedDistance := TRUE;
	END;
	{-- --}
	{INNER_146E}PROCEDURE INNER_PadList(bbp08:pt1A; __distance:INTEGER);
	BEGIN
		WHILE bbp08^.f_pNext <> nil
		DO BEGIN
			bbp08 := bbp08^.f_pNext;
			ZoneDistances[bbp08^.f_zoneId] := __distance;
		END;
	END;
	{-- --}
	{INNER_14AF}PROCEDURE INNER_MakeGraph;
	VAR
		_pPrevNode,_pCurNode_1,_pCurNode_2:pt1A;
		__p_10:INTEGER;
	BEGIN
		D_194D := 0;
		D_194C := 0;
		D_1950 := 10000;
		D_1952 := 0;
		IF (List_1^.f_pNext = nil) OR (List_2^.f_pNext = nil)
		THEN BEGIN
			_pCurNode_1 := List_1;
			REPEAT
				_pPrevNode := _pCurNode_1;
				_pCurNode_1 := _pCurNode_1^.f_pNext;
				DISPOSE(_pPrevNode);
			UNTIL _pCurNode_1 = nil;
			D_12CA := TRUE;
			{goto 17D5}
		END ELSE BEGIN
			_pCurNode_1 := List_1;
			REPEAT
				_pPrevNode := _pCurNode_1;
				_pCurNode_1 := _pCurNode_1^.f_pNext;
				DISPOSE(_pPrevNode);
				IF _distance = ZoneDistances[_pCurNode_1^.f_zoneId]
				THEN BEGIN{else 17B8}
					_pCurNode_2 := List_2;
					REPEAT
						_pCurNode_2 := _pCurNode_2^.f_pNext;
						IF _pCurNode_1^.f_zoneId = _pCurNode_2^.f_zoneId
						THEN BEGIN{else 17A8}
							D_194D := 0;
							_zoneId := _zoneId1;
							IF (_pCurNode_1^.f_index - 1) > 0
							THEN BEGIN{else 168E}
								FOR GlobalI := 1 TO (_pCurNode_1^.f_index - 1)
								DO BEGIN
									INC(D_194D);
									GlobalJ := FindPathBetween(_zoneId,_pCurNode_1^.f_02[GlobalI]);
									WITH ZoneGraph[D_194D]
									DO BEGIN
										f_x := Portals[GlobalJ]^.f_x;
										f_y := Portals[GlobalJ]^.f_y;
										f_zoneId := _zoneId;
									END;
									_zoneId := _pCurNode_1^.f_02[GlobalI];
								END;
							END;
							FOR GlobalI := _pCurNode_2^.f_index DOWNTO 1
							DO BEGIN
								INC(D_194D);
								GlobalJ := FindPathBetween(_zoneId,_pCurNode_2^.f_02[GlobalI]);
								WITH ZoneGraph[D_194D]
								DO BEGIN
									f_x := Portals[GlobalJ]^.f_x;
									f_y := Portals[GlobalJ]^.f_y;
									f_zoneId := _zoneId;
								END;
								_zoneId := _pCurNode_2^.f_02[GlobalI];
							END;
							INC(D_194D);
							GlobalJ := FindPathBetween(_zoneId,_zoneId2);
							WITH ZoneGraph[D_194D]
							DO BEGIN
								f_x := Portals[GlobalJ]^.f_x;
								f_y := Portals[GlobalJ]^.f_y;
								f_zoneId := _zoneId;
							END;
						END;
					UNTIL _pCurNode_2^.f_pNext = nil;
				END;
			UNTIL _pCurNode_1^.f_pNext = nil;
			DISPOSE(_pCurNode_1);
		END;
		_pCurNode_2 := List_2;
		WHILE _pCurNode_2^.f_pNext <> nil
		DO BEGIN
			_pPrevNode := _pCurNode_2;
			_pCurNode_2 := _pCurNode_2^.f_pNext;
			DISPOSE(_pPrevNode);
		END;
		DISPOSE(_pCurNode_2);
		IF D_12CA
		THEN BEGIN
			GuessAnimType(Actors[1]^.f_curFrame,AnimType);
			C_14C8_0A5B;
			D_12CC := 0;
			D_194D := 0;
			D_1A3B := 0;
			D_12CB := 0;
			C_16C2_00E8(D_27C4,3);
		END;
	END;
	{-- --}
BEGIN
	INNER_ResetDistance;
	_distance := 1;
	ZoneDistances[_zoneId2] := -_distance;
	ZoneDistances[_zoneId1] := _distance;
	INNER_ResetList(List_1,_zoneId1);
	INNER_ResetList(List_2,_zoneId2);
	REPEAT
		INNER_FillList(List_1,_reachedDistance,-_distance);
		IF NOT _reachedDistance
		THEN INNER_PadList(List_1,_distance + 1);
		IF NOT _reachedDistance
		THEN BEGIN{else 191B}
			INC(_distance);
			INNER_FillList(List_2,_reachedDistance,_distance);
			INNER_PadList(List_2,-_distance);
		END;
	UNTIL _reachedDistance;
	_distance := -_distance;
	INNER_MakeGraph
END;

{C_14C8_1931}FUNCTION FindZoneAt(_x,_y:INTEGER):BYTE;
VAR bp_02:BOOLEAN;
BEGIN
	FindZoneAt := 0;
	FOR GlobalI := 1 TO ZonesCount
	DO WITH Zones[GlobalI]^
	DO IF
		(_x >= f_left) AND (_x <= f_right) AND
		(_y >= f_top) AND (_y <= f_bottom)
	THEN BEGIN
		IF f_type <> 1{get state}
		THEN BEGIN
			FindZoneAt := GlobalI;
		END ELSE BEGIN
			IF f_stateId > $7fff
			THEN bp_02 := (State[$ffff - f_stateId] = 0)
			ELSE bp_02 := (State[f_stateId] = 1);
			IF bp_02
			THEN FindZoneAt := GlobalI;
		END;
	END;
END;

{C_14C8_1A5D}PROCEDURE PlayerGoesTo(_x,_y:INTEGER);
VAR
	_newX,_newY:INTEGER;
	_p_08:ARRAY[1..4] OF BYTE;
	{-- --}
	{INNER_1A09}PROCEDURE INNER_NextZone;
	BEGIN
		INC(D_194D);
		WITH ZoneGraph[D_194D]
		DO BEGIN
			f_x := _x;
			f_y := _y;
			f_zoneId := DestZoneId;
		END;
	END;
	{-- --}
BEGIN
	{-- --}
	DestZoneId := FindZoneAt(_x,_y);
	IF DestZoneId = 0
	THEN BEGIN
		_FindZoneNear(_x,_y,_newX,_newY);
		_x := _newX;
		_y := _newY;
		DestZoneId := FindZoneAt(_newX,_newY);
	END;
	{-- --}
	WITH Actors[1]^
	DO OrigZoneId := FindZoneAt(f_aX[1],f_aY[1]);
	{-- --}
	IF DestZoneId <> 0
	THEN BEGIN{else 1BFF}
		PlayerIsMoving := TRUE;
		D_12CA := FALSE;
		IF OrigZoneId <> DestZoneId
		THEN BEGIN{else 1B75}
			WITH Actors[1]^
			DO;
			ComputePath(OrigZoneId,DestZoneId);
			IF D_12CA = FALSE
			THEN BEGIN{else 1B73}
				INNER_NextZone;
				D_1A3B := 1;
				D_1A37 := OrigZoneId;
				_FindNearZone(
					Actors[1]^.f_aX[1],Actors[1]^.f_aY[1],
					ZoneGraph[2].f_zoneId,
					MovDestX,MovDestY
				);
				IF (MovDestX = -1) OR (MovDestY = -1)
				THEN BEGIN{else 1B73}
					MovDestX := ZoneGraph[D_1A3B].f_x;
					MovDestY := ZoneGraph[D_1A3B].f_y;
				END;
			END;
			{goto 1B9A}
		END ELSE BEGIN
			MovDestX := _x;
			MovDestY := _y;
			D_194D := 0;
			D_1A3B := 1;
			D_1A37 := FindZoneAt(MovDestX,MovDestY);
		END;
		IF D_12CA = FALSE
		THEN BEGIN{else 1BFF}
			StartMove(Actors[1]^.f_aX[1],Actors[1]^.f_aY[1],MovDestX,MovDestY,FALSE);
			C_0710;
			WITH Actors[1]^
			DO BEGIN
				IF (MovCos > 0.0) AND (AnimType = 0)
				THEN f_mirrorX := TRUE
				ELSE f_mirrorX := FALSE;
			END;
		END;
	END;
END;

{C_14C8_1C03}PROCEDURE MoveRefresh;
VAR
	_p_04:ARRAY[1..4] OF BYTE;
	_newX,_newY:INTEGER;
	_p___:ARRAY[1..$102] OF BYTE;
BEGIN
	IF PlayerIsMoving
	THEN WITH Actors[1]^
	DO BEGIN
		f_fb := TRUE;
		INC(AnimStep);
		IF AnimStep > AnimSteps[AnimType]
		THEN AnimStep := 1;
		f_curFrame := AnimFrames[AnimType][AnimStep];
		WITH Zones[D_1A37]^
		DO BEGIN
			IF ff_scale = 0
			THEN f_scale := Scale(f_aY[1],f_top,f_bottom,HI(f_stateId),LO(f_stateId))
			ELSE f_scale := ff_scale;
		END;
		IF f_scale <> 255
		THEN BEGIN
			f_aWidth[1] := (f_aFrameWidth[f_curFrame] * f_scale) SHR 7;
			f_aHeight[1] := (f_aFrameHeight[f_curFrame] * f_scale) SHR 7;
		END ELSE BEGIN
			f_aWidth[1] := f_aFrameWidth[f_curFrame];
			f_aHeight[1] := f_aFrameHeight[f_curFrame];
		END;
		{-- --}
		IF ABS(LONGINT(MovCurDist) - LONGINT(MovDistance)) <= MovSpeed
		THEN BEGIN
			f_aX[1] := MovDestX;
			f_aY[1] := MovDestY;
			MoveStop;
		END;
		IF (f_aX[1] = MovDestX) AND (f_aY[1] = MovDestY)
		THEN MoveStop;
		{-- --}
		IF PlayerIsMoving
		THEN WITH Zones[D_1A37]^
		DO BEGIN
			INC(MovCurDist,MovSpeed);
			_newX := ROUND(MovSrcX + MovCurDist * MovCos);
			_newY := ROUND(MovSrcY + MovCurDist * MovSin);
			IF (MovCos > 0) AND (AnimType = 0)
			THEN f_mirrorX := TRUE
			ELSE f_mirrorX := FALSE;
			f_aX[1] := _newX;
			f_aY[1] := _newY;
		END;
	END;
END;

{C_14C8_1ED2}
BEGIN
	D_12CC := 0;
	FOR GlobalI := 0 TO 18
	DO BEGIN
		D_127E[GlobalI][0] := ROUND(SIN((GlobalI * 5 * PI) / 180.0) * 32767.0);
		D_127E[GlobalI][1] := ROUND(COS((GlobalI * 5 * PI) / 180.0) * 32767.0);
	END;
END.
