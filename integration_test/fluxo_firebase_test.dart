import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tarefas_app/main.dart' as app;
import 'package:tarefas_app/services/preferences_service.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fluxo no Android com Firebase', (tester) async {
    await Firebase.initializeApp();
    final sessaoAnterior = FirebaseAuth.instance.currentUser;
    if (sessaoAnterior != null) {
      if (!(sessaoAnterior.email?.startsWith('teste-p2-') ?? false)) {
        throw StateError('Encerre sua sessão antes de executar o teste.');
      }
      await FirebaseAuth.instance.signOut();
    }
    final preferenciasTeste = PreferencesService();
    await preferenciasTeste.alterarTema(false);
    preferenciasTeste.dispose();
    await app.main();
    await esperar(tester, find.text('Entre para organizar suas tarefas.'));
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('01_login');

    final email =
        'teste-p2-${DateTime.now().millisecondsSinceEpoch}@example.com';
    const senha = 'P2teste123!';
    binding.reportData ??= {};
    binding.reportData!['email'] = email;
    await tocar(tester, find.text('Cadastrar novo usuário'));
    await esperar(tester, find.text('Criar conta'));
    await tester.enterText(find.byType(TextFormField).at(0), 'Arthur');
    await tester.enterText(find.byType(TextFormField).at(1), email);
    await tester.enterText(find.byType(TextFormField).at(2), senha);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('02_cadastro_usuario');
    await tocar(tester, find.text('Cadastrar'));
    await esperar(tester, find.text('Entre para organizar suas tarefas.'));
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), senha);
    await tocar(tester, find.text('Entrar'));
    await esperar(tester, find.text('Olá, Arthur!'));
    binding.reportData!['uid'] = FirebaseAuth.instance.currentUser!.uid;

    await tocar(tester, find.text('Cadastrar tarefa'));
    await preencher(
      tester,
      'Estudar Flutter',
      'Revisar navegação, models e Firebase.',
      'Média',
    );
    await tocar(tester, find.text('Salvar tarefa'));
    await esperar(tester, find.text('Olá, Arthur!'));
    await tocar(tester, find.text('Cadastrar tarefa'));
    await preencher(
      tester,
      'Entregar P2',
      'Conferir o projeto e gravar a demonstração.',
      'Alta',
    );
    await tocar(tester, find.text('Salvar tarefa'));
    await esperar(tester, find.text('Olá, Arthur!'));
    await esperar(tester, find.text('2').first);
    await binding.takeScreenshot('03_inicio');

    await tocar(tester, find.byTooltip('Abrir menu de navegação'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('04_drawer');
    await tocar(tester, find.widgetWithText(ListTile, 'Minhas tarefas'));
    await esperar(tester, find.text('Estudar Flutter'));
    await esperar(tester, find.text('Entregar P2'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('05_lista_tarefas');
    await tocar(tester, find.text('Estudar Flutter'));
    await esperar(tester, find.text('Editar tarefa'));
    await tocar(tester, find.text('Editar tarefa'));
    await esperar(tester, find.text('Salvar tarefa'));
    await tester.enterText(
      find.byType(TextFormField).first,
      'Revisar Flutter e Firebase',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Salvar tarefa'));
    await esperar(tester, find.text('Detalhes da tarefa'));
    await esperar(tester, find.text('Revisar Flutter e Firebase'));
    await tocar(tester, find.byType(Switch));
    await esperarCondicao(
      tester,
      () =>
          find.text('Concluída').evaluate().length == 2 &&
          tester.widget<Switch>(find.byType(Switch)).onChanged != null,
    );
    await tester.pumpAndSettle();
    await binding.takeScreenshot('06_detalhes_tarefa');
    await tocar(tester, find.byTooltip('Voltar'));
    await esperar(tester, find.text('Entregar P2'));
    await tocar(tester, find.text('Entregar P2'));
    await esperar(tester, find.text('Excluir tarefa'));
    await tocar(tester, find.text('Excluir tarefa'));
    await esperar(tester, find.text('Excluir tarefa?'));
    await tocar(tester, find.text('Excluir'));
    await esperar(tester, find.text('Nova tarefa'));
    expect(find.text('Entregar P2'), findsNothing);

    await menu(tester, 'Configurações');
    await esperar(tester, find.text('Tema escuro'));
    await tocar(tester, find.byType(Switch));
    await esperar(tester, find.text('Modo escuro ativado'));
    final preferences = PreferencesService();
    await preferences.carregar();
    expect(preferences.themeMode, ThemeMode.dark);
    preferences.dispose();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('07_configuracoes_escuro');
    await menu(tester, 'Sair');
    await esperar(tester, find.text('Entrar'));
    await binding.takeScreenshot('08_login_escuro');
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), senha);
    await tocar(tester, find.text('Entrar'));
    await esperar(tester, find.text('Olá, Arthur!'));
    await tocar(tester, find.widgetWithText(ElevatedButton, 'Minhas tarefas'));
    await esperar(tester, find.text('Revisar Flutter e Firebase'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('09_lista_escuro');
    // A conta temporária fica ativa para conferir a reabertura do APK.
    // O responsável pelo teste remove os dados e a conta ao terminar essa conferência.
  }, timeout: const Timeout(Duration(minutes: 5)));
}

Future<void> esperar(WidgetTester tester, Finder finder) async {
  final limite = DateTime.now().add(const Duration(seconds: 45));
  while (finder.evaluate().isEmpty && DateTime.now().isBefore(limite)) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  expect(finder, findsWidgets);
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> esperarCondicao(
  WidgetTester tester,
  bool Function() condicao,
) async {
  final limite = DateTime.now().add(const Duration(seconds: 45));
  while (!condicao() && DateTime.now().isBefore(limite)) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  expect(condicao(), isTrue);
}

Future<void> tocar(WidgetTester tester, Finder finder) async {
  await esperar(tester, finder);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 350));
}

Future<void> menu(WidgetTester tester, String destino) async {
  await tocar(tester, find.byTooltip('Abrir menu de navegação'));
  await tocar(tester, find.widgetWithText(ListTile, destino));
}

Future<void> preencher(
  WidgetTester tester,
  String titulo,
  String descricao,
  String prioridade,
) async {
  await esperar(tester, find.text('Salvar tarefa'));
  await tester.enterText(find.byType(TextFormField).at(0), titulo);
  await tester.enterText(find.byType(TextFormField).at(1), descricao);
  await tocar(tester, find.byType(TextFormField).at(2));
  await tocar(tester, find.text('OK'));
  await tocar(tester, find.byType(DropdownButtonFormField<String>));
  await tocar(tester, find.text(prioridade).last);
}
