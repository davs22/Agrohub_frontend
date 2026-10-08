import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/profile_avatar.dart';
import 'package:agrohub_app/models/profile_appearance.dart';
import 'package:agrohub_app/pages/edit/pass_adm.dart';
import 'package:agrohub_app/pages/edit/pass_operador.dart';
import 'package:agrohub_app/utils/display_formatters.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:agrohub_app/view_models/profile_view_model.dart';
import 'package:flutter/material.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final ProfileViewModel _viewModel = ProfileViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FlowBackGuard(
      child: Scaffold(
        appBar: AppBarComponent(
          title: 'Meu perfil',
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              tooltip: 'Voltar ao início',
              icon: const Icon(Icons.home_outlined),
              onPressed: () => FlowNavigation.goToRoot(context),
            ),
            Builder(
                builder: (context) => IconButton(
                      tooltip: 'Menu',
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    )),
          ],
        ),
        endDrawer: const DrawerMenuComponent(),
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _viewModel,
            builder: (context, _) {
              if (_viewModel.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              final session = _viewModel.session;
              if (session == null ||
                  (!session.isAdmin && !session.isOperator)) {
                return Center(
                    child: Text(_viewModel.error ?? 'Perfil indisponível.'));
              }
              final record = _viewModel.record ?? {};
              final name = DisplayFormatters.value(record['nome_completo'] ??
                  record['nome'] ??
                  session.displayName);
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              ProfileAvatar(
                                  appearance: _viewModel.appearance,
                                  radius: 56),
                              const SizedBox(height: 16),
                              Text(name,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              const SizedBox(height: 6),
                              Chip(
                                avatar: Icon(
                                    session.isAdmin
                                        ? Icons.admin_panel_settings
                                        : Icons.engineering,
                                    size: 18),
                                label: Text(session.isAdmin
                                    ? 'Administrador'
                                    : 'Operador'),
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: _viewModel.saving
                                    ? null
                                    : _viewModel.selectPhoto,
                                icon: const Icon(
                                    Icons.add_photo_alternate_outlined),
                                label: const Text('Escolher foto'),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                  'Foto e avatar são salvos somente para este login neste dispositivo.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: colors.onSurfaceVariant)),
                              if (_viewModel.saving) ...[
                                const SizedBox(height: 12),
                                const LinearProgressIndicator(),
                              ],
                              if (_viewModel.error != null) ...[
                                const SizedBox(height: 12),
                                Text(_viewModel.error!,
                                    style: TextStyle(color: colors.error)),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Escolha seu avatar',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text('Selecione uma opção para substituir a foto.',
                          style: TextStyle(color: colors.onSurfaceVariant)),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: AgroAvatar.values.map((avatar) {
                          final selected =
                              _viewModel.appearance.photoBase64 == null &&
                                  _viewModel.appearance.avatarId == avatar.id;
                          return Semantics(
                            selected: selected,
                            button: true,
                            label: avatar.label,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: _viewModel.saving
                                  ? null
                                  : () => _viewModel.selectAvatar(avatar.id),
                              child: Container(
                                width: 136,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? colors.secondaryContainer
                                      : colors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                      color: selected
                                          ? colors.primary
                                          : colors.outlineVariant,
                                      width: selected ? 2 : 1),
                                ),
                                child: Column(
                                  children: [
                                    ProfileAvatar(
                                        appearance: ProfileAppearance(
                                            avatarId: avatar.id),
                                        radius: 30),
                                    const SizedBox(height: 8),
                                    Text(avatar.label,
                                        textAlign: TextAlign.center),
                                    if (selected)
                                      Icon(Icons.check_circle,
                                          size: 18, color: colors.primary),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  session.isAdmin
                                      ? 'Acesso à empresa'
                                      : 'Dados do perfil',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 16),
                              _field('Nome', name, Icons.person_outline),
                              _field(
                                  session.isAdmin
                                      ? 'Documento da empresa'
                                      : 'CPF / CNPJ',
                                  record['cpf'] ??
                                      record['documento'] ??
                                      session.documento,
                                  Icons.badge_outlined),
                              _field('E-mail', record['email'],
                                  Icons.mail_outline),
                              _field('Telefone', record['telefone'],
                                  Icons.phone_outlined),
                              _field(
                                  'Situação',
                                  DisplayFormatters.status(record['status']),
                                  Icons.check_circle_outline),
                              _field(
                                  'Cadastro em',
                                  DisplayFormatters.date(
                                      record['data_registro']),
                                  Icons.event_outlined),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => session.isAdmin
                                      ? const NewPassAdmScreen()
                                      : const NewPassOperadorScreen(),
                                )),
                            icon: const Icon(Icons.lock_reset),
                            label: const Text('Alterar senha'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _field(String label, Object? value, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: Theme.of(context).textTheme.labelLarge),
      subtitle: SelectableText(DisplayFormatters.value(value),
          style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
