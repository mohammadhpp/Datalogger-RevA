{==============================================================================
 Datalogger RevA - T24
 FOOTPRINT LAYER / COURTYARD READ-ONLY AUDIT v1

 Entry point:
   AuditT24_Footprint_Layers_v1

 Purpose:
   Inspect representative components for the 12 unique footprint families
   involved in the current 21 Component Clearance violations.

 Representatives:
   D_NAV1     = SC70-6
   R_SER3     = 0805 resistor
   R_SCL_SER  = 0603 resistor
   U_PMUX     = TI DRL / SOT-5X3-8
   R_FB_TOP   = 1206 resistor
   D_ESD1     = SOT23-6
   Q_SD_DRV   = SOT23 / TO-236AB
   Q_OLED     = AOS SOT23
   C_OUT      = TDK C2012 / 0805 capacitor
   L1         = Murata DFE322512F
   J_NAV      = 1x5 2.54mm THT header
   J_EXT      = JST PA 6-pin THT header

 Purpose of this audit:
   Determine whether the footprints already contain Courtyard / Assembly /
   mechanical primitives that can support a valid Component Clearance check
   before adding any new 3D/Component Body.

 READ ONLY:
   - no component move
   - no footprint edit
   - no rule edit
   - no DRC or polygon action
   - only writes a TXT report

 Output:
   T24_Footprint_Layer_Courtyard_Audit.txt
==============================================================================}

Var
    GBoard;
    GReport;
    GFoundCount;

Procedure AddLine(S);
Begin
    GReport.Add(S);
End;

Function ObjKindText(O);
Begin
    Result:='UNKNOWN';
    If O=Nil Then Exit;

    If O.ObjectId=ePadObject Then Result:='PAD'
    Else If O.ObjectId=eTrackObject Then Result:='TRACK'
    Else If O.ObjectId=eArcObject Then Result:='ARC'
    Else If O.ObjectId=eTextObject Then Result:='TEXT'
    Else If O.ObjectId=eFillObject Then Result:='FILL'
    Else If O.ObjectId=eRegionObject Then Result:='REGION'
    Else If O.ObjectId=eComponentBodyObject Then Result:='COMPONENT_BODY'
    Else Result:='OBJECT_ID_'+IntToStr(O.ObjectId);
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

Procedure ExportComponentPrimitives(C);
Var GI;O;N;BR;
Begin
    AddLine('');
    AddLine('============================================================');
    AddLine('RefDes: '+C.SourceDesignator);
    AddLine('Component Layer: '+Layer2String(C.Layer));
    AddLine('X mil: '+FloatToStr(CoordToMils(C.X)));
    AddLine('Y mil: '+FloatToStr(CoordToMils(C.Y)));
    AddLine('Rotation deg: '+FloatToStr(C.Rotation));

    BR:=C.BoundingRectangle;
    AddLine('Component BBox L/B/R/T mil: '+
        FloatToStr(CoordToMils(BR.Left))+' / '+
        FloatToStr(CoordToMils(BR.Bottom))+' / '+
        FloatToStr(CoordToMils(BR.Right))+' / '+
        FloatToStr(CoordToMils(BR.Top)));

    N:=0;
    GI:=C.GroupIterator_Create;
    If GI=Nil Then
    Begin
        AddLine('ERROR: GroupIterator unavailable.');
        Exit;
    End;

    GI.AddFilter_ObjectSet(
        MkSet(
            ePadObject,
            eTrackObject,
            eArcObject,
            eTextObject,
            eFillObject,
            eRegionObject,
            eComponentBodyObject
        )
    );
    GI.AddFilter_LayerSet(AllLayers);

    O:=GI.FirstPCBObject;
    While O<>Nil Do
    Begin
        N:=N+1;
        AddLine(
            'Primitive #'+IntToStr(N)+
            ' | '+ObjKindText(O)+
            ' | Layer='+Layer2String(O.Layer)
        );
        O:=GI.NextPCBObject;
    End;

    C.GroupIterator_Destroy(GI);
    AddLine('PrimitiveCount: '+IntToStr(N));
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
            ExportComponentPrimitives(C);
        End;
        C:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
End;

Procedure AuditT24_Footprint_Layers_v1;
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
        AddLine('Datalogger RevA - T24 Footprint Layer / Courtyard Audit v1');
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
            AddLine('PASS: all 12 representative footprint families were found.')
        Else
            AddLine('REVIEW: expected 12 representative components.');

        FN:=ExtractFilePath(GBoard.FileName)+
            'T24_Footprint_Layer_Courtyard_Audit.txt';
        GReport.SaveToFile(FN);

        Msg:='READ-ONLY FOOTPRINT LAYER AUDIT COMPLETE.'+#13#10+
             'Representatives found: '+IntToStr(GFoundCount)+#13#10+
             'Report: T24_Footprint_Layer_Courtyard_Audit.txt'+#13#10+
             'Nothing changed.';

        ShowMessage(Msg);
    Finally
        GReport.Free;
    End;
End;
