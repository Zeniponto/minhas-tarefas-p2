import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tarefas_app/main.dart';
import 'package:tarefas_app/models/tarefa.dart';
import 'package:tarefas_app/models/usuario.dart';
import 'package:tarefas_app/services/auth_service.dart';
import 'package:tarefas_app/services/firebase_service.dart';
import 'package:tarefas_app/services/preferences_service.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('cadastro, login, CRUD, Drawer, tema e logout', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final auth = AuthTeste();
    final firebase = FirebaseTeste();
    final preferences = PreferencesService();
    await preferences.carregar();
    addTearDown(preferences.dispose);
    addTearDown(auth.fechar);
    addTearDown(firebase.fechar);
    await tester.pumpWidget(
      MinhasTarefasApp(
        preferences: preferences,
        auth: auth,
        firebase: firebase,
      ),
    );
    await tester.pumpAndSettle();

    await tocar(tester, find.text('Entrar'));
    expect(find.text('Informe o e-mail.'), findsOneWidget);
    expect(find.text('Informe a senha.'), findsOneWidget);
    await tocar(tester, find.text('Cadastrar novo usuário'));
    await tester.enterText(find.byType(TextFormField).at(0), 'Arthur Teste');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'arthur@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'senha123');
    await tocar(tester, find.text('Cadastrar'));
    expect(
      find.text('Conta criada. Entre com seu e-mail e senha.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'arthur@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'senhaerrada');
    await tocar(tester, find.text('Entrar'));
    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(1), 'senha123');
    await tocar(tester, find.text('Entrar'));
    expect(find.text('Olá, Arthur Teste!'), findsOneWidget);

    await tocar(tester, find.text('Cadastrar tarefa'));
    await preencherTarefa(
      tester,
      'Estudar Flutter',
      'Revisar navegação e models.',
    );
    await tocar(tester, find.text('Salvar tarefa'));
    await tocar(tester, find.widgetWithText(ElevatedButton, 'Minhas tarefas'));
    expect(find.text('Estudar Flutter'), findsOneWidget);
    await tocar(tester, find.text('Nova tarefa'));
    await preencherTarefa(
      tester,
      'Entregar P2',
      'Enviar o repositório e gravar o vídeo.',
    );
    await tocar(tester, find.byType(DropdownButtonFormField<String>));
    await tocar(tester, find.text('Alta').last);
    await tocar(tester, find.text('Salvar tarefa'));
    expect(find.text('Estudar Flutter'), findsOneWidget);
    expect(find.text('Entregar P2'), findsOneWidget);
    expect(find.text('Prioridade alta'), findsOneWidget);
    expect(find.byType(ListView), findsWidgets);

    await tocar(tester, find.text('Estudar Flutter'));
    expect(find.text('Revisar navegação e models.'), findsOneWidget);
    await tocar(tester, find.text('Editar tarefa'));
    expect(find.text('Estudar Flutter'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).first,
      'Estudar Firebase',
    );
    await tocar(tester, find.text('Salvar tarefa'));
    expect(find.text('Estudar Firebase'), findsOneWidget);
    await tocar(tester, find.byType(Switch));
    expect(find.text('Concluída'), findsNWidgets(2));
    await tocar(tester, find.byType(Switch));
    expect(find.text('Pendente'), findsOneWidget);
    await tocar(tester, find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    await tocar(tester, find.text('Entregar P2'));
    await tocar(tester, find.text('Excluir tarefa'));
    await tocar(tester, find.text('Cancelar'));
    expect(firebase.quantidade, 2);
    await tocar(tester, find.text('Excluir tarefa'));
    await tocar(tester, find.text('Excluir'));
    expect(find.text('Entregar P2'), findsNothing);
    expect(firebase.quantidade, 1);

    await abrirMenu(tester, 'Início');
    expect(find.text('Olá, Arthur Teste!'), findsOneWidget);
    expect(find.text('Cadastradas'), findsOneWidget);
    await abrirMenu(tester, 'Sobre o aplicativo');
    expect(find.text('Programação Mobile - P2'), findsOneWidget);
    await abrirMenu(tester, 'Configurações');
    await tocar(tester, find.byType(Switch));
    expect(preferences.themeMode, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.text('Tema escuro'))).brightness,
      Brightness.dark,
    );
    final recarregado = PreferencesService();
    await recarregado.carregar();
    expect(recarregado.themeMode, ThemeMode.dark);
    recarregado.dispose();
    await abrirMenu(tester, 'Sair');
    expect(find.text('Entre para organizar suas tarefas.'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Entrar'))).brightness,
      Brightness.dark,
    );
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'arthur@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'senha123');
    await tocar(tester, find.text('Entrar'));
    await tocar(tester, find.widgetWithText(ElevatedButton, 'Minhas tarefas'));
    expect(find.text('Estudar Firebase'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('formulários funcionam em celular pequeno com teclado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final auth = AuthTeste();
    final firebase = FirebaseTeste();
    final preferences = PreferencesService();
    addTearDown(auth.fechar);
    addTearDown(firebase.fechar);
    addTearDown(preferences.dispose);
    await tester.pumpWidget(
      MinhasTarefasApp(
        preferences: preferences,
        auth: auth,
        firebase: firebase,
      ),
    );
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Cadastrar novo usuário'));
    await tocar(tester, find.text('Cadastrar'));
    expect(find.text('Informe seu nome.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

Future<void> tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> abrirMenu(WidgetTester tester, String destino) async {
  await tocar(tester, find.byTooltip('Abrir menu de navegação'));
  expect(find.text('arthur@example.com'), findsOneWidget);
  await tocar(tester, find.widgetWithText(ListTile, destino));
}

Future<void> preencherTarefa(
  WidgetTester tester,
  String titulo,
  String descricao,
) async {
  await tester.enterText(find.byType(TextFormField).at(0), titulo);
  await tester.enterText(find.byType(TextFormField).at(1), descricao);
  await tocar(tester, find.byType(TextFormField).at(2));
  await tocar(tester, find.text('OK'));
}

// Os testes de interface usam serviços em memória. O acesso ao banco é testado separadamente.
class AuthTeste implements AuthService {
  final _eventos = StreamController<Usuario?>.broadcast();
  final _contas = <String, (Usuario, String)>{};
  Usuario? atual;

  @override
  Stream<Usuario?> get usuario async* {
    yield atual;
    yield* _eventos.stream;
  }

  @override
  Future<void> cadastrar(String nome, String email, String senha) async {
    _contas[email] = (Usuario(uid: email, nome: nome, email: email), senha);
  }

  @override
  Future<void> entrar(String email, String senha) async {
    final conta = _contas[email];
    if (conta == null || conta.$2 != senha) {
      throw FirebaseAuthException(code: 'invalid-credential');
    }
    atual = conta.$1;
    _eventos.add(atual);
  }

  @override
  Future<void> sair() async {
    atual = null;
    _eventos.add(null);
  }

  Future<void> fechar() => _eventos.close();
}

class FirebaseTeste implements FirebaseService {
  final _eventos = StreamController<void>.broadcast();
  final _dados = <String, Map<String, Tarefa>>{};
  int _proximoId = 0;

  int get quantidade =>
      _dados.values.fold(0, (total, tarefas) => total + tarefas.length);
  List<Tarefa> _lista(Usuario usuario) =>
      _dados[usuario.uid]?.values.toList() ?? [];

  @override
  Stream<List<Tarefa>> observarTarefas(Usuario usuario) async* {
    yield _lista(usuario);
    yield* _eventos.stream.map((_) => _lista(usuario));
  }

  @override
  Stream<Tarefa?> observarTarefa(Usuario usuario, Tarefa tarefa) =>
      observarTarefas(usuario).map((lista) {
        for (final registro in lista) {
          if (registro.id == tarefa.id) return registro;
        }
        return null;
      });

  @override
  Future<void> salvar(Usuario usuario, Tarefa tarefa) async {
    final id = tarefa.id ?? '${_proximoId++}';
    (_dados[usuario.uid] ??= {})[id] = tarefa.copyWith(id: id);
    _eventos.add(null);
  }

  @override
  Future<void> alterarSituacao(Usuario usuario, Tarefa tarefa) async {
    _dados[usuario.uid]![tarefa.id!] = tarefa.copyWith(
      concluida: !tarefa.concluida,
    );
    _eventos.add(null);
  }

  @override
  Future<void> excluir(Usuario usuario, Tarefa tarefa) async {
    _dados[usuario.uid]!.remove(tarefa.id);
    _eventos.add(null);
  }

  Future<void> fechar() => _eventos.close();
}
