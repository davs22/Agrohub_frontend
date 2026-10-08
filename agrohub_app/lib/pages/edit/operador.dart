import 'package:agrohub_app/pages/edit/management_form.dart';

class EditOperadorScreen extends ManagementFormScreen {
  const EditOperadorScreen({super.key, required int idLocal}) : super(table: 'operadores', id: idLocal);
}
