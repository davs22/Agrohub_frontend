enum FinancialEntryType {
  income('RECEITA', 'Receita'),
  expense('DESPESA', 'Despesa');

  const FinancialEntryType(this.code, this.label);
  final String code;
  final String label;
}

class FinancialEntry {
  const FinancialEntry({
    this.id,
    required this.description,
    required this.category,
    required this.type,
    required this.amountCents,
    required this.date,
  });

  final int? id;
  final String description;
  final String category;
  final FinancialEntryType type;
  final int amountCents;
  final DateTime date;
  double get amount => amountCents / 100;

  factory FinancialEntry.fromMap(Map<String, dynamic> row) => FinancialEntry(
    id: row['id_local'] as int,
    description: row['descricao'].toString(),
    category: row['categoria'].toString(),
    type: FinancialEntryType.values.firstWhere((type) => type.code == row['tipo']),
    amountCents: (row['valor_centavos'] as num).toInt(),
    date: DateTime.parse(row['data_movimento'].toString()),
  );

  Map<String, dynamic> toMap(String companyKey) => {
    'empresa_chave': companyKey,
    'descricao': description.trim(),
    'categoria': category.trim(),
    'tipo': type.code,
    'valor_centavos': amountCents,
    'data_movimento': DateTime(date.year, date.month, date.day).toIso8601String(),
  };

  static int? parseCents(String input) {
    var value = input.trim().replaceAll('R\$', '').replaceAll(' ', '');
    if (value.contains(',')) {
      if (!RegExp(r'^\d{1,3}(\.\d{3})*,\d{1,2}$|^\d+,\d{1,2}$').hasMatch(value)) {
        return null;
      }
      value = value.replaceAll('.', '').replaceAll(',', '.');
    }
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) return null;
    final pieces = value.split('.');
    final whole = int.tryParse(pieces.first);
    if (whole == null || whole > 9999999999) return null;
    final decimals = pieces.length > 1 ? int.parse(pieces[1].padRight(2, '0')) : 0;
    final cents = whole * 100 + decimals;
    return cents > 0 ? cents : null;
  }
}

class FinancialSummary {
  const FinancialSummary({required this.incomeCents, required this.expenseCents});

  factory FinancialSummary.fromEntries(Iterable<FinancialEntry> entries) {
    var income = 0;
    var expense = 0;
    for (final entry in entries) {
      if (entry.type == FinancialEntryType.income) {
        income += entry.amountCents;
      } else {
        expense += entry.amountCents;
      }
    }
    return FinancialSummary(incomeCents: income, expenseCents: expense);
  }

  final int incomeCents;
  final int expenseCents;
  int get balanceCents => incomeCents - expenseCents;
  double get income => incomeCents / 100;
  double get expense => expenseCents / 100;
  double get balance => balanceCents / 100;
  double? get margin => incomeCents == 0 ? null : balanceCents / incomeCents * 100;
}
