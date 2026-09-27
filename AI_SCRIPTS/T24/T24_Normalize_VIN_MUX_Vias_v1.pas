{==============================================================================
 Datalogger RevA - T24
 NORMALIZE TWO VIN_MUX VIA PADS v1

 Entry points:
   PreflightT24_Normalize_VIN_MUX_Vias_v1
   ApplyT24_Normalize_VIN_MUX_Vias_v1

 Purpose:
   Fix the two real Routing Via Style violations by normalizing ONLY the two
   VIN_MUX via pad diameters to the established project standard.

 Current violating vias:
   V1: VIN_MUX @ (4480,5950) mil
       Current = 27.559 / 11.811 mil = 0.70 / 0.30 mm
   V2: VIN_MUX @ (5235,5830) mil
       Current = 27.559 / 11.811 mil = 0.70 / 0.30 mm

 Target:
   Both -> 23.622 / 11.811 mil = 0.60 / 0.30 mm

 Engineering basis:
   - RoutingVias rule is intentionally fixed at 0.60 / 0.30 mm.
   - 178 of 180 existing vias already use 0.60 / 0.30 mm.
   - Other power-net vias (BAT_FUSED, BAT_SW, USB_VBUS_PROT, 3V3_SYS)
     use the same 0.60 / 0.30 mm standard.
   - Hole diameter remains 0.30 mm, so the via barrel geometry is unchanged.
   - This script does NOT weaken or widen the RoutingVias rule.

 Expected current in-memory baseline:
   - 43 total rules after PolygonConnect_GND_Via_Direct apply
   - 180 total vias
   - 46 GND vias
   - exactly two 27.559/11.811 mil vias, both VIN_MUX at the coordinates above
   - 2 GND polygons

 Safety:
   - Preflight changes nothing.
   - Apply changes ONLY Size on exactly those two VIN_MUX vias.
   - HoleSize, net, coordinates, layer span and routing are unchanged.
   - If validation fails: DO NOT SAVE; one Ctrl+Z should roll back.
==============================================================================}

Var
    GBoard;
    GVia1;
    GVia2;
    GLastError;

Function NearMil(C,V);
Begin
    Result:=Abs(CoordToMils(C)-V)<0.01;
End;

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

Function FindViaMil(NetName,X,Y);
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
        If UpperCase(O.Net.Name)=UpperCase(NetName) Then
        If NearMil(O.X,X) And NearMil(O.Y,Y) Then
        Begin
            Result:=O;
            Break;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
End;

Function CountViaGeometry(D,H);
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
        If NearMil(O.Size,D) And NearMil(O.HoleSize,H) Then N:=N+1;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function BaselineReady;
Var R;
Begin
    Result:=False;
    GLastError:='';

    If CountAllRules<>43 Then
    Begin GLastError:='expected exactly 43 rules'; Exit; End;

    R:=FindRuleByName('PolygonConnect_GND_Via_Direct');
    If R=Nil Then
    Begin GLastError:='PolygonConnect_GND_Via_Direct not found'; Exit; End;

    If CountAllVias<>180 Then
    Begin GLastError:='expected exactly 180 total vias'; Exit; End;

    If CountGndVias<>46 Then
    Begin GLastError:='expected exactly 46 GND vias'; Exit; End;

    If CountAllPolygons<>2 Then
    Begin GLastError:='expected exactly 2 polygons'; Exit; End;

    If CountViaGeometry(27.559,11.811)<>2 Then
    Begin GLastError:='expected exactly two 0.70/0.30 mm vias'; Exit; End;

    GVia1:=FindViaMil('VIN_MUX',4480,5950);
    GVia2:=FindViaMil('VIN_MUX',5235,5830);

    If GVia1=Nil Then
    Begin GLastError:='VIN_MUX via at 4480,5950 not found'; Exit; End;

    If GVia2=Nil Then
    Begin GLastError:='VIN_MUX via at 5235,5830 not found'; Exit; End;

    If Not NearMil(GVia1.Size,27.559) Or
       Not NearMil(GVia1.HoleSize,11.811) Then
    Begin GLastError:='VIN_MUX via 4480,5950 geometry unexpected'; Exit; End;

    If Not NearMil(GVia2.Size,27.559) Or
       Not NearMil(GVia2.HoleSize,11.811) Then
    Begin GLastError:='VIN_MUX via 5235,5830 geometry unexpected'; Exit; End;

    Result:=True;
End;

Function PostCheck;
Begin
    Result:=False;
    GLastError:='';

    GVia1:=FindViaMil('VIN_MUX',4480,5950);
    GVia2:=FindViaMil('VIN_MUX',5235,5830);

    If GVia1=Nil Then
    Begin GLastError:='post-check first VIN_MUX via missing'; Exit; End;

    If GVia2=Nil Then
    Begin GLastError:='post-check second VIN_MUX via missing'; Exit; End;

    If Not NearMil(GVia1.Size,23.622) Or
       Not NearMil(GVia1.HoleSize,11.811) Then
    Begin GLastError:='post-check first via geometry mismatch'; Exit; End;

    If Not NearMil(GVia2.Size,23.622) Or
       Not NearMil(GVia2.HoleSize,11.811) Then
    Begin GLastError:='post-check second via geometry mismatch'; Exit; End;

    If CountViaGeometry(27.559,11.811)<>0 Then
    Begin GLastError:='0.70/0.30 mm via remains after normalization'; Exit; End;

    If CountAllVias<>180 Then
    Begin GLastError:='total via count changed'; Exit; End;

    If CountGndVias<>46 Then
    Begin GLastError:='GND via count changed'; Exit; End;

    If CountAllPolygons<>2 Then
    Begin GLastError:='polygon count changed'; Exit; End;

    Result:=True;
End;

Procedure PreflightT24_Normalize_VIN_MUX_Vias_v1;
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
            'ABORT VIN_MUX via normalization preflight:'+#13#10+
            GLastError+#13#10+
            'Nothing changed.'
        );
        Exit;
    End;

    ShowMessage(
        'PREFLIGHT PASS - NORMALIZE VIN_MUX VIAS v1.'+#13#10+
        'Found exactly two non-standard 0.70/0.30 mm vias.'+#13#10+
        'Both are VIN_MUX at the expected coordinates.'+#13#10+
        'Target is project standard 0.60/0.30 mm.'+#13#10+
        'Hole, net, coordinates and routing will stay unchanged.'+#13#10+
        'No PCB geometry was changed.'+#13#10+
        'Next: run ApplyT24_Normalize_VIN_MUX_Vias_v1.'
    );
End;

Procedure ApplyT24_Normalize_VIN_MUX_Vias_v1;
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
            'ABORT VIN_MUX via normalization baseline:'+#13#10+
            GLastError+#13#10+
            'Nothing changed.'
        );
        Exit;
    End;

    PCBServer.PreProcess;
    Try
        PCBServer.SendMessageToRobots(
            GVia1.I_ObjectAddress,
            c_Broadcast,
            PCBM_BeginModify,
            c_NoEventData
        );
        GVia1.Size:=MilsToCoord(23.622);
        PCBServer.SendMessageToRobots(
            GVia1.I_ObjectAddress,
            c_Broadcast,
            PCBM_EndModify,
            c_NoEventData
        );

        PCBServer.SendMessageToRobots(
            GVia2.I_ObjectAddress,
            c_Broadcast,
            PCBM_BeginModify,
            c_NoEventData
        );
        GVia2.Size:=MilsToCoord(23.622);
        PCBServer.SendMessageToRobots(
            GVia2.I_ObjectAddress,
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
            'BUILD INCOMPLETE - VIN_MUX via normalization.'+#13#10+
            GLastError+#13#10+
            'DO NOT SAVE. One Ctrl+Z should roll back.'
        );
        Exit;
    End;

    ShowMessage(
        'APPLY COMPLETE - VIN_MUX VIAS NORMALIZED v1.'+#13#10+
        'Both VIN_MUX vias are now 0.60/0.30 mm.'+#13#10+
        'Hole size, net, coordinates, layer span and routing were preserved.'+#13#10+
        'RoutingVias design rule was NOT changed.'+#13#10+
        'NEXT: rerun Batch DRC.'+#13#10+
        'Component Clearance violations must still be audited separately.'+#13#10+
        'DO NOT SAVE until DRC disposition is complete.'
    );
End;
