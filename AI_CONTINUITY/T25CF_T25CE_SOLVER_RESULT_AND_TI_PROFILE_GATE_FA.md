# T25CF — ممیزی توقف T25CE و آزمون عددی با profile رسمی TI
Date: 2026-10-06 UTC. Baseline main: 83b312b1744980d6d7fcb1572ed9cc20c9c9715e.
Status: ACTUAL_TEST_WITH_RAW_EVIDENCE (failed solver audited) + TEST_STAGED_AWAITING_USER_RUN_OR_HARDWARE (changed numerical fixture).
**NO BOARD PASS / FABRICATION HOLD.**

## نتیجهٔ دادهٔ خام
ZIP کاربر `Datalogger_T25CE_20261006_204848_Result.zip`، SHA256 `8e785dd57156bfee7a72d7e8416309bb72e791653f9acd11bbc08f7af2f7a551`، شامل یک case از شش case است. مدل رسمی با hashهای pinned درست بارگذاری و bias حل شد؛ سپس ORPSIM-15139 در t=1.243ms، دستگاه داخلی X_USB.D_U6_D59، گام 133e-21s در برابر حداقل 1e-18s رخ داد. 623 سطر VOUT وجود دارد؛ آخرین سطر VOUT=0.8824V، هنوز در startup. زمان موتور142.55s، wrapper147.6936s. این عدد خروجی تنظیم‌شده یا افت هنگام انتقال نیست.
در پنجره‌های prestate13..14ms، fault15ms، 5.5V20ms و unplug25ms هیچ نمونه‌ای وجود ندارد. JOB CONCLUDED و Simulation complete همراه این خطا به معنی موفقیت نیستند. null ExitCode هم علت توقف نیست. فقط failureِ اجرای مدل/fixture اثبات شده؛ هیچ verdict فیزیکی از این trace استخراج نمی‌شود.
دادهٔ خام کامل ZIP، ممیزی مستقل JSON و profile رسمی در AI_EVIDENCE/T25CF حفظ شدند. auditor قبلی همین نتیجه را مستقلاً رد کرد.

## اختلاف قابل‌اقدام با بستهٔ سازنده
از خود TI ZIP pinned، مسیر `TPS54202_TRANS-PSpiceFiles/Startup/trans.sim` خوانده شد؛ نسخهٔ خام در `TI_Startup_trans.sim.txt` است. تنظیمات روشن آن:
- maximum step20n؛ T25CE برابر200n بود.
- ABSTOL10n، VNTOL10u، ITL1=1500، ITL2=400، ITL4=100.
این اختلاف علت قطعی failure نیست؛ یک فرضیهٔ عددی قابل آزمون است. profile TI متعلق به مدار مرجع متفاوت است؛ مدار پیشنهادی این پروژه را مرجع TI یا تضمین سازنده معرفی نمی‌کنیم. برای انطباق عددی .OPTIONS ADVCONV حذف و options بالا اعمال شد؛ هیچ global shunt یا مدل diode جدید، precharge، steady-state bypass یا تغییر بار/موج منبع اضافه نشده است.
TI راهنمای convergence کاهش max step و تغییر iteration/tolerances را پیشنهاد می‌کند و کاهش احتمالی دقت/سرعت را صریحاً بیان می‌کند: https://e2e.ti.com/cfs-file/__key/communityserver-discussions-components-files/196/PSpice_5F00_convergence_5F00_11_5F00_29_5F00_2021.pdf
Cadence: https://community.cadence.com/cadence_technology_forums/pcb-design/f/pspice/57749/tips-to-resolve-convergence
این تنظیمات راه‌حل اثبات‌شده نیستند؛ همگرایی، sensitivity و اعتبار خروجی هنوز باید بررسی شوند.

## آزمون جدید محدود؛ فقط یک اقدام کاربر
`AI_SCRIPTS/T25/Run_T25CF_USB_TI_Profile_v1.cmd`:
1. hash کتابخانهٔ قبلی در Documents/Datalogger_T25CE_* را می‌سنجد و اگر معتبر باشد استفاده می‌کند؛ وگرنه TI ZIP pinned را می‌گیرد. هیچ کتابخانهٔ دانلودشدهٔ متفاوت اجرا نمی‌شود.
2. pilot280/44 فقط تا6ms با همان waveform و مدار قبلی، maxstep20ns، options TI. پایان>=5.99ms، حداقل1000 sample، صفر warning/error و حداقل10 sample در5..5.9ms داخل±5%3.576V لازم است.
3. فقط پس از pilot معتبر، شش case قبلی تا28ms با profile اصلاح‌شده خودکار اجرا می‌شوند. پیش‌حالت13..14ms و پایان>=27.9ms همان gate قبلی است. همان fixture ناموفق بدون تغییر تکرار نمی‌شود.
4. سقف هرcase240s، کل900s از آغاز preparation؛ نخستین failure/timeout روند را متوقف می‌کند؛ retry ندارد. حتی روی failure ZIP logs/decks/manifest حفظ می‌شود. موتور runtime در این محیط غایب است؛ PS5.1 اجرای واقعی این نسخه هنوز ادعا نمی‌شود.

معیارهای±5% فقط اجازهٔ تفسیر fixture را می‌دهند؛ overshoot/fault/unplug و جریان‌ها باید مستقلاً با دادهٔ خام بازبینی شوند. هفت fixture سالم به معنی OVP PASS، خرید یا transfer/board PASS نیست. اگر pilot جدید هم timeout/convergence/prestate failure داد، مسیر macro-model TPS54202 را BLOCKED_BY_NAMED_MODEL_OR_INSTRUMENT ثبت کن؛ تغییرات کور، retry همان deck یا تشخیص خرابی سخت‌افزار ممنوع است. شواهد جایگزین و proposal یکپارچه مستقل را ادامه بده.
Auditor: `python AI_SCRIPTS/T25/T25CF_Audit_Printed_Output_v1.py RESULT.zip`؛ نبودن case هم status incomplete دارد.

## بررسی‌های محلی و دامنه
پارس raw user .out اجرا شد؛ checks مصنوعی split-PRINT و معتبر/نامعتبر اجرا شدند. شش deck جدید، به‌جز title/TRAN/OPTIONS، line-for-line از لحاظ عناصر و منابع با baseline برابرند. pilot فقط stop time را کوتاه می‌کند؛ CIN/COUT/L/R/Cff، EN floating، بارهای معادل19/280mA و fault/source sensitivity همان قبلی‌اند. این بازبینی متن و parser است، نه اجرای solver Windows.
TPS631000 و L1 اصلی1µH، SD T25BK/BL و معماری سه‌پل S1 حفظ؛ exactS1 deferred. خروجی5V توسعه باید شاخهٔ مستقل بماند. Ceff واقعی، battery1.80V startup، no-reset mux و هر دو USB branch هنوز باز؛ هیچ CAD/BOM/purchase/fabrication تغییری انجام نشد. 19mA مشاهدهٔ prototype،280mA سقف طراحی تاریخی است.
