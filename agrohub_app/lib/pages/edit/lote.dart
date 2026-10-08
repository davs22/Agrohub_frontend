import 'package:agrohub_app/pages/lot_form_screen.dart';
import 'package:flutter/material.dart';

class EditLoteScreen extends StatelessWidget {
  const EditLoteScreen({super.key, required this.idLocal});
  final int idLocal;
  @override
  Widget build(BuildContext context) => LotFormScreen(id: idLocal);
}
