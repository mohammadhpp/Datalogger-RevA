{==============================================================================
 Datalogger RevA - T24
 COMPONENT CLEARANCE VIOLATION READ-ONLY AUDIT v2

 Entry point:
   AuditT24_Component_Clearance_Violations_v2

 Purpose:
   Export the exact two component objects attached to every current
   Component Clearance violation marker.

 v1 limitation fixed:
   In current Altium, Violation.Description was empty and only the component
   primitives were exposed. v2 reads Primitive1/Primitive2 directly and
   exports component identity and geometry.

 READ ONLY:
   - no PCB object is added/removed/moved;
   - no rule is edited;
   - no DRC is run;
   - no polygon is repoured;
   - only a TXT report is written next to the open PcbDoc.

 Output:
   T24_Component_Clearance_Violation_Audit_v2.txt
==============================================================================}

Var
    GBoard;
    GReport;
    GAllViolationCount;
    GComponentClearanceCount;
    GResolvedPairCount;

Procedure AddLine(S);
Begin
    GReport.Add(S);
End;

Function SafeRuleName(V);
Begin
    Result:='<none>';
    If V=Nil Then Exit;
    If V.Rule=Nil Then Exit;
    Result:=V.Rule.Name;
End;

Function IsComponentClearanceViolation(V);
Begin
    Result:=False;
    If V=Nil Then Exit;
    If V.Rule=Nil Then Exit;
    Result:=V.Rule.RuleKind=eRule_ComponentClearance;
End;

Function ObjKindText(O);
Begin
    Result:='UNKNOWN';
    If O=Nil Then Exit;
    If O.ObjectId=eComponentObject Then Result:='COMPONENT'
    Else If O.ObjectId=ePadObject Then Result:='PAD'
    Else If O.ObjectId=eTrackObject Then Result:='TRACK'
    Else If O.ObjectId=eViaObject Then Result:='VIA'
    Else If O.ObjectId=eArcObject Then Result:='ARC'
    Else If O.ObjectId=eFillObject Then Result:='FILL'
    Else If O.ObjectId=eRegionObject Then Result:='REGION'
    Else If O.ObjectId=eTextObject Then Result:='TEXT'
    Else Result:='OBJECT_ID_'+IntToStr(O.ObjectId);
End;

Procedure ExportComponent(Prefix,C);
Var BR;
Begin
    If C=Nil Then
    Begin
        AddLine(Prefix+': <nil>');
        Exit;
    End;

    AddLine(Prefix+' kind: '+ObjKindText(C));

    If C.ObjectId<>eComponentObject Then
    Begin
        AddLine(Prefix+' object id: '+IntToStr(C.ObjectId));
        AddLine(Prefix+' layer: '+Layer2String(C.Layer));
        Exit;
    End;

    BR:=C.BoundingRectangle;

    AddLine(Prefix+' RefDes: '+C.SourceDesignator);
    AddLine(Prefix+' Comment: '+C.SourceComment);
    AddLine(Prefix+' Pattern: '+C.Pattern);
    AddLine(Prefix+' Source footprint: '+C.SourceLibReference);
    AddLine(Prefix+' Layer: '+Layer2String(C.Layer));
    AddLine(Prefix+' X mil: '+FloatToStr(CoordToMils(C.X)));
    AddLine(Prefix+' Y mil: '+FloatToStr(CoordToMils(C.Y)));
    AddLine(Prefix+' Rotation deg: '+FloatToStr(C.Rotation));

    AddLine(Prefix+' BBox left mil: '+FloatToStr(CoordToMils(BR.Left)));
    AddLine(Prefix+' BBox bottom mil: '+FloatToStr(CoordToMils(BR.Bottom)));
    AddLine(Prefix+' BBox right mil: '+FloatToStr(CoordToMils(BR.Right)));
    AddLine(Prefix+' BBox top mil: '+FloatToStr(CoordToMils(BR.Top)));
End;

Procedure ExportViolations;
Var BI;V;N;
Begin
    GAllViolationCount:=0;
    GComponentClearanceCount:=0;
    GResolvedPairCount:=0;
    N:=0;

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then
    Begin
        AddLine('ERROR: could not create violation iterator.');
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(eViolationObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    V:=BI.FirstPCBObject;
    While V<>Nil Do
    Begin
        GAllViolationCount:=GAllViolationCount+1;

        If IsComponentClearanceViolation(V) Then
        Begin
            GComponentClearanceCount:=GComponentClearanceCount+1;
            N:=N+1;

            AddLine('');
            AddLine('============================================================');
            AddLine('Component Clearance Violation #'+IntToStr(N));
            AddLine('Violation Name: '+V.Name);
            AddLine('Rule Name: '+SafeRuleName(V));

            ExportComponent('A',V.Primitive1);
            ExportComponent('B',V.Primitive2);

            If (V.Primitive1<>Nil) And (V.Primitive2<>Nil) Then
            If (V.Primitive1.ObjectId=eComponentObject) And
               (V.Primitive2.ObjectId=eComponentObject) Then
                GResolvedPairCount:=GResolvedPairCount+1;
        End;

        V:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
End;

Procedure AuditT24_Component_Clearance_Violations_v2;
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
        AddLine('Datalogger RevA - T24 Component Clearance Violation Audit v2');
        AddLine('READ ONLY - exact Primitive1/Primitive2 component identities');
        AddLine('PCB: '+GBoard.FileName);
        AddLine('');
        AddLine('Run this while the 21 current Component Clearance violation');
        AddLine('markers from the latest Batch DRC are still present.');

        ExportViolations;

        AddLine('');
        AddLine('============================================================');
        AddLine('SUMMARY');
        AddLine('All current violation objects: '+IntToStr(GAllViolationCount));
        AddLine('Component Clearance violations: '+IntToStr(GComponentClearanceCount));
        AddLine('Resolved component/component pairs: '+IntToStr(GResolvedPairCount));

        If GComponentClearanceCount=0 Then
            AddLine('FAIL: no Component Clearance violation markers found.')
        Else If GResolvedPairCount<>GComponentClearanceCount Then
            AddLine('REVIEW: one or more violation pairs did not resolve as components.')
        Else
            AddLine('PASS: all Component Clearance pairs resolved to exact components.');

        FN:=ExtractFilePath(GBoard.FileName)+
            'T24_Component_Clearance_Violation_Audit_v2.txt';
        GReport.SaveToFile(FN);

        Msg:='READ-ONLY COMPONENT CLEARANCE AUDIT v2 COMPLETE.'+#13#10+
             'Component Clearance violations: '+
             IntToStr(GComponentClearanceCount)+#13#10+
             'Resolved component pairs: '+IntToStr(GResolvedPairCount)+#13#10+
             'Report saved next to PCB:'+#13#10+
             'T24_Component_Clearance_Violation_Audit_v2.txt'+#13#10+
             'Nothing changed.';

        ShowMessage(Msg);
    Finally
        GReport.Free;
    End;
End;
