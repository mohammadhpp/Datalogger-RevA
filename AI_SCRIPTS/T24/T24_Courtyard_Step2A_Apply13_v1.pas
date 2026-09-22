{ T24 Courtyard Step2A Apply13 v1
  Controlled candidate. Adds courtyard rectangles for 13 targets only.
  Geometry = audited PAD/M1 union, with 0.05 mm courtyard track width.
  The old +10 mil expansion was rejected after live collision screening because
  it double-counted the ComponentClearance rule and created false/overconservative hits.
  Deferred: D_ESD1 and D_ESD2 (both border C_SD_HF at the 10 mil limit), J_SD
  (exact body drawing still missing). No silk or copper changes.
  Run Preflight first. Apply only after its PASS. Full DRC required after Apply.
  Never overwrite the original PCB. Do not save until DRC and review are complete.
}

Var
    GBoard;
    GError;
    GReport;
    GAdded;

Function T24WithinTolerance(A,V);
Begin Result:=Abs(A-V)<0.02; End;

Function T24FindComponent(S);
Var It;C;
Begin
    Result:=Nil;
    It:=GBoard.BoardIterator_Create;
    If It=Nil Then Exit;
    It.AddFilter_ObjectSet(MkSet(eComponentObject));
    It.AddFilter_LayerSet(AllLayers); It.AddFilter_Method(eProcessAll);
    C:=It.FirstPCBObject;
    While C<>Nil Do Begin
        If UpperCase(C.SourceDesignator)=UpperCase(S) Then Begin Result:=C; Break; End;
        C:=It.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(It);
End;

Procedure T24Measure(C,Mode; Var N,L,Lo,R,Hi);
Var It;O;BR;UseIt;
Begin
    N:=0; L:=0; Lo:=0; R:=0; Hi:=0;
    It:=C.GroupIterator_Create;
    If It=Nil Then Begin N:=-1; Exit; End;
    It.AddFilter_ObjectSet(MkSet(ePadObject,eTrackObject,eArcObject,eFillObject,eRegionObject,eTextObject));
    It.AddFilter_LayerSet(AllLayers);
    O:=It.FirstPCBObject;
    While O<>Nil Do Begin
        UseIt:=False;
        If Mode=0 Then UseIt:=O.ObjectId=ePadObject;
        If Mode=1 Then UseIt:=(O.Layer=eMechanical1) And (O.ObjectId<>eTextObject);
        If Mode=2 Then UseIt:=((O.Layer=eMechanical2) Or (O.Layer=eMechanical4)) And (O.ObjectId<>eTextObject);
        If UseIt Then Begin
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

Function T24CheckTarget(RefName,ExpectedX,ExpectedY,ExpectedRotation,ExpectedSide,
    PadCount,M1Count,PadLeft,PadBottom,PadRight,PadTop,
    M1Left,M1Bottom,M1Right,M1Top,CyLeft,CyBottom,CyRight,CyTop);
Var C; N; L; Lo; R; Hi;
Begin
    Result:=False;
    C:=T24FindComponent(RefName);
    If C=Nil Then Begin GError:='Missing '+RefName; Exit; End;
    If (C.Layer<>ExpectedSide) Or Not T24WithinTolerance(CoordToMils(C.X),ExpectedX) Or
       Not T24WithinTolerance(CoordToMils(C.Y),ExpectedY) Or
       Not T24WithinTolerance(C.Rotation,ExpectedRotation) Then
    Begin GError:='Placement changed: '+RefName; Exit; End;
    T24Measure(C,2,N,L,Lo,R,Hi);
    If N<>0 Then Begin GError:='Courtyard exists: '+RefName; Exit; End;
    T24Measure(C,0,N,L,Lo,R,Hi);
    If (N<>PadCount) Or Not T24WithinTolerance(L,PadLeft) Or
       Not T24WithinTolerance(Lo,PadBottom) Or Not T24WithinTolerance(R,PadRight) Or
       Not T24WithinTolerance(Hi,PadTop) Then
    Begin GError:='Pad envelope changed: '+RefName; Exit; End;
    T24Measure(C,1,N,L,Lo,R,Hi);
    If (N<>M1Count) Or Not T24WithinTolerance(L,M1Left) Or
       Not T24WithinTolerance(Lo,M1Bottom) Or Not T24WithinTolerance(R,M1Right) Or
       Not T24WithinTolerance(Hi,M1Top) Then
    Begin GError:='M1 envelope changed: '+RefName; Exit; End;
    Result:=True;
End;

Function T24CheckBaseline;
Var It; C; Count; Covered; N; L; Lo; R; Hi;
Begin
    Result:=False; GError:='';
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
        Count:=Count+1; T24Measure(C,2,N,L,Lo,R,Hi);
        If N>0 Then Covered:=Covered+1;
        C:=It.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(It);
    If (Count<>129) Or (Covered<>113) Then
    Begin GError:='Expected 129 components / 113 courtyard-covered; baseline changed'; Exit; End;
    If Not T24CheckTarget('U_RTC',6259.449,4900.0,0.0,eBottomLayer,16,4,6034.055,4712.599,6484.842,5087.401,6107.874,4691.339,6411.024,5108.661,6034.055,4691.339,6484.842,5108.661) Then Exit;
    If Not T24CheckTarget('Q_SD',6797.244,5352.598,270.0,eTopLayer,3,6,6732.283,5297.48,6862.205,5407.717,6751.968,5293.543,6830.709,5411.654,6732.283,5293.543,6862.205,5411.654) Then Exit;
    If Not T24CheckTarget('Q_OLED',5710.0,6665.0,0.0,eTopLayer,3,6,5654.882,6600.039,5765.118,6729.961,5650.945,6619.724,5769.055,6698.465,5650.945,6600.039,5769.055,6729.961) Then Exit;
    If Not T24CheckTarget('J_SWD',6875.0,6020.0,90.0,eTopLayer,5,6,6837.599,5782.599,6912.401,6257.401,6823.032,5768.032,6926.968,6271.968,6823.032,5768.032,6926.968,6271.968) Then Exit;
    If Not T24CheckTarget('J_SHIELD',4310.0,6710.0,90.0,eTopLayer,1,0,4260.787,6660.787,4359.213,6759.213,0,0,0,0,4260.787,6660.787,4359.213,6759.213) Then Exit;
    If Not T24CheckTarget('J_NAV',7091.575,6900.0,180.0,eTopLayer,5,4,6865.197,6870.472,7317.953,6929.528,6794.331,6783.858,7388.819,7016.142,6794.331,6783.858,7388.819,7016.142) Then Exit;
    If Not T24CheckTarget('D_EXT3',6452.598,4515.276,90.0,eTopLayer,6,6,6401.417,4444.409,6503.779,4586.142,6407.323,4456.221,6486.063,4574.331,6401.417,4444.409,6503.779,4586.142) Then Exit;
    If Not T24CheckTarget('D_EXT2',6777.598,4515.276,90.0,eTopLayer,6,6,6726.417,4444.409,6828.779,4586.142,6732.323,4456.221,6811.063,4574.331,6726.417,4444.409,6828.779,4586.142) Then Exit;
    If Not T24CheckTarget('D_EXT1',6617.598,4515.276,90.0,eTopLayer,6,6,6566.417,4444.409,6668.779,4586.142,6572.323,4456.221,6651.063,4574.331,6566.417,4444.409,6668.779,4586.142) Then Exit;
    If Not T24CheckTarget('D_ESD',4645.0,6629.724,270.0,eTopLayer,6,6,4593.819,6558.858,4696.181,6700.591,4611.535,6570.669,4690.276,6688.779,4593.819,6558.858,4696.181,6700.591) Then Exit;
    If Not T24CheckTarget('C_SENSOR_BULK',4925.433,6605.0,0.0,eTopLayer,2,4,4876.221,6578.425,4974.646,6631.575,4884.095,6578.425,4966.772,6631.575,4876.221,6578.425,4974.646,6631.575) Then Exit;
    If Not T24CheckTarget('C_SD_MID',7144.567,5675.0,0.0,eTopLayer,2,4,7095.354,5648.425,7193.779,5701.575,7103.228,5648.425,7185.905,5701.575,7095.354,5648.425,7193.779,5701.575) Then Exit;
    If Not T24CheckTarget('C_OLED_BULK',5725.0,6780.0,0.0,eTopLayer,2,4,5675.787,6753.425,5774.213,6806.575,5683.661,6753.425,5766.339,6806.575,5675.787,6753.425,5774.213,6806.575) Then Exit;
    Result:=True;
End;

Procedure T24WritePreflight;
Begin
    GReport.Add('T24 Step2A Apply13 v1 - BASELINE PREFLIGHT ONLY');
    GReport.Add('PCB: '+GBoard.FileName);
    GReport.Add('13 candidate rectangles / 52 component-owned tracks.');
    GReport.Add('Geometry: audited PAD/M1 union; 0.05 mm track width.');
    GReport.Add('Deferred: D_ESD1, D_ESD2, J_SD. Silk unchanged.');
    GReport.Add('Static/live collision screen must be followed by full DRC after Apply.');
    GReport.SaveToFile(ExtractFilePath(GBoard.FileName)+'T24_Courtyard_Step2A_Apply13_Preflight_v1.txt');
End;

Procedure T24AddLine(C,Lay,X1,Y1,X2,Y2);
Var T;
Begin
    T:=PCBServer.PCBObjectFactory(eTrackObject,eNoDimension,eCreate_Default);
    If T=Nil Then Raise Exception.Create('Track factory failed');
    T.Layer:=Lay; T.Width:=MilsToCoord(1.968504);
    T.X1:=MilsToCoord(X1); T.Y1:=MilsToCoord(Y1);
    T.X2:=MilsToCoord(X2); T.Y2:=MilsToCoord(Y2);
    C.AddPCBObject(T);
    PCBServer.SendMessageToRobots(C.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,T.I_ObjectAddress);
    GAdded:=GAdded+1;
End;

Procedure T24ApplyOne(RefName,SideName,L,B,R,T);
Var C; Lay;
Begin
    C:=T24FindComponent(RefName);
    If C=Nil Then Raise Exception.Create('Missing '+RefName);
    Lay:=eMechanical2;
    If SideName='BOTTOM' Then Lay:=eMechanical4;
    PCBServer.SendMessageToRobots(C.I_ObjectAddress,c_Broadcast,PCBM_BeginModify,c_NoEventData);
    Try
        T24AddLine(C,Lay,L,B,R,B);
        T24AddLine(C,Lay,R,B,R,T);
        T24AddLine(C,Lay,R,T,L,T);
        T24AddLine(C,Lay,L,T,L,B);
    Finally
        PCBServer.SendMessageToRobots(C.I_ObjectAddress,c_Broadcast,PCBM_EndModify,c_NoEventData);
    End;
End;

Function T24PostcheckOne(RefName,SideName,L,B,R,T);
Var C; N; OL; OB; OR; OT;
Begin
    Result:=False; C:=T24FindComponent(RefName);
    If C=Nil Then Exit;
    T24Measure(C,2,N,OL,OB,OR,OT);
    Result:=(N=4) And T24WithinTolerance(OL,L-0.984252) And
        T24WithinTolerance(OB,B-0.984252) And T24WithinTolerance(OR,R+0.984252) And
        T24WithinTolerance(OT,T+0.984252);
End;

Procedure PreflightT24_Courtyard_Step2A_Apply13_v1;
Begin
    GReport:=TStringList.Create;
    Try
        If Not T24CheckBaseline Then Begin ShowMessage('ABORT: '+GError+'. Nothing changed.'); Exit; End;
        T24WritePreflight;
        ShowMessage('PREFLIGHT PASS ONLY: 13 targets / 52 tracks verified.'+#13#10+
          'D_ESD1, D_ESD2 and J_SD are deferred. Nothing changed.'+#13#10+
          'Output: T24_Courtyard_Step2A_Apply13_Preflight_v1.txt');
    Finally GReport.Free; End;
End;

Procedure ApplyT24_Courtyard_Step2A_Apply13_v1;
Var Good;
Begin
    If Not T24CheckBaseline Then Begin ShowMessage('ABORT: '+GError+'. Nothing changed.'); Exit; End;
    GAdded:=0; Good:=True;
    PCBServer.PreProcess;
    Try
        T24ApplyOne('U_RTC','BOTTOM',6034.055,4691.339,6484.842,5108.661);
        T24ApplyOne('Q_SD','TOP',6732.283,5293.543,6862.205,5411.654);
        T24ApplyOne('Q_OLED','TOP',5650.945,6600.039,5769.055,6729.961);
        T24ApplyOne('J_SWD','TOP',6823.032,5768.032,6926.968,6271.968);
        T24ApplyOne('J_SHIELD','TOP',4260.787,6660.787,4359.213,6759.213);
        T24ApplyOne('J_NAV','TOP',6794.331,6783.858,7388.819,7016.142);
        T24ApplyOne('D_EXT3','TOP',6401.417,4444.409,6503.779,4586.142);
        T24ApplyOne('D_EXT2','TOP',6726.417,4444.409,6828.779,4586.142);
        T24ApplyOne('D_EXT1','TOP',6566.417,4444.409,6668.779,4586.142);
        T24ApplyOne('D_ESD','TOP',4593.819,6558.858,4696.181,6700.591);
        T24ApplyOne('C_SENSOR_BULK','TOP',4876.221,6578.425,4974.646,6631.575);
        T24ApplyOne('C_SD_MID','TOP',7095.354,5648.425,7193.779,5701.575);
        T24ApplyOne('C_OLED_BULK','TOP',5675.787,6753.425,5774.213,6806.575);
    Finally PCBServer.PostProcess; End;
    GBoard.ViewManager_FullUpdate;
    If Not T24PostcheckOne('U_RTC','BOTTOM',6034.055,4691.339,6484.842,5108.661) Then Good:=False;
    If Not T24PostcheckOne('Q_SD','TOP',6732.283,5293.543,6862.205,5411.654) Then Good:=False;
    If Not T24PostcheckOne('Q_OLED','TOP',5650.945,6600.039,5769.055,6729.961) Then Good:=False;
    If Not T24PostcheckOne('J_SWD','TOP',6823.032,5768.032,6926.968,6271.968) Then Good:=False;
    If Not T24PostcheckOne('J_SHIELD','TOP',4260.787,6660.787,4359.213,6759.213) Then Good:=False;
    If Not T24PostcheckOne('J_NAV','TOP',6794.331,6783.858,7388.819,7016.142) Then Good:=False;
    If Not T24PostcheckOne('D_EXT3','TOP',6401.417,4444.409,6503.779,4586.142) Then Good:=False;
    If Not T24PostcheckOne('D_EXT2','TOP',6726.417,4444.409,6828.779,4586.142) Then Good:=False;
    If Not T24PostcheckOne('D_EXT1','TOP',6566.417,4444.409,6668.779,4586.142) Then Good:=False;
    If Not T24PostcheckOne('D_ESD','TOP',4593.819,6558.858,4696.181,6700.591) Then Good:=False;
    If Not T24PostcheckOne('C_SENSOR_BULK','TOP',4876.221,6578.425,4974.646,6631.575) Then Good:=False;
    If Not T24PostcheckOne('C_SD_MID','TOP',7095.354,5648.425,7193.779,5701.575) Then Good:=False;
    If Not T24PostcheckOne('C_OLED_BULK','TOP',5675.787,6753.425,5774.213,6806.575) Then Good:=False;
    If (GAdded<>52) Or Not Good Then Begin
        ShowMessage('POSTCHECK FAILED. DO NOT SAVE. Keep recovery copy and report.'); Exit;
    End;
    ShowMessage('APPLY COMPLETE: 13 courtyards / 52 tracks.'+#13#10+
      '126 of 129 components now have courtyard data.'+#13#10+
      'Deferred: D_ESD1, D_ESD2 and J_SD.'+#13#10+
      'Run full Batch DRC. Do not save over the original PCB.');
End;
