# T25CE — شاخهٔ مستقل USB، بررسی اجراشده و آزمون جدید مدل رسمی
Date: 2026-10-02 UTC. Baseline: main e5f1ac0e8127854c482b599b6a5f010b243ba4df.
Status: ACTUAL_TEST_WITH_RAW_EVIDENCE (static/capacitor-only screen) + TEST_STAGED_AWAITING_USER_RUN_OR_HARDWARE (new USB vendor fixture).
**NO BOARD PASS / FABRICATION HOLD.**

## نتیجهٔ مهندسی
این مرحله فقط گزارش بعدی نیست: اسکریپت Python اجرا شد و CSV/JSON خام و شش netlist جدید تولید شد؛ آزمون مدل رسمی TPS54202 همراه اجرای تک‌کلیک و بازبین مستقل آماده است. مدل TPS2116 یا fixtureهای نامعتبر TPS631000 تکرار نشده‌اند. در این محیط PSpice ویندوز و PowerShell موجود نیست؛ اجرای عددی مدل رسمی و اعتبار syntax در موتور Windows هنوز ادعا نمی‌شود.

**اصلاح ضروری معماری:** در فایل زنده `07_EXPANSION.SchDoc`، `USB_VBUS_PROT` از طریق `R_EXP_PWR_EN` صفر اهم به `USB_5V_AUX` و J_EXP_PWR متصل است. بنابراین جایگزینی کل USB_VBUS_PROT با خروجی 3.576V نیاز خروجی 5V توسعه را نقض می‌کند. پیشنهاد بررسی‌شونده باید دو شاخه داشته باشد:
- شاخهٔ مستقل preregulator از USB خام پس از S1 به ریل پیشنهادی `USB_PMUX_REG`، سپس VIN1 مالتی‌پلکسر.
- شاخهٔ 5V توسعه با مسیر حفاظت جدا و نام/کارکرد فعلی حفظ‌شده.

این فقط تفکیک صحیح نیازهاست، نه تأیید OVP فعلی برای خروجی توسعه. حفاظت آن شاخه هم هنوز به دامنهٔ خطای محدودشده/مدل یا شواهد معتبر وابسته است. PCB، BOM و هیچ اتصال Altium تغییر نکرد.
CAD source identities: 01_POWER.SchDoc blob da2d005712c47000eb8c16157eca464d3fee4fe1; 07_EXPANSION.SchDoc blob 8714da5cbc041923e25a1aa647002e88f5b4d9a3.

## خریدپذیری فعلی؛ کاندیدا، نه انتخاب نهایی
صفحهٔ واقعی فروشنده بر متن کش‌شدهٔ جستجو مقدم است. شمارش موجودی تضمین تأمین/اصالت یا رزرو نیست.

| قطعه | شاهد ایران در 2026-10-02 | نتیجهٔ فعلی |
|---|---|---|
| TPS54202DDCR | [Lion 792](https://lionelectronic.ir/products/792-TPS54202DDCR) | IC قابل بررسی؛ قبلاً هم exact-MPN احراز شده |
| Bourns SRN1060-100M | [Lion 6722](https://lionelectronic.ir/products/6722-SRN1060-100M)، 1980 عدد در HTML مستقیم | 10µH ±20%، تقریباً 10×9.8×6mm؛ fit/layout باز |
| TDK SPM6530T-100M | [Lion 4357](https://lionelectronic.ir/products/4357-SPM6530T-100M)، «به زودی» در HTML مستقیم | موجودی قبلی search قابل اتکا نیست؛ تأمین عملی باز |
| TPSM863257RDXR | [Lion 6542](https://lionelectronic.ir/products/6542-TPSM863257RDXR)، «اتمام موجودی» | exact listing پیدا شد ولی موجودی عملی احراز نشده |
| Fenghua 0603CG560J500NT | [Lion 1904](https://lionelectronic.ir/products/1904-0603CG560J500NT)، 3450 عدد | 56pF C0G 50V ±5%، مقدار شروع Cff در fixture؛ انتخاب نهایی نیست |

برای SRN1060-100M دیتاشیت سازنده DCR حداکثر **29mΩ** می‌دهد؛ صفحهٔ فروشنده 290mΩ نوشته است. اسکریپت و fixture مقدار سازنده را استفاده می‌کنند و اختلاف صریحاً ثبت می‌شود. سازنده Irms=5.4A با معیار افزایش دما 40°C و Isat=5.2A با افت L=30% در 25°C اعلام می‌کند؛ این معیارها تضمین رفتار مدار در همهٔ دماها نیستند. این سلف USB مستقل از **L1 اصلی Murata 1µH** است.
برای lower divider دو مقاومت موجود 10k ARG05DTC1002 ±0.5% سری بررسی شد تا نوع جدید 20k لازم نشود؛ تعداد/فضا و موجودی باقیمانده قبل ECO باید بررسی شود. مقاومت upper همان 100k ±1% طرح قبلی است. خازن‌های توان هنوز به حداقل Ceff تحت bias/temp/tolerance نیاز دارند.

## بررسی واقعاً اجراشده
Command: `python AI_SCRIPTS/T25/T25CE_USB_Candidate_Screen_v1.py --root .`
Raw: `AI_EVIDENCE/T25CE/T25CE_executed_screen.json`, LC corner CSV and capacitor-only unplug CSV.
19 mA = مشاهدهٔ قدیمی prototype با bandwidth نامعلوم؛ 280 mA = سقف تاریخی طراحی در 3V3، **نه peak اندازه‌گیری‌شده**. مبنای اصلی توان 0.924W است؛ سناریوی 19mA فقط حساسیت است.

| کمیت | نتیجه | محدودیت |
|---|---:|---|
| خروجی static buck با VFB و divider corners | 3.442642..3.712055V | بدون دینامیک، temperature و ripple |
| مرز static پیشنهادی PR1، دو10k روی10k | 2.741692..3.261709V | تغییر PR1 اجرا نشده؛ hysteresis/leakage/dynamics جدا |
| فاصلهٔ static حداقل buck تا بالاترین PR1 | 180.933mV | حاشیهٔ کامل سیستم نیست |
| Ceff برای screen قبل Cff، f0<40kHz در Vout_min | **>28.6844µF** | pair نامی44µF باید بیش از65.19% حفظ کند؛ curve تضمین‌شده نداریم |
| بیشترین Ipeak در sweep فرضی CCM | 0.931416A | Vin5/5.5/12، eta70/75/90%، L_eff8/5.6µH و f400k؛ light Eco-mode شامل نیست |
| Ceff شرط slope0.1V/µs در کمترین PR با eta70% | ≥4.81455µF | فقط cap-only، نه waveform پین واقعی |
| C_mux برای شکاف فرضی100µs تا1.84V، eta75% | 59.64264µF | شکاف100µs تضمین mux نیست؛ عدد انتخاب BOM نیست |

CSV unplug حل مستقیم انرژی `V²(t)=V0²-2Pt/C` با بار توان ثابت و Ceff/eta سناریویی است؛ نوسان/RCB/کنترل buck و mux در آن وجود ندارند. در netlist vendor بار مقاومتی معادل در 3.576V است؛ بنابراین دو مدل بار عمداً به‌عنوان یک مدل فیزیکی واحد معرفی نمی‌شوند.
Screen f0 معیار طراحی قبل افزودن Cff است، نه حکم قطعی ناپایداری case22µF بعد Cff. پارامتر56pF نقطهٔ شروع fixture است و نیاز به پاسخ واقعی مدل دارد.

## مدل رسمی TI و آزمون آماده
TI [SLVMBJ5 download](https://www.ti.com/lit/zip/slvmbj5) در صفحه با عنوان Unencrypted نمایش داده می‌شود اما payload دارای `**$ENCRYPTED_LIB` و CDNENC است.
- ZIP 104464 bytes؛ SHA256 39e524bc2cc9a71a22e8afb753ccc5f2f8ee16ca0f491763b52ba1eb9c16271b.
- LIB 96538 bytes؛ SHA256 2410b7f6f64162ffe6c3ca94565396870aa55e4cafbeccd2382bc2471d933d3d.
- Interface: `.SUBCKT TPS54202_TRANS GND PH VIN VSENSE EN BOOT PARAMS: STEADY_STATE=0`.
- Runner از لینک رسمی دانلود می‌کند، هر دو hash را بررسی کرده و در صورت تغییر متوقف می‌شود. هیچ مدل ساختگی یا ادعای سازگاری ngspice/Altium جایگزین نشده.

شش case: بار معادل280/19/0mA در3V3 × Cout_effective44/22µF. Pilot280/44 اول است. source5V پس از startup، fault سناریویی12V در15ms، 5.5V در20ms، بازشدن واقعی switch منبع در25ms، پایان28ms. Source impedance0.1Ω و fault slew1µs **نیاز تأییدشدهٔ پروژه نیستند**. EN floating مطابق TI؛ هیچ اتصال به raw12V. L10µH nominal، DCR29mΩ، ESR5mΩ و Cin22µF نیز fixture هستند نه Ceff قطعات نصب‌شده.
Prestate13..14ms باید دارای حداقل10 sample در±5%3.576V باشد؛ JOB CONCLUDED، شمارش خطا/هشدار، تعداد نمونه و پایان زمانی بررسی می‌شوند. fixture نامعتبر روند را فوراً متوقف می‌کند؛ 180s هرcase/900s کل، بدون retry همان fixture. Gate اولیه فقط قابلیت تفسیر trace را می‌سنجد؛ خروجی fault، overshoot، افت VIN و جریان‌ها مستقل audit می‌شوند و هیچ board PASS خودکار صادر نمی‌شود.
پارس PRINT هر جدول مستقل از header است تا timestamp سطر بعدی اشتباهاً ستون داده نشود. parser Python روی fixture مصنوعی split-table و prestate معتبر/نامعتبر اجرا و موفق شد. این تست خود parser است، نه شاهد اجرای vendor model. بررسی متنی deckها و ASCII بودن PS/CMD انجام شده؛ Windows PowerShell اجرا نشده.

## قدم دقیق اجرا
پس از sync معمول `Git_Save.cmd`، فایل `AI_SCRIPTS\T25\Run_T25CE_USB_Official_Model_v1.cmd` را اجرا کنید. موتور همان مسیر موجود کاربر `C:\Cadence\OrCADX_25.1\tools\bin\psp_cmd.exe` است. نتیجه در Documents در ZIP دارای نام `Datalogger_T25CE_..._Result.zip` قرار می‌گیرد؛ آن ZIP برای audit لازم است. DATهای بزرگ و library در پوشهٔ work باقی می‌مانند.
این یک مدل **جدید برای شاخهٔ جدید USB** است؛ هیچکدام از مدل‌های قبلی نامعتبر تکرار نشده‌اند. این محیط موتور ویندوز ندارد؛ به همین دلیل اجرای vendor به کاربر وابسته است، نه به تأیید مجدد تصمیم‌های قفل‌شده.
Auditor: `python AI_SCRIPTS/T25/T25CE_Audit_Printed_Output_v1.py RESULT.zip`.

## باقی‌مانده و ادامه
نتیجهٔ vendor تنها USB را محدود می‌کند. انتخاب نهایی هنوز به Ceff، پاسخ buck، layout/thermal/EMI، bypass و PR1 واقعی، حفاظت شاخهٔ5V توسعه، startup TPS631000 در AA بارگذاری‌شده1.80V، no-reset هر دو انتقال و بار واقعی card/module وابسته است. SD T25BK/T25BL دوباره باز نشده، TPS631000 و L1 حفظ شدند، S1 exact sourcing طبق کاربر عقب افتاده. یک proposal کامل ECO/purchase بعد از تکمیل این evidence gates، نه partial ECO. T24 DRC0/0 فقط checkpoint CAD است.

Primary sources inspected:
- [TI TPS54202 datasheet](https://www.ti.com/lit/ds/symlink/tps54202.pdf)
- [TI TPS2116 datasheet](https://www.ti.com/lit/ds/symlink/tps2116.pdf)
- [Bourns SRN1060 datasheet](https://www.bourns.com/docs/Product-Datasheets/SRN1060.pdf)
- [Fenghua C0G catalog](https://www.fhcomp.com/en/product_page/?code=010000&page=502)
- [TI TPSM863257](https://www.ti.com/product/TPSM863257)
- Existing report T25CA and live CAD identities above; manufacturer facts take precedence over retailer typos.
