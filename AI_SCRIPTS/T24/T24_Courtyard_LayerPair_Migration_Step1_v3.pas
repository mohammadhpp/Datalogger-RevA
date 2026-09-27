{==============================================================================
 Datalogger RevA - T24
 COURTYARD LAYER PAIR MIGRATION STEP1 v3

 Entry points:
   PreflightT24_Courtyard_LayerPair_Step1_v3
   ApplyT24_Courtyard_LayerPair_Step1_v3

 Purpose:
   Controlled migration of the existing Mechanical-2 courtyard-like data
   into a real top/bottom mechanical layer pair.

 STEP1 DOES:
   - enable Mechanical Layer 4
   - move Mechanical-2 primitives of the 3 EXISTING bottom-side components
     to Mechanical Layer 4:
       R_RTC_INT_PU
       C_RTC
       BT2
   - add Mechanical Layer Pair: Mechanical 2 <-> Mechanical 4

 STEP1 DOES NOT:
   - set Layer Type = Courtyard (do this manually in View Configuration
     immediately after Apply, using Edit Layers Pair -> Layer Type=Courtyard)
   - create missing courtyards for the 16 components that currently lack M2
   - move any component
   - change copper, routing, vias, polygons, nets, pads, or design rules

 Expected live baseline:
   - 129 components
   - 113 components with Mechanical 2
   - 16 without Mechanical 2
   - 3 bottom components with Mechanical 2
   - 1 bottom component without Mechanical 2
   - 0 mechanical layer pairs
   - Mechanical 4 has no primitives
   - no loose/non-component Mechanical 2 primitives

 Safety:
   - Preflight is read-only.
   - Apply changes ONLY mechanical layer assignment/pair metadata.
   - If post-check fails: DO NOT SAVE.
==============================================================================}

Var
    GBoard;
    GLastError;

Function IsTargetBottomRef(S);
Var U;
Begin
    U:=UpperCase(S);
    Result:=
        (U='R_RTC_INT_PU') Or
        (U='C_RTC') Or
        (U='BT2');
End;

Function ComponentHasLayer(C,L);
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
            eTextObject
        )
    );
    GI.AddFilter_LayerSet(MkSet(L));

    O:=GI.FirstPCBObject;
    If O<>Nil Then Result:=True;

    C.GroupIterator_Destroy(GI);
End;

Function CountComponentLayerPrims(C,L);
Var GI;O;N;
Begin
    N:=0;
    GI:=C.GroupIterator_Create;
    If GI=Nil Then Begin Result:=-1; Exit; End;

    GI.AddFilter_ObjectSet(
        MkSet(
            eTrackObject,
            eArcObject,
            eFillObject,
            eRegionObject,
            eTextObject
        )
    );
    GI.AddFilter_LayerSet(MkSet(L));

    O:=GI.FirstPCBObject;
    While O<>Nil Do
    Begin
        N:=N+1;
        O:=GI.NextPCBObject;
    End;

    C.GroupIterator_Destroy(GI);
    Result:=N;
End;

Function CountTotalComponents;
Var BI;C;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;

    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    C:=BI.FirstPCBObject;
    While C<>Nil Do
    Begin
        N:=N+1;
        C:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountComponentsWithLayer(L);
Var BI;C;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;

    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    C:=BI.FirstPCBObject;
    While C<>Nil Do
    Begin
        If ComponentHasLayer(C,L) Then N:=N+1;
        C:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountBottomWithLayer(L);
Var BI;C;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;

    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(MkSet(eBottomLayer));
    BI.AddFilter_Method(eProcessAll);

    C:=BI.FirstPCBObject;
    While C<>Nil Do
    Begin
        If ComponentHasLayer(C,L) Then N:=N+1;
        C:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountBottomWithoutM2;
Var BI;C;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;

    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(MkSet(eBottomLayer));
    BI.AddFilter_Method(eProcessAll);

    C:=BI.FirstPCBObject;
    While C<>Nil Do
    Begin
        If Not ComponentHasLayer(C,eMechanical2) Then N:=N+1;
        C:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountLooseLayerPrims(L);
Var BI;O;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;

    BI.AddFilter_ObjectSet(
        MkSet(
            eTrackObject,
            eArcObject,
            eFillObject,
            eRegionObject,
            eTextObject
        )
    );
    BI.AddFilter_LayerSet(MkSet(L));
    BI.AddFilter_Method(eProcessAll);

    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If O.InComponent=False Then N:=N+1;
        O:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountAllPrimsOnLayer(L);
Var BI;O;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Begin Result:=-1; Exit; End;

    BI.AddFilter_ObjectSet(
        MkSet(
            eTrackObject,
            eArcObject,
            eFillObject,
            eRegionObject,
            eTextObject,
            ePadObject,
            eViaObject
        )
    );
    BI.AddFilter_LayerSet(MkSet(L));
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

Function FindComponentByRef(RefDes);
Var BI;C;
Begin
    Result:=Nil;

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Exit;

    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    C:=BI.FirstPCBObject;
    While C<>Nil Do
    Begin
        If UpperCase(C.SourceDesignator)=UpperCase(RefDes) Then
        Begin
            Result:=C;
            Break;
        End;
        C:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
End;

Function BaselineReady;
Var
    C1;C2;C3;
    Pairs;
Begin
    Result:=False;
    GLastError:='';

    If CountTotalComponents<>129 Then
    Begin GLastError:='expected 129 total components'; Exit; End;

    If CountComponentsWithLayer(eMechanical2)<>113 Then
    Begin GLastError:='expected 113 components with Mechanical 2'; Exit; End;

    If 129-CountComponentsWithLayer(eMechanical2)<>16 Then
    Begin GLastError:='expected 16 components without Mechanical 2'; Exit; End;

    If CountBottomWithLayer(eMechanical2)<>3 Then
    Begin GLastError:='expected 3 bottom components with Mechanical 2'; Exit; End;

    If CountBottomWithoutM2<>1 Then
    Begin GLastError:='expected 1 bottom component without Mechanical 2'; Exit; End;

    If CountLooseLayerPrims(eMechanical2)<>0 Then
    Begin GLastError:='Mechanical 2 has loose/non-component primitives'; Exit; End;

    If CountAllPrimsOnLayer(eMechanical4)<>0 Then
    Begin GLastError:='Mechanical 4 is not empty'; Exit; End;

    Pairs:=GBoard.MechanicalPairs;
    If Pairs=Nil Then
    Begin GLastError:='MechanicalPairs unavailable'; Exit; End;

    If Pairs.Count<>0 Then
    Begin GLastError:='expected zero existing mechanical layer pairs'; Exit; End;

    C1:=FindComponentByRef('R_RTC_INT_PU');
    C2:=FindComponentByRef('C_RTC');
    C3:=FindComponentByRef('BT2');

    If (C1=Nil) Or (C2=Nil) Or (C3=Nil) Then
    Begin GLastError:='one or more target bottom components missing'; Exit; End;

    If C1.Layer<>eBottomLayer Then
    Begin GLastError:='R_RTC_INT_PU is not on Bottom Layer'; Exit; End;
    If C2.Layer<>eBottomLayer Then
    Begin GLastError:='C_RTC is not on Bottom Layer'; Exit; End;
    If C3.Layer<>eBottomLayer Then
    Begin GLastError:='BT2 is not on Bottom Layer'; Exit; End;

    If CountComponentLayerPrims(C1,eMechanical2)<>4 Then
    Begin GLastError:='R_RTC_INT_PU expected 4 Mech2 primitives'; Exit; End;
    If CountComponentLayerPrims(C2,eMechanical2)<>4 Then
    Begin GLastError:='C_RTC expected 4 Mech2 primitives'; Exit; End;
    If CountComponentLayerPrims(C3,eMechanical2)<>4 Then
    Begin GLastError:='BT2 expected 4 Mech2 primitives'; Exit; End;

    Result:=True;
End;

Procedure MoveComponentLayer(C,FromLayer,ToLayer);
Var GI;O;NextO;
Begin
    GI:=C.GroupIterator_Create;
    If GI=Nil Then Exit;

    GI.AddFilter_ObjectSet(
        MkSet(
            eTrackObject,
            eArcObject,
            eFillObject,
            eRegionObject,
            eTextObject
        )
    );
    GI.AddFilter_LayerSet(MkSet(FromLayer));

    O:=GI.FirstPCBObject;
    While O<>Nil Do
    Begin
        { Fetch next BEFORE changing O.Layer so the filtered iterator
          cannot lose/skip an object when O leaves FromLayer. }
        NextO:=GI.NextPCBObject;

        PCBServer.SendMessageToRobots(
            O.I_ObjectAddress,
            c_Broadcast,
            PCBM_BeginModify,
            c_NoEventData
        );

        O.Layer:=ToLayer;

        PCBServer.SendMessageToRobots(
            O.I_ObjectAddress,
            c_Broadcast,
            PCBM_EndModify,
            c_NoEventData
        );

        O:=NextO;
    End;

    C.GroupIterator_Destroy(GI);
End;

Function PostCheck;
Var
    C1;C2;C3;
    Pairs;
Begin
    Result:=False;
    GLastError:='';

    Pairs:=GBoard.MechanicalPairs;
    If Pairs=Nil Then
    Begin GLastError:='MechanicalPairs unavailable after Apply'; Exit; End;

    If Not Pairs.PairDefined(eMechanical2,eMechanical4) Then
    Begin GLastError:='Mechanical 2/4 pair was not created'; Exit; End;

    If Pairs.Count<>1 Then
    Begin GLastError:='expected exactly one mechanical layer pair'; Exit; End;

    C1:=FindComponentByRef('R_RTC_INT_PU');
    C2:=FindComponentByRef('C_RTC');
    C3:=FindComponentByRef('BT2');

    If CountComponentLayerPrims(C1,eMechanical2)<>0 Then
    Begin GLastError:='R_RTC_INT_PU still has Mech2 primitives'; Exit; End;
    If CountComponentLayerPrims(C2,eMechanical2)<>0 Then
    Begin GLastError:='C_RTC still has Mech2 primitives'; Exit; End;
    If CountComponentLayerPrims(C3,eMechanical2)<>0 Then
    Begin GLastError:='BT2 still has Mech2 primitives'; Exit; End;

    If CountComponentLayerPrims(C1,eMechanical4)<>4 Then
    Begin GLastError:='R_RTC_INT_PU expected 4 Mech4 primitives'; Exit; End;
    If CountComponentLayerPrims(C2,eMechanical4)<>4 Then
    Begin GLastError:='C_RTC expected 4 Mech4 primitives'; Exit; End;
    If CountComponentLayerPrims(C3,eMechanical4)<>4 Then
    Begin GLastError:='BT2 expected 4 Mech4 primitives'; Exit; End;

    If CountBottomWithLayer(eMechanical2)<>0 Then
    Begin GLastError:='a bottom component still owns Mech2 primitives'; Exit; End;

    If CountComponentsWithLayer(eMechanical2)<>110 Then
    Begin GLastError:='expected 110 top-side components remaining on Mech2'; Exit; End;

    If CountComponentsWithLayer(eMechanical4)<>3 Then
    Begin GLastError:='expected 3 bottom-side components on Mech4'; Exit; End;

    If CountTotalComponents<>129 Then
    Begin GLastError:='component count changed'; Exit; End;

    Result:=True;
End;

Procedure PreflightT24_Courtyard_LayerPair_Step1_v3;
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
            'ABORT COURTYARD MIGRATION STEP1 PREFLIGHT:'+#13#10+
            GLastError+#13#10+
            'Nothing changed.'
        );
        Exit;
    End;

    ShowMessage(
        'PREFLIGHT PASS - COURTYARD MIGRATION STEP1 v3.'+#13#10+
        '129 components / 113 with Mech2 / 16 without Mech2.'+#13#10+
        '3 bottom components with Mech2 verified.'+#13#10+
        'Mechanical 4 is empty.'+#13#10+
        'No existing mechanical layer pairs.'+#13#10+
        'No loose Mechanical 2 primitives.'+#13#10+
        'Nothing changed.'+#13#10+
        'Next: ApplyT24_Courtyard_LayerPair_Step1_v3'
    );
End;

Procedure ApplyT24_Courtyard_LayerPair_Step1_v3;
Var
    C1;C2;C3;
    LS;
    L4;
    Pairs;
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
            'ABORT COURTYARD MIGRATION STEP1 BASELINE:'+#13#10+
            GLastError+#13#10+
            'Nothing changed.'
        );
        Exit;
    End;

    C1:=FindComponentByRef('R_RTC_INT_PU');
    C2:=FindComponentByRef('C_RTC');
    C3:=FindComponentByRef('BT2');

    LS:=GBoard.LayerStack;
    If LS=Nil Then
    Begin
        ShowMessage('ABORT: LayerStack unavailable. Nothing changed.');
        Exit;
    End;

    L4:=LS.LayerObject[eMechanical4];
    If L4=Nil Then
    Begin
        ShowMessage('ABORT: Mechanical 4 layer object unavailable. Nothing changed.');
        Exit;
    End;

    Pairs:=GBoard.MechanicalPairs;

    PCBServer.PreProcess;
    Try
        L4.MechanicalLayerEnabled:=True;

        MoveComponentLayer(C1,eMechanical2,eMechanical4);
        MoveComponentLayer(C2,eMechanical2,eMechanical4);
        MoveComponentLayer(C3,eMechanical2,eMechanical4);

        Pairs.AddPair(eMechanical2,eMechanical4);

        GBoard.LayerIsDisplayed[eMechanical2]:=True;
        GBoard.LayerIsDisplayed[eMechanical4]:=True;
    Finally
        PCBServer.PostProcess;
    End;

    GBoard.ViewManager_FullUpdate;

    If Not PostCheck Then
    Begin
        ShowMessage(
            'MIGRATION STEP1 INCOMPLETE:'+#13#10+
            GLastError+#13#10+
            'DO NOT SAVE.'+#13#10+
            'Do not continue to Layer Type assignment.'
        );
        Exit;
    End;

    ShowMessage(
        'APPLY COMPLETE - COURTYARD MIGRATION STEP1 v3.'+#13#10+
        'Mechanical 2 <-> Mechanical 4 pair created.'+#13#10+
        '12 bottom-side mechanical primitives moved to Mechanical 4.'+#13#10+
        'No copper/routing/via/polygon/component-position/rule changed.'+#13#10+
        ''+#13#10+
        'NEXT MANUAL STEP:'+#13#10+
        'View Configuration -> Component Layer Pairs -> edit the 2/4 pair'+#13#10+
        'and set Layer Type = Courtyard.'+#13#10+
        ''+#13#10+
        'DO NOT SAVE yet.'
    );
End;
