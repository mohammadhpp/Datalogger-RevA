{ Datalogger RevA - T24
  ComponentClearance boundary-mode audit v1
  READ ONLY. No rule edit, no PCB mutation, no DRC run.
  Output: T24_ComponentClearance_BoundaryMode_Audit_v1.txt
}

Var
    GBoard;
    GReport;

Procedure BMAAdd(S);
Begin
    GReport.Add(S);
End;

Function BMABoolText(B);
Begin
    If B Then Result:='TRUE' Else Result:='FALSE';
End;

Procedure AuditT24_ComponentClearance_BoundaryMode_v1;
Var It; R; FN; Found;
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
        BMAAdd('Datalogger RevA - T24 ComponentClearance Boundary Mode Audit v1');
        BMAAdd('READ ONLY');
        BMAAdd('PCB: '+GBoard.FileName);
        BMAAdd('');

        Found:=0;

        It:=GBoard.BoardIterator_Create;
        If It=Nil Then Begin
            BMAAdd('ERROR: rule iterator unavailable.');
        End Else Begin
            It.AddFilter_ObjectSet(MkSet(eRuleObject));
            It.AddFilter_LayerSet(AllLayers);
            It.AddFilter_Method(eProcessAll);

            R:=It.FirstPCBObject;
            While R<>Nil Do Begin
                If R.RuleKind=eRule_ComponentClearance Then Begin
                    Found:=Found+1;
                    BMAAdd('Rule Name: '+R.Name);
                    BMAAdd('Gap mil: '+FloatToStr(CoordToMils(R.Gap)));
                    BMAAdd('VerticalGap mil: '+FloatToStr(CoordToMils(R.VerticalGap)));
                    BMAAdd('CollisionCheckMode: '+IntToStr(R.CollisionCheckMode));
                    BMAAdd('CheckByCompBoundary: '+BMABoolText(R.CheckByCompBoundary));
                    BMAAdd('Scope1: '+R.Scope1Expression);
                    BMAAdd('Scope2: '+R.Scope2Expression);
                    BMAAdd('');
                End;
                R:=It.NextPCBObject;
            End;

            GBoard.BoardIterator_Destroy(It);
        End;

        BMAAdd('ComponentClearance rule count: '+IntToStr(Found));
        BMAAdd('Nothing changed.');

        FN:=ExtractFilePath(GBoard.FileName)+
            'T24_ComponentClearance_BoundaryMode_Audit_v1.txt';
        GReport.SaveToFile(FN);

        ShowMessage('READ-ONLY BOUNDARY MODE AUDIT COMPLETE.'+#13#10+
            'Rules found: '+IntToStr(Found)+#13#10+
            'Output: T24_ComponentClearance_BoundaryMode_Audit_v1.txt'+#13#10+
            'Nothing changed.');
    Finally
        GReport.Free;
    End;
End;
