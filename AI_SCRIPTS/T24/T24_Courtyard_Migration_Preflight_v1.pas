{==============================================================================
 Datalogger RevA - T24
 COURTYARD MIGRATION PREFLIGHT READ-ONLY v1

 Entry point:
   PreflightT24_Courtyard_Migration_v1

 Purpose:
   Final read-only inventory before converting Mechanical Layer 2 into the
   Top Courtyard side of a true Courtyard Component Layer Pair.

 Reports:
   - total component count
   - components with Mechanical 2
   - components WITHOUT Mechanical 2
   - top-side components with Mechanical 2
   - bottom-side components with Mechanical 2
   - bottom-side components WITHOUT Mechanical 2
   - exact RefDes lists for migration handling

 Expected baseline from prior global audit:
   total components = 129
   components with Mech2 = 113
   components without Mech2 = 16
   loose non-component Mech2 = 0

 READ ONLY:
   - no layer pair creation
   - no primitive layer changes
   - no footprint/component edits
   - no rule edits
   - no DRC/polygon actions

 Output:
   T24_Courtyard_Migration_Preflight.txt
==============================================================================}

Var
    GBoard;
    GReport;
    GTotal;
    GWithM2;
    GWithoutM2;
    GTopWithM2;
    GBottomWithM2;
    GBottomWithoutM2;

Procedure AddLine(S);
Begin
    GReport.Add(S);
End;

Function ComponentHasMech2(C);
Var GI;O;
Begin
    Result:=False;

    GI:=C.GroupIterator_Create;
    If GI=Nil Then Exit;

    GI.AddFilter_ObjectSet(
        MkSet(
            eTrackObject,
            eArcObject,
            eFillObject,
            eRegionObject,
            eTextObject
        )
    );
    GI.AddFilter_LayerSet(MkSet(eMechanical2));

    O:=GI.FirstPCBObject;
    If O<>Nil Then Result:=True;

    C.GroupIterator_Destroy(GI);
End;

Procedure AuditComponents;
Var BI;C;HasM2;
Begin
    GTotal:=0;
    GWithM2:=0;
    GWithoutM2:=0;
    GTopWithM2:=0;
    GBottomWithM2:=0;
    GBottomWithoutM2:=0;

    AddLine('=== COMPONENTS WITHOUT MECHANICAL 2 ===');

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then
    Begin
        AddLine('ERROR: component iterator unavailable.');
        Exit;
    End;

    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(AllLayers);
    BI.AddFilter_Method(eProcessAll);

    C:=BI.FirstPCBObject;
    While C<>Nil Do
    Begin
        GTotal:=GTotal+1;
        HasM2:=ComponentHasMech2(C);

        If HasM2 Then
        Begin
            GWithM2:=GWithM2+1;

            If C.Layer=eBottomLayer Then
                GBottomWithM2:=GBottomWithM2+1
            Else If C.Layer=eTopLayer Then
                GTopWithM2:=GTopWithM2+1;
        End
        Else
        Begin
            GWithoutM2:=GWithoutM2+1;
            AddLine(
                C.SourceDesignator+
                ' | Layer='+Layer2String(C.Layer)+
                ' | X='+FloatToStr(CoordToMils(C.X))+
                ' | Y='+FloatToStr(CoordToMils(C.Y))
            );

            If C.Layer=eBottomLayer Then
                GBottomWithoutM2:=GBottomWithoutM2+1;
        End;

        C:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);

    AddLine('');
    AddLine('=== BOTTOM-SIDE COMPONENTS WITH MECHANICAL 2 ===');

    BI:=GBoard.BoardIterator_Create;
    If BI=Nil Then Exit;

    BI.AddFilter_ObjectSet(MkSet(eComponentObject));
    BI.AddFilter_LayerSet(MkSet(eBottomLayer));
    BI.AddFilter_Method(eProcessAll);

    C:=BI.FirstPCBObject;
    While C<>Nil Do
    Begin
        If ComponentHasMech2(C) Then
            AddLine(
                C.SourceDesignator+
                ' | X='+FloatToStr(CoordToMils(C.X))+
                ' | Y='+FloatToStr(CoordToMils(C.Y))+
                ' | Rotation='+FloatToStr(C.Rotation)
            );

        C:=BI.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(BI);
End;

Procedure PreflightT24_Courtyard_Migration_v1;
Var FN;Msg;
Begin
    GBoard:=PCBServer.GetCurrentPCBBoard;
    If GBoard=Nil Then
    Begin
        ShowMessage('ABORT: open DATALOGER_RevA.PcbDoc. Nothing changed.');
        Exit;
    End;

    GReport:=TStringList.Create;
    Try
        AddLine('Datalogger RevA - T24 Courtyard Migration Preflight v1');
        AddLine('READ ONLY');
        AddLine('PCB: '+GBoard.FileName);
        AddLine('');

        AuditComponents;

        AddLine('');
        AddLine('============================================================');
        AddLine('SUMMARY');
        AddLine('Total components: '+IntToStr(GTotal));
        AddLine('Components with Mechanical 2: '+IntToStr(GWithM2));
        AddLine('Components without Mechanical 2: '+IntToStr(GWithoutM2));
        AddLine('Top-side components with Mechanical 2: '+IntToStr(GTopWithM2));
        AddLine('Bottom-side components with Mechanical 2: '+IntToStr(GBottomWithM2));
        AddLine('Bottom-side components without Mechanical 2: '+IntToStr(GBottomWithoutM2));

        If (GTotal=129) And (GWithM2=113) And (GWithoutM2=16) Then
            AddLine('BASELINE PASS: counts match prior global audit.')
        Else
            AddLine('BASELINE REVIEW: counts differ from prior global audit.');

        FN:=ExtractFilePath(GBoard.FileName)+
            'T24_Courtyard_Migration_Preflight.txt';
        GReport.SaveToFile(FN);

        Msg:='COURTYARD MIGRATION PREFLIGHT COMPLETE.'+#13#10+
             'Total: '+IntToStr(GTotal)+#13#10+
             'With Mech2: '+IntToStr(GWithM2)+#13#10+
             'Without Mech2: '+IntToStr(GWithoutM2)+#13#10+
             'Bottom with Mech2: '+IntToStr(GBottomWithM2)+#13#10+
             'Report: T24_Courtyard_Migration_Preflight.txt'+#13#10+
             'Nothing changed.';

        ShowMessage(Msg);
    Finally
        GReport.Free;
    End;
End;
