{ Datalogger RevA - T24
  FINAL COURTYARD PERSISTENCE AUDIT v1
  READ ONLY. No geometry/rules/selection/library changes.

  Run after Save -> Close PcbDoc -> Reopen PcbDoc.

  PASS:
    - DATALOGER_RevA.PcbDoc active
    - 129 total components
    - 129 / 129 have M2/M4 courtyard data
    - 15 repaired Top-side components have exactly 4 primitives on M2 and 0 on M4
    - U_RTC has 0 on M2 and exactly 4 on M4

  Output:
    T24_Courtyard_Final_Persistence_Audit_v1.txt

  Entry:
    AuditT24_Courtyard_Final_Persistence_v1
}

Var
    GBoard;
    GReport;
    GFailCount;

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

Function T24CountLayer(C,Lay);
Var
    It;
    O;
    N;
Begin
    N := 0;

    It := C.GroupIterator_Create;
    If It = Nil Then Begin
        Result := -1;
        Exit;
    End;

    It.AddFilter_ObjectSet(
        MkSet(eTrackObject,eArcObject,eFillObject,eRegionObject)
    );
    It.AddFilter_LayerSet(MkSet(Lay));

    O := It.FirstPCBObject;
    While O <> Nil Do Begin
        N := N + 1;
        O := It.NextPCBObject;
    End;

    C.GroupIterator_Destroy(It);
    Result := N;
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
    NM2;
    NM4;
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
        NM2 := T24CountLayer(C,eMechanical2);
        NM4 := T24CountLayer(C,eMechanical4);

        If (NM2 > 0) Or (NM4 > 0) Then
            Covered := Covered + 1;

        C := It.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(It);
    Result := Covered;
End;

Procedure T24AuditTarget(RefName,ExpectedM2,ExpectedM4);
Var
    C;
    NM2;
    NM4;
Begin
    C := T24FindComponent(RefName);

    If C = Nil Then Begin
        GReport.Add(RefName+' | FAIL | missing component');
        GFailCount := GFailCount + 1;
        Exit;
    End;

    NM2 := T24CountLayer(C,eMechanical2);
    NM4 := T24CountLayer(C,eMechanical4);

    If (NM2 = ExpectedM2) And (NM4 = ExpectedM4) Then Begin
        GReport.Add(
            RefName+
            ' | PASS | M2='+IntToStr(NM2)+
            ' M4='+IntToStr(NM4)
        );
    End
    Else Begin
        GReport.Add(
            RefName+
            ' | FAIL | M2='+IntToStr(NM2)+
            ' M4='+IntToStr(NM4)+
            ' | expected M2='+IntToStr(ExpectedM2)+
            ' M4='+IntToStr(ExpectedM4)
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
        GReport.Add('TOTAL COMPONENTS: '+IntToStr(Total));
        GReport.Add(
            'COURTYARD COVERED: '+IntToStr(Covered)+' / '+IntToStr(Total)
        );
        GReport.Add('');

        If Total <> 129 Then
            GFailCount := GFailCount + 1;

        If Covered <> 129 Then
            GFailCount := GFailCount + 1;

        T24AuditTarget('U_RTC',0,4);

        T24AuditTarget('Q_SD',4,0);
        T24AuditTarget('Q_OLED',4,0);
        T24AuditTarget('J_SWD',4,0);
        T24AuditTarget('J_SHIELD',4,0);
        T24AuditTarget('J_NAV',4,0);
        T24AuditTarget('J_SD',4,0);

        T24AuditTarget('D_EXT1',4,0);
        T24AuditTarget('D_EXT2',4,0);
        T24AuditTarget('D_EXT3',4,0);
        T24AuditTarget('D_ESD',4,0);
        T24AuditTarget('D_ESD1',4,0);
        T24AuditTarget('D_ESD2',4,0);

        T24AuditTarget('C_SENSOR_BULK',4,0);
        T24AuditTarget('C_SD_MID',4,0);
        T24AuditTarget('C_OLED_BULK',4,0);

        GReport.Add('');

        If GFailCount = 0 Then
            GReport.Add(
                'FINAL STATE: PASS - 129 / 129 persistent courtyard coverage.'
            )
        Else
            GReport.Add(
                'FINAL STATE: FAIL - '+IntToStr(GFailCount)+
                ' condition(s) failed.'
            );

        GReport.Add('Nothing changed.');

        OutPath :=
            ExtractFilePath(GBoard.FileName)+
            'T24_Courtyard_Final_Persistence_Audit_v1.txt';

        GReport.SaveToFile(OutPath);

        If GFailCount = 0 Then Begin
            ShowMessage(
                'PASS: 129 / 129 courtyard coverage persists after reopen.'+#13#10+
                'All 16 repaired components passed layer checks.'+#13#10+
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
