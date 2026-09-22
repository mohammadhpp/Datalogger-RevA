{ T24 Courtyard Step2A Collision Preflight v1
  READ ONLY. No PCB mutation. Run on DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc.
  Candidate bounds are audited PAD/M1 union + 10 mil each side.
  This is an AABB screening report, not a final DRC or fabrication approval.
  A target-to-target or target-to-existing-courtyard hit under 10 mil must be
  dispositioned before any Apply. Do not shrink a courtyard or relax the rule
  merely to suppress a violation.
}

Var
    GBoard;
    GReport;
    GError;
    GPotentialCount;

Function T24FindComponent(RefName);
Var It; C;
Begin
    Result:=Nil;
    It:=GBoard.BoardIterator_Create;
    If It=Nil Then Exit;
    It.AddFilter_ObjectSet(MkSet(eComponentObject));
    It.AddFilter_LayerSet(AllLayers); It.AddFilter_Method(eProcessAll);
    C:=It.FirstPCBObject;
    While C<>Nil Do Begin
        If UpperCase(C.SourceDesignator)=UpperCase(RefName) Then Begin Result:=C; Break; End;
        C:=It.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(It);
End;

Procedure T24MeasureCourtyard(C; Var N,L,Lo,R,Hi);
Var It; O; BR;
Begin
    N:=0; L:=0; Lo:=0; R:=0; Hi:=0;
    It:=C.GroupIterator_Create;
    If It=Nil Then Begin N:=-1; Exit; End;
    It.AddFilter_ObjectSet(MkSet(ePadObject,eTrackObject,eArcObject,eFillObject,eRegionObject,eTextObject));
    It.AddFilter_LayerSet(AllLayers);
    O:=It.FirstPCBObject;
    While O<>Nil Do Begin
        If ((O.Layer=eMechanical2) Or (O.Layer=eMechanical4)) And
           (O.ObjectId<>eTextObject) Then Begin
            BR:=O.BoundingRectangle;
            If N=0 Then Begin
                L:=CoordToMils(BR.Left); Lo:=CoordToMils(BR.Bottom);
                R:=CoordToMils(BR.Right); Hi:=CoordToMils(BR.Top);
            End Else Begin
                If CoordToMils(BR.Left)<L Then L:=CoordToMils(BR.Left);
                If CoordToMils(BR.Bottom)<Lo Then Lo:=CoordToMils(BR.Bottom);
                If CoordToMils(BR.Right)>R Then R:=CoordToMils(BR.Right);
                If CoordToMils(BR.Top)>Hi Then Hi:=CoordToMils(BR.Top);
            End;
            N:=N+1;
        End;
        O:=It.NextPCBObject;
    End;
    C.GroupIterator_Destroy(It);
End;

Function T24GapX(AL,AR,BL,BR);
Begin
    If (AR<BL) Then Result:=BL-AR
    Else If (BR<AL) Then Result:=AL-BR
    Else Result:=0;
End;

Function T24GapY(AB,AT,BB,BT);
Begin
    If (AT<BB) Then Result:=BB-AT
    Else If (BT<AB) Then Result:=AB-BT
    Else Result:=0;
End;

Procedure T24ReportPair(AName,BName,AL,AB,AR,AT,BL,BB,BR,BT,SourceName);
Var DX; DY;
Begin
    DX:=T24GapX(AL,AR,BL,BR); DY:=T24GapY(AB,AT,BB,BT);
    If (DX<10) And (DY<10) Then Begin
        GPotentialCount:=GPotentialCount+1;
        GReport.Add('POTENTIAL <10 mil | '+AName+' vs '+BName+
            ' | DX='+FloatToStr(DX)+' | DY='+FloatToStr(DY)+
            ' | source='+SourceName);
    End;
End;

Procedure T24AuditTarget(RefName,SideName,AL,AB,AR,AT);
Var C; It; Other; N; L; Lo; R; Hi; TargetLayer; TargetComponentLayer;
Begin
    C:=T24FindComponent(RefName);
    If C=Nil Then Begin GError:='Missing target '+RefName; Exit; End;
    TargetLayer:=eMechanical2;
    TargetComponentLayer:=eTopLayer;
    If SideName='BOTTOM' Then Begin
        TargetLayer:=eMechanical4;
        TargetComponentLayer:=eBottomLayer;
    End;
    T24MeasureCourtyard(C,N,L,Lo,R,Hi);
    If N<>0 Then Begin GError:='Target already has courtyard: '+RefName; Exit; End;
    It:=GBoard.BoardIterator_Create;
    If It=Nil Then Begin GError:='Board iterator unavailable'; Exit; End;
    It.AddFilter_ObjectSet(MkSet(eComponentObject));
    It.AddFilter_LayerSet(AllLayers); It.AddFilter_Method(eProcessAll);
    Other:=It.FirstPCBObject;
    While Other<>Nil Do Begin
        If UpperCase(Other.SourceDesignator)<>UpperCase(RefName) Then Begin
            T24MeasureCourtyard(Other,N,L,Lo,R,Hi);
            If (N>0) And (Other.Layer=TargetComponentLayer) Then
                T24ReportPair(RefName,Other.SourceDesignator,AL,AB,AR,AT,L,Lo,R,Hi,'existing courtyard');
        End;
        Other:=It.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(It);
End;

Procedure T24CheckBaseline;
Var It; C; Count; Covered; N; L; Lo; R; Hi;
Begin
    GError:='';
    GBoard:=PCBServer.GetCurrentPCBBoard;
    If GBoard=Nil Then Begin GError:='No PCB active'; Exit; End;
    If UpperCase(ExtractFileName(GBoard.FileName))<>'DATALOGER_REVA_T24_COURTYARD_PENDING.PCBDOC' Then
    Begin GError:='Activate the PENDING copy'; Exit; End;
    If Not GBoard.MechanicalPairs.PairDefined(eMechanical2,eMechanical4) Then
    Begin GError:='M2/M4 pair missing'; Exit; End;
    Count:=0; Covered:=0;
    It:=GBoard.BoardIterator_Create;
    If It=Nil Then Begin GError:='Board iterator unavailable'; Exit; End;
    It.AddFilter_ObjectSet(MkSet(eComponentObject));
    It.AddFilter_LayerSet(AllLayers); It.AddFilter_Method(eProcessAll);
    C:=It.FirstPCBObject;
    While C<>Nil Do Begin
        Count:=Count+1; T24MeasureCourtyard(C,N,L,Lo,R,Hi);
        If N>0 Then Covered:=Covered+1;
        C:=It.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(It);
    If (Count<>129) Or (Covered<>113) Then
        GError:='Expected 129 components / 113 covered; baseline changed';
End;

Procedure PreflightT24_Courtyard_Step2A_Collision_v1;
Begin
    GReport:=TStringList.Create;
    Try
        T24CheckBaseline;
        If GError<>'' Then Begin ShowMessage('ABORT: '+GError+'. Nothing changed.'); Exit; End;
        GPotentialCount:=0;
        GReport.Add('T24 Step2A Collision Preflight v1 - READ ONLY');
        GReport.Add('PCB: '+GBoard.FileName);
        GReport.Add('Threshold: target-to-target or target-to-existing AABB gap < 10 mil');
        GReport.Add('Candidate source: PAD/M1 union + 10 mil per side');
        GReport.Add('');
        T24ReportPair('Q_OLED','C_OLED_BULK',5640.945,6590.039,5779.055,6739.961,5665.787,6743.425,5784.213,6816.575,'candidate/candidate');
        T24ReportPair('D_ESD2','C_SD_MID',7168.858,5523.819,7330.591,5646.181,7085.354,5638.425,7203.779,5711.575,'candidate/candidate');
        T24AuditTarget('U_RTC','BOTTOM',6024.055,4681.339,6494.842,5118.661);
        T24AuditTarget('Q_SD','TOP',6722.283,5283.543,6872.205,5421.654);
        T24AuditTarget('Q_OLED','TOP',5640.945,6590.039,5779.055,6739.961);
        T24AuditTarget('J_SWD','TOP',6813.032,5758.032,6936.968,6281.968);
        T24AuditTarget('J_SHIELD','TOP',4250.787,6650.787,4369.213,6769.213);
        T24AuditTarget('J_NAV','TOP',6784.331,6773.858,7398.819,7026.142);
        T24AuditTarget('D_EXT3','TOP',6391.417,4434.409,6513.779,4596.142);
        T24AuditTarget('D_EXT2','TOP',6716.417,4434.409,6838.779,4596.142);
        T24AuditTarget('D_EXT1','TOP',6556.417,4434.409,6678.779,4596.142);
        T24AuditTarget('D_ESD','TOP',4583.819,6548.858,4706.181,6710.591);
        T24AuditTarget('D_ESD2','TOP',7168.858,5523.819,7330.591,5646.181);
        T24AuditTarget('D_ESD1','TOP',7163.858,5751.417,7325.591,5873.779);
        T24AuditTarget('C_SENSOR_BULK','TOP',4866.221,6568.425,4984.646,6641.575);
        T24AuditTarget('C_SD_MID','TOP',7085.354,5638.425,7203.779,5711.575);
        T24AuditTarget('C_OLED_BULK','TOP',5665.787,6743.425,5784.213,6816.575);
        If GError<>'' Then Begin ShowMessage('ABORT: '+GError+'. Nothing changed.'); Exit; End;
        GReport.Add('');
        GReport.Add('Potential hits found: '+IntToStr(GPotentialCount));
        GReport.Add('Any hit requires physical/footprint disposition before Apply.');
        GReport.Add('This report does not change geometry or rules and is not a DRC PASS.');
        GReport.SaveToFile(ExtractFilePath(GBoard.FileName)+'T24_Courtyard_Step2A_Collision_Preflight_v1.txt');
        ShowMessage('Collision preflight complete. Potential hits: '+IntToStr(GPotentialCount)+#13#10+
          'Send T24_Courtyard_Step2A_Collision_Preflight_v1.txt. Nothing changed.');
    Finally
        GReport.Free;
    End;
End;
