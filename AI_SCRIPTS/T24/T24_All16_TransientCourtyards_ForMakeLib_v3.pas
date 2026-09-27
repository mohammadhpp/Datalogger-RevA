{ Datalogger RevA - T24
  AUTO WORKAROUND: Build all 16 missing courtyards on the CURRENT PCB in memory,
  then use Altium native Design > Make PCB Library to regenerate a persistent PcbLib.

  WHY THIS PATH
  - PcbDoc component-child mutation is already proven to work in this project/session.
  - Direct PcbLib DelphiScript mutation crashes ScriptingSystem.DLL on AD 26.8.1.
  - Altium's native Make PCB Library command creates a PcbLib from the ACTIVE PCB.
  - NO manual rectangle drawing is required.

  IMPORTANT
  - Run only on DATALOGER_RevA.PcbDoc.
  - This is now the canonical working PCB name per project decision on 2026-09-23.
  - User already made a backup before promoting this filename.
  - Baseline must be 129 components / 113 courtyard-covered.
  - This script deliberately does NOT save the PcbDoc.
  - After PASS, immediately run: Design > Make PCB Library.
  - Do NOT save/close/reopen the PcbDoc before Make PCB Library, because these
    temporary component-child courtyards are known not to persist reliably in PcbDoc.
  - The generated PcbLib must be audited before becoming canonical.\n  - EXTRACTION-SPECIFIC FIX: U_RTC is physically on Bottom in the PCB, but its SOURCE footprint courtyard must be Top Courtyard / Mechanical2. Therefore v3 deliberately stages U_RTC courtyard on Mechanical2 before Make PCB Library.

  Entry:
    ApplyT24_All16_TransientCourtyards_ForMakeLib_v3
}

Var
    GBoard;
    GError;
    GAdded;

Function T24Near(A,V);
Begin
    Result:=Abs(A-V)<0.03;
End;

Function T24FindComponent(S);
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

Procedure T24Measure(C,Mode; Var N,L,B,R,T);
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

        If Mode=0 Then
            UseIt:=O.ObjectId=ePadObject;

        If Mode=1 Then
            UseIt:=(O.Layer=eMechanical1) And (O.ObjectId<>eTextObject);

        If Mode=2 Then
            UseIt:=((O.Layer=eMechanical2) Or (O.Layer=eMechanical4)) And
                   (O.ObjectId<>eTextObject);

        If UseIt Then Begin
            BR:=O.BoundingRectangle;

            If N=0 Then Begin
                L:=CoordToMils(BR.Left);
                B:=CoordToMils(BR.Bottom);
                R:=CoordToMils(BR.Right);
                T:=CoordToMils(BR.Top);
            End
            Else Begin
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

Procedure T24UnionPadM1(C; Var L; Var B; Var R; Var T);
Var
    NP; NM;
    PL; PB; PR; PT;
    ML; MB; MR; MT;
Begin
    T24Measure(C,0,NP,PL,PB,PR,PT);
    If NP<=0 Then Begin
        L:=0; B:=0; R:=0; T:=0;
        Exit;
    End;

    L:=PL; B:=PB; R:=PR; T:=PT;

    T24Measure(C,1,NM,ML,MB,MR,MT);
    If NM>0 Then Begin
        If ML<L Then L:=ML;
        If MB<B Then B:=MB;
        If MR>R Then R:=MR;
        If MT>T Then T:=MT;
    End;
End;

Function T24CountCovered;
Var It; C; N; Covered; CN; L; B; R; T;
Begin
    Covered:=0;
    It:=GBoard.BoardIterator_Create;
    If It=Nil Then Begin Result:=-1; Exit; End;

    It.AddFilter_ObjectSet(MkSet(eComponentObject));
    It.AddFilter_LayerSet(AllLayers);
    It.AddFilter_Method(eProcessAll);

    C:=It.FirstPCBObject;
    While C<>Nil Do Begin
        T24Measure(C,2,CN,L,B,R,T);
        If CN>0 Then Covered:=Covered+1;
        C:=It.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(It);
    Result:=Covered;
End;

Function T24CountComponents;
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

Function T24CheckOne(RefName,ExpectedSide,PadCount,M1Count,SmallMM,LargeMM);
Var
    C;
    NP; NM; NC;
    PL; PB; PR; PT;
    ML; MB; MR; MT;
    L; B; R; T;
    Wmm; Hmm; SmallV; LargeV;
Begin
    Result:=False;

    C:=T24FindComponent(RefName);
    If C=Nil Then Begin
        GError:='Missing '+RefName;
        Exit;
    End;

    If C.Layer<>ExpectedSide Then Begin
        GError:='Layer changed: '+RefName;
        Exit;
    End;

    T24Measure(C,2,NC,L,B,R,T);
    If NC<>0 Then Begin
        GError:='Courtyard already exists: '+RefName;
        Exit;
    End;

    T24Measure(C,0,NP,PL,PB,PR,PT);
    If NP<>PadCount Then Begin
        GError:='Pad count changed: '+RefName;
        Exit;
    End;

    T24Measure(C,1,NM,ML,MB,MR,MT);
    If NM<>M1Count Then Begin
        GError:='Mechanical1 count changed: '+RefName;
        Exit;
    End;

    T24UnionPadM1(C,L,B,R,T);

    Wmm:=(R-L)*0.0254;
    Hmm:=(T-B)*0.0254;

    If Wmm<Hmm Then Begin
        SmallV:=Wmm;
        LargeV:=Hmm;
    End
    Else Begin
        SmallV:=Hmm;
        LargeV:=Wmm;
    End;

    If Not T24Near(SmallV,SmallMM) Then Begin
        GError:='Small envelope changed: '+RefName+
                ' got '+FloatToStr(SmallV)+' mm';
        Exit;
    End;

    If Not T24Near(LargeV,LargeMM) Then Begin
        GError:='Large envelope changed: '+RefName+
                ' got '+FloatToStr(LargeV)+' mm';
        Exit;
    End;

    Result:=True;
End;

Function T24Preflight;
Begin
    Result:=False;
    GError:='';

    GBoard:=PCBServer.GetCurrentPCBBoard;
    If GBoard=Nil Then Begin
        GError:='No PCB active';
        Exit;
    End;

    If UpperCase(ExtractFileName(GBoard.FileName))
       <>'DATALOGER_REVA.PCBDOC' Then Begin
        GError:='Activate DATALOGER_RevA.PcbDoc';
        Exit;
    End;

    If Not GBoard.MechanicalPairs.PairDefined(eMechanical2,eMechanical4) Then Begin
        GError:='M2/M4 courtyard pair missing';
        Exit;
    End;

    If T24CountComponents<>129 Then Begin
        GError:='Expected 129 components';
        Exit;
    End;

    If T24CountCovered<>113 Then Begin
        GError:='Expected 113/129 courtyard-covered baseline';
        Exit;
    End;

    If Not T24CheckOne('U_RTC',eBottomLayer,16,4,10.60,11.45) Then Exit;
    If Not T24CheckOne('Q_SD',eTopLayer,3,6,3.00,3.30) Then Exit;
    If Not T24CheckOne('Q_OLED',eTopLayer,3,6,3.00,3.30) Then Exit;
    If Not T24CheckOne('J_SWD',eTopLayer,5,6,2.64,12.80) Then Exit;
    If Not T24CheckOne('J_SHIELD',eTopLayer,1,0,2.50,2.50) Then Exit;
    If Not T24CheckOne('J_NAV',eTopLayer,5,4,5.90,15.10) Then Exit;

    If Not T24CheckOne('D_EXT3',eTopLayer,6,6,2.60,3.60) Then Exit;
    If Not T24CheckOne('D_EXT2',eTopLayer,6,6,2.60,3.60) Then Exit;
    If Not T24CheckOne('D_EXT1',eTopLayer,6,6,2.60,3.60) Then Exit;
    If Not T24CheckOne('D_ESD', eTopLayer,6,6,2.60,3.60) Then Exit;
    If Not T24CheckOne('D_ESD1',eTopLayer,6,6,2.60,3.60) Then Exit;
    If Not T24CheckOne('D_ESD2',eTopLayer,6,6,2.60,3.60) Then Exit;

    If Not T24CheckOne('C_SENSOR_BULK',eTopLayer,2,4,1.35,2.50) Then Exit;
    If Not T24CheckOne('C_SD_MID',eTopLayer,2,4,1.35,2.50) Then Exit;
    If Not T24CheckOne('C_OLED_BULK',eTopLayer,2,4,1.35,2.50) Then Exit;

    { J_SD has no usable M1 body in the current footprint; PAD envelope fallback. }
    If Not T24CheckOne('J_SD',eTopLayer,15,0,12.50,16.80) Then Exit;

    Result:=True;
End;

Procedure T24AddLine(C,Lay,X1,Y1,X2,Y2);
Var P;
Begin
    P:=PCBServer.PCBObjectFactory(
        eTrackObject,
        eNoDimension,
        eCreate_Default
    );

    If P=Nil Then Begin
        Raise('Track factory failed');
    End;

    P.Layer:=Lay;
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

Procedure T24ApplyOne(RefName,SideName);
Var
    C;
    Lay;
    L; B; R; T;
    H;
Begin
    C:=T24FindComponent(RefName);
    If C=Nil Then Begin
        Raise('Missing '+RefName);
    End;

    T24UnionPadM1(C,L,B,R,T);

    { half of 0.05 mm track width in mil }
    H:=0.984252;

    Lay:=eMechanical2;
    If SideName='BOTTOM' Then
        Lay:=eMechanical4;

    PCBServer.SendMessageToRobots(
        C.I_ObjectAddress,
        c_Broadcast,
        PCBM_BeginModify,
        c_NoEventData
    );

    Try
        { Centerlines are inset so the OUTER courtyard boundary equals the audited union. }
        T24AddLine(C,Lay,L+H,B+H,R-H,B+H);
        T24AddLine(C,Lay,R-H,B+H,R-H,T-H);
        T24AddLine(C,Lay,R-H,T-H,L+H,T-H);
        T24AddLine(C,Lay,L+H,T-H,L+H,B+H);
    Finally
        PCBServer.SendMessageToRobots(
            C.I_ObjectAddress,
            c_Broadcast,
            PCBM_EndModify,
            c_NoEventData
        );
    End;
End;

Function T24PostcheckOne(RefName);
Var
    C;
    N;
    OL; OB; ORight; OT;
    L; B; R; T;
Begin
    Result:=False;

    C:=T24FindComponent(RefName);
    If C=Nil Then Exit;

    T24UnionPadM1(C,L,B,R,T);
    T24Measure(C,2,N,OL,OB,ORight,OT);

    Result:=
        (N=4) And
        T24Near(OL,L) And
        T24Near(OB,B) And
        T24Near(ORight,R) And
        T24Near(OT,T);
End;

Procedure ApplyT24_All16_TransientCourtyards_ForMakeLib_v3;
Var Good;
Begin
    If Not T24Preflight Then Begin
        ShowMessage('ABORT: '+GError+'. Nothing changed.');
        Exit;
    End;

    GAdded:=0;
    Good:=True;

    PCBServer.PreProcess;
    Try
        T24ApplyOne('U_RTC','TOP');
        T24ApplyOne('Q_SD','TOP');
        T24ApplyOne('Q_OLED','TOP');
        T24ApplyOne('J_SWD','TOP');
        T24ApplyOne('J_SHIELD','TOP');
        T24ApplyOne('J_NAV','TOP');

        T24ApplyOne('D_EXT3','TOP');
        T24ApplyOne('D_EXT2','TOP');
        T24ApplyOne('D_EXT1','TOP');
        T24ApplyOne('D_ESD','TOP');
        T24ApplyOne('D_ESD1','TOP');
        T24ApplyOne('D_ESD2','TOP');

        T24ApplyOne('C_SENSOR_BULK','TOP');
        T24ApplyOne('C_SD_MID','TOP');
        T24ApplyOne('C_OLED_BULK','TOP');

        T24ApplyOne('J_SD','TOP');
    Finally
        PCBServer.PostProcess;
    End;

    GBoard.ViewManager_FullUpdate;

    If Not T24PostcheckOne('U_RTC') Then Good:=False;
    If Not T24PostcheckOne('Q_SD') Then Good:=False;
    If Not T24PostcheckOne('Q_OLED') Then Good:=False;
    If Not T24PostcheckOne('J_SWD') Then Good:=False;
    If Not T24PostcheckOne('J_SHIELD') Then Good:=False;
    If Not T24PostcheckOne('J_NAV') Then Good:=False;

    If Not T24PostcheckOne('D_EXT3') Then Good:=False;
    If Not T24PostcheckOne('D_EXT2') Then Good:=False;
    If Not T24PostcheckOne('D_EXT1') Then Good:=False;
    If Not T24PostcheckOne('D_ESD') Then Good:=False;
    If Not T24PostcheckOne('D_ESD1') Then Good:=False;
    If Not T24PostcheckOne('D_ESD2') Then Good:=False;

    If Not T24PostcheckOne('C_SENSOR_BULK') Then Good:=False;
    If Not T24PostcheckOne('C_SD_MID') Then Good:=False;
    If Not T24PostcheckOne('C_OLED_BULK') Then Good:=False;

    If Not T24PostcheckOne('J_SD') Then Good:=False;

    If (GAdded<>64) Or Not Good Then Begin
        ShowMessage(
            'POSTCHECK FAILED. DO NOT SAVE.'+#13#10+
            'Close the PCB without saving and report the result.'
        );
        Exit;
    End;

    If T24CountCovered<>129 Then Begin
        ShowMessage(
            'POSTCHECK FAILED: expected 129/129 courtyards.'+#13#10+
            'DO NOT SAVE. Close PCB without saving.'
        );
        Exit;
    End;

    ShowMessage(
        'PASS: 16 missing courtyards created IN MEMORY.'+#13#10+
        '129 / 129 components now have courtyard data.'+#13#10+
        'DO NOT SAVE OR REOPEN THIS PCB YET.'+#13#10+
        'NEXT: Design > Make PCB Library.'+#13#10+
        'Altium will generate a new PcbLib from this active PCB automatically.'
    );
End;
