{==============================================================================
 Datalogger RevA - T24
 COMPONENT CLEARANCE VIOLATION READ-ONLY AUDIT v1

 Entry point:
   AuditT24_Component_Clearance_Violations_v1

 Purpose:
   Export the COMPLETE text of the current Altium Component Clearance
   violation objects after Batch DRC, so the exact component pairs can be
   audited without relying on the clipped Messages-panel columns.

 READ ONLY:
   - no PCB object is added/removed/moved;
   - no design rule is edited;
   - no DRC is run;
   - no polygon is repoured;
   - only a TXT report is written next to the open PcbDoc.

 Output:
   T24_Component_Clearance_Violation_Audit.txt
==============================================================================}

Var
    GBoard;
    GReport;
    GAllViolationCount;
    GComponentClearanceCount;

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

Procedure ExportViolations;
Var BI;V;N;
Begin
    GAllViolationCount:=0;
    GComponentClearanceCount:=0;
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
            AddLine('------------------------------------------------------------');
            AddLine('Component Clearance Violation #'+IntToStr(N));
            AddLine('Violation Name: '+V.Name);
            AddLine('Rule Name: '+SafeRuleName(V));
            AddLine('Description:');
            AddLine(V.Description);

            If V.Primitive1<>Nil Then
            Begin
                AddLine('Primitive1 object id: '+IntToStr(V.Primitive1.ObjectId));
                AddLine('Primitive1 layer: '+Layer2String(V.Primitive1.Layer));
            End
            Else
                AddLine('Primitive1: <nil>');

            If V.Primitive2<>Nil Then
            Begin
                AddLine('Primitive2 object id: '+IntToStr(V.Primitive2.ObjectId));
                AddLine('Primitive2 layer: '+Layer2String(V.Primitive2.Layer));
            End
            Else
                AddLine('Primitive2: <nil>');
        End;

        V:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
End;

Procedure AuditT24_Component_Clearance_Violations_v1;
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
        AddLine('Datalogger RevA - T24 Component Clearance Violation Audit v1');
        AddLine('READ ONLY - current Altium violation objects');
        AddLine('PCB: '+GBoard.FileName);
        AddLine('');
        AddLine('This report must be generated AFTER the Batch DRC that shows');
        AddLine('the current Component Clearance violations.');
        AddLine('');

        ExportViolations;

        AddLine('');
        AddLine('============================================================');
        AddLine('SUMMARY');
        AddLine('All current violation objects: '+IntToStr(GAllViolationCount));
        AddLine('Component Clearance violations: '+IntToStr(GComponentClearanceCount));

        If GComponentClearanceCount=0 Then
            AddLine('WARNING: no Component Clearance violation objects were found.')
        Else
            AddLine('PASS: complete Component Clearance violation descriptions exported.');

        FN:=ExtractFilePath(GBoard.FileName)+
            'T24_Component_Clearance_Violation_Audit.txt';
        GReport.SaveToFile(FN);

        Msg:='READ-ONLY COMPONENT CLEARANCE AUDIT COMPLETE.'+#13#10+
             'All violation objects: '+IntToStr(GAllViolationCount)+#13#10+
             'Component Clearance violations: '+
             IntToStr(GComponentClearanceCount)+#13#10+
             'Report saved next to PCB:'+#13#10+
             'T24_Component_Clearance_Violation_Audit.txt'+#13#10+
             'Nothing changed.';

        ShowMessage(Msg);
    Finally
        GReport.Free;
    End;
End;
