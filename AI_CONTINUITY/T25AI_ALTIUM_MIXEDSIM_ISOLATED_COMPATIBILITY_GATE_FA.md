# T25AI — مسیر عملی Altium MixedSim برای قطع USB

تاریخ 2026-09-26. وضعیت: **فایل‌های ورودی آزمون آماده شده‌اند؛ هیچ اجرای Altium یا نتیجهٔ PASS گزارش نشده است.** هیچ SchDoc/PcbDoc/PcbLib/BOM/POP و فایل کارخانه دستکاری نشد. آخرین DRC معتبر همان T24 صفر/صفر است.

## دلیل انتخاب این مسیر

- [مستندات رسمی Altium](https://www.altium.com/documentation/knowledge-base/altium-designer/run-mixed-signal-simulation-off-of-netlist-generated-externally-to-compare-the-results-from-other-engines-directly) تأیید می‌کند که Altium Designer 22 به بعد فایل متن `*.nsx` مستقل را باز می‌کند و با F9 در موتور داخلی شبیه‌سازی می‌کند. [MixedSim](https://www.altium.com/documentation/altium-designer/circuit-simulation) از SPICE3f5 و بخشی از PSpice پشتیبانی می‌کند؛ سازگاری همهٔ دستورهای مدل TI تضمین نشده است. هیچ اسکریپتی نقش موتور شبیه‌سازی را ندارد.
- ممیزی بایت‌های شماتیک زنده `01_POWER.SchDoc`، blob `da2d005712c47000eb8c16157eca464d3fee4fe1`، در [T25A](T25A_POWER_TREE_SIMULATION_MODEL_AUDIT.md) و [T25AH](T25AH_HARD_UNPLUG_ENERGY_ENVELOPE_FA.md): `C_USB1` نامی22µF روی `USB_VBUS_PROT`، PR1 مقاومت‌های30k/10k، TPS2116 ورودی USB=`USB_VBUS_PROT`، باتری=`BAT_SW`، `MODE=USB_VBUS_PROT`، خروجی=`VIN_MUX` و `C_IN` نامی22µF. `C_USB2` و `R_ST_PU` طبق workbook تاریخی initially DNP؛ POP نهایی تأیید نشده است.
- مدل رسمی TI `SLVMDI4A.ZIP` SHA256=`730DD922475B68183CB2D3ECAC3259C8F5637E6458764CED7F3FBC0C89DA80A7` متن PSpice و `.SUBCKT TPS2116_TRANS GND MODE PR1 ST VIN1 VIN2 VOUT_0 VOUT_1` دارد. اسکریپت SHA و ترتیب پایه‌ها را **پیش از تولید** می‌سنجد و مدل را در Git وارد نمی‌کند.

## فایل‌ها و گیت

`AI_SCRIPTS/T25/Run_T25AI_Altium_Prepare_v1.cmd` فایل PowerShell هم‌نام را اجرا می‌کند و در Documents پوشهٔ یکتای `Datalogger_T25AI_Altium_v1_<timestamp>` می‌سازد. ابتدا فایل رسمیِ منطبق را در Downloads می‌جوید، سپس در صورت لزوم از TI دریافت می‌کند. تمام خروجی‌ها آزمایشی‌اند:

1. `01_CORE_RC_SMOKE.nsx`: فقط موتور Altium، سوییچ ایده‌آلِ قطع منبع، C_USB1 نامی22µF، مقاومت تست330Ω و PR1 را بررسی می‌کند. Q_OVP واقعی داخل آن نیست؛ موج آزمونِ قطع کابل هم اندازه‌گیری واقعی کابل نیست.
2. `02_TPS2116_USB_UNPLUG_BAT_1p8.nsx`: مدل رسمی TPS2116، باتری ایده‌آل1.8V، C_USB1 و C_IN هرکدام22µF **اسمی**، بار سبک آزمایشی330Ω و قطع منبع upstream. این آزمون کنترل سازگاری و رفتار مدل است، نه شبیه‌سازی بار 280mA خروجی3V3.
3. `02_TPS2116_USB_UNPLUG_BAT_3p0.nsx`: کنترل همان مدار با VIN2=3V، برای جداکردن هشدار سریع‌افتِ TI زیر2.5V از اختلال خود مدل.

کاربر ابتدا `01_CORE_RC_SMOKE.nsx` را در Altium به‌صورت free document باز می‌کند و F9 می‌زند؛ تنها در صورت موفقیت، دو آزمون مدل را اجرا می‌کند. `READ_ME_FIRST.txt` داخل خروجی ترتیب و سیگنال‌ها را شرح می‌دهد. خروجیِ اجرا، Messages یا نخستین خطا و موج‌های VIN1/PR1/VIN_MUX و جریان منبع باتری باید برای تحلیل برگردد. **در این محیط Altium ویندوز اجرا نشده، سازگاری مدل اثبات نشده است.**

در [T25AE](T25AE_TPS2116_REAL_MODEL_CROSSCHECK_FA.md)، مدل رسمی در PSpice با شواهد فیزیکی/توضیح [TI E2E](https://e2e.ti.com/support/power-management-group/power-management/f/power-management-forum/1209082/tps2116-question-about-the-behavior-in-priority-mode) اختلاف داشته است. اجرای احتمالی همان مدل در Altium این اختلاف را به‌خودی‌خود رفع نمی‌کند. حتی موفقیت این تست، OVP واقعی، Ceff تضمینی، TPS631000، 3V3_SYS، SD/OLED و شرط بدون ریست را تأیید نمی‌کند؛ **پیش از ساخت PCB اصلی همچنان NO FABRICATION PASS**.
