# CURRENT HANDOFF — Datalogger RevA

## ACTIVE USER EXECUTION RULE — 2026-09-28, 23:40 Tehran

- User explicitly instructed: **«منتظر تأیید نباش؛ اینو در هندآف ثبت کن»**. Continue the Datalogger RevA power-block work autonomously through read-only investigation, calculations, source checks, design drafts, reversible documentation and necessary validation. Do not stop at each intermediate gate with “موافقی؟ / مرحله بعد؟”, do not repeatedly ask for limits already locked in the workbook, and do not impose another Windows PSpice→ZIP/upload cycle whose model has already proved invalid.
- User also instructed: **«S1 بعد پیدا می‌کنیم؛ ادامه بده»**. Defer exact S1 three-pole sourcing; preserve the user-approved three-pole functional architecture and the live four-pole CAD mismatch in T25BX/T25BY. Continue USB/OVP/handoff and other independent power analysis.
- Prepare a single concrete, reviewable consolidated power proposal, Iran-sourced exact new-part list, test criteria and one ECO/purchase decision when technically ready. User's instruction to continue removes routine confirmation pauses; it does **not** turn unverified simulations into PASS or authorize claiming fabricated hardware. Do not ask for routine permission to write continuity reports or investigate candidates. If an irreversible purchase/fabrication action or a material change of locked product requirements truly requires a user choice, complete all independent work first and present the specific decision once.
- Keep GitHub `main` authoritative, maintain one live CURRENT EXACT POINT, and carry these instructions across chats. Preserve T24 0/0 DRC as a CAD-only checkpoint and FABRICATION HOLD until power gates are actually closed.

## CURRENT EXACT POINT — T25CK/CJ execution and CL runtime blocker, 2026-10-06 UTC

- Latest user instruction **«ادامه بده متوقف نشو»**: continue independently without routine permission pauses. No CAD/ECO/purchase/new physical stage or fabricated-board claim authorized.
- Read `T25CK_TPS2121_EXECUTION_AND_LIMITS_FA.md`, `T25CJ_USB_AUX_DNP_AND_IRAN_PROTECTION_FA.md`, `T25CL_LINEAR_USB_SCREEN_AND_RUNTIME_BLOCK_FA.md`.
- CJ live07_EXPANSION parsedread-only: R_EXP_PWR_EN=SER0603J0R/0R, noDNPparameterobserved;PrjPcbhasNoVariations/noVariantsection. HistoricalT21text + MasterBOM!L50 explicitinitiallinkDNP/Open. ProposedocumentingthatintentintheonefutureECO/BOM; doNOTclaimcurrentCAD/assemblydisconnection. USB3V3preregdoesNOTreplaceaux5V; poweredAUXfutureload/protectionremainsunqualified.
- ExactIranobservationsCJ:TPS259621DDAR168,TPS25921ADR102,TPS259630DDAR49,TPS259533DSGR35,TPS259250DRCR17,TPS2121RUXR28;TPS63070RNMTsoononly. Fixed5.7clampsdoNOTguarantee5.5ceiling;primaryvarianttable/polarityread. NoeFusechosen.
- CK unmodifiedofficialTPS2121SLVMCO8 executedlocalngspice42:9fixtures,8complete3ms,LM4040slowattachaborts2.47004216msd.xu.d_u_mos_d2;partialtraceREJECTED,returncode0doesnotmeancompletion. Valid3.285Vprestateincompletedcases. 1nsremovalSYSmin2.370..2.388Vfor22/47/100u;1us/33usfall3.105940/3.075417;hardattach3.037876. IdealregulatedBAT3.3,notAA1.8/TPS631000/MCU/SD.
- CK conditionalnewcontrolCP2LM4040-NbiasedUSBthrough2.4k,PR1Rt2k/Rb10k;noTLV1701/diodeORinthese9fixtures. UNSELECTED. 32JSstaticcorners:2.884369..3.116252V,attachmargin68.842mVrelativeUSBmin3.185094. Offset+/-40mVconservativescreenNOThysteresisguarantee;TCR/ripple/coldstartfullboundsopen.
- TPS2121modelnoIQ/thermal;INsourcesdonotaccountoutputloadcurrent;XCOMPideal/UVLO2.5/2.4versusdatabook2.65/2.55typ. DoNOTinterpretmodelinput0currentasAAbackfeedproof. Minimumstart2.8VmeanscannotreplaceupstreammuxonrawAA1.8. NointegratedorfullcornersPASS.
- NewCLlinearUSBscreen:TLV76133DCYR350stock,TLV76733DRVRsoon,LD1117S33CTR49;76701catalogexactfoundbutstocknotreceived/webopenfailed. TI76701SLVMCY1availablemodelnotdownloaded/executed. LM1117SNOM488downloadedunmodifiedbutnotexecuted/notexactSTorTLVfamily. TLV761DCYtheta95.4scenario,P=.476/.616/2.436W@5/5.5/12V280mA;temperature/reversecurrent/dropoutrecoverygatesopen. TPS631000RevC2026reviewed:revisionchangesLXshortnegative/CDMonly,nonewvalidmodel(TIstillencryptedSLVMDV2).
- **Real execution blocker:** exec-server transport disconnected; recoverytimedoutafter25s;laterread-onlypendingcellterminated. CLprocess52410outcomeunknown;NO LDOsimulationlaunch. DoNOTclaimmodeltestfailureorapprovalrejection.
- **Raw retention:** CJ/CKfullCSV/logs/model/PDF/HTMLwerewrittenlocally butnewdurableZIPnotcreated/verifiedbeforeexecutorloss. Gitcontainsreceivedsummary/deckhashes/sourceaudit/32corners,NOTcompleteCKrawtraces. Firstrecoverexisting`/workspace/scratch/38719da73a41/T25CJ,T25CK,T25CL`whenexecutorreturns;save/verifyfullrawbeforeclaimingretainedrawevidence. OriginalCIcompletearchiveversion1remainsverifiedin`AI_EVIDENCE/T25CI/EVIDENCE_INDEX.json`.
- EarlierCI:6nominalTLV1701/LM4040idealMONcontrolfixtures +8192conditionalcornerscompleted;hardattachatlowMONnumericblocked,TLV431lowbiasprestateinvalid. Noarchitectureselected. Mainencryptedregulator/USBbuck/macromodelandactualCeff/source/loadremainopen. SDsubgateclosed,TPS631000/L1retained,S1exactdeferred.
- CAD unchanged;lastDRC0/0CAD-only; **FABRICATION HOLD**.

## Accepted design and validation baseline

- Live engineering source: private GitHub `mohammadhpp/Datalogger-RevA`, branch `main`, and the user's Windows repo `C:\#MHP FILES\DataLoger`. Historical ZIPs are rollback/evidence only. Read `AI_START_HERE.md` and its required source registry and continuation rules first.
- No RevA PCB has been fabricated. Existing final PCB-mounted parts were purchased; proposed new power parts are not an approved purchase. Canonical PCB `DATALOGER_RevA.PcbDoc`, library `Datalogger_RevA_Clean.PcbLib`.
- T23 routing CLOSED/PASS; T24 courtyards 129/129 persistent, last accepted Full Batch DRC 0 warnings / 0 violations at `3ea38daf1998dc926ec7ee77df95ce5ccf42d3b8`. No fresh DRC or functional PASS is claimed.
- Locked requirements: two-layer PCB; schematic grid 100 mil; readable PCB RefDes/polarity/pin-1; correct connectors for off-board devices; loaded pack minimum 1.80V; no USB nuisance cutoff at 5.50V; uninterrupted USB-priority battery↔USB transfers, zero MCU reset and no intentional AA backfeed.
- **19 mA** is the old prototype observation with unknown bandwidth; **280 mA** is the historical RevA maximum design envelope, not a measured peak. Keep both provenance labels. SD 400mA is a historic switch-drop sizing point, not a measured card peak.
- Retain TPS631000 and Murata `DFE322512F-1R0M=P2` 1µH L1. TPS54202DDCR and its separate USB coil remain exploratory, unselected; do not silently substitute them.
- S1 three-pole maintained functional architecture is user-approved: BAT, USB, and common return ends of the two separate CC Rd resistors. Live CAD still shows four contacts; see T25BX/T25BY. Exact switch procurement is deferred by user.
- Every new replacement part needs exact-MPN technical and practical Iranian availability evidence. Close the whole power block, present one consolidated purchase/ECO proposal, then obtain that single concrete design decision before modifying Altium. No partial order or power ECO.

## Evidence already completed; do not repeat

- T25BD/T25BE: 12/12 valid user PSpice capacitor-only cases independently match T25AZ. Conditional source/capacitor scenarios do not qualify physical RevA.
- T25BF/T25BG and T25BT/T25BV official encrypted TPS631000 short/precharged/SS=1 fixtures completed jobs but failed the regulated 3.3V pre-state gate. Post-step outputs are rejected. No hardware failure inferred; do not request another identical Windows run.
- T25AE TPS2116 vendor-model behavior conflicts with independent TI evidence. Do not repeat the discrepant fixture or interpret its output as hardware transfer PASS/FAIL.
- T25BH conditional slew targets are sensitivity results, not actual AO3401A gate timing.
- **SD controlled-inrush sub-gate is already screened**: T25BK independently audited 16 TPS22918 official-model cases; T25BL gives the unapplied ECO and exact Iranian sourcing. Do not reopen SD selection.
- SD candidate: `TPS22918DBVT`, CT `C1608NP01H472J080AA` 4.7nF C0G 0603, input bypass `C2012X7R1H105K125AB` 1µF X7R 0805, existing 100k ON pulldown. Correct physical pads 1 VIN, 2 GND, 3 ON, 4 CT, 5 QOD, 6 VOUT. Exact T25BL sourcing supersedes earlier provisional Samsung parts. This is a sub-gate technical/procurement screen, not an applied ECO or complete power purchase list.
- Actual card/module transients, TPS631000 source/startup at loaded 1.80V, exact biased Ceff, OVP and weak-battery no-reset handoff remain OPEN. No integrated system or fabrication PASS.
- Historical T25AI Altium netlist preparation does not establish an Altium execution. Newer T25CD and the active execution rule govern continuation; do not restart old compatibility loops merely from chat memory.

## Cleanup and preserved history

Exact pre-CJ/CK handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CJ_T25CK_2026-10-06.md` (source blob 734e40adb5353bb0d2ff0decfd5d760400eb85de).

Exact pre-T25CI handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CI_2026-10-06.md` (source blob c9b58bb90bff1a125590200388bd7af182875597).

Exact pre-T25CH handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CH_2026-10-06.md` (source blob 4ac0055e0e3b1a87a5315998e5b5a6756224dbf3).

Exact pre-T25CG handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CG_2026-10-06.md` (source blob 540c0318277f1ee1070cc0a618534c0d1f03f28c).

Exact pre-T25CF live handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CF_2026-10-06.md` (source blob e8a342bcb91f580285ef7f27cdc1377668ddbb19).

Exact pre-T25CE live handoff is also archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CE_2026-10-02.md` (source blob7416df90961a0981cfc3421791806ead75979d9f).

The exact pre-compaction live handoff is preserved byte-for-byte in
`AI_CONTINUITY/HANDOFF_ARCHIVE_PRE_COMPACTION_2026-10-02.md`
(source blob `7374eeb3fe3b931a72e22d68cd9438fbbe0b294b`, baseline main `3a1c713a1e371546a2fa72116adc5fe235e5686c`).

Read archived details only when needed; the sole active continuation point is the T25CK/CJ/CL section above. Further evidence and older checkpoints remain in `HISTORY.md`, dated T25 reports and source archives.

The 2026-09-28 cleanup audit is `GITHUB_CLEANUP_AUDIT_2026-09-28.md`: canonical SchLib was restored byte-identically; duplicate PcbLib and T23/T24 evidence retained pending dependency/path checks. Do not delete evidence to reduce apparent clutter. This compaction repairs documentation only.

**NEXT EXECUTABLE ACTION:** Recover existingCJ/CK/CLrawfileswhenexecutoraccessreturns;preserve/verifyCSV/logs/modelhashes. Finishexact76701stockandlinearUSBthermal/reverse/Ceffscreen,thenexecuteonlyexactvalidLDOmodelifviable. Continueonewholepowerproposal/exactIranBOM. DoNOTrerununchangedWindows/TPS2116/TPS631000/TPS54202/CIhardattachloopsor9CKcaseswhenoriginalrawexists;donotreopenSDorapplypartialECO.

**BLOCKER REQUIRING USER:** No routineapprovalorWindowsrerunrequested. Localexecutionisblockedbyexec-servertransport/recoveryfailure;fullCKrawretentionpending. Engineeringpre-fabricationproofstillblockedbyvalidBAT/USB/source/Ceff/load/fullcorner/NRST/SDintegrityevidence. ExactnewCLrouteisUNSELECTEDandnotexecuted;oneconsolidatedECO/purchasedecisionawaitstechnicalreadiness.

**FABRICATION HOLD.** Continuity CI validates file retention and metadata; it does not certify circuit function.
