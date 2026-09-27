{ Datalogger RevA - T24
  SAFE CURRENT-FOOTPRINT Courtyard Repair v4

  This version intentionally follows the proven T23 mutation discipline:
    1) read-only preflight
    2) destroy iterators
    3) ONE simple PCBServer.PreProcess/PostProcess transaction
    4) PCBObjectFactory
    5) CurrentComponent.AddPCBObject
    6) PCBM_BoardRegisteration for each new primitive
    7) postcheck after transaction

  IMPORTANT:
  - Operates ONLY on the footprint currently displayed in Datalogger_RevA_Clean.PcbLib.
  - No LibraryIterator.
  - No SetBoardToComponentByName.
  - No GetComponentByName.
  - No SetState_LayersUsedArray / SetState_XSizeYSize.
  - No Raise / Except.
  - No PCB document is modified.
  - Does not save the PcbLib automatically.

  Run the SAME procedure once for each of these 8 footprints:
    MAXIM_W16H2_SO16_90_0107
    AOS_SOT23_AO3401A_3P
    GOSUN_PLS_2P54_1X5_THT
    WIRE_DRAIN_1P_D1P20_P2P40_THT
    ATOM_MR01A_01245_10P
    SHOUHAN_2P50_1X05_ZZMS_THT
    ST_SOT23_6L_USBLC6_6P
    MURATA_GRM21_0805_CAP_2P

  Entry:
    ApplyT24_CurrentFootprint_Courtyard_v4
}

Var
    V4Lib;
    V4Board;
    V4Footprint;
    V4Error;
    V4BuildOK;
    V4Added;

Function V4Near(A,B,Tol);
Begin
    Result:=Abs(A-B)<=Tol;
End;

Procedure V4Expected(Name; Var PadCount; Var M1Count; Var SmallMM; Var LargeMM);
Var U;
Begin
    U:=UpperCase(Name);
    PadCount:=-1;
    M1Count:=-1;
    SmallMM:=0;
    LargeMM:=0;

    If U='MAXIM_W16H2_SO16_90_0107' Then Begin
        PadCount:=16; M1Count:=4; SmallMM:=10.60; LargeMM:=11.45;
    End;

    If U='AOS_SOT23_AO3401A_3P' Then Begin
        PadCount:=3; M1Count:=6; SmallMM:=3.00; LargeMM:=3.30;
    End;

    If U='GOSUN_PLS_2P54_1X5_THT' Then Begin
        PadCount:=5; M1Count:=6; SmallMM:=2.64; LargeMM:=12.80;
    End;

    If U='WIRE_DRAIN_1P_D1P20_P2P40_THT' Then Begin
        PadCount:=1; M1Count:=0; SmallMM:=2.50; LargeMM:=2.50;
    End;

    If U='ATOM_MR01A_01245_10P' Then Begin
        PadCount:=15; M1Count:=0; SmallMM:=12.50; LargeMM:=16.80;
    End;

    If U='SHOUHAN_2P50_1X05_ZZMS_THT' Then Begin
        PadCount:=5; M1Count:=4; SmallMM:=5.90; LargeMM:=15.10;
    End;

    If U='ST_SOT23_6L_USBLC6_6P' Then Begin
        PadCount:=6; M1Count:=6; SmallMM:=2.60; LargeMM:=3.60;
    End;

    If U='MURATA_GRM21_0805_CAP_2P' Then Begin
        PadCount:=2; M1Count:=4; SmallMM:=1.35; LargeMM:=2.50;
    End;
End;

Procedure V4MeasureUnion(F; Var PadN; Var M1N; Var L; Var B; Var R; Var T);
Var
    GI;
    O;
    BR;
    UseIt;
    N;
Begin
    PadN:=0;
    M1N:=0;
    N:=0;
    L:=0;
    B:=0;
    R:=0;
    T:=0;

    GI:=F.GroupIterator_Create;
    If GI=Nil Then Begin
        PadN:=-1;
        Exit;
    End;

    GI.SetState_FilterAll;

    O:=GI.FirstPCBObject;
    While O<>Nil Do Begin
        UseIt:=False;

        If O.ObjectId=ePadObject Then Begin
            UseIt:=True;
            PadN:=PadN+1;
        End;

        If (O.Layer=eMechanical1) And
           (O.ObjectId<>eTextObject) Then Begin
            UseIt:=True;
            M1N:=M1N+1;
        End;

        If UseIt Then Begin
            BR:=O.BoundingRectangle;

            If N=0 Then Begin
                L:=BR.Left;
                B:=BR.Bottom;
                R:=BR.Right;
                T:=BR.Top;
            End
            Else Begin
                If BR.Left<L Then L:=BR.Left;
                If BR.Bottom<B Then B:=BR.Bottom;
                If BR.Right>R Then R:=BR.Right;
                If BR.Top>T Then T:=BR.Top;
            End;

            N:=N+1;
        End;

        O:=GI.NextPCBObject;
    End;

    F.GroupIterator_Destroy(GI);

    If N=0 Then PadN:=-1;
End;

Function V4CountCourtyard(F);
Var
    GI;
    O;
    N;
Begin
    N:=0;

    GI:=F.GroupIterator_Create;
    If GI=Nil Then Begin
        Result:=-1;
        Exit;
    End;

    GI.AddFilter_ObjectSet(
        MkSet(eTrackObject,eArcObject,eFillObject,eRegionObject)
    );
    GI.AddFilter_LayerSet(
        MkSet(eMechanical2,eMechanical4)
    );

    O:=GI.FirstPCBObject;
    While O<>Nil Do Begin
        N:=N+1;
        O:=GI.NextPCBObject;
    End;

    F.GroupIterator_Destroy(GI);
    Result:=N;
End;

Function V4Preflight(Var L; Var B; Var R; Var T);
Var
    PadN;
    M1N;
    ExpPadN;
    ExpM1N;
    ExpSmall;
    ExpLarge;
    Wmm;
    Hmm;
    SmallV;
    LargeV;
Begin
    Result:=False;
    V4Error:='';

    V4Lib:=PCBServer.GetCurrentPCBLibrary;
    If V4Lib=Nil Then Begin
        V4Error:='Active document is not a PcbLib';
        Exit;
    End;

    V4Board:=PCBServer.GetCurrentPCBBoard;
    If V4Board=Nil Then Begin
        V4Error:='Current PCB/PcbLib board interface unavailable';
        Exit;
    End;

    If Not V4Board.IsLibrary Then Begin
        V4Error:='Active document is not a PCB library';
        Exit;
    End;

    If UpperCase(ExtractFileName(V4Board.FileName))
       <>'DATALOGGER_REVA_CLEAN.PCBLIB' Then Begin
        V4Error:='Activate Datalogger_RevA_Clean.PcbLib';
        Exit;
    End;

    V4Footprint:=V4Lib.CurrentComponent;
    If V4Footprint=Nil Then Begin
        V4Error:='No current footprint selected';
        Exit;
    End;

    V4Expected(
        V4Footprint.Name,
        ExpPadN,
        ExpM1N,
        ExpSmall,
        ExpLarge
    );

    If ExpPadN<0 Then Begin
        V4Error:='Current footprint is not one of the 8 T24 targets: '+V4Footprint.Name;
        Exit;
    End;

    If V4CountCourtyard(V4Footprint)<>0 Then Begin
        V4Error:='Current footprint already has M2/M4 courtyard: '+V4Footprint.Name;
        Exit;
    End;

    V4MeasureUnion(
        V4Footprint,
        PadN,
        M1N,
        L,
        B,
        R,
        T
    );

    If PadN<>ExpPadN Then Begin
        V4Error:='Pad count mismatch on '+V4Footprint.Name+
                 ': got '+IntToStr(PadN)+
                 ', expected '+IntToStr(ExpPadN);
        Exit;
    End;

    If M1N<>ExpM1N Then Begin
        V4Error:='Mechanical1 count mismatch on '+V4Footprint.Name+
                 ': got '+IntToStr(M1N)+
                 ', expected '+IntToStr(ExpM1N);
        Exit;
    End;

    Wmm:=CoordToMMs(R-L);
    Hmm:=CoordToMMs(T-B);

    If Wmm<Hmm Then Begin
        SmallV:=Wmm;
        LargeV:=Hmm;
    End
    Else Begin
        SmallV:=Hmm;
        LargeV:=Wmm;
    End;

    If Not V4Near(SmallV,ExpSmall,0.12) Then Begin
        V4Error:='Small envelope mismatch on '+V4Footprint.Name+
                 ': got '+FloatToStr(SmallV)+
                 ' mm, expected '+FloatToStr(ExpSmall)+' mm';
        Exit;
    End;

    If Not V4Near(LargeV,ExpLarge,0.12) Then Begin
        V4Error:='Large envelope mismatch on '+V4Footprint.Name+
                 ': got '+FloatToStr(LargeV)+
                 ' mm, expected '+FloatToStr(ExpLarge)+' mm';
        Exit;
    End;

    Result:=True;
End;

Procedure V4AddTrack(X1,Y1,X2,Y2,W);
Var
    P;
Begin
    If Not V4BuildOK Then Exit;

    P:=PCBServer.PCBObjectFactory(
        eTrackObject,
        eNoDimension,
        eCreate_Default
    );

    If P=Nil Then Begin
        V4BuildOK:=False;
        V4Error:='Track factory failed';
        Exit;
    End;

    P.X1:=X1;
    P.Y1:=Y1;
    P.X2:=X2;
    P.Y2:=Y2;
    P.Width:=W;
    P.Layer:=eMechanical2;

    V4Footprint.AddPCBObject(P);

    PCBServer.SendMessageToRobots(
        V4Footprint.I_ObjectAddress,
        c_Broadcast,
        PCBM_BoardRegisteration,
        P.I_ObjectAddress
    );

    V4Added:=V4Added+1;
End;

Procedure ApplyT24_CurrentFootprint_Courtyard_v4;
Var
    L;
    B;
    R;
    T;
    W;
    HW;
    AfterCount;
Begin
    If Not V4Preflight(L,B,R,T) Then Begin
        ShowMessage('ABORT: '+V4Error+'. Nothing changed.');
        Exit;
    End;

    V4BuildOK:=True;
    V4Added:=0;

    W:=MilsToCoord(1.968504);
    HW:=MilsToCoord(0.984252);

    PCBServer.PreProcess;
    Try
        V4AddTrack(L+HW,B+HW,R-HW,B+HW,W);
        V4AddTrack(R-HW,B+HW,R-HW,T-HW,W);
        V4AddTrack(R-HW,T-HW,L+HW,T-HW,W);
        V4AddTrack(L+HW,T-HW,L+HW,B+HW,W);
    Finally
        PCBServer.PostProcess;
    End;

    If Not V4BuildOK Then Begin
        ShowMessage(
            'BUILD INCOMPLETE: '+V4Error+#13#10+
            'Do not save. One Ctrl+Z should roll back this transaction.'
        );
        Exit;
    End;

    AfterCount:=V4CountCourtyard(V4Footprint);

    If (V4Added<>4) Or (AfterCount<>4) Then Begin
        ShowMessage(
            'POSTCHECK FAILED on '+V4Footprint.Name+#13#10+
            'Added='+IntToStr(V4Added)+
            ', courtyard primitives='+IntToStr(AfterCount)+#13#10+
            'Do not save. One Ctrl+Z should roll back.'
        );
        Exit;
    End;

    V4Board.ViewManager_FullUpdate;

    ShowMessage(
        'PASS: '+V4Footprint.Name+#13#10+
        '4 Top Courtyard tracks added with the proven T23 transaction pattern.'+#13#10+
        'SAVE the PcbLib now, then select the next target footprint and run this SAME procedure again.'
    );
End;
