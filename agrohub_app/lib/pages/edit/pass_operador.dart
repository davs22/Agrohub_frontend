import 'package:agrohub_app/pages/edit/password_change_screen.dart';
import 'package:flutter/material.dart';

class NewPassOperadorScreen extends StatelessWidget {
  const NewPassOperadorScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PasswordChangeScreen(admin: false);
}
