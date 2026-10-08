import 'package:agrohub_app/components/data_grid.dart';
import 'package:agrohub_app/services/local_image_service.dart';
import 'package:agrohub_app/utils/display_formatters.dart';
import 'package:agrohub_app/view_models/inventory_view_model.dart';
import 'package:flutter/material.dart';

class InventoryImage extends StatelessWidget {
  const InventoryImage({super.key, this.base64, this.height = 124});
  final String? base64;
  final double height;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bytes = LocalImageService.decodeImage(base64);
    final fallback = Container(
        height: height,
        width: double.infinity,
        color: colors.primaryContainer,
        child: Icon(Icons.eco_outlined,
            color: colors.onPrimaryContainer, size: 48));
    return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: bytes == null
            ? fallback
            : Image.memory(bytes,
                height: height,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stack) => fallback));
  }
}

class InventoryCard extends StatelessWidget {
  const InventoryCard(
      {super.key,
      required this.kind,
      required this.record,
      this.onEdit,
      this.onDetails});
  final InventoryKind kind;
  final Map<String, dynamic> record;
  final VoidCallback? onEdit;
  final VoidCallback? onDetails;
  String value(String key) => DisplayFormatters.value(record[key]);
  num number(String key) => num.tryParse(record[key]?.toString() ?? '') ?? 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLot = kind == InventoryKind.catalog || kind == InventoryKind.lots;
    final isOperator = kind == InventoryKind.operators;
    final title = value(isLot
        ? 'produto'
        : isOperator
            ? 'nome_completo'
            : 'nome');
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLot) ...[
                InventoryImage(base64: record['imagem_base64']?.toString()),
                const SizedBox(height: 12)
              ] else ...[
                CircleAvatar(
                    backgroundColor: colors.primaryContainer,
                    foregroundColor: colors.onPrimaryContainer,
                    child: Icon(isOperator
                        ? Icons.badge_outlined
                        : Icons.landscape_outlined)),
                const SizedBox(height: 12)
              ],
              Text(title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(DisplayFormatters.status(record['status']),
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: colors.onSurfaceVariant)),
              const SizedBox(height: 12),
              if (isLot) ...[
                Text(
                    number('preco_unitario') > 0
                        ? '${DisplayFormatters.currency(number('preco_unitario'))} / ${value('unidade_medida')}'
                        : 'Preço não definido',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.primary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                    '${DisplayFormatters.number(number('quantidade'))} ${value('unidade_medida')} em estoque'),
                const SizedBox(height: 8),
                Text('Talhão: ${value('talhao_nome')}',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                    record['data_validade'] == null
                        ? 'Validade não informada'
                        : 'Validade: ${DisplayFormatters.date(record['data_validade'])}',
                    style: Theme.of(context).textTheme.bodySmall),
              ] else if (isOperator) ...[
                DataLabel('Telefone', DisplayFormatters.phone(record['telefone']),
                    icon: Icons.phone_outlined),
                DataLabel('E-mail', value('email'), icon: Icons.mail_outline),
                DataLabel('Na equipe desde',
                    DisplayFormatters.date(record['data_registro'])),
              ] else ...[
                DataLabel('Cultura atual', value('cultura_atual'),
                    icon: Icons.grass_outlined),
                DataLabel('Área',
                    '${DisplayFormatters.number(number('tamanho_hectares'))} hectares'),
                DataLabel('Responsável', value('operador_nome')),
              ],
              const SizedBox(height: 12),
              Wrap(alignment: WrapAlignment.end, spacing: 4, runSpacing: 4, children: [
                if (onDetails != null)
                  TextButton(
                      onPressed: onDetails, child: const Text('Ver detalhes')),
                if (onEdit != null)
                  IconButton(
                      tooltip: 'Editar $title',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined)),
              ]),
            ],
          )),
      ),
    );
  }
}
