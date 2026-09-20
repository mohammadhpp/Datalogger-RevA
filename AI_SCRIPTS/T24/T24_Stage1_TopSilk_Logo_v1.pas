{==============================================================================
 Datalogger RevA - T24 Stage1
 TOP SILK BRANDING LOGO v1

 Entry point:
   ApplyT24_Stage1_TopSilk_Logo_v1

 Purpose:
   Place the approved chibi portrait logo plus:
     SANAT NEGAR
     M.PAHLAVIAN
   as monochrome Top Overlay artwork in the user-selected empty zone.

 Authoritative PCB baseline:
   Clean post-T23 board.
   Final T23 routing baseline:
     GND tracks = 117
     GND vias   = 46
     polygons   = 1
   Final user-verified DRC before logo:
     Warnings = 0
     Rule Violations = 0

 Artwork:
   Embedded 120 x 115 monochrome bitmap.
   Implemented as horizontal Top Overlay fill runs.
   No external image/font dependency at runtime.

 Placement:
   X = 4910 .. 5390 mil
   Y = 4360 .. 4820 mil
   Center approx = 5150,4590 mil
   Physical size = 480 x 460 mil
                 = 12.192 x 11.684 mm
   Raster cell   = 4 x 4 mil

 Snapshot audit before creation found this zone free of visible
 Top Overlay text/tracks/arcs/fills. Hidden schematic text is irrelevant.

 Safety:
   - refuses to run unless final T23 GND/polygon counts still match
   - refuses to run if any visible Top Overlay object already occupies
     the logo rectangle
   - refuses to rerun after logo placement
   - does NOT touch copper, nets, routing, vias, pads, polygon, or components
   - does NOT save the PCB
   - one Altium transaction; if build incomplete, do NOT save and Ctrl+Z

 After apply:
   Run FULL DRC. Since this is silk-only in a pad/via-free zone,
   copper connectivity must remain unchanged.
==============================================================================}

Var
    GBoard;
    GRow : Array[0..114] Of String;
    GAddedFills;
    GBuildOK;

Const
    C_W = 120;
    C_H = 115;
    C_CELL = 4.0;
    C_X0 = 4910.0;
    C_Y0 = 4360.0;
    C_X1 = 5390.0;
    C_Y1 = 4820.0;
    C_EXPECTED_FILLS = 964;

Procedure InitBitmap;
Begin
    GRow[0] := '000000000000000000000000000000';
    GRow[1] := '000000000000000003F00000000000';
    GRow[2] := '000000000000000187F80000000000';
    GRow[3] := '00000000000001FFFE0C0000000000';
    GRow[4] := '0000000000003FF83FEC0000000000';
    GRow[5] := '000000000001FC0063FE0000000000';
    GRow[6] := '00000000000FC001803FC000000000';
    GRow[7] := '00000000007F00030001F000000000';
    GRow[8] := '0000000001FC000600007C00000000';
    GRow[9] := '0000000007B8000C00002F00000000';
    GRow[10] := '000000001E60001800001380000000';
    GRow[11] := '0000000038800010000009C0000000';
    GRow[12] := '00000000F100003000000CE0000000';
    GRow[13] := '00000001C2000020000006F0000000';
    GRow[14] := '00000003A400000000000278000000';
    GRow[15] := '00000007400000000000012C000000';
    GRow[16] := '0000000680000000000001A6000000';
    GRow[17] := '0000000D040780C000000093000000';
    GRow[18] := '0000001B0C0F80C0000000D3800000';
    GRow[19] := '0000001A1E181C8000C00059C00000';
    GRow[20] := '000000343F303EB6FCC20048C00000';
    GRow[21] := '000000607FB066B6FEE20028600000';
    GRow[22] := '00000068F7B067A7B6F2000C700000';
    GRow[23] := '00000068FF1BFDBFB79EE024300000';
    GRow[24] := '000000D07E1F3DBFB79EF024180000';
    GRow[25] := '000000D03E00000037FEF0141C0000';
    GRow[26] := '000000901C00000000F7F0161C0000';
    GRow[27] := '000001B0080000000005F0160E0000';
    GRow[28] := '000001A003FFFFFE0000F0120E0000';
    GRow[29] := '000001A0FFFF803FF0001012070000';
    GRow[30] := '000001BFFFFFFE007F000012070000';
    GRow[31] := '000003FE000003F007E00012078000';
    GRow[32] := '00000FE07FFFF01F00F80012078000';
    GRow[33] := '00003E0FFFFFFFC1E01F0012038000';
    GRow[34] := '0001F0FFBFFFFFFC3C03C012038000';
    GRow[35] := '0007C7C1FFFFFFFFC780F01202C000';
    GRow[36] := '000E3E1FFFFFFDFFF8E03C1202C000';
    GRow[37] := '0038E03FFFFFFBEF3F1C0F1203C000';
    GRow[38] := '0073937FFFF7E3EE07C2039203C000';
    GRow[39] := '00CEC0FFFFE7C7DC00F868F2034000';
    GRow[40] := '019803FFFFEF87FC001F07F0034000';
    GRow[41] := '033227FFFFCF0F780003F81C014000';
    GRow[42] := '03603FFBEE8F0E3003FE7FFE016000';
    GRow[43] := '03C21FF7CD860C600FFF87FF016000';
    GRow[44] := '03107FFFDD040C003FFFC7FFC3E000';
    GRow[45] := '0388FFFF990008007E0003FFE3C000';
    GRow[46] := '01C3FFFF9BFC0000F80003FFF1FE00';
    GRow[47] := '00FFFBFF0FFE0000C00001FFF9FC00';
    GRow[48] := '003FFFFF1FFF0000001F01BFFFF800';
    GRow[49] := '00007FFF3E0780000FFFFC3F7EF000';
    GRow[50] := '00007FFE70000000FFF80E3F7FF800';
    GRow[51] := '0001FFFE40000003E3FE031F7FFC00';
    GRow[52] := '000FFFFE03FFE00707FF037FFFFE00';
    GRow[53] := '000C3FF63FFE70040FE783FFFFFF80';
    GRow[54] := '00007FF3F1FF300407E7C3FFFFF000';
    GRow[55] := '0000FFF787FF93FC07E7431FFFF800';
    GRow[56] := '0000FFFC0DF31FFC0FFF631FFBFC00';
    GRow[57] := '0001FFFC19F39C0E07FF230FE0FC00';
    GRow[58] := '0001DFFC13FF980707FF2307E07600';
    GRow[59] := '00019FFC33FF980707FE230FC03200';
    GRow[60] := '00001FDC23FF980783FE030F803000';
    GRow[61] := '00003FFC23FF900281FC030F8E3800';
    GRow[62] := '00007FFC21FF300300F00E0F3B1800';
    GRow[63] := '00007FEC20FE30030003FC0E619800';
    GRow[64] := '00001FEE007C3001FFFFC01E401800';
    GRow[65] := '000016760000E2007FC0001CC03800';
    GRow[66] := '0000063F000FC6000002D004603800';
    GRow[67] := '00000C3B03FE040000049604303800';
    GRow[68] := '00000C19FFC00400000D2404303800';
    GRow[69] := '00000C1800000600001B6C0C307800';
    GRow[70] := '00000C3C080003000012481C607800';
    GRow[71] := '00000C3C5A80000000004019C0D800';
    GRow[72] := '0000041C948000000C00000C01D800';
    GRow[73] := '0000060CA58000000600003803C000';
    GRow[74] := '0000060C690000002300003007C000';
    GRow[75] := '0000030C48006000600000180F8000';
    GRow[76] := '0000038C0000C000E000007C7F8000';
    GRow[77] := '000001CE000096078000017FFD8000';
    GRow[78] := '0000007C000017FE020001FFF90000';
    GRow[79] := '0000001E000001F0030006FFF80000';
    GRow[80] := '0000000F0000000001002BFFB00000';
    GRow[81] := '000000072000000000102BFFE00000';
    GRow[82] := '0000000740004040001227E1E00000';
    GRow[83] := '00000003C800C080021B1FC0F00000';
    GRow[84] := '00000001D220808013093F0FF80000';
    GRow[85] := '000000000000000000000000000000';
    GRow[86] := '000000000000000000000000000000';
    GRow[87] := '000000000000000000000000000000';
    GRow[88] := '000000000000000000000000000000';
    GRow[89] := '000000000000000000000000000000';
    GRow[90] := '000000000000000000000000000000';
    GRow[91] := '000000000000000000000000000000';
    GRow[92] := '000000000000000000000000000000';
    GRow[93] := '003F0F0E3879FF038E7F0FC3C3F800';
    GRow[94] := '00730F0F38783803CE701C43C39800';
    GRow[95] := '00601F8F38FC3803CE703807E39C00';
    GRow[96] := '007C1F8FB8FC3803EE703007E39C00';
    GRow[97] := '007F198FF8CC3803FE7F71E6639800';
    GRow[98] := '001F39CEF9CE3803BE7030EE73F000';
    GRow[99] := '0003BFCEF9FE3803BE7038EFF3B800';
    GRow[100] := '006370EE7B8738039E701CFC3B9C00';
    GRow[101] := '007E70EE3B8738038E7F0FFC3B8E00';
    GRow[102] := '000000000000000000000000000000';
    GRow[103] := '000000000000000000000000000000';
    GRow[104] := '000000000000000000000000000000';
    GRow[105] := '000000000000000000000000000000';
    GRow[106] := '000000C70786211019850631000000';
    GRow[107] := '000000C7044E211039850E39000000';
    GRow[108] := '000000E7044A2110288D0A39000000';
    GRow[109] := '000000AB04493F1024C9092D000000';
    GRow[110] := '000000BB07D9211064591925000000';
    GRow[111] := '0000009B041FA1107E511FA7000000';
    GRow[112] := '000000830430A110C27130A3000000';
    GRow[113] := '000000834430A11FC23130A3000000';
    GRow[114] := '000000000000000000000000000000';
End;

Function SameNetName(O,NetName);
Begin
    Result:=False;
    If O=Nil Then Exit;
    If O.Net=Nil Then Exit;
    Result:=UpperCase(O.Net.Name)=UpperCase(NetName);
End;

Function CountTracks(NetName);
Var BI;T;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then
    Begin
        Result:=-1;
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(eTrackObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    T:=BI.FirstPCBObject;
    While T<>Nil Do
    Begin
        If SameNetName(T,NetName) Then N:=N+1;
        T:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountVias(NetName);
Var BI;V;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then
    Begin
        Result:=-1;
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(eViaObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    V:=BI.FirstPCBObject;
    While V<>Nil Do
    Begin
        If SameNetName(V,NetName) Then N:=N+1;
        V:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function CountPolygons;
Var BI;P;N;
Begin
    N:=0;
    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then
    Begin
        Result:=-1;
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(ePolyObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    P:=BI.FirstPCBObject;
    While P<>Nil Do
    Begin
        N:=N+1;
        P:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
    Result:=N;
End;

Function RectOverlap(BR);
Var L;R;B;T;
Begin
    L:=CoordToMils(BR.Left);
    R:=CoordToMils(BR.Right);
    B:=CoordToMils(BR.Bottom);
    T:=CoordToMils(BR.Top);

    Result:=
      Not (
        (R<=C_X0) Or
        (L>=C_X1) Or
        (T<=C_Y0) Or
        (B>=C_Y1)
      );
End;

Function VisibleOverlayZoneFree;
Var BI;O;
Begin
    Result:=False;

    { Top Overlay tracks }
    BI:=GBoard.BoardIterator_Create;
    BI.AddFilter_ObjectSet(MkSet(eTrackObject));
    BI.AddFilter_LayerSet(MkSet(eTopOverlay));
    BI.AddFilter_Method(eProcessAll);

    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If RectOverlap(O.BoundingRectangle) Then
        Begin
            GBoard.BoardIterator_Destroy(BI);
            Exit;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);

    { Top Overlay arcs }
    BI:=GBoard.BoardIterator_Create;
    BI.AddFilter_ObjectSet(MkSet(eArcObject));
    BI.AddFilter_LayerSet(MkSet(eTopOverlay));
    BI.AddFilter_Method(eProcessAll);

    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If RectOverlap(O.BoundingRectangle) Then
        Begin
            GBoard.BoardIterator_Destroy(BI);
            Exit;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);

    { Top Overlay fills - also serves as rerun guard }
    BI:=GBoard.BoardIterator_Create;
    BI.AddFilter_ObjectSet(MkSet(eFillObject));
    BI.AddFilter_LayerSet(MkSet(eTopOverlay));
    BI.AddFilter_Method(eProcessAll);

    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If RectOverlap(O.BoundingRectangle) Then
        Begin
            GBoard.BoardIterator_Destroy(BI);
            Exit;
        End;
        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);

    { Visible Top Overlay text; hidden schematic comments are ignored. }
    BI:=GBoard.BoardIterator_Create;
    BI.AddFilter_ObjectSet(MkSet(eTextObject));
    BI.AddFilter_LayerSet(MkSet(eTopOverlay));
    BI.AddFilter_Method(eProcessAll);

    O:=BI.FirstPCBObject;
    While O<>Nil Do
    Begin
        If Not O.IsHidden Then
            If RectOverlap(O.BoundingRectangle) Then
            Begin
                GBoard.BoardIterator_Destroy(BI);
                Exit;
            End;

        O:=BI.NextPCBObject;
    End;
    GBoard.BoardIterator_Destroy(BI);

    Result:=True;
End;

Function HexValue(S);
Begin
    Result:=0;

    If S='0' Then Result:=0
    Else If S='1' Then Result:=1
    Else If S='2' Then Result:=2
    Else If S='3' Then Result:=3
    Else If S='4' Then Result:=4
    Else If S='5' Then Result:=5
    Else If S='6' Then Result:=6
    Else If S='7' Then Result:=7
    Else If S='8' Then Result:=8
    Else If S='9' Then Result:=9
    Else If UpperCase(S)='A' Then Result:=10
    Else If UpperCase(S)='B' Then Result:=11
    Else If UpperCase(S)='C' Then Result:=12
    Else If UpperCase(S)='D' Then Result:=13
    Else If UpperCase(S)='E' Then Result:=14
    Else If UpperCase(S)='F' Then Result:=15;
End;

Function PixelOn(X,Y);
Var NibbleIndex;BitIndex;V;Divisor;Ch;
Begin
    Result:=False;

    If (X<0) Or (X>=C_W) Or
       (Y<0) Or (Y>=C_H) Then Exit;

    NibbleIndex:=X Div 4;
    BitIndex:=X Mod 4;

    Ch:=Copy(GRow[Y],NibbleIndex+1,1);
    V:=HexValue(Ch);

    If BitIndex=0 Then Divisor:=8
    Else If BitIndex=1 Then Divisor:=4
    Else If BitIndex=2 Then Divisor:=2
    Else Divisor:=1;

    Result:=((V Div Divisor) Mod 2)=1;
End;

Function AddFillRun(Y,XStart,XEnd);
Var F;LX;RX;BY;TY;
Begin
    Result:=False;

    LX:=C_X0+(XStart*C_CELL);
    RX:=C_X0+((XEnd+1)*C_CELL);

    { Image Y=0 is top. PCB Y increases upward. }
    TY:=C_Y1-(Y*C_CELL);
    BY:=C_Y1-((Y+1)*C_CELL);

    F:=PCBServer.PCBObjectFactory(
        eFillObject,
        eNoDimension,
        eCreate_Default
    );

    If F=Nil Then Exit;

    F.X1:=MilsToCoord(LX);
    F.Y1:=MilsToCoord(BY);
    F.X2:=MilsToCoord(RX);
    F.Y2:=MilsToCoord(TY);
    F.Layer:=eTopOverlay;

    GBoard.AddPCBObject(F);

    PCBServer.SendMessageToRobots(
        GBoard.I_ObjectAddress,
        c_Broadcast,
        PCBM_BoardRegisteration,
        F.I_ObjectAddress
    );

    GAddedFills:=GAddedFills+1;
    Result:=True;
End;

Procedure RedrawPCB;
Begin
    ResetParameters;
    AddStringParameter('Action','Redraw');
    RunProcess('PCB:Zoom');
End;

Procedure ApplyT24_Stage1_TopSilk_Logo_v1;
Var X;Y;RunStart;InRun;
Begin
    GBoard:=PCBServer.GetCurrentPCBBoard;

    If GBoard=Nil Then
    Begin
        ShowMessage(
            'ABORT T24-1: open DATALOGER_RevA.PcbDoc.'+#13#10+
            'Nothing changed.'
        );
        Exit;
    End;

    If (CountTracks('GND')<>117) Or
       (CountVias('GND')<>46) Or
       (CountPolygons<>1) Then
    Begin
        ShowMessage(
            'ABORT T24-1: PCB baseline differs from final T23 checkpoint.'+#13#10+
            'Expected 117 GND tracks / 46 GND vias / 1 polygon.'+#13#10+
            'Nothing changed.'
        );
        Exit;
    End;

    If Not VisibleOverlayZoneFree Then
    Begin
        ShowMessage(
            'ABORT T24-1: selected Top Overlay logo zone is no longer empty,'+#13#10+
            'or this logo was already applied.'+#13#10+
            'Nothing changed.'
        );
        Exit;
    End;

    InitBitmap;

    GAddedFills:=0;
    GBuildOK:=True;

    PCBServer.PreProcess;

    Try
        Try
            For Y:=0 To C_H-1 Do
            Begin
                InRun:=False;
                RunStart:=0;

                For X:=0 To C_W-1 Do
                Begin
                    If PixelOn(X,Y) Then
                    Begin
                        If Not InRun Then
                        Begin
                            InRun:=True;
                            RunStart:=X;
                        End;
                    End
                    Else
                    Begin
                        If InRun Then
                        Begin
                            If Not AddFillRun(Y,RunStart,X-1) Then
                                GBuildOK:=False;

                            InRun:=False;
                        End;
                    End;
                End;

                If InRun Then
                    If Not AddFillRun(Y,RunStart,C_W-1) Then
                        GBuildOK:=False;
            End;

        Except
            GBuildOK:=False;
        End;

    Finally
        PCBServer.PostProcess;
    End;

    If (Not GBuildOK) Or
       (GAddedFills<>C_EXPECTED_FILLS) Then
    Begin
        ShowMessage(
            'BUILD INCOMPLETE T24 Stage1.'+#13#10+
            'Top Overlay fills added: '+IntToStr(GAddedFills)+
            ' / expected '+IntToStr(C_EXPECTED_FILLS)+'.'+#13#10+
            'Do NOT save. Use one Ctrl+Z.'
        );

        RedrawPCB;
        Exit;
    End;

    RedrawPCB;

    ShowMessage(
        'APPLY COMPLETE T24 Stage1 Logo v1.'+#13#10+
        'Approved logo + SANAT NEGAR + M.PAHLAVIAN placed on Top Overlay.'+#13#10+
        'Size: 12.192 x 11.684 mm.'+#13#10+
        'Location: X 4910..5390 mil / Y 4360..4820 mil.'+#13#10+
        'Silk fills: '+IntToStr(GAddedFills)+'.'+#13#10+
        'Copper / routing / GND polygon were NOT modified.'+#13#10+
        'FULL DRC REQUIRED BEFORE SAVE.'+#13#10+
        'If appearance is not acceptable, do NOT save and use one Ctrl+Z.'+#13#10+
        'Do not rerun.'
    );
End;
