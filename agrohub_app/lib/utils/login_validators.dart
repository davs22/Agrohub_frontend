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
