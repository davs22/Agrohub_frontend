import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:flutter/material.dart';

class HomeAdmScreen extends StatefulWidget {
  const HomeAdmScreen({super.key});

  @override
  State<HomeAdmScreen> createState() => _HomeAdmScreenState();
}

class _HomeAdmScreenState extends State<HomeAdmScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'AgroHub',
        automaticallyImplyLeading: false,
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.menu),
            ),
          ),
        ],
      ),
      endDrawer: const DrawerMenuComponent(headerTitle: 'Administrador'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const Padding(
              padding: EdgeInsets.only(left: 15),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    TextComponent(
                      text: 'Painel Administrativo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: 350,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total de vendas:'),
                  Text('Total de operadores:'),
                  Text('Total de Talhões:'),
                  Text('Total de lotes registrados:'),
                  Text('Data de registro instância:'),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: 350,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nome do usuário:'),
                  Text('CNPJ/CPF:'),
                  Text('Hectares totais:'),
                  Text('Latitude:'),
                  Text('Longitude:'),
                  Text('Telefone:'),
                  SizedBox(height: 40),
                  Center(
                    child: ButtonComponent(
                      label: 'Editar dados',
                      height: 25,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      onPressed: () {
                        debugPrint('Editar dados');
                      },
                      borderColor: Color.fromARGB(255, 76, 175, 80),
                      backgroundColor: Color.fromARGB(255, 76, 175, 80),
                      borderRadius: 2,
                      width: 300,
                    ),
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
