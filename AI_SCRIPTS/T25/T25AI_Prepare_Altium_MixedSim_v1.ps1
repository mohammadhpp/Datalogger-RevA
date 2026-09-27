# T25AI v1: prepare isolated Altium MixedSim netlists. Does NOT run simulation.
# PS 5.1 / ASCII source. Never changes project SchDoc/PcbDoc/PcbLib/BOM.
$ErrorActionPreference = 'Stop'
$sourceSha = '730DD922475B68183CB2D3ECAC3259C8F5637E6458764CED7F3FBC0C89DA80A7'
$dateTag = Get-Date -Format 'yyyyMMdd_HHmmss'
$outDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "Datalogger_T25AI_Altium_v1_$dateTag"
$downloads = Join-Path $env:USERPROFILE 'Downloads'
$archive = Join-Path $outDir 'SLVMDI4A.ZIP'
$vendorDir = Join-Path $outDir 'vendor'
$modelPath = Join-Path $vendorDir 'TPS2116_PSPICE_TRANS\TPS2116_TRANS.LIB'

function Save-Deck([string]$name, [string]$body) {
    $target = Join-Path $outDir $name
    [System.IO.File]::WriteAllText($target, ($body -replace "`r?`n", "`r`n"), [Text.Encoding]::ASCII)
}

try {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    $match = $null
    if (Test-Path -LiteralPath $downloads -PathType Container) {
        foreach ($f in (Get-ChildItem -LiteralPath $downloads -Filter 'SLVMDI4*.zip' -File -ErrorAction SilentlyContinue)) {
            if ((Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash.ToUpperInvariant() -eq $sourceSha) {
                $match = $f.FullName
                break
            }
        }
    }
    if ($match) {
        Copy-Item -LiteralPath $match -Destination $archive
    } else {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri 'https://www.ti.com/lit/zip/SLVMDI4' -OutFile $archive -UseBasicParsing
    }
    $actualSha = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actualSha -ne $sourceSha) { throw "Official TI archive SHA256 mismatch: $actualSha" }
    Expand-Archive -LiteralPath $archive -DestinationPath $vendorDir
    if (-not (Test-Path -LiteralPath $modelPath -PathType Leaf)) { throw 'Expected TI .LIB missing' }
    $model = Get-Content -LiteralPath $modelPath -Raw
    if ($model -notmatch '(?im)^\.SUBCKT\s+TPS2116_TRANS\s+GND\s+MODE\s+PR1\s+ST\s+VIN1\s+VIN2\s+VOUT_0\s+VOUT_1\s*$') {
        throw 'TI model interface changed; pin map must be re-audited'
    }
    if ($modelPath -match '[^\x00-\x7F]') { throw 'Model path contains non-ASCII; Altium netlist encoding requires an ASCII path' }

    $rc = @'
T25AI v1 - Altium core/USB capacitor isolated parser smoke only
* Ideal source disconnect is a TEST STIMULUS; NOT the real OVP circuit.
V_USB USB_SOURCE 0 DC 5.5
V_CTRL CONTROL 0 PWL(0 1 1m 1 1.0001m 0 20m 0)
S_UNPLUG USB_SOURCE USB_VBUS_PROT CONTROL 0 SW_UNPLUG
.MODEL SW_UNPLUG SW (RON=0.01 ROFF=1G VT=0.5 VH=0.1)
C_USB1 USB_VBUS_PROT 0 22u
R_LOAD_TEST USB_VBUS_PROT 0 330
R_PR_TOP USB_VBUS_PROT PMUX_PR1 30k
R_PR_BOTTOM PMUX_PR1 0 10k
.TRAN 2u 20m 0 2u
.PRINT TRAN V(USB_VBUS_PROT) V(PMUX_PR1)
.END
'@
    Save-Deck '01_CORE_RC_SMOKE.nsx' $rc

    foreach ($battery in @('1p8','3p0')) {
        $batteryV = if ($battery -eq '1p8') { '1.8' } else { '3.0' }
        $deck = @'
T25AI v1 - vendor TPS2116 Altium parser and output control only
* All 22u caps are NAMEPLATE; effective C is unknown.
* USB disconnect is ideal; actual OVP and cable are not included.
* 330ohm load is a light TEST FIXTURE, not the RevA 280mA rail load.
* TI vendor model disagreed with TI EVM evidence in a previous fixture.
* No TPS631000/3V3/SD/OLED; never infer no-reset hardware PASS.
.LIB "@MODEL@"
V_USB USB_SOURCE 0 DC 5.5
V_CTRL CONTROL 0 PWL(0 1 1m 1 1.0001m 0 20m 0)
S_UNPLUG USB_SOURCE USB_VBUS_PROT CONTROL 0 SW_UNPLUG
.MODEL SW_UNPLUG SW (RON=0.01 ROFF=1G VT=0.5 VH=0.1)
C_USB1 USB_VBUS_PROT 0 22u
V_BAT BAT_SW 0 DC @BATTERY@
R_PR_TOP USB_VBUS_PROT PMUX_PR1 30k
R_PR_BOTTOM PMUX_PR1 0 10k
R_ST_TEST PMUX_ST 0 1G
X_PMUX 0 USB_VBUS_PROT PMUX_PR1 PMUX_ST USB_VBUS_PROT BAT_SW VIN_MUX VIN_MUX TPS2116_TRANS
C_IN VIN_MUX 0 22u
R_LOAD_TEST VIN_MUX 0 330
.TRAN 2u 20m 0 2u
.PRINT TRAN V(USB_VBUS_PROT) V(PMUX_PR1) V(BAT_SW) V(VIN_MUX) I(V_BAT)
.END
'@
        $deck = $deck.Replace('@MODEL@', $modelPath).Replace('@BATTERY@', $batteryV)
        Save-Deck "02_TPS2116_USB_UNPLUG_BAT_${battery}.nsx" $deck
    }
    $readme = @'
T25AI v1 - Altium mixed-simulation preparation only (NO SIMULATION HAS RUN)

1. Open 01_CORE_RC_SMOKE.nsx as a free document in Altium Designer.
2. Press F9 (Simulate > Run). Save the Messages/error text and any result.
3. Only if 01 works, open 02_TPS2116_USB_UNPLUG_BAT_1p8.nsx and press F9.
4. Compare with 02_TPS2116_USB_UNPLUG_BAT_3p0.nsx as a model-control case.
5. Inspect V(USB_VBUS_PROT), V(PMUX_PR1), V(VIN_MUX), -I(V_BAT).
6. Share the Altium Messages output and saved SimData/results, or a screenshot
   of the first error. No need to repeat a failed vendor case blindly.

These netlists are isolated TEST FIXTURES derived from live 01_POWER.SchDoc
blob da2d005712c47000eb8c16157eca464d3fee4fe1 and verified TI model.
USB source disconnect switch represents the OPEN cable contact, not Q_OVP.
C_USB1 and C_IN are nominal 22u; C_USB2 and ST pullup are DNP-initial
assumptions from historical purchase workbook, not an assembly instruction.
The load resistor is arbitrary and does NOT emulate TPS631000 or 280mA at 3V3.
Altium may reject PSpice-specific model syntax; that is a compatibility FAIL,
not evidence of hardware failure. The TI model may fail physically even if parsed.
Do not run a Simulation Dashboard regeneration on these external netlists.
Do not release Gerbers or claim no-reset from these tests.
'@
    Save-Deck 'READ_ME_FIRST.txt' $readme
    Write-Host "T25AI PREPARATION COMPLETE (no Altium simulation executed): $outDir"
    Write-Host 'Open 01_CORE_RC_SMOKE.nsx in Altium and press F9. Share Messages/results.'
} catch {
    Write-Error "T25AI PREPARATION FAILED: $($_.Exception.Message)"
    exit 1
}
