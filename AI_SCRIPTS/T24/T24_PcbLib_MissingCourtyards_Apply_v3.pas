{ Datalogger RevA - T24
  Persistent PcbLib missing-courtyard repair v3
  SAFER LIBRARY MUTATION:
  - no LibraryIterator while mutating
  - each footprint is addressed directly by GetComponentByName
  - each footprint is made current by SetBoardToComponentByName
  - no SetState_LayersUsedArray / SetState_XSizeYSize calls
  - no Raise / exception flow

  Target: Datalogger_RevA_Clean.PcbLib
  Entry: ApplyT24_PcbLib_MissingCourtyards_v3

  Adds 4 x 0.05mm Mechanical-2 tracks to each of 8 source footprints.
  Boundary policy = audited PAD / Mechanical1 union itself.
  PCB Component Clearance remains the separate 10mil spacing control.
  J_SD uses PAD envelope fallback because no complete M1 body exists.

  Does NOT save the PcbLib and does NOT update any PCB document.
}

Var
    GLib;
    GBoard;
    GError;
    GAddedFootprints;
    GAddedTracks;

Function V3Near(A,B,Tol);
Begin
    Result:=Abs(A-B)<=Tol;
End;

Procedure V3Expected(Name; Var A; Var B);
Var U;
Begin
    U:=UpperCase(Name);
    A:=0;
    B:=0;

    If U='MAXIM_W16H2_SO16_90_0107' Then Begin A:=10.60; B:=11.45; End;
    If U='AOS_SOT23_AO3401A_3P' Then Begin A:=3.00; B:=3.30; End;
    If U='GOSUN_PLS_2P54_1X5_THT' Then Begin A:=2.64; B:=12.80; End;
    If U='WIRE_DRAIN_1P_D1P20_P2P40_THT' Then Begin A:=2.50; B:=2.50; End;
    If U='ATOM_MR01A_01245_10P' Then Begin A:=12.50; B:=16.80; End;
    If U='SHOUHAN_2P50_1X05_ZZMS_THT' Then Begin A:=5.90; B:=15.10; End;
    If U='ST_SOT23_6L_USBLC6_6P' Then Begin A:=2.60; B:=3.60; End;
    If U='MURATA_GRM21_0805_CAP_2P' Then Begin A:=1.35; B:=2.50; End;
End;

Procedure V3MeasureUnion(F; Var PadN; Var M1N; Var L; Var B; Var R; Var T);
Var GI; O; BR; UseIt; N;
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

Function V3CountCourtyard(F);
Var GI; O; N;
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

Function V3CheckOne(Name);
Var F; PadN; M1N; L; B; R; T;
    Wmm; Hmm; SmallV; LargeV; A; BExp;
Begin
    Result:=False;

    F:=GLib.GetComponentByName(Name);
    If F=Nil Then Begin
        GError:='Missing footprint: '+Name;
        Exit;
    End;

    If V3CountCourtyard(F)<>0 Then Begin
        GError:='Footprint already has M2/M4 courtyard: '+Name;
        Exit;
    End;

    V3MeasureUnion(F,PadN,M1N,L,B,R,T);
    If PadN<=0 Then Begin
        GError:='No measurable pad envelope: '+Name;
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

    V3Expected(Name,A,BExp);

    If A=0 Then Begin
        GError:='No expected tuple: '+Name;
        Exit;
    End;

    If Not V3Near(SmallV,A,0.12) Then Begin
        GError:='Envelope small dimension mismatch: '+Name;
        Exit;
    End;

    If Not V3Near(LargeV,BExp,0.12) Then Begin
        GError:='Envelope large dimension mismatch: '+Name;
        Exit;
    End;

    Result:=True;
End;

Function V3Preflight;
Begin
    Result:=False;
    GError:='';

    GLib:=PCBServer.GetCurrentPCBLibrary;
    If GLib=Nil Then Begin
        GError:='Active document is not a PCB library';
        Exit;
    End;

    GBoard:=GLib.Board;
    If GBoard=Nil Then Begin
        GError:='PcbLib board interface unavailable';
        Exit;
    End;

    If UpperCase(ExtractFileName(GBoard.FileName))
       <>'DATALOGGER_REVA_CLEAN.PCBLIB' Then Begin
        GError:='Activate Datalogger_RevA_Clean.PcbLib';
        Exit;
    End;

    If Not V3CheckOne('MAXIM_W16H2_SO16_90_0107') Then Exit;
    If Not V3CheckOne('AOS_SOT23_AO3401A_3P') Then Exit;
    If Not V3CheckOne('GOSUN_PLS_2P54_1X5_THT') Then Exit;
    If Not V3CheckOne('WIRE_DRAIN_1P_D1P20_P2P40_THT') Then Exit;
    If Not V3CheckOne('ATOM_MR01A_01245_10P') Then Exit;
    If Not V3CheckOne('SHOUHAN_2P50_1X05_ZZMS_THT') Then Exit;
    If Not V3CheckOne('ST_SOT23_6L_USBLC6_6P') Then Exit;
    If Not V3CheckOne('MURATA_GRM21_0805_CAP_2P') Then Exit;

    Result:=True;
End;

Function V3AddTrack(F,X1,Y1,X2,Y2,W);
Var P;
Begin
    Result:=False;

    P:=PCBServer.PCBObjectFactory(
        eTrackObject,
        eNoDimension,
        eCreate_Default
    );

    If P=Nil Then Begin
        GError:='Track factory failed';
        Exit;
    End;

    P.Layer:=eMechanical2;
    P.Width:=W;
    P.X1:=X1;
    P.Y1:=Y1;
    P.X2:=X2;
    P.Y2:=Y2;

    F.AddPCBObject(P);

    PCBServer.SendMessageToRobots(
        F.I_ObjectAddress,
        c_Broadcast,
        PCBM_BoardRegisteration,
        P.I_ObjectAddress
    );

    GAddedTracks:=GAddedTracks+1;
    Result:=True;
End;

Function V3ApplyOne(Name);
Var F; PadN; M1N; L; B; R; T; W; HW;
Begin
    Result:=False;

    If Not GLib.SetBoardToComponentByName(Name) Then Begin
        GError:='Cannot make footprint current: '+Name;
        Exit;
    End;

    F:=GLib.GetComponentByName(Name);
    If F=Nil Then Begin
        GError:='Cannot fetch current footprint: '+Name;
        Exit;
    End;

    V3MeasureUnion(F,PadN,M1N,L,B,R,T);
    If PadN<=0 Then Begin
        GError:='Envelope unavailable during Apply: '+Name;
        Exit;
    End;

    W:=MilsToCoord(1.968504);
    HW:=MilsToCoord(0.984252);

    PCBServer.PreProcess;

    If Not V3AddTrack(F,L+HW,B+HW,R-HW,B+HW,W) Then Begin
        PCBServer.PostProcess;
        Exit;
    End;

    If Not V3AddTrack(F,R-HW,B+HW,R-HW,T-HW,W) Then Begin
        PCBServer.PostProcess;
        Exit;
    End;

    If Not V3AddTrack(F,R-HW,T-HW,L+HW,T-HW,W) Then Begin
        PCBServer.PostProcess;
        Exit;
    End;

    If Not V3AddTrack(F,L+HW,T-HW,L+HW,B+HW,W) Then Begin
        PCBServer.PostProcess;
        Exit;
    End;

    PCBServer.PostProcess;

    If V3CountCourtyard(F)<>4 Then Begin
        GError:='Postcheck failed: '+Name;
        Exit;
    End;

    GAddedFootprints:=GAddedFootprints+1;
    Result:=True;
End;

Procedure ApplyT24_PcbLib_MissingCourtyards_v3;
Var FN; R;
Begin
    GAddedFootprints:=0;
    GAddedTracks:=0;

    If Not V3Preflight Then Begin
        ShowMessage('ABORT: '+GError+'. Nothing changed.');
        Exit;
    End;

    If Not V3ApplyOne('MAXIM_W16H2_SO16_90_0107') Then Begin
        ShowMessage('STOP: '+GError+'. DO NOT SAVE PCBLIB.');
        Exit;
    End;

    If Not V3ApplyOne('AOS_SOT23_AO3401A_3P') Then Begin
        ShowMessage('STOP: '+GError+'. DO NOT SAVE PCBLIB.');
        Exit;
    End;

    If Not V3ApplyOne('GOSUN_PLS_2P54_1X5_THT') Then Begin
        ShowMessage('STOP: '+GError+'. DO NOT SAVE PCBLIB.');
        Exit;
    End;

    If Not V3ApplyOne('WIRE_DRAIN_1P_D1P20_P2P40_THT') Then Begin
        ShowMessage('STOP: '+GError+'. DO NOT SAVE PCBLIB.');
        Exit;
    End;

    If Not V3ApplyOne('ATOM_MR01A_01245_10P') Then Begin
        ShowMessage('STOP: '+GError+'. DO NOT SAVE PCBLIB.');
        Exit;
    End;

    If Not V3ApplyOne('SHOUHAN_2P50_1X05_ZZMS_THT') Then Begin
        ShowMessage('STOP: '+GError+'. DO NOT SAVE PCBLIB.');
        Exit;
    End;

    If Not V3ApplyOne('ST_SOT23_6L_USBLC6_6P') Then Begin
        ShowMessage('STOP: '+GError+'. DO NOT SAVE PCBLIB.');
        Exit;
    End;

    If Not V3ApplyOne('MURATA_GRM21_0805_CAP_2P') Then Begin
        ShowMessage('STOP: '+GError+'. DO NOT SAVE PCBLIB.');
        Exit;
    End;

    If GAddedFootprints<>8 Then Begin
        ShowMessage('POSTCHECK FAILED: footprint count. DO NOT SAVE PCBLIB.');
        Exit;
    End;

    If GAddedTracks<>32 Then Begin
        ShowMessage('POSTCHECK FAILED: track count. DO NOT SAVE PCBLIB.');
        Exit;
    End;

    GBoard.ViewManager_FullUpdate;

    R:=TStringList.Create;
    R.Add('T24 PcbLib Missing Courtyards v3');
    R.Add('PASS');
    R.Add('Footprints modified: '+IntToStr(GAddedFootprints));
    R.Add('M2 tracks added: '+IntToStr(GAddedTracks));
    R.Add('No PCB document was modified.');
    R.Add('PcbLib is not auto-saved.');

    FN:=ExtractFilePath(GBoard.FileName)+
        'T24_PcbLib_MissingCourtyards_Apply_v3.txt';

    R.SaveToFile(FN);
    R.Free;

    ShowMessage(
        'PCBLIB REPAIR PASS.'+#13#10+
        '8 footprints / 32 Top Courtyard tracks added.'+#13#10+
        'SAVE the PcbLib now.'+#13#10+
        'Output: T24_PcbLib_MissingCourtyards_Apply_v3.txt'
    );
End;
