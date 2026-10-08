import 'package:flutter/material.dart';

class DataGrid<T> extends StatelessWidget {
  const DataGrid(
      {super.key,
      required this.items,
      required this.itemBuilder,
      this.itemHeight = 360});
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final double itemHeight;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 980
            ? 4
            : width >= 740
                ? 3
                : width >= 520
                    ? 2
                    : 1;
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: itemHeight + (scale - 1).clamp(0, 3) * 240,
          ),
          itemBuilder: (context, index) => itemBuilder(context, items[index]),
        );
      });
}

class DataSearchToolbar extends StatelessWidget {
  const DataSearchToolbar(
      {super.key,
      required this.filter,
      required this.filters,
      required this.onFilterChanged,
      required this.onSearch,
      required this.searchHint});
  final String filter;
  final Map<String, String> filters;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSearch;
  final String searchHint;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final narrow = constraints.maxWidth < 390;
        final selector = SizedBox(
          width: narrow
              ? double.infinity
              : constraints.maxWidth < 650
                  ? 142
                  : 205,
          child: DropdownButtonFormField<String>(
            initialValue: filter,
            isExpanded: true,
            decoration: const InputDecoration(
                labelText: 'Filtrar', prefixIcon: Icon(Icons.filter_list)),
            items: filters.entries
                .map((entry) => DropdownMenuItem(
                    value: entry.key, child: Text(entry.value)))
                .toList(),
            onChanged: (value) {
              if (value != null) onFilterChanged(value);
            },
          ),
        );
        final search = TextField(
          onChanged: onSearch,
          decoration: InputDecoration(
            hintText: searchHint,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.outline)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 2)),
          ),
        );
        if (narrow) {
          return Column(
              children: [selector, const SizedBox(height: 12), search]);
        }
        return Row(children: [
          selector,
          const SizedBox(width: 16),
          Expanded(child: search)
        ]);
      });
}

class DataLabel extends StatelessWidget {
  const DataLabel(this.label, this.value, {super.key, this.icon});
  final String label;
  final String value;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (icon != null) ...[
            Icon(icon,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8)
          ],
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                Text(value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium),
              ])),
        ]),
      );
}
