{ Datalogger RevA - T24
  Q_OLED / R_OLED_GATE focused clearance audit v2
  READ ONLY. No PCB mutation, no rule edit, no DRC run, no save.
  Adds BoundingRectangleForSelection and ComponentClearance rule state.
  Output: T24_QOLED_ROLEDGATE_Audit_v2.txt
}

Var
    GBoard;
    GReport;

Procedure A2Add(S);
Begin
    GReport.Add(S);
End;

Function A2FindComponent(RefName);
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

Procedure A2Reset(Var HasAny; Var L; Var B; Var R; Var T; Var N);
Begin
    HasAny:=False; L:=0; B:=0; R:=0; T:=0; N:=0;
End;

Procedure A2Expand(BR; Var HasAny; Var L; Var B; Var R; Var T; Var N);
Var X1;Y1;X2;Y2;
Begin
    X1:=CoordToMils(BR.Left); Y1:=CoordToMils(BR.Bottom);
    X2:=CoordToMils(BR.Right); Y2:=CoordToMils(BR.Top);
    If Not HasAny Then Begin
        L:=X1; B:=Y1; R:=X2; T:=Y2; HasAny:=True;
    End Else Begin
        If X1<L Then L:=X1;
        If Y1<B Then B:=Y1;
        If X2>R Then R:=X2;
        If Y2>T Then T:=Y2;
    End;
    N:=N+1;
End;

Procedure A2MeasureCourtyard(C; Var HasAny; Var L; Var B; Var R; Var T; Var N);
Var It;O;BR;
Begin
    A2Reset(HasAny,L,B,R,T,N);
    It:=C.GroupIterator_Create;
    If It=Nil Then Exit;
    It.AddFilter_ObjectSet(MkSet(eTrackObject,eArcObject,eFillObject,eRegionObject,eTextObject));
    It.AddFilter_LayerSet(AllLayers);
    O:=It.FirstPCBObject;
    While O<>Nil Do Begin
        If ((O.Layer=eMechanical2) Or (O.Layer=eMechanical4)) And (O.ObjectId<>eTextObject) Then Begin
            BR:=O.BoundingRectangle;
            A2Expand(BR,HasAny,L,B,R,T,N);
        End;
        O:=It.NextPCBObject;
    End;
    C.GroupIterator_Destroy(It);
End;

Procedure A2Rect(LabelText,BR);
Begin
    A2Add(LabelText+' L/B/R/T mil: '+
        FloatToStr(CoordToMils(BR.Left))+' / '+
        FloatToStr(CoordToMils(BR.Bottom))+' / '+
        FloatToStr(CoordToMils(BR.Right))+' / '+
        FloatToStr(CoordToMils(BR.Top)));
End;

Procedure A2ExportComponent(C);
Var BR;SR;PR;
    H;L;B;R;T;N;
Begin
    A2Add('');
    A2Add('============================================================');
    A2Add('RefDes: '+C.SourceDesignator);
    A2Add('X/Y mil: '+FloatToStr(CoordToMils(C.X))+' / '+FloatToStr(CoordToMils(C.Y)));
    A2Add('Rotation deg: '+FloatToStr(C.Rotation));
    BR:=C.BoundingRectangle;
    SR:=C.BoundingRectangleForSelection;
    PR:=C.BoundingRectangleForPainting;
    A2Rect('BoundingRectangle',BR);
    A2Rect('BoundingRectangleForSelection',SR);
    A2Rect('BoundingRectangleForPainting',PR);

    A2MeasureCourtyard(C,H,L,B,R,T,N);
    If H Then
        A2Add('COURTYARD M2/M4 | Count='+IntToStr(N)+
              ' | L/B/R/T mil='+FloatToStr(L)+' / '+FloatToStr(B)+' / '+
              FloatToStr(R)+' / '+FloatToStr(T))
    Else
        A2Add('COURTYARD M2/M4: NONE');
End;

Function A2GapX(AL,AR,BL,BR);
Begin
    If AR<BL Then Result:=BL-AR
    Else If BR<AL Then Result:=AL-BR
    Else Result:=0;
End;

Function A2GapY(AB,AT,BB,BT);
Begin
    If AT<BB Then Result:=BB-AT
    Else If BT<AB Then Result:=AB-BT
    Else Result:=0;
End;

Procedure A2ExportSelectionGap(A,B);
Var AR;BR;DX;DY;
Begin
    AR:=A.BoundingRectangleForSelection;
    BR:=B.BoundingRectangleForSelection;
    DX:=A2GapX(CoordToMils(AR.Left),CoordToMils(AR.Right),
               CoordToMils(BR.Left),CoordToMils(BR.Right));
    DY:=A2GapY(CoordToMils(AR.Bottom),CoordToMils(AR.Top),
               CoordToMils(BR.Bottom),CoordToMils(BR.Top));
    A2Add('');
    A2Add('SELECTION BBOX axis gap | DX='+FloatToStr(DX)+' mil | DY='+FloatToStr(DY)+' mil');
End;

Procedure A2ExportCourtyardGap(A,B);
Var HA;AL;ABo;AR;AT;AN;
    HB;BL;BBo;BRi;BT;BN;
    DX;DY;
Begin
    A2MeasureCourtyard(A,HA,AL,ABo,AR,AT,AN);
    A2MeasureCourtyard(B,HB,BL,BBo,BRi,BT,BN);
    If HA And HB Then Begin
        DX:=A2GapX(AL,AR,BL,BRi);
        DY:=A2GapY(ABo,AT,BBo,BT);
        A2Add('COURTYARD axis gap | DX='+FloatToStr(DX)+' mil | DY='+FloatToStr(DY)+' mil');
    End Else
        A2Add('COURTYARD axis gap: unavailable');
End;

Procedure A2ExportClearanceRules;
Var It;R;
Begin
    A2Add('');
    A2Add('=== COMPONENT CLEARANCE RULES ===');
    It:=GBoard.BoardIterator_Create;
    If It=Nil Then Begin A2Add('ERROR: rule iterator unavailable'); Exit; End;
    It.AddFilter_ObjectSet(MkSet(eRuleObject));
    It.AddFilter_LayerSet(AllLayers);
    It.AddFilter_Method(eProcessAll);
    R:=It.FirstPCBObject;
    While R<>Nil Do Begin
        If R.RuleKind=eRule_ComponentClearance Then Begin
            A2Add('Rule Name: '+R.Name);
            A2Add('Gap mil: '+FloatToStr(CoordToMils(R.Gap)));
            A2Add('VerticalGap mil: '+FloatToStr(CoordToMils(R.VerticalGap)));
            A2Add('CollisionCheckMode: '+IntToStr(R.CollisionCheckMode));
            A2Add('Scope1: '+R.Scope1Expression);
            A2Add('Scope2: '+R.Scope2Expression);
        End;
        R:=It.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(It);
End;

Procedure AuditT24_QOLED_ROLEDGATE_v2;
Var Q;R;FN;
Begin
    GBoard:=PCBServer.GetCurrentPCBBoard;
    If GBoard=Nil Then Begin
        ShowMessage('ABORT: no PCB active. Nothing changed.'); Exit;
    End;
    If UpperCase(ExtractFileName(GBoard.FileName))<>'DATALOGER_REVA_T24_COURTYARD_PENDING.PCBDOC' Then Begin
        ShowMessage('ABORT: activate DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc. Nothing changed.'); Exit;
    End;

    Q:=A2FindComponent('Q_OLED');
    R:=A2FindComponent('R_OLED_GATE');
    If (Q=Nil) Or (R=Nil) Then Begin
        ShowMessage('ABORT: target components not found. Nothing changed.'); Exit;
    End;

    GReport:=TStringList.Create;
    Try
        A2Add('Datalogger RevA - T24 Q_OLED / R_OLED_GATE focused audit v2');
        A2Add('READ ONLY - selection boundary diagnostic');
        A2Add('PCB: '+GBoard.FileName);
        A2ExportComponent(Q);
        A2ExportComponent(R);
        A2ExportSelectionGap(Q,R);
        A2ExportCourtyardGap(Q,R);
        A2ExportClearanceRules;
        A2Add('');
        A2Add('Nothing changed.');

        FN:=ExtractFilePath(GBoard.FileName)+'T24_QOLED_ROLEDGATE_Audit_v2.txt';
        GReport.SaveToFile(FN);
        ShowMessage('READ-ONLY Q_OLED / R_OLED_GATE AUDIT v2 COMPLETE.'+#13#10+
          'Output: T24_QOLED_ROLEDGATE_Audit_v2.txt'+#13#10+
          'Nothing changed.');
    Finally
        GReport.Free;
    End;
End;
