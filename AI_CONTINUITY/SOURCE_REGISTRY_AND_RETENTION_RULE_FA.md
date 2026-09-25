# Datalogger RevA — نقشهٔ اسناد و شرط حذف امن بکاپ

تاریخ: 2026-09-25. [Release خصوصی آرشیوهای تاریخی](https://github.com/mohammadhpp/Datalogger-RevA/releases/tag/continuity-archives-2026-09-25) شامل **هر سه ZIP کامل** است؛ این Release پیش‌انتشار است و مجوز تولید برد نیست. خود manifest و خروجی متنی، جای فایل‌های کامل را نمی‌گیرند. منبع شماتیک و PCB فعلی GitHub خصوصی `mohammadhpp/Datalogger-RevA/main` است. فایل‌های تاریخی صرفاً منشأ تصمیم‌ها و بازگشت به وضعیت پیشین هستند.

| فایل | اندازه (بایت) / SHA256 | دارایی کامل در GitHub خصوصی | بررسی |
| --- | --- | --- | --- |
| T22 کامل | 72,765,718؛ `22502ef489575150f849f394d5db9e67546c592243e48c0e49deb7ff9983a96b` | [ZIP اصلی در Release](https://github.com/mohammadhpp/Datalogger-RevA/releases/download/continuity-archives-2026-09-25/Datalogger_RevA_FULL_OFFLINE_CONTINUITY_BACKUP_T22_RELEASE_EXACT_2026-08-29.zip)؛ PDFهای طراحی و Purchase BOM v0.17 | بارگذاری‌شده؛ SHA-256 محاسبه‌شدهٔ GitHub مطابق اصل |
| T23 Stage2 کامل | 105,917,226؛ `1576ed0e29aa6f59926ab778dca46ab8aef43207b080da867b8cb1cce2c6cdea` | [ZIP اصلی در Release](https://github.com/mohammadhpp/Datalogger-RevA/releases/download/continuity-archives-2026-09-25/Datalogger_RevA_FULL_OFFLINE_CONTINUITY_BACKUP_T23_ROUTING_STAGE2_V3_2026-09-08.zip)؛ نام دارایی Release با اصل فرق دارد ولی هش بایت‌ها یکی است | بارگذاری‌شده؛ SHA-256 محاسبه‌شدهٔ GitHub مطابق اصل؛ فاقد PDFهای T22 |
| T25V گزیده | 7,981,136؛ `dabdbf320e9cf477cbc037c14ba7ed300d5a965c0eafb776224326cd8d098062` | [ZIP گزیده در Release](https://github.com/mohammadhpp/Datalogger-RevA/releases/download/continuity-archives-2026-09-25/Datalogger_T25V_Recovered_Design_Documents_2026-09-25.zip)؛ 39 فایل منتخب از T22 | بارگذاری‌شده؛ SHA-256 محاسبه‌شدهٔ GitHub مطابق اصل؛ جانشین T22/T23 نیست |

## چهار مدرک متنی که از این پس در خود Git قابل خواندن‌اند

1. `AI_CONTINUITY/SOURCE_ARCHIVE_REGISTRY_2026-09-25.json`: SHA256 کل هر ZIP و مسیر/اندازه/SHA256 همهٔ اعضای ۳ بسته؛ برچسب `NOT_TRACKED` فقط یعنی باینری‌ها در شاخهٔ `main` commit نشده‌اند؛ لینک Release، اندازهٔ دقیق و SHA-256 محاسبه‌شدهٔ GitHub هم در رجیستری آمده است. رجیستری فقط فهرست است.
2. `AI_CONTINUITY/T25V_PURCHASE_BOM_V017_CELL_EXPORT.json`: هر ۱۴ برگهٔ Excel تاریخی، آدرس سلول، مقدار/فرمول و cached value اگر در فایل مبنا موجود بود. `Power Calculations!B6=0.28 A`. برای ویرایش BOM یا احراز قطعات تحویلی از PDF/شماتیک و خود Excel استفاده شود.
3. `AI_CONTINUITY/T25V_RECOVERED_BLOCK_DOCUMENT_TEXT.md`: متن ۹ مأخذ پاور، MCU، MicroSD، OLED/SHT3x، RTC، کلید، توسعه و بودجهٔ پایه‌ها با مسیر اصلی/SHA. استخراج متن تصاویر/جدول‌های PDF را به‌طور کامل حفظ نمی‌کند.
4. `AI_CONTINUITY/T25V_RECOVERED_DESIGN_BASIS_AND_GAPS_FA.md`: تحلیل اعتبار و اختلافات؛ `AI_CONTINUITY/CURRENT_HANDOFF.md`: یک نقطهٔ ادامهٔ زنده.

**منشأ جریان:** طبق آخرین اصلاح کاربر، عدد نمونهٔ ۳٫۳ V قدیمی **۱۹ mA** بود؛ **تمام محاسبات پاور و انتخاب قطعات RevA با بار طراحی محافظه‌کارانهٔ ۲۸۰ mA** انجام شد. ادعای ۸۵ mA تصحیح و از نتیجه‌گیری حذف شده است. خود نمونهٔ قدیمی و شماتیک جاری یکی نیستند.

## قانون حذف فایل

اکنون هر سه فایل اصلی در GitHub **به‌صورت دارایی Release** ذخیره شده‌اند؛ هیچ‌یک به شاخهٔ `main` افزوده نشده‌اند. API گیت‌هاب وضعیت `uploaded`، اندازه و SHA-256 یکسان با اصل را برای هر سه گزارش کرد. پیش از حذف نسخهٔ قدیمیِ محلی، همان ZIP را از لینک Release روی ویندوز دوباره دانلود کنید، SHA-256 فایل بازیابی‌شده را با سطر جدول تطبیق دهید، ZIP را باز کنید/سالم بودنش را بسنجید و یک نسخهٔ مستقل دوم را نگه دارید. دانلود و آزمون ZIP بازیابی‌شده هنوز در این محیط تأیید نشده است؛ بنابراین حذف نسخهٔ یگانه یا حذف آرشیو مستقل دوم را هنوز امن اعلام نمی‌کنیم. این ZIPهای تاریخی مرجع PCB جاری نیستند.

## سازوکار جلوگیری از گم‌شدن اطلاعات

- `AI_START_HERE.md` باید **قبل از تصمیم طراحی** به این رجیستری، گزارش و متن مأخذها ارجاع دهد؛ اگر سندی در Git نبود، رجیستری محل نسخهٔ آرشیوی و SHA را نشان می‌دهد.
- `AI_SCRIPTS/Continuity/check_source_continuity.py` با Python استاندارد و بدون ویرایش فایل، وجود هفت شیت/PCB/PcbLib، یک عنوان زندهٔ handoff، هش‌های بکاپ، ۱۴ برگهٔ BOM و سلول ۰٫۲۸ A را چک می‌کند. اجرای خودکار هنگام هر push در `.github/workflows/continuity_guard.yml` نیز همین وضعیت **متنی** را کنترل می‌کند؛ موفقیت آن فقط درستی پیوستگی متنی را تأیید می‌کند؛ اثبات آنلاین موجود بودن و سلامت دارایی‌های Release از API و بازآزمایی دانلود حاصل می‌شود.
- هر تصمیم تازه باید در handoff کوتاه ثبت و در صورت تغییر طراحی، با Git/DRC همان مرحله همراه شود. هر محاسبه باید منبع، مقدار فرض‌شده، شرط اعتبار و وضعیت PASS/OPEN داشته باشد. اگر داده در منبع اصلی نیست، آن را از حافظه حدس نزنید.
