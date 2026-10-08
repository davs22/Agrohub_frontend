import 'package:agrohub_app/components/form_page.dart';

class BaseRegisterTemplate extends FormPage {
  const BaseRegisterTemplate({
    super.key,
    required super.title,
    required super.headerDrawerTitle,
    required super.visibleOptions,
    required super.fields,
    required super.isLoading,
    required super.onSubmit,
  }) : super(submitLabel: 'Cadastrar');
}