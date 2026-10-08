import 'package:agrohub_app/pages/view/inventory_screen.dart';
import 'package:agrohub_app/view_models/inventory_view_model.dart';
import 'package:flutter/material.dart';

class ViewTalhaoScreen extends StatelessWidget {
  const ViewTalhaoScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const InventoryScreen(kind: InventoryKind.fields);
}
