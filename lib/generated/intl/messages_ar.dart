// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ar';

  static String m0(foodName) => "تم إضافة ${foodName} إلى السلة";

  static String m1(error) => "❌ فشل في الاتصال: ${error}";

  static String m2(count) => "✅ تم بنجاح! عدد الإشعارات: ${count}";

  static String m3(phone) =>
      "أدخل الرمز المكون من 4 أرقام المُرسل إلى ${phone}";

  static String m4(error) => "خطأ في جلب الإشعارات: ${error}";

  static String m5(time) => "مفتوح حتى ${time}";

  static String m6(seconds) => "إعادة الإرسال متاحة خلال ${seconds} ثانية";

  static String m7(phone) =>
      "أدخل رمز التحقق المكون من 4 أرقام المرسل إلى ${phone}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("نبذة"),
        "add": MessageLookupByLibrary.simpleMessage("اضافة"),
        "addNewAddress":
            MessageLookupByLibrary.simpleMessage("إضافة عنوان جديد"),
        "addOrCreateAddressLabelsToEasilyChooseBetweenDeliveryAddresses":
            MessageLookupByLibrary.simpleMessage(
                "أضف أو أنشئ وسمًا للعناوين لتسهيل اختيار عنوان التوصيل."),
        "add_a_promo_code":
            MessageLookupByLibrary.simpleMessage("اضافة رمز الخصم"),
        "add_courier_tip":
            MessageLookupByLibrary.simpleMessage("إضافة إكرامية عامل التوصيل"),
        "add_credit_card":
            MessageLookupByLibrary.simpleMessage("أضف بطاقة ائتمانية جديدة"),
        "add_delivery_address":
            MessageLookupByLibrary.simpleMessage("اضافة عنوان للتوصيل"),
        "add_new_card": MessageLookupByLibrary.simpleMessage("أضف بطاقة جديدة"),
        "add_new_credit_card":
            MessageLookupByLibrary.simpleMessage("إضافة بطاقة ائتمانية جديدة"),
        "add_to_cart": MessageLookupByLibrary.simpleMessage("أضف إلى السلة"),
        "added_to_cart": m0,
        "addingExactAddressDetailsHelpsUsFindYouFaster":
            MessageLookupByLibrary.simpleMessage(
                "إضافة تفاصيل دقيقة للعنوان تساعدنا في العثور عليك بشكل أسرع"),
        "address": MessageLookupByLibrary.simpleMessage("العنوان"),
        "addressDetails":
            MessageLookupByLibrary.simpleMessage("تفاصيل العنوان"),
        "addressTypeAndLabel":
            MessageLookupByLibrary.simpleMessage("نوع العنوان والوسم"),
        "addresses_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("تم تحديث العناوين بنجاح"),
        "already_logged_in":
            MessageLookupByLibrary.simpleMessage("أنت مسجّل دخول مسبقًا"),
        "apartment": MessageLookupByLibrary.simpleMessage("شقة"),
        "apiConnectionFailed": m1,
        "apiConnectionSuccess": m2,
        "apiEndpoint": MessageLookupByLibrary.simpleMessage(
            "النقطة الطرفية: https://carrytechnologies.co/api/notifications"),
        "apiInfoTitle": MessageLookupByLibrary.simpleMessage("معلومات الـ API"),
        "apiToken": MessageLookupByLibrary.simpleMessage(
            "التوكن: fXLu7VeYgXDu82SkMxlLPG1mCAXc4EBIx6O5isgYVIKFQiHah0xiOHmzNsBv"),
        "app_settings": MessageLookupByLibrary.simpleMessage("إعدادات التطبيق"),
        "application_preferences":
            MessageLookupByLibrary.simpleMessage("تفضيلات التطبيق"),
        "back_to_edit_number":
            MessageLookupByLibrary.simpleMessage("تعديل الرقم"),
        "buildingName": MessageLookupByLibrary.simpleMessage("اسم المبنى"),
        "cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
        "card_added_successfully":
            MessageLookupByLibrary.simpleMessage("تمت إضافة البطاقة بنجاح"),
        "card_already_exist":
            MessageLookupByLibrary.simpleMessage("البطاقة موجودة بالفعل"),
        "card_deleted_successfully":
            MessageLookupByLibrary.simpleMessage("تم حذف البطاقة بنجاح"),
        "card_number": MessageLookupByLibrary.simpleMessage("رقم البطاقة"),
        "cart": MessageLookupByLibrary.simpleMessage("سلة التسوق"),
        "cartIsEmpty": MessageLookupByLibrary.simpleMessage("السلة فارغة"),
        "carts_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("تم تحديث السلة بنجاح"),
        "cash": MessageLookupByLibrary.simpleMessage("نقداً"),
        "cash_on_delivery":
            MessageLookupByLibrary.simpleMessage("الدفع عن الاستلام"),
        "category": MessageLookupByLibrary.simpleMessage("الفئة"),
        "category_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("تم تحديث التصنيف بنجاح"),
        "change": MessageLookupByLibrary.simpleMessage("تغيير"),
        "chats": MessageLookupByLibrary.simpleMessage("المحادثات"),
        "check_on_waze":
            MessageLookupByLibrary.simpleMessage("افحص الموقع على تطبيق Waze:"),
        "checkout": MessageLookupByLibrary.simpleMessage("إتمام الشراء"),
        "chooseOrderType":
            MessageLookupByLibrary.simpleMessage("اختيار نوع الطلب"),
        "choose_your_location":
            MessageLookupByLibrary.simpleMessage("برجاء تحديد موقعك"),
        "clickToPayWithRazorpayMethod": MessageLookupByLibrary.simpleMessage(
            "انقر للدفع باستخدام طريقة RazorPay"),
        "click_on_the_stars_below_to_leave_comments":
            MessageLookupByLibrary.simpleMessage(
                "انقر على النجوم أدناه لترك تعليق"),
        "close": MessageLookupByLibrary.simpleMessage("اغلاق"),
        "codeSent":
            MessageLookupByLibrary.simpleMessage("لقد أرسلنا لك رمزًا 🧏‍♂️"),
        "completeYourProfileDetailsToContinue":
            MessageLookupByLibrary.simpleMessage(
                "أكمل تفاصيل ملفك الشخصي للمتابعة"),
        "complete_order": MessageLookupByLibrary.simpleMessage("إكمال الطلب"),
        "complete_payment": MessageLookupByLibrary.simpleMessage("إكمال الدفع"),
        "confirm_payment": MessageLookupByLibrary.simpleMessage("تأكيد الدفع"),
        "confirmation": MessageLookupByLibrary.simpleMessage("التأكيد"),
        "continueBtn": MessageLookupByLibrary.simpleMessage("متابعة"),
        "continue_button": MessageLookupByLibrary.simpleMessage("استمرار"),
        "credit_card": MessageLookupByLibrary.simpleMessage("بطاقة ائتمان"),
        "cuisines": MessageLookupByLibrary.simpleMessage("المطابخ"),
        "dark_mode": MessageLookupByLibrary.simpleMessage("الوضع الداكن"),
        "dateTimeFormatDdMmYyyyHhMm":
            MessageLookupByLibrary.simpleMessage("dd/MM/yyyy HH:mm"),
        "dateTimeFormatMmmDdYyyyHhMm":
            MessageLookupByLibrary.simpleMessage("MMM dd, yyyy HH:mm"),
        "ddMMyyyy": MessageLookupByLibrary.simpleMessage("dd-MM-yyyy"),
        "debug": MessageLookupByLibrary.simpleMessage("تصحيح الأخطاء"),
        "default_credit_card":
            MessageLookupByLibrary.simpleMessage("بطاقة الائتمان الافتراضية"),
        "delete": MessageLookupByLibrary.simpleMessage("حذف"),
        "delivery": MessageLookupByLibrary.simpleMessage("توصيل"),
        "deliveryAddressOutsideRange": MessageLookupByLibrary.simpleMessage(
            "عنوانك خارج نطاق التوصيل. يرجى اختيار الاستلام من المتجر أو تغيير العنوان."),
        "delivery_20_30_mnt":
            MessageLookupByLibrary.simpleMessage("التوصيل خلال 20–30 دقيقة"),
        "delivery_addresses":
            MessageLookupByLibrary.simpleMessage("عناوين التوصيل"),
        "delivery_fee": MessageLookupByLibrary.simpleMessage("رسوم التوصيل"),
        "description": MessageLookupByLibrary.simpleMessage("الوصف"),
        "didntReceiveTheCodeResendit":
            MessageLookupByLibrary.simpleMessage("لم يصلك الرمز؟ أعد الإرسال"),
        "discount": MessageLookupByLibrary.simpleMessage("خصم"),
        "discover__explorer": MessageLookupByLibrary.simpleMessage("استكشاف"),
        "do_not_have_account":
            MessageLookupByLibrary.simpleMessage("ليس لديك حساب؟"),
        "dont_have_any_item_in_the_notification_list":
            MessageLookupByLibrary.simpleMessage("قائمة الاشعارات فارغة"),
        "dont_have_any_item_in_your_cart":
            MessageLookupByLibrary.simpleMessage("سلة التسوق فارغة"),
        "doorCode": MessageLookupByLibrary.simpleMessage("رمز الباب"),
        "doorIsOpen": MessageLookupByLibrary.simpleMessage("الباب مفتوح"),
        "doorbellIntercom":
            MessageLookupByLibrary.simpleMessage("جرس الباب / الاتصال الداخلي"),
        "edit": MessageLookupByLibrary.simpleMessage("تعديل"),
        "email": MessageLookupByLibrary.simpleMessage("البريد الإلكتروني"),
        "email_address":
            MessageLookupByLibrary.simpleMessage("البريد الإلكتروني"),
        "email_to_reset_password": MessageLookupByLibrary.simpleMessage(
            "استعادة كلمة المرور بالبريد الالكتروني"),
        "english": MessageLookupByLibrary.simpleMessage("الإنجليزية"),
        "enterAnotherAddress":
            MessageLookupByLibrary.simpleMessage("أدخل عنوانًا آخر"),
        "enterPassword":
            MessageLookupByLibrary.simpleMessage("أدخل كلمة المرور"),
        "enterThe4DigitCodeSentTo": m3,
        "enterTheDoorCode":
            MessageLookupByLibrary.simpleMessage("اكتب لنا كود الباب"),
        "enterYourEmail":
            MessageLookupByLibrary.simpleMessage("أدخل بريدك الإلكتروني"),
        "enter_here": MessageLookupByLibrary.simpleMessage("ادخل هنا"),
        "entranceStaircase":
            MessageLookupByLibrary.simpleMessage("المدخل / السلم"),
        "errorFetchingNotifications": m4,
        "error_verify_email_settings": MessageLookupByLibrary.simpleMessage(
            "البريد الالكتروني غير مسجل لدينا"),
        "estimatedTime": MessageLookupByLibrary.simpleMessage("الوقت المتوقع:"),
        "estimated_time": MessageLookupByLibrary.simpleMessage("الوقت المتوقع"),
        "expiry_date": MessageLookupByLibrary.simpleMessage("تاريخ الانتهاء"),
        "extras": MessageLookupByLibrary.simpleMessage("إضافات"),
        "faq": MessageLookupByLibrary.simpleMessage("الاسئلة الشائعة"),
        "faqsRefreshedSuccessfuly": MessageLookupByLibrary.simpleMessage(
            "تم تحديث الأسئلة الشائعة بنجاح"),
        "favorite_foods":
            MessageLookupByLibrary.simpleMessage("الأطعمة المفضلة"),
        "favorites": MessageLookupByLibrary.simpleMessage("المفضلة"),
        "favorites_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("تم تحديث المفضلة بنجاح"),
        "featured_foods":
            MessageLookupByLibrary.simpleMessage("الأطعمة المميزة"),
        "fetchAllNotifications":
            MessageLookupByLibrary.simpleMessage("جلب جميع الإشعارات"),
        "filter": MessageLookupByLibrary.simpleMessage("تصفية"),
        "first_name": MessageLookupByLibrary.simpleMessage("الاسم الأول"),
        "floor": MessageLookupByLibrary.simpleMessage("الطابق"),
        "foodRefreshedSuccessfuly":
            MessageLookupByLibrary.simpleMessage("تم تحديث الطعام بنجاح"),
        "forMoreDetailsPleaseChatWithOurManagers":
            MessageLookupByLibrary.simpleMessage(
                "لمزيد من التفاصيل، يرجى الدردشة مع مديرينا"),
        "forgot_password":
            MessageLookupByLibrary.simpleMessage("هل نسيت كلمة المرور؟"),
        "fullAddress": MessageLookupByLibrary.simpleMessage("العنوان الكامل"),
        "full_address": MessageLookupByLibrary.simpleMessage("العنوان بالكامل"),
        "full_name": MessageLookupByLibrary.simpleMessage("الاسم الكامل"),
        "g": MessageLookupByLibrary.simpleMessage("جم"),
        "goToNotificationsPage":
            MessageLookupByLibrary.simpleMessage("الذهاب لصفحة الإشعارات"),
        "go_back_checkout":
            MessageLookupByLibrary.simpleMessage("الرجوع إلى صفحة الدفع"),
        "guest": MessageLookupByLibrary.simpleMessage("زائر"),
        "haveCouponCode":
            MessageLookupByLibrary.simpleMessage("هل لديك رمز قسيمة؟"),
        "help__support": MessageLookupByLibrary.simpleMessage("المساعدة"),
        "help_support": MessageLookupByLibrary.simpleMessage("المساعدة"),
        "help_supports":
            MessageLookupByLibrary.simpleMessage("المساعدة والدعم"),
        "hi": MessageLookupByLibrary.simpleMessage("مرحبًا 👋"),
        "hint_full_address": MessageLookupByLibrary.simpleMessage(
            "المدينة المنورة ، حي الازهري ، الشارع العام ، خلف مكتبة الحرمين"),
        "home": MessageLookupByLibrary.simpleMessage("المنزل"),
        "homeAddress": MessageLookupByLibrary.simpleMessage("عنوان المنزل"),
        "home_address": MessageLookupByLibrary.simpleMessage("المنزل"),
        "house": MessageLookupByLibrary.simpleMessage("منزل"),
        "howDoWeGetIn": MessageLookupByLibrary.simpleMessage("كيف ندخل؟"),
        "how_would_you_rate_this_restaurant_":
            MessageLookupByLibrary.simpleMessage("كيف تقيّم هذا المطعم؟"),
        "iCredit": MessageLookupByLibrary.simpleMessage("ادفع الآن"),
        "i_dont_have_an_account":
            MessageLookupByLibrary.simpleMessage("لا أملك حسابًا"),
        "i_have_account_back_to_login": MessageLookupByLibrary.simpleMessage(
            "لدي حساب، العودة لتسجيل الدخول"),
        "i_remember_my_password_return_to_login":
            MessageLookupByLibrary.simpleMessage(
                "تذكرت كلمة المرور، ارجع لشاشة الدخول"),
        "include_tax":
            MessageLookupByLibrary.simpleMessage("اضف الضريبة (ان وجدت)"),
        "information": MessageLookupByLibrary.simpleMessage("معلومات"),
        "ingredients": MessageLookupByLibrary.simpleMessage("المكونات"),
        "invalidCouponCode":
            MessageLookupByLibrary.simpleMessage("رمز القسيمة غير صالح"),
        "item_subtotal":
            MessageLookupByLibrary.simpleMessage("المجموع الفرعي للعنصر"),
        "john_doe": MessageLookupByLibrary.simpleMessage("فلان الفلاني"),
        "keep_your_old_meals_of_this_restaurant":
            MessageLookupByLibrary.simpleMessage(
                "لا تفرغ السلة واحتفظ باختياراتي السابقة"),
        "languages": MessageLookupByLibrary.simpleMessage("اللغات"),
        "last_name": MessageLookupByLibrary.simpleMessage("اسم العائلة"),
        "lets_start_with_login":
            MessageLookupByLibrary.simpleMessage("لنبدأ بتسجيل الدخول!"),
        "lets_start_with_register":
            MessageLookupByLibrary.simpleMessage("لنبدأ بالتسجيل!"),
        "light_mode": MessageLookupByLibrary.simpleMessage("الوضع الفاتح"),
        "loadingRoute":
            MessageLookupByLibrary.simpleMessage("جاري تحميل المسار..."),
        "locationBasedMessage": MessageLookupByLibrary.simpleMessage(
            "بناءً على موقع هاتفك، يبدو أنك هنا:"),
        "locationFetchError":
            MessageLookupByLibrary.simpleMessage("تعذر تحديد الموقع"),
        "locationPermissionDeniedForever": MessageLookupByLibrary.simpleMessage(
            "تم رفض صلاحيات الموقع نهائياً"),
        "locationServiceDisabled":
            MessageLookupByLibrary.simpleMessage("خدمة الموقع معطلة"),
        "locationType": MessageLookupByLibrary.simpleMessage("نوع الموقع"),
        "locationTypeHint":
            MessageLookupByLibrary.simpleMessage("اختر نوع الموقع"),
        "location_type_hint": MessageLookupByLibrary.simpleMessage(
            "نوع الموقع يساعدنا في الوصول إليك بشكل أفضل، مثل: المنزل، المكتب"),
        "log_out": MessageLookupByLibrary.simpleMessage("تسجيل الخروج"),
        "login": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
        "login_icon_delivery": MessageLookupByLibrary.simpleMessage("توصيل"),
        "login_icon_quality": MessageLookupByLibrary.simpleMessage("جودة"),
        "login_icon_restaurants": MessageLookupByLibrary.simpleMessage("مطاعم"),
        "login_subtitle": MessageLookupByLibrary.simpleMessage(
            "اطلب من أفضل المطاعم واحصل على توصيل سريع"),
        "login_success":
            MessageLookupByLibrary.simpleMessage("تم تسجيل الدخول بنجاح!"),
        "login_successful":
            MessageLookupByLibrary.simpleMessage("تم تسجيل الدخول بنجاح"),
        "login_welcome":
            MessageLookupByLibrary.simpleMessage("مرحباً بك في Jetak"),
        "login_with_apple":
            MessageLookupByLibrary.simpleMessage("تسجيل الدخول عبر آبل"),
        "login_with_facebook":
            MessageLookupByLibrary.simpleMessage("تسجيل الدخول عبر فيسبوك"),
        "login_with_google":
            MessageLookupByLibrary.simpleMessage("تسجيل الدخول عبر جوجل"),
        "long_press_to_edit_item_swipe_item_to_delete_it":
            MessageLookupByLibrary.simpleMessage(
                "اضغط مطولا لتحرير العنصر، اسحب الى الجنب لحذفه"),
        "makeItDefault":
            MessageLookupByLibrary.simpleMessage("اجعله الافتراضي"),
        "maps": MessageLookupByLibrary.simpleMessage("الخرائط"),
        "maps_explorer": MessageLookupByLibrary.simpleMessage("مستكشف الخرائط"),
        "menu": MessageLookupByLibrary.simpleMessage("المينيو"),
        "messages": MessageLookupByLibrary.simpleMessage("الرسائل"),
        "more": MessageLookupByLibrary.simpleMessage("المزيد"),
        "most_ordered": MessageLookupByLibrary.simpleMessage("الأكثر طلبًا"),
        "most_popular": MessageLookupByLibrary.simpleMessage("الأكثر شهرة"),
        "multirestaurants": MessageLookupByLibrary.simpleMessage("عدة مطابخ"),
        "my_orders": MessageLookupByLibrary.simpleMessage("طلباتي"),
        "newMessageFrom":
            MessageLookupByLibrary.simpleMessage("رسالة جديدة من"),
        "new_address_added_successfully": MessageLookupByLibrary.simpleMessage(
            "تمت اضافة العنوان الجديد بنجاح"),
        "new_order_from_client":
            MessageLookupByLibrary.simpleMessage("طلب جديد من عميل"),
        "no_items_in_this_category":
            MessageLookupByLibrary.simpleMessage("لا توجد عناصر في هذه الفئة"),
        "no_restaurants_found":
            MessageLookupByLibrary.simpleMessage("لم يتم العثور على مطاعم"),
        "no_saved_cards":
            MessageLookupByLibrary.simpleMessage("لا توجد بطاقات محفوظة"),
        "no_stores_found":
            MessageLookupByLibrary.simpleMessage("لم يتم العثور على متاجر"),
        "notAvailableNow":
            MessageLookupByLibrary.simpleMessage("غير متوفر الآن"),
        "notValidAddress":
            MessageLookupByLibrary.simpleMessage("العنوان غير صالح"),
        "not_a_valid_address":
            MessageLookupByLibrary.simpleMessage("العنوان غير صالح"),
        "not_a_valid_biography":
            MessageLookupByLibrary.simpleMessage("نبذة غير صالحة"),
        "not_a_valid_cvc":
            MessageLookupByLibrary.simpleMessage("سيرة ذاتية غير صالحة"),
        "not_a_valid_date":
            MessageLookupByLibrary.simpleMessage("تاريخ غير صالح"),
        "not_a_valid_email":
            MessageLookupByLibrary.simpleMessage("بريد الكتروني غير صالح"),
        "not_a_valid_full_name":
            MessageLookupByLibrary.simpleMessage("اسم غير صالح"),
        "not_a_valid_number":
            MessageLookupByLibrary.simpleMessage("رقم غير صحيح"),
        "not_a_valid_phone":
            MessageLookupByLibrary.simpleMessage("رقم الجوال غير صالح"),
        "notificationWasRemoved":
            MessageLookupByLibrary.simpleMessage("تم حذف الإشعار"),
        "notifications": MessageLookupByLibrary.simpleMessage("إشعارات"),
        "notificationsTestTitle":
            MessageLookupByLibrary.simpleMessage("🧪 اختبار الإشعارات"),
        "notifications_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("تم تحديث الإشعارات بنجاح"),
        "nutrition": MessageLookupByLibrary.simpleMessage("العناصر الغذائية"),
        "offers_near_you":
            MessageLookupByLibrary.simpleMessage("عروض قريبة منك"),
        "office": MessageLookupByLibrary.simpleMessage("مكتب"),
        "open_until": m5,
        "optional": MessageLookupByLibrary.simpleMessage("اختياري"),
        "or_checkout_with":
            MessageLookupByLibrary.simpleMessage("أو ادفع بواسطة"),
        "order_id": MessageLookupByLibrary.simpleMessage("رقم الطلب"),
        "order_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("تم تحديث الطلب بنجاح"),
        "order_status_changed":
            MessageLookupByLibrary.simpleMessage("تم تغيير حالة الطلب"),
        "order_summary": MessageLookupByLibrary.simpleMessage("ملخص الطلب"),
        "ordered_by_nearby_first":
            MessageLookupByLibrary.simpleMessage("مرتبة حسب الأقرب أولاً"),
        "orders_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("تم تحديث الطلبات بنجاح"),
        "other": MessageLookupByLibrary.simpleMessage("أخرى"),
        "otherInstructionsForCourier":
            MessageLookupByLibrary.simpleMessage("تعليمات أخرى لمندوب التوصيل"),
        "otherInstructionsForTheCourier":
            MessageLookupByLibrary.simpleMessage("تعليمات أخرى للساعي"),
        "otherTellUsHow":
            MessageLookupByLibrary.simpleMessage("آخر (أخبرنا كيف)"),
        "otp_send_error": MessageLookupByLibrary.simpleMessage(
            "حدث خطأ أثناء إرسال رمز التحقق"),
        "otp_sent_error":
            MessageLookupByLibrary.simpleMessage("❌ فشل في إرسال رمز التحقق"),
        "otp_sent_success":
            MessageLookupByLibrary.simpleMessage("📩 تم إرسال رمز التحقق"),
        "otp_verification_error":
            MessageLookupByLibrary.simpleMessage("حدث خطأ أثناء التحقق"),
        "otp_verification_invalid":
            MessageLookupByLibrary.simpleMessage("❌ رمز غير صالح أو منتهي"),
        "otp_verification_success":
            MessageLookupByLibrary.simpleMessage("✅ تم التحقق بنجاح"),
        "password": MessageLookupByLibrary.simpleMessage("كلمه المرور"),
        "payNow": MessageLookupByLibrary.simpleMessage("ادفع الآن"),
        "pay_now": MessageLookupByLibrary.simpleMessage("ادفع الان"),
        "payment": MessageLookupByLibrary.simpleMessage("الدقع"),
        "payment_method": MessageLookupByLibrary.simpleMessage("طريقة الدفع"),
        "payment_mode": MessageLookupByLibrary.simpleMessage("طريقة الدفع"),
        "payment_options": MessageLookupByLibrary.simpleMessage("خيارات الدفع"),
        "payment_settings":
            MessageLookupByLibrary.simpleMessage("إعدادات الدفع"),
        "payment_settings_updated_successfully":
            MessageLookupByLibrary.simpleMessage(
                "تم تحديث إعدادات الدفع بنجاح"),
        "payments": MessageLookupByLibrary.simpleMessage("المدفوعات"),
        "payments_settings":
            MessageLookupByLibrary.simpleMessage("إعدادات الدفع"),
        "paypal_payment":
            MessageLookupByLibrary.simpleMessage("الدفع بواسطة Paypal"),
        "phone": MessageLookupByLibrary.simpleMessage("رقم الجوال"),
        "phoneNumber": MessageLookupByLibrary.simpleMessage("رقم الهاتف"),
        "pickup": MessageLookupByLibrary.simpleMessage("استلام"),
        "pleaseEnterOrSelectAddress":
            MessageLookupByLibrary.simpleMessage("يرجى إدخال أو اختيار عنوان"),
        "pleaseWait": MessageLookupByLibrary.simpleMessage("يرجى الانتظار..."),
        "please_enter_phone_number":
            MessageLookupByLibrary.simpleMessage("يرجى إدخال رقم الهاتف"),
        "please_fill_all_fields": MessageLookupByLibrary.simpleMessage(
            "الرجاء تعبئة جميع الحقول بشكل صحيح"),
        "profile": MessageLookupByLibrary.simpleMessage("الملف الشخصي"),
        "profile_settings":
            MessageLookupByLibrary.simpleMessage("إعدادات الملف الشخصي"),
        "profile_settings_updated_successfully":
            MessageLookupByLibrary.simpleMessage(
                "تم تحديث إعدادات الملف الشخصي بنجاح"),
        "promo": MessageLookupByLibrary.simpleMessage("الخصم"),
        "providePhoneNumber":
            MessageLookupByLibrary.simpleMessage("زوّدنا برقم هاتفك 🙅‍♂️"),
        "quantity": MessageLookupByLibrary.simpleMessage("الكمية"),
        "razorpay": MessageLookupByLibrary.simpleMessage("RazorPay"),
        "razorpayPayment": MessageLookupByLibrary.simpleMessage("دفع RazorPay"),
        "recent_orders":
            MessageLookupByLibrary.simpleMessage("الطلبات الأخيرة"),
        "refreshNotificationCount":
            MessageLookupByLibrary.simpleMessage("تحديث عدد الإشعارات"),
        "register": MessageLookupByLibrary.simpleMessage("تسجيل"),
        "register_successful":
            MessageLookupByLibrary.simpleMessage("تم التسجيل بنجاح"),
        "resend_available_in": m6,
        "resend_code": MessageLookupByLibrary.simpleMessage(
            "لم يصلك الرمز؟ إعادة الإرسال"),
        "reset": MessageLookupByLibrary.simpleMessage("إعادة تعيين"),
        "reset_cart":
            MessageLookupByLibrary.simpleMessage("إعادة تعيين سلة التسوق"),
        "reset_your_cart_and_order_meals_form_this_restaurant":
            MessageLookupByLibrary.simpleMessage(
                "افرغ سلة التسوق واضف اختياراتي من هذا المطبخ"),
        "restaurant_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("تم تحديث المطبخ بنجاح"),
        "restaurants": MessageLookupByLibrary.simpleMessage("المطاعم"),
        "reviews": MessageLookupByLibrary.simpleMessage("التعليقات"),
        "reviews_refreshed_successfully":
            MessageLookupByLibrary.simpleMessage("تم تحديث المراجعات بنجاح!"),
        "save": MessageLookupByLibrary.simpleMessage("حفظ"),
        "search": MessageLookupByLibrary.simpleMessage("بحث"),
        "search_for_restaurants_or_foods":
            MessageLookupByLibrary.simpleMessage("ابحث عن مطاعم أو أطعمة"),
        "see_all": MessageLookupByLibrary.simpleMessage("عرض الكل"),
        "select": MessageLookupByLibrary.simpleMessage("اختر"),
        "selectLocationType":
            MessageLookupByLibrary.simpleMessage("اختر نوع الموقع"),
        "select_extras": MessageLookupByLibrary.simpleMessage(
            "اختر الإضافات لإضافتها على الطعام"),
        "select_your_preferred_payment_mode":
            MessageLookupByLibrary.simpleMessage("اختر طريقة الدفع المفضلة"),
        "send_password_reset_link": MessageLookupByLibrary.simpleMessage(
            "ارسل رابط استعادة كلمة المرور"),
        "service_fee": MessageLookupByLibrary.simpleMessage("ضريبة الخدمة"),
        "settings": MessageLookupByLibrary.simpleMessage("الإعدادات"),
        "shopping_cart": MessageLookupByLibrary.simpleMessage("سلة التسوق"),
        "should_be_a_valid_email": MessageLookupByLibrary.simpleMessage(
            "يجب أن يكون بريدًا إلكترونيًا صالحًا"),
        "should_be_more_than_3_characters":
            MessageLookupByLibrary.simpleMessage("يجب أن يكون أكثر من 3 أحرف"),
        "should_be_more_than_3_letters":
            MessageLookupByLibrary.simpleMessage("يجب أن يكون أكثر من 3 أحرف"),
        "should_be_more_than_6_letters":
            MessageLookupByLibrary.simpleMessage("يجب أن يكون أكثر من 6 أحرف"),
        "sign": MessageLookupByLibrary.simpleMessage("تسجيل دخول"),
        "signinToChatWithOurManagers": MessageLookupByLibrary.simpleMessage(
            "قم بتسجيل الدخول للدردشة مع مديرينا"),
        "skip": MessageLookupByLibrary.simpleMessage("تخطي"),
        "start_exploring": MessageLookupByLibrary.simpleMessage("استكشف الآن"),
        "stores": MessageLookupByLibrary.simpleMessage("المتاجر"),
        "streetCityCountry":
            MessageLookupByLibrary.simpleMessage("شارع، مدينة، دولة"),
        "submit": MessageLookupByLibrary.simpleMessage("ارسال"),
        "subtotal": MessageLookupByLibrary.simpleMessage("مجموع الطلب"),
        "swipeLeftTheNotificationToDeleteOrReadUnreadIt":
            MessageLookupByLibrary.simpleMessage(
                "اسحب الإشعار إلى اليسار لحذفه أو تمييزه كمقروء/غير مقروء"),
        "tax": MessageLookupByLibrary.simpleMessage("ضريبة"),
        "tell_us_about_this_food":
            MessageLookupByLibrary.simpleMessage("أخبرنا عن هذا الطعام"),
        "testApiConnection":
            MessageLookupByLibrary.simpleMessage("اختبار الاتصال بالـ API"),
        "testLocalNotification":
            MessageLookupByLibrary.simpleMessage("اختبار إشعار محلي"),
        "testNotification":
            MessageLookupByLibrary.simpleMessage("إشعار تجريبي"),
        "testNotificationBody":
            MessageLookupByLibrary.simpleMessage("هذا إشعار تجريبي!"),
        "testNotificationSent":
            MessageLookupByLibrary.simpleMessage("تم إرسال الإشعار التجريبي!"),
        "testNotifications":
            MessageLookupByLibrary.simpleMessage("اختبار الإشعارات"),
        "testingApiConnection": MessageLookupByLibrary.simpleMessage(
            "جاري اختبار الاتصال بالـ API..."),
        "the_address_updated_successfully":
            MessageLookupByLibrary.simpleMessage("تم تحديث العنوان بنجاح"),
        "the_food_has_been_rated_successfully":
            MessageLookupByLibrary.simpleMessage("تم تقييم الطعام بنجاح"),
        "the_restaurant_has_been_rated_successfully":
            MessageLookupByLibrary.simpleMessage("تم تقييم المطعم بنجاح"),
        "thisFoodWasAddedToFavorite": MessageLookupByLibrary.simpleMessage(
            "تمت إضافة هذا الطعام إلى المفضلة"),
        "thisFoodWasRemovedFromFavorites": MessageLookupByLibrary.simpleMessage(
            "تمت إزالة هذا الطعام من المفضلة"),
        "thisNotificationHasMarkedAsRead":
            MessageLookupByLibrary.simpleMessage("تم تمييز هذا الإشعار كمقروء"),
        "thisNotificationHasMarkedAsUnread":
            MessageLookupByLibrary.simpleMessage(
                "تم تمييز هذا الإشعار كغير مقروء"),
        "timeFormatHhMm": MessageLookupByLibrary.simpleMessage("HH:mm"),
        "tip_check_card_info": MessageLookupByLibrary.simpleMessage(
            "• تحقق من معلومات البطاقة جيدًا."),
        "tip_contact_issuer": MessageLookupByLibrary.simpleMessage(
            "• تواصل مع الجهة المصدرة للبطاقة لتأكيد الحساب."),
        "tip_use_different_card": MessageLookupByLibrary.simpleMessage(
            "• استخدم بطاقة أخرى أو طريقة بديلة."),
        "tips_complete_order":
            MessageLookupByLibrary.simpleMessage("نصائح لإكمال طلبك"),
        "top_restaurants": MessageLookupByLibrary.simpleMessage("أفضل المطاعم"),
        "total": MessageLookupByLibrary.simpleMessage("المجموع"),
        "tracking": MessageLookupByLibrary.simpleMessage("تتبع"),
        "tracking_order": MessageLookupByLibrary.simpleMessage("تتبع الطلب"),
        "tracking_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("تم تحديث قائمة التتبع بنجاح"),
        "transaction_declined":
            MessageLookupByLibrary.simpleMessage("تم رفض المعاملة"),
        "trending_this_week":
            MessageLookupByLibrary.simpleMessage("الشائع هذا الأسبوع"),
        "twentyToThirtyMin":
            MessageLookupByLibrary.simpleMessage("20–30 دقيقة"),
        "typeToStartChat":
            MessageLookupByLibrary.simpleMessage("اكتب لبدء المحادثة"),
        "unknown": MessageLookupByLibrary.simpleMessage("غير معروف"),
        "unreadNotifications":
            MessageLookupByLibrary.simpleMessage("إشعارات غير مقروءة"),
        "useThisAddress":
            MessageLookupByLibrary.simpleMessage("استخدم هذا العنوان"),
        "validCouponCode":
            MessageLookupByLibrary.simpleMessage("رمز القسيمة صالح"),
        "verification_failed":
            MessageLookupByLibrary.simpleMessage("فشل التحقق"),
        "verification_instruction": m7,
        "verification_title":
            MessageLookupByLibrary.simpleMessage("رمز التحقق"),
        "verify": MessageLookupByLibrary.simpleMessage("التحقق"),
        "verifyCode": MessageLookupByLibrary.simpleMessage("تحقق من الرمز"),
        "verify_your_internet_connection":
            MessageLookupByLibrary.simpleMessage("تحقق من اتصال الإنترنت"),
        "verify_your_quantity_and_click_checkout":
            MessageLookupByLibrary.simpleMessage(
                "تحقق من الكمية واضغط على الدفع"),
        "version": MessageLookupByLibrary.simpleMessage("الإصدار"),
        "warning": MessageLookupByLibrary.simpleMessage("تحذير"),
        "welcome": MessageLookupByLibrary.simpleMessage("مرحبا"),
        "what_they_say": MessageLookupByLibrary.simpleMessage("آراء العملاء"),
        "work": MessageLookupByLibrary.simpleMessage("العمل"),
        "writeEmailAndPassword": MessageLookupByLibrary.simpleMessage(
            " اكتب بريدك الإلكتروني وكلمة المرور 💁‍♂️"),
        "wrong_email_or_password": MessageLookupByLibrary.simpleMessage(
            "بريد إلكتروني أو كلمة مرور خاطئة"),
        "wrong_password":
            MessageLookupByLibrary.simpleMessage("كلمة المرور غير صحيحة"),
        "youDontHaveAnyConversations":
            MessageLookupByLibrary.simpleMessage("لا توجد أي محادثات لديك"),
        "you_can_discover_restaurants": MessageLookupByLibrary.simpleMessage(
            "يمكنك استكتشاف المطابخ المحيطة بك واختيار أفضل وجبة لك"),
        "you_must_add_foods_of_the_same_restaurants_choose_one":
            MessageLookupByLibrary.simpleMessage(
                "فضلا اختيار الاصناف من مطبخ واحد في كل طلب"),
        "you_must_signin_to_access_to_this_section":
            MessageLookupByLibrary.simpleMessage(
                "يجب تسجيل الدخول لمشاهدة هذه الصفحة"),
        "your_address": MessageLookupByLibrary.simpleMessage("عنوانك"),
        "your_biography": MessageLookupByLibrary.simpleMessage("نبذة عنك"),
        "your_credit_card_not_valid":
            MessageLookupByLibrary.simpleMessage("بطاقتك غير صالحة"),
        "your_location": MessageLookupByLibrary.simpleMessage("موقعك"),
        "your_order_has_been_successfully_submitted":
            MessageLookupByLibrary.simpleMessage("تم إرسال طلبك بنجاح"),
        "your_reset_link_has_been_sent_to_your_email":
            MessageLookupByLibrary.simpleMessage(
                "تم ارسال رابط استعادة كلمة المرور الى البريد الالكتروني الخاص بك")
      };
}
