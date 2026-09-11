{==============================================================================
 Datalogger RevA - T23 Stage 4H1
 3V3_SYS North / Upper Distribution Backbone
 EXTERNALLY PLANNED / STATIC APPLY v4 - AUDIT-ONLY CORRECTION

 NOTE: Stage4H1 v3 is already accepted and saved. DO NOT RERUN it.
 v4 preserves the exact v3 build geometry; only audit/version text changes.

 AUTHORITATIVE BASELINE
   PCB checkpoint:
     4b3fdd50c4fe619e312c0d59d6a2fae5d386c131
   Collision snapshot:
     7840d80a223e2bee4b294b8d1e744a2d4469f0cf

 ENTRY POINT
   ApplyT23_Stage4H1_3V3_North_v4

 METHOD
   - Planned outside Altium from the post-Stage4G collision snapshot.
   - NO route search / A* / grid solver runs inside Altium.
   - Altium performs only:
       baseline checks
       exact live-board preflight
       static apply
       connectivity analysis
   - No polygon.
   - No component movement.
   - No automatic save.

 SCOPE
   Establish a Bottom-layer 3V3_SYS north backbone from the already-routed
   regulator output copper and connect these upper-board consumers:

     TP_3V3_SYS
     R_SCL_PU.2
     R_SDA_PU.2
     D_ESD.5
     FB_SENSOR.1
     R_OLED_GATE.2
     U_OLED_SW.14
     C_4066.1

   Main Bottom backbone v3:
     existing 3V3 track @ (5035,5750)
       -> (4980,5750)
       -> (4980,5840)
       -> (4460,5840)
       -> (4460,5120)
       -> (5600,5120)
       -> (5600,6600)

   Why v3:
     The post-Stage4G snapshot shows two coupled Bottom obstacles:
       USB_VBUS_PROT wall:
         X=5290, Y=5480..6039.055
       OVP_K wall:
         Y=5440, X=4700..5320
         plus X=5320, Y=5260..5440
         plus Y=5260 / Y=5160 internal segments
     Therefore a simple "go lower once" route is impossible.
     v3 exits left ABOVE the OVP/USB maze, descends at X=4460,
     passes BELOW the complete OVP_K structure at Y=5120,
     then rises on the clear right-side corridor X=5600.

   New objects requested:
     24 tracks
      8 vias

   Width discipline:
     20mil main Bottom backbone
     10mil local Bottom branches / Top pad entries

 If preflight aborts:
   NOTHING is added. No Ctrl+Z is required.

 If PASS:
   DO NOT SAVE until user runs DRC.
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
                        Limit := Radius + 3.937
                    Else
                        Limit := Radius + 6.0;

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
            Limit := Radius + ExistingRadius + 3.937
        Else
            Limit := Radius + ExistingRadius + 6.0;

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
    Result := Abs(CoordToMils(AValueCoord) - AMil) <= 0.75;
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

    If Abs(CoordToMils(T.Width) - AWidthMil) > 0.75 Then Exit;

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




Function Preflight3V3_H1(Net3V3);
Begin
    Result := False;

    { ---------------------------------------------------------------
      Root via placed exactly on accepted existing 3V3_SYS Top track:
      (5005,5780) -> (5055,5730), width 10mil.
      --------------------------------------------------------------- }
    If Not GuardViaNamed(
        'H1-VROOT',
        Net3V3,
        5035,5750,
        23.622
    ) Then Exit;

    { Main Bottom backbone v3.
      This path deliberately goes around BOTH the USB_VBUS_PROT wall and
      the nested OVP_K / OVP_GATE Bottom maze instead of crossing either. }

    If Not GuardTrackNamed(
        'H1-BACKBONE-A-LEFT',
        Net3V3,eBottomLayer,
        5035,5750,
        4980,5750,
        20
    ) Then Exit;

    If Not GuardTrackNamed(
        'H1-BACKBONE-B-UP',
        Net3V3,eBottomLayer,
        4980,5750,
        4980,5840,
        20
    ) Then Exit;

    If Not GuardTrackNamed(
        'H1-BACKBONE-C-WEST',
        Net3V3,eBottomLayer,
        4980,5840,
        4460,5840,
        20
    ) Then Exit;

    If Not GuardTrackNamed(
        'H1-BACKBONE-D-SOUTH',
        Net3V3,eBottomLayer,
        4460,5840,
        4460,5120,
        20
    ) Then Exit;

    If Not GuardTrackNamed(
        'H1-BACKBONE-E-BELOW-OVP',
        Net3V3,eBottomLayer,
        4460,5120,
        5600,5120,
        20
    ) Then Exit;

    If Not GuardTrackNamed(
        'H1-BACKBONE-F-NORTH',
        Net3V3,eBottomLayer,
        5600,5120,
        5600,6600,
        20
    ) Then Exit;

    { ---------------------------------------------------------------
      TP_3V3_SYS branch
      --------------------------------------------------------------- }
    If Not GuardTrackNamed(
        'H1-TP-BOT',
        Net3V3,eBottomLayer,
        5600,5675,
        5480,5675,
        10
    ) Then Exit;

    If Not GuardViaNamed(
        'H1-V-TP',
        Net3V3,
        5480,5675,
        23.622
    ) Then Exit;

    If Not GuardTrackNamed(
        'H1-TP-TOP',
        Net3V3,eTopLayer,
        5480,5675,
        5540,5675,
        10
    ) Then Exit;

    { ---------------------------------------------------------------
      Sensor / I2C pull-up Bottom branch
      --------------------------------------------------------------- }
    If Not GuardTrackNamed(
        'H1-SENSOR-MAIN',
        Net3V3,eBottomLayer,
        5600,6600,
        4905,6600,
        20
    ) Then Exit;

    { R_SCL_PU.2 }
    If Not GuardTrackNamed(
        'H1-SCL-BOT',
        Net3V3,eBottomLayer,
        4905,6600,
        4905,6505,
        10
    ) Then Exit;

    If Not GuardViaNamed(
        'H1-V-SCL',
        Net3V3,
        4905,6505,
        23.622
    ) Then Exit;

    If Not GuardTrackNamed(
        'H1-SCL-TOP',
        Net3V3,eTopLayer,
        4905,6505,
        4865,6505,
        10
    ) Then Exit;

    { R_SDA_PU.2 }
    If Not GuardTrackNamed(
        'H1-SDA-BOT',
        Net3V3,eBottomLayer,
        4905,6505,
        4905,6435,
        10
    ) Then Exit;

    If Not GuardViaNamed(
        'H1-V-SDA',
        Net3V3,
        4905,6435,
        23.622
    ) Then Exit;

    If Not GuardTrackNamed(
        'H1-SDA-TOP',
        Net3V3,eTopLayer,
        4905,6435,
        4865,6435,
        10
    ) Then Exit;

    { D_ESD.5 local 3V3 rail }
    If Not GuardTrackNamed(
        'H1-ESD-BOT-A',
        Net3V3,eBottomLayer,
        4905,6600,
        4645,6600,
        10
    ) Then Exit;

    If Not GuardTrackNamed(
        'H1-ESD-BOT-B',
        Net3V3,eBottomLayer,
        4645,6600,
        4645,6530,
        10
    ) Then Exit;

    If Not GuardViaNamed(
        'H1-V-ESD',
        Net3V3,
        4645,6530,
        23.622
    ) Then Exit;

    If Not GuardTrackNamed(
        'H1-ESD-TOP',
        Net3V3,eTopLayer,
        4645,6530,
        4645,6584.449,
        10
    ) Then Exit;

    { FB_SENSOR.1 feed }
    If Not GuardTrackNamed(
        'H1-FBS-BOT-A',
        Net3V3,eBottomLayer,
        5155,6600,
        5155,6910,
        10
    ) Then Exit;

    If Not GuardViaNamed(
        'H1-V-FBS',
        Net3V3,
        5155,6910,
        23.622
    ) Then Exit;

    If Not GuardTrackNamed(
        'H1-FBS-TOP',
        Net3V3,eTopLayer,
        5155,6910,
        5155,6970,
        10
    ) Then Exit;

    { ---------------------------------------------------------------
      OLED logic branch
      --------------------------------------------------------------- }

    { R_OLED_GATE.2 }
    If Not GuardTrackNamed(
        'H1-OLED-GATE-BOT',
        Net3V3,eBottomLayer,
        5600,6520,
        5570,6520,
        10
    ) Then Exit;

    If Not GuardViaNamed(
        'H1-V-OLED-GATE',
        Net3V3,
        5570,6520,
        23.622
    ) Then Exit;

    If Not GuardTrackNamed(
        'H1-OLED-GATE-TOP',
        Net3V3,eTopLayer,
        5570,6520,
        5570,6565,
        10
    ) Then Exit;

    { U_OLED_SW.14 + C_4066.1 }
    If Not GuardTrackNamed(
        'H1-OLED-LOGIC-BOT-A',
        Net3V3,eBottomLayer,
        5600,6600,
        6137.441,6600,
        20
    ) Then Exit;

    If Not GuardTrackNamed(
        'H1-OLED-LOGIC-BOT-B',
        Net3V3,eBottomLayer,
        6137.441,6600,
        6137.441,6610,
        10
    ) Then Exit;

    If Not GuardViaNamed(
        'H1-V-OLED-LOGIC',
        Net3V3,
        6137.441,6610,
        23.622
    ) Then Exit;

    If Not GuardTrackNamed(
        'H1-OLED-LOGIC-TOP-A',
        Net3V3,eTopLayer,
        6137.441,6610,
        6137.441,6565,
        10
    ) Then Exit;

    If Not GuardTrackNamed(
        'H1-OLED-LOGIC-TOP-B',
        Net3V3,eTopLayer,
        6137.441,6565,
        6215,6565,
        10
    ) Then Exit;

    Result := True;
End;

Procedure RedrawPCB;
Begin
    ResetParameters;
    AddStringParameter('Action', 'Redraw');
    RunProcess('PCB:Zoom');
End;

Procedure ApplyT23_Stage4H1_3V3_North_v4;
Var
    C_TP;
    C_RSCL;
    C_RSDA;
    C_DESD;
    C_FBS;
    C_ROLEDG;
    C_UOLEDSW;
    C_C4066;

    P_TP1;
    P_RSCL2;
    P_RSDA2;
    P_DESD5;
    P_FBS1;
    P_ROLEDG2;
    P_UOLEDSW14;
    P_C40661;

    Net3V3;

    AnchorCC1;
    AnchorCC2;
    Anchor3V3Root;
    AlreadyApplied;
Begin
    GBoard := PCBServer.GetCurrentPCBBoard;

    If GBoard = Nil Then
    Begin
        ShowMessage(
            'ABORT H1: open the current DATALOGER_RevA.PcbDoc first.'
        );
        Exit;
    End;

    { ---------------------------------------------------------------
      Authoritative post-Stage4G baseline anchors.
      --------------------------------------------------------------- }
    AnchorCC1 := FindExactTrack(
        'CC1_RD_RET',eTopLayer,
        4459.528,5405,
        4432.5,5432.5,
        8
    );

    AnchorCC2 := FindExactTrack(
        'CC2_RD_RET',eBottomLayer,
        4307.5,5362.5,
        4292.5,5810,
        8
    );

    Anchor3V3Root := FindExactTrack(
        '3V3_SYS',eTopLayer,
        5005,5780,
        5055,5730,
        10
    );

    If (AnchorCC1 = Nil) Or
       (AnchorCC2 = Nil) Or
       (Anchor3V3Root = Nil) Then
    Begin
        ShowMessage(
            'ABORT H1: post-Stage4G baseline anchor missing. ' +
            'Expected PCB 4b3fdd50 / snapshot 7840d80a.'
        );
        Exit;
    End;

    { Idempotence guard: this exact Bottom backbone must not already exist. }
    AlreadyApplied := FindExactTrack(
        '3V3_SYS',eBottomLayer,
        4460,5120,
        5600,5120,
        20
    );

    If AlreadyApplied <> Nil Then
    Begin
        ShowMessage(
            'ABORT H1: Stage4H1 appears to be already applied.'
        );
        Exit;
    End;

    { ---------------------------------------------------------------
      Resolve target endpoint pads.
      --------------------------------------------------------------- }
    C_TP := FindComponent('TP_3V3_SYS');
    C_RSCL := FindComponent('R_SCL_PU');
    C_RSDA := FindComponent('R_SDA_PU');
    C_DESD := FindComponent('D_ESD');
    C_FBS := FindComponent('FB_SENSOR');
    C_ROLEDG := FindComponent('R_OLED_GATE');
    C_UOLEDSW := FindComponent('U_OLED_SW');
    C_C4066 := FindComponent('C_4066');

    If (C_TP = Nil) Or
       (C_RSCL = Nil) Or
       (C_RSDA = Nil) Or
       (C_DESD = Nil) Or
       (C_FBS = Nil) Or
       (C_ROLEDG = Nil) Or
       (C_UOLEDSW = Nil) Or
       (C_C4066 = Nil) Then
    Begin
        ShowMessage(
            'ABORT H1: a required Stage4H1 component was not found.'
        );
        Exit;
    End;

    P_TP1 := FindPad(C_TP,'1');
    P_RSCL2 := FindPad(C_RSCL,'2');
    P_RSDA2 := FindPad(C_RSDA,'2');
    P_DESD5 := FindPad(C_DESD,'5');
    P_FBS1 := FindPad(C_FBS,'1');
    P_ROLEDG2 := FindPad(C_ROLEDG,'2');
    P_UOLEDSW14 := FindPad(C_UOLEDSW,'14');
    P_C40661 := FindPad(C_C4066,'1');

    If Not PadHasNet(P_TP1,'3V3_SYS') Or
       Not PadHasNet(P_RSCL2,'3V3_SYS') Or
       Not PadHasNet(P_RSDA2,'3V3_SYS') Or
       Not PadHasNet(P_DESD5,'3V3_SYS') Or
       Not PadHasNet(P_FBS1,'3V3_SYS') Or
       Not PadHasNet(P_ROLEDG2,'3V3_SYS') Or
       Not PadHasNet(P_UOLEDSW14,'3V3_SYS') Or
       Not PadHasNet(P_C40661,'3V3_SYS') Then
    Begin
        ShowMessage(
            'ABORT H1: Stage4H1 pad/net mapping differs from snapshot 7840d80a.'
        );
        Exit;
    End;

    If Not PadAt(P_TP1,5540,5675) Or
       Not PadAt(P_RSCL2,4865,6505) Or
       Not PadAt(P_RSDA2,4865,6435) Or
       Not PadAt(P_DESD5,4645,6584.449) Or
       Not PadAt(P_FBS1,5155,6970) Or
       Not PadAt(P_ROLEDG2,5570,6565) Or
       Not PadAt(P_UOLEDSW14,6137.441,6565) Or
       Not PadAt(P_C40661,6215,6565) Then
    Begin
        ShowMessage(
            'ABORT H1: Stage4H1 placement differs from snapshot 7840d80a.'
        );
        Exit;
    End;

    Net3V3 := P_TP1.Net;

    GLastCollision := '';
    GAddedTracks := 0;
    GAddedVias := 0;
    GBuildOK := True;

    { ---------------------------------------------------------------
      LIGHTWEIGHT EXACT PREFLIGHT.
      No route search occurs inside Altium.
      --------------------------------------------------------------- }
    If Not Preflight3V3_H1(Net3V3) Then
    Begin
        ShowMessage(
            'ABORT Stage4H1 exact preflight:' + #13#10 +
            GLastCollision + #13#10 + #13#10 +
            'Nothing was added. No Ctrl+Z is required.'
        );
        Exit;
    End;

    { ---------------------------------------------------------------
      STATIC APPLY — one transaction.
      --------------------------------------------------------------- }
    PCBServer.PreProcess;
    Try
        { Root / main backbone v3 }
        AddViaMil(Net3V3,5035,5750,23.622,11.811);
        AddTrackMil(Net3V3,eBottomLayer,5035,5750,4980,5750,20);
        AddTrackMil(Net3V3,eBottomLayer,4980,5750,4980,5840,20);
        AddTrackMil(Net3V3,eBottomLayer,4980,5840,4460,5840,20);
        AddTrackMil(Net3V3,eBottomLayer,4460,5840,4460,5120,20);
        AddTrackMil(Net3V3,eBottomLayer,4460,5120,5600,5120,20);
        AddTrackMil(Net3V3,eBottomLayer,5600,5120,5600,6600,20);

        { TP_3V3_SYS }
        AddTrackMil(Net3V3,eBottomLayer,5600,5675,5480,5675,10);
        AddViaMil(Net3V3,5480,5675,23.622,11.811);
        AddTrackMil(Net3V3,eTopLayer,5480,5675,5540,5675,10);

        { Sensor / pull-up main branch }
        AddTrackMil(Net3V3,eBottomLayer,5600,6600,4905,6600,20);

        { R_SCL_PU.2 }
        AddTrackMil(Net3V3,eBottomLayer,4905,6600,4905,6505,10);
        AddViaMil(Net3V3,4905,6505,23.622,11.811);
        AddTrackMil(Net3V3,eTopLayer,4905,6505,4865,6505,10);

        { R_SDA_PU.2 }
        AddTrackMil(Net3V3,eBottomLayer,4905,6505,4905,6435,10);
        AddViaMil(Net3V3,4905,6435,23.622,11.811);
        AddTrackMil(Net3V3,eTopLayer,4905,6435,4865,6435,10);

        { D_ESD.5 }
        AddTrackMil(Net3V3,eBottomLayer,4905,6600,4645,6600,10);
        AddTrackMil(Net3V3,eBottomLayer,4645,6600,4645,6530,10);
        AddViaMil(Net3V3,4645,6530,23.622,11.811);
        AddTrackMil(Net3V3,eTopLayer,4645,6530,4645,6584.449,10);

        { FB_SENSOR.1 }
        AddTrackMil(Net3V3,eBottomLayer,5155,6600,5155,6910,10);
        AddViaMil(Net3V3,5155,6910,23.622,11.811);
        AddTrackMil(Net3V3,eTopLayer,5155,6910,5155,6970,10);

        { R_OLED_GATE.2 }
        AddTrackMil(Net3V3,eBottomLayer,5600,6520,5570,6520,10);
        AddViaMil(Net3V3,5570,6520,23.622,11.811);
        AddTrackMil(Net3V3,eTopLayer,5570,6520,5570,6565,10);

        { U_OLED_SW.14 + C_4066.1 }
        AddTrackMil(Net3V3,eBottomLayer,5600,6600,6137.441,6600,20);
        AddTrackMil(Net3V3,eBottomLayer,6137.441,6600,6137.441,6610,10);
        AddViaMil(Net3V3,6137.441,6610,23.622,11.811);
        AddTrackMil(Net3V3,eTopLayer,6137.441,6610,6137.441,6565,10);
        AddTrackMil(Net3V3,eTopLayer,6137.441,6565,6215,6565,10);

    Finally
        PCBServer.PostProcess;
    End;

    If Not GBuildOK Then
    Begin
        ShowMessage(
            'BUILD ABORT Stage4H1:' + #13#10 +
            GLastCollision + #13#10 +
            'Do NOT save. Press Ctrl+Z once.'
        );
        RedrawPCB;
        Exit;
    End;

    GBoard.AnalyzeNet(Net3V3);
    GBoard.ConnectivelyValidateNets;
    RedrawPCB;

    If (GAddedTracks = 24) And
       (GAddedVias = 8) Then
    Begin
        ShowMessage(
            'PASS Stage4H1 3V3 North v4 (v3 geometry).' + #13#10 +
            'Requested objects: 24 tracks / 8 vias.' + #13#10 +
            'Run DRC before saving.'
        );
    End
    Else
    Begin
        ShowMessage(
            'FAIL Stage4H1 object audit:' + #13#10 +
            'AddedTracks=' + IntToStr(GAddedTracks) +
            ', AddedVias=' + IntToStr(GAddedVias) + #13#10 +
            'Do NOT save. Press Ctrl+Z once.'
        );
    End;
End;
