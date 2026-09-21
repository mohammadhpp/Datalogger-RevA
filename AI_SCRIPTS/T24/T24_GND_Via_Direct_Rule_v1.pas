{==============================================================================
 Datalogger RevA - T24
 GND VIA DIRECT POLYGON CONNECT RULE v1

 Entry points:
   PreflightT24_GND_Via_Direct_Rule_v1
   ApplyT24_GND_Via_Direct_Rule_v1

 Purpose:
   Keep the existing general PolygonConnect rule as Relief for soldered pads,
   and add one higher-priority Polygon Connect Style rule that targets ONLY
   GND vias and uses Direct Connect.

 New rule:
   Name:  PolygonConnect_GND_Via_Direct
   Scope: IsVia AND InNet('GND')
   Style: Direct Connect

 Authoritative baseline:
   - current PCB blob: 16f5576c1882a60a69a03b55c5456104be938911
   - exactly 42 total rules
   - exactly 1 PolygonConnect rule named PolygonConnect
   - existing general PolygonConnect rule:
       Scope1 = All
       Scope2 = All
       Enabled = TRUE
       ConnectStyle = Relief
       ReliefConductorWidth = 10 mil
       ReliefEntries = 4
       PolygonReliefAngle = 90 deg
   - 180 total vias / 46 GND vias
   - 2 GND polygons: one Top + one Bottom

 Safety:
   - Preflight changes nothing.
   - Apply changes rules only; no tracks, vias, pads, polygons or components.
   - New rules of the same type should receive priority 1 in Altium.
   - Apply verifies that the new rule is priority 1 and the general rule is
     lower priority after insertion.
   - Apply also tests the new rule scope against:
       one GND via       -> MUST match
       one non-GND via   -> MUST NOT match
       one GND pad       -> MUST NOT match
   - If post-apply validation fails: DO NOT SAVE; one Ctrl+Z rolls back.
   - After successful Apply: Repour All Polygons -> FULL DRC.
==============================================================================}

Var
    GBoard;
    GGeneralRule;
    GNewRule;
    GGndVia;
    GNonGndVia;
    GGndPad;
    GLastError;

Function CountAllRules;
Var BI;O;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(eRuleObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        N:=N+1;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountPolygonConnectRules;
Var BI;O;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(eRuleObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If O.RuleKind=eRule_PolygonConnectStyle Then N:=N+1;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountAllVias;
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
        N:=N+1;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountGndVias;
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
        If O.Net<>Nil Then
            If UpperCase(O.Net.Name)='GND' Then N:=N+1;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountAllPolygons;
Var BI;O;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(ePolyObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        N:=N+1;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountGndTopPolygons;
Var BI;O;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(ePolyObject));
    BI.AddFilter_LayerSet(MkSet(eTopLayer));
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If O.Net<>Nil Then
            If UpperCase(O.Net.Name)='GND' Then N:=N+1;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountGndBottomPolygons;
Var BI;O;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;
    BI.AddFilter_ObjectSet(MkSet(ePolyObject));
    BI.AddFilter_LayerSet(MkSet(eBottomLayer));
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If O.Net<>Nil Then
            If UpperCase(O.Net.Name)='GND' Then N:=N+1;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function FindRuleByName(RuleName);
Var BI;O;
Begin
    Result:=Nil;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Exit;
    BI.AddFilter_ObjectSet(MkSet(eRuleObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If UpperCase(O.Name)=UpperCase(RuleName) Then
        Begin
            Result:=O;
            Break;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
End;

Function FindGeneralPolygonRule;
Var BI;O;
Begin
    Result:=Nil;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Exit;
    BI.AddFilter_ObjectSet(MkSet(eRuleObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If O.RuleKind=eRule_PolygonConnectStyle Then
        If UpperCase(O.Name)='POLYGONCONNECT' Then
        Begin
            Result:=O;
            Break;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
End;

Function FindFirstGndVia;
Var BI;O;
Begin
    Result:=Nil;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Exit;
    BI.AddFilter_ObjectSet(MkSet(eViaObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If O.Net<>Nil Then
        If UpperCase(O.Net.Name)='GND' Then
        Begin
            Result:=O;
            Break;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
End;

Function FindFirstNonGndVia;
Var BI;O;
Begin
    Result:=Nil;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Exit;
    BI.AddFilter_ObjectSet(MkSet(eViaObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If O.Net<>Nil Then
        If UpperCase(O.Net.Name)<>'GND' Then
        Begin
            Result:=O;
            Break;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
End;

Function FindFirstGndPad;
Var BI;O;
Begin
    Result:=Nil;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Exit;
    BI.AddFilter_ObjectSet(MkSet(ePadObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);
    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If O.Net<>Nil Then
        If UpperCase(O.Net.Name)='GND' Then
        Begin
            Result:=O;
            Break;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
End;

Function BaselineReady;
Begin
    Result:=False;
    GLastError:='';

    If CountAllRules<>42 Then
    Begin GLastError:='expected exactly 42 design rules'; Exit; End;

    If CountPolygonConnectRules<>1 Then
    Begin GLastError:='expected exactly 1 Polygon Connect Style rule'; Exit; End;

    If FindRuleByName('PolygonConnect_GND_Via_Direct')<>Nil Then
    Begin GLastError:='GND-via Direct rule already exists; do not rerun'; Exit; End;

    GGeneralRule:=FindGeneralPolygonRule;
    If GGeneralRule=Nil Then
    Begin GLastError:='general PolygonConnect rule not found'; Exit; End;

    If Not GGeneralRule.DRCEnabled Then
    Begin GLastError:='general PolygonConnect rule is disabled'; Exit; End;

    If UpperCase(GGeneralRule.Scope1Expression)<>'ALL' Then
    Begin GLastError:='general PolygonConnect Scope1 is not All'; Exit; End;

    If UpperCase(GGeneralRule.Scope2Expression)<>'ALL' Then
    Begin GLastError:='general PolygonConnect Scope2 is not All'; Exit; End;

    If GGeneralRule.ConnectStyle<>eReliefConnectToPlane Then
    Begin GLastError:='general PolygonConnect style is not Relief'; Exit; End;

    If Abs(CoordToMils(GGeneralRule.ReliefConductorWidth)-10.0)>0.01 Then
    Begin GLastError:='general PolygonConnect spoke width is not 10 mil'; Exit; End;

    If GGeneralRule.ReliefEntries<>4 Then
    Begin GLastError:='general PolygonConnect relief entries is not 4'; Exit; End;

    If CountAllVias<>180 Then
    Begin GLastError:='expected exactly 180 total vias'; Exit; End;

    If CountGndVias<>46 Then
    Begin GLastError:='expected exactly 46 GND vias'; Exit; End;

    If CountAllPolygons<>2 Then
    Begin GLastError:='expected exactly 2 polygons'; Exit; End;

    If CountGndTopPolygons<>1 Then
    Begin GLastError:='expected exactly 1 Top GND polygon'; Exit; End;

    If CountGndBottomPolygons<>1 Then
    Begin GLastError:='expected exactly 1 Bottom GND polygon'; Exit; End;

    GGndVia:=FindFirstGndVia;
    GNonGndVia:=FindFirstNonGndVia;
    GGndPad:=FindFirstGndPad;

    If GGndVia=Nil Then
    Begin GLastError:='cannot find representative GND via'; Exit; End;

    If GNonGndVia=Nil Then
    Begin GLastError:='cannot find representative non-GND via'; Exit; End;

    If GGndPad=Nil Then
    Begin GLastError:='cannot find representative GND pad'; Exit; End;

    Result:=True;
End;

Function NewRulePostCheck;
Begin
    Result:=False;
    GLastError:='';

    GNewRule:=FindRuleByName('PolygonConnect_GND_Via_Direct');
    If GNewRule=Nil Then
    Begin GLastError:='new rule not found after Apply'; Exit; End;

    GGeneralRule:=FindGeneralPolygonRule;
    If GGeneralRule=Nil Then
    Begin GLastError:='general PolygonConnect missing after Apply'; Exit; End;

    If CountAllRules<>43 Then
    Begin GLastError:='expected exactly 43 total rules after Apply'; Exit; End;

    If CountPolygonConnectRules<>2 Then
    Begin GLastError:='expected exactly 2 Polygon Connect Style rules after Apply'; Exit; End;

    If GNewRule.RuleKind<>eRule_PolygonConnectStyle Then
    Begin GLastError:='new rule kind is not PolygonConnectStyle'; Exit; End;

    If Not GNewRule.DRCEnabled Then
    Begin GLastError:='new rule is disabled'; Exit; End;

    If UpperCase(GNewRule.Scope1Expression)<>
       'ISVIA AND INNET(''GND'')' Then
    Begin GLastError:='new rule Scope1 changed unexpectedly'; Exit; End;

    If GNewRule.ConnectStyle<>eDirectConnectToPlane Then
    Begin GLastError:='new rule style is not Direct Connect'; Exit; End;

    { New same-type rule must be priority 1 and override the old All rule. }
    If GNewRule.Priority<>1 Then
    Begin GLastError:='new rule did not receive priority 1'; Exit; End;

    If GGeneralRule.Priority<=GNewRule.Priority Then
    Begin GLastError:='general rule priority is not below new specific rule'; Exit; End;

    { Validate exact scope behavior on real board primitives. }
    If Not GNewRule.Scope1Includes(GGndVia) Then
    Begin GLastError:='new rule does not match a real GND via'; Exit; End;

    If GNewRule.Scope1Includes(GNonGndVia) Then
    Begin GLastError:='new rule incorrectly matches a non-GND via'; Exit; End;

    If GNewRule.Scope1Includes(GGndPad) Then
    Begin GLastError:='new rule incorrectly matches a GND pad'; Exit; End;

    { Geometry must remain unchanged by this rule-only stage. }
    If CountAllVias<>180 Then
    Begin GLastError:='via count changed unexpectedly'; Exit; End;

    If CountGndVias<>46 Then
    Begin GLastError:='GND via count changed unexpectedly'; Exit; End;

    If CountAllPolygons<>2 Then
    Begin GLastError:='polygon count changed unexpectedly'; Exit; End;

    Result:=True;
End;

Procedure PreflightT24_GND_Via_Direct_Rule_v1;
Begin
    GBoard:=PCBServer.GetCurrentPCBBoard;
    If GBoard=Nil Then
    Begin
        ShowMessage('ABORT: open DATALOGER_RevA.PcbDoc. Nothing changed.');
        Exit;
    End;

    If Not BaselineReady Then
    Begin
        ShowMessage(
            'ABORT T24 GND Via Direct rule preflight:'+#13#10+
            GLastError+#13#10+
            'Nothing changed.'
        );
        Exit;
    End;

    ShowMessage(
        'PREFLIGHT PASS - T24 GND VIA DIRECT RULE v1.'+#13#10+
        'Current general PolygonConnect = Relief.'+#13#10+
        'Baseline: 42 rules / 180 vias / 46 GND vias / 2 GND polygons.'+#13#10+
        'Representative GND/non-GND via and GND pad are present.'+#13#10+
        'No PCB or rule change was made.'+#13#10+
        'Next: run ApplyT24_GND_Via_Direct_Rule_v1.'
    );
End;

Procedure ApplyT24_GND_Via_Direct_Rule_v1;
Var R;
Begin
    GBoard:=PCBServer.GetCurrentPCBBoard;
    If GBoard=Nil Then
    Begin
        ShowMessage('ABORT: open DATALOGER_RevA.PcbDoc. Nothing changed.');
        Exit;
    End;

    If Not BaselineReady Then
    Begin
        ShowMessage(
            'ABORT T24 GND Via Direct rule baseline:'+#13#10+
            GLastError+#13#10+
            'Nothing changed.'
        );
        Exit;
    End;

    PCBServer.PreProcess;
    Try
        R:=PCBServer.PCBObjectFactory(eRuleObject,eNoDimension,eCreate_Default);
        If R=Nil Then
        Begin
            GLastError:='rule factory failed';
        End
        Else
        Begin
            R.RuleKind:=eRule_PolygonConnectStyle;
            R.Name:='PolygonConnect_GND_Via_Direct';
            R.Comment:='T24: Direct polygon connection for GND vias only';
            R.Scope1Expression:='IsVia AND InNet(''GND'')';
            R.Scope2Expression:='All';
            R.DRCEnabled:=True;
            R.ConnectStyle:=eDirectConnectToPlane;

            GBoard.AddPCBObject(R);
            PCBServer.SendMessageToRobots(
                GBoard.I_ObjectAddress,
                c_Broadcast,
                PCBM_BoardRegisteration,
                R.I_ObjectAddress
            );
        End;
    Finally
        PCBServer.PostProcess;
    End;

    GBoard.ViewManager_FullUpdate;

    If R=Nil Then
    Begin
        ShowMessage(
            'BUILD INCOMPLETE - T24 GND Via Direct rule.'+#13#10+
            GLastError+#13#10+
            'DO NOT SAVE.'
        );
        Exit;
    End;

    If Not NewRulePostCheck Then
    Begin
        ShowMessage(
            'BUILD INCOMPLETE - T24 GND Via Direct rule.'+#13#10+
            GLastError+#13#10+
            'DO NOT SAVE. One Ctrl+Z should roll back the rule transaction.'
        );
        Exit;
    End;

    ShowMessage(
        'APPLY COMPLETE - T24 GND VIA DIRECT RULE v1.'+#13#10+
        'New rule: PolygonConnect_GND_Via_Direct'+#13#10+
        'Scope: IsVia AND InNet(''GND'')'+#13#10+
        'Style: Direct Connect'+#13#10+
        'Priority: 1 (higher than general Relief rule).'+#13#10+
        'Scope test PASS:'+#13#10+
        '  GND via = MATCH'+#13#10+
        '  non-GND via = NO MATCH'+#13#10+
        '  GND pad = NO MATCH'+#13#10+
        'No routing/via/polygon geometry was changed.'+#13#10+
        'NEXT: Repour All Polygons, then run FULL DRC.'+#13#10+
        'Do NOT save until DRC is clean.'+#13#10+
        'After DRC PASS: save PCB, run Snapshot Exporter v1.4.2, then Git_Save.cmd.'
    );
End;
