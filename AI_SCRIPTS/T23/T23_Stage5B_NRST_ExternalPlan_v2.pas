{==============================================================================
 Datalogger RevA - T23 Stage5B - NRST / reset distribution
 EXTERNALLY PLANNED / STATIC APPLY v2

 Entry point: ApplyT23_Stage5B_NRST_v2

 Baseline PCB: 77fed8e2f76d5eed73fb5d3d81b96ce2d1ec7888 (Stage5A PASS)
 Snapshot commit: a067fc546e8a9ea8fe3dcbda82ac7a13fd932479
 Snapshot blob: 6f94abb49147c55e99795558dc3fb1cc00dc3c01

 Targets: U_MCU.6, C_NRST.1, SW_RESET.1/.2 and J_SWD.5.
 Adds EXACTLY 12 tracks / 2 vias, all on NRST.
 Track width: 8mil. Vias: 0.60 / 0.30mm (23.622 / 11.811mil).

 The local MCU/capacitor escape stays on Top. The long cross-board trunk is
 deliberately placed on Bottom between vias at (6030,5970) and (6500,6150),
 preserving Top-layer north-side MCU fanout for later signal bundles.

 v1 preflight correctly aborted before apply because its marginal diagonal
 touched the conservative expanded bbox of C_MCU_HF.1 (GND). v2 replaces that
 diagonal with a vertical-down plus diagonal pair at X=6245 / Y=5810.

 Geometry, mask clearance, connectivity and future-fanout impact were checked
 externally on the exact fresh snapshot. No route search runs inside Altium.
 No movements, polygon or save. One PCB transaction; one Ctrl+Z rolls back an
 applied candidate.

 STATUS: externally verified candidate; LIVE ALTIUM EXECUTION / DRC PENDING.
==============================================================================}
Var
    GBoard;
    GLastCollision;
    GAddedTracks;
    GAddedVias;
    GBuildOK;

Function ObjNetName(AObj);
Begin
    Result := '<none>';
    If AObj = Nil Then Exit;
    If AObj.Net <> Nil Then
        Result := AObj.Net.Name;
End;

Function SameNet(AObj, ANet);
Begin
    Result := False;

    If AObj = Nil Then Exit;
    If ANet = Nil Then Exit;
    If AObj.Net = Nil Then Exit;

    Result := UpperCase(AObj.Net.Name) = UpperCase(ANet.Name);
End;

Function LayerApplies(APrimitiveLayer, ATargetLayer);
Var
    L1;
    L2;
Begin
    L1 := UpperCase(Layer2String(APrimitiveLayer));
    L2 := UpperCase(Layer2String(ATargetLayer));

    Result := (L1 = L2) Or (L1 = 'MULTI LAYER');
End;

Function MinReal(A, B);
Begin
    If A < B Then
        Result := A
    Else
        Result := B;
End;

Function MaxReal(A, B);
Begin
    If A > B Then
        Result := A
    Else
        Result := B;
End;

Function PointInsideRect(PX, PY, L, B, R, T);
Begin
    Result :=
        (PX >= L) And
        (PX <= R) And
        (PY >= B) And
        (PY <= T);
End;

Function Cross2D(AX, AY, BX, BY, CX, CY);
Begin
    Result := ((BX - AX) * (CY - AY)) -
              ((BY - AY) * (CX - AX));
End;

Function OnSegment(AX, AY, BX, BY, PX, PY);
Var
    Eps;
Begin
    Eps := 0.001;

    Result :=
        (PX >= MinReal(AX, BX) - Eps) And
        (PX <= MaxReal(AX, BX) + Eps) And
        (PY >= MinReal(AY, BY) - Eps) And
        (PY <= MaxReal(AY, BY) + Eps) And
        (Abs(Cross2D(AX, AY, BX, BY, PX, PY)) <= Eps);
End;

Function SegmentsIntersect(
    A1X, A1Y, A2X, A2Y,
    B1X, B1Y, B2X, B2Y
);
Var
    C1;
    C2;
    C3;
    C4;
    Eps;
Begin
    Eps := 0.001;

    C1 := Cross2D(A1X, A1Y, A2X, A2Y, B1X, B1Y);
    C2 := Cross2D(A1X, A1Y, A2X, A2Y, B2X, B2Y);
    C3 := Cross2D(B1X, B1Y, B2X, B2Y, A1X, A1Y);
    C4 := Cross2D(B1X, B1Y, B2X, B2Y, A2X, A2Y);

    Result := False;

    If (((C1 > Eps) And (C2 < -Eps)) Or
        ((C1 < -Eps) And (C2 > Eps))) And
       (((C3 > Eps) And (C4 < -Eps)) Or
        ((C3 < -Eps) And (C4 > Eps))) Then
    Begin
        Result := True;
        Exit;
    End;

    If (Abs(C1) <= Eps) And OnSegment(A1X,A1Y,A2X,A2Y,B1X,B1Y) Then
    Begin
        Result := True;
        Exit;
    End;

    If (Abs(C2) <= Eps) And OnSegment(A1X,A1Y,A2X,A2Y,B2X,B2Y) Then
    Begin
        Result := True;
        Exit;
    End;

    If (Abs(C3) <= Eps) And OnSegment(B1X,B1Y,B2X,B2Y,A1X,A1Y) Then
    Begin
        Result := True;
        Exit;
    End;

    If (Abs(C4) <= Eps) And OnSegment(B1X,B1Y,B2X,B2Y,A2X,A2Y) Then
    Begin
        Result := True;
        Exit;
    End;
End;

Function PointToSegmentDistance(
    PX, PY,
    X1, Y1,
    X2, Y2
);
Var
    VX;
    VY;
    WX;
    WY;
    C1;
    C2;
    U;
    QX;
    QY;
    DX;
    DY;
Begin
    VX := X2 - X1;
    VY := Y2 - Y1;
    WX := PX - X1;
    WY := PY - Y1;

    C1 := (VX * WX) + (VY * WY);

    If C1 <= 0 Then
    Begin
        DX := PX - X1;
        DY := PY - Y1;
        Result := Sqrt((DX * DX) + (DY * DY));
        Exit;
    End;

    C2 := (VX * VX) + (VY * VY);

    If C2 <= 0.000001 Then
    Begin
        DX := PX - X1;
        DY := PY - Y1;
        Result := Sqrt((DX * DX) + (DY * DY));
        Exit;
    End;

    If C1 >= C2 Then
    Begin
        DX := PX - X2;
        DY := PY - Y2;
        Result := Sqrt((DX * DX) + (DY * DY));
        Exit;
    End;

    U := C1 / C2;
    QX := X1 + (U * VX);
    QY := Y1 + (U * VY);

    DX := PX - QX;
    DY := PY - QY;

    Result := Sqrt((DX * DX) + (DY * DY));
End;

Function SegmentDistance(
    A1X, A1Y, A2X, A2Y,
    B1X, B1Y, B2X, B2Y
);
Var
    D1;
    D2;
    D3;
    D4;
    D;
Begin
    If SegmentsIntersect(
        A1X,A1Y,A2X,A2Y,
        B1X,B1Y,B2X,B2Y
    ) Then
    Begin
        Result := 0;
        Exit;
    End;

    D1 := PointToSegmentDistance(A1X,A1Y,B1X,B1Y,B2X,B2Y);
    D2 := PointToSegmentDistance(A2X,A2Y,B1X,B1Y,B2X,B2Y);
    D3 := PointToSegmentDistance(B1X,B1Y,A1X,A1Y,A2X,A2Y);
    D4 := PointToSegmentDistance(B2X,B2Y,A1X,A1Y,A2X,A2Y);

    D := D1;
    If D2 < D Then D := D2;
    If D3 < D Then D := D3;
    If D4 < D Then D := D4;

    Result := D;
End;

Function SegmentHitsRect(
    X1, Y1, X2, Y2,
    L, B, R, T
);
Begin
    Result := False;

    If PointInsideRect(X1,Y1,L,B,R,T) Or
       PointInsideRect(X2,Y2,L,B,R,T) Then
    Begin
        Result := True;
        Exit;
    End;

    If SegmentsIntersect(X1,Y1,X2,Y2,L,B,R,B) Or
       SegmentsIntersect(X1,Y1,X2,Y2,R,B,R,T) Or
       SegmentsIntersect(X1,Y1,X2,Y2,R,T,L,T) Or
       SegmentsIntersect(X1,Y1,X2,Y2,L,T,L,B) Then
    Begin
        Result := True;
        Exit;
    End;
End;

Function PointToRectDistance(PX, PY, L, B, R, T);
Var
    DX;
    DY;
Begin
    DX := 0;
    DY := 0;

    If PX < L Then
        DX := L - PX
    Else If PX > R Then
        DX := PX - R;

    If PY < B Then
        DY := B - PY
    Else If PY > T Then
        DY := PY - T;

    Result := Sqrt((DX * DX) + (DY * DY));
End;

Function TrackClearAgainstBoard(
    ANet,
    ALayer,
    AX1, AY1, AX2, AY2,
    AWidthMil
);
Var
    BI;
    C;
    GI;
    P;
    O;
    BR;
    Margin;
    Dist;
    Limit;
    EX1;
    EY1;
    EX2;
    EY2;
    ExistingWidth;
    ViaRadius;
Begin
    Result := False;
    GLastCollision := '';

    Margin := (AWidthMil / 2.0) + 6.0;

    { Pads: exact segment against inflated conservative pad bbox. }
    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then
    Begin
        GLastCollision := 'Could not create component iterator.';
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    C := BI.FirstPCBObject;
    While C <> Nil Do
    Begin
        GI := C.GroupIterator_Create;

        If GI = Nil Then
        Begin
            GLastCollision := 'Cannot inspect component pads; aborting.';
            GBoard.BoardIterator_Destroy(BI);
            Exit;
        End;

        If GI <> Nil Then
        Begin
            GI.AddFilter_ObjectSet(MkSet(ePadObject));
            GI.AddFilter_LayerSet(AllLayers);

            P := GI.FirstPCBObject;
            While P <> Nil Do
            Begin
                If LayerApplies(P.Layer, ALayer) Then
                Begin
                    If Not SameNet(P, ANet) Then
                    Begin
                        BR := P.BoundingRectangle;

                        If SegmentHitsRect(
                            AX1,AY1,AX2,AY2,
                            CoordToMils(BR.Left)   - Margin,
                            CoordToMils(BR.Bottom) - Margin,
                            CoordToMils(BR.Right)  + Margin,
                            CoordToMils(BR.Top)    + Margin
                        ) Then
                        Begin
                            GLastCollision :=
                                'TRACK preflight hit PAD ' +
                                C.SourceDesignator + '.' + P.Name +
                                ' net=' + ObjNetName(P);

                            C.GroupIterator_Destroy(GI);
                            GBoard.BoardIterator_Destroy(BI);
                            Exit;
                        End;
                    End;
                End;

                P := GI.NextPCBObject;
            End;

            C.GroupIterator_Destroy(GI);
        End;

        C := BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);

    { Existing tracks: exact segment-to-segment copper distance. }
    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then
    Begin
        GLastCollision := 'Could not create track iterator.';
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(eTrackObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    O := BI.FirstPCBObject;
    While O <> Nil Do
    Begin
        If UpperCase(Layer2String(O.Layer)) =
           UpperCase(Layer2String(ALayer)) Then
        Begin
            If Not SameNet(O, ANet) Then
            Begin
                EX1 := CoordToMils(O.X1);
                EY1 := CoordToMils(O.Y1);
                EX2 := CoordToMils(O.X2);
                EY2 := CoordToMils(O.Y2);
                ExistingWidth := CoordToMils(O.Width);

                Dist := SegmentDistance(
                    AX1,AY1,AX2,AY2,
                    EX1,EY1,EX2,EY2
                );

                Limit := (AWidthMil / 2.0) +
                         (ExistingWidth / 2.0) +
                         6.0;

                If Dist < (Limit - 0.001) Then
                Begin
                    GLastCollision :=
                        'TRACK preflight hit TRACK net=' +
                        ObjNetName(O) +
                        ' layer=' + Layer2String(O.Layer);

                    GBoard.BoardIterator_Destroy(BI);
                    Exit;
                End;
            End;
        End;

        O := BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);

    { Existing vias: exact point-to-segment distance. }
    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then
    Begin
        GLastCollision := 'Could not create via iterator.';
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(eViaObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    O := BI.FirstPCBObject;
    While O <> Nil Do
    Begin
        If Not SameNet(O, ANet) Then
        Begin
            ViaRadius := CoordToMils(O.Size) / 2.0;

            Dist := PointToSegmentDistance(
                CoordToMils(O.X),
                CoordToMils(O.Y),
                AX1,AY1,AX2,AY2
            );

            Limit := (AWidthMil / 2.0) +
                     ViaRadius +
                     6.0;

            If Dist < (Limit - 0.001) Then
            Begin
                GLastCollision :=
                    'TRACK preflight hit VIA net=' +
                    ObjNetName(O);

                GBoard.BoardIterator_Destroy(BI);
                Exit;
            End;
        End;

        O := BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);

    Result := True;
End;

Function ViaClearAgainstBoard(
    ANet,
    AX, AY,
    ADiameterMil
);
Var
    BI;
    C;
    GI;
    P;
    O;
    BR;
    Radius;
    ExistingRadius;
    Dist;
    Limit;
    IsSame;
Begin
    Result := False;
    GLastCollision := '';

    Radius := ADiameterMil / 2.0;

    { Pads on either signal layer / Multi Layer. }
    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then
    Begin
        GLastCollision := 'Could not create component iterator for via.';
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    C := BI.FirstPCBObject;
    While C <> Nil Do
    Begin
        GI := C.GroupIterator_Create;

        If GI = Nil Then
        Begin
            GLastCollision := 'Cannot inspect component pads; aborting.';
            GBoard.BoardIterator_Destroy(BI);
            Exit;
        End;

        If GI <> Nil Then
        Begin
            GI.AddFilter_ObjectSet(MkSet(ePadObject));
            GI.AddFilter_LayerSet(AllLayers);

            P := GI.FirstPCBObject;
            While P <> Nil Do
            Begin
                If (UpperCase(Layer2String(P.Layer)) = 'TOP LAYER') Or
                   (UpperCase(Layer2String(P.Layer)) = 'BOTTOM LAYER') Or
                   (UpperCase(Layer2String(P.Layer)) = 'MULTI LAYER') Then
                Begin
                    BR := P.BoundingRectangle;

                    Dist := PointToRectDistance(
                        AX,AY,
                        CoordToMils(BR.Left),
                        CoordToMils(BR.Bottom),
                        CoordToMils(BR.Right),
                        CoordToMils(BR.Top)
                    );

                    IsSame := SameNet(P, ANet);

                    If IsSame Then
                        Limit := Radius + 8.0
                    Else
                        Limit := Radius + 8.0;

                    If Dist < (Limit - 0.001) Then
                    Begin
                        GLastCollision :=
                            'VIA preflight too close to PAD ' +
                            C.SourceDesignator + '.' + P.Name +
                            ' net=' + ObjNetName(P);

                        C.GroupIterator_Destroy(GI);
                        GBoard.BoardIterator_Destroy(BI);
                        Exit;
                    End;
                End;

                P := GI.NextPCBObject;
            End;

            C.GroupIterator_Destroy(GI);
        End;

        C := BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);

    { Tracks on Top / Bottom. }
    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then
    Begin
        GLastCollision := 'Could not create track iterator for via.';
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(eTrackObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    O := BI.FirstPCBObject;
    While O <> Nil Do
    Begin
        If (UpperCase(Layer2String(O.Layer)) = 'TOP LAYER') Or
           (UpperCase(Layer2String(O.Layer)) = 'BOTTOM LAYER') Then
        Begin
            If Not SameNet(O, ANet) Then
            Begin
                Dist := PointToSegmentDistance(
                    AX,AY,
                    CoordToMils(O.X1),
                    CoordToMils(O.Y1),
                    CoordToMils(O.X2),
                    CoordToMils(O.Y2)
                );

                Limit := Radius +
                         (CoordToMils(O.Width) / 2.0) +
                         6.0;

                If Dist < (Limit - 0.001) Then
                Begin
                    GLastCollision :=
                        'VIA preflight hit TRACK net=' +
                        ObjNetName(O);

                    GBoard.BoardIterator_Destroy(BI);
                    Exit;
                End;
            End;
        End;

        O := BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);

    { Existing vias. }
    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then
    Begin
        GLastCollision := 'Could not create via iterator for via.';
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(eViaObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    O := BI.FirstPCBObject;
    While O <> Nil Do
    Begin
        Dist := Sqrt(
            ((AX - CoordToMils(O.X)) *
             (AX - CoordToMils(O.X))) +
            ((AY - CoordToMils(O.Y)) *
             (AY - CoordToMils(O.Y)))
        );

        ExistingRadius := CoordToMils(O.Size) / 2.0;

        If SameNet(O, ANet) Then
            Limit := Radius + ExistingRadius + 8.0
        Else
            Limit := Radius + ExistingRadius + 8.0;

        If Dist < (Limit - 0.001) Then
        Begin
            GLastCollision :=
                'VIA preflight too close to existing VIA net=' +
                ObjNetName(O);

            GBoard.BoardIterator_Destroy(BI);
            Exit;
        End;

        O := BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);

    Result := True;
End;

Function CountTracksOnNet(ANetName);
Var
    BI;
    O;
    N;
Begin
    N := 0;

    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then
    Begin
        Result := -1;
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(eTrackObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    O := BI.FirstPCBObject;
    While O <> Nil Do
    Begin
        If O.Net <> Nil Then
            If UpperCase(O.Net.Name) = UpperCase(ANetName) Then
                N := N + 1;

        O := BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
    Result := N;
End;

Function CountViasOnNet(ANetName);
Var
    BI;
    O;
    N;
Begin
    N := 0;

    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then
    Begin
        Result := -1;
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(eViaObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    O := BI.FirstPCBObject;
    While O <> Nil Do
    Begin
        If O.Net <> Nil Then
            If UpperCase(O.Net.Name) = UpperCase(ANetName) Then
                N := N + 1;

        O := BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
    Result := N;
End;

Function FindComponent(ARefDes);
Var
    BI;
    O;
Begin
    Result := Nil;

    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then Exit;

    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    O := BI.FirstPCBObject;
    While O <> Nil Do
    Begin
        If UpperCase(O.SourceDesignator) = UpperCase(ARefDes) Then
        Begin
            Result := O;
            Break;
        End;

        O := BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
End;

Function FindPad(AComponent, APadName);
Var
    GI;
    P;
Begin
    Result := Nil;
    If AComponent = Nil Then Exit;

    GI := AComponent.GroupIterator_Create;
    If GI = Nil Then Exit;

    GI.AddFilter_ObjectSet(MkSet(ePadObject));
    GI.AddFilter_LayerSet(AllLayers);

    P := GI.FirstPCBObject;
    While P <> Nil Do
    Begin
        If UpperCase(P.Name) = UpperCase(APadName) Then
        Begin
            Result := P;
            Break;
        End;

        P := GI.NextPCBObject;
    End;

    AComponent.GroupIterator_Destroy(GI);
End;

Function NearMil(AValueCoord, AMil);
Begin
    Result := Abs(CoordToMils(AValueCoord) - AMil) <= 0.05;
End;

Function PadHasNet(P, ANetName);
Begin
    Result := False;

    If P = Nil Then Exit;
    If P.Net = Nil Then Exit;

    Result := UpperCase(P.Net.Name) = UpperCase(ANetName);
End;

Function PadAt(P, AX, AY);
Begin
    Result :=
        NearMil(P.X, AX) And
        NearMil(P.Y, AY);
End;

Function ExactTrackGeometry(
    T,
    ANetName,
    ALayer,
    AX1, AY1, AX2, AY2,
    AWidthMil
);
Var
    DirectMatch;
    ReverseMatch;
Begin
    Result := False;

    If T = Nil Then Exit;
    If T.Net = Nil Then Exit;

    If UpperCase(T.Net.Name) <> UpperCase(ANetName) Then Exit;

    If UpperCase(Layer2String(T.Layer)) <>
       UpperCase(Layer2String(ALayer)) Then Exit;

    If Abs(CoordToMils(T.Width) - AWidthMil) > 0.05 Then Exit;

    DirectMatch :=
        NearMil(T.X1, AX1) And NearMil(T.Y1, AY1) And
        NearMil(T.X2, AX2) And NearMil(T.Y2, AY2);

    ReverseMatch :=
        NearMil(T.X1, AX2) And NearMil(T.Y1, AY2) And
        NearMil(T.X2, AX1) And NearMil(T.Y2, AY1);

    Result := DirectMatch Or ReverseMatch;
End;

Function FindExactTrack(
    ANetName,
    ALayer,
    AX1, AY1, AX2, AY2,
    AWidthMil
);
Var
    BI;
    T;
Begin
    Result := Nil;

    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then Exit;

    BI.AddFilter_ObjectSet(MkSet(eTrackObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    T := BI.FirstPCBObject;
    While T <> Nil Do
    Begin
        If ExactTrackGeometry(
            T, ANetName, ALayer,
            AX1, AY1, AX2, AY2, AWidthMil
        ) Then
        Begin
            Result := T;
            Break;
        End;

        T := BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
End;

Procedure AddTrackMil(
    ANet,
    ALayer,
    AX1, AY1, AX2, AY2,
    AWidthMil
);
Var
    T;
Begin
    If Not GBuildOK Then Exit;

    T := PCBServer.PCBObjectFactory(
        eTrackObject, eNoDimension, eCreate_Default
    );

    If T = Nil Then
    Begin
        GBuildOK := False;
        GLastCollision := 'Track object factory failed.';
        Exit;
    End;

    T.X1 := MilsToCoord(AX1);
    T.Y1 := MilsToCoord(AY1);
    T.X2 := MilsToCoord(AX2);
    T.Y2 := MilsToCoord(AY2);
    T.Width := MilsToCoord(AWidthMil);
    T.Layer := ALayer;
    T.Net := ANet;

    GBoard.AddPCBObject(T);

    PCBServer.SendMessageToRobots(
        GBoard.I_ObjectAddress,
        c_Broadcast,
        PCBM_BoardRegisteration,
        T.I_ObjectAddress
    );

    GAddedTracks := GAddedTracks + 1;
End;

Procedure AddViaMil(
    ANet,
    AX, AY,
    ADiameterMil,
    AHoleMil
);
Var
    V;
Begin
    If Not GBuildOK Then Exit;

    V := PCBServer.PCBObjectFactory(
        eViaObject, eNoDimension, eCreate_Default
    );

    If V = Nil Then
    Begin
        GBuildOK := False;
        GLastCollision := 'Via object factory failed.';
        Exit;
    End;

    V.X := MilsToCoord(AX);
    V.Y := MilsToCoord(AY);
    V.Size := MilsToCoord(ADiameterMil);
    V.HoleSize := MilsToCoord(AHoleMil);
    V.LowLayer := eTopLayer;
    V.HighLayer := eBottomLayer;
    V.Net := ANet;

    GBoard.AddPCBObject(V);

    PCBServer.SendMessageToRobots(
        GBoard.I_ObjectAddress,
        c_Broadcast,
        PCBM_BoardRegisteration,
        V.I_ObjectAddress
    );

    GAddedVias := GAddedVias + 1;
End;

Function GuardTrack(
    ANet,
    ALayer,
    AX1, AY1, AX2, AY2,
    AWidthMil
);
Begin
    Result := TrackClearAgainstBoard(
        ANet, ALayer,
        AX1, AY1, AX2, AY2,
        AWidthMil
    );
End;

Function GuardVia(
    ANet,
    AX, AY,
    ADiameterMil
);
Begin
    Result := ViaClearAgainstBoard(
        ANet,
        AX, AY,
        ADiameterMil
    );
End;


Function GuardTrackNamed(
    ALabel,
    ANet,
    ALayer,
    AX1, AY1, AX2, AY2,
    AWidthMil
);
Var
    Why;
Begin
    Result := GuardTrack(
        ANet, ALayer,
        AX1, AY1, AX2, AY2,
        AWidthMil
    );

    If Not Result Then
    Begin
        Why := GLastCollision;
        GLastCollision :=
            ALabel + ' [' +
            FloatToStr(AX1) + ',' + FloatToStr(AY1) + ' -> ' +
            FloatToStr(AX2) + ',' + FloatToStr(AY2) + '] : ' +
            Why;
    End;
End;

Function GuardViaNamed(
    ALabel,
    ANet,
    AX, AY,
    ADiameterMil
);
Var
    Why;
Begin
    Result := GuardVia(
        ANet,
        AX, AY,
        ADiameterMil
    );

    If Not Result Then
    Begin
        Why := GLastCollision;
        GLastCollision :=
            ALabel + ' [' +
            FloatToStr(AX) + ',' + FloatToStr(AY) + '] : ' +
            Why;
    End;
End;




{ Supplemental conservative checks. Pad objects found by the board iterator
  include free pads; repeating a component-pad check is harmless. }
Function ExtraObjectClear(AKind, ANet, ALayer, AX1, AY1, AX2, AY2, AWidthMil, IsVia);
Var
    BI;
    O;
    BR;
    Relevant;
    Margin;
    LName;
Begin
    Result := False;
    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then
    Begin
        GLastCollision := 'Cannot inspect supplemental obstacles.';
        Exit;
    End;
    BI.AddFilter_ObjectSet(MkSet(AKind));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O := BI.FirstPCBObject;
    While O <> Nil Do
    Begin
        LName := UpperCase(Layer2String(O.Layer));
        If IsVia Then
            Relevant := (LName = 'TOP LAYER') Or (LName = 'BOTTOM LAYER')
        Else
            Relevant := LName = UpperCase(Layer2String(ALayer));
        If (AKind = ePadObject) And (LName = 'MULTI LAYER') Then
            Relevant := True;
        If LName = 'KEEP-OUT LAYER' Then Relevant := True;

        If Relevant Then
        Begin
            If IsVia Or (Not SameNet(O, ANet)) Or (LName = 'KEEP-OUT LAYER') Then
            Begin
                BR := O.BoundingRectangle;
                If IsVia Then
                Begin
                    Margin := (AWidthMil / 2.0) + 8.0;
                    If PointToRectDistance(AX1, AY1,
                        CoordToMils(BR.Left), CoordToMils(BR.Bottom),
                        CoordToMils(BR.Right), CoordToMils(BR.Top)) < Margin Then
                    Begin
                        GLastCollision := 'Via hits supplemental object, net=' + ObjNetName(O);
                        GBoard.BoardIterator_Destroy(BI);
                        Exit;
                    End;
                End
                Else
                Begin
                    Margin := (AWidthMil / 2.0) + 6.0;
                    If SegmentHitsRect(AX1,AY1,AX2,AY2,
                        CoordToMils(BR.Left)-Margin, CoordToMils(BR.Bottom)-Margin,
                        CoordToMils(BR.Right)+Margin, CoordToMils(BR.Top)+Margin) Then
                    Begin
                        GLastCollision := 'Track hits supplemental object, net=' + ObjNetName(O);
                        GBoard.BoardIterator_Destroy(BI);
                        Exit;
                    End;
                End;
            End;
        End;
        O := BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result := True;
End;

Function ExtraTrackClear(ANet, ALayer, AX1, AY1, AX2, AY2, AWidthMil);
Begin
    Result := False;
    If Not ExtraObjectClear(ePadObject,ANet,ALayer,AX1,AY1,AX2,AY2,AWidthMil,False) Then Exit;
    If Not ExtraObjectClear(eFillObject,ANet,ALayer,AX1,AY1,AX2,AY2,AWidthMil,False) Then Exit;
    If Not ExtraObjectClear(eRegionObject,ANet,ALayer,AX1,AY1,AX2,AY2,AWidthMil,False) Then Exit;
    If Not ExtraObjectClear(eArcObject,ANet,ALayer,AX1,AY1,AX2,AY2,AWidthMil,False) Then Exit;
    Result := True;
End;

Function ExtraViaClear(ANet, AX, AY, ADiameter);
Begin
    Result := False;
    If Not ExtraObjectClear(ePadObject,ANet,eTopLayer,AX,AY,AX,AY,ADiameter,True) Then Exit;
    If Not ExtraObjectClear(eFillObject,ANet,eTopLayer,AX,AY,AX,AY,ADiameter,True) Then Exit;
    If Not ExtraObjectClear(eRegionObject,ANet,eTopLayer,AX,AY,AX,AY,ADiameter,True) Then Exit;
    If Not ExtraObjectClear(eArcObject,ANet,eTopLayer,AX,AY,AX,AY,ADiameter,True) Then Exit;
    Result := True;
End;

Function NoPolygons;
Var BI; O;
Begin
    Result := False;
    BI := GBoard.BoardIterator_Create;
    If BI = Nil Then Exit;
    BI.AddFilter_ObjectSet(MkSet(ePolyObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O := BI.FirstPCBObject;
    Result := O = Nil;
    GBoard.BoardIterator_Destroy(BI);
End;

Function TargetPadNamed(ARef, APad, ANetName, AX, AY, ALayer);
Var C; P;
Begin
    Result := Nil;
    C := FindComponent(ARef);
    If C = Nil Then Exit;
    P := FindPad(C, APad);
    If Not PadHasNet(P, ANetName) Then Exit;
    If Not PadAt(P, AX, AY) Then Exit;
    If UpperCase(Layer2String(P.Layer)) <> UpperCase(Layer2String(ALayer)) Then Exit;
    Result := P;
End;




Function PreflightNRST_5B_v2(NetNRST);
Begin
    Result := False;
    If Not GuardTrackNamed('5B-T01',NetNRST,eTopLayer,6285,5840,6245,5840,8) Then Exit;
    If Not ExtraTrackClear(NetNRST,eTopLayer,6285,5840,6245,5840,8) Then Exit;
    If Not GuardTrackNamed('5B-T02',NetNRST,eTopLayer,6245,5840,6245,5810,8) Then Exit;
    If Not ExtraTrackClear(NetNRST,eTopLayer,6245,5840,6245,5810,8) Then Exit;
    If Not GuardTrackNamed('5B-T03',NetNRST,eTopLayer,6245,5810,6190,5780,8) Then Exit;
    If Not ExtraTrackClear(NetNRST,eTopLayer,6245,5810,6190,5780,8) Then Exit;
    If Not GuardTrackNamed('5B-T04',NetNRST,eTopLayer,6190,5780,6190,5730,8) Then Exit;
    If Not ExtraTrackClear(NetNRST,eTopLayer,6190,5780,6190,5730,8) Then Exit;
    If Not GuardTrackNamed('5B-T05',NetNRST,eTopLayer,6190,5730,6030,5730,8) Then Exit;
    If Not ExtraTrackClear(NetNRST,eTopLayer,6190,5730,6030,5730,8) Then Exit;
    If Not GuardTrackNamed('5B-T06',NetNRST,eTopLayer,6030,5730,6030,5970,8) Then Exit;
    If Not ExtraTrackClear(NetNRST,eTopLayer,6030,5730,6030,5970,8) Then Exit;
    If Not GuardTrackNamed('5B-T07',NetNRST,eBottomLayer,6030,5970,6030,6150,8) Then Exit;
    If Not ExtraTrackClear(NetNRST,eBottomLayer,6030,5970,6030,6150,8) Then Exit;
    If Not GuardTrackNamed('5B-T08',NetNRST,eBottomLayer,6030,6150,6500,6150,8) Then Exit;
    If Not ExtraTrackClear(NetNRST,eBottomLayer,6030,6150,6500,6150,8) Then Exit;
    If Not GuardTrackNamed('5B-T09',NetNRST,eTopLayer,6500,6150,6575,6225,8) Then Exit;
    If Not ExtraTrackClear(NetNRST,eTopLayer,6500,6150,6575,6225,8) Then Exit;
    If Not GuardTrackNamed('5B-T10',NetNRST,eTopLayer,6575,6225,6617.953,6321.417,8) Then Exit;
    If Not ExtraTrackClear(NetNRST,eTopLayer,6575,6225,6617.953,6321.417,8) Then Exit;
    If Not GuardTrackNamed('5B-T11',NetNRST,eTopLayer,6617.953,6321.417,6617.953,6498.583,8) Then Exit;
    If Not ExtraTrackClear(NetNRST,eTopLayer,6617.953,6321.417,6617.953,6498.583,8) Then Exit;
    If Not GuardTrackNamed('5B-T12',NetNRST,eTopLayer,6617.953,6321.417,6875,6220,8) Then Exit;
    If Not ExtraTrackClear(NetNRST,eTopLayer,6617.953,6321.417,6875,6220,8) Then Exit;
    If Not GuardViaNamed('5B-V01',NetNRST,6030,5970,23.622) Then Exit;
    If Not ExtraViaClear(NetNRST,6030,5970,23.622) Then Exit;
    If Not GuardViaNamed('5B-V02',NetNRST,6500,6150,23.622) Then Exit;
    If Not ExtraViaClear(NetNRST,6500,6150,23.622) Then Exit;
    Result := True;
End;

Procedure RedrawPCB;
Begin
    ResetParameters;
    AddStringParameter('Action', 'Redraw');
    RunProcess('PCB:Zoom');
End;

Procedure ApplyT23_Stage5B_NRST_v2;
Var
    P_MCU;
    P_C;
    P_SW1;
    P_SW2;
    P_SWD;
    AnchorDIO;
    AnchorCLK;
    NetNRST;
Begin
    GBoard := PCBServer.GetCurrentPCBBoard;
    If GBoard = Nil Then
    Begin
        ShowMessage('ABORT 5B v2: open DATALOGER_RevA.PcbDoc. Nothing changed.');
        Exit;
    End;
    If (CountTracksOnNet('NRST') <> 0) Or (CountViasOnNet('NRST') <> 0) Then
    Begin
        ShowMessage('ABORT 5B v2: NRST already routed or baseline changed. Nothing changed.');
        Exit;
    End;
    If Not NoPolygons Then
    Begin
        ShowMessage('ABORT 5B v2: baseline must have no polygons. Nothing changed.');
        Exit;
    End;
    AnchorDIO := FindExactTrack('SWDIO',eTopLayer,6675,5997.48,6875,5920,8);
    AnchorCLK := FindExactTrack('SWCLK',eTopLayer,6564.528,6056.535,6875,6120,8);
    If (AnchorDIO = Nil) Or (AnchorCLK = Nil) Then
    Begin
        ShowMessage('ABORT 5B v2: saved Stage5A anchors missing. Expected PCB 77fed8e2 / snapshot a067fc54. Nothing changed.');
        Exit;
    End;
    P_MCU := TargetPadNamed('U_MCU','6','NRST',6285,5840,eTopLayer);
    P_C := TargetPadNamed('C_NRST','1','NRST',6190,5780,eTopLayer);
    P_SW1 := TargetPadNamed('SW_RESET','1','NRST',6617.953,6321.417,eMultiLayer);
    P_SW2 := TargetPadNamed('SW_RESET','2','NRST',6617.953,6498.583,eMultiLayer);
    P_SWD := TargetPadNamed('J_SWD','5','NRST',6875,6220,eMultiLayer);
    If (P_MCU = Nil) Or (P_C = Nil) Or (P_SW1 = Nil) Or
       (P_SW2 = Nil) Or (P_SWD = Nil) Then
    Begin
        ShowMessage('ABORT 5B v2: NRST target net/layer/placement differs from a067fc54. Nothing changed.');
        Exit;
    End;
    NetNRST := P_MCU.Net;
    GLastCollision := '';
    GAddedTracks := 0;
    GAddedVias := 0;
    GBuildOK := True;
    If Not PreflightNRST_5B_v2(NetNRST) Then
    Begin
        ShowMessage('ABORT 5B v2 preflight:' + #13#10 + GLastCollision + #13#10 +
                    'Nothing added. No Ctrl+Z required.');
        Exit;
    End;

    PCBServer.PreProcess;
    Try
        Try
            AddViaMil(NetNRST,6030,5970,23.622,11.811);
            AddViaMil(NetNRST,6500,6150,23.622,11.811);
            AddTrackMil(NetNRST,eTopLayer,6285,5840,6245,5840,8);
            AddTrackMil(NetNRST,eTopLayer,6245,5840,6245,5810,8);
            AddTrackMil(NetNRST,eTopLayer,6245,5810,6190,5780,8);
            AddTrackMil(NetNRST,eTopLayer,6190,5780,6190,5730,8);
            AddTrackMil(NetNRST,eTopLayer,6190,5730,6030,5730,8);
            AddTrackMil(NetNRST,eTopLayer,6030,5730,6030,5970,8);
            AddTrackMil(NetNRST,eBottomLayer,6030,5970,6030,6150,8);
            AddTrackMil(NetNRST,eBottomLayer,6030,6150,6500,6150,8);
            AddTrackMil(NetNRST,eTopLayer,6500,6150,6575,6225,8);
            AddTrackMil(NetNRST,eTopLayer,6575,6225,6617.953,6321.417,8);
            AddTrackMil(NetNRST,eTopLayer,6617.953,6321.417,6617.953,6498.583,8);
            AddTrackMil(NetNRST,eTopLayer,6617.953,6321.417,6875,6220,8);
        Except
            GBuildOK := False;
            GLastCollision := 'Unexpected apply exception; geometry may be partial.';
        End;
    Finally
        PCBServer.PostProcess;
    End;
    If (Not GBuildOK) Or (GAddedTracks <> 12) Or (GAddedVias <> 2) Then
    Begin
        ShowMessage('BUILD INCOMPLETE 5B: ' + GLastCollision + #13#10 +
                    'AddedTracks=' + IntToStr(GAddedTracks) +
                    ', AddedVias=' + IntToStr(GAddedVias) + #13#10 +
                    'Do not save. One Ctrl+Z rolls back this transaction.');
        RedrawPCB;
        Exit;
    End;
    GBoard.AnalyzeNet(NetNRST);
    GBoard.ConnectivelyValidateNets;
    RedrawPCB;
    ShowMessage('APPLY COMPLETE Stage5B v2: 12 tracks / 2 vias.' + #13#10 +
                'NRST connected across MCU, C_NRST, SW_RESET and J_SWD.' + #13#10 +
                'DRC PENDING. Run DRC before saving. Do not rerun.');
End;
