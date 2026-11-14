import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/preferences_service.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/mensagem.dart';
import 'cadastro_tarefa_screen.dart';
import 'configuracoes_screen.dart';
import 'sobre_screen.dart';
import 'tarefas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.usuario,
    required this.auth,
    required this.firebase,
    required this.preferences,
  });

  final Usuario usuario;
  final AuthService auth;
  final FirebaseService firebase;
  final PreferencesService preferences;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Stream<List<Tarefa>> _tarefas = widget.firebase.observarTarefas(
    widget.usuario,
  );
  int _pagina = 0;
  bool _saindo = false;

  Future<void> _sair() async {
    setState(() => _saindo = true);
    try {
      await widget.auth.sair();
    } catch (erro) {
      if (mounted) mostrarMensagem(context, AuthService.mensagemErro(erro));
    } finally {
      if (mounted) setState(() => _saindo = false);
    }
  }

  Future<void> _novaTarefa() async {
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CadastroTarefaScreen(
          usuario: widget.usuario,
          firebase: widget.firebase,
        ),
      ),
    );
    if (salvou == true && mounted) {
      mostrarMensagem(context, 'Tarefa cadastrada.');
    }
  }

  @override
  Widget build(BuildContext context) {
    const titulos = [
      'Início',
      'Minhas tarefas',
      'Configurações',
      'Sobre o aplicativo',
    ];
    return Scaffold(
      appBar: AppBar(title: Text(titulos[_pagina])),
      drawer: DrawerMenu(
        usuario: widget.usuario,
        paginaAtual: _pagina,
        onSelecionar: (pagina) => setState(() => _pagina = pagina),
        onSair: _saindo ? null : _sair,
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _pagina,
          children: [
            _inicio(),
            TarefasScreen(usuario: widget.usuario, firebase: widget.firebase),
            ConfiguracoesScreen(preferences: widget.preferences),
            const SobreScreen(),
          ],
        ),
      ),
      floatingActionButton: _pagina == 1
          ? FloatingActionButton.extended(
              onPressed: _novaTarefa,
              icon: const Icon(Icons.add),
              label: const Text('Nova tarefa'),
            )
          : null,
    );
  }

  Widget _inicio() => StreamBuilder<List<Tarefa>>(
    stream: _tarefas,
    builder: (context, snapshot) {
      final tema = Theme.of(context);
      final tarefas = snapshot.data ?? [];
      final concluidas = tarefas.where((tarefa) => tarefa.concluida).length;
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: tema.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Olá, ${widget.usuario.nome}!',
              style: tema.textTheme.headlineSmall!.copyWith(
                color: tema.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Suas tarefas', style: tema.textTheme.titleLarge),
          const SizedBox(height: 16),
          if (snapshot.hasError)
            Text(FirebaseService.mensagemErro(snapshot.error!))
          else if (!snapshot.hasData)
            const Center(child: CircularProgressIndicator())
          else ...[
            _resumo('Cadastradas', tarefas.length, Icons.list_alt),
            const SizedBox(height: 12),
            _resumo('Pendentes', tarefas.length - concluidas, Icons.schedule),
            const SizedBox(height: 12),
            _resumo('Concluídas', concluidas, Icons.check_circle_outline),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() => _pagina = 1),
            icon: const Icon(Icons.checklist),
            label: const Text('Minhas tarefas'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _novaTarefa,
            icon: const Icon(Icons.add),
            label: const Text('Cadastrar tarefa'),
          ),
        ],
      );
    },
  );

  Widget _resumo(String titulo, int quantidade, IconData icone) => Card(
    child: ListTile(
      leading: Icon(icone, color: Theme.of(context).colorScheme.primary),
      title: Text(titulo),
      trailing: Text(
        '$quantidade',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ),
  );
}
