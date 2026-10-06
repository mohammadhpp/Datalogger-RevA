# T25CH — مقایسهٔ معماری و اثبات محدودیت PR1
Date: 2026-10-06 UTC. Baseline main 4b2ef993972ac40c57fdb6c38f6700aa278625b6.
Status: ACTUAL_TEST_WITH_RAW_EVIDENCE — static corner proof / conditional energy and source budgets.
Integrated dynamics: BLOCKED_BY_NAMED_MODEL_OR_INSTRUMENT. NO BOARD PASS / FABRICATION HOLD.

## نتیجهٔ قابل تصمیم
نسخهٔ پایین‌دستِ T25CG با تنظیم USB نزدیک3.3V و تقسیم مقاومتی سادهٔ PR1، راهکار کامل نیست. محاسبهٔ corner نشان می‌دهد با مقاومت‌های±0.5% هیچ نسبت مقاومتی نمی‌تواند هم USB سالم را در تمام cornerها انتخاب کند و هم قبل از افت rail به2.7V انتقال دهد. این ردِ همان گزینه و فرض‌هاست، نه رد تمام معماری‌های پایین‌دست. جابه‌جاییmux به‌تنهایی مسئله را حل نمی‌کند.

مانیتور دقیق TPS3823-33DBVR واقعاً در صفحهٔ Lion با موجودی اعلام‌شده1300 پیدا شد؛ گزینش فنی/خرید نشده. تأخیر ورودUSB120..300ms و پاسخ افت25us فقط nominal در شرایط آزمون25°C هستند. این قطعه بدون بررسی بیشتر، پاسخ فوری یا no-reset تضمین‌شده نمی‌دهد. MAX809TEUR+T و MAX809S در همان فروشگاه «به زودی» هستند؛ MAX809S به دیتاشیتUMW لینک می‌شود و جایگزین دقیق ADI با همان مشخصات محسوب نمی‌شود. جستجوی عمومی ناموفق به معنی نبود قطعه در سراسر ایران نیست.

## مقایسهٔ مشخص
| موضوع | mux پیش از TPS631000، با USB preregulator T25CE | دو regulator پیش از mux، پیش‌نویس T25CG/CH |
|---|---|---|
| پک1.80V | mux در مسیر جریان بزرگِ ورودیconverter؛ نیاز به اثبات افت/منبع | mux از مسیر پرجریانAA حذف، ولیconverter هنوز باید280mA را از1.80V بدهد |
| قطع سریعUSB | VIN2 خام1.80V؛ شرط fast-collapse دیتاشیت بسته نیست | VIN2 تنظیم‌شده فقط در صورت ready ماندن دینامیکی>=2.5V کمک می‌کند |
| standby هنگامUSB | converter مشترک ازUSB تغذیه می‌شود | converter باتری روشن می‌ماند؛ جریان پک صفر نیست |
| ولتاژUSB |3.576V پیش ازconverter مجازبودن وابسته به ورودی‌ها | candidate3.3078V، corner3.185094..3.432960V؛ همهٔ بارها/ripple هنوز لازم |
| اولویتUSB | divider قبلی با USB3.576V حاشیهٔ static دارد؛ دینامیک باز | divider سادهٔ candidate رد؛ highest-voltage هم به علت هم‌پوشانی دو rail اولویت را تضمین نمی‌کند |
| خازن | C_IN/C_OUT و افتUSB باید در مدار واقعی بررسی شوند | C_OUT برایconverter می‌ماند؛ Cbus جدید پس ازmux جدا لازم |
| تغییرPCB | شاخهٔUSB جدید؛ مسیر اصلیpower عمدتاً حفظ | تغییرbattery/USB/mux/3V3، Cbus و مدارmonitor؛ layout گسترده‌تر |
| وضعیت | fast-collapse/source/OVP/system باز | passive PR رد؛ monitor/dynamics/sourcing کلBOM باز |

هیچ معماری برندهٔ نهایی انتخاب نشد. مسیر پایین‌دست تنها با monitor دقیق و backup آماده ارزش ادامه دارد؛ مسیر بالادست تنها با افتUSB کنترل‌شدهٔ معتبر. مدل‌های نامعتبر قبلی و timeout، حکم خرابیhardware هیچ‌کدام نیستند.

## محاسبهٔ اجراشده و counterexample
USB FB پیشنهادی از نوع91k±1% موجود `0805W8F9102T5E` و دو10k±0.5% نوع `ARG05DTC1002` ساخته می‌شود؛ مصرف اضافی/موجودی خرید احراز نشده و resistor اصلیTPS631000 برداشته نمی‌شود. VFB USB=.581..611V. باتری همان510k/91k±1% با VFB=.495..505V: nominal3.302198 و corner3.214242..3.392396V. این‌ها فقط FB/resistor corners هستند؛ ripple، leakage و dynamics را شامل نیستند.

برای k=Rtop/Rbottom و tolerance برابرt:
`k_min=(Vfloor/0.92-1)*(1+t)/(1-t)`
`k_max=(Vusb_min/1.08-1)*(1-t)/(1+t)`
وجود k در این بازه شرط ضروری است؛ leakage/gap فقط حاشیه را بدتر می‌کند.

درfloor2.7V وt=.005، k_min=1.954228 > k_max=1.929767؛ بازه خالی است. با مقاومت آرمانی وfloor2.72V نیز بازه خالی می‌شود. 20mV صرفاً allowance سناریویی است، حد افتSD-switch تأییدشده نیست. نمونهٔ20k/10k قبلی max threshold3.261709V و margin اتصالUSB=-76.615mV دارد. نمونهٔ18k/10k min threshold2.551284V دارد؛ در افت آهسته و توقفUSB روی2.65V همچنانUSB انتخاب می‌ماند، پایین‌تر ازمرجعSD2.7V. هیچCbus متناهی افتِ پایدار زیرحد را درمان نمی‌کند.

اسکریپت `AI_SCRIPTS/T25/T25CH_Architecture_Corners_v1.py` اجرا شد:9 پنجرهٔdivider،48 energy budget و6 source budget؛ CSV/JSON خام در AI_EVIDENCE/T25CH. 19 mA مشاهدهٔprototype قدیمی باbandwidth نامعلوم؛280 mA envelope طراحی است. total-gap31.2us جمع دو مقدارtypical است،75/200us فقط حساسیت. انرژی شاملESR/RCB/سیم/مدلبار نیست؛ هیچcase به عنوانsystem PASS طبقه‌بندی نشده. درسناریوی شروع2.86V و280mA،47uF مؤثر فقط19.868us را تا2.72V پوشش می‌دهد؛75us کلinterval به177.419uF مؤثر نیاز دارد. این یک بودجهٔمشروطِ تماماًبدون‌منبع است، نه اثباتزمانوقوع یا نیازقطعیphysicalboard. تست1.80V هنوز مستقل لازم است؛ بودجهٔمقاومت از توان/بازده70/80/90% سناریویی وfloor1.65V به دست آمده، ضمانت راندمانیاجریانconverter نیست. RON جدول200mA در جریان‌های دیگر فقط فرض حساسیت است.

## monitor دقیق: پیش‌نویس اتصال و گیت باز
TPS3823-33DBVR: pin1 RESET(active-low)→PR1؛pin2GND؛pin3MR→USB_REG؛pin4WDI باز طبقTI برای غیرفعال‌کردنwatchdog؛pin5VDD→USB_REG. RESET اینجا سیگنال انتخاب منبع است و بهNRST MCU وصل نمی‌شود. MODE→VIN1 مطابقpriority wiring؛ حالات absent/ramp باید مستقل بررسی شوند.
- Threshold falling2.86..3.00V در-40..85°C، hysteresis30mVtyp؛ release120..300ms تحت شرایطtimingجدول. این تأخیر نباید به عنوانUSB-priority فوری معرفی شود یا خواستهٔکاربر پنهانی تغییر کند.
- High output spec در VDD=VIT-+0.2V وload30uA؛ cornerUSB3.185V ازشرط محافظه‌کارانه3.20V پایین‌تر است. بنابراین logic-high margin زیرripple هم فعلاً بسته نیست.
- Pulldown پیش‌نویسPR1 دو100k1% نوع موجود `0603WAF1003T5E` درseries است: جریانhigh<18uA درmaxrail، leakPR1=.1uA فقط~20.2mV ایجاد می‌کند. این اتصال پیش‌نویس است؛ عملکردunpowered supervisor/transition/leakage مستقل لازم است. Pullup بهbattery برای این push-pull پیشنهاد نشده.
- Bypass100nF جدا ازC_OLED لازم؛ MPN/quantity/budget کامل هنوز بسته نشده. نسخهٔمعمول -33DBVR طبقTI تا85°C است؛125°C فروشگاه بااینMPN منبع specification نیست و نسخهٔA جایگزین خودکار نیست.
- مانیتور، افتCbus/RCB/backup recovery و reverse leakage بهپک را تضمین نمی‌کند. بازهٔfall timing max برای کلcornerها موجود نیست؛25usnom را max ننویس.

StandbyTPS631000: divider نامی~5.495uA ازVOUT، IQ VOUTtyp8uA و IQ VINtyp.15uA باشرایط متفاوت‌اند؛ تبدیل بهجریانپک بهنشتی/بازده/میزانpulse بستگی دارد. headline8uA را battery-pack maximum معرفی نکن. Shutdownباتری هنگامUSB با EN/startup delay سازگاربا backup آماده نیست.

## اقدام دقیق بعدی و حد فعلی
1. شاخهٔdownstream باpassivePR دیگر تکرار نشود. برایmonitor باید logic/threshold/ripple، افت پاسخ و تأخیرattach باخواستUSBpriority بسته شود؛ TPS3823 فقط کاندیدِایران‌قابل‌تأمین است.
2. قبل ازهرتستvendor تازه، rail prestate معتبرTPS631000 درloaded1.80V وUSBregulator،Ceff تحتbias ومدلmux قابل‌اعتماد لازم است. bounded TPS54202،TPS631000 وTPS2116 مسیرهای گذشته قابل اتکا نیستند؛ rerunWindows بدون تغییرمعتبر تولید نشد.
3. برایانتخابwhole-power بایدcapacitor/BOM/5V expansion fault branch/OVP/system matrix کامل شود. T25BK/BLSD و L1/U_SYS حفظ؛ exactS1طبقکاربر deferred.
No CAD/ECO/purchase/fabrication change. Independent work is authorized; no routine confirmation requested. Model/source/dynamic evidence is the named remaining blocker, not user's permission.

## منابع و evidence
- TI TPS2116 RevA §6.5, §7.3.1/7.4/7.6: https://www.ti.com/lit/ds/symlink/tps2116.pdf
- TI TPS631000 RevC: https://www.ti.com/lit/ds/symlink/tps631000.pdf
- TI TPS54202 RevC: https://www.ti.com/lit/ds/symlink/tps54202.pdf
- TI TPS382x SLVS165O, ordinaryTPS3823 electrical/timing/pins: https://www.ti.com/lit/ds/symlink/tps3823.pdf
- ADI MAX803/MAX809/MAX810 Rev11 (not UMW): https://www.analog.com/media/en/technical-documentation/data-sheets/MAX803-MAX810Z.pdf
- Iran listing snapshots/hashes/excerpts: AI_EVIDENCE/T25CH/iran_supervisor_sources.json and TPS3823_Lion_excerpt.html. Dates2026-10-06UTC; stock is retailer declaration at retrieval, no purchase/reservation/identity authentication.
