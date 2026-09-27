{ Datalogger RevA - T24
  Final Courtyard completion for D_ESD1 + D_ESD2 v1

  PURPOSE
  - Add courtyard only for D_ESD1 and D_ESD2.
  - Keep J_SD deferred until exact MR01A-01245 body drawing is available.
  - Courtyard outer bounds equal the audited PAD envelope.
  - Track width = 0.05 mm = 1.968504 mil.
  - Track centerlines are inset by half-width so the final outer courtyard
    does NOT grow beyond the audited PAD envelope.

  SAFETY
  - Preflight first.
  - Live collision screen against every existing M2/M4 courtyard.
  - Requires current 126/129 courtyard-covered baseline.
  - No copper, routing, vias, polygons, rules, components or silk changed.
  - After Apply: Full Batch DRC before Save.

  Entry points:
    PreflightT24_Courtyard_ESD12_Final_v1
    ApplyT24_Courtyard_ESD12_Final_v1
}

Var
    GBoard;
    GError;
    GReport;
    GAdded;

Function E12Near(A,V);
Begin
    Result:=Abs(A-V)<0.03;
End;

Function E12FindComponent(S);
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

Procedure E12Measure(C,Mode; Var N,L,B,R,T);
Var It; O; BR; UseIt;
Begin
    N:=0; L:=0; B:=0; R:=0; T:=0;
    It:=C.GroupIterator_Create;
    If It=Nil Then Begin N:=-1; Exit; End;

    It.AddFilter_ObjectSet(
        MkSet(ePadObject,eTrackObject,eArcObject,eFillObject,eRegionObject,eTextObject)
    );
    It.AddFilter_LayerSet(AllLayers);

    O:=It.FirstPCBObject;
    While O<>Nil Do Begin
        UseIt:=False;
        If Mode=0 Then UseIt:=O.ObjectId=ePadObject;
        If Mode=1 Then UseIt:=(O.Layer=eMechanical1) And (O.ObjectId<>eTextObject);
        If Mode=2 Then UseIt:=((O.Layer=eMechanical2) Or (O.Layer=eMechanical4)) And
                              (O.ObjectId<>eTextObject);

        If UseIt Then Begin
            BR:=O.BoundingRectangle;
            If N=0 Then Begin
                L:=CoordToMils(BR.Left);
                B:=CoordToMils(BR.Bottom);
                R:=CoordToMils(BR.Right);
                T:=CoordToMils(BR.Top);
            End Else Begin
                If CoordToMils(BR.Left)<L Then L:=CoordToMils(BR.Left);
                If CoordToMils(BR.Bottom)<B Then B:=CoordToMils(BR.Bottom);
                If CoordToMils(BR.Right)>R Then R:=CoordToMils(BR.Right);
                If CoordToMils(BR.Top)>T Then T:=CoordToMils(BR.Top);
            End;
            N:=N+1;
        End;
        O:=It.NextPCBObject;
    End;

    C.GroupIterator_Destroy(It);
End;

Function E12CountCovered;
Var It; C; N; CN; L; B; R; T;
Begin
    N:=0;
    It:=GBoard.BoardIterator_Create;
    If It=Nil Then Begin Result:=-1; Exit; End;

    It.AddFilter_ObjectSet(MkSet(eComponentObject));
    It.AddFilter_LayerSet(AllLayers);
    It.AddFilter_Method(eProcessAll);

    C:=It.FirstPCBObject;
    While C<>Nil Do Begin
        E12Measure(C,2,CN,L,B,R,T);
        If CN>0 Then N:=N+1;
        C:=It.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(It);
    Result:=N;
End;

Function E12CountComponents;
Var It; C; N;
Begin
    N:=0;
    It:=GBoard.BoardIterator_Create;
    If It=Nil Then Begin Result:=-1; Exit; End;

    It.AddFilter_ObjectSet(MkSet(eComponentObject));
    It.AddFilter_LayerSet(AllLayers);
    It.AddFilter_Method(eProcessAll);

    C:=It.FirstPCBObject;
    While C<>Nil Do Begin
        N:=N+1;
        C:=It.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(It);
    Result:=N;
End;

Function E12CheckTarget(
    RefName,ExpectedX,ExpectedY,ExpectedRotation,
    PadL,PadB,PadR,PadT,
    M1L,M1B,M1R,M1T
);
Var C; N; L; B; R; T;
Begin
    Result:=False;

    C:=E12FindComponent(RefName);
    If C=Nil Then Begin
        GError:='Missing '+RefName;
        Exit;
    End;

    If C.Layer<>eTopLayer Then Begin
        GError:=RefName+' is not on Top Layer';
        Exit;
    End;

    If Not E12Near(CoordToMils(C.X),ExpectedX) Or
       Not E12Near(CoordToMils(C.Y),ExpectedY) Or
       Not E12Near(C.Rotation,ExpectedRotation) Then Begin
        GError:='Placement changed: '+RefName;
        Exit;
    End;

    E12Measure(C,2,N,L,B,R,T);
    If N<>0 Then Begin
        GError:='Courtyard already exists: '+RefName;
        Exit;
    End;

    E12Measure(C,0,N,L,B,R,T);
    If (N<>6) Or
       Not E12Near(L,PadL) Or Not E12Near(B,PadB) Or
       Not E12Near(R,PadR) Or Not E12Near(T,PadT) Then Begin
        GError:='Pad envelope changed: '+RefName;
        Exit;
    End;

    E12Measure(C,1,N,L,B,R,T);
    If (N<>6) Or
       Not E12Near(L,M1L) Or Not E12Near(B,M1B) Or
       Not E12Near(R,M1R) Or Not E12Near(T,M1T) Then Begin
        GError:='Mechanical1 envelope changed: '+RefName;
        Exit;
    End;

    Result:=True;
End;

Function E12GapX(AL,AR,BL,BR);
Begin
    If AR<BL Then Result:=BL-AR
    Else If BR<AL Then Result:=AL-BR
    Else Result:=0;
End;

Function E12GapY(AB,AT,BB,BT);
Begin
    If AT<BB Then Result:=BB-AT
    Else If BT<AB Then Result:=AB-BT
    Else Result:=0;
End;

Function E12CandidateClear(RefName,L,B,R,T);
Var It; C; N; OL; OB; ORight; OT; DX; DY; MinSep;
Begin
    Result:=False;
    MinSep:=1000000;

    It:=GBoard.BoardIterator_Create;
    If It=Nil Then Begin
        GError:='Board iterator unavailable during collision screen';
        Exit;
    End;

    It.AddFilter_ObjectSet(MkSet(eComponentObject));
    It.AddFilter_LayerSet(AllLayers);
    It.AddFilter_Method(eProcessAll);

    C:=It.FirstPCBObject;
    While C<>Nil Do Begin
        If (UpperCase(C.SourceDesignator)<>UpperCase(RefName)) And
           (UpperCase(C.SourceDesignator)<>'D_ESD1') And
           (UpperCase(C.SourceDesignator)<>'D_ESD2') Then Begin

            E12Measure(C,2,N,OL,OB,ORight,OT);

            If N>0 Then Begin
                DX:=E12GapX(L,R,OL,ORight);
                DY:=E12GapY(B,T,OB,OT);

                If (DX<10.0) And (DY<10.0) Then Begin
                    GError:=
                        'Candidate '+RefName+
                        ' is under 10mil from existing courtyard '+C.SourceDesignator+
                        ' (DX='+FloatToStr(DX)+', DY='+FloatToStr(DY)+')';
                    GBoard.BoardIterator_Destroy(It);
                    Exit;
                End;

                If DX>DY Then MinSep:=DY Else MinSep:=DX;
            End;
        End;

        C:=It.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(It);
    Result:=True;
End;

Function E12BaselineReady;
Var J;
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
        GError:='Activate the PENDING PCB';
        Exit;
    End;

    If Not GBoard.MechanicalPairs.PairDefined(eMechanical2,eMechanical4) Then Begin
        GError:='M2/M4 courtyard pair missing';
        Exit;
    End;

    If E12CountComponents<>129 Then Begin
        GError:='Expected 129 components';
        Exit;
    End;

    If E12CountCovered<>126 Then Begin
        GError:='Expected 126/129 courtyard-covered baseline';
        Exit;
    End;

    If Not E12CheckTarget(
        'D_ESD1',
        7244.724,5812.598,0.0,
        7173.858,5761.417,7315.591,5863.779,
        7185.669,5779.134,7303.779,5857.874
    ) Then Exit;

    If Not E12CheckTarget(
        'D_ESD2',
        7249.724,5585.0,0.0,
        7178.858,5533.819,7320.591,5636.181,
        7190.669,5551.535,7308.779,5630.276
    ) Then Exit;

    J:=E12FindComponent('J_SD');
    If J=Nil Then Begin
        GError:='Missing J_SD';
        Exit;
    End;

    If E12CountCovered<>126 Then Begin
        GError:='Covered count changed during preflight';
        Exit;
    End;

    If Not E12CandidateClear(
        'D_ESD1',
        7173.858,5761.417,7315.591,5863.779
    ) Then Exit;

    If Not E12CandidateClear(
        'D_ESD2',
        7178.858,5533.819,7320.591,5636.181
    ) Then Exit;

    { Explicit candidate-to-candidate check }
    If (E12GapX(7173.858,7315.591,7178.858,7320.591)<10.0) And
       (E12GapY(5761.417,5863.779,5533.819,5636.181)<10.0) Then Begin
        GError:='D_ESD1 / D_ESD2 candidate courtyards are under 10mil';
        Exit;
    End;

    Result:=True;
End;

Procedure E12AddLine(C,X1,Y1,X2,Y2);
Var P;
Begin
    P:=PCBServer.PCBObjectFactory(eTrackObject,eNoDimension,eCreate_Default);
    If P=Nil Then Raise('Track factory failed');

    P.Layer:=eMechanical2;
    P.Width:=MilsToCoord(1.968504);
    P.X1:=MilsToCoord(X1);
    P.Y1:=MilsToCoord(Y1);
    P.X2:=MilsToCoord(X2);
    P.Y2:=MilsToCoord(Y2);

    C.AddPCBObject(P);

    PCBServer.SendMessageToRobots(
        C.I_ObjectAddress,
        c_Broadcast,
        PCBM_BoardRegisteration,
        P.I_ObjectAddress
    );

    GAdded:=GAdded+1;
End;

Procedure E12ApplyRect(RefName,L,B,R,T);
Var C;
Begin
    C:=E12FindComponent(RefName);
    If C=Nil Then Raise('Missing '+RefName);

    PCBServer.SendMessageToRobots(
        C.I_ObjectAddress,c_Broadcast,PCBM_BeginModify,c_NoEventData
    );

    Try
        E12AddLine(C,L,B,R,B);
        E12AddLine(C,R,B,R,T);
        E12AddLine(C,R,T,L,T);
        E12AddLine(C,L,T,L,B);
    Finally
        PCBServer.SendMessageToRobots(
            C.I_ObjectAddress,c_Broadcast,PCBM_EndModify,c_NoEventData
        );
    End;
End;

Function E12Postcheck(RefName,OuterL,OuterB,OuterR,OuterT);
Var C; N; L; B; R; T;
Begin
    Result:=False;
    C:=E12FindComponent(RefName);
    If C=Nil Then Exit;

    E12Measure(C,2,N,L,B,R,T);

    Result:=
        (N=4) And
        E12Near(L,OuterL) And
        E12Near(B,OuterB) And
        E12Near(R,OuterR) And
        E12Near(T,OuterT);
End;

Procedure PreflightT24_Courtyard_ESD12_Final_v1;
Var FN;
Begin
    GReport:=TStringList.Create;
    Try
        If Not E12BaselineReady Then Begin
            ShowMessage('ABORT: '+GError+'. Nothing changed.');
            Exit;
        End;

        GReport.Add('T24 Final Courtyard ESD12 v1 - PREFLIGHT PASS');
        GReport.Add('PCB: '+GBoard.FileName);
        GReport.Add('Baseline: 129 components / 126 courtyard-covered.');
        GReport.Add('D_ESD1 candidate OUTER envelope: 7173.858 / 5761.417 / 7315.591 / 5863.779 mil.');
        GReport.Add('D_ESD2 candidate OUTER envelope: 7178.858 / 5533.819 / 7320.591 / 5636.181 mil.');
        GReport.Add('Track width: 0.05 mm; centerline inset preserves exact outer envelope.');
        GReport.Add('Live screen: no existing courtyard under 10 mil.');
        GReport.Add('J_SD remains deferred pending exact MR01A-01245 body drawing.');
        GReport.Add('Nothing changed.');

        FN:=ExtractFilePath(GBoard.FileName)+
            'T24_Courtyard_ESD12_Final_Preflight_v1.txt';
        GReport.SaveToFile(FN);

        ShowMessage(
            'PREFLIGHT PASS - D_ESD1 + D_ESD2.'+#13#10+
            'Live courtyard screen >=10mil.'+#13#10+
            'J_SD remains deferred.'+#13#10+
            'Nothing changed.'+#13#10+
            'Output: T24_Courtyard_ESD12_Final_Preflight_v1.txt'
        );
    Finally
        GReport.Free;
    End;
End;

Procedure ApplyT24_Courtyard_ESD12_Final_v1;
Var Good;
Begin
    If Not E12BaselineReady Then Begin
        ShowMessage('ABORT: '+GError+'. Nothing changed.');
        Exit;
    End;

    GAdded:=0;
    Good:=True;

    PCBServer.PreProcess;
    Try
        { Track half-width = 0.984252 mil.
          These centerlines produce final OUTER bounds equal to pad envelopes. }

        E12ApplyRect(
            'D_ESD1',
            7174.842252,5762.401252,
            7314.606748,5862.794748
        );

        E12ApplyRect(
            'D_ESD2',
            7179.842252,5534.803252,
            7319.606748,5635.196748
        );
    Finally
        PCBServer.PostProcess;
    End;

    GBoard.ViewManager_FullUpdate;

    If Not E12Postcheck(
        'D_ESD1',
        7173.858,5761.417,7315.591,5863.779
    ) Then Good:=False;

    If Not E12Postcheck(
        'D_ESD2',
        7178.858,5533.819,7320.591,5636.181
    ) Then Good:=False;

    If E12CountCovered<>128 Then Good:=False;

    If (GAdded<>8) Or Not Good Then Begin
        ShowMessage(
            'POSTCHECK FAILED. DO NOT SAVE.'+#13#10+
            'Use Ctrl+Z once and report the result.'
        );
        Exit;
    End;

    ShowMessage(
        'APPLY COMPLETE - D_ESD1 + D_ESD2.'+#13#10+
        '8 courtyard tracks added.'+#13#10+
        '128 of 129 components now have courtyard data.'+#13#10+
        'Only J_SD remains deferred.'+#13#10+
        'NEXT: Full Batch DRC. Do not save until DRC is clean.'
    );
End;
