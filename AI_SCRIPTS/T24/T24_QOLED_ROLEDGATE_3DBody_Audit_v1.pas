{ Datalogger RevA - T24
  Q_OLED / R_OLED_GATE 3D Body audit v1
  READ ONLY. No PCB/rule mutation, no DRC run, no save.
  Output: T24_QOLED_ROLEDGATE_3DBody_Audit_v1.txt
}

Var
    GBoard;
    GReport;

Procedure B3Add(S);
Begin
    GReport.Add(S);
End;

Function B3FindComponent(RefName);
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
            Result:=C;
            Break;
        End;
        C:=It.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(It);
End;

Procedure B3ExportComponent(C);
Var It; O; BR; N;
Begin
    B3Add('');
    B3Add('============================================================');
    B3Add('RefDes: '+C.SourceDesignator);
    B3Add('Component Height mil: '+FloatToStr(CoordToMils(C.Height)));
    B3Add('DefaultPCB3DModel: '+C.DefaultPCB3DModel);

    N:=0;
    It:=C.GroupIterator_Create;
    If It=Nil Then Begin
        B3Add('ERROR: GroupIterator unavailable.');
        Exit;
    End;

    It.AddFilter_ObjectSet(MkSet(eComponentBodyObject));
    It.AddFilter_LayerSet(AllLayers);

    O:=It.FirstPCBObject;
    While O<>Nil Do Begin
        N:=N+1;
        BR:=O.BoundingRectangle;

        B3Add('3D Body #'+IntToStr(N));
        B3Add('  Layer: '+Layer2String(O.Layer));
        B3Add('  BBox L/B/R/T mil: '+
            FloatToStr(CoordToMils(BR.Left))+' / '+
            FloatToStr(CoordToMils(BR.Bottom))+' / '+
            FloatToStr(CoordToMils(BR.Right))+' / '+
            FloatToStr(CoordToMils(BR.Top)));
        B3Add('  StandoffHeight mil: '+FloatToStr(CoordToMils(O.StandoffHeight)));
        B3Add('  OverallHeight mil: '+FloatToStr(CoordToMils(O.OverallHeight)));
        B3Add('  BodyProjection: '+IntToStr(O.BodyProjection));

        O:=It.NextPCBObject;
    End;

    C.GroupIterator_Destroy(It);
    B3Add('3D Body count: '+IntToStr(N));
End;

Procedure AuditT24_QOLED_ROLEDGATE_3DBody_v1;
Var Q; R; FN;
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

    Q:=B3FindComponent('Q_OLED');
    R:=B3FindComponent('R_OLED_GATE');

    If (Q=Nil) Or (R=Nil) Then Begin
        ShowMessage('ABORT: Q_OLED or R_OLED_GATE not found. Nothing changed.');
        Exit;
    End;

    GReport:=TStringList.Create;
    Try
        B3Add('Datalogger RevA - T24 Q_OLED / R_OLED_GATE 3D Body Audit v1');
        B3Add('READ ONLY');
        B3Add('PCB: '+GBoard.FileName);

        B3ExportComponent(Q);
        B3ExportComponent(R);

        B3Add('');
        B3Add('Nothing changed.');

        FN:=ExtractFilePath(GBoard.FileName)+
            'T24_QOLED_ROLEDGATE_3DBody_Audit_v1.txt';

        GReport.SaveToFile(FN);

        ShowMessage('READ-ONLY 3D BODY AUDIT COMPLETE.'+#13#10+
            'Output: T24_QOLED_ROLEDGATE_3DBody_Audit_v1.txt'+#13#10+
            'Nothing changed.');
    Finally
        GReport.Free;
    End;
End;
