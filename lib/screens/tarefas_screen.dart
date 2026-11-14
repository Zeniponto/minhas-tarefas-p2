import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';
import '../services/firebase_service.dart';
import '../widgets/mensagem.dart';
import '../widgets/tarefa_card.dart';
import 'detalhes_tarefa_screen.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({
    super.key,
    required this.usuario,
    required this.firebase,
  });
  final Usuario usuario;
  final FirebaseService firebase;

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  late final Stream<List<Tarefa>> _tarefas = widget.firebase.observarTarefas(
    widget.usuario,
  );
  final Set<String> _alterando = {};

  Future<void> _alterarSituacao(Tarefa tarefa) async {
    setState(() => _alterando.add(tarefa.id!));
    try {
      await widget.firebase.alterarSituacao(widget.usuario, tarefa);
    } catch (erro) {
      if (mounted) mostrarMensagem(context, FirebaseService.mensagemErro(erro));
    } finally {
      if (mounted) setState(() => _alterando.remove(tarefa.id!));
    }
  }

  Future<void> _abrir(Tarefa tarefa) async {
    final excluiu = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DetalhesTarefaScreen(
          usuario: widget.usuario,
          firebase: widget.firebase,
          tarefa: tarefa,
        ),
      ),
    );
    if (excluiu == true && mounted) {
      mostrarMensagem(context, 'Tarefa excluída.');
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Tarefa>>(
    stream: _tarefas,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(FirebaseService.mensagemErro(snapshot.error!)),
          ),
        );
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final tarefas = snapshot.data!;
      if (tarefas.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Nenhuma tarefa cadastrada. Toque em Nova tarefa para começar.',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
        itemCount: tarefas.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tarefa = tarefas[index];
          return TarefaCard(
            key: ValueKey(tarefa.id),
            tarefa: tarefa,
            onAbrir: () => _abrir(tarefa),
            onAlterarSituacao: _alterando.contains(tarefa.id)
                ? null
                : (_) => _alterarSituacao(tarefa),
          );
        },
      );
    },
  );
}
