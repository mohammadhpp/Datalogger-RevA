{ T24 Step2A Preflight v2. READ ONLY. Compatibility rewrite after v1 parser error.
  No arrays, no Apply entry point. Geometry and baseline unchanged.
  BASELINE PASS is not clearance approval. J_SD and silk remain pending. }

Var
    GBoard;
    GError;
    GReport;

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
        If Mode=2 Then UseIt:=(O.Layer=eMechanical2) Or (O.Layer=eMechanical4);
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
    GReport.Add(RefName+' L/B/R/T mil: '+FloatToStr(CyLeft)+' / '+FloatToStr(CyBottom)+' / '+FloatToStr(CyRight)+' / '+FloatToStr(CyTop));
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
    Begin GError:='Expected 129 components / 113 courtyard-covered; already applied or baseline changed'; Exit; End;
    If Not T24CheckTarget('U_RTC',6259.449,4900.0,0.0,eBottomLayer,16,4,6034.055,4712.599,6484.842,5087.401,6107.874,4691.339,6411.024,5108.661,6024.055,4681.339,6494.842,5118.661) Then Exit;
    If Not T24CheckTarget('Q_SD',6797.244,5352.598,270.0,eTopLayer,3,6,6732.283,5297.48,6862.205,5407.717,6751.968,5293.543,6830.709,5411.654,6722.283,5283.543,6872.205,5421.654) Then Exit;
    If Not T24CheckTarget('Q_OLED',5710.0,6665.0,0.0,eTopLayer,3,6,5654.882,6600.039,5765.118,6729.961,5650.945,6619.724,5769.055,6698.465,5640.945,6590.039,5779.055,6739.961) Then Exit;
    If Not T24CheckTarget('J_SWD',6875.0,6020.0,90.0,eTopLayer,5,6,6837.599,5782.599,6912.401,6257.401,6823.032,5768.032,6926.968,6271.968,6813.032,5758.032,6936.968,6281.968) Then Exit;
    If Not T24CheckTarget('J_SHIELD',4310.0,6710.0,90.0,eTopLayer,1,0,4260.787,6660.787,4359.213,6759.213,0,0,0,0,4250.787,6650.787,4369.213,6769.213) Then Exit;
    If Not T24CheckTarget('J_NAV',7091.575,6900.0,180.0,eTopLayer,5,4,6865.197,6870.472,7317.953,6929.528,6794.331,6783.858,7388.819,7016.142,6784.331,6773.858,7398.819,7026.142) Then Exit;
    If Not T24CheckTarget('D_EXT3',6452.598,4515.276,90.0,eTopLayer,6,6,6401.417,4444.409,6503.779,4586.142,6407.323,4456.221,6486.063,4574.331,6391.417,4434.409,6513.779,4596.142) Then Exit;
    If Not T24CheckTarget('D_EXT2',6777.598,4515.276,90.0,eTopLayer,6,6,6726.417,4444.409,6828.779,4586.142,6732.323,4456.221,6811.063,4574.331,6716.417,4434.409,6838.779,4596.142) Then Exit;
    If Not T24CheckTarget('D_EXT1',6617.598,4515.276,90.0,eTopLayer,6,6,6566.417,4444.409,6668.779,4586.142,6572.323,4456.221,6651.063,4574.331,6556.417,4434.409,6678.779,4596.142) Then Exit;
    If Not T24CheckTarget('D_ESD',4645.0,6629.724,270.0,eTopLayer,6,6,4593.819,6558.858,4696.181,6700.591,4611.535,6570.669,4690.276,6688.779,4583.819,6548.858,4706.181,6710.591) Then Exit;
    If Not T24CheckTarget('D_ESD2',7249.724,5585.0,0.0,eTopLayer,6,6,7178.858,5533.819,7320.591,5636.181,7190.669,5551.535,7308.779,5630.276,7168.858,5523.819,7330.591,5646.181) Then Exit;
    If Not T24CheckTarget('D_ESD1',7244.724,5812.598,0.0,eTopLayer,6,6,7173.858,5761.417,7315.591,5863.779,7185.669,5779.134,7303.779,5857.874,7163.858,5751.417,7325.591,5873.779) Then Exit;
    If Not T24CheckTarget('C_SENSOR_BULK',4925.433,6605.0,0.0,eTopLayer,2,4,4876.221,6578.425,4974.646,6631.575,4884.095,6578.425,4966.772,6631.575,4866.221,6568.425,4984.646,6641.575) Then Exit;
    If Not T24CheckTarget('C_SD_MID',7144.567,5675.0,0.0,eTopLayer,2,4,7095.354,5648.425,7193.779,5701.575,7103.228,5648.425,7185.905,5701.575,7085.354,5638.425,7203.779,5711.575) Then Exit;
    If Not T24CheckTarget('C_OLED_BULK',5725.0,6780.0,0.0,eTopLayer,2,4,5675.787,6753.425,5774.213,6806.575,5683.661,6753.425,5766.339,6806.575,5665.787,6743.425,5784.213,6816.575) Then Exit;
    Result:=True;
End;

Procedure PreflightT24_Courtyard_Step2A_v2;
Var ReportPath; Passed;
Begin
    GReport:=TStringList.Create;
    Try
        GReport.Add('T24 Step2A Preflight v2 - READ ONLY');
        Passed:=T24CheckBaseline;
        If Not Passed Then Begin
            ShowMessage('ABORT: '+GError+'. Nothing changed.');
            Exit;
        End;
        GReport.Add('BASELINE PASS ONLY - not a clearance or fabrication PASS');
        GReport.Add('PCB: '+GBoard.FileName);
        GReport.Add('129 components / 113 courtyard-covered / 15 targets verified.');
        GReport.Add('Candidate: 15 rectangles / 60 tracks; pad/M1 union + 10 mil per side.');
        GReport.Add('J_SD unresolved. J_SHIELD solder land only; wire envelope needs review.');
        GReport.Add('KNOWN REVIEW: C_SD_MID / D_ESD2 candidate rectangles overlap.');
        GReport.Add('KNOWN REVIEW: C_OLED_BULK / Q_OLED gap 3.464 mil, below 10 mil.');
        GReport.Add('Existing neighbours also need review. No collision PASS claimed.');
        GReport.Add('Courtyard layer type requires UI confirmation. Silk remains pending.');
        ReportPath:=ExtractFilePath(GBoard.FileName)+'T24_Courtyard_Step2A_Preflight_v2.txt';
        GReport.SaveToFile(ReportPath);
        ShowMessage('BASELINE PASS ONLY. Nothing changed.'+#13#10+
            'Send T24_Courtyard_Step2A_Preflight_v2.txt. Do not run v1 Apply.');
    Finally
        GReport.Free;
    End;
End;
