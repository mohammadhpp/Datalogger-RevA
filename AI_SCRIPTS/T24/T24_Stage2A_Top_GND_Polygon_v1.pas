{==============================================================================
 Datalogger RevA - T24 Stage2A
 TOP GND POLYGON v1
 Entry point: ApplyT24_Stage2A_Top_GND_Polygon_v1
==============================================================================}

Var
    GBoard;
    GBottomPoly;
    GTopPoly;
    GBuildOK;

Function SameNetName(O, NetName);
Begin
    Result := False;
    If O = Nil Then Exit;
    If O.Net = Nil Then Exit;
    Result := UpperCase(O.Net.Name) = UpperCase(NetName);
End;

Function CountTracksOnNet(NetName);
Var BI; O; N;
Begin
    N := 0;
    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then Begin Result := -1; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(eTrackObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O := BI.FirstPCBObject;
    While O <> Nil Do
    Begin
        If SameNetName(O, NetName) Then N := N + 1;
        O := BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result := N;
End;

Function CountViasOnNet(NetName);
Var BI; O; N;
Begin
    N := 0;
    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then Begin Result := -1; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(eViaObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O := BI.FirstPCBObject;
    While O <> Nil Do
    Begin
        If SameNetName(O, NetName) Then N := N + 1;
        O := BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result := N;
End;

Function CountAllPolygons;
Var BI; O; N;
Begin
    N := 0;
    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then Begin Result := -1; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(ePolyObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O := BI.FirstPCBObject;
    While O <> Nil Do
    Begin
        N := N + 1;
        O := BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result := N;
End;

Function CountTopPolygons;
Var BI; O; N;
Begin
    N := 0;
    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then Begin Result := -1; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(ePolyObject));
    BI.AddFilter_LayerSet(MkSet(eTopLayer));
    BI.AddFilter_Method(eProcessAll);
    O := BI.FirstPCBObject;
    While O <> Nil Do
    Begin
        N := N + 1;
        O := BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result := N;
End;

Function FindBottomGNDPolygon;
Var BI; O;
Begin
    Result := Nil;
    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then Exit;
    BI.AddFilter_ObjectSet(MkSet(ePolyObject));
    BI.AddFilter_LayerSet(MkSet(eBottomLayer));
    BI.AddFilter_Method(eProcessAll);
    O := BI.FirstPCBObject;
    While O <> Nil Do
    Begin
        If SameNetName(O, 'GND') Then
        Begin
            Result := O;
            Break;
        End;
        O := BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
End;

Procedure ApplyT24_Stage2A_Top_GND_Polygon_v1;
Var I; Seg;
Begin
    GBoard := PCBServer.GetCurrentPCBBoard;

    If GBoard = Nil Then
    Begin
        ShowMessage('ABORT: open DATALOGER_RevA.PcbDoc. Nothing changed.');
        Exit;
    End;

    If CountTracksOnNet('GND') <> 117 Then
    Begin
        ShowMessage('ABORT: expected 117 GND tracks. Nothing changed.');
        Exit;
    End;

    If CountViasOnNet('GND') <> 46 Then
    Begin
        ShowMessage('ABORT: expected 46 GND vias. Nothing changed.');
        Exit;
    End;

    If CountAllPolygons <> 1 Then
    Begin
        ShowMessage('ABORT: expected exactly one existing polygon. Nothing changed.');
        Exit;
    End;

    If CountTopPolygons <> 0 Then
    Begin
        ShowMessage('ABORT: Top Layer polygon already exists. Do not rerun.');
        Exit;
    End;

    GBottomPoly := FindBottomGNDPolygon;
    If GBottomPoly = Nil Then
    Begin
        ShowMessage('ABORT: Bottom GND polygon not found. Nothing changed.');
        Exit;
    End;

    If GBottomPoly.PointCount <> 8 Then
    Begin
        ShowMessage('ABORT: Bottom GND polygon point count is not 8.');
        Exit;
    End;

    GBoard.BoardOutline.Invalidate;
    GBoard.BoardOutline.Rebuild;
    GBoard.BoardOutline.Validate;

    If GBoard.BoardOutline.PointCount <> 8 Then
    Begin
        ShowMessage('ABORT: live BoardOutline point count is not 8.');
        Exit;
    End;

    GBuildOK := True;
    GTopPoly := Nil;

    PCBServer.PreProcess;
    Try
        Try
            GTopPoly := PCBServer.PCBObjectFactory(
                ePolyObject, eNoDimension, eCreate_Default
            );

            If GTopPoly = Nil Then
                GBuildOK := False
            Else
            Begin
                GTopPoly.SetState_PointCount(GBoard.BoardOutline.PointCount);

                For I := 0 To GBoard.BoardOutline.PointCount - 1 Do
                Begin
                    Seg := GBoard.BoardOutline.Segments[I];
                    GTopPoly.SetState_Segments(I, Seg);
                End;

                GTopPoly.Layer := eTopLayer;
                GTopPoly.Net := GBottomPoly.Net;
                GTopPoly.SetState_PolygonType(eSignalLayerPolygon);
                GTopPoly.SetState_PolyHatchStyle(ePolySolid);
                GTopPoly.SetState_PourOver(ePolygonPourOver_SameNet);

                GTopPoly.SetState_AvoidObsticles(True);
                GTopPoly.SetState_ExpandOutline(False);
                GTopPoly.SetState_UseOctagons(False);

                GTopPoly.SetState_Grid(GBottomPoly.Grid);
                GTopPoly.SetState_TrackSize(GBottomPoly.TrackSize);
                GTopPoly.SetState_MinTrack(GBottomPoly.MinTrack);
                GTopPoly.SetState_BorderWidth(GBottomPoly.BorderWidth);
                GTopPoly.SetState_ArcApproximation(GBottomPoly.ArcApproximation);

                GTopPoly.SetState_RemoveDead(True);
                GTopPoly.SetState_RemoveIslandsByArea(True);
                GTopPoly.SetState_IslandAreaThreshold(5000.0);
                GTopPoly.SetState_RemoveNarrowNecks(True);
                GTopPoly.SetState_NeckWidthThreshold(MilsToCoord(10));
                GTopPoly.SetState_ClipAcuteCorners(True);
                GTopPoly.SetState_MitreCorners(True);
                GTopPoly.SetState_DrawRemovedNecks(False);
                GTopPoly.SetState_DrawRemovedIslands(False);
                GTopPoly.SetState_DrawDeadCopper(False);

                GBoard.AddPCBObject(GTopPoly);

                PCBServer.SendMessageToRobots(
                    GBoard.I_ObjectAddress,
                    c_Broadcast,
                    PCBM_BoardRegisteration,
                    GTopPoly.I_ObjectAddress
                );

                GTopPoly.Rebuild;
                GTopPoly.CopperPourValidate;
            End;
        Except
            GBuildOK := False;
        End;
    Finally
        PCBServer.PostProcess;
    End;

    If (Not GBuildOK) Or
       (CountAllPolygons <> 2) Or
       (CountTopPolygons <> 1) Or
       (CountTracksOnNet('GND') <> 117) Or
       (CountViasOnNet('GND') <> 46) Then
    Begin
        ShowMessage(
            'BUILD INCOMPLETE T24 Stage2A.'+#13#10+
            'Expected: 2 polygons / 1 Top polygon / 117 GND tracks / 46 GND vias.'+#13#10+
            'Do NOT save. Use one Ctrl+Z.'
        );
        Exit;
    End;

    ShowMessage(
        'APPLY COMPLETE T24 Stage2A Top GND Polygon v1.'+#13#10+
        'One solid GND polygon added on Top Layer.'+#13#10+
        'Outline copied from live BoardOutline (8 points).'+#13#10+
        'Bottom polygon and routing were not changed.'+#13#10+
        'No stitching vias added yet.'+#13#10+
        'FULL DRC REQUIRED BEFORE SAVE.'+#13#10+
        'Then run Snapshot Exporter v1.4.2 for Stage2B planning.'+#13#10+
        'Do not rerun.'
    );
End;
