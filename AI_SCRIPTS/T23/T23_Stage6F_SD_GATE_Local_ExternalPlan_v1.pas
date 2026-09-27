{==============================================================================
 Datalogger RevA - T23 Stage6F - microSD SD_GATE local net
 EXTERNALLY PLANNED / STATIC APPLY v1

 Entry point: ApplyT23_Stage6F_SD_GATE_v1

 Baseline PCB commit: 9e7f28af5b5f9d9cb03599e6054f7a197b7ec069
 Snapshot commit:     735e943eafef5b59151990bd5991945ed5d0acd2
 Snapshot blob:       8322bf2ac27b02b79a77ba25f821b852961fdcae

 Stage scope:
   Complete SD_GATE locally across U_SD_BUF, R_GATE, Q_SD_DRV and Q_SD.

 Adds EXACTLY 9 tracks / 0 vias, all Top Layer, 8mil.
 No movement, polygon or save. One PCB transaction; one Ctrl+Z rolls back.
 Full local corridor checked on Top and Bottom from the fresh post-Stage6E snapshot.
 Minimum conservative cross-net obstacle headroom: 7.681mil.
 A tighter first candidate was rejected before script generation.
 No new via, therefore no new via-to-pad solder-mask-sliver risk.
==============================================================================}

Var
    GBoard;
    GLastCollision;
    GAddedTracks;
    GAddedVias;
    GBuildOK;

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

Function MinReal(A,B);
Begin
    If A < B Then Result := A Else Result := B;
End;

Function MaxReal(A,B);
Begin
    If A > B Then Result := A Else Result := B;
End;

Function Cross2D(AX,AY,BX,BY,CX,CY);
Begin
    Result := ((BX-AX)*(CY-AY))-((BY-AY)*(CX-AX));
End;

Function OnSegment(AX,AY,BX,BY,PX,PY);
Var E;
Begin
    E := 0.001;
    Result :=
        (PX >= MinReal(AX,BX)-E) And (PX <= MaxReal(AX,BX)+E) And
        (PY >= MinReal(AY,BY)-E) And (PY <= MaxReal(AY,BY)+E) And
        (Abs(Cross2D(AX,AY,BX,BY,PX,PY)) <= E);
End;

Function SegmentsIntersect(A1X,A1Y,A2X,A2Y,B1X,B1Y,B2X,B2Y);
Var C1; C2; C3; C4; E;
Begin
    E := 0.001;
    C1 := Cross2D(A1X,A1Y,A2X,A2Y,B1X,B1Y);
    C2 := Cross2D(A1X,A1Y,A2X,A2Y,B2X,B2Y);
    C3 := Cross2D(B1X,B1Y,B2X,B2Y,A1X,A1Y);
    C4 := Cross2D(B1X,B1Y,B2X,B2Y,A2X,A2Y);
    Result := False;
    If (((C1>E) And (C2<-E)) Or ((C1<-E) And (C2>E))) And
       (((C3>E) And (C4<-E)) Or ((C3<-E) And (C4>E))) Then
    Begin Result := True; Exit; End;
    If (Abs(C1)<=E) And OnSegment(A1X,A1Y,A2X,A2Y,B1X,B1Y) Then Begin Result:=True; Exit; End;
    If (Abs(C2)<=E) And OnSegment(A1X,A1Y,A2X,A2Y,B2X,B2Y) Then Begin Result:=True; Exit; End;
    If (Abs(C3)<=E) And OnSegment(B1X,B1Y,B2X,B2Y,A1X,A1Y) Then Begin Result:=True; Exit; End;
    If (Abs(C4)<=E) And OnSegment(B1X,B1Y,B2X,B2Y,A2X,A2Y) Then Begin Result:=True; Exit; End;
End;

Function PointInsideRect(PX,PY,L,B,R,T);
Begin
    Result := (PX>=L) And (PX<=R) And (PY>=B) And (PY<=T);
End;

Function SegmentHitsRect(X1,Y1,X2,Y2,L,B,R,T);
Begin
    Result:=False;
    If PointInsideRect(X1,Y1,L,B,R,T) Or PointInsideRect(X2,Y2,L,B,R,T) Then
    Begin Result:=True; Exit; End;
    If SegmentsIntersect(X1,Y1,X2,Y2,L,B,R,B) Or
       SegmentsIntersect(X1,Y1,X2,Y2,R,B,R,T) Or
       SegmentsIntersect(X1,Y1,X2,Y2,R,T,L,T) Or
       SegmentsIntersect(X1,Y1,X2,Y2,L,T,L,B) Then
    Begin Result:=True; Exit; End;
End;

Function PointToSegmentDistance(PX,PY,X1,Y1,X2,Y2);
Var VX;VY;WX;WY;C1;C2;U;QX;QY;DX;DY;
Begin
    VX:=X2-X1; VY:=Y2-Y1; WX:=PX-X1; WY:=PY-Y1;
    C1:=(VX*WX)+(VY*WY);
    If C1<=0 Then Begin DX:=PX-X1; DY:=PY-Y1; Result:=Sqrt((DX*DX)+(DY*DY)); Exit; End;
    C2:=(VX*VX)+(VY*VY);
    If C2<=0.000001 Then Begin DX:=PX-X1; DY:=PY-Y1; Result:=Sqrt((DX*DX)+(DY*DY)); Exit; End;
    If C1>=C2 Then Begin DX:=PX-X2; DY:=PY-Y2; Result:=Sqrt((DX*DX)+(DY*DY)); Exit; End;
    U:=C1/C2; QX:=X1+(U*VX); QY:=Y1+(U*VY);
    DX:=PX-QX; DY:=PY-QY;
    Result:=Sqrt((DX*DX)+(DY*DY));
End;

Function SegmentDistance(A1X,A1Y,A2X,A2Y,B1X,B1Y,B2X,B2Y);
Var D1;D2;D3;D4;D;
Begin
    If SegmentsIntersect(A1X,A1Y,A2X,A2Y,B1X,B1Y,B2X,B2Y) Then Begin Result:=0; Exit; End;
    D1:=PointToSegmentDistance(A1X,A1Y,B1X,B1Y,B2X,B2Y);
    D2:=PointToSegmentDistance(A2X,A2Y,B1X,B1Y,B2X,B2Y);
    D3:=PointToSegmentDistance(B1X,B1Y,A1X,A1Y,A2X,A2Y);
    D4:=PointToSegmentDistance(B2X,B2Y,A1X,A1Y,A2X,A2Y);
    D:=D1; If D2<D Then D:=D2; If D3<D Then D:=D3; If D4<D Then D:=D4;
    Result:=D;
End;

Function PointToRectDistance(PX,PY,L,B,R,T);
Var DX;DY;
Begin
    DX:=0; DY:=0;
    If PX<L Then DX:=L-PX Else If PX>R Then DX:=PX-R;
    If PY<B Then DY:=B-PY Else If PY>T Then DY:=PY-T;
    Result:=Sqrt((DX*DX)+(DY*DY));
End;

Function LayerApplies(ObjLayer, TargetLayer);
Var L1;L2;
Begin
    L1:=UpperCase(Layer2String(ObjLayer));
    L2:=UpperCase(Layer2String(TargetLayer));
    Result:=(L1=L2) Or (L1='MULTI LAYER') Or (L1='KEEP-OUT LAYER');
End;

Function TrackClearAgainstBoard(ANet,ALayer,X1,Y1,X2,Y2,W);
Var BI;C;GI;P;O;BR;Margin;Dist;Limit;EW;VR;LName;
Begin
    Result:=False;
    GLastCollision:='';
    Margin:=(W/2.0)+6.0;

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin GLastCollision:='Cannot inspect component pads.'; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    C:=BI.FirstPCBObject;
    While C<>Nil Do
    Begin
        GI:=C.GroupIterator_Create;
        If GI=Nil Then Begin GBoard.BoardIterator_Destroy(BI); GLastCollision:='Cannot inspect component pads.'; Exit; End;
        GI.AddFilter_ObjectSet(MkSet(ePadObject));
        GI.AddFilter_LayerSet(AllLayers);
        P:=GI.FirstPCBObject;
        While P<>Nil Do
        Begin
            If LayerApplies(P.Layer,ALayer) And (Not SameNet(P,ANet)) Then
            Begin
                BR:=P.BoundingRectangle;
                If SegmentHitsRect(X1,Y1,X2,Y2,
                    CoordToMils(BR.Left)-Margin,CoordToMils(BR.Bottom)-Margin,
                    CoordToMils(BR.Right)+Margin,CoordToMils(BR.Top)+Margin) Then
                Begin
                    GLastCollision:='hit PAD '+C.SourceDesignator+'.'+P.Name+' net='+ObjNetName(P);
                    C.GroupIterator_Destroy(GI); GBoard.BoardIterator_Destroy(BI); Exit;
                End;
            End;
            P:=GI.NextPCBObject;
        End;
        C.GroupIterator_Destroy(GI);
        C:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin GLastCollision:='Cannot inspect tracks.'; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(eTrackObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        LName:=UpperCase(Layer2String(O.Layer));
        If (LName=UpperCase(Layer2String(ALayer))) Or (LName='KEEP-OUT LAYER') Then
        Begin
            If (LName='KEEP-OUT LAYER') Or (Not SameNet(O,ANet)) Then
            Begin
                Dist:=SegmentDistance(X1,Y1,X2,Y2,
                    CoordToMils(O.X1),CoordToMils(O.Y1),CoordToMils(O.X2),CoordToMils(O.Y2));
                EW:=CoordToMils(O.Width);
                Limit:=(W/2.0)+(EW/2.0)+6.0;
                If Dist<(Limit-0.001) Then
                Begin
                    GLastCollision:='hit TRACK net='+ObjNetName(O)+' layer='+Layer2String(O.Layer);
                    GBoard.BoardIterator_Destroy(BI); Exit;
                End;
            End;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin GLastCollision:='Cannot inspect vias.'; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(eViaObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If Not SameNet(O,ANet) Then
        Begin
            VR:=CoordToMils(O.Size)/2.0;
            Dist:=PointToSegmentDistance(CoordToMils(O.X),CoordToMils(O.Y),X1,Y1,X2,Y2);
            Limit:=(W/2.0)+VR+6.0;
            If Dist<(Limit-0.001) Then
            Begin
                GLastCollision:='hit VIA net='+ObjNetName(O);
                GBoard.BoardIterator_Destroy(BI); Exit;
            End;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin GLastCollision:='Cannot inspect supplemental objects.'; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(ePadObject,eFillObject,eRegionObject,eArcObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If LayerApplies(O.Layer,ALayer) Then
        Begin
            LName:=UpperCase(Layer2String(O.Layer));
            If (LName='KEEP-OUT LAYER') Or ((O.Net<>Nil) And (Not SameNet(O,ANet))) Then
            Begin
                BR:=O.BoundingRectangle;
                If SegmentHitsRect(X1,Y1,X2,Y2,
                    CoordToMils(BR.Left)-Margin,CoordToMils(BR.Bottom)-Margin,
                    CoordToMils(BR.Right)+Margin,CoordToMils(BR.Top)+Margin) Then
                Begin
                    GLastCollision:='hit electrical/keepout supplemental object net='+ObjNetName(O)+
                        ' layer='+Layer2String(O.Layer);
                    GBoard.BoardIterator_Destroy(BI); Exit;
                End;
            End;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);

    Result:=True;
End;

Function ViaClearAgainstBoard(ANet,X,Y,D);
Var BI;C;GI;P;O;BR;R;ER;Dist;Limit;LName;
Begin
    Result:=False;
    GLastCollision:='';
    R:=D/2.0;

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin GLastCollision:='Cannot inspect pads for via.'; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    C:=BI.FirstPCBObject;
    While C<>Nil Do
    Begin
        GI:=C.GroupIterator_Create;
        If GI=Nil Then Begin GBoard.BoardIterator_Destroy(BI); GLastCollision:='Cannot inspect pads for via.'; Exit; End;
        GI.AddFilter_ObjectSet(MkSet(ePadObject));
        GI.AddFilter_LayerSet(AllLayers);
        P:=GI.FirstPCBObject;
        While P<>Nil Do
        Begin
            LName:=UpperCase(Layer2String(P.Layer));
            If (LName='TOP LAYER') Or (LName='BOTTOM LAYER') Or (LName='MULTI LAYER') Then
            Begin
                If Not SameNet(P,ANet) Then
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
                        C.GroupIterator_Destroy(GI); GBoard.BoardIterator_Destroy(BI); Exit;
                    End;
                End;
            End;
            P:=GI.NextPCBObject;
        End;
        C.GroupIterator_Destroy(GI);
        C:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin GLastCollision:='Cannot inspect tracks for via.'; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(eTrackObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        LName:=UpperCase(Layer2String(O.Layer));
        If (LName='TOP LAYER') Or (LName='BOTTOM LAYER') Then
        Begin
            If Not SameNet(O,ANet) Then
            Begin
                Dist:=PointToSegmentDistance(X,Y,
                    CoordToMils(O.X1),CoordToMils(O.Y1),CoordToMils(O.X2),CoordToMils(O.Y2));
                Limit:=R+(CoordToMils(O.Width)/2.0)+6.0;
                If Dist<(Limit-0.001) Then
                Begin
                    GLastCollision:='via too close to TRACK net='+ObjNetName(O);
                    GBoard.BoardIterator_Destroy(BI); Exit;
                End;
            End;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin GLastCollision:='Cannot inspect vias for via.'; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(eViaObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If Not SameNet(O,ANet) Then
        Begin
            Dist:=Sqrt(((X-CoordToMils(O.X))*(X-CoordToMils(O.X)))+
                       ((Y-CoordToMils(O.Y))*(Y-CoordToMils(O.Y))));
            ER:=CoordToMils(O.Size)/2.0;
            Limit:=R+ER+8.0;
            If Dist<(Limit-0.001) Then
            Begin
                GLastCollision:='via too close to existing VIA net='+ObjNetName(O);
                GBoard.BoardIterator_Destroy(BI); Exit;
            End;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin GLastCollision:='Cannot inspect supplemental objects for via.'; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(ePadObject,eFillObject,eRegionObject,eArcObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        LName:=UpperCase(Layer2String(O.Layer));
        If (LName='TOP LAYER') Or (LName='BOTTOM LAYER') Or (LName='MULTI LAYER') Or
           (LName='KEEP-OUT LAYER') Then
        Begin
            If (LName='KEEP-OUT LAYER') Or ((O.Net<>Nil) And (Not SameNet(O,ANet))) Then
            Begin
                BR:=O.BoundingRectangle;
                Dist:=PointToRectDistance(X,Y,
                    CoordToMils(BR.Left),CoordToMils(BR.Bottom),
                    CoordToMils(BR.Right),CoordToMils(BR.Top));
                Limit:=R+8.0;
                If Dist<(Limit-0.001) Then
                Begin
                    GLastCollision:='via too close to electrical/keepout supplemental object net='+
                        ObjNetName(O)+' layer='+Layer2String(O.Layer);
                    GBoard.BoardIterator_Destroy(BI); Exit;
                End;
            End;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);

    Result:=True;
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
        If O.Net<>Nil Then If UpperCase(O.Net.Name)=UpperCase(NetName) Then N:=N+1;
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
        If O.Net<>Nil Then If UpperCase(O.Net.Name)=UpperCase(NetName) Then N:=N+1;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function FindComponent(ARef);
Var BI;O;
Begin
    Result:=Nil;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Exit;
    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If UpperCase(O.SourceDesignator)=UpperCase(ARef) Then Begin Result:=O; Break; End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
End;

Function FindPad(C,PadName);
Var GI;P;
Begin
    Result:=Nil;
    If C=Nil Then Exit;
    GI:=C.GroupIterator_Create;
    If GI=Nil Then Exit;
    GI.AddFilter_ObjectSet(MkSet(ePadObject));
    GI.AddFilter_LayerSet(AllLayers);
    P:=GI.FirstPCBObject;
    While P<>Nil Do
    Begin
        If UpperCase(P.Name)=UpperCase(PadName) Then Begin Result:=P; Break; End;
        P:=GI.NextPCBObject;
    End;
    C.GroupIterator_Destroy(GI);
End;

Function NearMil(V,Mil);
Begin Result:=Abs(CoordToMils(V)-Mil)<=0.05; End;

Function PadHasNet(P,NetName);
Begin
    Result:=False;
    If P=Nil Then Exit;
    If P.Net=Nil Then Exit;
    Result:=UpperCase(P.Net.Name)=UpperCase(NetName);
End;

Function PadAt(P,X,Y);
Begin Result:=NearMil(P.X,X) And NearMil(P.Y,Y); End;

Function TargetPadNamed(ARef,APad,NetName,X,Y,ALayer);
Var C;P;
Begin
    Result:=Nil;
    C:=FindComponent(ARef); If C=Nil Then Exit;
    P:=FindPad(C,APad);
    If Not PadHasNet(P,NetName) Then Exit;
    If Not PadAt(P,X,Y) Then Exit;
    If UpperCase(Layer2String(P.Layer))<>UpperCase(Layer2String(ALayer)) Then Exit;
    Result:=P;
End;

Function ExactTrackGeometry(T,NetName,ALayer,X1,Y1,X2,Y2,W);
Var D;R;
Begin
    Result:=False;
    If T=Nil Then Exit;
    If T.Net=Nil Then Exit;
    If UpperCase(T.Net.Name)<>UpperCase(NetName) Then Exit;
    If UpperCase(Layer2String(T.Layer))<>UpperCase(Layer2String(ALayer)) Then Exit;
    If Abs(CoordToMils(T.Width)-W)>0.05 Then Exit;
    D:=NearMil(T.X1,X1) And NearMil(T.Y1,Y1) And NearMil(T.X2,X2) And NearMil(T.Y2,Y2);
    R:=NearMil(T.X1,X2) And NearMil(T.Y1,Y2) And NearMil(T.X2,X1) And NearMil(T.Y2,Y1);
    Result:=D Or R;
End;

Function FindExactTrack(NetName,ALayer,X1,Y1,X2,Y2,W);
Var BI;T;
Begin
    Result:=Nil;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Exit;
    BI.AddFilter_ObjectSet(MkSet(eTrackObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    T:=BI.FirstPCBObject;
    While T<>Nil Do
    Begin
        If ExactTrackGeometry(T,NetName,ALayer,X1,Y1,X2,Y2,W) Then Begin Result:=T; Break; End;
        T:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
End;

Function NoPolygons;
Var BI;O;
Begin
    Result:=False;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Exit;
    BI.AddFilter_ObjectSet(MkSet(ePolyObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    Result:=O=Nil;
    GBoard.BoardIterator_Destroy(BI);
End;

Function GuardTrackNamed(LabelText,ANet,ALayer,X1,Y1,X2,Y2,W);
Var Why;
Begin
    Result:=TrackClearAgainstBoard(ANet,ALayer,X1,Y1,X2,Y2,W);
    If Not Result Then
    Begin
        Why:=GLastCollision;
        GLastCollision:=LabelText+' ['+FloatToStr(X1)+','+FloatToStr(Y1)+' -> '+
            FloatToStr(X2)+','+FloatToStr(Y2)+'] : '+Why;
    End;
End;

Function GuardViaNamed(LabelText,ANet,X,Y,D);
Var Why;
Begin
    Result:=ViaClearAgainstBoard(ANet,X,Y,D);
    If Not Result Then
    Begin
        Why:=GLastCollision;
        GLastCollision:=LabelText+' ['+FloatToStr(X)+','+FloatToStr(Y)+'] : '+Why;
    End;
End;

Procedure AddTrackMil(ANet,ALayer,X1,Y1,X2,Y2,W);
Var T;
Begin
    If Not GBuildOK Then Exit;
    T:=PCBServer.PCBObjectFactory(eTrackObject,eNoDimension,eCreate_Default);
    If T=Nil Then Begin GBuildOK:=False; GLastCollision:='Track factory failed.'; Exit; End;
    T.X1:=MilsToCoord(X1); T.Y1:=MilsToCoord(Y1);
    T.X2:=MilsToCoord(X2); T.Y2:=MilsToCoord(Y2);
    T.Width:=MilsToCoord(W); T.Layer:=ALayer; T.Net:=ANet;
    GBoard.AddPCBObject(T);
    PCBServer.SendMessageToRobots(GBoard.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,T.I_ObjectAddress);
    GAddedTracks:=GAddedTracks+1;
End;

Procedure AddViaMil(ANet,X,Y,D,Hole);
Var V;
Begin
    If Not GBuildOK Then Exit;
    V:=PCBServer.PCBObjectFactory(eViaObject,eNoDimension,eCreate_Default);
    If V=Nil Then Begin GBuildOK:=False; GLastCollision:='Via factory failed.'; Exit; End;
    V.X:=MilsToCoord(X); V.Y:=MilsToCoord(Y);
    V.Size:=MilsToCoord(D); V.HoleSize:=MilsToCoord(Hole);
    V.LowLayer:=eTopLayer; V.HighLayer:=eBottomLayer; V.Net:=ANet;
    GBoard.AddPCBObject(V);
    PCBServer.SendMessageToRobots(GBoard.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,V.I_ObjectAddress);
    GAddedVias:=GAddedVias+1;
End;





Function Preflight6F(NetGate);
Begin
    Result:=False;
    If Not GuardTrackNamed('6F-T01',NetGate,eTopLayer,6175,5380,6397.441,5330,8) Then Exit;
    If Not GuardTrackNamed('6F-T02',NetGate,eTopLayer,6397.441,5330,6455,5330,8) Then Exit;
    If Not GuardTrackNamed('6F-T03',NetGate,eTopLayer,6455,5330,6455,5281,8) Then Exit;
    If Not GuardTrackNamed('6F-T04',NetGate,eTopLayer,6455,5281,6656.5,5281,8) Then Exit;
    If Not GuardTrackNamed('6F-T05',NetGate,eTopLayer,6656.5,5281,6656.5,5350,8) Then Exit;
    If Not GuardTrackNamed('6F-T06',NetGate,eTopLayer,6656.5,5350,6690,5350,8) Then Exit;
    If Not GuardTrackNamed('6F-T07',NetGate,eTopLayer,6397.441,5180,6690.945,5245,8) Then Exit;
    If Not GuardTrackNamed('6F-T08',NetGate,eTopLayer,6690.945,5245,6690,5350,8) Then Exit;
    If Not GuardTrackNamed('6F-T09',NetGate,eTopLayer,6690,5350,6750,5390,8) Then Exit;
    Result:=True;
End;

Procedure RedrawPCB;
Begin
    ResetParameters;
    AddStringParameter('Action','Redraw');
    RunProcess('PCB:Zoom');
End;

Procedure ApplyT23_Stage6F_SD_GATE_v1;
Var
    U10; U4; U1; RGate; QDriveGate; QSwitchGate;
    NetGate;
    Stage6EAnchor;
Begin
    GBoard:=PCBServer.GetCurrentPCBBoard;
    If GBoard=Nil Then
    Begin
        ShowMessage('ABORT 6F: open DATALOGER_RevA.PcbDoc. Nothing changed.');
        Exit;
    End;

    If Not NoPolygons Then
    Begin
        ShowMessage('ABORT 6F: baseline must still have no polygons. Nothing changed.');
        Exit;
    End;

    Stage6EAnchor:=FindExactTrack('SD_DRV_BASE',eTopLayer,6485,5380,6555,5380,8);
    If Stage6EAnchor=Nil Then
    Begin
        ShowMessage('ABORT 6F: saved Stage6E anchor missing. Expected PCB 9e7f28af / snapshot 735e943e. Nothing changed.');
        Exit;
    End;

    If (CountTracksOnNet('SD_GATE')<>0) Or (CountViasOnNet('SD_GATE')<>0) Then
    Begin
        ShowMessage('ABORT 6F: SD_GATE already contains routing. Do not rerun. Nothing changed.');
        Exit;
    End;

    U10:=TargetPadNamed('U_SD_BUF','10','SD_GATE',6175,5380,eTopLayer);
    U4:=TargetPadNamed('U_SD_BUF','4','SD_GATE',6397.441,5330,eTopLayer);
    U1:=TargetPadNamed('U_SD_BUF','1','SD_GATE',6397.441,5180,eTopLayer);
    RGate:=TargetPadNamed('R_GATE','1','SD_GATE',6690.945,5245,eTopLayer);
    QDriveGate:=TargetPadNamed('Q_SD_DRV','3','SD_GATE',6690,5350,eTopLayer);
    QSwitchGate:=TargetPadNamed('Q_SD','1','SD_GATE',6750,5390,eTopLayer);

    If (U10=Nil) Or (U4=Nil) Or (U1=Nil) Or (RGate=Nil) Or
       (QDriveGate=Nil) Or (QSwitchGate=Nil) Then
    Begin
        ShowMessage('ABORT 6F: target pad net/layer/coordinates differ from snapshot 735e943e. Nothing changed.');
        Exit;
    End;

    NetGate:=U10.Net;
    GLastCollision:='';
    GAddedTracks:=0;
    GAddedVias:=0;
    GBuildOK:=True;

    If Not Preflight6F(NetGate) Then
    Begin
        ShowMessage('ABORT 6F preflight:'+#13#10+GLastCollision+#13#10+'Nothing added. No Ctrl+Z required.');
        Exit;
    End;

    PCBServer.PreProcess;
    Try
        Try
            AddTrackMil(NetGate,eTopLayer,6175,5380,6397.441,5330,8);
            AddTrackMil(NetGate,eTopLayer,6397.441,5330,6455,5330,8);
            AddTrackMil(NetGate,eTopLayer,6455,5330,6455,5281,8);
            AddTrackMil(NetGate,eTopLayer,6455,5281,6656.5,5281,8);
            AddTrackMil(NetGate,eTopLayer,6656.5,5281,6656.5,5350,8);
            AddTrackMil(NetGate,eTopLayer,6656.5,5350,6690,5350,8);
            AddTrackMil(NetGate,eTopLayer,6397.441,5180,6690.945,5245,8);
            AddTrackMil(NetGate,eTopLayer,6690.945,5245,6690,5350,8);
            AddTrackMil(NetGate,eTopLayer,6690,5350,6750,5390,8);
        Except
            GBuildOK:=False;
            GLastCollision:='Unexpected apply exception; geometry may be partial.';
        End;
    Finally
        PCBServer.PostProcess;
    End;

    If (Not GBuildOK) Or (GAddedTracks<>9) Or (GAddedVias<>0) Then
    Begin
        ShowMessage('BUILD INCOMPLETE 6F: '+GLastCollision+#13#10+
                    'AddedTracks='+IntToStr(GAddedTracks)+', AddedVias='+IntToStr(GAddedVias)+#13#10+
                    'Do not save. One Ctrl+Z rolls back this transaction.');
        RedrawPCB;
        Exit;
    End;

    GBoard.AnalyzeNet(NetGate);
    GBoard.ConnectivelyValidateNets;
    RedrawPCB;

    ShowMessage('APPLY COMPLETE Stage6F v1: 9 tracks / 0 vias.'+#13#10+
                'SD_GATE local net is complete.'+#13#10+
                'DRC PENDING. Run DRC before saving. Do not rerun.');
End;
