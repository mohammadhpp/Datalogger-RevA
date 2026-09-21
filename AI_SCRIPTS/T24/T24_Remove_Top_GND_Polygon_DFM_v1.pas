{==============================================================================
 Datalogger RevA - T24 DFM
 REMOVE OPTIONAL TOP GND POLYGON v1

 Entry points:
   PreflightT24_Remove_Top_GND_Polygon_DFM_v1
   ApplyT24_Remove_Top_GND_Polygon_DFM_v1

 Purpose:
   Remove ONLY the optional T24 Stage2A Top Layer GND polygon.
   Preserve the validated Bottom GND plane and all T23 routing.

 Authoritative baseline:
   - Current post-Stage2A / pre-Stage2B board
   - 117 GND tracks
   - 46 GND vias
   - 180 total vias
   - exactly 2 polygons: 1 Top GND + 1 Bottom GND
   - both polygon outlines have 8 points

 DFM reason:
   The bottom-only T23 closeout already passed full DRC with
   0 warnings / 0 rule violations and all Top-side GND groups
   already had deliberate Bottom-layer access.
   Stage2A added 20 Top pour-generated regions, including many
   small fragmented copper regions near dense routing. The Top
   plane is therefore optional for release and is removed as the
   lower-risk manufacturing choice.

 IMPORTANT:
   - This script does NOT remove individual REGION primitives.
   - It removes the parent Top GND polygon only.
   - After Apply: Repour All Polygons, FULL DRC, then save/snapshot/Git_Save.
   - Do NOT run Stage2B stitching after this removal.
   - Do not rerun after a successful apply.
==============================================================================}

Var
    GBoard;
    GTopPoly;
    GBottomPoly;
    GLastError;

Function CountTracksOnNet(NetName);
Var BI;O;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(eTrackObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If O.Net<>Nil Then
            If UpperCase(O.Net.Name)=UpperCase(NetName) Then N:=N+1;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountViasOnNet(NetName);
Var BI;O;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(eViaObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If O.Net<>Nil Then
            If UpperCase(O.Net.Name)=UpperCase(NetName) Then N:=N+1;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountAllVias;
Var BI;O;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(eViaObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        N:=N+1;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountAllPolygons;
Var BI;O;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(ePolyObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        N:=N+1;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountTopPolygons;
Var BI;O;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(ePolyObject));
    BI.AddFilter_LayerSet(MkSet(eTopLayer));
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        N:=N+1;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountBottomPolygons;
Var BI;O;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(ePolyObject));
    BI.AddFilter_LayerSet(MkSet(eBottomLayer));
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        N:=N+1;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function FindTopGNDPolygon;
Var BI;O;
Begin
    Result:=Nil;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Exit;
    BI.AddFilter_ObjectSet(MkSet(ePolyObject));
    BI.AddFilter_LayerSet(MkSet(eTopLayer));
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If O.Net<>Nil Then
            If UpperCase(O.Net.Name)='GND' Then
            Begin
                Result:=O;
                Break;
            End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
End;

Function FindBottomGNDPolygon;
Var BI;O;
Begin
    Result:=Nil;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Exit;
    BI.AddFilter_ObjectSet(MkSet(ePolyObject));
    BI.AddFilter_LayerSet(MkSet(eBottomLayer));
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If O.Net<>Nil Then
            If UpperCase(O.Net.Name)='GND' Then
            Begin
                Result:=O;
                Break;
            End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
End;

Function BaselineReady;
Begin
    Result:=False;
    GLastError:='';

    If CountTracksOnNet('GND')<>117 Then
    Begin GLastError:='expected exactly 117 GND tracks'; Exit; End;

    If CountViasOnNet('GND')<>46 Then
    Begin GLastError:='expected exactly 46 GND vias; Stage2B may already have run'; Exit; End;

    If CountAllVias<>180 Then
    Begin GLastError:='expected exactly 180 total vias; board is not the audited pre-Stage2B baseline'; Exit; End;

    If CountAllPolygons<>2 Then
    Begin GLastError:='expected exactly 2 polygons before Top-polygon removal'; Exit; End;

    If CountTopPolygons<>1 Then
    Begin GLastError:='expected exactly 1 Top polygon'; Exit; End;

    If CountBottomPolygons<>1 Then
    Begin GLastError:='expected exactly 1 Bottom polygon'; Exit; End;

    GTopPoly:=FindTopGNDPolygon;
    GBottomPoly:=FindBottomGNDPolygon;

    If GTopPoly=Nil Then
    Begin GLastError:='Top GND polygon not found'; Exit; End;

    If GBottomPoly=Nil Then
    Begin GLastError:='Bottom GND polygon not found'; Exit; End;

    If GTopPoly.PointCount<>8 Then
    Begin GLastError:='Top GND polygon point count is not 8'; Exit; End;

    If GBottomPoly.PointCount<>8 Then
    Begin GLastError:='Bottom GND polygon point count is not 8'; Exit; End;

    Result:=True;
End;

Procedure PreflightT24_Remove_Top_GND_Polygon_DFM_v1;
Begin
    GBoard:=PCBServer.GetCurrentPCBBoard;
    If GBoard=Nil Then
    Begin
        ShowMessage('ABORT: open DATALOGER_RevA.PcbDoc. Nothing changed.');
        Exit;
    End;

    If Not BaselineReady Then
    Begin
        ShowMessage('ABORT Top GND DFM removal preflight:'+#13#10+
                    GLastError+#13#10+
                    'Nothing changed.');
        Exit;
    End;

    ShowMessage(
        'PREFLIGHT PASS - REMOVE OPTIONAL TOP GND POLYGON v1.'+#13#10+
        'Baseline: 117 GND tracks / 46 GND vias / 180 total vias.'+#13#10+
        'Found exactly 1 Top GND polygon + 1 Bottom GND polygon.'+#13#10+
        'No PCB geometry was changed.'+#13#10+
        'Next: run ApplyT24_Remove_Top_GND_Polygon_DFM_v1.'
    );
End;

Procedure ApplyT24_Remove_Top_GND_Polygon_DFM_v1;
Begin
    GBoard:=PCBServer.GetCurrentPCBBoard;
    If GBoard=Nil Then
    Begin
        ShowMessage('ABORT: open DATALOGER_RevA.PcbDoc. Nothing changed.');
        Exit;
    End;

    If Not BaselineReady Then
    Begin
        ShowMessage('ABORT Top GND DFM removal baseline:'+#13#10+
                    GLastError+#13#10+
                    'Nothing changed.');
        Exit;
    End;

    PCBServer.PreProcess;
    Try
        GBoard.RemovePCBObject(GTopPoly);
        PCBServer.SendMessageToRobots(
            GBoard.I_ObjectAddress,
            c_Broadcast,
            PCBM_BoardRegisteration,
            GTopPoly.I_ObjectAddress
        );
    Finally
        PCBServer.PostProcess;
    End;

    GBoard.ViewManager_FullUpdate;

    GBottomPoly:=FindBottomGNDPolygon;

    If (CountAllPolygons<>1) Or
       (CountTopPolygons<>0) Or
       (CountBottomPolygons<>1) Or
       (GBottomPoly=Nil) Or
       (CountTracksOnNet('GND')<>117) Or
       (CountViasOnNet('GND')<>46) Or
       (CountAllVias<>180) Then
    Begin
        ShowMessage(
            'BUILD INCOMPLETE - TOP GND POLYGON REMOVAL.'+#13#10+
            'Expected after removal:'+#13#10+
            '1 polygon total / 0 Top / 1 Bottom GND'+#13#10+
            '117 GND tracks / 46 GND vias / 180 total vias.'+#13#10+
            'DO NOT SAVE. One Ctrl+Z should restore the prior state.'
        );
        Exit;
    End;

    If GBottomPoly.PointCount<>8 Then
    Begin
        ShowMessage(
            'BUILD INCOMPLETE - Bottom GND polygon outline changed unexpectedly.'+#13#10+
            'DO NOT SAVE. One Ctrl+Z should restore the prior state.'
        );
        Exit;
    End;

    ShowMessage(
        'APPLY COMPLETE - OPTIONAL TOP GND POLYGON REMOVED.'+#13#10+
        'Bottom GND polygon preserved.'+#13#10+
        '117 GND tracks / 46 GND vias / 180 total vias preserved.'+#13#10+
        'NEXT: Repour All Polygons, then run FULL DRC.'+#13#10+
        'Do NOT save until DRC is clean.'+#13#10+
        'After DRC PASS: save PCB, run Snapshot Exporter v1.4.2, then Git_Save.cmd.'+#13#10+
        'Do NOT run Stage2B stitching.'
    );
End;
