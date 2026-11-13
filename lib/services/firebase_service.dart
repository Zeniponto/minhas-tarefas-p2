import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';

class FirebaseService {
  FirebaseService({FirebaseDatabase? database})
    : _database =
          database ??
          FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL:
                'https://minhas-tarefas-p2-default-rtdb.firebaseio.com',
          );

  final FirebaseDatabase _database;

  // Cada conta tem sua própria lista. As regras também verificam o UID.
  DatabaseReference _tarefas(Usuario usuario) {
    return _database.ref('tarefas/${usuario.uid}');
  }

  Stream<List<Tarefa>> observarTarefas(Usuario usuario) {
    return _tarefas(usuario).onValue.map((evento) {
      final tarefas = evento.snapshot.children.map((registro) {
        return Tarefa.fromMap(
          registro.key!,
          Map<Object?, Object?>.from(registro.value as Map),
        );
      }).toList();
      tarefas.sort((a, b) {
        final comparacao = a.dataVencimento.compareTo(b.dataVencimento);
        return comparacao != 0 ? comparacao : a.id!.compareTo(b.id!);
      });
      return tarefas;
    });
  }

  Stream<Tarefa?> observarTarefa(Usuario usuario, Tarefa tarefa) {
    return _tarefas(usuario).child(tarefa.id!).onValue.map((evento) {
      if (!evento.snapshot.exists) return null;
      return Tarefa.fromMap(
        evento.snapshot.key!,
        Map<Object?, Object?>.from(evento.snapshot.value as Map),
      );
    });
  }

  Future<void> salvar(Usuario usuario, Tarefa tarefa) async {
    final referencia = tarefa.id == null
        ? _tarefas(usuario).push()
        : _tarefas(usuario).child(tarefa.id!);
    final registro = tarefa.copyWith(id: referencia.key);
    await referencia.set(registro.toMap());
  }

  Future<void> alterarSituacao(Usuario usuario, Tarefa tarefa) {
    return _tarefas(
      usuario,
    ).child(tarefa.id!).update({'concluida': !tarefa.concluida});
  }

  Future<void> excluir(Usuario usuario, Tarefa tarefa) {
    return _tarefas(usuario).child(tarefa.id!).remove();
  }

  static String mensagemErro(Object erro) {
    if (erro is FirebaseException && erro.code == 'permission-denied') {
      return 'Você não tem permissão para acessar estas tarefas.';
    }
    return 'Não foi possível acessar as tarefas. Verifique sua conexão e tente novamente.';
  }
}
