# T25CI — اجرای مدل کنترل، مرجع دقیق و پیش‌نویس تأمین ایران

2026-10-06 UTC. مرجع CAD همچنان GitHub `mohammadhpp/Datalogger-RevA/main` در checkpoint مهندسی T24 است. این مرحله فقط مدل، دادهٔ خام، محاسبه و پیش‌نویس مدار تولید کرده است. هیچ ECO یا خریدی اعمال نشده. **FABRICATION HOLD / NO BOARD PASS.**

## نتیجهٔ قابل استفاده

برای گزینهٔ «دو رگولاتور پیش از TPS2116»، مرجع دقیق قابل اجرای محلی پیدا شد. ترکیب مدل‌های رسمی و دست‌نخوردهٔ `TLV1701` و `LM4040_ND2P5` شش fixture نامی کنترل را کامل کرد. بررسی KCL با ۸۱۹۲ ترکیب شرطی نیز پنجرهٔ استاتیک غیرتهی نشان داد. ولی آزمون وصل ناگهانی با تغذیهٔ محافظه‌کارانهٔ MON هنوز خطای عددی دارد؛ مدل دیود OR، زمان بدترین‌حالت، ریپل و مدار کامل رگولاتور/مکس تأیید نشده‌اند. گزینهٔ نهایی انتخاب نشده است.

این شش موفقیت، انتخاب واقعی TPS2116، جریان تحویلی باتری، افت MCU/SD، NRST یا سلامت نوشتن SD را آزمایش نمی‌کنند. دادهٔ `PR1` فرمان انتخاب است، نه اثبات جریان منبع یا نبود ریست.

## محیط اجرا و ممیزی خطا

`ngspice 42` از بستهٔ Ubuntu در پوشهٔ محلی استخراج شد؛ نصب سیستمی یا دسترسی به ویندوز کاربر انجام نشد. حالت PSpice و code-modelهای محلی فعال شدند. نخستین خطای بارگذاری XSPICE برطرف شد؛ این خطا شکست مدل IC نبود. Python runnerها برای هر case حد زمانی، stdout، stderr، deck و log را حفظ می‌کنند. returncode=0 به‌تنهایی موفقیت نیست: عبارت `tran simulation(s) aborted` و زمان پایانی داده نیز بررسی شدند.

بستهٔ داده، لاگ‌های ناقص و کامل را با هم حفظ می‌کند. برای بازاجرا در Linux از `NGSPICE_BIN` و در صورت نیاز `NGSPICE_CMODEL_DIR` استفاده شود؛ مدل‌ها باید در ساختار پوشهٔ `AI_EVIDENCE/T25CI/vendor` استخراج شوند. numpy برای تحلیل گوشه‌ها لازم است. fixtureها ورودی درخواست مجدد Windows نیستند.

| اجرای واقعی | نتیجه و محدوده |
| --- | --- |
| TLV431 TINA، Rbias=10k، MON آرمانی 3.3V | REF اولیه 1.148922V نامعتبر؛ گذرا در 9.478916ms متوقف شد؛ آخر USB=2.798042V. post-step مردود |
| همان fixture، Gear/50ns | timeout دیواری 40s؛ دادهٔ جدید ایجاد نشد؛ مقدار پیش‌حالت همچنان نامعتبر. پیشرفت شبیه‌سازی UNKNOWN |
| TLV431 PSpice جداگانه، 100/200µA | خروجی DC به‌ترتیب 1.058467/1.138759V؛ نامعتبر برای مرجع نامی 1.24V |
| TLV431، 1/10mA | 1.240237/1.242500V؛ فقط مقدار DC مدل در شرایط fixture |
| TLV1701 جداگانه، ±100mV ورودی | 30µs کامل، 5187 سطر؛ runtime و منطق نامی مدل محدود |
| پیش‌نویس TLV431 با Rbias_USB=1k و RS=5.1k | رمپ آرام، hard-unplug و دو حالت ثابت کامل؛ hard-attach و recovery ناقص. یک مقایسهٔ Gear نیز ناقص؛ مسیر تکرار بسته |
| LM4040-N D2.5، 9 مقدار DC | TOL=-1/0/+1 در 100/300/1000µA کامل. TOL=0 حدود 2.496107..2.496547V؛ TOL=-1 حدود 2.473513..2.473949V، کمی زیر حد 25°C=2.475V. پارامتر TOL معادل تأیید همهٔ گوشه‌های قطعه نیست |
| LM4040-N + TLV1701، MON آرمانی 3.3V | هر شش fixture کامل، بدون solver-abort؛ فقط مدار کنترل نامی |
| MON شرطی OR با افت ثابت 0.41V | USB-only آرام، hard-unplug با backup آماده و plateau/recovery کامل؛ دو hard-attach ناقص در گرهٔ داخلی مرجع |
| افزودن فیزیکی پیشنهادی C_REF=100n | USB-only hard-attach کامل شد؛ battery-ready hard-attach هنوز ناقص. این تغییر به مدل vendor اعمال نشده و به‌عنوان گزینهٔ ECO ثبت نشده است |

**طبقه‌بندی:** اجراهای فوق `ACTUAL_TEST_WITH_RAW_EVIDENCE` با حدود صریح‌اند. مدار کامل `BLOCKED_BY_NAMED_MODEL_OR_INSTRUMENT` باقی است. بار **19 mA** مشاهدهٔ نمونهٔ قدیمی با پهنای‌باند نامعلوم؛ **280 mA** سقف طراحی تاریخی است. هیچ‌کدام پروفایل اندازه‌گیری‌شدهٔ card/OLED نیست.

## چرا TLV431 دیگر مسیر فعال نیست

[مدل PSpice رسمی SLIM005](https://www.ti.com/lit/zip/SLIM005) در توضیح «v2، حذف encryption» آمده، اما هستهٔ الکتریکی با مدل قدیمی TINA یکسان است؛ مدل تازهٔ رفتاری پیدا نشد. فایل‌های اصلی اصلاح نشدند. نتیجهٔ غیرمنتظره در جریان کم می‌تواند محدودیت مدل/تفسیر simulator باشد و شکست قطعهٔ واقعی را ثابت نمی‌کند. افزایش bias به حدود 2mA صرفاً برای معتبر کردن مدل، مصرف نامناسبی به مدار monitor تحمیل می‌کند؛ مرجع جایگزین با مدل خودش بررسی شد.

[TLV431 TI SLVS139Z](https://www.ti.com/lit/ds/symlink/tlv431.pdf): grade AI به -40..85°C محدود است؛ حد VREF در IK=10mA داده شده. impedance دینامیکی، ضمانت مستقل خطای DC در 150µA نیست. pinهای DBZ: 1 REF، 2 cathode، 3 anode. TLV431AIDBZR با DBV پنج‌پایه یا LM4040-N هم‌پین نیست.

## مدار کنترل جدید، فقط پیش‌نویس

| گره / عنصر | اتصال و مقدار پیشنهادی |
| --- | --- |
| USB_REG | خروجی USB buck مستقل؛ تنظیم T25CH، 91k / دو10k؛ VIN1 TPS2116 |
| BAT_REG | خروجی TPS631000/L1 حفظ‌شده؛ VIN2؛ باید هنگام USB آماده بماند |
| MON | OR دیودی دو ریل؛ bypass مستقل 100nF. به VOUT مکس وابسته نیست تا USB-only cold-start قفل نشود |
| LM4040DIM3X-2.5 | cathode→REF، anode→GND؛ Rbias=2.4k از USB_REG. بنابراین bias مرجع هنگام نبود USB عمدتاً از AA گرفته نمی‌شود |
| sense | USB_REG→دو1k سری→IN+؛ 10k از IN+ به GND؛ 100k از OUT به IN+ برای hysteresis |
| TLV1701 | IN−→REF؛ V+→MON؛ V−→GND؛ OUT open-collector |
| فرمان | 10k از USB_REG به OUT؛ 5.1k از OUT به PR1؛ 10k از PR1 به GND؛ MODE→USB_REG |
| C_REF | 100nF یک sensitivity فیزیکی جدید است؛ هنوز تصویب/انتخاب نشده |

MON از ریل باتری خام 1.80V تأمین نمی‌شود: TLV1701 حد تغذیه 2.2V دارد. اتصال MON به 3V3_SYS نیز cold-start USB-only را بدون اثبات حل نمی‌کند. fixtureهای نامی اولیه MON=3.3V آرمانی دارند؛ نام فایل `usb_only_static` تنها نبود وابستگی باتری در معادلات را بررسی می‌کند، نه راه‌اندازی واقعی دیود/رگولاتور.

[TLV1701 TI SBOS589D](https://www.ti.com/lit/ds/symlink/tlv1701.pdf): pinهای SOT23-5 به‌ترتیب 1 IN+، 2 V−، 3 IN−، 4 OUT، 5 V+. ورودی‌ها clamp به ریل دارند و در بیرون ±0.5V باید جریان ≤10mA شود. Vos full-temp ±5.5mV و Ib max20nA است؛ Iq full-temp max100µA. output leakage=70nA و delayهای 460/560ns **typical** هستند. حد VOL=900mV **MAX** در 25°C/VS=36V/100mV overdrive آمده؛ حداکثر تضمین‌شدهٔ مستقل در MON≈2.8V و full-temp نیست. به همین دلیل RS/pulldown برای حاشیهٔ فرمان بررسی شد، ولی qualification کامل نیست.

## مرجع درست، مدل درست و تفاوت پایه‌ها

قطعهٔ لیست ایران `LM4040DIM3X-2.5` متعلق به **LM4040-N** است، نه سری جدید `LM4040D25IDBZR`. [دیتاشیت درست TI SNOS633N](https://www.ti.com/lit/ds/symlink/lm4040-n.pdf)، grade D/I: در 100µA، خطای ±25mV در 25°C و ±49mV در -40..85°C؛ حداقل جریان full-temp70µA؛ تغییر جریان تا1mA max1.2mV. محاسبه از REF=2.4498..2.5502V استفاده می‌کند. مدل [SNOM542](https://www.ti.com/lit/zip/SNOM542) صریحاً `LM4040_ND2P5` است و TOL توسط خود vendor دارد.

**LM4040-N SOT23:** pin1 cathode→REF، pin2 anode→GND، pin3 باید شناور یا به anode متصل شود؛ برای مدار سوئیچینگ pin3→GND در draft. این نقشه با TLV431 DBZ متفاوت است. فروشگاه suffix `/NOPB` نشان نمی‌دهد؛ سفارش آن suffix نباید از روی نام پایه فرض شود. current TI ordering باید در فهرست نهایی حل شود.

## دادهٔ KCL و حاشیهٔ شرطی

برای حس‌کردن USB و positive-feedback، بار RS/RPD، leakage PR1 و offset comparator در معادلات لحاظ شدند. `T25CI_Monitor_Corners_v1.py` دادهٔ کامل 8192 سطر را نگه می‌دارد. مقاومت‌ها Rt2k±1%، Rb10k±0.5%، Rh100k±1%، Rpu10k±0.5%، Rs5.1k±1% و Rpd10k±0.5% هستند. source floor3.185094V همان bound استاتیک T25CH است.

| کمیت | تلرانس اولیهٔ مقاومت | sensitivity اضافهٔ ±100ppm/°C تمام مقاومت‌ها، ΔT65°C |
| --- | ---: | ---: |
| آستانهٔ افت | 2.938193..3.089328V | 2.931708..3.096395V |
| آستانهٔ وصل | 2.956098..3.126733V | 2.949472..3.134188V |
| کمترین hysteresis در همان corner | 16.497mV | 16.043mV |
| کمترین PR1 در USB سالم | 1.248805V | 1.238795V |
| بیشترین PR1 پایین، با VOL scenario0.9 | 0.599382V | 0.601987V |
| حاشیهٔ وصل تا USB_min | 58.361mV | 50.906mV |

70nA خروجی typical است؛ 10µA یک **سناریوی leakage** است، نه MAX سازنده. TCRهای جدول دوم نیز exact-MPN qualification نیستند. USB FB TCR/ripple/load-drop هنوز به floor پایه افزوده نشده‌اند؛ لذا جدول PASS نهایی نیست. کمینه/بیشینهٔ مستقل دو آستانه را از دو corner متفاوت برای محاسبهٔ hysteresis تفریق نکنید.

Rbias2.4k±1% با bound مرجع، جریان262..414µA در محدودهٔ USB سالم می‌دهد؛ در کوچک‌ترین آستانهٔ افت sensitivity، حدود157µA باقی می‌ماند. همه از70µA بالاتر و از1mA پایین‌ترند. boundهای حرارتی Rbias و افت ولتاژ واقعی مستقل هنوز بررسی نهایی می‌خواهند. nominal USB fixture در حالت سالم ~0.743mA به مجموعهٔ کنترل می‌دهد؛ این جریان main-load دستگاه نیست.

در raw model، هنگام USB=0 حدود2.11µA به منبع آرمانی صفرولت بازمی‌گردد. این عدد اثر fixture/model است، نه اندازه‌گیری جریان برگشت واقعی به AA یا USB. مسیرهای دیود monitor، pin clamps، reverse buck و TPS631000 باید جداگانه بررسی شوند.

## تأمین ایران، بدون سفارش

raw HTML و SHA-256 هر صفحه در بستهٔ شواهد است؛ موجودی اعلام فروشنده در 2026-10-06، نه رزرو یا اصالت فیزیکی قطعه.

| نام دقیق در صفحه | تعداد نصب draft | فروشنده / موجودی اعلام‌شده | وضعیت |
| --- | ---: | --- | --- |
| TLV1701AIDBVR | 1 | [Lion4354](https://lionelectronic.ir/products/4354-TLV1701AIDBVR)،64 | نام دقیق؛ technical full-temp/timing OPEN |
| LM4040DIM3X-2.5 | 1 | [Lion2505](https://lionelectronic.ir/products/2505-LM4040DIM3X-2.5)،889 | grade/model تطبیق؛ suffix نهایی OPEN |
| BAS7004E6327HTSA1 | 2 | [Lion4597](https://lionelectronic.ir/products/4597-BAS7004E6327HTSA1)،424 | OR candidate، یک دیود از هر package |
| TLV431AIDBZR | 0 در مسیر جدید | [Lion3304](https://lionelectronic.ir/products/3304-TLV431AIDBZR)،1297 | مسیر قبلی کنار گذاشته شده؛ خرید نشود |
| AC0603FR-0713K7L | 0 در مسیر جدید | [Lion6693](https://lionelectronic.ir/products/6693-AC0603FR-0713K7L)،3200، MOQ100 | برای Rt13.7k قدیمی؛ به BOM جدید افزوده نشود |

دیود [Infineon BAS70-04](https://www.infineon.com/part/BAS70-04) سری است، **common-cathode نیست**. طبق شکل صفحهٔ1، D1 از pin1 anode به pin3 cathode است؛ برای هر شاخه pin1→source، pin3→MON، pin2 NC. استفاده از دو package برای OR درست ثبت شود. VFmax410mV@1mA و IRmax0.1µA@50V فقط در25°C هستند؛ منحنی حرارتی max تضمین‌شده نیست. مدل دقیق Infineon در صفحهٔ محصول پیدا نشد؛ BMON با افت ثابت0.41V جای آن را برای qualification نمی‌گیرد. full-temp supply/AA-backfeed OPEN.

انواع مقاومت/خازن از موجودی طراحی: `0805W8F1001T5E` ×2 sense، `ARG05DTC1002` ×3، `0603WAF1003T5E` ×1، `FRC0603F5101TS` ×1، `0603WAF2401T5E` ×1، `CL10B104KB8NNNC` ×1 bypassMON و احتمالا ×1C_REF. این‌ها **تعداد اضافی** هستند؛ وجود همین MPN روی برد به معنی داشتن spare نیست. قطعات retained FB، CC1/CC2 Rd، OLED/SD bypass برد از جای خود برداشته نشوند. برای فهرست خرید نهایی spare/ایران exact/TCR باید احراز شود.

جست‌وجوی catalog Lion برای TLV3011/3012، TPS3700/3710/3702 و چند comparator دیگر نتیجهٔ دقیق نداد؛ جست‌وجوی وب ایران هم listing معتبر فراهم نکرد. این فقط **عدم احراز در جست‌وجوی فعلی** است، نه اثبات عدم عرضه در ایران. MAX809 و supervisor120..300ms قبلی نیز به‌عنوان راه فوری انتخاب نشده‌اند.

## کار باقی‌مانده و مسیر اجرا

1. monitor هنوز باید مدل واقعی diode-OR/boot/full-temp یا شواهد سازندهٔ معادل معتبر بگیرد؛ دو hard-attach در MON پایین شکست numerical دارند. افزایش کورکورانهٔ timer یا مدل‌سازی ideal reference به‌جای vendor مجاز نیست. C_REF100n نتیجهٔ universal ندارد و فعلاً انتخاب نشده.
2. تاخیر قطعه و mux حداکثر تضمین‌شده ندارد؛ hysteresis min≈16mV با ریپل واقعی سنجیده نشده. bound 51mV وصل، شامل ریپل/افت buck نیست. منبع همیشه‌آمادهٔ BAT باید به‌طور دینامیکی ≥2.5V بماند.
3. TPS631000 فقط مدل encrypted رسمی دارد؛ bounded PSpice prestate قبلی معتبر نبود. TPS54202 bounded startup timeout و TPS2116 discrepancy قبلی باقی‌اند. ngspice کنترل جدید رمزگشایی یا اصلاح این سه مدل را انجام نمی‌دهد. هیچ Windows rerun قدیمی درخواست نشود.
4. ظرفیت مؤثر C_OUT/Cbus، ESR، پروفایل actual load و fault source12V بازند. SD sub-gate T25BK/T25BL باز نشود. 3V3 buck جدید، rail توسعهٔ5V را جایگزین نمی‌کند؛ USB_5V_AUX همچنان حفاظت مستقل می‌خواهد.
5. پیش‌نویس کامل مسیرها/قطعات/مرز کاربرد و آزمون باید یک‌جا آماده شود؛ تنها بعد از بسته‌شدن فنی، تصمیم واحد ECO/خرید. S1 دقیق به دستور کاربر مؤجل است.

**NEXT EXECUTABLE ACTION:** ادامهٔ حفاظت USB_5V_AUX و جمع‌بندی full-power draft، exact capacitor/BOM و model-gap table. هیچ تغییر CAD یا سفارش جزءبه‌جزء. **BLOCKER REQUIRING USER:** برای بررسی مستقل فعلی هیچ؛ qualification دینامیکی کامل نیازمند مدل قابل‌اجرا/معتبرِ قطعات پاور و دادهٔ actual source/load/Ceff است، هنوز آمادهٔ درخواست هزینه/ساخت نیست.
