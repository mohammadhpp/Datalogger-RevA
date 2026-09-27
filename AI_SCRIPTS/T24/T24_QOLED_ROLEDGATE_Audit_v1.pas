{ Datalogger RevA - T24
  Q_OLED / R_OLED_GATE focused clearance audit v1
  READ ONLY. No PCB mutation, no rule edit, no DRC run, no save.
  Run on DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc after Apply13 v2 + full DRC.
  Output: T24_QOLED_ROLEDGATE_Audit_v1.txt
}

Var
    GBoard;
    GReport;

Procedure T24QRAdd(S);
Begin
    GReport.Add(S);
End;

Function T24QRFindComponent(RefName);
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

Procedure T24QRReset(Var HasAny; Var L; Var B; Var R; Var T; Var N);
Begin
    HasAny:=False;
    L:=0; B:=0; R:=0; T:=0; N:=0;
End;

Procedure T24QRExpand(BR; Var HasAny; Var L; Var B; Var R; Var T; Var N);
Var X1; Y1; X2; Y2;
Begin
    X1:=CoordToMils(BR.Left);
    Y1:=CoordToMils(BR.Bottom);
    X2:=CoordToMils(BR.Right);
    Y2:=CoordToMils(BR.Top);

    If Not HasAny Then Begin
        L:=X1; B:=Y1; R:=X2; T:=Y2;
        HasAny:=True;
    End Else Begin
        If X1<L Then L:=X1;
        If Y1<B Then B:=Y1;
        If X2>R Then R:=X2;
        If Y2>T Then T:=Y2;
    End;
    N:=N+1;
End;

Procedure T24QRMeasure(C,Mode; Var HasAny; Var L; Var B; Var R; Var T; Var N);
Var It; O; BR; UseIt;
Begin
    T24QRReset(HasAny,L,B,R,T,N);
    It:=C.GroupIterator_Create;
    If It=Nil Then Exit;
    It.AddFilter_ObjectSet(MkSet(ePadObject,eTrackObject,eArcObject,eFillObject,eRegionObject,eTextObject));
    It.AddFilter_LayerSet(AllLayers);
    O:=It.FirstPCBObject;
    While O<>Nil Do Begin
        UseIt:=False;
        If Mode=1 Then UseIt:=(O.Layer=eMechanical1) And (O.ObjectId<>eTextObject);
        If Mode=2 Then UseIt:=((O.Layer=eMechanical2) Or (O.Layer=eMechanical4)) And (O.ObjectId<>eTextObject);
        If Mode=3 Then UseIt:=(O.Layer=eTopOverlay) And (O.ObjectId<>eTextObject);
        If UseIt Then Begin
            BR:=O.BoundingRectangle;
            T24QRExpand(BR,HasAny,L,B,R,T,N);
        End;
        O:=It.NextPCBObject;
    End;
    C.GroupIterator_Destroy(It);
End;

Procedure T24QRBoundsLine(LabelText,HasAny,L,B,R,T,N);
Begin
    If Not HasAny Then Begin
        T24QRAdd(LabelText+': NONE');
        Exit;
    End;
    T24QRAdd(LabelText+
        ' | Count='+IntToStr(N)+
        ' | L/B/R/T mil='+FloatToStr(L)+' / '+FloatToStr(B)+' / '+
        FloatToStr(R)+' / '+FloatToStr(T)+
        ' | W/H mil='+FloatToStr(R-L)+' / '+FloatToStr(T-B));
End;

Procedure T24QRExportPrimitives(C);
Var It; O; BR;
Begin
    It:=C.GroupIterator_Create;
    If It=Nil Then Begin
        T24QRAdd('ERROR: primitive iterator unavailable for '+C.SourceDesignator);
        Exit;
    End;
    It.AddFilter_ObjectSet(MkSet(eTrackObject,eArcObject,eFillObject,eRegionObject,eTextObject));
    It.AddFilter_LayerSet(AllLayers);
    O:=It.FirstPCBObject;
    While O<>Nil Do Begin
        If (O.Layer=eTopOverlay) Or (O.Layer=eMechanical2) Or (O.Layer=eMechanical4) Then Begin
            BR:=O.BoundingRectangle;
            T24QRAdd('Primitive | Ref='+C.SourceDesignator+
                ' | ObjectId='+IntToStr(O.ObjectId)+
                ' | Layer='+IntToStr(O.Layer)+
                ' | L/B/R/T mil='+FloatToStr(CoordToMils(BR.Left))+' / '+
                FloatToStr(CoordToMils(BR.Bottom))+' / '+
                FloatToStr(CoordToMils(BR.Right))+' / '+
                FloatToStr(CoordToMils(BR.Top)));
        End;
        O:=It.NextPCBObject;
    End;
    C.GroupIterator_Destroy(It);
End;

Procedure T24QRExportComponent(C);
Var BR; H1; L1; B1; R1; T1; N1;
    H2; L2; B2; R2; T2; N2;
    H3; L3; B3; R3; T3; N3;
Begin
    BR:=C.BoundingRectangle;
    T24QRAdd('');
    T24QRAdd('============================================================');
    T24QRAdd('RefDes: '+C.SourceDesignator);
    T24QRAdd('X/Y mil: '+FloatToStr(CoordToMils(C.X))+' / '+FloatToStr(CoordToMils(C.Y)));
    T24QRAdd('Layer ID: '+IntToStr(C.Layer));
    T24QRAdd('Rotation deg: '+FloatToStr(C.Rotation));
    T24QRAdd('Component BBox L/B/R/T mil: '+
        FloatToStr(CoordToMils(BR.Left))+' / '+FloatToStr(CoordToMils(BR.Bottom))+' / '+
        FloatToStr(CoordToMils(BR.Right))+' / '+FloatToStr(CoordToMils(BR.Top)));

    T24QRMeasure(C,1,H1,L1,B1,R1,T1,N1);
    T24QRMeasure(C,2,H2,L2,B2,R2,T2,N2);
    T24QRMeasure(C,3,H3,L3,B3,R3,T3,N3);
    T24QRBoundsLine('MECH1',H1,L1,B1,R1,T1,N1);
    T24QRBoundsLine('COURTYARD M2/M4',H2,L2,B2,R2,T2,N2);
    T24QRBoundsLine('TOP OVERLAY (text excluded)',H3,L3,B3,R3,T3,N3);
    T24QRExportPrimitives(C);
End;

Function T24QRGapX(AL,AR,BL,BR);
Begin
    If AR<BL Then Result:=BL-AR
    Else If BR<AL Then Result:=AL-BR
    Else Result:=0;
End;

Function T24QRGapY(AB,AT,BB,BT);
Begin
    If AT<BB Then Result:=BB-AT
    Else If BT<AB Then Result:=AB-BT
    Else Result:=0;
End;

Procedure T24QRExportGap(A,B);
Var ABR; BBR;
    HA; AL; ABo; AR; AT; AN;
    HB; BL; BBo; BRi; BT; BN;
    DX; DY;
Begin
    ABR:=A.BoundingRectangle;
    BBR:=B.BoundingRectangle;
    DX:=T24QRGapX(CoordToMils(ABR.Left),CoordToMils(ABR.Right),
                  CoordToMils(BBR.Left),CoordToMils(BBR.Right));
    DY:=T24QRGapY(CoordToMils(ABR.Bottom),CoordToMils(ABR.Top),
                  CoordToMils(BBR.Bottom),CoordToMils(BBR.Top));
    T24QRAdd('');
    T24QRAdd('COMPONENT BBOX axis gap | DX='+FloatToStr(DX)+' mil | DY='+FloatToStr(DY)+' mil');

    T24QRMeasure(A,2,HA,AL,ABo,AR,AT,AN);
    T24QRMeasure(B,2,HB,BL,BBo,BRi,BT,BN);
    If HA And HB Then Begin
        DX:=T24QRGapX(AL,AR,BL,BRi);
        DY:=T24QRGapY(ABo,AT,BBo,BT);
        T24QRAdd('COURTYARD axis gap | DX='+FloatToStr(DX)+' mil | DY='+FloatToStr(DY)+' mil');
        If (DX>=10) Or (DY>=10) Then
            T24QRAdd('COURTYARD SCREEN: >=10 mil separation exists on at least one axis.')
        Else
            T24QRAdd('COURTYARD SCREEN: <10 mil on both axes; requires geometry review.');
    End Else
        T24QRAdd('COURTYARD SCREEN: missing courtyard geometry on one/both components.');
End;

Procedure T24QRExportViolation;
Var It; V; A; B; SA; SB;
Begin
    It:=GBoard.BoardIterator_Create;
    If It=Nil Then Begin
        T24QRAdd('ERROR: violation iterator unavailable.');
        Exit;
    End;
    It.AddFilter_ObjectSet(MkSet(eViolationObject));
    It.AddFilter_LayerSet(AllLayers);
    It.AddFilter_Method(eProcessAll);
    V:=It.FirstPCBObject;
    While V<>Nil Do Begin
        If (V.Rule<>Nil) And (V.Rule.RuleKind=eRule_ComponentClearance) Then Begin
            A:=V.Primitive1; B:=V.Primitive2;
            SA:=''; SB:='';
            If (A<>Nil) And (A.ObjectId=eComponentObject) Then SA:=UpperCase(A.SourceDesignator);
            If (B<>Nil) And (B.ObjectId=eComponentObject) Then SB:=UpperCase(B.SourceDesignator);
            If ((SA='Q_OLED') And (SB='R_OLED_GATE')) Or
               ((SA='R_OLED_GATE') And (SB='Q_OLED')) Then Begin
                T24QRAdd('');
                T24QRAdd('CURRENT DRC VIOLATION FOUND');
                T24QRAdd('Violation Name: '+V.Name);
                T24QRAdd('Rule Name: '+V.Rule.Name);
                T24QRAdd('Pair: '+SA+' / '+SB);
            End;
        End;
        V:=It.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(It);
End;

Procedure AuditT24_QOLED_ROLEDGATE_v1;
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

    Q:=T24QRFindComponent('Q_OLED');
    R:=T24QRFindComponent('R_OLED_GATE');
    If (Q=Nil) Or (R=Nil) Then Begin
        ShowMessage('ABORT: Q_OLED or R_OLED_GATE not found. Nothing changed.');
        Exit;
    End;

    GReport:=TStringList.Create;
    Try
        T24QRAdd('Datalogger RevA - T24 Q_OLED / R_OLED_GATE focused audit v1');
        T24QRAdd('READ ONLY - post Apply13 v2');
        T24QRAdd('PCB: '+GBoard.FileName);
        T24QRExportViolation;
        T24QRExportComponent(Q);
        T24QRExportComponent(R);
        T24QRExportGap(Q,R);
        T24QRAdd('');
        T24QRAdd('Nothing changed.');

        FN:=ExtractFilePath(GBoard.FileName)+'T24_QOLED_ROLEDGATE_Audit_v1.txt';
        GReport.SaveToFile(FN);
        ShowMessage('READ-ONLY Q_OLED / R_OLED_GATE AUDIT COMPLETE.'+#13#10+
            'Output: T24_QOLED_ROLEDGATE_Audit_v1.txt'+#13#10+
            'Nothing changed.');
    Finally
        GReport.Free;
    End;
End;
