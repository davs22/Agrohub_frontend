import 'package:intl/intl.dart';

abstract final class DisplayFormatters {
  static String value(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? 'Não informado' : text;
  }

  static String date(Object? value) {
    final parsed = value is DateTime
        ? value
        : DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return 'Não informado';
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(parsed.toLocal());
  }

  static String currency(num value) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);

  static String number(num value) =>
      NumberFormat('#,##0.##', 'pt_BR').format(value);

  static String status(Object? value) {
    return switch (value?.toString().toUpperCase()) {
      'ATIVO' => 'Ativo',
      'INATIVO' => 'Inativo',
      'VENDIDO' => 'Vendido',
      'RESERVADO' => 'Reservado',
      'DISPONIVEL' => 'Disponível',
      'ESGOTADO' => 'Esgotado',
      _ => DisplayFormatters.value(value),
    };
  }

  static String document(Object? value) {
    final digits = (value?.toString() ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11) {
      return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
    }
    if (digits.length == 14) {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12)}';
    }
    return DisplayFormatters.value(value);
  }

  static String phone(Object? value) {
    final digits = (value?.toString() ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
    }
    if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    }
    return DisplayFormatters.value(value);
  }

  static String cep(Object? value) {
    final digits = (value?.toString() ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length == 8) {
      return '${digits.substring(0, 5)}-${digits.substring(5)}';
    }
    return DisplayFormatters.value(value);
  }
}
