{ Datalogger RevA - T24
  ComponentClearance raw rule summary audit v1
  READ ONLY. No PCB/rule mutation, no DRC run, no save.
  Uses documented IPCB_Rule summary/descriptor methods only.
  Output: T24_ComponentClearance_RawRuleSummary_v1.txt
}

Var
    GBoard;
    GReport;

Procedure RSAdd(S);
Begin
    GReport.Add(S);
End;

Procedure AuditT24_ComponentClearance_RawRuleSummary_v1;
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
        RSAdd('Datalogger RevA - T24 ComponentClearance Raw Rule Summary v1');
        RSAdd('READ ONLY');
        RSAdd('PCB: '+GBoard.FileName);
        RSAdd('');

        Found:=0;

        It:=GBoard.BoardIterator_Create;
        If It=Nil Then Begin
            RSAdd('ERROR: rule iterator unavailable.');
        End Else Begin
            It.AddFilter_ObjectSet(MkSet(eRuleObject));
            It.AddFilter_LayerSet(AllLayers);
            It.AddFilter_Method(eProcessAll);

            R:=It.FirstPCBObject;
            While R<>Nil Do Begin
                If R.RuleKind=eRule_ComponentClearance Then Begin
                    Found:=Found+1;
                    RSAdd('============================================================');
                    RSAdd('Rule Name: '+R.Name);
                    RSAdd('DRCEnabled: '+BoolToStr(R.DRCEnabled,True));
                    RSAdd('Scope1: '+R.Scope1Expression);
                    RSAdd('Scope2: '+R.Scope2Expression);
                    RSAdd('Gap mil: '+FloatToStr(CoordToMils(R.Gap)));
                    RSAdd('VerticalGap mil: '+FloatToStr(CoordToMils(R.VerticalGap)));
                    RSAdd('CollisionCheckMode: '+IntToStr(R.CollisionCheckMode));
                    RSAdd('ShortDescriptor: '+R.GetState_ShortDescriptorString);
                    RSAdd('ScopeDescriptor: '+R.GetState_ScopeDescriptorString);
                    RSAdd('DataSummary: '+R.GetState_DataSummaryString);
                    RSAdd('');
                End;
                R:=It.NextPCBObject;
            End;

            GBoard.BoardIterator_Destroy(It);
        End;

        RSAdd('ComponentClearance rule count: '+IntToStr(Found));
        RSAdd('Nothing changed.');

        FN:=ExtractFilePath(GBoard.FileName)+
            'T24_ComponentClearance_RawRuleSummary_v1.txt';
        GReport.SaveToFile(FN);

        ShowMessage('READ-ONLY RAW RULE SUMMARY COMPLETE.'+#13#10+
            'Rules found: '+IntToStr(Found)+#13#10+
            'Output: T24_ComponentClearance_RawRuleSummary_v1.txt'+#13#10+
            'Nothing changed.');
    Finally
        GReport.Free;
    End;
End;
