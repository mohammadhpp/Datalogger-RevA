{ Datalogger RevA - T24
  Apply13 post-crash state audit v1
  READ ONLY. No PCB mutation, no rule edit, no DRC run, no save.
  Purpose: determine whether Apply13 v2 survived an Altium crash before save.
  Output: T24_Apply13_PostCrash_Audit_v1.txt
}

Var
    GBoard;
    GReport;

Procedure PCAdd(S);
Begin
    GReport.Add(S);
End;

Function PCFindComponent(RefName);
Var It; C;
Begin
    Result:=Nil;
    It:=GBoard.BoardIterator_Create;
    If It=Nil Then Exit;
    It.AddFilter_ObjectSet(MkSet(eComponentObject));
    It.AddFilter_LayerSet(AllLayers);
    It.AddFilter_Method(eProcessAll);
    C:=It.FirstPCBObject;
    While C<>Nil Do Begin
        If UpperCase(C.SourceDesignator)=UpperCase(RefName) Then Begin
            Result:=C; Break;
        End;
        C:=It.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(It);
End;

Function PCCountCourtyardPrims(C);
Var It; O; N;
Begin
    N:=0;
    It:=C.GroupIterator_Create;
    If It=Nil Then Begin Result:=-1; Exit; End;
    It.AddFilter_ObjectSet(MkSet(eTrackObject,eArcObject,eFillObject,eRegionObject,eTextObject));
    It.AddFilter_LayerSet(AllLayers);
    O:=It.FirstPCBObject;
    While O<>Nil Do Begin
        If ((O.Layer=eMechanical2) Or (O.Layer=eMechanical4)) And (O.ObjectId<>eTextObject) Then
            N:=N+1;
        O:=It.NextPCBObject;
    End;
    C.GroupIterator_Destroy(It);
    Result:=N;
End;

Function PCCoveredCount;
Var It; C; N;
Begin
    N:=0;
    It:=GBoard.BoardIterator_Create;
    If It=Nil Then Begin Result:=-1; Exit; End;
    It.AddFilter_ObjectSet(MkSet(eComponentObject));
    It.AddFilter_LayerSet(AllLayers);
    It.AddFilter_Method(eProcessAll);
    C:=It.FirstPCBObject;
    While C<>Nil Do Begin
        If PCCountCourtyardPrims(C)>0 Then N:=N+1;
        C:=It.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(It);
    Result:=N;
End;

Procedure PCCheckTarget(RefName);
Var C; N;
Begin
    C:=PCFindComponent(RefName);
    If C=Nil Then Begin
        PCAdd(RefName+' | MISSING');
        Exit;
    End;
    N:=PCCountCourtyardPrims(C);
    PCAdd(RefName+' | courtyard primitive count='+IntToStr(N));
End;

Procedure AuditT24_Apply13_PostCrash_v1;
Var Covered; FN;
Begin
    GBoard:=PCBServer.GetCurrentPCBBoard;
    If GBoard=Nil Then Begin
        ShowMessage('ABORT: no PCB active. Nothing changed.');
        Exit;
    End;

    If UpperCase(ExtractFileName(GBoard.FileName))<>'DATALOGER_REVA_T24_COURTYARD_PENDING.PCBDOC' Then Begin
        ShowMessage('ABORT: activate DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc. Nothing changed.');
        Exit;
    End;

    GReport:=TStringList.Create;
    Try
        PCAdd('Datalogger RevA - T24 Apply13 post-crash audit v1');
        PCAdd('READ ONLY');
        PCAdd('PCB: '+GBoard.FileName);
        PCAdd('');

        Covered:=PCCoveredCount;
        PCAdd('Covered components: '+IntToStr(Covered)+' / 129');
        PCAdd('');

        PCCheckTarget('U_RTC');
        PCCheckTarget('Q_SD');
        PCCheckTarget('Q_OLED');
        PCCheckTarget('J_SWD');
        PCCheckTarget('J_SHIELD');
        PCCheckTarget('J_NAV');
        PCCheckTarget('D_EXT3');
        PCCheckTarget('D_EXT2');
        PCCheckTarget('D_EXT1');
        PCCheckTarget('D_ESD');
        PCCheckTarget('C_SENSOR_BULK');
        PCCheckTarget('C_SD_MID');
        PCCheckTarget('C_OLED_BULK');

        PCAdd('');
        PCAdd('Deferred targets should still have no courtyard:');
        PCCheckTarget('D_ESD1');
        PCCheckTarget('D_ESD2');
        PCCheckTarget('J_SD');

        PCAdd('');
        If Covered=126 Then
            PCAdd('STATE: Apply13 appears PRESENT. Review target counts before continuing.')
        Else If Covered=113 Then
            PCAdd('STATE: Apply13 appears NOT PRESENT. Baseline likely restored/reopened.')
        Else
            PCAdd('STATE: MIXED/UNEXPECTED. Do not continue until reviewed.');

        PCAdd('Nothing changed.');

        FN:=ExtractFilePath(GBoard.FileName)+'T24_Apply13_PostCrash_Audit_v1.txt';
        GReport.SaveToFile(FN);

        ShowMessage('POST-CRASH AUDIT COMPLETE.'+#13#10+
            'Covered: '+IntToStr(Covered)+' / 129'+#13#10+
            'Output: T24_Apply13_PostCrash_Audit_v1.txt'+#13#10+
            'Nothing changed.');
    Finally
        GReport.Free;
    End;
End;
