{ Datalogger RevA - T24
  FINAL COURTYARD PERSISTENCE AUDIT v1
  READ ONLY. No PCB geometry, rules, selection, or library content is modified.

  Run only AFTER:
    1) controlled 16-component ECO completed,
    2) DATALOGER_RevA.PcbDoc saved,
    3) PcbDoc closed,
    4) PcbDoc reopened.

  PASS criteria:
    - canonical PCB filename
    - 129 total components
    - 129 / 129 components have M2/M4 courtyard data
    - all 16 repaired components have exactly 4 courtyard tracks
    - Top-side repaired components: 4 tracks on Mechanical2, 0 on Mechanical4
    - U_RTC bottom-side placement: 0 on Mechanical2, 4 on Mechanical4
    - repaired courtyard outer envelope matches audited PAD/Mechanical1 union

  Output:
    T24_Courtyard_Final_Persistence_Audit_v1.txt

  Entry:
    AuditT24_Courtyard_Final_Persistence_v1
}

Var
    GBoard;
    GReport;
    GFailCount;

Function T24NearMil(A,V);
Begin
    Result := Abs(A - V) < 0.05;
End;

Function T24FindComponent(S);
Var
    It;
    C;
Begin
    Result := Nil;

    It := GBoard.BoardIterator_Create;
    If It = Nil Then
        Exit;

    It.AddFilter_ObjectSet(MkSet(eComponentObject));
    It.AddFilter_LayerSet(AllLayers);
    It.AddFilter_Method(eProcessAll);

    C := It.FirstPCBObject;
    While C <> Nil Do Begin
        If UpperCase(C.SourceDesignator) = UpperCase(S) Then Begin
            Result := C;
            Break;
        End;

        C := It.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(It);
End;

Procedure T24MeasureMode(C,Mode; Var N,L,B,R,T);
Var
    It;
    O;
    BR;
    UseIt;
Begin
    N := 0;
    L := 0;
    B := 0;
    R := 0;
    T := 0;

    It := C.GroupIterator_Create;
    If It = Nil Then Begin
        N := -1;
        Exit;
    End;

    It.AddFilter_ObjectSet(
        MkSet(ePadObject,eTrackObject,eArcObject,eFillObject,eRegionObject,eTextObject)
    );
    It.AddFilter_LayerSet(AllLayers);

    O := It.FirstPCBObject;
    While O <> Nil Do Begin
        UseIt := False;

        If Mode = 0 Then
            UseIt := O.ObjectId = ePadObject;

        If Mode = 1 Then
            UseIt := (O.Layer = eMechanical1) And
                     (O.ObjectId <> eTextObject);

        If Mode = 2 Then
            UseIt := ((O.Layer = eMechanical2) Or
                      (O.Layer = eMechanical4)) And
                     (O.ObjectId <> eTextObject);

        If UseIt Then Begin
            BR := O.BoundingRectangle;

            If N = 0 Then Begin
                L := CoordToMils(BR.Left);
                B := CoordToMils(BR.Bottom);
                R := CoordToMils(BR.Right);
                T := CoordToMils(BR.Top);
            End
            Else Begin
                If CoordToMils(BR.Left) < L Then
                    L := CoordToMils(BR.Left);

                If CoordToMils(BR.Bottom) < B Then
                    B := CoordToMils(BR.Bottom);

                If CoordToMils(BR.Right) > R Then
                    R := CoordToMils(BR.Right);

                If CoordToMils(BR.Top) > T Then
                    T := CoordToMils(BR.Top);
            End;

            N := N + 1;
        End;

        O := It.NextPCBObject;
    End;

    C.GroupIterator_Destroy(It);
End;

Procedure T24MeasureLayer(C,Lay; Var N,L,B,R,T);
Var
    It;
    O;
    BR;
Begin
    N := 0;
    L := 0;
    B := 0;
    R := 0;
    T := 0;

    It := C.GroupIterator_Create;
    If It = Nil Then Begin
        N := -1;
        Exit;
    End;

    It.AddFilter_ObjectSet(
        MkSet(eTrackObject,eArcObject,eFillObject,eRegionObject)
    );
    It.AddFilter_LayerSet(MkSet(Lay));

    O := It.FirstPCBObject;
    While O <> Nil Do Begin
        BR := O.BoundingRectangle;

        If N = 0 Then Begin
            L := CoordToMils(BR.Left);
            B := CoordToMils(BR.Bottom);
            R := CoordToMils(BR.Right);
            T := CoordToMils(BR.Top);
        End
        Else Begin
            If CoordToMils(BR.Left) < L Then
                L := CoordToMils(BR.Left);

            If CoordToMils(BR.Bottom) < B Then
                B := CoordToMils(BR.Bottom);

            If CoordToMils(BR.Right) > R Then
                R := CoordToMils(BR.Right);

            If CoordToMils(BR.Top) > T Then
                T := CoordToMils(BR.Top);
        End;

        N := N + 1;
        O := It.NextPCBObject;
    End;

    C.GroupIterator_Destroy(It);
End;

Procedure T24UnionPadM1(C; Var L,B,R,T);
Var
    NP;
    NM;
    PL;
    PB;
    PR;
    PT;
    ML;
    MB;
    MR;
    MT;
Begin
    T24MeasureMode(C,0,NP,PL,PB,PR,PT);

    L := PL;
    B := PB;
    R := PR;
    T := PT;

    T24MeasureMode(C,1,NM,ML,MB,MR,MT);

    If NM > 0 Then Begin
        If ML < L Then L := ML;
        If MB < B Then B := MB;
        If MR > R Then R := MR;
        If MT > T Then T := MT;
    End;
End;

Function T24CountComponents;
Var
    It;
    C;
    N;
Begin
    N := 0;

    It := GBoard.BoardIterator_Create;
    If It = Nil Then Begin
        Result := -1;
        Exit;
    End;

    It.AddFilter_ObjectSet(MkSet(eComponentObject));
    It.AddFilter_LayerSet(AllLayers);
    It.AddFilter_Method(eProcessAll);

    C := It.FirstPCBObject;
    While C <> Nil Do Begin
        N := N + 1;
        C := It.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(It);
    Result := N;
End;

Function T24CountCovered;
Var
    It;
    C;
    Covered;
    N;
    L;
    B;
    R;
    T;
Begin
    Covered := 0;

    It := GBoard.BoardIterator_Create;
    If It = Nil Then Begin
        Result := -1;
        Exit;
    End;

    It.AddFilter_ObjectSet(MkSet(eComponentObject));
    It.AddFilter_LayerSet(AllLayers);
    It.AddFilter_Method(eProcessAll);

    C := It.FirstPCBObject;
    While C <> Nil Do Begin
        T24MeasureMode(C,2,N,L,B,R,T);

        If N > 0 Then
            Covered := Covered + 1;

        C := It.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(It);
    Result := Covered;
End;

Procedure T24AuditTarget(RefName,ExpectedMainLayer);
Var
    C;
    NM2;
    NM4;
    LM2;
    BM2;
    RM2;
    TM2;
    LM4;
    BM4;
    RM4;
    TM4;
    UL;
    UB;
    UR;
    UT;
    CL;
    CB;
    CR;
    CT;
    Pass;
Begin
    Pass := True;

    C := T24FindComponent(RefName);

    If C = Nil Then Begin
        GReport.Add(RefName+' | FAIL | missing component');
        GFailCount := GFailCount + 1;
        Exit;
    End;

    T24MeasureLayer(C,eMechanical2,NM2,LM2,BM2,RM2,TM2);
    T24MeasureLayer(C,eMechanical4,NM4,LM4,BM4,RM4,TM4);

    If ExpectedMainLayer = eMechanical2 Then Begin
        If NM2 <> 4 Then Pass := False;
        If NM4 <> 0 Then Pass := False;

        CL := LM2;
        CB := BM2;
        CR := RM2;
        CT := TM2;
    End
    Else Begin
        If NM4 <> 4 Then Pass := False;
        If NM2 <> 0 Then Pass := False;

        CL := LM4;
        CB := BM4;
        CR := RM4;
        CT := TM4;
    End;

    T24UnionPadM1(C,UL,UB,UR,UT);

    If Not T24NearMil(CL,UL) Then Pass := False;
    If Not T24NearMil(CB,UB) Then Pass := False;
    If Not T24NearMil(CR,UR) Then Pass := False;
    If Not T24NearMil(CT,UT) Then Pass := False;

    If Pass Then Begin
        GReport.Add(
            RefName+
            ' | PASS | M2='+IntToStr(NM2)+
            ' M4='+IntToStr(NM4)+
            ' | courtyard L/B/R/T mil='+
            FloatToStr(CL)+' / '+
            FloatToStr(CB)+' / '+
            FloatToStr(CR)+' / '+
            FloatToStr(CT)
        );
    End
    Else Begin
        GReport.Add(
            RefName+
            ' | FAIL | M2='+IntToStr(NM2)+
            ' M4='+IntToStr(NM4)+
            ' | courtyard L/B/R/T mil='+
            FloatToStr(CL)+' / '+
            FloatToStr(CB)+' / '+
            FloatToStr(CR)+' / '+
            FloatToStr(CT)+
            ' | union L/B/R/T mil='+
            FloatToStr(UL)+' / '+
            FloatToStr(UB)+' / '+
            FloatToStr(UR)+' / '+
            FloatToStr(UT)
        );

        GFailCount := GFailCount + 1;
    End;
End;

Procedure AuditT24_Courtyard_Final_Persistence_v1;
Var
    Total;
    Covered;
    OutPath;
Begin
    GReport := TStringList.Create;

    Try
        GBoard := PCBServer.GetCurrentPCBBoard;

        If GBoard = Nil Then Begin
            ShowMessage('ABORT: No PCB active. Nothing changed.');
            Exit;
        End;

        If UpperCase(ExtractFileName(GBoard.FileName))
           <> 'DATALOGER_REVA.PCBDOC' Then Begin
            ShowMessage(
                'ABORT: Activate DATALOGER_RevA.PcbDoc. Nothing changed.'
            );
            Exit;
        End;

        GFailCount := 0;

        Total := T24CountComponents;
        Covered := T24CountCovered;

        GReport.Add('Datalogger RevA - T24 Final Courtyard Persistence Audit v1');
        GReport.Add('READ ONLY');
        GReport.Add('PCB: '+GBoard.FileName);
        GReport.Add('');
        GReport.Add(
            'TOTAL COMPONENTS: '+IntToStr(Total)
        );
        GReport.Add(
            'COURTYARD COVERED: '+IntToStr(Covered)+' / '+IntToStr(Total)
        );
        GReport.Add('');

        If Total <> 129 Then
            GFailCount := GFailCount + 1;

        If Covered <> 129 Then
            GFailCount := GFailCount + 1;

        T24AuditTarget('U_RTC',eMechanical4);

        T24AuditTarget('Q_SD',eMechanical2);
        T24AuditTarget('Q_OLED',eMechanical2);
        T24AuditTarget('J_SWD',eMechanical2);
        T24AuditTarget('J_SHIELD',eMechanical2);
        T24AuditTarget('J_NAV',eMechanical2);
        T24AuditTarget('J_SD',eMechanical2);

        T24AuditTarget('D_EXT1',eMechanical2);
        T24AuditTarget('D_EXT2',eMechanical2);
        T24AuditTarget('D_EXT3',eMechanical2);
        T24AuditTarget('D_ESD',eMechanical2);
        T24AuditTarget('D_ESD1',eMechanical2);
        T24AuditTarget('D_ESD2',eMechanical2);

        T24AuditTarget('C_SENSOR_BULK',eMechanical2);
        T24AuditTarget('C_SD_MID',eMechanical2);
        T24AuditTarget('C_OLED_BULK',eMechanical2);

        GReport.Add('');

        If GFailCount = 0 Then
            GReport.Add('FINAL STATE: PASS - 129 / 129 persistent courtyard coverage.')
        Else
            GReport.Add(
                'FINAL STATE: FAIL - '+IntToStr(GFailCount)+
                ' audit condition(s) failed.'
            );

        GReport.Add('Nothing changed.');

        OutPath :=
            ExtractFilePath(GBoard.FileName)+
            'T24_Courtyard_Final_Persistence_Audit_v1.txt';

        GReport.SaveToFile(OutPath);

        If GFailCount = 0 Then Begin
            ShowMessage(
                'PASS: 129 / 129 courtyard coverage persists after reopen.'+#13#10+
                'All 16 repaired components passed layer + envelope checks.'+#13#10+
                'NEXT: Full Batch DRC.'+#13#10+
                'Report: T24_Courtyard_Final_Persistence_Audit_v1.txt'
            );
        End
        Else Begin
            ShowMessage(
                'FAIL: '+IntToStr(GFailCount)+
                ' persistence audit condition(s) failed.'+#13#10+
                'Do not continue to DRC yet.'+#13#10+
                'Report: T24_Courtyard_Final_Persistence_Audit_v1.txt'
            );
        End;

    Finally
        GReport.Free;
    End;
End;
