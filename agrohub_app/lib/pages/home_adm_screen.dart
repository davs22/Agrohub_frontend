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
      endDrawer: const DrawerMenuComponent(
        headerTitle: 'Comercio',
        visibleOptions: {
          DrawerMenuOption.homeAdmin,
          DrawerMenuOption.listaOperadores,
          DrawerMenuOption.registrarOperador,
          DrawerMenuOption.editarOperador,
          DrawerMenuOption.configuracoes,
          DrawerMenuOption.logout,
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resumo do painel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text('Total de vendas: 10', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Total de operadores: 2', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Total de talhoes: 5', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Total de lotes registrados: 10', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Data de registro da instancia: 01/01/2024', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dados do usuario',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text('Nome do usuario:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const Text('CNPJ/CPF:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const Text('Hectares totais:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const Text('Latitude:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const Text('Longitude:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const Text('Telefone:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 24),
                            Center(
                              child: ButtonComponent(
                                label: 'Editar dados',
                                height: 40,
                                fontSize: 16,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                onPressed: () {
                                  debugPrint('Editar dados');
                                },
                                borderColor: const Color.fromARGB(
                                  255,
                                  76,
                                  175,
                                  80,
                                ),
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  76,
                                  175,
                                  80,
                                ),
                                borderRadius: 4,
                                width: 300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}