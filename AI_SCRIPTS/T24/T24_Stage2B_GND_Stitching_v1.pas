{==============================================================================
 Datalogger RevA - T24 Stage2B
 CONTROLLED GND PLANE STITCHING v1

 Entry points:
   PreflightT24_Stage2B_GND_Stitching_v1
   ApplyT24_Stage2B_GND_Stitching_v1

 Authoritative baseline:
   PCB checkpoint: c7c57171ca952ee28726ef206b83eb5daaae330e
   Snapshot v1.4.2 generated: 2026-09-21 00:17:46
   Stage2A: PASS / SAVED / CLOSED / full DRC OK

 Scope:
   Add 11 conservative GND stitching vias between the already-poured
   Top and Bottom GND planes. No tracks, component moves, or polygon
   geometry changes are performed by this script.

 External planning audit:
   - 418 pads, 180 existing vias, and 2400 track primitives parsed.
   - Candidates restricted to the board interior; no edge stitching in v1.
   - Branding/logo rectangle deliberately excluded.
   - Candidate selection also kept away from component bounding rectangles.
   - Via geometry matches the established project via:
       diameter = 23.622 mil
       hole     = 11.811 mil
   - Apply repeats a live Altium preflight before changing the PCB.

 IMPORTANT:
   Run PREFLIGHT first.
   APPLY repeats preflight and is single-transaction.
   After APPLY: Repour All Polygons, run FULL DRC, then save/snapshot/Git_Save.
   Do not rerun after a successful apply.
==============================================================================}

Var
    GBoard;
    GBottomPoly;
    GTopPoly;
    GNetGND;
    GLastCollision;
    GBuildOK;
    GAddedVias;

Function ObjNetName(O);
Begin
    Result := '<none>';
    If O = Nil Then Exit;
    If O.Net <> Nil Then Result := O.Net.Name;
End;

Function SameNet(O, N);
Begin
    Result := False;
    If O = Nil Then Exit;
    If N = Nil Then Exit;
    If O.Net = Nil Then Exit;
    Result := UpperCase(O.Net.Name) = UpperCase(N.Name);
End;

Function PointInsideRect(PX,PY,L,B,R,T);
Begin
    Result := (PX>=L) And (PX<=R) And (PY>=B) And (PY<=T);
End;

Function PointToRectDistance(PX,PY,L,B,R,T);
Var DX;DY;
Begin
    DX:=0; DY:=0;
    If PX<L Then DX:=L-PX Else If PX>R Then DX:=PX-R;
    If PY<B Then DY:=B-PY Else If PY>T Then DY:=PY-T;
    Result:=Sqrt((DX*DX)+(DY*DY));
End;

Function PointToSegmentDistance(PX,PY,X1,Y1,X2,Y2);
Var VX;VY;WX;WY;C1;C2;U;QX;QY;DX;DY;
Begin
    VX:=X2-X1; VY:=Y2-Y1; WX:=PX-X1; WY:=PY-Y1;
    C1:=(VX*WX)+(VY*WY);
    If C1<=0 Then
    Begin
        DX:=PX-X1; DY:=PY-Y1;
        Result:=Sqrt((DX*DX)+(DY*DY));
        Exit;
    End;
    C2:=(VX*VX)+(VY*VY);
    If C2<=0.000001 Then
    Begin
        DX:=PX-X1; DY:=PY-Y1;
        Result:=Sqrt((DX*DX)+(DY*DY));
        Exit;
    End;
    If C1>=C2 Then
    Begin
        DX:=PX-X2; DY:=PY-Y2;
        Result:=Sqrt((DX*DX)+(DY*DY));
        Exit;
    End;
    U:=C1/C2;
    QX:=X1+(U*VX); QY:=Y1+(U*VY);
    DX:=PX-QX; DY:=PY-QY;
    Result:=Sqrt((DX*DX)+(DY*DY));
End;

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

Function CandidateInsideControlledInterior(X,Y,D);
Var R;
Begin
    Result:=False;
    R:=D/2.0;

    { Deliberately far from the live board edge / 8-point outline. }
    If (X-R<4300) Or (X+R>7000) Or (Y-R<4250) Or (Y+R>6500) Then
    Begin
        GLastCollision:='candidate outside controlled Stage2B interior window';
        Exit;
    End;

    { Protect the complete Stage1 logo/branding neighborhood. }
    If PointToRectDistance(X,Y,4874,4304,5422,4876)<(R+30.0) Then
    Begin
        GLastCollision:='candidate too close to Stage1 branding/logo area';
        Exit;
    End;

    Result:=True;
End;

Function CandidateClearOfComponentBounds(X,Y,D);
Var BI;C;BR;Dist;Limit;
Begin
    Result:=False;
    Limit:=(D/2.0)+30.0;

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then
    Begin
        GLastCollision:='cannot inspect component bounds';
        Exit;
    End;
    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    C:=BI.FirstPCBObject;
    While C<>Nil Do
    Begin
        BR:=C.BoundingRectangle;
        Dist:=PointToRectDistance(X,Y,
            CoordToMils(BR.Left),CoordToMils(BR.Bottom),
            CoordToMils(BR.Right),CoordToMils(BR.Top));
        If Dist<(Limit-0.001) Then
        Begin
            GLastCollision:='candidate too close to COMPONENT '+C.SourceDesignator;
            GBoard.BoardIterator_Destroy(BI);
            Exit;
        End;
        C:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result:=True;
End;

Function StitchViaClearAgainstBoard(ANet,X,Y,D);
Var BI;C;GI;P;O;BR;R;ER;Dist;Limit;LName;
Begin
    Result:=False;
    GLastCollision:='';
    R:=D/2.0;

    If Not CandidateInsideControlledInterior(X,Y,D) Then Exit;
    If Not CandidateClearOfComponentBounds(X,Y,D) Then Exit;

    { All component pads are obstacles here, including same-net GND pads.
      Stitching vias belong in open plane, not crowded against pad escapes. }
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin GLastCollision:='cannot inspect component pads'; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    C:=BI.FirstPCBObject;
    While C<>Nil Do
    Begin
        GI:=C.GroupIterator_Create;
        If GI=Nil Then
        Begin
            GBoard.BoardIterator_Destroy(BI);
            GLastCollision:='cannot inspect component pads';
            Exit;
        End;
        GI.AddFilter_ObjectSet(MkSet(ePadObject));
        GI.AddFilter_LayerSet(AllLayers);
        P:=GI.FirstPCBObject;
        While P<>Nil Do
        Begin
            LName:=UpperCase(Layer2String(P.Layer));
            If (LName='TOP LAYER') Or (LName='BOTTOM LAYER') Or
               (LName='MULTI LAYER') Then
            Begin
                BR:=P.BoundingRectangle;
                Dist:=PointToRectDistance(X,Y,
                    CoordToMils(BR.Left),CoordToMils(BR.Bottom),
                    CoordToMils(BR.Right),CoordToMils(BR.Top));
                Limit:=R+8.0;
                If Dist<(Limit-0.001) Then
                Begin
                    GLastCollision:='via too close to PAD '+C.SourceDesignator+'.'+P.Name+
                        ' net='+ObjNetName(P);
                    C.GroupIterator_Destroy(GI);
                    GBoard.BoardIterator_Destroy(BI);
                    Exit;
                End;
            End;
            P:=GI.NextPCBObject;
        End;
        C.GroupIterator_Destroy(GI);
        C:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);

    { All existing Top/Bottom tracks are obstacles, including GND tracks. }
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin GLastCollision:='cannot inspect tracks'; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(eTrackObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        LName:=UpperCase(Layer2String(O.Layer));
        If (LName='TOP LAYER') Or (LName='BOTTOM LAYER') Then
        Begin
            Dist:=PointToSegmentDistance(X,Y,
                CoordToMils(O.X1),CoordToMils(O.Y1),
                CoordToMils(O.X2),CoordToMils(O.Y2));
            Limit:=R+(CoordToMils(O.Width)/2.0)+6.0;
            If Dist<(Limit-0.001) Then
            Begin
                GLastCollision:='via too close to TRACK net='+ObjNetName(O)+
                    ' layer='+Layer2String(O.Layer);
                GBoard.BoardIterator_Destroy(BI);
                Exit;
            End;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);

    { All existing vias are obstacles, including GND vias. }
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin GLastCollision:='cannot inspect existing vias'; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(eViaObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        Dist:=Sqrt(
            ((X-CoordToMils(O.X))*(X-CoordToMils(O.X)))+
            ((Y-CoordToMils(O.Y))*(Y-CoordToMils(O.Y)))
        );
        ER:=CoordToMils(O.Size)/2.0;
        Limit:=R+ER+8.0;
        If Dist<(Limit-0.001) Then
        Begin
            GLastCollision:='via too close to existing VIA net='+ObjNetName(O);
            GBoard.BoardIterator_Destroy(BI);
            Exit;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);

    { Copper/keepout supplemental objects.
      Same-net GND poured regions are intentionally allowed. }
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin GLastCollision:='cannot inspect supplemental objects'; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(ePadObject,eFillObject,eRegionObject,eArcObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        LName:=UpperCase(Layer2String(O.Layer));
        If (LName='TOP LAYER') Or (LName='BOTTOM LAYER') Or
           (LName='MULTI LAYER') Or (LName='KEEP-OUT LAYER') Then
        Begin
            If (LName='KEEP-OUT LAYER') Or
               ((O.Net<>Nil) And (Not SameNet(O,ANet))) Then
            Begin
                BR:=O.BoundingRectangle;
                Dist:=PointToRectDistance(X,Y,
                    CoordToMils(BR.Left),CoordToMils(BR.Bottom),
                    CoordToMils(BR.Right),CoordToMils(BR.Top));
                Limit:=R+8.0;
                If Dist<(Limit-0.001) Then
                Begin
                    GLastCollision:='via too close to electrical/keepout object net='+
                        ObjNetName(O)+' layer='+Layer2String(O.Layer);
                    GBoard.BoardIterator_Destroy(BI);
                    Exit;
                End;
            End;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);

    Result:=True;
End;

Function GuardStitchVia(LabelText,ANet,X,Y,D);
Var Why;
Begin
    Result:=StitchViaClearAgainstBoard(ANet,X,Y,D);
    If Not Result Then
    Begin
        Why:=GLastCollision;
        GLastCollision:=LabelText+' ['+FloatToStr(X)+','+FloatToStr(Y)+'] : '+Why;
    End;
End;

Function BaselineReady;
Begin
    Result:=False;
    GLastCollision:='';

    If CountTracksOnNet('GND')<>117 Then
    Begin GLastCollision:='expected exactly 117 GND tracks'; Exit; End;

    If CountViasOnNet('GND')<>46 Then
    Begin GLastCollision:='expected exactly 46 GND vias; Stage2B may already have run'; Exit; End;

    If CountAllVias<>180 Then
    Begin GLastCollision:='expected exactly 180 total vias from snapshot v1.4.2'; Exit; End;

    If CountAllPolygons<>2 Then
    Begin GLastCollision:='expected exactly 2 polygons'; Exit; End;

    If CountTopPolygons<>1 Then
    Begin GLastCollision:='expected exactly 1 Top polygon'; Exit; End;

    If CountBottomPolygons<>1 Then
    Begin GLastCollision:='expected exactly 1 Bottom polygon'; Exit; End;

    GTopPoly:=FindTopGNDPolygon;
    GBottomPoly:=FindBottomGNDPolygon;
    If (GTopPoly=Nil) Or (GBottomPoly=Nil) Then
    Begin GLastCollision:='Top/Bottom GND polygon not found'; Exit; End;

    If GTopPoly.PointCount<>8 Then
    Begin GLastCollision:='Top GND polygon point count is not 8'; Exit; End;

    If GBottomPoly.PointCount<>8 Then
    Begin GLastCollision:='Bottom GND polygon point count is not 8'; Exit; End;

    GNetGND:=GBottomPoly.Net;
    If GNetGND=Nil Then
    Begin GLastCollision:='Bottom GND polygon has no GND net'; Exit; End;

    If UpperCase(GNetGND.Name)<>'GND' Then
    Begin GLastCollision:='Bottom polygon net is not GND'; Exit; End;

    Result:=True;
End;

Function PreflightAllCandidates;
Begin
    Result:=False;

    If Not GuardStitchVia('S2B-V01',GNetGND,6750,5000,23.622) Then Exit;
    If Not GuardStitchVia('S2B-V02',GNetGND,4775,4725,23.622) Then Exit;
    If Not GuardStitchVia('S2B-V03',GNetGND,6075,4425,23.622) Then Exit;
    If Not GuardStitchVia('S2B-V04',GNetGND,5100,4900,23.622) Then Exit;
    If Not GuardStitchVia('S2B-V05',GNetGND,4400,5000,23.622) Then Exit;
    If Not GuardStitchVia('S2B-V06',GNetGND,5175,6250,23.622) Then Exit;
    If Not GuardStitchVia('S2B-V07',GNetGND,5425,5575,23.622) Then Exit;
    If Not GuardStitchVia('S2B-V08',GNetGND,4450,6325,23.622) Then Exit;
    If Not GuardStitchVia('S2B-V09',GNetGND,4525,4375,23.622) Then Exit;
    If Not GuardStitchVia('S2B-V10',GNetGND,5050,5600,23.622) Then Exit;
    If Not GuardStitchVia('S2B-V11',GNetGND,5725,6075,23.622) Then Exit;

    Result:=True;
End;

Procedure AddViaMil(ANet,X,Y,D,Hole);
Var V;
Begin
    If Not GBuildOK Then Exit;
    V:=PCBServer.PCBObjectFactory(eViaObject,eNoDimension,eCreate_Default);
    If V=Nil Then
    Begin
        GBuildOK:=False;
        GLastCollision:='Via factory failed';
        Exit;
    End;

    V.X:=MilsToCoord(X);
    V.Y:=MilsToCoord(Y);
    V.Size:=MilsToCoord(D);
    V.HoleSize:=MilsToCoord(Hole);
    V.LowLayer:=eTopLayer;
    V.HighLayer:=eBottomLayer;
    V.Net:=ANet;

    GBoard.AddPCBObject(V);
    PCBServer.SendMessageToRobots(
        GBoard.I_ObjectAddress,
        c_Broadcast,
        PCBM_BoardRegisteration,
        V.I_ObjectAddress
    );
    GAddedVias:=GAddedVias+1;
End;

Procedure PreflightT24_Stage2B_GND_Stitching_v1;
Begin
    GBoard:=PCBServer.GetCurrentPCBBoard;
    If GBoard=Nil Then
    Begin
        ShowMessage('ABORT Stage2B: open DATALOGER_RevA.PcbDoc. Nothing changed.');
        Exit;
    End;

    If Not BaselineReady Then
    Begin
        ShowMessage('ABORT Stage2B baseline:'+#13#10+GLastCollision+
                    #13#10+'Nothing changed.');
        Exit;
    End;

    If Not PreflightAllCandidates Then
    Begin
        ShowMessage('ABORT Stage2B preflight:'+#13#10+GLastCollision+
                    #13#10+'Nothing changed. No Ctrl+Z required.');
        Exit;
    End;

    ShowMessage(
        'PREFLIGHT PASS T24 Stage2B GND Stitching v1.'+#13#10+
        '11/11 candidates passed live-board checks.'+#13#10+
        'No PCB geometry was changed.'+#13#10+
        'Now run ApplyT24_Stage2B_GND_Stitching_v1.'
    );
End;

Procedure ApplyT24_Stage2B_GND_Stitching_v1;
Begin
    GBoard:=PCBServer.GetCurrentPCBBoard;
    If GBoard=Nil Then
    Begin
        ShowMessage('ABORT Stage2B: open DATALOGER_RevA.PcbDoc. Nothing changed.');
        Exit;
    End;

    If Not BaselineReady Then
    Begin
        ShowMessage('ABORT Stage2B baseline:'+#13#10+GLastCollision+
                    #13#10+'Nothing changed.');
        Exit;
    End;

    If Not PreflightAllCandidates Then
    Begin
        ShowMessage('ABORT Stage2B preflight:'+#13#10+GLastCollision+
                    #13#10+'Nothing changed. No Ctrl+Z required.');
        Exit;
    End;

    GBuildOK:=True;
    GAddedVias:=0;

    PCBServer.PreProcess;
    Try
        Try
            AddViaMil(GNetGND,6750,5000,23.622,11.811);
            AddViaMil(GNetGND,4775,4725,23.622,11.811);
            AddViaMil(GNetGND,6075,4425,23.622,11.811);
            AddViaMil(GNetGND,5100,4900,23.622,11.811);
            AddViaMil(GNetGND,4400,5000,23.622,11.811);
            AddViaMil(GNetGND,5175,6250,23.622,11.811);
            AddViaMil(GNetGND,5425,5575,23.622,11.811);
            AddViaMil(GNetGND,4450,6325,23.622,11.811);
            AddViaMil(GNetGND,4525,4375,23.622,11.811);
            AddViaMil(GNetGND,5050,5600,23.622,11.811);
            AddViaMil(GNetGND,5725,6075,23.622,11.811);
        Except
            GBuildOK:=False;
            GLastCollision:='Unexpected apply exception; geometry may be partial';
        End;
    Finally
        PCBServer.PostProcess;
    End;

    If (Not GBuildOK) Or
       (GAddedVias<>11) Or
       (CountTracksOnNet('GND')<>117) Or
       (CountViasOnNet('GND')<>57) Or
       (CountAllVias<>191) Or
       (CountAllPolygons<>2) Then
    Begin
        ShowMessage(
            'BUILD INCOMPLETE T24 Stage2B.'+#13#10+
            GLastCollision+#13#10+
            'AddedVias='+IntToStr(GAddedVias)+#13#10+
            'Expected final: 117 GND tracks / 57 GND vias / 191 total vias / 2 polygons.'+#13#10+
            'DO NOT SAVE. One Ctrl+Z should roll back this transaction.'
        );
        Exit;
    End;

    ShowMessage(
        'APPLY COMPLETE T24 Stage2B GND Stitching v1.'+#13#10+
        '11 GND stitching vias added.'+#13#10+
        'Routing and polygon outlines were not changed.'+#13#10+
        'NEXT: Repour All Polygons, then run FULL DRC.'+#13#10+
        'Do NOT save until DRC is clean.'+#13#10+
        'After DRC PASS: save PCB, run Snapshot Exporter v1.4.2, then Git_Save.cmd.'+#13#10+
        'Do not rerun this script.'
    );
End;
