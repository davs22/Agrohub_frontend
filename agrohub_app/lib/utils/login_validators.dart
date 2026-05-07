import 'package:flutter/services.dart';

class LoginValidators {
  static String? validatePassword(String value, {required int minLength}) {
    if (value.trim().isEmpty) {
      return 'Informe a senha.';
    }

    if (value.length < minLength) {
      return 'A senha deve ter no minimo $minLength caracteres.';
    }

    return null;
  }

  static String? validateCpf(String value) {
    final digits = _onlyDigits(value);

    if (digits.isEmpty) {
      return 'Informe o CPF.';
    }

    if (digits.length != 11) {
      return 'Digite um CPF com 11 numeros.';
    }

    if (_allDigitsEqual(digits) || !_isValidCpf(digits)) {
      return 'Digite um CPF valido.';
    }

    return null;
  }

  static String? validateCpfOrCnpj(String value) {
    final digits = _onlyDigits(value);

    if (digits.isEmpty) {
      return 'Informe o CPF ou CNPJ.';
    }

    if (digits.length == 11) {
      return validateCpf(value);
    }

    if (digits.length == 14) {
      return validateCnpj(value);
    }

    return 'Digite um CPF com 11 numeros ou um CNPJ com 14 numeros.';
  }

  static String? validateCnpj(String value) {
    final digits = _onlyDigits(value);

    if (digits.isEmpty) {
      return 'Informe o CNPJ.';
    }

    if (digits.length != 14) {
      return 'Digite um CNPJ com 14 numeros.';
    }

    if (_allDigitsEqual(digits) || !_isValidCnpj(digits)) {
      return 'Digite um CNPJ valido.';
    }

    return null;
  }

  static String? validateVerificationCode(
    String value, {
    required int length,
  }) {
    final digits = _onlyDigits(value);

    if (digits.isEmpty) {
      return 'Informe o codigo de verificacao.';
    }

    if (digits.length != length) {
      return 'Digite um codigo com $length numeros.';
    }

    return null;
  }

  static String formatCpf(String value) {
    final digits = _onlyDigits(value);
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length && index < 11; index++) {
      if (index == 3 || index == 6) {
        buffer.write('.');
      } else if (index == 9) {
        buffer.write('-');
      }

      buffer.write(digits[index]);
    }

    return buffer.toString();
  }

  static String formatCpfOrCnpj(String value) {
    final digits = _onlyDigits(value);

    if (digits.length <= 11) {
      return formatCpf(value);
    }

    final buffer = StringBuffer();

    for (var index = 0; index < digits.length && index < 14; index++) {
      if (index == 2 || index == 5) {
        buffer.write('.');
      } else if (index == 8) {
        buffer.write('/');
      } else if (index == 12) {
        buffer.write('-');
      }

      buffer.write(digits[index]);
    }

    return buffer.toString();
  }

  static String _onlyDigits(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  static bool _allDigitsEqual(String value) {
    return value.split('').every((digit) => digit == value[0]);
  }

  static bool _isValidCpf(String digits) {
    final numbers = digits.split('').map(int.parse).toList();

    var firstSum = 0;
    for (var index = 0; index < 9; index++) {
      firstSum += numbers[index] * (10 - index);
    }

    final firstDigit = (firstSum * 10) % 11 % 10;
    if (numbers[9] != firstDigit) {
      return false;
    }

    var secondSum = 0;
    for (var index = 0; index < 10; index++) {
      secondSum += numbers[index] * (11 - index);
    }

    final secondDigit = (secondSum * 10) % 11 % 10;
    return numbers[10] == secondDigit;
  }

  static bool _isValidCnpj(String digits) {
    final numbers = digits.split('').map(int.parse).toList();

    const firstWeights = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    const secondWeights = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    var firstSum = 0;
    for (var index = 0; index < 12; index++) {
      firstSum += numbers[index] * firstWeights[index];
    }

    final firstRemainder = firstSum % 11;
    final firstDigit = firstRemainder < 2 ? 0 : 11 - firstRemainder;
    if (numbers[12] != firstDigit) {
      return false;
    }

    var secondSum = 0;
    for (var index = 0; index < 13; index++) {
      secondSum += numbers[index] * secondWeights[index];
    }

    final secondRemainder = secondSum % 11;
    final secondDigit = secondRemainder < 2 ? 0 : 11 - secondRemainder;
    return numbers[13] == secondDigit;
  }
}

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = LoginValidators.formatCpf(newValue.text);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CpfOrCnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = LoginValidators.formatCpfOrCnpj(newValue.text);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
