class Validators {
  Validators._();

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  static String? email(String? value) {
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$';
    if (value == null || value.isEmpty) {
      return requiredField(value);
    }
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return requiredField(value);
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  static String? phone(String? value) {
    const pattern = r'^\+?[0-9]{7,15}\$';
    if (value == null || value.isEmpty) {
      return requiredField(value);
    }
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value.trim())) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  static String? cnic(String? value) {
    const pattern = r'^[0-9]{5}-[0-9]{7}-[0-9]\$';
    if (value == null || value.isEmpty) {
      return requiredField(value);
    }
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value.trim())) {
      return 'Enter a valid CNIC number.';
    }
    return null;
  }
}
