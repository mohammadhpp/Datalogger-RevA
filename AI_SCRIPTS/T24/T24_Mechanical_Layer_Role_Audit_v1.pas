{==============================================================================
 Datalogger RevA - T24
 MECHANICAL LAYER ROLE / PAIR READ-ONLY AUDIT v1

 Entry point:
   AuditT24_Mechanical_Layer_Roles_v1

 Purpose:
   Read the actual Mechanical layer names, enabled/used state, and mechanical
   layer pair definitions from the current PCB.

 Why:
   Mechanical Layer 1 geometrically behaves like component outline/body and
   Mechanical Layer 2 behaves like courtyard in most affected footprints.
   Before editing footprints, confirm how the board has these layers named
   and paired.

 READ ONLY:
   - no layer edit
   - no component/footprint edit
   - no rule edit
   - no DRC/polygon action
   - only writes a TXT report

 Output:
   T24_Mechanical_Layer_Role_Audit.txt
==============================================================================}

Var
    GBoard;
    GReport;

Procedure AddLine(S);
Begin
    GReport.Add(S);
End;

Function BoolText(B);
Begin
    If B Then Result:='TRUE' Else Result:='FALSE';
End;

Procedure ExportMechanicalLayers;
Var
    LS;
    L;
    O;
Begin
    LS:=GBoard.LayerStack;
    If LS=Nil Then
    Begin
        AddLine('ERROR: LayerStack unavailable.');
        Exit;
    End;

    AddLine('=== MECHANICAL LAYERS ===');

    For L:=eMechanical1 To eMechanical16 Do
    Begin
        O:=LS.LayerObject[L];
        If O<>Nil Then
        Begin
            AddLine('');
            AddLine('Layer ID: '+Layer2String(L));
            AddLine('Name: '+O.Name);
            AddLine('Used by primitives: '+BoolText(O.UsedByPrims));
            AddLine('Mechanical enabled: '+BoolText(O.MechanicalLayerEnabled));
            AddLine('Displayed single-layer mode: '+BoolText(O.DisplayInSingleLayerMode));
            AddLine('Linked to sheet: '+BoolText(O.LinkToSheet));
        End;
    End;
End;

Procedure ExportMechanicalPairs;
Var
    Pairs;
    I;
    P;
Begin
    AddLine('');
    AddLine('=== MECHANICAL LAYER PAIRS ===');

    Pairs:=GBoard.MechanicalPairs;
    If Pairs=Nil Then
    Begin
        AddLine('ERROR: MechanicalPairs unavailable.');
        Exit;
    End;

    AddLine('Pair count: '+IntToStr(Pairs.Count));

    For I:=0 To Pairs.Count-1 Do
    Begin
        P:=Pairs.LayerPair[I];
        AddLine(
            'Pair #'+IntToStr(I+1)+
            ': '+Layer2String(P.Layer1)+
            ' <-> '+Layer2String(P.Layer2)
        );
    End;

    AddLine('');
    AddLine(
        'Mechanical1 paired with Mechanical2: '+
        BoolText(Pairs.PairDefined(eMechanical1,eMechanical2))
    );
End;

Procedure AuditT24_Mechanical_Layer_Roles_v1;
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
        AddLine('Datalogger RevA - T24 Mechanical Layer Role Audit v1');
        AddLine('READ ONLY');
        AddLine('PCB: '+GBoard.FileName);
        AddLine('');

        ExportMechanicalLayers;
        ExportMechanicalPairs;

        FN:=ExtractFilePath(GBoard.FileName)+
            'T24_Mechanical_Layer_Role_Audit.txt';
        GReport.SaveToFile(FN);

        Msg:='READ-ONLY MECHANICAL LAYER ROLE AUDIT COMPLETE.'+#13#10+
             'Report: T24_Mechanical_Layer_Role_Audit.txt'+#13#10+
             'Nothing changed.';

        ShowMessage(Msg);
    Finally
        GReport.Free;
    End;
End;
