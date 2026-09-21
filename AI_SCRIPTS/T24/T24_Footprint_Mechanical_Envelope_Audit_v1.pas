{==============================================================================
 Datalogger RevA - T24
 FOOTPRINT MECHANICAL ENVELOPE READ-ONLY AUDIT v1

 Entry point:
   AuditT24_Footprint_Mechanical_Envelopes_v1

 Purpose:
   For the 12 representative footprint families involved in the current
   Component Clearance violations, calculate separate bounding envelopes for:
     - Pads
     - Mechanical Layer 1 primitives
     - Mechanical Layer 2 primitives
     - Top Overlay primitives

 This lets us identify whether Mechanical 1/2 is being used as body outline,
 assembly outline, or courtyard without guessing from layer names.

 READ ONLY:
   - no component/footprint/rule edit
   - no DRC
   - no polygon action
   - only writes a TXT report

 Output:
   T24_Footprint_Mechanical_Envelope_Audit.txt
==============================================================================}

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
        (S='D_NAV1') Or
        (S='R_SER3') Or
        (S='R_SCL_SER') Or
        (S='U_PMUX') Or
        (S='R_FB_TOP') Or
        (S='D_ESD1') Or
        (S='Q_SD_DRV') Or
        (S='Q_OLED') Or
        (S='C_OUT') Or
        (S='L1') Or
        (S='J_NAV') Or
        (S='J_EXT');
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
    CompBR;
Begin
    ResetBounds(HasPad,PadL,PadB,PadR,PadT);
    ResetBounds(HasM1,M1L,M1B,M1R,M1T);
    ResetBounds(HasM2,M2L,M2B,M2R,M2T);
    ResetBounds(HasOv,OvL,OvB,OvR,OvT);
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
            eRegionObject,
            eTextObject
        )
    );
    GI.AddFilter_LayerSet(AllLayers);

    O:=GI.FirstPCBObject;
    While O<>Nil Do
    Begin
        BR:=O.BoundingRectangle;

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
    AddLine('Rotation deg: '+FloatToStr(C.Rotation));
    AddLine(
        'Component BBox L/B/R/T mil: '+
        FloatToStr(CoordToMils(CompBR.Left))+' / '+
        FloatToStr(CoordToMils(CompBR.Bottom))+' / '+
        FloatToStr(CoordToMils(CompBR.Right))+' / '+
        FloatToStr(CoordToMils(CompBR.Top))
    );

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

Procedure AuditT24_Footprint_Mechanical_Envelopes_v1;
Var FN;Msg;
Begin
    GBoard:=PCBServer.GetCurrentPCBBoard;
    If GBoard=Nil Then
    Begin
        ShowMessage('ABORT: open DATALOGER_RevA.PcbDoc. Nothing changed.');
        Exit;
    End;

    GReport:=TStringList.Create;
    Try
        AddLine('Datalogger RevA - T24 Footprint Mechanical Envelope Audit v1');
        AddLine('READ ONLY');
        AddLine('PCB: '+GBoard.FileName);
        AddLine('');
        AddLine('Expected representative footprint families: 12.');

        ExportRepresentatives;

        AddLine('');
        AddLine('============================================================');
        AddLine('SUMMARY');
        AddLine('Representative components found: '+IntToStr(GFoundCount));

        If GFoundCount=12 Then
            AddLine('PASS: all 12 representative footprint families were measured.')
        Else
            AddLine('REVIEW: expected 12 representatives.');

        FN:=ExtractFilePath(GBoard.FileName)+
            'T24_Footprint_Mechanical_Envelope_Audit.txt';
        GReport.SaveToFile(FN);

        Msg:='READ-ONLY MECHANICAL ENVELOPE AUDIT COMPLETE.'+#13#10+
             'Representatives found: '+IntToStr(GFoundCount)+#13#10+
             'Report: T24_Footprint_Mechanical_Envelope_Audit.txt'+#13#10+
             'Nothing changed.';

        ShowMessage(Msg);
    Finally
        GReport.Free;
    End;
End;
