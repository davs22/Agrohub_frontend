import 'package:agrohub_app/pages/edit/password_change_screen.dart';
import 'package:flutter/material.dart';

class NewPassAdmScreen extends StatelessWidget {
  const NewPassAdmScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PasswordChangeScreen(admin: true);
}
