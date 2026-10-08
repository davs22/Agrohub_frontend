import 'package:agrohub_app/pages/view/inventory_screen.dart';
import 'package:agrohub_app/view_models/inventory_view_model.dart';
import 'package:flutter/material.dart';

class CarrinhoScreen extends StatelessWidget {
  const CarrinhoScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const InventoryScreen(kind: InventoryKind.catalog);
}
