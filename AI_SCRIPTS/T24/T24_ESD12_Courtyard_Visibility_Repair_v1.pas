{ Datalogger RevA - T24
  Refresh LayersUsed for D_ESD1 / D_ESD2 after component-child courtyard insertion.
  NO geometry creation/deletion. NO rule/copper/polygon changes.

  Entry:
    RepairT24_ESD12_CourtyardVisibility_v1
}

Var
    GBoard;

Function RVFindComponent(S);
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
        If UpperCase(C.SourceDesignator)=UpperCase(S) Then Begin
            Result:=C;
            Break;
        End;
        C:=It.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(It);
End;

Function RVCountCourtyard(C);
Var GI; O; N;
Begin
    N:=0;
    GI:=C.GroupIterator_Create;
    If GI=Nil Then Begin Result:=-1; Exit; End;

    GI.AddFilter_ObjectSet(MkSet(eTrackObject,eArcObject,eFillObject,eRegionObject));
    GI.AddFilter_LayerSet(MkSet(eMechanical2,eMechanical4));

    O:=GI.FirstPCBObject;
    While O<>Nil Do Begin
        N:=N+1;
        O:=GI.NextPCBObject;
    End;

    C.GroupIterator_Destroy(GI);
    Result:=N;
End;

Procedure RVRefresh(C);
Begin
    PCBServer.SendMessageToRobots(
        C.I_ObjectAddress,
        c_Broadcast,
        PCBM_BeginModify,
        c_NoEventData
    );

    Try
        C.SetState_LayersUsedArray;
        C.SetState_XSizeYSize;
    Finally
        PCBServer.SendMessageToRobots(
            C.I_ObjectAddress,
            c_Broadcast,
            PCBM_EndModify,
            c_NoEventData
        );
    End;

    GBoard.ViewManager_GraphicallyInvalidatePrimitive(C);
End;

Procedure RepairT24_ESD12_CourtyardVisibility_v1;
Var C1; C2; N1; N2;
Begin
    GBoard:=PCBServer.GetCurrentPCBBoard;

    If GBoard=Nil Then Begin
        ShowMessage('ABORT: no PCB active. Nothing changed.');
        Exit;
    End;

    If UpperCase(ExtractFileName(GBoard.FileName))
       <>'DATALOGER_REVA_T24_COURTYARD_PENDING.PCBDOC' Then Begin
        ShowMessage('ABORT: activate DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc.');
        Exit;
    End;

    C1:=RVFindComponent('D_ESD1');
    C2:=RVFindComponent('D_ESD2');

    If (C1=Nil) Or (C2=Nil) Then Begin
        ShowMessage('ABORT: D_ESD1 or D_ESD2 missing.');
        Exit;
    End;

    N1:=RVCountCourtyard(C1);
    N2:=RVCountCourtyard(C2);

    If (N1<>4) Or (N2<>4) Then Begin
        ShowMessage(
            'ABORT: expected 4 courtyard primitives on each component.'+#13#10+
            'D_ESD1='+IntToStr(N1)+' / D_ESD2='+IntToStr(N2)+#13#10+
            'Nothing changed.'
        );
        Exit;
    End;

    PCBServer.PreProcess;
    Try
        RVRefresh(C1);
        RVRefresh(C2);
    Finally
        PCBServer.PostProcess;
    End;

    GBoard.ViewManager_FullUpdate;

    ShowMessage(
        'REFRESH COMPLETE.'+#13#10+
        'No geometry was added or removed.'+#13#10+
        'D_ESD1 and D_ESD2 LayersUsed arrays were rebuilt.'+#13#10+
        'Now select Top Courtyard and visually verify the two rectangles.'+#13#10+
        'Do not save until they are visible.'
    );
End;
