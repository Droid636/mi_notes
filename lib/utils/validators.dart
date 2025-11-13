class Validators {
  /// Validatación del formato del email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }

    // Expresión regular para validar el formato del email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingrese un email válido';
    }

    return null;
  }

  // validación de la contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  /// validación de campos obligatorios
  static String? validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }

    if (value.trim().isEmpty) {
      return '$fieldName no puede estar vacío';
    }

    return null;
  }

  // validación de títulos
  static String? validateTitle(String? value) {
    return validateField(value, 'El título');
  }

  /// validación de contenidos
  static String? validateContent(String? value) {
    return validateField(value, 'El contenido');
  }

  /// vaklidación de descripciones
  static String? validateDescription(String? value) {
    return validateField(value, 'La descripción');
  }

  /// validación de nombre/nombre para mostrar
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

  /// validaciones de confirmación de contraseña
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
