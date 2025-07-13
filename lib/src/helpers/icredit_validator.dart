class ICreditValidator {
  // BIN range for iCredit cards (Israel Credit Cards)
  static const String _iCreditBinPrefix = '458028';
  
  /// التحقق من أن البطاقة من نوع iCredit
  /// Returns true if the card is an iCredit card
  static bool isICreditCard(String cardNumber) {
    // إزالة المسافات والشرطات
    String cleanNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // التحقق من أن البطاقة تبدأ بـ BIN الخاص بـ iCredit
    return cleanNumber.startsWith(_iCreditBinPrefix);
  }
  
  /// التحقق من صحة رقم البطاقة باستخدام خوارزمية Luhn
  /// Returns true if the card number is valid using Luhn algorithm
  static bool isValidLuhn(String cardNumber) {
    String cleanNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanNumber.isEmpty) return false;
    
    int sum = 0;
    bool alternate = false;
    
    // البدء من الرقم الأخير والانتقال للخلف
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }
  
  /// التحقق من صحة أي بطاقة ائتمانية
  /// Returns true if it's a valid credit card (any type)
  static bool isValidCreditCard(String cardNumber) {
    String cleanNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    // التحقق من الطول (بين 13 و 19 رقماً)
    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return false;
    }
    // التحقق من صحة الرقم باستخدام خوارزمية Luhn
    return isValidLuhn(cleanNumber);
  }
  
  /// التحقق الشامل من صحة بطاقة iCredit
  /// Returns validation result with details
  static ICreditValidationResult validateICreditCard(String cardNumber) {
    String cleanNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // التحقق من الطول
    if (cleanNumber.length != 16) {
      return ICreditValidationResult(
        isValid: false,
        errorMessage: 'رقم البطاقة يجب أن يكون 16 رقماً',
        errorMessageEn: 'Card number must be 16 digits',
      );
    }
    
    // التحقق من أن البطاقة من نوع iCredit
    if (!isICreditCard(cleanNumber)) {
      return ICreditValidationResult(
        isValid: false,
        errorMessage: 'هذه البطاقة غير مدعومة. يرجى استخدام بطاقة iCredit فقط (تبدأ بـ 4580 28)',
        errorMessageEn: 'This card is not supported. Please use iCredit cards only (starting with 4580 28)',
      );
    }
    
    // التحقق من صحة الرقم باستخدام خوارزمية Luhn
    if (!isValidLuhn(cleanNumber)) {
      return ICreditValidationResult(
        isValid: false,
        errorMessage: 'رقم البطاقة غير صحيح',
        errorMessageEn: 'Invalid card number',
      );
    }
    
    return ICreditValidationResult(
      isValid: true,
      cardType: 'iCredit',
      maskedNumber: '**** **** **** ${cleanNumber.substring(12)}',
    );
  }
  
  /// تنسيق رقم البطاقة لعرضه
  /// Format card number for display
  static String formatCardNumber(String cardNumber) {
    String cleanNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanNumber.length <= 4) return cleanNumber;
    if (cleanNumber.length <= 8) return '${cleanNumber.substring(0, 4)} ${cleanNumber.substring(4)}';
    if (cleanNumber.length <= 12) return '${cleanNumber.substring(0, 4)} ${cleanNumber.substring(4, 8)} ${cleanNumber.substring(8)}';
    
    return '${cleanNumber.substring(0, 4)} ${cleanNumber.substring(4, 8)} ${cleanNumber.substring(8, 12)} ${cleanNumber.substring(12)}';
  }
  
  /// إخفاء رقم البطاقة للأمان
  /// Mask card number for security
  static String maskCardNumber(String cardNumber) {
    String cleanNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanNumber.length < 4) return cleanNumber;
    
    return '**** **** **** ${cleanNumber.substring(cleanNumber.length - 4)}';
  }
  
  /// التحقق من تاريخ انتهاء الصلاحية
  /// Validate expiry date
  static bool isValidExpiryDate(String expiryDate) {
    if (expiryDate.length != 5 || !expiryDate.contains('/')) {
      return false;
    }
    
    List<String> parts = expiryDate.split('/');
    if (parts.length != 2) return false;
    
    try {
      int month = int.parse(parts[0]);
      int year = int.parse('20${parts[1]}');
      
      if (month < 1 || month > 12) return false;
      
      DateTime now = DateTime.now();
      DateTime expiry = DateTime(year, month);
      
      // التحقق من أن البطاقة لم تنته صلاحيتها
      return expiry.isAfter(now);
    } catch (e) {
      return false;
    }
  }
  
  /// التحقق من رمز الأمان CVV
  /// Validate CVV
  static bool isValidCVV(String cvv) {
    return cvv.length == 3 && int.tryParse(cvv) != null;
  }
  
  /// التحقق من اسم حامل البطاقة
  /// Validate card holder name
  static bool isValidCardHolderName(String name) {
    return name.trim().length >= 2 && name.trim().length <= 50;
  }
}

/// نتيجة التحقق من صحة البطاقة
class ICreditValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? errorMessageEn;
  final String? cardType;
  final String? maskedNumber;
  
  ICreditValidationResult({
    required this.isValid,
    this.errorMessage,
    this.errorMessageEn,
    this.cardType,
    this.maskedNumber,
  });
} 