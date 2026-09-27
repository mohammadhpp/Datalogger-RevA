{==============================================================================
 Datalogger RevA - T24
 GLOBAL MECHANICAL-2 USAGE READ-ONLY AUDIT v1

 Entry point:
   AuditT24_Global_Mech2_Usage_v1

 Purpose:
   Before converting/migrating Mechanical Layer 2 into a true Courtyard
   Component Layer Pair, verify GLOBAL board usage.

 This audit reports:
   - every component that contains Mechanical Layer 2 primitives
   - Mech2 primitive count and envelope per component
   - Mechanical Layer 1 envelope for comparison
   - pad envelope for comparison
   - any Mechanical Layer 2 primitives NOT owned by a component

 READ ONLY:
   - no layer edit
   - no component/footprint edit
   - no rule edit
   - no DRC/polygon action
   - only writes a TXT report

 Output:
   T24_Global_Mech2_Usage_Audit.txt
==============================================================================}

Var
    GBoard;
    GReport;
    GCompCount;
    GCompWithM2;
    GLooseM2Count;

Procedure AddLine(S);
Begin
    GReport.Add(S);
End;

Procedure ResetBounds(Var HasAny; Var L; Var B; Var R; Var T);
Begin
    HasAny:=False;
    L:=0; B:=0; R:=0; T:=0;
End;

Procedure ExpandBounds(BR; Var HasAny; Var L; Var B; Var R; Var T);
Var BL;BB;BRi;BT;
Begin
    BL:=CoordToMils(BR.Left);
    BB:=CoordToMils(BR.Bottom);
    BRi:=CoordToMils(BR.Right);
    BT:=CoordToMils(BR.Top);

    If Not HasAny Then
    Begin
        L:=BL; B:=BB; R:=BRi; T:=BT;
        HasAny:=True;
    End
    Else
    Begin
        If BL<L Then L:=BL;
        If BB<B Then B:=BB;
        If BRi>R Then R:=BRi;
        If BT>T Then T:=BT;
    End;
End;

Function DimsText(HasAny,L,B,R,T);
Begin
    If Not HasAny Then
    Begin
        Result:='NONE';
        Exit;
    End;

    Result:=
        'W/H mm='+
        FloatToStr((R-L)*0.0254)+' / '+
        FloatToStr((T-B)*0.0254)+
        ' | L/B/R/T mil='+
        FloatToStr(L)+' / '+
        FloatToStr(B)+' / '+
        FloatToStr(R)+' / '+
        FloatToStr(T);
End;

Procedure AuditComponent(C);
Var
    GI;O;BR;
    HasPad;PadL;PadB;PadR;PadT;PadN;
    HasM1;M1L;M1B;M1R;M1T;M1N;
    HasM2;M2L;M2B;M2R;M2T;M2N;
Begin
    GCompCount:=GCompCount+1;

    ResetBounds(HasPad,PadL,PadB,PadR,PadT);
    ResetBounds(HasM1,M1L,M1B,M1R,M1T);
    ResetBounds(HasM2,M2L,M2B,M2R,M2T);
    PadN:=0; M1N:=0; M2N:=0;

    GI:=C.GroupIterator_Create;
    If GI=Nil Then Exit;

    GI.AddFilter_ObjectSet(
        MkSet(
            ePadObject,
            eTrackObject,
            eArcObject,
            eFillObject,
            eRegionObject,
            eTextObject
        )
    );
    GI.AddFilter_LayerSet(AllLayers);

    O:=GI.FirstPCBObject;
    While O<>Nil Do
    Begin
        BR:=O.BoundingRectangle;

        If O.ObjectId=ePadObject Then
        Begin
            PadN:=PadN+1;
            ExpandBounds(BR,HasPad,PadL,PadB,PadR,PadT);
        End;

        If O.Layer=eMechanical1 Then
        Begin
            M1N:=M1N+1;
            ExpandBounds(BR,HasM1,M1L,M1B,M1R,M1T);
        End;

        If O.Layer=eMechanical2 Then
        Begin
            M2N:=M2N+1;
            ExpandBounds(BR,HasM2,M2L,M2B,M2R,M2T);
        End;

        O:=GI.NextPCBObject;
    End;

    C.GroupIterator_Destroy(GI);

    If HasM2 Then
    Begin
        GCompWithM2:=GCompWithM2+1;
        AddLine('');
        AddLine('============================================================');
        AddLine('RefDes: '+C.SourceDesignator);
        AddLine('Layer: '+Layer2String(C.Layer));
        AddLine('X/Y mil: '+
            FloatToStr(CoordToMils(C.X))+' / '+
            FloatToStr(CoordToMils(C.Y)));
        AddLine('Rotation deg: '+FloatToStr(C.Rotation));
        AddLine('PadCount: '+IntToStr(PadN));
        AddLine('PAD: '+DimsText(HasPad,PadL,PadB,PadR,PadT));
        AddLine('Mech1Count: '+IntToStr(M1N));
        AddLine('MECH1: '+DimsText(HasM1,M1L,M1B,M1R,M1T));
        AddLine('Mech2Count: '+IntToStr(M2N));
        AddLine('MECH2: '+DimsText(HasM2,M2L,M2B,M2R,M2T));
    End;
End;

Procedure AuditAllComponents;
Var BI;C;
Begin
    GCompCount:=0;
    GCompWithM2:=0;

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
        AuditComponent(C);
        C:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
End;

Procedure AuditLooseMechanical2;
Var BI;O;
Begin
    GLooseM2Count:=0;

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then
    Begin
        AddLine('ERROR: loose Mech2 iterator unavailable.');
        Exit;
    End;

    BI.AddFilter_ObjectSet(
        MkSet(
            eTrackObject,
            eArcObject,
            eFillObject,
            eRegionObject,
            eTextObject
        )
    );
    BI.AddFilter_LayerSet(MkSet(eMechanical2));
    BI.AddFilter_Method(eProcessAll);

    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If O.InComponent=False Then
        Begin
            GLooseM2Count:=GLooseM2Count+1;
            AddLine(
                'LOOSE_MECH2 #'+IntToStr(GLooseM2Count)+
                ' ObjectId='+IntToStr(O.ObjectId)
            );
        End;
        O:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
End;

Procedure AuditT24_Global_Mech2_Usage_v1;
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
        AddLine('Datalogger RevA - T24 Global Mechanical-2 Usage Audit v1');
        AddLine('READ ONLY');
        AddLine('PCB: '+GBoard.FileName);
        AddLine('');
        AddLine('Goal: prove Mechanical Layer 2 is globally safe to migrate/retag as Courtyard.');

        AuditAllComponents;

        AddLine('');
        AddLine('============================================================');
        AddLine('LOOSE / NON-COMPONENT MECHANICAL-2 PRIMITIVES');
        AuditLooseMechanical2;

        AddLine('');
        AddLine('============================================================');
        AddLine('SUMMARY');
        AddLine('Total components scanned: '+IntToStr(GCompCount));
        AddLine('Components containing Mechanical 2: '+IntToStr(GCompWithM2));
        AddLine('Loose non-component Mechanical 2 primitives: '+IntToStr(GLooseM2Count));

        If GLooseM2Count=0 Then
            AddLine('PASS: no loose board-level Mechanical 2 primitives found.')
        Else
            AddLine('REVIEW: Mechanical 2 contains non-component primitives; do not migrate globally yet.');

        FN:=ExtractFilePath(GBoard.FileName)+
            'T24_Global_Mech2_Usage_Audit.txt';
        GReport.SaveToFile(FN);

        Msg:='READ-ONLY GLOBAL MECH2 AUDIT COMPLETE.'+#13#10+
             'Components with Mech2: '+IntToStr(GCompWithM2)+#13#10+
             'Loose Mech2 primitives: '+IntToStr(GLooseM2Count)+#13#10+
             'Report: T24_Global_Mech2_Usage_Audit.txt'+#13#10+
             'Nothing changed.';

        ShowMessage(Msg);
    Finally
        GReport.Free;
    End;
End;
