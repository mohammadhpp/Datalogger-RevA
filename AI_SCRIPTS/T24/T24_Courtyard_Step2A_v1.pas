{ T24 Courtyard Step2A v1 - 15 components, 60 component-owned tracks.
  Candidate only, NOT fabrication approval. J_SD remains unresolved.
  Bounds = audited pad/M1 union + 10 mil per side (engineering allowance).
  J_SHIELD bounds cover solder land only; wire strain relief remains a review item.
  M1 includes line thickness, so bounds are conservative. No silk is changed.
  Run Preflight first. Apply repeats guards. Full DRC required after Apply.
  Never overwrite the original PCB until all remaining items are dispositioned.
}
Var B; Err; Added; Log;
    Comps: Array[0..14] Of Variant;
    Names: Array[0..14] Of Variant;
    XS: Array[0..14] Of Variant;
    YS: Array[0..14] Of Variant;
    RS: Array[0..14] Of Variant;
    Sides: Array[0..14] Of Variant;
    PN: Array[0..14] Of Variant;
    MN: Array[0..14] Of Variant;
    PL: Array[0..14] Of Variant;
    PB: Array[0..14] Of Variant;
    PR: Array[0..14] Of Variant;
    PT: Array[0..14] Of Variant;
    ML: Array[0..14] Of Variant;
    MB: Array[0..14] Of Variant;
    MR: Array[0..14] Of Variant;
    MT: Array[0..14] Of Variant;
    CL: Array[0..14] Of Variant;
    CB: Array[0..14] Of Variant;
    CR: Array[0..14] Of Variant;
    CT: Array[0..14] Of Variant;

Procedure Init;
Begin
    Names[0]:='U_RTC'; XS[0]:=6259.449; YS[0]:=4900.0; RS[0]:=0.0; Sides[0]:=eBottomLayer; PN[0]:=16; MN[0]:=4; PL[0]:=6034.055; PB[0]:=4712.599; PR[0]:=6484.842; PT[0]:=5087.401; ML[0]:=6107.874; MB[0]:=4691.339; MR[0]:=6411.024; MT[0]:=5108.661; CL[0]:=6024.055; CB[0]:=4681.339; CR[0]:=6494.842; CT[0]:=5118.661;
    Names[1]:='Q_SD'; XS[1]:=6797.244; YS[1]:=5352.598; RS[1]:=270.0; Sides[1]:=eTopLayer; PN[1]:=3; MN[1]:=6; PL[1]:=6732.283; PB[1]:=5297.48; PR[1]:=6862.205; PT[1]:=5407.717; ML[1]:=6751.968; MB[1]:=5293.543; MR[1]:=6830.709; MT[1]:=5411.654; CL[1]:=6722.283; CB[1]:=5283.543; CR[1]:=6872.205; CT[1]:=5421.654;
    Names[2]:='Q_OLED'; XS[2]:=5710.0; YS[2]:=6665.0; RS[2]:=0.0; Sides[2]:=eTopLayer; PN[2]:=3; MN[2]:=6; PL[2]:=5654.882; PB[2]:=6600.039; PR[2]:=5765.118; PT[2]:=6729.961; ML[2]:=5650.945; MB[2]:=6619.724; MR[2]:=5769.055; MT[2]:=6698.465; CL[2]:=5640.945; CB[2]:=6590.039; CR[2]:=5779.055; CT[2]:=6739.961;
    Names[3]:='J_SWD'; XS[3]:=6875.0; YS[3]:=6020.0; RS[3]:=90.0; Sides[3]:=eTopLayer; PN[3]:=5; MN[3]:=6; PL[3]:=6837.599; PB[3]:=5782.599; PR[3]:=6912.401; PT[3]:=6257.401; ML[3]:=6823.032; MB[3]:=5768.032; MR[3]:=6926.968; MT[3]:=6271.968; CL[3]:=6813.032; CB[3]:=5758.032; CR[3]:=6936.968; CT[3]:=6281.968;
    Names[4]:='J_SHIELD'; XS[4]:=4310.0; YS[4]:=6710.0; RS[4]:=90.0; Sides[4]:=eTopLayer; PN[4]:=1; MN[4]:=0; PL[4]:=4260.787; PB[4]:=6660.787; PR[4]:=4359.213; PT[4]:=6759.213; ML[4]:=0; MB[4]:=0; MR[4]:=0; MT[4]:=0; CL[4]:=4250.787; CB[4]:=6650.787; CR[4]:=4369.213; CT[4]:=6769.213;
    Names[5]:='J_NAV'; XS[5]:=7091.575; YS[5]:=6900.0; RS[5]:=180.0; Sides[5]:=eTopLayer; PN[5]:=5; MN[5]:=4; PL[5]:=6865.197; PB[5]:=6870.472; PR[5]:=7317.953; PT[5]:=6929.528; ML[5]:=6794.331; MB[5]:=6783.858; MR[5]:=7388.819; MT[5]:=7016.142; CL[5]:=6784.331; CB[5]:=6773.858; CR[5]:=7398.819; CT[5]:=7026.142;
    Names[6]:='D_EXT3'; XS[6]:=6452.598; YS[6]:=4515.276; RS[6]:=90.0; Sides[6]:=eTopLayer; PN[6]:=6; MN[6]:=6; PL[6]:=6401.417; PB[6]:=4444.409; PR[6]:=6503.779; PT[6]:=4586.142; ML[6]:=6407.323; MB[6]:=4456.221; MR[6]:=6486.063; MT[6]:=4574.331; CL[6]:=6391.417; CB[6]:=4434.409; CR[6]:=6513.779; CT[6]:=4596.142;
    Names[7]:='D_EXT2'; XS[7]:=6777.598; YS[7]:=4515.276; RS[7]:=90.0; Sides[7]:=eTopLayer; PN[7]:=6; MN[7]:=6; PL[7]:=6726.417; PB[7]:=4444.409; PR[7]:=6828.779; PT[7]:=4586.142; ML[7]:=6732.323; MB[7]:=4456.221; MR[7]:=6811.063; MT[7]:=4574.331; CL[7]:=6716.417; CB[7]:=4434.409; CR[7]:=6838.779; CT[7]:=4596.142;
    Names[8]:='D_EXT1'; XS[8]:=6617.598; YS[8]:=4515.276; RS[8]:=90.0; Sides[8]:=eTopLayer; PN[8]:=6; MN[8]:=6; PL[8]:=6566.417; PB[8]:=4444.409; PR[8]:=6668.779; PT[8]:=4586.142; ML[8]:=6572.323; MB[8]:=4456.221; MR[8]:=6651.063; MT[8]:=4574.331; CL[8]:=6556.417; CB[8]:=4434.409; CR[8]:=6678.779; CT[8]:=4596.142;
    Names[9]:='D_ESD'; XS[9]:=4645.0; YS[9]:=6629.724; RS[9]:=270.0; Sides[9]:=eTopLayer; PN[9]:=6; MN[9]:=6; PL[9]:=4593.819; PB[9]:=6558.858; PR[9]:=4696.181; PT[9]:=6700.591; ML[9]:=4611.535; MB[9]:=6570.669; MR[9]:=4690.276; MT[9]:=6688.779; CL[9]:=4583.819; CB[9]:=6548.858; CR[9]:=4706.181; CT[9]:=6710.591;
    Names[10]:='D_ESD2'; XS[10]:=7249.724; YS[10]:=5585.0; RS[10]:=0.0; Sides[10]:=eTopLayer; PN[10]:=6; MN[10]:=6; PL[10]:=7178.858; PB[10]:=5533.819; PR[10]:=7320.591; PT[10]:=5636.181; ML[10]:=7190.669; MB[10]:=5551.535; MR[10]:=7308.779; MT[10]:=5630.276; CL[10]:=7168.858; CB[10]:=5523.819; CR[10]:=7330.591; CT[10]:=5646.181;
    Names[11]:='D_ESD1'; XS[11]:=7244.724; YS[11]:=5812.598; RS[11]:=0.0; Sides[11]:=eTopLayer; PN[11]:=6; MN[11]:=6; PL[11]:=7173.858; PB[11]:=5761.417; PR[11]:=7315.591; PT[11]:=5863.779; ML[11]:=7185.669; MB[11]:=5779.134; MR[11]:=7303.779; MT[11]:=5857.874; CL[11]:=7163.858; CB[11]:=5751.417; CR[11]:=7325.591; CT[11]:=5873.779;
    Names[12]:='C_SENSOR_BULK'; XS[12]:=4925.433; YS[12]:=6605.0; RS[12]:=0.0; Sides[12]:=eTopLayer; PN[12]:=2; MN[12]:=4; PL[12]:=4876.221; PB[12]:=6578.425; PR[12]:=4974.646; PT[12]:=6631.575; ML[12]:=4884.095; MB[12]:=6578.425; MR[12]:=4966.772; MT[12]:=6631.575; CL[12]:=4866.221; CB[12]:=6568.425; CR[12]:=4984.646; CT[12]:=6641.575;
    Names[13]:='C_SD_MID'; XS[13]:=7144.567; YS[13]:=5675.0; RS[13]:=0.0; Sides[13]:=eTopLayer; PN[13]:=2; MN[13]:=4; PL[13]:=7095.354; PB[13]:=5648.425; PR[13]:=7193.779; PT[13]:=5701.575; ML[13]:=7103.228; MB[13]:=5648.425; MR[13]:=7185.905; MT[13]:=5701.575; CL[13]:=7085.354; CB[13]:=5638.425; CR[13]:=7203.779; CT[13]:=5711.575;
    Names[14]:='C_OLED_BULK'; XS[14]:=5725.0; YS[14]:=6780.0; RS[14]:=0.0; Sides[14]:=eTopLayer; PN[14]:=2; MN[14]:=4; PL[14]:=5675.787; PB[14]:=6753.425; PR[14]:=5774.213; PT[14]:=6806.575; ML[14]:=5683.661; MB[14]:=6753.425; MR[14]:=5766.339; MT[14]:=6806.575; CL[14]:=5665.787; CB[14]:=6743.425; CR[14]:=5784.213; CT[14]:=6816.575;
End;

Function Near(A,V);
Begin Result:=Abs(A-V)<0.02; End;

Function FindComp(S);
Var It;C;
Begin
    Result:=Nil;
    It:=B.BoardIterator_Create;
    If It=Nil Then Exit;
    It.AddFilter_ObjectSet(MkSet(eComponentObject));
    It.AddFilter_LayerSet(AllLayers); It.AddFilter_Method(eProcessAll);
    C:=It.FirstPCBObject;
    While C<>Nil Do Begin
        If UpperCase(C.SourceDesignator)=UpperCase(S) Then Begin Result:=C; Break; End;
        C:=It.NextPCBObject;
    End;
    B.BoardIterator_Destroy(It);
End;

Procedure Measure(C,Mode; Var N,L,Lo,R,Hi);
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

Function Check;
Var I;N;L;Lo;R;Hi;C;It;Count;Covered;
Begin
    Result:=False; Err:=''; Init;
    B:=PCBServer.GetCurrentPCBBoard;
    If B=Nil Then Begin Err:='No PCB active'; Exit; End;
    If UpperCase(ExtractFileName(B.FileName))<>'DATALOGER_REVA_T24_COURTYARD_PENDING.PCBDOC' Then
    Begin Err:='Activate the PENDING copy'; Exit; End;
    If Not B.MechanicalPairs.PairDefined(eMechanical2,eMechanical4) Then
    Begin Err:='M2/M4 pair missing'; Exit; End;
    Count:=0; Covered:=0;
    It:=B.BoardIterator_Create;
    If It=Nil Then Begin Err:='Board iterator unavailable'; Exit; End;
    It.AddFilter_ObjectSet(MkSet(eComponentObject));
    It.AddFilter_LayerSet(AllLayers); It.AddFilter_Method(eProcessAll);
    C:=It.FirstPCBObject;
    While C<>Nil Do Begin
        Count:=Count+1; Measure(C,2,N,L,Lo,R,Hi);
        If N>0 Then Covered:=Covered+1;
        C:=It.NextPCBObject;
    End;
    B.BoardIterator_Destroy(It);
    If (Count<>129) Or (Covered<>113) Then
    Begin Err:='Expected 129 components / 113 courtyard-covered; already applied or baseline changed'; Exit; End;
    For I:=0 To 14 Do Begin
        C:=FindComp(Names[I]); Comps[I]:=C;
        If C=Nil Then Begin Err:='Missing '+Names[I]; Exit; End;
        If (C.Layer<>Sides[I]) Or Not Near(CoordToMils(C.X),XS[I]) Or
            Not Near(CoordToMils(C.Y),YS[I]) Or Not Near(C.Rotation,RS[I]) Then
        Begin Err:='Placement changed: '+Names[I]; Exit; End;
        Measure(C,2,N,L,Lo,R,Hi);
        If N<>0 Then Begin Err:='Courtyard already exists: '+Names[I]; Exit; End;
        Measure(C,0,N,L,Lo,R,Hi);
        If (N<>PN[I]) Or Not Near(L,PL[I]) Or Not Near(Lo,PB[I]) Or
            Not Near(R,PR[I]) Or Not Near(Hi,PT[I]) Then
        Begin Err:='Pad envelope changed: '+Names[I]; Exit; End;
        Measure(C,1,N,L,Lo,R,Hi);
        If (N<>MN[I]) Or Not Near(L,ML[I]) Or Not Near(Lo,MB[I]) Or
            Not Near(R,MR[I]) Or Not Near(Hi,MT[I]) Then
        Begin Err:='M1 envelope changed: '+Names[I]; Exit; End;
    End;
    Result:=True;
End;

Procedure PreflightT24_Courtyard_Step2A_v1;
Var I;
Begin
    If Not Check Then Begin ShowMessage('ABORT: '+Err+'. Nothing changed.'); Exit; End;
    Log:=TStringList.Create;
    Try
        Log.Add('BASELINE PASS ONLY - not a clearance or fabrication PASS');
        Log.Add('PCB: '+B.FileName);
        Log.Add('15 rectangles / 60 tracks. J_SD unresolved. Silk unchanged.');
        Log.Add('KNOWN CANDIDATE REVIEW: C_SD_MID / D_ESD2 rectangles overlap.');
        Log.Add('KNOWN CANDIDATE REVIEW: C_OLED_BULK / Q_OLED gap = 3.464 mil, below 10 mil.');
        Log.Add('Existing-courtyard neighbours also require live DRC; this is NOT collision preflight.');
        Log.Add('10 mil allowance around pad/M1 union; does not waive the 10 mil ComponentClearance rule.');
        For I:=0 To 14 Do
            Log.Add(Names[I]+' L/B/R/T mil: '+FloatToStr(CL[I])+' / '+FloatToStr(CB[I])+' / '+FloatToStr(CR[I])+' / '+FloatToStr(CT[I]));
        Log.SaveToFile(ExtractFilePath(B.FileName)+'T24_Courtyard_Step2A_Preflight_v1.txt');
    Finally Log.Free; End;
    ShowMessage('BASELINE PASS - 15 targets verified. Nothing changed.'+#13#10+
        'Candidate courtyards may expose additional clearance violations.'+#13#10+
        'J_SD and silk repair remain pending. Layer Type must remain Courtyard.');
End;

Procedure AddLineToComp(C,Lay,X1,Y1,X2,Y2);
Var T;
Begin
    T:=PCBServer.PCBObjectFactory(eTrackObject,eNoDimension,eCreate_Default);
    If T=Nil Then Raise Exception.Create('Track factory failed');
    T.Layer:=Lay; T.Width:=MilsToCoord(1.968504);
    T.X1:=MilsToCoord(X1); T.Y1:=MilsToCoord(Y1);
    T.X2:=MilsToCoord(X2); T.Y2:=MilsToCoord(Y2);
    C.AddPCBObject(T);
    PCBServer.SendMessageToRobots(C.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,T.I_ObjectAddress);
    Added:=Added+1;
End;

Procedure ApplyT24_Courtyard_Step2A_v1;
Var I;C;Lay;N;L;Lo;R;Hi;Good;
Begin
    If Not Check Then Begin ShowMessage('ABORT: '+Err+'. Nothing changed.'); Exit; End;
    Added:=0; Good:=True;
    PCBServer.PreProcess;
    Try
        For I:=0 To 14 Do Begin
            C:=Comps[I]; Lay:=eMechanical2;
            If Sides[I]=eBottomLayer Then Lay:=eMechanical4;
            PCBServer.SendMessageToRobots(C.I_ObjectAddress,c_Broadcast,PCBM_BeginModify,c_NoEventData);
            Try
                AddLineToComp(C,Lay,CL[I],CB[I],CR[I],CB[I]);
                AddLineToComp(C,Lay,CR[I],CB[I],CR[I],CT[I]);
                AddLineToComp(C,Lay,CR[I],CT[I],CL[I],CT[I]);
                AddLineToComp(C,Lay,CL[I],CT[I],CL[I],CB[I]);
            Finally
                PCBServer.SendMessageToRobots(C.I_ObjectAddress,c_Broadcast,PCBM_EndModify,c_NoEventData);
            End;
        End;
    Finally PCBServer.PostProcess; End;
    B.ViewManager_FullUpdate;
    For I:=0 To 14 Do Begin
        Measure(Comps[I],2,N,L,Lo,R,Hi);
        If (N<>4) Or Not Near(L,CL[I]-0.984252) Or Not Near(Lo,CB[I]-0.984252) Or
            Not Near(R,CR[I]+0.984252) Or Not Near(Hi,CT[I]+0.984252) Then Good:=False;
    End;
    If (Added<>60) Or Not Good Then Begin
        ShowMessage('POSTCHECK FAILED. DO NOT SAVE. Keep recovery copy. Report the error.'); Exit;
    End;
    ShowMessage('APPLY COMPLETE: 15 courtyards / 60 tracks.'+#13#10+
        '128 of 129 components now have courtyard data; J_SD remains pending.'+#13#10+
        'Run full Batch DRC. Do not save over the original PCB.'+#13#10+
        'No copper, placement, rules, or silkscreen intentionally changed.');
End;
