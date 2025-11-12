/// Utility class containing validation functions for form fields
class Validators {
  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }

    // Basic email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingrese un email válido';
    }

    return null;
  }

  /// Validates password strength
  /// Requirements: at least 6 characters
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  /// Validates that a field is not empty
  static String? validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }

    if (value.trim().isEmpty) {
      return '$fieldName no puede estar vacío';
    }

    return null;
  }

  /// Validates title for notes/events
  static String? validateTitle(String? value) {
    return validateField(value, 'El título');
  }

  /// Validates content/description
  static String? validateContent(String? value) {
    return validateField(value, 'El contenido');
  }

  /// Validates description
  static String? validateDescription(String? value) {
    return validateField(value, 'La descripción');
  }

  /// Validates name/display name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }

    if (value.trim().isEmpty) {
      return 'El nombre no puede estar vacío';
    }

    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }

    return null;
  }

  /// Validates that two passwords match
  static String? validatePasswordMatch(String? value, String? passwordValue) {
    if (value == null || value.isEmpty) {
      return 'Confirme la contraseña';
    }

    if (value != passwordValue) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }
}
