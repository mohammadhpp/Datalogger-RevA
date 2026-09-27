{ Datalogger RevA - T24
  Select ONLY the 16 components whose source footprints received persistent courtyard fixes.
  No geometry is modified. This is only a controlled selection helper before
  Component Actions > Update Current Components From PCB Libraries.

  Entry:
    SelectT24_Courtyard16_ForLibraryUpdate_v1
}

Var
    GBoard;

Function T24IsTarget(S);
Var U;
Begin
    U := UpperCase(S);
    Result :=
        (U='U_RTC') Or
        (U='Q_SD') Or
        (U='Q_OLED') Or
        (U='J_SWD') Or
        (U='J_SHIELD') Or
        (U='J_NAV') Or
        (U='J_SD') Or
        (U='D_EXT1') Or
        (U='D_EXT2') Or
        (U='D_EXT3') Or
        (U='D_ESD') Or
        (U='D_ESD1') Or
        (U='D_ESD2') Or
        (U='C_SENSOR_BULK') Or
        (U='C_SD_MID') Or
        (U='C_OLED_BULK');
End;

Procedure SelectT24_Courtyard16_ForLibraryUpdate_v1;
Var
    It;
    O;
    C;
    SelectedCount;
Begin
    GBoard := PCBServer.GetCurrentPCBBoard;

    If GBoard=Nil Then Begin
        ShowMessage('ABORT: No PCB active.');
        Exit;
    End;

    If UpperCase(ExtractFileName(GBoard.FileName))<>'DATALOGER_REVA.PCBDOC' Then Begin
        ShowMessage('ABORT: Activate DATALOGER_RevA.PcbDoc. Nothing changed.');
        Exit;
    End;

    It := GBoard.BoardIterator_Create;
    If It=Nil Then Begin
        ShowMessage('ABORT: Board iterator unavailable.');
        Exit;
    End;

    It.AddFilter_ObjectSet(AllObjects);
    It.AddFilter_LayerSet(AllLayers);
    It.AddFilter_Method(eProcessAll);

    O := It.FirstPCBObject;
    While O<>Nil Do Begin
        O.Selected := False;
        O := It.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(It);

    SelectedCount := 0;

    It := GBoard.BoardIterator_Create;
    If It=Nil Then Begin
        ShowMessage('ABORT: Component iterator unavailable.');
        Exit;
    End;

    It.AddFilter_ObjectSet(MkSet(eComponentObject));
    It.AddFilter_LayerSet(AllLayers);
    It.AddFilter_Method(eProcessAll);

    C := It.FirstPCBObject;
    While C<>Nil Do Begin
        If T24IsTarget(C.SourceDesignator) Then Begin
            C.Selected := True;
            SelectedCount := SelectedCount + 1;
        End;
        C := It.NextPCBObject;
    End;

    GBoard.BoardIterator_Destroy(It);

    GBoard.ViewManager_FullUpdate;

    If SelectedCount<>16 Then Begin
        ShowMessage(
            'ABORT: Expected 16 selected target components, got '+
            IntToStr(SelectedCount)+'.'+#13#10+
            'Do not run the library update.'
        );
        Exit;
    End;

    ShowMessage(
        'PASS: exactly 16 T24 courtyard target components selected.'+#13#10+
        'NEXT: right-click one selected component > Component Actions >'+#13#10+
        'Update Current Components From PCB Libraries.'+#13#10+
        'In Update Options, include ONLY Mechanical 2 and Mechanical 4.'
    );
End;
