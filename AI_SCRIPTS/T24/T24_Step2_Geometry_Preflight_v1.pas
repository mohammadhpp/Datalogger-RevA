{ Datalogger RevA T24 Step2 Geometry Preflight v1
  READ ONLY. Measures 16 missing courtyards plus R_OLED_GATE.
  Does not approve fabrication or modify the PCB. Run on the PENDING copy.
  Excludes text from envelopes. Includes M3, M4 and Bottom Overlay.
  Reports individual primitive bounds; track centerlines where available.
  Output: T24_Step2_Geometry_Preflight_v1.txt
}

Var
    GBoard;
    GReport;
    GFoundCount;

Procedure AddLine(S);
Begin
    GReport.Add(S);
End;

Function IsRepresentative(RefDes);
Var S;
Begin
    S:=UpperCase(RefDes);
    Result:=
        (S='U_RTC') Or
        (S='Q_SD') Or
        (S='Q_OLED') Or
        (S='J_SWD') Or
        (S='J_SHIELD') Or
        (S='J_SD') Or
        (S='J_NAV') Or
        (S='D_EXT3') Or
        (S='D_EXT2') Or
        (S='D_EXT1') Or
        (S='D_ESD') Or
        (S='D_ESD2') Or
        (S='D_ESD1') Or
        (S='C_SENSOR_BULK') Or
        (S='C_SD_MID') Or
        (S='C_OLED_BULK') Or
        (S='R_OLED_GATE');
End;

Procedure ResetBounds(Var HasAny; Var L; Var B; Var R; Var T);
Begin
    HasAny:=False;
    L:=0; B:=0; R:=0; T:=0;
End;

Procedure ExpandBounds(BR; Var HasAny; Var L; Var B; Var R; Var T);
Var BL;BB;BRi;BT;
Begin
    BL:=CoordToMils(BR.Left);
    BB:=CoordToMils(BR.Bottom);
    BRi:=CoordToMils(BR.Right);
    BT:=CoordToMils(BR.Top);

    If Not HasAny Then
    Begin
        L:=BL; B:=BB; R:=BRi; T:=BT;
        HasAny:=True;
    End
    Else
    Begin
        If BL<L Then L:=BL;
        If BB<B Then B:=BB;
        If BRi>R Then R:=BRi;
        If BT>T Then T:=BT;
    End;
End;

Procedure AddBoundsLine(LabelText,HasAny,L,B,R,T,Count);
Begin
    If Not HasAny Then
    Begin
        AddLine(LabelText+': NONE');
        Exit;
    End;

    AddLine(
        LabelText+
        ' | Count='+IntToStr(Count)+
        ' | L/B/R/T mil='+
        FloatToStr(L)+' / '+
        FloatToStr(B)+' / '+
        FloatToStr(R)+' / '+
        FloatToStr(T)+
        ' | W/H mil='+
        FloatToStr(R-L)+' / '+
        FloatToStr(T-B)+
        ' | W/H mm='+
        FloatToStr((R-L)*0.0254)+' / '+
        FloatToStr((T-B)*0.0254)
    );
End;

Procedure ExportComponentEnvelopes(C);
Var
    GI;O;BR;
    HasPad;PadL;PadB;PadR;PadT;PadN;
    HasM1;M1L;M1B;M1R;M1T;M1N;
    HasM2;M2L;M2B;M2R;M2T;M2N;
    HasOv;OvL;OvB;OvR;OvT;OvN;
    HasM3;M3L;M3B;M3R;M3T;M3N;
    HasM4;M4L;M4B;M4R;M4T;M4N;
    HasBo;BoL;BoB;BoR;BoT;BoN;
    CompBR;
Begin
    ResetBounds(HasPad,PadL,PadB,PadR,PadT);
    ResetBounds(HasM1,M1L,M1B,M1R,M1T);
    ResetBounds(HasM2,M2L,M2B,M2R,M2T);
    ResetBounds(HasOv,OvL,OvB,OvR,OvT);
    ResetBounds(HasM3,M3L,M3B,M3R,M3T);
    M3N:=0;
    ResetBounds(HasM4,M4L,M4B,M4R,M4T);
    M4N:=0;
    ResetBounds(HasBo,BoL,BoB,BoR,BoT);
    BoN:=0;
    PadN:=0; M1N:=0; M2N:=0; OvN:=0;

    GI:=C.GroupIterator_Create;
    If GI=Nil Then
    Begin
        AddLine('ERROR: GroupIterator unavailable for '+C.SourceDesignator);
        Exit;
    End;

    GI.AddFilter_ObjectSet(
        MkSet(
            ePadObject,
            eTrackObject,
            eArcObject,
            eFillObject,
            eRegionObject
        )
    );
    GI.AddFilter_LayerSet(AllLayers);

    AddLine('');
    AddLine('PRIMITIVES FOR '+C.SourceDesignator);
    O:=GI.FirstPCBObject;
    While O<>Nil Do
    Begin
        BR:=O.BoundingRectangle;
        AddLine('Object='+IntToStr(O.ObjectId)+' Layer='+IntToStr(O.Layer)+
            ' L/B/R/T mil='+FloatToStr(CoordToMils(BR.Left))+' / '+
            FloatToStr(CoordToMils(BR.Bottom))+' / '+
            FloatToStr(CoordToMils(BR.Right))+' / '+FloatToStr(CoordToMils(BR.Top)));
        If O.ObjectId=eTrackObject Then
            AddLine('Track X1/Y1/X2/Y2/W mil='+
                FloatToStr(CoordToMils(O.X1))+' / '+FloatToStr(CoordToMils(O.Y1))+' / '+
                FloatToStr(CoordToMils(O.X2))+' / '+FloatToStr(CoordToMils(O.Y2))+' / '+
                FloatToStr(CoordToMils(O.Width)));

        If O.ObjectId=ePadObject Then
        Begin
            PadN:=PadN+1;
            ExpandBounds(BR,HasPad,PadL,PadB,PadR,PadT);
        End;

        If O.Layer=eMechanical1 Then
        Begin
            M1N:=M1N+1;
            ExpandBounds(BR,HasM1,M1L,M1B,M1R,M1T);
        End;

        If O.Layer=eMechanical2 Then
        Begin
            M2N:=M2N+1;
            ExpandBounds(BR,HasM2,M2L,M2B,M2R,M2T);
        End;

        If O.Layer=eTopOverlay Then
        Begin
            OvN:=OvN+1;
            ExpandBounds(BR,HasOv,OvL,OvB,OvR,OvT);
        End;

        If O.Layer=eMechanical3 Then
        Begin
            M3N:=M3N+1;
            ExpandBounds(BR,HasM3,M3L,M3B,M3R,M3T);
        End;

        If O.Layer=eMechanical4 Then
        Begin
            M4N:=M4N+1;
            ExpandBounds(BR,HasM4,M4L,M4B,M4R,M4T);
        End;

        If O.Layer=eBottomOverlay Then
        Begin
            BoN:=BoN+1;
            ExpandBounds(BR,HasBo,BoL,BoB,BoR,BoT);
        End;

        O:=GI.NextPCBObject;
    End;

    C.GroupIterator_Destroy(GI);

    CompBR:=C.BoundingRectangle;

    AddLine('');
    AddLine('============================================================');
    AddLine('RefDes: '+C.SourceDesignator);
    AddLine('Component X/Y mil: '+
        FloatToStr(CoordToMils(C.X))+' / '+
        FloatToStr(CoordToMils(C.Y)));
    AddLine('Component layer ID: '+IntToStr(C.Layer));
    AddLine('Rotation deg: '+FloatToStr(C.Rotation));
    AddLine(
        'Component BBox L/B/R/T mil: '+
        FloatToStr(CoordToMils(CompBR.Left))+' / '+
        FloatToStr(CoordToMils(CompBR.Bottom))+' / '+
        FloatToStr(CoordToMils(CompBR.Right))+' / '+
        FloatToStr(CoordToMils(CompBR.Top))
    );

    AddBoundsLine('M3 ENVELOPE',HasM3,M3L,M3B,M3R,M3T,M3N);
    AddBoundsLine('M4 ENVELOPE',HasM4,M4L,M4B,M4R,M4T,M4N);
    AddBoundsLine('Bo ENVELOPE',HasBo,BoL,BoB,BoR,BoT,BoN);
    AddBoundsLine('PAD ENVELOPE',HasPad,PadL,PadB,PadR,PadT,PadN);
    AddBoundsLine('MECH1 ENVELOPE',HasM1,M1L,M1B,M1R,M1T,M1N);
    AddBoundsLine('MECH2 ENVELOPE',HasM2,M2L,M2B,M2R,M2T,M2N);
    AddBoundsLine('TOP OVERLAY ENVELOPE',HasOv,OvL,OvB,OvR,OvT,OvN);
End;

Procedure ExportRepresentatives;
Var BI;C;
Begin
    GFoundCount:=0;

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then
    Begin
        AddLine('ERROR: component iterator unavailable.');
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    C:=BI.FirstPCBObject;
    While C<>Nil Do
    Begin
        If IsRepresentative(C.SourceDesignator) Then
        Begin
            GFoundCount:=GFoundCount+1;
            ExportComponentEnvelopes(C);
        End;
        C:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
End;


Procedure ExportBoardSilkInventory;
Var BI;C;GI;O;TN;BN;PN;
Begin
    AddLine('');
    AddLine('=== ALL COMPONENTS: SILK TRACK/ARC COUNTS (TEXT EXCLUDED) ===');
    AddLine('Zero means no track/arc outline; fills/regions/marks need separate interpretation.');
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Exit;
    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    C:=BI.FirstPCBObject;
    While C<>Nil Do
    Begin
        TN:=0; BN:=0; PN:=0;
        GI:=C.GroupIterator_Create;
        If GI<>Nil Then
        Begin
            GI.AddFilter_ObjectSet(MkSet(eTrackObject,eArcObject));
            GI.AddFilter_LayerSet(AllLayers);
            O:=GI.FirstPCBObject;
            While O<>Nil Do
            Begin
                If O.Layer=eTopOverlay Then TN:=TN+1;
                If O.Layer=eBottomOverlay Then BN:=BN+1;
                If (O.Layer=eMechanical2) Or (O.Layer=eMechanical4) Then PN:=PN+1;
                O:=GI.NextPCBObject;
            End;
            C.GroupIterator_Destroy(GI);
            AddLine(C.SourceDesignator+' | SideID='+IntToStr(C.Layer)+
                ' | TopSilk='+IntToStr(TN)+' | BottomSilk='+IntToStr(BN)+
                ' | M2/M4 tracks/arcs='+IntToStr(PN));
        End
        Else AddLine('ERROR: iterator unavailable for '+C.SourceDesignator);
        C:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
End;

Procedure PreflightT24_Step2_Geometry_v1;
Var FN;Msg;
Begin
    GBoard:=PCBServer.GetCurrentPCBBoard;
    If GBoard=Nil Then
    Begin
        ShowMessage('ABORT: open DATALOGER_RevA.PcbDoc. Nothing changed.');
        Exit;
    End;

    If UpperCase(ExtractFileName(GBoard.FileName))<>'DATALOGER_REVA_T24_COURTYARD_PENDING.PCBDOC' Then
    Begin
        ShowMessage('ABORT: activate DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc. Nothing changed.');
        Exit;
    End;

    GReport:=TStringList.Create;
    Try
        AddLine('Datalogger RevA - T24 Step2 Geometry Preflight v1');
        AddLine('READ ONLY');
        AddLine('PCB: '+GBoard.FileName);
        AddLine('');
        AddLine('Expected target components: 17.');

        ExportRepresentatives;
        ExportBoardSilkInventory;

        AddLine('');
        AddLine('============================================================');
        AddLine('SUMMARY');
        AddLine('Representative components found: '+IntToStr(GFoundCount));

        If GFoundCount=17 Then
            AddLine('DATA COMPLETE (NOT DRC PASS): all 17 target components were measured.')
        Else
            AddLine('REVIEW: expected 17 representatives.');

        FN:=ExtractFilePath(GBoard.FileName)+
            'T24_Step2_Geometry_Preflight_v1.txt';
        GReport.SaveToFile(FN);

        Msg:='READ-ONLY MECHANICAL ENVELOPE AUDIT COMPLETE.'+#13#10+
             'Representatives found: '+IntToStr(GFoundCount)+#13#10+
             'Report: T24_Step2_Geometry_Preflight_v1.txt'+#13#10+
             'Nothing changed.';

        ShowMessage(Msg);
    Finally
        GReport.Free;
    End;
End;
