{==============================================================================
 Datalogger RevA - T24
 COMPONENT BODY AUDIT FOR CURRENT CLEARANCE VIOLATIONS v1

 Entry point:
   AuditT24_Component_Bodies_For_Clearance_v1

 Purpose:
   For each current Component Clearance violation, inspect the two component
   objects and report their actual eComponentBodyObject primitives.

 Why:
   The live ComponentClearance rule in the current PcbDoc is stored with
   COLLISIONCHECKMODE=3, which maps to Component Body Mode in Altium's API.
   Before moving any component, verify whether each violation is caused by
   realistic body geometry or an incorrect/oversized footprint body.

 READ ONLY:
   - no PCB/rule/DRC/polygon modification
   - only writes a TXT report next to the PCB

 Output:
   T24_Component_Body_Clearance_Audit.txt
==============================================================================}

Var
    GBoard;
    GReport;
    GViolationCount;
    GPairCount;

Procedure AddLine(S);
Begin
    GReport.Add(S);
End;

Function IsComponentClearanceViolation(V);
Begin
    Result:=False;
    If V=Nil Then Exit;
    If V.Rule=Nil Then Exit;
    Result:=V.Rule.RuleKind=eRule_ComponentClearance;
End;

Procedure ExportBodies(Prefix,C);
Var GI;O;BR;N;
Begin
    If C=Nil Then
    Begin
        AddLine(Prefix+' Component: <nil>');
        Exit;
    End;

    If C.ObjectId<>eComponentObject Then
    Begin
        AddLine(Prefix+' ObjectId: '+IntToStr(C.ObjectId)+' (not component)');
        Exit;
    End;

    AddLine(Prefix+' RefDes: '+C.SourceDesignator);
    AddLine(Prefix+' Height mil: '+FloatToStr(CoordToMils(C.Height)));

    N:=0;
    GI:=C.GroupIterator_Create;
    If GI=Nil Then
    Begin
        AddLine(Prefix+' BodyCount: ERROR iterator unavailable');
        Exit;
    End;

    GI.AddFilter_ObjectSet(MkSet(eComponentBodyObject));
    GI.AddFilter_LayerSet(AllLayers);

    O:=GI.FirstPCBObject;
    While O<>Nil Do
    Begin
        N:=N+1;
        BR:=O.BoundingRectangle;

        AddLine(Prefix+' Body #'+IntToStr(N));
        AddLine(Prefix+' Body layer: '+Layer2String(O.Layer));
        AddLine(Prefix+' Body BBox left mil: '+FloatToStr(CoordToMils(BR.Left)));
        AddLine(Prefix+' Body BBox bottom mil: '+FloatToStr(CoordToMils(BR.Bottom)));
        AddLine(Prefix+' Body BBox right mil: '+FloatToStr(CoordToMils(BR.Right)));
        AddLine(Prefix+' Body BBox top mil: '+FloatToStr(CoordToMils(BR.Top)));

        O:=GI.NextPCBObject;
    End;

    C.GroupIterator_Destroy(GI);

    AddLine(Prefix+' BodyCount: '+IntToStr(N));
End;

Procedure ExportCurrentViolations;
Var BI;V;N;
Begin
    GViolationCount:=0;
    GPairCount:=0;
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
        If IsComponentClearanceViolation(V) Then
        Begin
            GViolationCount:=GViolationCount+1;
            N:=N+1;

            AddLine('');
            AddLine('============================================================');
            AddLine('Violation #'+IntToStr(N));
            AddLine('Violation Name: '+V.Name);

            ExportBodies('A',V.Primitive1);
            ExportBodies('B',V.Primitive2);

            If (V.Primitive1<>Nil) And (V.Primitive2<>Nil) Then
            If (V.Primitive1.ObjectId=eComponentObject) And
               (V.Primitive2.ObjectId=eComponentObject) Then
                GPairCount:=GPairCount+1;
        End;

        V:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
End;

Procedure AuditT24_Component_Bodies_For_Clearance_v1;
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
        AddLine('Datalogger RevA - T24 Component Body Clearance Audit v1');
        AddLine('READ ONLY');
        AddLine('PCB: '+GBoard.FileName);
        AddLine('');
        AddLine('Run while the current 21 Component Clearance violation markers remain.');

        ExportCurrentViolations;

        AddLine('');
        AddLine('============================================================');
        AddLine('SUMMARY');
        AddLine('Component Clearance violations: '+IntToStr(GViolationCount));
        AddLine('Resolved component/component pairs: '+IntToStr(GPairCount));

        FN:=ExtractFilePath(GBoard.FileName)+
            'T24_Component_Body_Clearance_Audit.txt';
        GReport.SaveToFile(FN);

        Msg:='READ-ONLY COMPONENT BODY AUDIT COMPLETE.'+#13#10+
             'Violations: '+IntToStr(GViolationCount)+#13#10+
             'Resolved pairs: '+IntToStr(GPairCount)+#13#10+
             'Report: T24_Component_Body_Clearance_Audit.txt'+#13#10+
             'Nothing changed.';

        ShowMessage(Msg);
    Finally
        GReport.Free;
    End;
End;
