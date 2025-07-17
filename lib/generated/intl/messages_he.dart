// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a he locale. All the
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
  String get localeName => 'he';

  static String m0(foodName) => "${foodName} נוסף לעגלה";

  static String m1(error) => "❌ נכשל החיבור: ${error}";

  static String m2(count) => "✅ הצלחה! מספר התראות: ${count}";

  static String m3(phone) => "הזן את הקוד בן 4 הספרות שנשלח ל-${phone}";

  static String m4(error) => "שגיאה בשליפת התראות: ${error}";

  static String m5(time) => "פתוח עד ${time}";

  static String m7(id) => "הזמנה: #${id} בוטלה";

  static String m6(foodname) => "ה${foodname} הוסר מהעגלה שלך";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "Enter_password": MessageLookupByLibrary.simpleMessage("הזן סיסמה"),
        "Enter_your_email":
            MessageLookupByLibrary.simpleMessage("הזן את כתובת האימייל שלך"),
        "HHmm": MessageLookupByLibrary.simpleMessage("HH:mm"),
        "MMMddyyyyHHmm":
            MessageLookupByLibrary.simpleMessage("MMM dd, yyyy • HH:mm"),
        "Sign": MessageLookupByLibrary.simpleMessage("הרשמה"),
        "about": MessageLookupByLibrary.simpleMessage("אודות"),
        "add": MessageLookupByLibrary.simpleMessage("הוסף"),
        "addNewAddress":
            MessageLookupByLibrary.simpleMessage("הוסף כתובת חדשה"),
        "addOrCreateAddressLabelsToEasilyChooseBetweenDeliveryAddresses":
            MessageLookupByLibrary.simpleMessage(
                "הוסף או צור תוויות כתובת כדי לבחור בקלות בין כתובות המשלוח."),
        "add_credit_card":
            MessageLookupByLibrary.simpleMessage("הוסף כרטיס אשראי חדש"),
        "add_delivery_address":
            MessageLookupByLibrary.simpleMessage("הוסף כתובת למשלוח"),
        "add_new_card": MessageLookupByLibrary.simpleMessage("הוסף כרטיס חדש"),
        "add_new_credit_card":
            MessageLookupByLibrary.simpleMessage("הוספת כרטיס אשראי חדש"),
        "add_new_delivery_address":
            MessageLookupByLibrary.simpleMessage("הוסף כתובת למשלוח חדשה"),
        "add_to_cart": MessageLookupByLibrary.simpleMessage("הוסף לעגלה"),
        "added_to_cart": m0,
        "addingExactAddressDetailsHelpsUsFindYouFaster":
            MessageLookupByLibrary.simpleMessage(
                "הוספת פרטי כתובת מדויקים עוזרת לנו למצוא אותך מהר יותר"),
        "address": MessageLookupByLibrary.simpleMessage("כתובת"),
        "addressDetails": MessageLookupByLibrary.simpleMessage("פרטי הכתובת"),
        "addressTypeAndLabel":
            MessageLookupByLibrary.simpleMessage("סוג הכתובת ותווית"),
        "addresses_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("כתובות רעננו בהצלחה"),
        "all": MessageLookupByLibrary.simpleMessage("הכל"),
        "all_menu": MessageLookupByLibrary.simpleMessage("כל התפריט"),
        "already_logged_in":
            MessageLookupByLibrary.simpleMessage("אתה כבר מחובר"),
        "apartment": MessageLookupByLibrary.simpleMessage("דירה"),
        "apiConnectionFailed": m1,
        "apiConnectionSuccess": m2,
        "apiEndpoint": MessageLookupByLibrary.simpleMessage(
            "נקודת קצה: https://carrytechnologies.co/api/notifications"),
        "apiInfoTitle": MessageLookupByLibrary.simpleMessage("מידע על ה-API"),
        "apiToken": MessageLookupByLibrary.simpleMessage(
            "טוקן: fXLu7VeYgXDu82SkMxlLPG1mCAXc4EBIx6O5isgYVIKFQiHah0xiOHmzNsBv"),
        "app_language": MessageLookupByLibrary.simpleMessage("שפת האפליקציה"),
        "app_settings": MessageLookupByLibrary.simpleMessage("הגדרות אפליקציה"),
        "application_preferences":
            MessageLookupByLibrary.simpleMessage("העדפות האפליקציה"),
        "apply_filters": MessageLookupByLibrary.simpleMessage("החל סינון"),
        "areYouSureYouWantToCancelThisOrder":
            MessageLookupByLibrary.simpleMessage(
                "האם אתה בטוח שברצונך לבטל הזמנה זו?"),
        "buildingName": MessageLookupByLibrary.simpleMessage("שם המבנה"),
        "cancel": MessageLookupByLibrary.simpleMessage("ביטול"),
        "cancelOrder": MessageLookupByLibrary.simpleMessage("בטל הזמנה"),
        "canceled": MessageLookupByLibrary.simpleMessage("בוטל"),
        "card_added_successfully":
            MessageLookupByLibrary.simpleMessage("הכרטיס נוסף בהצלחה"),
        "card_already_exist":
            MessageLookupByLibrary.simpleMessage("הכרטיס כבר קיים"),
        "card_deleted_successfully":
            MessageLookupByLibrary.simpleMessage("הכרטיס נמחק בהצלחה"),
        "card_number": MessageLookupByLibrary.simpleMessage("מספר כרטיס"),
        "cart": MessageLookupByLibrary.simpleMessage("עגלה"),
        "carts_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("עגלות רעננו בהצלחה"),
        "cash_on_delivery":
            MessageLookupByLibrary.simpleMessage("תשלום במזומן"),
        "category": MessageLookupByLibrary.simpleMessage("קטגוריה"),
        "category_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("קטגוריה רעננה בהצלחה"),
        "change": MessageLookupByLibrary.simpleMessage("שנה"),
        "chats": MessageLookupByLibrary.simpleMessage("צ\'אטים"),
        "check_on_waze": MessageLookupByLibrary.simpleMessage("בדוק ב-Waze:"),
        "checkout": MessageLookupByLibrary.simpleMessage("צ׳קאאוט"),
        "choose_your_location": MessageLookupByLibrary.simpleMessage(
            "Please , Choose Your Location"),
        "clear": MessageLookupByLibrary.simpleMessage("נקה"),
        "clickOnTheFoodToGetMoreDetailsAboutIt":
            MessageLookupByLibrary.simpleMessage(
                "לחץ על האוכל כדי לקבל פרטים נוספים עליו"),
        "clickToPayWithRazorpayMethod": MessageLookupByLibrary.simpleMessage(
            "לחץ כדי לשלם עם שיטת RazorPay"),
        "click_on_the_stars_below_to_leave_comments":
            MessageLookupByLibrary.simpleMessage(
                "לחץ על הכוכבים למטה כדי להשאיר תגובות"),
        "click_to_confirm_your_address_and_pay_or_long_press":
            MessageLookupByLibrary.simpleMessage(
                "לחץ כדי לאשר את כתובתך ולשלם או ללחוץ לחיצה ארוכה כדי לערוך את כתובתך"),
        "click_to_pay_cash_on_delivery":
            MessageLookupByLibrary.simpleMessage("לחץ כדי לשלם במזומן במשלוח"),
        "click_to_pay_on_pickup":
            MessageLookupByLibrary.simpleMessage("לחץ כדי לשלם באיסוף"),
        "click_to_pay_with_icredit": MessageLookupByLibrary.simpleMessage(
            "לחץ כדי לשלם עם האי-קרדיט שלך"),
        "click_to_pay_with_your_mastercard":
            MessageLookupByLibrary.simpleMessage(
                "לחץ כדי לשלם עם כרטיס ה-MasterCard שלך"),
        "click_to_pay_with_your_paypal_account":
            MessageLookupByLibrary.simpleMessage(
                "לחץ כדי לשלם עם חשבון ה-PayPal שלך"),
        "click_to_pay_with_your_visa_card":
            MessageLookupByLibrary.simpleMessage(
                "לחץ כדי לשלם עם כרטיס ה-Visa שלך"),
        "close": MessageLookupByLibrary.simpleMessage("סגור"),
        "closed": MessageLookupByLibrary.simpleMessage("סגור"),
        "completeYourProfileDetailsToContinue":
            MessageLookupByLibrary.simpleMessage(
                "השלם את פרטי הפרופיל שלך כדי להמשיך"),
        "complete_order": MessageLookupByLibrary.simpleMessage("השלם הזמנה"),
        "complete_payment": MessageLookupByLibrary.simpleMessage("השלם תשלום"),
        "confirm_payment": MessageLookupByLibrary.simpleMessage("אישור תשלום"),
        "confirm_your_delivery_address":
            MessageLookupByLibrary.simpleMessage("אישור כתובת המשלוח שלך"),
        "confirmation": MessageLookupByLibrary.simpleMessage("אישור"),
        "continueBtn": MessageLookupByLibrary.simpleMessage("המשך"),
        "cuisines": MessageLookupByLibrary.simpleMessage("סוגי מטבח"),
        "current_location": MessageLookupByLibrary.simpleMessage("מיקום נוכחי"),
        "cvc": MessageLookupByLibrary.simpleMessage("CVC"),
        "cvv": MessageLookupByLibrary.simpleMessage("קוד CVV"),
        "dark_mode": MessageLookupByLibrary.simpleMessage("מצב חשוך"),
        "ddMMyyyy": MessageLookupByLibrary.simpleMessage("dd-MM-yyyy"),
        "ddMMyyyyHHmm":
            MessageLookupByLibrary.simpleMessage("dd-MM-yyyy | HH:mm"),
        "debug": MessageLookupByLibrary.simpleMessage("ניפוי באגים"),
        "default_credit_card":
            MessageLookupByLibrary.simpleMessage("כרטיס אשראי ברירת מחדל"),
        "delete": MessageLookupByLibrary.simpleMessage("מחיקה"),
        "deliverable": MessageLookupByLibrary.simpleMessage("ניתן למשלוח"),
        "delivery": MessageLookupByLibrary.simpleMessage("משלוח"),
        "deliveryAddressOutsideRange": MessageLookupByLibrary.simpleMessage(
            "הכתובת שלך מחוץ לאזור המשלוח. אנא בחר באיסוף עצמי או שנה את הכתובת."),
        "deliveryAddressOutsideTheDeliveryRangeOfThisRestaurants":
            MessageLookupByLibrary.simpleMessage(
                "כתובת המשלוח מחוץ לטווח המשלוח של המסעדות הללו."),
        "deliveryMethodNotAllowed":
            MessageLookupByLibrary.simpleMessage("שיטת המשלוח אינה מורשת!"),
        "delivery_20_30_mnt":
            MessageLookupByLibrary.simpleMessage("משלוח תוך 20–30 דקות"),
        "delivery_address":
            MessageLookupByLibrary.simpleMessage("כתובת למשלוח"),
        "delivery_address_removed_successfully":
            MessageLookupByLibrary.simpleMessage("כתובת למשלוח הוסרה בהצלחה"),
        "delivery_addresses":
            MessageLookupByLibrary.simpleMessage("כתובות למשלוח"),
        "delivery_fee": MessageLookupByLibrary.simpleMessage("דמי משלוח"),
        "delivery_or_pickup":
            MessageLookupByLibrary.simpleMessage("משלוח או איסוף"),
        "description": MessageLookupByLibrary.simpleMessage("תיאור"),
        "details": MessageLookupByLibrary.simpleMessage("פרטים"),
        "didntReceiveTheCodeResendit":
            MessageLookupByLibrary.simpleMessage("לא קיבלת את הקוד? שלח שוב"),
        "discount": MessageLookupByLibrary.simpleMessage("הנחה"),
        "discover__explorer":
            MessageLookupByLibrary.simpleMessage("גליה וחוקר"),
        "do_not_have_account":
            MessageLookupByLibrary.simpleMessage("אין לך חשבון?"),
        "dont_have_any_item_in_the_notification_list":
            MessageLookupByLibrary.simpleMessage("אין פריטים ברשימת ההתראות"),
        "dont_have_any_item_in_your_cart":
            MessageLookupByLibrary.simpleMessage("אין פריטים בעגלה שלך"),
        "doorCode": MessageLookupByLibrary.simpleMessage("קוד לדלת"),
        "doorIsOpen": MessageLookupByLibrary.simpleMessage("הדלת פתוחה"),
        "doorbellIntercom":
            MessageLookupByLibrary.simpleMessage("פעמון / אינטרקום"),
        "double_click_on_the_food_to_add_it_to_the":
            MessageLookupByLibrary.simpleMessage(
                "לחץ פעמיים על המזון כדי להוסיף אותו לעגלה"),
        "edit": MessageLookupByLibrary.simpleMessage("עריכה"),
        "email": MessageLookupByLibrary.simpleMessage("אימייל"),
        "email_address": MessageLookupByLibrary.simpleMessage("כתובת דוא\"ל"),
        "email_to_reset_password":
            MessageLookupByLibrary.simpleMessage("דואר אלקטרוני לאיפוס סיסמה"),
        "english": MessageLookupByLibrary.simpleMessage("אנגלית"),
        "enterAnotherAddress":
            MessageLookupByLibrary.simpleMessage("הזן כתובת אחרת"),
        "enterThe4DigitCodeSentTo": m3,
        "entranceStaircase":
            MessageLookupByLibrary.simpleMessage("כניסה / מדרגות"),
        "errorFetchingNotifications": m4,
        "error_verify_email_settings":
            MessageLookupByLibrary.simpleMessage("שגיאה! אמת הגדרות דוא\"ל"),
        "estimatedTime": MessageLookupByLibrary.simpleMessage("זמן משוער:"),
        "estimated_time": MessageLookupByLibrary.simpleMessage("זמן משוער"),
        "exp_date": MessageLookupByLibrary.simpleMessage("תאריך תפוגה"),
        "expiry_date": MessageLookupByLibrary.simpleMessage("תאריך תפוגה"),
        "extras": MessageLookupByLibrary.simpleMessage("תוספות"),
        "faq": MessageLookupByLibrary.simpleMessage("שאלות נפוצות"),
        "faqsRefreshedSuccessfuly":
            MessageLookupByLibrary.simpleMessage("שאלות נפוצות רעננו בהצלחה"),
        "favorite_foods":
            MessageLookupByLibrary.simpleMessage("מזונות מועדפים"),
        "favorites": MessageLookupByLibrary.simpleMessage("מועדפים"),
        "favorites_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("המועדפים רעננו בהצלחה"),
        "featured_foods":
            MessageLookupByLibrary.simpleMessage("מזונות מובחרים"),
        "fetchAllNotifications":
            MessageLookupByLibrary.simpleMessage("שליפת כל ההתראות"),
        "fields": MessageLookupByLibrary.simpleMessage("שדות"),
        "filter": MessageLookupByLibrary.simpleMessage("סנן"),
        "floor": MessageLookupByLibrary.simpleMessage("קומה"),
        "foodRefreshedSuccessfuly":
            MessageLookupByLibrary.simpleMessage("המזון רענן בהצלחה"),
        "food_categories":
            MessageLookupByLibrary.simpleMessage("קטגוריות מזונות"),
        "foods_result": MessageLookupByLibrary.simpleMessage("תוצאת מזונות"),
        "foods_results": MessageLookupByLibrary.simpleMessage("תוצאות מזונות"),
        "forMoreDetailsPleaseChatWithOurManagers":
            MessageLookupByLibrary.simpleMessage(
                "לפרטים נוספים, אנא שוחח עם המנהלים שלנו"),
        "forgot_password": MessageLookupByLibrary.simpleMessage("שכחת סיסמה?"),
        "fullAddress": MessageLookupByLibrary.simpleMessage("כתובת מלאה"),
        "full_address": MessageLookupByLibrary.simpleMessage("כתובת מלאה"),
        "full_name": MessageLookupByLibrary.simpleMessage("שם מלא"),
        "g": MessageLookupByLibrary.simpleMessage("גרם"),
        "goToNotificationsPage":
            MessageLookupByLibrary.simpleMessage("מעבר לעמוד ההתראות"),
        "go_back_checkout":
            MessageLookupByLibrary.simpleMessage("חזור לדף התשלום"),
        "guest": MessageLookupByLibrary.simpleMessage("אורח"),
        "haveCouponCode":
            MessageLookupByLibrary.simpleMessage("יש לך קוד קופון?"),
        "help__support": MessageLookupByLibrary.simpleMessage("עזרה ותמיכה"),
        "help_support": MessageLookupByLibrary.simpleMessage("עזרה ותמיכה"),
        "help_supports": MessageLookupByLibrary.simpleMessage("עזרה ותמיכה"),
        "hint_full_address":
            MessageLookupByLibrary.simpleMessage("רחוב 12, עיר 21663, מדינה"),
        "home": MessageLookupByLibrary.simpleMessage("בית"),
        "homeAddress": MessageLookupByLibrary.simpleMessage("כתובת הבית"),
        "home_address": MessageLookupByLibrary.simpleMessage("כתובת בית"),
        "howDoWeGetIn": MessageLookupByLibrary.simpleMessage("איך נכנסים?"),
        "how_would_you_rate_this_restaurant":
            MessageLookupByLibrary.simpleMessage(
                "איך היית מדרג את המסעדה הזו?"),
        "how_would_you_rate_this_restaurant_":
            MessageLookupByLibrary.simpleMessage(
                "איך היית מדרג את המסעדה הזו?"),
        "iCredit": MessageLookupByLibrary.simpleMessage("שלם עכשיו"),
        "i_dont_have_an_account":
            MessageLookupByLibrary.simpleMessage("אין לי חשבון?"),
        "i_forgot_password":
            MessageLookupByLibrary.simpleMessage("שכחתי סיסמה?"),
        "i_have_account_back_to_login":
            MessageLookupByLibrary.simpleMessage("יש לי חשבון? חזרה להתחברות"),
        "i_remember_my_password_return_to_login":
            MessageLookupByLibrary.simpleMessage(
                "אני זוכר את הסיסמה שלי, חזרה להתחברות"),
        "information": MessageLookupByLibrary.simpleMessage("מידע"),
        "ingredients": MessageLookupByLibrary.simpleMessage("מרכיבים"),
        "invalidCouponCode":
            MessageLookupByLibrary.simpleMessage("קוד קופון לא תקין"),
        "items": MessageLookupByLibrary.simpleMessage("פריטים"),
        "john_doe": MessageLookupByLibrary.simpleMessage("יהון דו"),
        "keep_your_old_meals_of_this_restaurant":
            MessageLookupByLibrary.simpleMessage(
                "שמור על הארוחות הישנות שלך מהמסעדה הזו"),
        "km": MessageLookupByLibrary.simpleMessage("ק\"מ"),
        "languages": MessageLookupByLibrary.simpleMessage("שפות"),
        "lets_start_with_login":
            MessageLookupByLibrary.simpleMessage("בואו נתחיל עם התחברות!"),
        "lets_start_with_register":
            MessageLookupByLibrary.simpleMessage("בואו נתחיל עם הרשמה!"),
        "light_mode": MessageLookupByLibrary.simpleMessage("מצב אור"),
        "loadingRoute": MessageLookupByLibrary.simpleMessage("טוען מסלול..."),
        "locationBasedMessage": MessageLookupByLibrary.simpleMessage(
            "בהתבסס על מיקום הטלפון שלך, נראה שאתה כאן:"),
        "locationFetchError":
            MessageLookupByLibrary.simpleMessage("לא ניתן לקבוע מיקום"),
        "locationPermissionDeniedForever":
            MessageLookupByLibrary.simpleMessage("ההרשאה למיקום נדחתה לצמיתות"),
        "locationServiceDisabled":
            MessageLookupByLibrary.simpleMessage("שירות המיקום מושבת"),
        "locationType": MessageLookupByLibrary.simpleMessage("סוג מיקום"),
        "locationTypeHint":
            MessageLookupByLibrary.simpleMessage("בחר סוג מיקום"),
        "log_out": MessageLookupByLibrary.simpleMessage("התנתקות"),
        "login": MessageLookupByLibrary.simpleMessage("התחברות"),
        "login_success":
            MessageLookupByLibrary.simpleMessage("התחברות הצליחה!"),
        "login_successful":
            MessageLookupByLibrary.simpleMessage("התחברה בהצלחה"),
        "login_with_apple":
            MessageLookupByLibrary.simpleMessage("התחבר עם אפל"),
        "login_with_facebook":
            MessageLookupByLibrary.simpleMessage("התחבר עם פייסבוק"),
        "login_with_google":
            MessageLookupByLibrary.simpleMessage("התחבר עם גוגל"),
        "long_press_to_edit_item_swipe_item_to_delete_it":
            MessageLookupByLibrary.simpleMessage(
                "לחיצה ארוכה לעריכת פריט, החלק פריט למחיקה"),
        "longpress_on_the_food_to_add_suplements":
            MessageLookupByLibrary.simpleMessage(
                "לחיצה ארוכה על המזון להוספת תוספות"),
        "makeItDefault":
            MessageLookupByLibrary.simpleMessage("הגדר כברירת מחדל"),
        "maps": MessageLookupByLibrary.simpleMessage("מפות"),
        "maps_explorer": MessageLookupByLibrary.simpleMessage("מגלה מפות"),
        "mastercard": MessageLookupByLibrary.simpleMessage("MasterCard"),
        "menu": MessageLookupByLibrary.simpleMessage("תפריט"),
        "messages": MessageLookupByLibrary.simpleMessage("הודעות"),
        "mi": MessageLookupByLibrary.simpleMessage("מייל"),
        "more": MessageLookupByLibrary.simpleMessage("עוד"),
        "most_ordered": MessageLookupByLibrary.simpleMessage("הכי מוזמן"),
        "most_popular": MessageLookupByLibrary.simpleMessage("הכי פופולרי"),
        "multirestaurants":
            MessageLookupByLibrary.simpleMessage("מסעדות מרובות"),
        "my_orders": MessageLookupByLibrary.simpleMessage("ההזמנות שלי"),
        "near_to": MessageLookupByLibrary.simpleMessage("בקרבת"),
        "near_to_your_current_location":
            MessageLookupByLibrary.simpleMessage("בקרבת מיקום הנוכחי שלך"),
        "newMessageFrom":
            MessageLookupByLibrary.simpleMessage("הודעה חדשה מאת"),
        "new_address_added_successfully":
            MessageLookupByLibrary.simpleMessage("כתובת חדשה התווספה בהצלחה"),
        "new_order_from_client":
            MessageLookupByLibrary.simpleMessage("הזמנה חדשה מלקוח"),
        "no_restaurants_found":
            MessageLookupByLibrary.simpleMessage("לא נמצאו מסעדות"),
        "no_saved_cards":
            MessageLookupByLibrary.simpleMessage("אין כרטיסים שמורים"),
        "no_stores_found":
            MessageLookupByLibrary.simpleMessage("לא נמצאו חנויות"),
        "notAvailableNow": MessageLookupByLibrary.simpleMessage("לא זמין כרגע"),
        "notValidAddress":
            MessageLookupByLibrary.simpleMessage("כתובת לא תקפה"),
        "not_a_valid_address":
            MessageLookupByLibrary.simpleMessage("כתובת לא חוקית"),
        "not_a_valid_biography":
            MessageLookupByLibrary.simpleMessage("ביוגרפיה לא חוקית"),
        "not_a_valid_cvc": MessageLookupByLibrary.simpleMessage("CVC לא חוקי"),
        "not_a_valid_date":
            MessageLookupByLibrary.simpleMessage("לא תאריך חוקי"),
        "not_a_valid_email":
            MessageLookupByLibrary.simpleMessage("כתובת דוא\"ל לא חוקית"),
        "not_a_valid_full_name":
            MessageLookupByLibrary.simpleMessage("שם מלא לא חוקי"),
        "not_a_valid_number":
            MessageLookupByLibrary.simpleMessage("לא מספר חוקי"),
        "not_a_valid_phone":
            MessageLookupByLibrary.simpleMessage("מספר טלפון לא חוקי"),
        "not_deliverable":
            MessageLookupByLibrary.simpleMessage("לא ניתן למשלוח"),
        "notificationWasRemoved":
            MessageLookupByLibrary.simpleMessage("ההתראה הוסרה"),
        "notifications": MessageLookupByLibrary.simpleMessage("התראות"),
        "notificationsTestTitle":
            MessageLookupByLibrary.simpleMessage("🧪 בדיקת התראות"),
        "notifications_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("התראות רעננו בהצלחה"),
        "number": MessageLookupByLibrary.simpleMessage("מספר"),
        "nutrition": MessageLookupByLibrary.simpleMessage("ערכים תזונתיים"),
        "oneOrMoreFoodsInYourCartNotDeliverable":
            MessageLookupByLibrary.simpleMessage(
                "פריט או יותר בעגלתך אינם ניתנים למשלוח."),
        "open": MessageLookupByLibrary.simpleMessage("פתוח"),
        "open_until": m5,
        "opened_restaurants":
            MessageLookupByLibrary.simpleMessage("מסעדות פתוחות"),
        "optional": MessageLookupByLibrary.simpleMessage("אופציונלי"),
        "or_checkout_with":
            MessageLookupByLibrary.simpleMessage("או בצע הזמנה עם"),
        "order": MessageLookupByLibrary.simpleMessage("הזמנה"),
        "orderDetails": MessageLookupByLibrary.simpleMessage("פרטי הזמנה"),
        "orderThisorderidHasBeenCanceled": m7,
        "order_id": MessageLookupByLibrary.simpleMessage("מספר הזמנה"),
        "order_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("הזמנה רעננה בהצלחה"),
        "order_status_changed":
            MessageLookupByLibrary.simpleMessage("סטטוס הזמנה שונה"),
        "ordered_by_nearby_first":
            MessageLookupByLibrary.simpleMessage("מסודר על פי קרבה ראשית"),
        "orders_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("הזמנות רעננו בהצלחה"),
        "other": MessageLookupByLibrary.simpleMessage("אחר"),
        "otherInstructionsForTheCourier":
            MessageLookupByLibrary.simpleMessage("הוראות נוספות לשליח"),
        "otherTellUsHow":
            MessageLookupByLibrary.simpleMessage("אחר (ספר לנו איך)"),
        "password": MessageLookupByLibrary.simpleMessage("סיסמה"),
        "payNow": MessageLookupByLibrary.simpleMessage("שלם עכשיו"),
        "pay_on_pickup": MessageLookupByLibrary.simpleMessage("תשלום באיסוף"),
        "payment_card_updated_successfully":
            MessageLookupByLibrary.simpleMessage("כרטיס התשלום עודכן בהצלחה"),
        "payment_mode": MessageLookupByLibrary.simpleMessage("אמצעי תשלום"),
        "payment_options":
            MessageLookupByLibrary.simpleMessage("אפשרויות תשלום"),
        "payment_settings":
            MessageLookupByLibrary.simpleMessage("הגדרות תשלום"),
        "payment_settings_updated_successfully":
            MessageLookupByLibrary.simpleMessage("הגדרות התשלום עודכנו בהצלחה"),
        "payments": MessageLookupByLibrary.simpleMessage("תשלומים"),
        "payments_settings":
            MessageLookupByLibrary.simpleMessage("הגדרות תשלומים"),
        "paypal": MessageLookupByLibrary.simpleMessage("PayPal"),
        "paypal_payment":
            MessageLookupByLibrary.simpleMessage("תשלום ב-PayPal"),
        "phone": MessageLookupByLibrary.simpleMessage("טלפון"),
        "phoneNumber": MessageLookupByLibrary.simpleMessage("מספר טלפון"),
        "pickup": MessageLookupByLibrary.simpleMessage("איסוף"),
        "pickup_your_food_from_the_restaurant":
            MessageLookupByLibrary.simpleMessage("איסוף המזון שלך מהמסעדה"),
        "pleaseEnterOrSelectAddress":
            MessageLookupByLibrary.simpleMessage("אנא הזן או בחר כתובת"),
        "pleaseWait": MessageLookupByLibrary.simpleMessage("אנא המתן..."),
        "please_fill_all_fields":
            MessageLookupByLibrary.simpleMessage("אנא מלא את כל השדות כראוי"),
        "profile": MessageLookupByLibrary.simpleMessage("פרופיל"),
        "profile_settings":
            MessageLookupByLibrary.simpleMessage("הגדרות פרופיל"),
        "profile_settings_updated_successfully":
            MessageLookupByLibrary.simpleMessage(
                "הגדרות הפרופיל עודכנו בהצלחה"),
        "quantity": MessageLookupByLibrary.simpleMessage("כמות"),
        "razorpay": MessageLookupByLibrary.simpleMessage("RazorPay"),
        "razorpayPayment":
            MessageLookupByLibrary.simpleMessage("תשלום RazorPay"),
        "recent_orders": MessageLookupByLibrary.simpleMessage("הזמנות אחרונות"),
        "recent_reviews":
            MessageLookupByLibrary.simpleMessage("ביקורות אחרונות"),
        "recents_search":
            MessageLookupByLibrary.simpleMessage("חיפושים אחרונים"),
        "refreshNotificationCount":
            MessageLookupByLibrary.simpleMessage("רענון מספר התראות"),
        "register": MessageLookupByLibrary.simpleMessage("הרשמה"),
        "register_successful":
            MessageLookupByLibrary.simpleMessage("ההרשמה הצליחה"),
        "reset": MessageLookupByLibrary.simpleMessage("אתחול"),
        "reset_cart": MessageLookupByLibrary.simpleMessage("אתחל עגלה?"),
        "reset_your_cart_and_order_meals_form_this_restaurant":
            MessageLookupByLibrary.simpleMessage(
                "אתחל את העגלה שלך והזמן ארוחות מהמסעדה הזו"),
        "restaurant_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("מסעדה רעננה בהצלחה"),
        "restaurants": MessageLookupByLibrary.simpleMessage("מסעדות"),
        "restaurants_near_to":
            MessageLookupByLibrary.simpleMessage("מסעדות בקרבת"),
        "restaurants_near_to_your_current_location":
            MessageLookupByLibrary.simpleMessage(
                "מסעדות בקרבת מקום הנוכחי שלך"),
        "restaurants_results":
            MessageLookupByLibrary.simpleMessage("תוצאות מסעדות"),
        "reviews": MessageLookupByLibrary.simpleMessage("ביקורות"),
        "reviews_refreshed_successfully":
            MessageLookupByLibrary.simpleMessage("ביקורות רעננו בהצלחה!"),
        "save": MessageLookupByLibrary.simpleMessage("שמירה"),
        "search": MessageLookupByLibrary.simpleMessage("חיפוש"),
        "search_for_restaurants_or_foods":
            MessageLookupByLibrary.simpleMessage("חפש מסעדות או מזונות"),
        "select": MessageLookupByLibrary.simpleMessage("בחר"),
        "selectLocationType":
            MessageLookupByLibrary.simpleMessage("בחר סוג מיקום"),
        "select_extras":
            MessageLookupByLibrary.simpleMessage("בחר תוספות להוספה למנה"),
        "select_extras_to_add_them_on_the_food":
            MessageLookupByLibrary.simpleMessage("בחר תוספות להוספתן למזון"),
        "select_your_preferred_languages":
            MessageLookupByLibrary.simpleMessage("בחר את שפת המועדפת עליך"),
        "select_your_preferred_payment_mode":
            MessageLookupByLibrary.simpleMessage(
                "בחר את אמצעי התשלום המועדף עליך"),
        "send_password_reset_link":
            MessageLookupByLibrary.simpleMessage("שלח קישור"),
        "settings": MessageLookupByLibrary.simpleMessage("הגדרות"),
        "shopping": MessageLookupByLibrary.simpleMessage("קניות"),
        "shopping_cart": MessageLookupByLibrary.simpleMessage("עגלת קניות"),
        "should_be_a_valid_email":
            MessageLookupByLibrary.simpleMessage("כתובת אימייל לא תקינה"),
        "should_be_more_than_3_characters":
            MessageLookupByLibrary.simpleMessage("חייב להכיל יותר מ-3 תווים"),
        "should_be_more_than_3_letters":
            MessageLookupByLibrary.simpleMessage("צריך להיות יותר מ-3 אותיות"),
        "should_be_more_than_6_letters":
            MessageLookupByLibrary.simpleMessage("צריך להיות יותר מ-6 אותיות"),
        "signinToChatWithOurManagers": MessageLookupByLibrary.simpleMessage(
            "היכנס כדי לשוחח עם המנהלים שלנו"),
        "skip": MessageLookupByLibrary.simpleMessage("דלג"),
        "smsHasBeenSentTo":
            MessageLookupByLibrary.simpleMessage("הודעת SMS נשלחה אל"),
        "start_exploring": MessageLookupByLibrary.simpleMessage("התחל לחקור"),
        "stores": MessageLookupByLibrary.simpleMessage("חנויות"),
        "streetCityCountry":
            MessageLookupByLibrary.simpleMessage("רחוב, עיר, מדינה"),
        "submit": MessageLookupByLibrary.simpleMessage("שלח"),
        "subtotal": MessageLookupByLibrary.simpleMessage("סכום חלקי"),
        "swipeLeftTheNotificationToDeleteOrReadUnreadIt":
            MessageLookupByLibrary.simpleMessage(
                "גרור שמאלה את ההתראה כדי למחוק אותה או לקרוא / לא לקרוא אותה"),
        "tapAgainToLeave":
            MessageLookupByLibrary.simpleMessage("הקש שוב כדי לצאת"),
        "tax": MessageLookupByLibrary.simpleMessage("מס"),
        "tell_us_about_this_food":
            MessageLookupByLibrary.simpleMessage("ספר לנו על המזון הזה"),
        "tell_us_about_this_restaurant":
            MessageLookupByLibrary.simpleMessage("ספר לנו על המסעדה הזו"),
        "testApiConnection":
            MessageLookupByLibrary.simpleMessage("בדיקת חיבור ל-API"),
        "testLocalNotification":
            MessageLookupByLibrary.simpleMessage("בדיקת התראה מקומית"),
        "testNotification":
            MessageLookupByLibrary.simpleMessage("התראה לבדיקה"),
        "testNotificationBody":
            MessageLookupByLibrary.simpleMessage("זו התראה לבדיקה!"),
        "testNotificationSent":
            MessageLookupByLibrary.simpleMessage("התראה לבדיקה נשלחה!"),
        "testNotifications":
            MessageLookupByLibrary.simpleMessage("בדיקת התראות"),
        "testingApiConnection":
            MessageLookupByLibrary.simpleMessage("בודק חיבור ל-API..."),
        "the_address_updated_successfully":
            MessageLookupByLibrary.simpleMessage("הכתובת עודכנה בהצלחה"),
        "the_food_has_been_rated_successfully":
            MessageLookupByLibrary.simpleMessage("האוכל דורג בהצלחה"),
        "the_food_was_removed_from_your_cart": m6,
        "the_restaurant_has_been_rated_successfully":
            MessageLookupByLibrary.simpleMessage("המסעדה דורגה בהצלחה"),
        "thisFoodWasAddedToFavorite":
            MessageLookupByLibrary.simpleMessage("המזון הזה נוסף למועדפים"),
        "thisFoodWasRemovedFromFavorites":
            MessageLookupByLibrary.simpleMessage("המזון הזה הוסר מהמועדפים"),
        "thisNotificationHasMarkedAsRead":
            MessageLookupByLibrary.simpleMessage("ההתראה הזו סומנה כנקראה"),
        "thisNotificationHasMarkedAsUnread":
            MessageLookupByLibrary.simpleMessage("ההתראה הזו סומנה כלא נקראה"),
        "thisRestaurantNotSupportDeliveryMethod":
            MessageLookupByLibrary.simpleMessage(
                "המסעדה הזו לא תומכת בשיטת משלוח."),
        "this_account_not_exist":
            MessageLookupByLibrary.simpleMessage("החשבון הזה לא קיים"),
        "this_email_account_exists":
            MessageLookupByLibrary.simpleMessage("חשבון דוא\"ל זה כבר קיים"),
        "this_food_was_added_to_cart":
            MessageLookupByLibrary.simpleMessage("המזון הזה נוסף לעגלה"),
        "this_restaurant_is_closed_":
            MessageLookupByLibrary.simpleMessage("המסעדה הזו סגורה!"),
        "tip_check_card_info": MessageLookupByLibrary.simpleMessage(
            "• בדוק שוב את פרטי הכרטיס שלך."),
        "tip_contact_issuer": MessageLookupByLibrary.simpleMessage(
            "• פנה לחברת הכרטיס לאימות החשבון שלך."),
        "tip_use_different_card": MessageLookupByLibrary.simpleMessage(
            "• השתמש בכרטיס אחר או שיטה חלופית."),
        "tips_complete_order":
            MessageLookupByLibrary.simpleMessage("טיפים להשלמת ההזמנה שלך"),
        "top_restaurants":
            MessageLookupByLibrary.simpleMessage("מסעדות מובילות"),
        "total": MessageLookupByLibrary.simpleMessage("סך הכל"),
        "tracking": MessageLookupByLibrary.simpleMessage("מעקב"),
        "tracking_order":
            MessageLookupByLibrary.simpleMessage("מעקב אחר ההזמנה"),
        "tracking_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage("מעקב רענן בהצלחה"),
        "transaction_declined":
            MessageLookupByLibrary.simpleMessage("העסקה נדחתה"),
        "trending_this_week":
            MessageLookupByLibrary.simpleMessage("טרנדים השבוע"),
        "twentyToThirtyMin": MessageLookupByLibrary.simpleMessage("20–30 דקות"),
        "typeToStartChat":
            MessageLookupByLibrary.simpleMessage("הקלד כדי להתחיל בשיחה"),
        "unknown": MessageLookupByLibrary.simpleMessage("לא ידוע"),
        "unreadNotifications":
            MessageLookupByLibrary.simpleMessage("התראות שלא נקראו"),
        "useThisAddress":
            MessageLookupByLibrary.simpleMessage("השתמש בכתובת זו"),
        "validCouponCode":
            MessageLookupByLibrary.simpleMessage("קוד קופון תקף"),
        "verify": MessageLookupByLibrary.simpleMessage("אמת"),
        "verifyCode": MessageLookupByLibrary.simpleMessage("אמת קוד"),
        "verifyPhoneNumber":
            MessageLookupByLibrary.simpleMessage("אמת מספר טלפון"),
        "verify_your_internet_connection":
            MessageLookupByLibrary.simpleMessage("אמת את חיבור האינטרנט שלך"),
        "verify_your_quantity_and_click_checkout":
            MessageLookupByLibrary.simpleMessage("אמת את כמותך ולחץ על קופה"),
        "version": MessageLookupByLibrary.simpleMessage("גרסה"),
        "view": MessageLookupByLibrary.simpleMessage("הצג"),
        "viewDetails": MessageLookupByLibrary.simpleMessage("צפה בפרטים"),
        "visa_card": MessageLookupByLibrary.simpleMessage("כרטיס Visa"),
        "weAreSendingOtpToValidateYourMobileNumberHang":
            MessageLookupByLibrary.simpleMessage(
                "אנו שולחים OTP כדי לאמת את מספר הטלפון שלך. נא להמתין!"),
        "welcome": MessageLookupByLibrary.simpleMessage("ברוך הבא"),
        "what_they_say": MessageLookupByLibrary.simpleMessage("מה הם אומרים?"),
        "work": MessageLookupByLibrary.simpleMessage("עבודה"),
        "wrong_email_or_password": MessageLookupByLibrary.simpleMessage(
            "כתובת האימייל או הסיסמה שגויים"),
        "wrong_password": MessageLookupByLibrary.simpleMessage("הסיסמה שגויה"),
        "yes": MessageLookupByLibrary.simpleMessage("כן"),
        "youDontHaveAnyConversations":
            MessageLookupByLibrary.simpleMessage("אין לך שיחות"),
        "youDontHaveAnyOrder":
            MessageLookupByLibrary.simpleMessage("אין לך שום הזמנה"),
        "you_can_discover_restaurants": MessageLookupByLibrary.simpleMessage(
            "אתה יכול לגלות מסעדות ואוכל מהיר באזור שלך ולבחור את המנה הטובה ביותר שלך לאחר כמה דקות אנו מכינים ומספקים אותה עבורך"),
        "you_must_add_foods_of_the_same_restaurants_choose_one":
            MessageLookupByLibrary.simpleMessage(
                "עליך להוסיף מזונות מאותו המסעדות לבחור מסעדה אחת בלבד!"),
        "you_must_signin_to_access_to_this_section":
            MessageLookupByLibrary.simpleMessage(
                "עליך להיכנס כדי לגשת לאזור זה"),
        "your_address": MessageLookupByLibrary.simpleMessage("הכתובת שלך"),
        "your_biography": MessageLookupByLibrary.simpleMessage("הביוגרפיה שלך"),
        "your_credit_card_not_valid":
            MessageLookupByLibrary.simpleMessage("הכרטיס האשראי שלך לא תקין"),
        "your_order_has_been_successfully_submitted":
            MessageLookupByLibrary.simpleMessage("ההזמנה שלך הוגשה בהצלחה!"),
        "your_reset_link_has_been_sent_to_your_email":
            MessageLookupByLibrary.simpleMessage(
                "קישור האיפוס שלך נשלח לדואר האלקטרוני שלך")
      };
}
