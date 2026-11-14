import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import '../widgets/mensagem.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key, required this.preferences});
  final PreferencesService preferences;

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  bool _salvando = false;

  Future<void> _alterarTema(bool escuro) async {
    setState(() => _salvando = true);
    try {
      await widget.preferences.alterarTema(escuro);
    } catch (_) {
      if (mounted) mostrarMensagem(context, 'Não foi possível salvar o tema.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text('Aparência', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 16),
      Card(
        child: SwitchListTile(
          title: const Text('Tema escuro'),
          subtitle: Text(
            widget.preferences.temaEscuro
                ? 'Modo escuro ativado'
                : 'Modo claro ativado',
          ),
          secondary: const Icon(Icons.dark_mode_outlined),
          value: widget.preferences.temaEscuro,
          onChanged: _salvando ? null : _alterarTema,
        ),
      ),
    ],
  );
}
