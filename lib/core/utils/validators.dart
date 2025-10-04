class Validators {
  static String? requiredField(String? value, {String label = 'هذا الحقل'}) {
    if (value == null || value.trim().isEmpty) return '$label مطلوب';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'البريد الإلكتروني مطلوب';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'صيغة بريد إلكتروني غير صحيحة';
    return null;
  }

  static String? password(String? value, {int min = 6}) {
    if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
    if (value.length < min) return 'كلمة المرور يجب أن تكون $min أحرف على الأقل';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'رقم الهاتف مطلوب';
    final phoneRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value)) return 'رقم هاتف غير صحيح';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'الاسم مطلوب';
    if (value.trim().length < 2) return 'الاسم يجب أن يكون حرفين على الأقل';
    return null;
  }

  static String? age(String? value) {
    if (value == null || value.isEmpty) return 'العمر مطلوب';
    final age = int.tryParse(value);
    if (age == null) return 'العمر يجب أن يكون رقماً';
    if (age < 1 || age > 120) return 'العمر يجب أن يكون بين 1 و 120';
    return null;
  }

  static String? gender(String? value) {
    if (value == null || value.isEmpty) return 'الجنس مطلوب';
    if (!['male', 'female', 'ذكر', 'أنثى'].contains(value.toLowerCase())) {
      return 'يرجى اختيار الجنس';
    }
    return null;
  }

  static String? specialization(String? value) {
    if (value == null || value.isEmpty) return 'التخصص مطلوب';
    return null;
  }

  static String? experienceYears(String? value) {
    if (value == null || value.isEmpty) return 'سنوات الخبرة مطلوبة';
    final years = int.tryParse(value);
    if (years == null) return 'سنوات الخبرة يجب أن تكون رقماً';
    if (years < 0 || years > 50) return 'سنوات الخبرة يجب أن تكون بين 0 و 50';
    return null;
  }

  static String? symptoms(String? value) {
    if (value == null || value.trim().isEmpty) return 'وصف الأعراض مطلوب';
    if (value.trim().length < 10) return 'وصف الأعراض يجب أن يكون 10 أحرف على الأقل';
    return null;
  }

  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) return 'العنوان مطلوب';
    if (value.trim().length < 10) return 'العنوان يجب أن يكون 10 أحرف على الأقل';
    return null;
  }

  static String? emergencyContact(String? value) {
    if (value == null || value.isEmpty) return 'رقم الطوارئ مطلوب';
    final phoneRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value)) return 'رقم هاتف الطوارئ غير صحيح';
    return null;
  }
}
