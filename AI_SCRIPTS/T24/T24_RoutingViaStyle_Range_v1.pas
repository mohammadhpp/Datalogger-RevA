{==============================================================================
 Datalogger RevA - T24
 ROUTING VIA STYLE RANGE UPDATE v1

 Entry points:
   PreflightT24_RoutingViaStyle_Range_v1
   ApplyT24_RoutingViaStyle_Range_v1

 Purpose:
   Correct the existing general Routing Via Style rule so it accepts:
   - existing 0.60 / 0.30 mm vias
   - two existing 0.70 / 0.30 mm VIN_MUX vias
   - planned Stage2B 0.80 / 0.45 mm GND stitching vias

 IMPORTANT:
   This script changes ONLY the RoutingVias design-rule range.
   It does NOT resize, move, add or delete any via or routing geometry.

 New allowed range:
   Via diameter:
     Min       = 23.622 mil = 0.60 mm
     Preferred = 23.622 mil = 0.60 mm
     Max       = 31.496 mil = 0.80 mm
   Hole:
     Min       = 11.811 mil = 0.30 mm
     Preferred = 11.811 mil = 0.30 mm
     Max       = 17.717 mil = 0.45 mm

 Current in-memory baseline after T24 GND-via Direct rule:
   - 43 total design rules
   - rule PolygonConnect_GND_Via_Direct exists
   - 180 total vias / 46 GND vias
   - 2 GND polygons
   - RoutingVias currently fixed at exactly 23.622 / 11.811 mil

 DRC evidence:
   Two pre-existing VIN_MUX vias at:
     (4480,5950) and (5235,5830)
   are 27.559 / 11.811 mil and therefore violate the old fixed rule.

 Safety:
   - Preflight changes nothing.
   - Apply uses BeginModify/EndModify robot messages on the rule.
   - Geometry counts must remain unchanged.
   - If validation fails: DO NOT SAVE; one Ctrl+Z rolls back the rule edit.
==============================================================================}

Var
    GBoard;
    GViaRule;
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

Function NearMil(C,V);
Begin
    Result:=Abs(CoordToMils(C)-V)<0.01;
End;

Function BaselineReady;
Var R;
Begin
    Result:=False;
    GLastError:='';

    If CountAllRules<>43 Then
    Begin GLastError:='expected exactly 43 rules after GND-via Direct rule'; Exit; End;

    R:=FindRuleByName('PolygonConnect_GND_Via_Direct');
    If R=Nil Then
    Begin GLastError:='PolygonConnect_GND_Via_Direct rule not found'; Exit; End;

    GViaRule:=FindRuleByName('RoutingVias');
    If GViaRule=Nil Then
    Begin GLastError:='RoutingVias rule not found'; Exit; End;

    If GViaRule.RuleKind<>eRule_RoutingViaStyle Then
    Begin GLastError:='RoutingVias is not a Routing Via Style rule'; Exit; End;

    If Not GViaRule.DRCEnabled Then
    Begin GLastError:='RoutingVias rule is disabled'; Exit; End;

    If UpperCase(GViaRule.Scope1Expression)<>'ALL' Then
    Begin GLastError:='RoutingVias Scope1 is not All'; Exit; End;

    If Not NearMil(GViaRule.MinWidth,23.622) Then
    Begin GLastError:='RoutingVias MinWidth is not baseline 23.622 mil'; Exit; End;

    If Not NearMil(GViaRule.MaxWidth,23.622) Then
    Begin GLastError:='RoutingVias MaxWidth is not baseline 23.622 mil'; Exit; End;

    If Not NearMil(GViaRule.PreferedWidth,23.622) Then
    Begin GLastError:='RoutingVias PreferredWidth is not baseline 23.622 mil'; Exit; End;

    If Not NearMil(GViaRule.MinHoleWidth,11.811) Then
    Begin GLastError:='RoutingVias MinHoleWidth is not baseline 11.811 mil'; Exit; End;

    If Not NearMil(GViaRule.MaxHoleWidth,11.811) Then
    Begin GLastError:='RoutingVias MaxHoleWidth is not baseline 11.811 mil'; Exit; End;

    If Not NearMil(GViaRule.PreferedHoleWidth,11.811) Then
    Begin GLastError:='RoutingVias PreferredHoleWidth is not baseline 11.811 mil'; Exit; End;

    If CountAllVias<>180 Then
    Begin GLastError:='expected exactly 180 total vias'; Exit; End;

    If CountGndVias<>46 Then
    Begin GLastError:='expected exactly 46 GND vias'; Exit; End;

    If CountAllPolygons<>2 Then
    Begin GLastError:='expected exactly 2 polygons'; Exit; End;

    Result:=True;
End;

Function PostCheck;
Begin
    Result:=False;
    GLastError:='';

    GViaRule:=FindRuleByName('RoutingVias');
    If GViaRule=Nil Then
    Begin GLastError:='RoutingVias rule missing after Apply'; Exit; End;

    If Not NearMil(GViaRule.MinWidth,23.622) Then
    Begin GLastError:='post-check MinWidth mismatch'; Exit; End;

    If Not NearMil(GViaRule.PreferedWidth,23.622) Then
    Begin GLastError:='post-check PreferredWidth mismatch'; Exit; End;

    If Not NearMil(GViaRule.MaxWidth,31.496) Then
    Begin GLastError:='post-check MaxWidth mismatch'; Exit; End;

    If Not NearMil(GViaRule.MinHoleWidth,11.811) Then
    Begin GLastError:='post-check MinHoleWidth mismatch'; Exit; End;

    If Not NearMil(GViaRule.PreferedHoleWidth,11.811) Then
    Begin GLastError:='post-check PreferredHoleWidth mismatch'; Exit; End;

    If Not NearMil(GViaRule.MaxHoleWidth,17.717) Then
    Begin GLastError:='post-check MaxHoleWidth mismatch'; Exit; End;

    If CountAllRules<>43 Then
    Begin GLastError:='rule count changed unexpectedly'; Exit; End;

    If CountAllVias<>180 Then
    Begin GLastError:='via geometry/count changed unexpectedly'; Exit; End;

    If CountGndVias<>46 Then
    Begin GLastError:='GND via count changed unexpectedly'; Exit; End;

    If CountAllPolygons<>2 Then
    Begin GLastError:='polygon count changed unexpectedly'; Exit; End;

    Result:=True;
End;

Procedure PreflightT24_RoutingViaStyle_Range_v1;
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
            'ABORT T24 RoutingViaStyle range preflight:'+#13#10+
            GLastError+#13#10+
            'Nothing changed.'
        );
        Exit;
    End;

    ShowMessage(
        'PREFLIGHT PASS - T24 ROUTING VIA STYLE RANGE v1.'+#13#10+
        'Old rule is fixed at 0.60/0.30 mm.'+#13#10+
        'Planned allowed range:'+#13#10+
        'Diameter 0.60 .. 0.80 mm; Preferred 0.60 mm.'+#13#10+
        'Hole 0.30 .. 0.45 mm; Preferred 0.30 mm.'+#13#10+
        'No PCB or rule change was made.'+#13#10+
        'Next: run ApplyT24_RoutingViaStyle_Range_v1.'
    );
End;

Procedure ApplyT24_RoutingViaStyle_Range_v1;
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
            'ABORT T24 RoutingViaStyle range baseline:'+#13#10+
            GLastError+#13#10+
            'Nothing changed.'
        );
        Exit;
    End;

    PCBServer.PreProcess;
    Try
        PCBServer.SendMessageToRobots(
            GViaRule.I_ObjectAddress,
            c_Broadcast,
            PCBM_BeginModify,
            c_NoEventData
        );

        GViaRule.MinWidth:=MilsToCoord(23.622);
        GViaRule.PreferedWidth:=MilsToCoord(23.622);
        GViaRule.MaxWidth:=MilsToCoord(31.496);

        GViaRule.MinHoleWidth:=MilsToCoord(11.811);
        GViaRule.PreferedHoleWidth:=MilsToCoord(11.811);
        GViaRule.MaxHoleWidth:=MilsToCoord(17.717);

        PCBServer.SendMessageToRobots(
            GViaRule.I_ObjectAddress,
            c_Broadcast,
            PCBM_EndModify,
            c_NoEventData
        );
    Finally
        PCBServer.PostProcess;
    End;

    GBoard.ViewManager_FullUpdate;

    If Not PostCheck Then
    Begin
        ShowMessage(
            'BUILD INCOMPLETE - T24 RoutingViaStyle range.'+#13#10+
            GLastError+#13#10+
            'DO NOT SAVE. One Ctrl+Z should roll back the rule edit.'
        );
        Exit;
    End;

    ShowMessage(
        'APPLY COMPLETE - T24 ROUTING VIA STYLE RANGE v1.'+#13#10+
        'RoutingVias rule now allows:'+#13#10+
        'Diameter: 0.60 .. 0.80 mm; Preferred 0.60 mm.'+#13#10+
        'Hole: 0.30 .. 0.45 mm; Preferred 0.30 mm.'+#13#10+
        'Existing vias were NOT resized or moved.'+#13#10+
        'NEXT: rerun Batch DRC.'+#13#10+
        'The old Component Clearance violations are a separate audit item.'
    );
End;
