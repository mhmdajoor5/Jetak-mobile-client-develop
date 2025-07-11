import '../helpers/custom_trace.dart';
import '../helpers/icredit_validator.dart';

class CreditCard {
  String id;
  String number;
  String expMonth;
  String expYear;
  String cvc;
  String holderName;
  String expiryDate;

  CreditCard({this.id = '', this.number = '', this.expMonth = '', this.expYear = '', this.cvc = '', this.holderName = '', this.expiryDate = ''});

  factory CreditCard.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return CreditCard(
        id: jsonMap?['id']?.toString() ?? '',
        number: jsonMap?['stripe_number']?.toString() ?? '',
        expMonth: jsonMap?['stripe_exp_month']?.toString() ?? '',
        expYear: jsonMap?['stripe_exp_year']?.toString() ?? '',
        cvc: jsonMap?['stripe_cvc']?.toString() ?? '',
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return CreditCard();
    }
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "stripe_number": number, "stripe_exp_month": expMonth, "stripe_exp_year": expYear, "stripe_cvc": cvc};
  }

  /// التحقق الأساسي من صحة البطاقة
  bool validated() {
    return number.isNotEmpty && expMonth.isNotEmpty && expYear.isNotEmpty && cvc.isNotEmpty;
  }

  /// التحقق المتقدم من صحة البطاقة مع فالديشن iCredit
  bool validatedWithICreditCheck() {
    // التحقق الأساسي
    if (!validated()) return false;
    
    // التحقق من أن البطاقة من نوع iCredit
    if (!ICreditValidator.isICreditCard(number)) {
      return false;
    }
    
    // التحقق من صحة رقم البطاقة باستخدام Luhn algorithm
    if (!ICreditValidator.isValidLuhn(number)) {
      return false;
    }
    
    // التحقق من صحة تاريخ انتهاء الصلاحية
    if (!ICreditValidator.isValidExpiryDate(expiryDate)) {
      return false;
    }
    
    // التحقق من صحة CVV
    if (!ICreditValidator.isValidCVV(cvc)) {
      return false;
    }
    
    // التحقق من صحة اسم حامل البطاقة
    if (!ICreditValidator.isValidCardHolderName(holderName)) {
      return false;
    }
    
    return true;
  }

  /// التحقق الشامل مع إرجاع تفاصيل الخطأ
  ICreditValidationResult validateWithDetails() {
    return ICreditValidator.validateICreditCard(number);
  }

  /// التحقق من نوع البطاقة
  bool isICreditCard() {
    return ICreditValidator.isICreditCard(number);
  }

  /// إخفاء رقم البطاقة للأمان
  String get maskedNumber {
    return ICreditValidator.maskCardNumber(number);
  }

  /// تنسيق رقم البطاقة
  String get formattedNumber {
    return ICreditValidator.formatCardNumber(number);
  }

  /// رسالة خطأ إذا كانت البطاقة غير صحيحة
  String? get validationError {
    ICreditValidationResult result = validateWithDetails();
    return result.isValid ? null : result.errorMessage;
  }

  /// رسالة خطأ باللغة الإنجليزية
  String? get validationErrorEn {
    ICreditValidationResult result = validateWithDetails();
    return result.isValid ? null : result.errorMessageEn;
  }
}
