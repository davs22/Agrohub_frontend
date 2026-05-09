import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:flutter/material.dart';

class ViewOperadorScreen extends StatefulWidget {
  const ViewOperadorScreen({super.key});

  @override
  State<ViewOperadorScreen> createState() => _ViewOperadorScreenState();
}

class _ViewOperadorScreenState extends State<ViewOperadorScreen> {
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
        headerTitle: 'Administrador',
        visibleOptions: {
          DrawerMenuOption.homeAdmin,
          DrawerMenuOption.listaOperadores,
          DrawerMenuOption.registrarOperador,
          DrawerMenuOption.editarOperador,
          DrawerMenuOption.configuracoes,
          DrawerMenuOption.logout,
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        text: 'Operadores',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 10, // Substitua pelo número real de operadores
                  itemBuilder: (context, index) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Id do Operador: $index', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('CNPJ/CPF do Comercio: 123.456.789-00', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Nome: Operador $index', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('CPF: 123.456.789-00', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Telefone: (11) 98765-4321', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Email: operador$index@example.com', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Status: Ativo', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Data de registro: 01/01/2024', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Última atualização: 01/02/2024', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Status Sync: Sincronizado', style: const TextStyle(fontWeight: FontWeight.bold)),

                        ],
                      ),
                    );
                  },
                ),
              ),
            ],),
        ),
      ),
    );
  }
}
