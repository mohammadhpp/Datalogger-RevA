{ Datalogger RevA - T24
  Persistent missing-courtyard repair in PcbLib v2

  PURPOSE
  - Fix the root problem: add courtyard primitives to the SOURCE footprint library,
    not transiently to placed PCB component groups.
  - Target library: Datalogger_RevA_Clean.PcbLib
  - Target footprints: 8 unique footprints covering the 16 missing board instances.
  - Geometry policy follows the previously approved T24 controlled strategy:
      boundary = PAD / Mechanical1 union itself
      line width = 0.05 mm
      track centerlines inset by half line width
    The board-level Component Clearance rule supplies the separate 10 mil spacing.
  - J_SD / ATOM_MR01A_01245_10P uses the known pad envelope because its current
    footprint has no complete Mechanical1 body outline; this is explicitly documented
    as an engineering fallback, not a manufacturer-certified IPC courtyard.

  SAFETY
  - One entry point, internal preflight before any mutation.
  - Aborts unless all 8 footprints are present and have no existing M2/M4 courtyard.
  - Validates each measured PAD/M1 envelope size against the audited board geometry.
  - Adds exactly 4 tracks per footprint on Mechanical 2.
  - Rebuilds LayersUsed and footprint X/Y size state.
  - Does NOT alter pads, silk, copper, routing, rules, 3D bodies, or PCB documents.
  - Does NOT auto-save the library.

  ENTRY:
    ApplyT24_PcbLib_MissingCourtyards_v2
}

Var
    GLib;
    GBoard;
    GError;
    GReport;
    GAddedFootprints;
    GAddedTracks;

Function PCNear(A,B,Tol);
Begin
    Result:=Abs(A-B)<=Tol;
End;

Function PCIsTarget(Name);
Var U;
Begin
    U:=UpperCase(Name);
    Result:=
        (U='MAXIM_W16H2_SO16_90_0107') Or
        (U='AOS_SOT23_AO3401A_3P') Or
        (U='GOSUN_PLS_2P54_1X5_THT') Or
        (U='WIRE_DRAIN_1P_D1P20_P2P40_THT') Or
        (U='ATOM_MR01A_01245_10P') Or
        (U='SHOUHAN_2P50_1X05_ZZMS_THT') Or
        (U='ST_SOT23_6L_USBLC6_6P') Or
        (U='MURATA_GRM21_0805_CAP_2P');
End;

Procedure PCExpectedSortedMM(Name; Var A; Var B);
Var U;
Begin
    U:=UpperCase(Name);
    A:=0; B:=0;

    If U='MAXIM_W16H2_SO16_90_0107' Then Begin A:=10.60; B:=11.45; End
    Else If U='AOS_SOT23_AO3401A_3P' Then Begin A:=3.00; B:=3.30; End
    Else If U='GOSUN_PLS_2P54_1X5_THT' Then Begin A:=2.64; B:=12.80; End
    Else If U='WIRE_DRAIN_1P_D1P20_P2P40_THT' Then Begin A:=2.50; B:=2.50; End
    Else If U='ATOM_MR01A_01245_10P' Then Begin A:=12.50; B:=16.80; End
    Else If U='SHOUHAN_2P50_1X05_ZZMS_THT' Then Begin A:=5.90; B:=15.10; End
    Else If U='ST_SOT23_6L_USBLC6_6P' Then Begin A:=2.60; B:=3.60; End
    Else If U='MURATA_GRM21_0805_CAP_2P' Then Begin A:=1.35; B:=2.50; End;
End;

Procedure PCMeasureUnion(F; Var PadN; Var M1N; Var L; Var B; Var R; Var T);
Var GI; O; BR; UseIt; N;
Begin
    PadN:=0;
    M1N:=0;
    N:=0;
    L:=0; B:=0; R:=0; T:=0;

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
        End
        Else If (O.Layer=eMechanical1) And
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
            End Else Begin
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

Function PCCountCourtyard(F);
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

Function PCEnvelopeMatches(F);
Var PadN; M1N; L; B; R; T;
    Wmm; Hmm; A; BExp; SmallV; LargeV;
Begin
    Result:=False;

    PCMeasureUnion(F,PadN,M1N,L,B,R,T);

    If PadN<=0 Then Begin
        GError:='No measurable pad envelope: '+F.Name;
        Exit;
    End;

    Wmm:=CoordToMMs(R-L);
    Hmm:=CoordToMMs(T-B);

    If Wmm<Hmm Then Begin
        SmallV:=Wmm;
        LargeV:=Hmm;
    End Else Begin
        SmallV:=Hmm;
        LargeV:=Wmm;
    End;

    PCExpectedSortedMM(F.Name,A,BExp);

    If (A=0) Or (BExp=0) Then Begin
        GError:='No expected envelope tuple: '+F.Name;
        Exit;
    End;

    { 0.12 mm tolerance is intentional: library primitive stroke rounding and
      old footprint line widths can move the measured outer envelope slightly. }
    If Not PCNear(SmallV,A,0.12) Or
       Not PCNear(LargeV,BExp,0.12) Then Begin
        GError:=
            'Envelope mismatch '+F.Name+
            ' measured(sorted)='+FloatToStr(SmallV)+' / '+FloatToStr(LargeV)+
            ' mm expected='+FloatToStr(A)+' / '+FloatToStr(BExp)+' mm';
        Exit;
    End;

    Result:=True;
End;

Function PCPreflight;
Var LI; F; Found;
    F1;F2;F3;F4;F5;F6;F7;F8;
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
        GError:='PCB library board interface unavailable';
        Exit;
    End;

    If UpperCase(ExtractFileName(GBoard.FileName))
       <>'DATALOGGER_REVA_CLEAN.PCBLIB' Then Begin
        GError:='Activate Datalogger_RevA_Clean.PcbLib';
        Exit;
    End;

    Found:=0;
    F1:=False; F2:=False; F3:=False; F4:=False;
    F5:=False; F6:=False; F7:=False; F8:=False;

    LI:=GLib.LibraryIterator_Create;
    If LI=Nil Then Begin
        GError:='Library iterator unavailable';
        Exit;
    End;

    LI.SetState_FilterAll;

    F:=LI.FirstPCBObject;
    While F<>Nil Do Begin
        If PCIsTarget(F.Name) Then Begin
            Found:=Found+1;

            If PCCountCourtyard(F)<>0 Then Begin
                GError:='Existing M2/M4 courtyard already present in '+F.Name;
                GLib.LibraryIterator_Destroy(LI);
                Exit;
            End;

            If Not PCEnvelopeMatches(F) Then Begin
                GLib.LibraryIterator_Destroy(LI);
                Exit;
            End;

            If UpperCase(F.Name)='MAXIM_W16H2_SO16_90_0107' Then F1:=True;
            If UpperCase(F.Name)='AOS_SOT23_AO3401A_3P' Then F2:=True;
            If UpperCase(F.Name)='GOSUN_PLS_2P54_1X5_THT' Then F3:=True;
            If UpperCase(F.Name)='WIRE_DRAIN_1P_D1P20_P2P40_THT' Then F4:=True;
            If UpperCase(F.Name)='ATOM_MR01A_01245_10P' Then F5:=True;
            If UpperCase(F.Name)='SHOUHAN_2P50_1X05_ZZMS_THT' Then F6:=True;
            If UpperCase(F.Name)='ST_SOT23_6L_USBLC6_6P' Then F7:=True;
            If UpperCase(F.Name)='MURATA_GRM21_0805_CAP_2P' Then F8:=True;
        End;

        F:=LI.NextPCBObject;
    End;

    GLib.LibraryIterator_Destroy(LI);

    If Found<>8 Then Begin
        GError:='Expected 8 target footprints; found '+IntToStr(Found);
        Exit;
    End;

    If Not (F1 And F2 And F3 And F4 And F5 And F6 And F7 And F8) Then Begin
        GError:='One or more expected target footprint names are missing';
        Exit;
    End;

    Result:=True;
End;

Procedure PCAddTrack(F,X1,Y1,X2,Y2,W);
Var P;
Begin
    P:=PCBServer.PCBObjectFactory(
        eTrackObject,
        eNoDimension,
        eCreate_Default
    );

    If P=Nil Then Begin Raise('Track factory failed'); End;

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
End;

Procedure PCApplyOne(F);
Var PadN; M1N; L; B; R; T;
    W; HW;
Begin
    PCMeasureUnion(F,PadN,M1N,L,B,R,T);

    If PadN<=0 Then Begin Raise('Envelope missing: '+F.Name); End;

    W:=MilsToCoord(1.968504);
    HW:=MilsToCoord(0.984252);

    If (R-L)<=W Then Begin Raise('Envelope too small in X: '+F.Name); End;
    If (T-B)<=W Then Begin Raise('Envelope too small in Y: '+F.Name); End;

    PCBServer.SendMessageToRobots(
        F.I_ObjectAddress,
        c_Broadcast,
        PCBM_BeginModify,
        c_NoEventData
    );

    Try
        { Inset centerlines by half track width so the OUTER track bounds
          equal the audited PAD/M1 union envelope exactly. }
        PCAddTrack(F,L+HW,B+HW,R-HW,B+HW,W);
        PCAddTrack(F,R-HW,B+HW,R-HW,T-HW,W);
        PCAddTrack(F,R-HW,T-HW,L+HW,T-HW,W);
        PCAddTrack(F,L+HW,T-HW,L+HW,B+HW,W);

        F.SetState_LayersUsedArray;
        F.SetState_XSizeYSize;
    Finally
        PCBServer.SendMessageToRobots(
            F.I_ObjectAddress,
            c_Broadcast,
            PCBM_EndModify,
            c_NoEventData
        );
    End;

    GAddedFootprints:=GAddedFootprints+1;
End;

Function PCPostcheck;
Var LI; F; Seen; Bad;
Begin
    Result:=False;
    Seen:=0;
    Bad:=0;

    LI:=GLib.LibraryIterator_Create;
    If LI=Nil Then Exit;

    LI.SetState_FilterAll;

    F:=LI.FirstPCBObject;
    While F<>Nil Do Begin
        If PCIsTarget(F.Name) Then Begin
            Seen:=Seen+1;
            If PCCountCourtyard(F)<>4 Then Bad:=Bad+1;
        End;

        F:=LI.NextPCBObject;
    End;

    GLib.LibraryIterator_Destroy(LI);

    Result:=(Seen=8) And (Bad=0);
End;

Procedure PCWriteReport(StatusText);
Var FN;
Begin
    If GReport=Nil Then Exit;

    GReport.Add('Datalogger RevA - T24 Persistent PcbLib Courtyard Repair v1');
    GReport.Add('Status: '+StatusText);
    GReport.Add('Library: '+GBoard.FileName);
    GReport.Add('');
    GReport.Add('Policy: PAD/Mechanical1 union boundary; 0.05 mm M2 track.');
    GReport.Add('Board Component Clearance remains the separate 10 mil spacing rule.');
    GReport.Add('J_SD fallback: PAD envelope because complete body drawing is not present in current footprint.');
    GReport.Add('');
    GReport.Add('Target footprints: 8');
    GReport.Add('Expected placed PCB instances fixed after library update: 16');
    GReport.Add('Footprints modified: '+IntToStr(GAddedFootprints));
    GReport.Add('Courtyard tracks added: '+IntToStr(GAddedTracks));
    GReport.Add('');
    GReport.Add('IMPORTANT: this script does not save the library and does not update the PCB.');

    FN:=ExtractFilePath(GBoard.FileName)+
        'T24_PcbLib_MissingCourtyards_Apply_v2.txt';

    GReport.SaveToFile(FN);
End;

Procedure ApplyT24_PcbLib_MissingCourtyards_v1;
Var LI; F;
Begin
    GAddedFootprints:=0;
    GAddedTracks:=0;

    If Not PCPreflight Then Begin
        ShowMessage('ABORT: '+GError+'. Nothing changed.');
        Exit;
    End;

    GReport:=TStringList.Create;

    Try
        PCBServer.PreProcess;
        Try
            LI:=GLib.LibraryIterator_Create;
            If LI=Nil Then Raise('Library iterator unavailable during Apply');

            LI.SetState_FilterAll;

            F:=LI.FirstPCBObject;
            While F<>Nil Do Begin
                If PCIsTarget(F.Name) Then
                    PCApplyOne(F);

                F:=LI.NextPCBObject;
            End;

            GLib.LibraryIterator_Destroy(LI);
        Finally
            PCBServer.PostProcess;
        End;

        GBoard.ViewManager_FullUpdate;

        If (GAddedFootprints<>8) Or
           (GAddedTracks<>32) Or
           Not PCPostcheck Then Begin
            PCWriteReport('POSTCHECK FAILED');
            ShowMessage(
                'POSTCHECK FAILED. DO NOT SAVE THE PCBLIB.'+#13#10+
                'Use Ctrl+Z once.'+#13#10+
                'Footprints modified='+IntToStr(GAddedFootprints)+
                ' / tracks='+IntToStr(GAddedTracks)
            );
            Exit;
        End;

        PCWriteReport('PASS');

        ShowMessage(
            'PCBLIB COURTYARD REPAIR PASS.'+#13#10+
            '8 footprints / 32 M2 tracks added persistently.'+#13#10+
            'Now SAVE Datalogger_RevA_Clean.PcbLib.'+#13#10+
            'Then use Tools > Update PCB With All Footprints,'+#13#10+
            'updating Mechanical-layer primitives only.'+#13#10+
            'Output: T24_PcbLib_MissingCourtyards_Apply_v1.txt'
        );
    Finally
        GReport.Free;
    End;
End;
