# T25AM — شکست Operating Point مدل TPS2116 در Altium و آزمون تفکیکی

تاریخ: 2026-09-26. **شاهد مستقیم** تصویر پنل Messages ارسالی کاربر، `image.png`، SHA256 `024dfea78f8fb1a476d4005cf65096dea87aed88a547428796c0e6906149d849`. تصویر در Git کپی نشده است. فایل مربوط: `05_TI_MODEL_INLINE_VOLTAGE_ONLY.nsx` (مدل اصلی TI به صورت inline، 200µs، باتری 1.8V).

| سطح | متن پیام Altium | برداشت مجاز |
| --- | --- | --- |
| Error | `Simulation Failed` | اجرای این fixture ناموفق. |
| Error | `Transient Analysis: Failed to Calculate the Operating Point` | تحلیل transient قبل از تولید دادهٔ معتبر در محاسبهٔ نقطهٔ کار DC متوقف شده است؛ تب SDF و محور حدود 1e20 در تصویر قبلی خروجی معتبر نیستند. |
| Warning | `v_ctrl: no DC value, transient time 0 value used` | مولد کنترلی PWL مقدار DC جداگانه ندارد؛ Altium مقدار t=0 را استفاده کرده است. **هشدار است، اثبات علت شکست نیست.** |
| Warning | `Component TPS2116_TRANS.C_U1_C4: ignored unknown parameter "TC"` و `...C_U7_C4...` | دو `TC=0,0` خازن داخلی TI در Altium نادیده گرفته می‌شوند. از تصویر نمی‌توان نشان داد که موجب عدم همگرایی‌اند. |

مستند رسمی Altium در [Simulation Troubleshooting](https://www.altium.com/documentation/altium-designer/circuit-simulation/troubleshooting) تفاوت warning غیرکشنده و error کشنده را روشن کرده و برای شکست operating point بررسی پیام‌ها، مسیر DC به زمین و وضعیت منابع را پیشنهاد می‌کند. [نمونهٔ netlist Altium](https://www.altium.com/documentation/altium-designer/circuit-simulation/working-with-spice-netlist) استفادهٔ همزمان `DC` و محرک زمانی در یک منبع را نشان می‌دهد. این‌ها مجوز افزایش بی‌دلیل تلرانس یا bypass کردن نقطهٔ کار نیستند.

## کنترل نسخه‌دار T25AM

`AI_SCRIPTS/T25/Run_T25AM_Altium_OP_v1.cmd` و `T25AM_Altium_OP_Isolation_v1.ps1` در Documents پوشهٔ `Datalogger_T25AM_Altium_OP_v1_<timestamp>` می‌سازند. پیش از نوشتن، ZIP رسمی `SLVMDI4A.ZIP` با SHA256 `730DD922475B68183CB2D3ECAC3259C8F5637E6458764CED7F3FBC0C89DA80A7` و pin-map اصلی TI بررسی می‌شوند؛ منبع فایل T25AI موجود و همان مدل inline T25AK است. اسکریپت فقط فایل آماده می‌کند، Altium را در محیط فعلی اجرا نمی‌کند.

1. `06_TI_INLINE_DC1_KEEP_TC.nsx`: همان TI model و 200µs، فقط `V_CTRL CONTROL 0 DC 1 PWL(...)` به جای بدون DC. اگر Messages بدون Error و `V(VIN_MUX)` دارای دادهٔ عددی محدود و معقول باشد، **فقط امکان حل این کنترل 200µs** ثبت می‌شود.
2. `07_TI_INLINE_DC1_ZERO_TC_REMOVED.nsx`: فقط اگر 06 ناموفق بود؛ از 06 تنها `TC=0,0` دو خازن `C_U1_C4`/`C_U7_C4` برداشته می‌شود. این مقادیر صفر بودند و در Altium نادیده گرفته شده بودند، اما فایل **دیگر عین متن مدل فروشنده نیست**. نتیجه فقط تشخیص سازگاری است.
3. اگر هر دو ناموفق‌اند، توقف و ارزیابی پیام‌ها/گره‌های داخلی؛ بدون تکرار 20ms یا گزارش PASS. فایل اصلی، CAD، BOM و اسمبلی تغییر نمی‌کنند.

**حدود:** USB در t=1ms قطع می‌شود، در حالی که تمام این آزمایش‌ها در t=200µs تمام می‌شوند؛ هیچ انتقال باتری، `3V3_SYS`، عدم ریست، پاسخ بار SD/OLED یا مجوز کارخانه آزمایش نشده است. مدل TPS2116 در PSpice سابقهٔ اختلاف با شواهد EVM دارد (T25AE)، و موفقیت solver به معنای اثبات سخت‌افزار نیست. آخرین DRC معتبر T24 همچنان 0/0 است. آزمون‌های جدید در Windows اجرا و مشاهده نشده‌اند؛ بازبینی static تعداد دو خط `TC=0,0` مطابق مدل اصلی را تأیید کرد.
