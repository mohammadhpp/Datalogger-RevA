# T25CG — توقف محدود T25CF و بررسی مستقل معماری تغذیه
Date: 2026-10-06 UTC. Baseline main e6f9a3649b1e017e257394697a6f287560e49ec1.
Status: ACTUAL_TEST_WITH_RAW_EVIDENCE (timeout audited / analytical energy screen); BLOCKED_BY_NAMED_MODEL_OR_INSTRUMENT (bounded vendor execution).
**NO BOARD PASS / FABRICATION HOLD.**

## نتیجهٔ ZIP کاربر
SHA256 `543cb3e4d98385f1ee8c61ec4d686275888d8c5286d2c072b4ff407b2527bf1f`، پنج عضو. Runner در240.1857475s به CASE_TIMEOUT رسید و pilot را متوقف کرد. stdout تأیید می‌کند parsing بدون خطا و bias کامل شد و transient شروع شد؛ .out فقط بخش netlist/bias ناقصِ هنگام توقف دارد، PRINT و JOB CONCLUDED ندارد. DAT در ZIP نیست. stderr خالی است. warning ORPSIM-16534 می‌گوید ITL4 بالا در Speed Level>0 ممکن است زمان را زیاد کند؛ علت قطعی timeout از این هشدار ثابت نمی‌شود.
**زمان واقعیِ پیشروی شبیه‌سازی معلوم نیست.** نبود PRINT تا پایان job، به معنی پیش نرفتن solver یا crash آن نیست. این نتیجه را خطای همگرایی جدید، خروجی صفر ولت، خرابی IC یا FAIL مدار معرفی نکن. شش سناریوی بعدی launch نشدند. hashهای مدل pinned در manifest ثبت‌اند؛ LIB داخل ZIP نیست و در این مرحله بازهش مستقل آن امکان نداشت.
ممیزی مستقل T25CF روی raw .out اجرا شد و0 نمونه/1 هشدار/fixture incomplete داد. JSON audit و اصلZIP در AI_EVIDENCE/T25CG حفظ شدند.

## تصمیم عملی دربارهٔ مدل
T25CE با step-too-small شکست خورد؛ T25CF با profile واضح بستهٔTI در زمان محدود نتیجهٔ قابل‌تفسیر نداد. مسیر bounded این macro-model فعلاً **BLOCKED** است، نه اینکه ثابت کرده باشیم مدل برای هیچ مدار یا زمان طولانی کار نمی‌کند. T25CE/T25CF را دوباره اجرا نکن و timeout را کورکورانه افزایش نده؛ هیچ نسخهٔ بعدی Windows برای این مسیر در این مرحله تولید نشده. صفحهٔ جاریTI همچنان همان SLVMBJ5C را فهرست می‌کند؛ عنوان Unencrypted قبلاً با payload encrypted تناقض داشت و عنوان به‌تنهایی مدل دیگری نیست.

## بررسی مستقل انجام‌شده: جایگاه mux
دیتاشیتTPS2116 §7.4 برای افت سریع‌تر از1V/10us، ورودی دیگر>=2.5V را جهت جلوگیری از reset داخلی لازم می‌داند. تفسیر معماری: اگر باتری1.80V ابتدا توسط TPS631000 به ریل تنظیم‌شده تبدیل شود و mux بعد از دو regulator قرار بگیرد، شرط وابسته به باتری خام از ورودی mux حذف می‌شود؛ **به شرط اثبات آماده‌بودن ریل backup هنگام انتقال**. این استنتاج طراحی است، نه ضمانت uninterrupted operation.

| اتصال | CAD فعلی / گزینهٔUSB T25CE | گزینهٔ جدید برای مقایسه، انتخاب‌نشده |
|---|---|---|
| پکباتری وL1/U_SYS | باتری→VIN2 mux؛ خروجیmux→TPS631000→3V3_SYS | باتری→TPS631000/L1 فعلی→BAT_REG_3V3→VIN2 mux |
| USB | حفاظت/شاخهٔcandidate3.576V→VIN1 mux | USB regulator با setpoint جدید نزدیک3.3V→VIN1 mux |
| مصرف‌کننده‌ها | TPS631000→3V3_SYS | VOUT mux→3V3_SYS با Cbus مناسب |
| توسعه5V | USB_VBUS_PROT→R_EXP_PWR_EN→USB_5V_AUX | مسیر مستقل5V با حفاظت جدا حفظ می‌شود |
| قطعUSB | backup mux می‌تواند1.80V باشد | backup تنظیم‌شده باید>=2.5V بماند و فوراً بار بگیرد |

TPS631000 و سلف اصلی1µH حذف/تعویض نمی‌شوند؛ بلوک به مسیر باتری اختصاص می‌یابد فقط اگر این گزینه بعداً انتخاب شود. برای آماده‌بودن backup، converter باتری باید در زمانUSB روشن بماند؛ مصرف standby صفر نیست. TI8uA را typical IQ ذکر می‌کند، نه جریان تضمین‌شدهٔ پک در مدار باdivider/بازده/نشت. خاموش‌کردن این regulator تا لحظهٔunplug می‌تواند تأخیرstartup ایجاد کند؛ بنابراین راهکار آماده‌بودن backup با shutdown ساده قابل ادعا نیست. توان280mA درloaded1.80V همچنان باید جدا اثبات شود؛ headline1.5A مربوط بهVIN>=2.7V است.

دو نقص مستقیمِ بازاستفادهٔ T25CE در این گزینه:
- خروجیcandidate3.576V باcornermax3.712055V از حدکارکرد3.6V MCU فعلیSTM32G070KBT6 بالاتر است؛ اتصال مستقیم آن به3V3_SYS قابل قبول نیست. USB regulator/feedback جدید باید مطابق تمام بارها و transient بازطراحی شود؛ هیچMPN جدید انتخاب نشد.
- مرزPR1 قبلیmax3.261709V از ریل سناریویی3.135V بالاتر است؛ با انتقالmux به3V3 بازاستفادهٔ divider قبلی اولویتUSB را درهمهcornerها تضمین نمی‌کند. PR1/hysteresis/RCB و sequencing مستقل لازم‌اند.

C_OUT فعلی پیش ازmux جدید و برای پایداریregulator لازم می‌ماند؛ نمی‌توان آن را بدون بررسی بهCbus خروجیmux تبدیل کرد. 2.7V فقط مرجعکارکردrail برایSD است؛ افتswitch/trace باید بالاتر از آن حاشیه بگیرد. startup محدود1.3ms mux و RCB/delay ممکن است وقفهٔ بزرگ‌تری از typical switchover ایجاد کنند؛ typical6.2us حدبالای سیستم نیست. هیچ pass از این جابه‌جایی استنباط نشود.

## بررسی عددی واقعاً اجراشده
`python AI_SCRIPTS/T25/T25CG_Regulated_Mux_Screen_v1.py`، هجده case؛ CSV وJSON خام.
فقط معادلهٔ انرژی خازن `V_end=sqrt(V_start²-2Pt/C)` اجرا شد؛ مدلconverter/mux نیست. شروع3.135V ازفرض3.3V-5%، power=3.3×19/280mA؛ این‌ها minimum یا currentprofile تأییدشده نیستند. gaps6.2us (typTI در3.3V باRL10ohm/CL10uF)،50/100us (حساسیت اعلام‌شده)؛ Cbus مؤثر10.4/22/47uF سناریویی.
برای280mA، Cbus لازم تا2.7V در6.2us برابر4.514uF و در100us برابر72.807uF است؛ ESR/RCB/افتswitch/منبع و بازگشتکنترل شامل نیستند. این اعداد BOM یا PASS نیستند و نامplateخازن قبلی به معنیCeff اینnode نیست. 19mA مشاهدهٔ prototype قدیمی باbandwidth نامعلوم؛280mA سقف طراحی تاریخی است.

## ادامهٔ دقیق
مقایسهٔ دو معماری باید USBsetpoint/PR1corner، backup-ready atloaded1.80V،Cbus/C_OUT،RCB،SDdrop،کنترلپاور،layout وexactIranparts را تعیین کند. گزینهٔupstreammux باslow-collapse تأییدشده همچنان قابل بررسی است؛ timeout آن را ازنظرhardware رد نمی‌کند. هیچ طراحی/قطعه جدید/سفارش/ECO اعمال نشد. SDT25BK/BL بستهٔscreenشده حفظ؛S1exact طبقکاربرعقبافتاده. به‌جایطلبZIPجدید،کارمستقل تا یکproposal کامل ادامه پیدا می‌کند. یک تصمیم خرید/ECO بعد از تکمیلtechnical/procurementgates؛fabricationhold.

Primary sources inspected 2026-10-06:
- TI TPS54202 product/models: https://www.ti.com/product/TPS54202
- TI TPS2116 RevA §7.4/6.6: https://www.ti.com/lit/ds/symlink/tps2116.pdf
- TI TPS631000 product/RevC conditions: https://www.ti.com/product/TPS631000
- ST DS12766 STM32G070CB/KB/RB working supply: https://www.st.com/resource/en/datasheet/stm32g070kb.pdf
- Live CAD preserved by e6f9a364 compare; local parsed U_PMUXTPS2116DRLR/U_SYSTPS631000DRLR/C_OUTC2012X5R1A476M125AC/C_INC2012X5R1V226M125AC and expansionzero-ohm inspected. No physicalPCB tested.
