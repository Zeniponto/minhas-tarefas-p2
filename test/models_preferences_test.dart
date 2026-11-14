import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tarefas_app/models/tarefa.dart';
import 'package:tarefas_app/services/auth_service.dart';
import 'package:tarefas_app/services/preferences_service.dart';
import 'package:tarefas_app/widgets/mensagem.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test(
    'tarefa preserva data sem horário, acentos e situação ao serializar',
    () {
      final tarefa = Tarefa(
        id: 'tarefa-1',
        titulo: 'Revisão da P2',
        descricao: 'Estudar autenticação.',
        dataVencimento: DateTime(2028, 2, 29),
        prioridade: 'Média',
        concluida: true,
      );
      final mapa = tarefa.toMap();
      expect(mapa['dataVencimento'], '2028-02-29');
      final recuperada = Tarefa.fromMap('tarefa-1', mapa);
      expect(recuperada.titulo, 'Revisão da P2');
      expect(recuperada.dataVencimento, DateTime(2028, 2, 29));
      expect(recuperada.prioridade, 'Média');
      expect(recuperada.situacao, 'Concluída');
    },
  );

  test('mudança de situação conserva a identificação e os dados da tarefa', () {
    final original = Tarefa(
      id: '0',
      titulo: 'Estudar',
      descricao: 'Revisar models',
      dataVencimento: DateTime(2026, 11, 20),
      prioridade: 'Alta',
      concluida: false,
    );
    final alterada = original.copyWith(concluida: true);
    expect(alterada.id, '0');
    expect(alterada.toMap()['titulo'], original.titulo);
    expect(alterada.toMap()['dataVencimento'], '2026-11-20');
    expect(original.concluida, isFalse);
    expect(alterada.concluida, isTrue);
  });

  test('tema claro é usado quando não existe preferência salva', () async {
    final preferences = PreferencesService();
    await preferences.carregar();
    expect(preferences.themeMode, ThemeMode.light);
    preferences.dispose();
  });

  test(
    'tema é recuperado por uma nova instância e pode voltar ao claro',
    () async {
      final primeiro = PreferencesService();
      await primeiro.alterarTema(true);
      final segundo = PreferencesService();
      await segundo.carregar();
      expect(segundo.themeMode, ThemeMode.dark);
      await segundo.alterarTema(false);
      await primeiro.carregar();
      expect(primeiro.themeMode, ThemeMode.light);
      final dados = await SharedPreferencesAsync().getAll();
      expect(dados, {'tema_escuro': false});
      primeiro.dispose();
      segundo.dispose();
    },
  );

  test('erros de autenticação recebem mensagens compreensíveis', () {
    expect(
      AuthService.mensagemErro(
        FirebaseAuthException(code: 'invalid-credential'),
      ),
      'E-mail ou senha incorretos.',
    );
    expect(
      AuthService.mensagemErro(
        FirebaseAuthException(code: 'email-already-in-use'),
      ),
      'Este e-mail já está cadastrado.',
    );
    expect(
      AuthService.mensagemErro(
        FirebaseAuthException(code: 'network-request-failed'),
      ),
      'Verifique sua conexão com a internet.',
    );
  });

  test(
    'validação de e-mail aceita endereço comum e rejeita campo inválido',
    () {
      expect(validarEmail(' aluno@example.com '), isNull);
      expect(validarEmail(''), 'Informe o e-mail.');
      expect(validarEmail('aluno@'), 'Informe um e-mail válido.');
      expect(
        validarEmail('nome com espaço@example.com'),
        'Informe um e-mail válido.',
      );
    },
  );
}
