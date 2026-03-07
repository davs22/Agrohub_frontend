
import 'package:agrohub_app/components/app_bar_component.dart';
import 'package:agrohub_app/components/text_component.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppbarComponent(
        title: "Inicio",
      ),
      body: Center(
        child: TextComponent(text: "Olá mundo!"),
      ),
    );
  }
}
