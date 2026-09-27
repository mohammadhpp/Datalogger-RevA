{==============================================================================
 Datalogger RevA - T24
 POLYGON CONNECT / THERMAL RELIEF READ-ONLY AUDIT v1

 Entry point:
   AuditT24_Polygon_Thermal_Relief_v1

 Scope:
   READ ONLY. No PCB geometry, design rule, polygon or pad/via state is modified.

 Purpose:
   - Enumerate actual Polygon Connect Style design rules from the open PcbDoc.
   - Report rule scopes and Altium's own DataSummaryString.
   - Count GND SMD pads, GND through-hole pads and GND vias.
   - Detect manual pad/via cache overrides that may supersede rule-driven relief.
   - Export a text report next to the PcbDoc.

 IMPORTANT:
   This audit exists because the collision snapshot does not export design rules.
==============================================================================}

Var
    GBoard;
    GReport;
    GRuleCount;
    GGndSmdPads;
    GGndThPads;
    GGndVias;
    GManualPadOverrides;
    GManualViaOverrides;

Function BoolText(B);
Begin
    If B Then Result:='TRUE' Else Result:='FALSE';
End;

Function CacheStateText(S);
Begin
    If S=eCacheInvalid Then Result:='INVALID'
    Else If S=eCacheValid Then Result:='RULE/CACHE'
    Else If S=eCacheManual Then Result:='MANUAL'
    Else Result:='UNKNOWN';
End;

Function PlaneStyleText(S);
Begin
    If S=eReliefConnectToPlane Then Result:='RELIEF'
    Else If S=eDirectConnectToPlane Then Result:='DIRECT'
    Else If S=eNoConnect Then Result:='NO_CONNECT'
    Else Result:='UNKNOWN';
End;

Function PadKindText(P);
Begin
    If P=Nil Then Begin Result:='UNKNOWN'; Exit; End;
    If P.Layer=eMultiLayer Then Result:='TH'
    Else If P.HoleSize>0 Then Result:='TH'
    Else Result:='SMD';
End;

Procedure AddLine(S);
Begin
    GReport.Add(S);
End;

Procedure AuditPolygonRules;
Var BI;O;R;N;
Begin
    AddLine('=== POLYGON CONNECT STYLE RULES ===');
    N:=0;

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then
    Begin
        AddLine('ERROR: cannot create board iterator for rules');
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(eRuleObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        R:=O;
        If R.RuleKind=eRule_PolygonConnectStyle Then
        Begin
            N:=N+1;
            AddLine('');
            AddLine('Rule #'+IntToStr(N));
            AddLine('Name: '+R.Name);
            AddLine('Enabled: '+BoolText(R.DRCEnabled));
            AddLine('Scope1: '+R.Scope1Expression);
            AddLine('Scope2: '+R.Scope2Expression);
            AddLine('Scope descriptor: '+R.GetState_ScopeDescriptorString);
            AddLine('Short descriptor: '+R.GetState_ShortDescriptorString);
            AddLine('Data summary: '+R.GetState_DataSummaryString);

            { Legacy/simple API fields. DataSummary above is authoritative for
              displaying any newer/advanced settings Altium exposes. }
            AddLine('ConnectStyle(simple API): '+PlaneStyleText(R.ConnectStyle));
            AddLine('Relief conductor width mil: '+
                FloatToStr(CoordToMils(R.ReliefConductorWidth)));
            AddLine('Relief entries(simple API): '+IntToStr(R.ReliefEntries));
            If R.PolygonReliefAngle=ePolygonReliefAngle_45 Then
                AddLine('Relief angle(simple API): 45')
            Else If R.PolygonReliefAngle=ePolygonReliefAngle_90 Then
                AddLine('Relief angle(simple API): 90')
            Else
                AddLine('Relief angle(simple API): UNKNOWN');
        End;
        O:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
    GRuleCount:=N;
    AddLine('');
    AddLine('Polygon Connect Style rule count: '+IntToStr(N));
End;

Procedure AuditGndPads;
Var BI;P;C;K;Manual;
Begin
    AddLine('');
    AddLine('=== GND PAD OVERRIDE AUDIT ===');

    GGndSmdPads:=0;
    GGndThPads:=0;
    GManualPadOverrides:=0;

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then
    Begin
        AddLine('ERROR: cannot create pad iterator');
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(ePadObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    P:=BI.FirstPCBObject;
    While P<>Nil Do
    Begin
        If P.Net<>Nil Then
        If UpperCase(P.Net.Name)='GND' Then
        Begin
            K:=PadKindText(P);
            If K='TH' Then GGndThPads:=GGndThPads+1
                      Else GGndSmdPads:=GGndSmdPads+1;

            Manual:=False;
            C:=P.Cache;
            If C.PlaneConnectionStyleValid=eCacheManual Then Manual:=True;
            If C.ReliefConductorWidthValid=eCacheManual Then Manual:=True;
            If C.ReliefEntriesValid=eCacheManual Then Manual:=True;
            If C.ReliefAirGapValid=eCacheManual Then Manual:=True;

            If Manual Then
            Begin
                GManualPadOverrides:=GManualPadOverrides+1;
                AddLine(
                    'MANUAL PAD override: '+P.Name+
                    ' kind='+K+
                    ' layer='+Layer2String(P.Layer)+
                    ' style='+PlaneStyleText(P.PowerPlaneConnectStyle)+
                    ' airgap_mil='+FloatToStr(CoordToMils(P.ReliefAirGap))+
                    ' spoke_mil='+FloatToStr(CoordToMils(P.ReliefConductorWidth))+
                    ' entries='+IntToStr(P.ReliefEntries)
                );
            End;
        End;
        P:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);

    AddLine('GND SMD pad count: '+IntToStr(GGndSmdPads));
    AddLine('GND TH pad count: '+IntToStr(GGndThPads));
    AddLine('GND pads with manual thermal/plane cache override: '+
        IntToStr(GManualPadOverrides));
End;

Procedure AuditGndVias;
Var BI;V;C;Manual;
Begin
    AddLine('');
    AddLine('=== GND VIA OVERRIDE AUDIT ===');

    GGndVias:=0;
    GManualViaOverrides:=0;

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then
    Begin
        AddLine('ERROR: cannot create via iterator');
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(eViaObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    V:=BI.FirstPCBObject;
    While V<>Nil Do
    Begin
        If V.Net<>Nil Then
        If UpperCase(V.Net.Name)='GND' Then
        Begin
            GGndVias:=GGndVias+1;
            Manual:=False;
            C:=V.Cache;
            If C.PlaneConnectionStyleValid=eCacheManual Then Manual:=True;
            If C.ReliefConductorWidthValid=eCacheManual Then Manual:=True;
            If C.ReliefEntriesValid=eCacheManual Then Manual:=True;
            If C.ReliefAirGapValid=eCacheManual Then Manual:=True;

            If Manual Then
            Begin
                GManualViaOverrides:=GManualViaOverrides+1;
                AddLine(
                    'MANUAL VIA override at ['+
                    FloatToStr(CoordToMils(V.X))+','+
                    FloatToStr(CoordToMils(V.Y))+']'+
                    ' style='+PlaneStyleText(V.PowerPlaneConnectStyle)+
                    ' airgap_mil='+FloatToStr(CoordToMils(V.ReliefAirGap))+
                    ' spoke_mil='+FloatToStr(CoordToMils(V.ReliefConductorWidth))+
                    ' entries='+IntToStr(V.ReliefEntries)
                );
            End;
        End;
        V:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);

    AddLine('GND via count: '+IntToStr(GGndVias));
    AddLine('GND vias with manual thermal/plane cache override: '+
        IntToStr(GManualViaOverrides));
End;

Procedure AuditT24_Polygon_Thermal_Relief_v1;
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
        AddLine('Datalogger RevA - T24 Polygon/Thermal Relief Audit v1');
        AddLine('READ ONLY - no PCB modification');
        AddLine('PCB: '+GBoard.FileName);
        AddLine('');

        AuditPolygonRules;
        AuditGndPads;
        AuditGndVias;

        AddLine('');
        AddLine('=== AUDIT GATE ===');
        If GRuleCount=0 Then
            AddLine('FAIL: no Polygon Connect Style rule was found.')
        Else
            AddLine('INFO: inspect the rule Data summary above for Relief/Direct/No Connect.');

        If GManualPadOverrides=0 Then
            AddLine('PASS: no manual GND pad thermal/plane cache override detected.')
        Else
            AddLine('REVIEW: manual GND pad overrides exist; inspect entries above.');

        If GManualViaOverrides=0 Then
            AddLine('PASS: no manual GND via thermal/plane cache override detected.')
        Else
            AddLine('REVIEW: manual GND via overrides exist; inspect entries above.');

        FN:=ExtractFilePath(GBoard.FileName)+'T24_Thermal_Relief_Audit_Report.txt';
        GReport.SaveToFile(FN);

        Msg:='READ-ONLY AUDIT COMPLETE.'+#13#10+
             'Polygon Connect Style rules: '+IntToStr(GRuleCount)+#13#10+
             'GND SMD pads: '+IntToStr(GGndSmdPads)+#13#10+
             'GND TH pads: '+IntToStr(GGndThPads)+#13#10+
             'GND vias: '+IntToStr(GGndVias)+#13#10+
             'Manual pad overrides: '+IntToStr(GManualPadOverrides)+#13#10+
             'Manual via overrides: '+IntToStr(GManualViaOverrides)+#13#10+
             'Report saved next to PCB:'+#13#10+
             'T24_Thermal_Relief_Audit_Report.txt'+#13#10+
             'Nothing changed.';
        ShowMessage(Msg);
    Finally
        GReport.Free;
    End;
End;
