{ Datalogger RevA - T24
  ComponentClearance mode fix v1
  PURPOSE: change ONLY ComponentClearance.CollisionCheckMode
           from eComponentBodyCheck (3) to eFullCheck (2).
  Does NOT change Gap, VerticalGap, scopes, components, courtyards, copper or DRC markers.

  Entry:
    ApplyT24_ComponentClearance_FullCheck_v1
}

Var
    GBoard;
    GRule;
    GCount;
    GError;

Function T24FindComponentClearanceRule;
Var It; R;
Begin
    Result:=Nil;
    GCount:=0;

    It:=GBoard.BoardIterator_Create;
    If It=Nil Then Exit;

    It.AddFilter_ObjectSet(MkSet(eRuleObject));
    It.AddFilter_LayerSet(AllLayers);
    It.AddFilter_Method(eProcessAll);

    R:=It.FirstPCBObject;
    While R<>Nil Do Begin
        If R.RuleKind=eRule_ComponentClearance Then Begin
            GCount:=GCount+1;
            Result:=R;
        End;
        R:=It.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(It);
End;

Function T24Precheck;
Begin
    Result:=False;
    GError:='';

    GBoard:=PCBServer.GetCurrentPCBBoard;
    If GBoard=Nil Then Begin
        GError:='No PCB active';
        Exit;
    End;

    If UpperCase(ExtractFileName(GBoard.FileName))
       <>'DATALOGER_REVA_T24_COURTYARD_PENDING.PCBDOC' Then Begin
        GError:='Activate DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc';
        Exit;
    End;

    GRule:=T24FindComponentClearanceRule;

    If GCount<>1 Then Begin
        GError:='Expected exactly one Component Clearance rule; found '+IntToStr(GCount);
        Exit;
    End;

    If GRule=Nil Then Begin
        GError:='Component Clearance rule not found';
        Exit;
    End;

    If UpperCase(GRule.Name)<>'COMPONENTCLEARANCE' Then Begin
        GError:='Unexpected rule name: '+GRule.Name;
        Exit;
    End;

    If Abs(CoordToMils(GRule.Gap)-10)>0.01 Then Begin
        GError:='Horizontal gap is not 10 mil';
        Exit;
    End;

    If Abs(CoordToMils(GRule.VerticalGap)-10)>0.01 Then Begin
        GError:='Vertical gap is not 10 mil';
        Exit;
    End;

    If GRule.CollisionCheckMode<>eComponentBodyCheck Then Begin
        GError:='Expected Component Body Mode before fix; current mode='+IntToStr(GRule.CollisionCheckMode);
        Exit;
    End;

    Result:=True;
End;

Procedure ApplyT24_ComponentClearance_FullCheck_v1;
Begin
    If Not T24Precheck Then Begin
        ShowMessage('ABORT: '+GError+'. Nothing changed.');
        Exit;
    End;

    PCBServer.PreProcess;
    Try
        PCBServer.SendMessageToRobots(
            GRule.I_ObjectAddress,
            c_Broadcast,
            PCBM_BeginModify,
            c_NoEventData
        );

        GRule.CollisionCheckMode:=eFullCheck;

        PCBServer.SendMessageToRobots(
            GRule.I_ObjectAddress,
            c_Broadcast,
            PCBM_EndModify,
            c_NoEventData
        );
    Finally
        PCBServer.PostProcess;
    End;

    If GRule.CollisionCheckMode<>eFullCheck Then Begin
        ShowMessage('POSTCHECK FAILED. DO NOT SAVE.');
        Exit;
    End;

    ShowMessage(
        'APPLY COMPLETE.'+#13#10+
        'ComponentClearance mode: Component Body -> Full Check.'+#13#10+
        'Gap remains 10 mil / Vertical remains 10 mil.'+#13#10+
        'Now Reset Error Markers and run Full Batch DRC.'+#13#10+
        'Do not save until DRC result is reviewed.'
    );
End;
