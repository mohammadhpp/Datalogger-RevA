{==============================================================================
 Datalogger RevA - T24
 GLOBAL MISSING MECHANICAL-2 / COURTYARD READ-ONLY AUDIT v1

 Entry point:
   AuditT24_Missing_Mech2_Components_v1

 Purpose:
   List every PCB component that currently has NO Mechanical Layer 2
   primitives before Mechanical 2 is migrated/retagged as Courtyard.

 READ ONLY:
   - no component/footprint edit
   - no layer/rule edit
   - no DRC/polygon action
   - only writes a TXT report

 Output:
   T24_Missing_Mech2_Components_Audit.txt
==============================================================================}

Var
    GBoard;
    GReport;
    GTotalComponents;
    GMissingMech2;

Procedure AddLine(S);
Begin
    GReport.Add(S);
End;

Function HasMechanical2(C);
Var GI;O;
Begin
    Result:=False;

    GI:=C.GroupIterator_Create;
    If GI=Nil Then Exit;

    GI.AddFilter_ObjectSet(
        MkSet(
            eTrackObject,
            eArcObject,
            eFillObject,
            eRegionObject,
            eTextObject,
            eComponentBodyObject
        )
    );
    GI.AddFilter_LayerSet(MkSet(eMechanical2));

    O:=GI.FirstPCBObject;
    If O<>Nil Then Result:=True;

    C.GroupIterator_Destroy(GI);
End;

Procedure ExportComponentSummary(C);
Var BR;
Begin
    BR:=C.BoundingRectangle;

    AddLine('');
    AddLine('------------------------------------------------------------');
    AddLine('RefDes: '+C.SourceDesignator);
    AddLine('Layer: '+Layer2String(C.Layer));
    AddLine('X/Y mil: '+
        FloatToStr(CoordToMils(C.X))+' / '+
        FloatToStr(CoordToMils(C.Y)));
    AddLine('Rotation deg: '+FloatToStr(C.Rotation));
    AddLine('Component Height mil: '+FloatToStr(CoordToMils(C.Height)));
    AddLine(
        'Component BBox L/B/R/T mil: '+
        FloatToStr(CoordToMils(BR.Left))+' / '+
        FloatToStr(CoordToMils(BR.Bottom))+' / '+
        FloatToStr(CoordToMils(BR.Right))+' / '+
        FloatToStr(CoordToMils(BR.Top))
    );
End;

Procedure ScanComponents;
Var BI;C;
Begin
    GTotalComponents:=0;
    GMissingMech2:=0;

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
        GTotalComponents:=GTotalComponents+1;

        If Not HasMechanical2(C) Then
        Begin
            GMissingMech2:=GMissingMech2+1;
            ExportComponentSummary(C);
        End;

        C:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
End;

Procedure AuditT24_Missing_Mech2_Components_v1;
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
        AddLine('Datalogger RevA - T24 Missing Mechanical-2 Components Audit v1');
        AddLine('READ ONLY');
        AddLine('PCB: '+GBoard.FileName);
        AddLine('');
        AddLine('Goal: enumerate every component that would lack a Courtyard');
        AddLine('if current Mechanical Layer 2 is migrated to Courtyard.');

        ScanComponents;

        AddLine('');
        AddLine('============================================================');
        AddLine('SUMMARY');
        AddLine('Total components scanned: '+IntToStr(GTotalComponents));
        AddLine('Components without Mechanical 2: '+IntToStr(GMissingMech2));

        If GMissingMech2=0 Then
            AddLine('PASS: every component already has Mechanical 2.')
        Else
            AddLine('ACTION: complete valid courtyard geometry for the listed components before migration.');

        FN:=ExtractFilePath(GBoard.FileName)+
            'T24_Missing_Mech2_Components_Audit.txt';
        GReport.SaveToFile(FN);

        Msg:='READ-ONLY MISSING MECH2 AUDIT COMPLETE.'+#13#10+
             'Total components: '+IntToStr(GTotalComponents)+#13#10+
             'Missing Mechanical 2: '+IntToStr(GMissingMech2)+#13#10+
             'Report: T24_Missing_Mech2_Components_Audit.txt'+#13#10+
             'Nothing changed.';

        ShowMessage(Msg);
    Finally
        GReport.Free;
    End;
End;
