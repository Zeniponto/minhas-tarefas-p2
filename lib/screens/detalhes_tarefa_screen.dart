import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';
import '../services/firebase_service.dart';
import '../widgets/mensagem.dart';
import '../widgets/tarefa_card.dart';
import 'cadastro_tarefa_screen.dart';

class DetalhesTarefaScreen extends StatefulWidget {
  const DetalhesTarefaScreen({
    super.key,
    required this.usuario,
    required this.firebase,
    required this.tarefa,
  });

  final Usuario usuario;
  final FirebaseService firebase;
  final Tarefa tarefa;

  @override
  State<DetalhesTarefaScreen> createState() => _DetalhesTarefaScreenState();
}

class _DetalhesTarefaScreenState extends State<DetalhesTarefaScreen> {
  late final Stream<Tarefa?> _tarefa = widget.firebase.observarTarefa(
    widget.usuario,
    widget.tarefa,
  );
  bool _ocupado = false;

  Future<void> _editar(Tarefa tarefa) async {
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CadastroTarefaScreen(
          usuario: widget.usuario,
          firebase: widget.firebase,
          tarefa: tarefa,
        ),
      ),
    );
    if (salvou == true && mounted) {
      mostrarMensagem(context, 'Tarefa atualizada.');
    }
  }

  Future<void> _alterarSituacao(Tarefa tarefa) async {
    setState(() => _ocupado = true);
    try {
      await widget.firebase.alterarSituacao(widget.usuario, tarefa);
    } catch (erro) {
      if (mounted) mostrarMensagem(context, FirebaseService.mensagemErro(erro));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _excluir(Tarefa tarefa) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: Text('A tarefa "${tarefa.titulo}" será excluída.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;
    setState(() => _ocupado = true);
    try {
      await widget.firebase.excluir(widget.usuario, tarefa);
      if (mounted) Navigator.of(context).pop(true);
    } catch (erro) {
      if (mounted) mostrarMensagem(context, FirebaseService.mensagemErro(erro));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detalhes da tarefa')),
    body: SafeArea(
      child: StreamBuilder<Tarefa?>(
        stream: _tarefa,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(FirebaseService.mensagemErro(snapshot.error!)),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tarefa = snapshot.data;
          if (tarefa == null) {
            return const Center(child: Text('Esta tarefa foi excluída.'));
          }
          final tema = Theme.of(context);
          final data = MaterialLocalizations.of(
            context,
          ).formatMediumDate(tarefa.dataVencimento);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(tarefa.titulo, style: tema.textTheme.headlineMedium),
              const SizedBox(height: 20),
              Text('Descrição', style: tema.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(tarefa.descricao),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Data de vencimento'),
                      subtitle: Text(data),
                    ),
                    ListTile(
                      leading: Icon(
                        iconePrioridade(tarefa.prioridade),
                        color: corPrioridade(context, tarefa.prioridade),
                      ),
                      title: const Text('Prioridade'),
                      subtitle: Text(tarefa.prioridade),
                    ),
                    SwitchListTile(
                      title: const Text('Concluída'),
                      subtitle: Text(tarefa.situacao),
                      value: tarefa.concluida,
                      onChanged: _ocupado
                          ? null
                          : (_) => _alterarSituacao(tarefa),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _ocupado ? null : () => _editar(tarefa),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar tarefa'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _ocupado ? null : () => _excluir(tarefa),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tema.colorScheme.error,
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Excluir tarefa'),
              ),
            ],
          );
        },
      ),
    ),
  );
}
