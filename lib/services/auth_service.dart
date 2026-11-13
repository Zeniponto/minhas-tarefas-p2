import 'package:firebase_auth/firebase_auth.dart';

import '../models/usuario.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<Usuario?> get usuario => _auth.userChanges().map((usuario) {
    if (usuario == null) return null;
    return Usuario(
      uid: usuario.uid,
      nome: usuario.displayName ?? '',
      email: usuario.email ?? '',
    );
  });

  Future<void> cadastrar(String nome, String email, String senha) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    try {
      await credencial.user!.updateDisplayName(nome.trim());
    } finally {
      // O cadastro termina no login, para o usuário entrar com a nova conta.
      await _auth.signOut();
    }
  }

  Future<void> entrar(String email, String senha) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }

  Future<void> sair() => _auth.signOut();

  static String mensagemErro(Object erro) {
    if (erro is FirebaseAuthException) {
      return switch (erro.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' => 'E-mail ou senha incorretos.',
        'email-already-in-use' => 'Este e-mail já está cadastrado.',
        'invalid-email' => 'Informe um e-mail válido.',
        'weak-password' => 'A senha deve ter pelo menos 6 caracteres.',
        'network-request-failed' => 'Verifique sua conexão com a internet.',
        'too-many-requests' => 'Muitas tentativas. Aguarde e tente novamente.',
        'user-disabled' => 'Esta conta está desativada.',
        _ => 'Não foi possível acessar a conta. Tente novamente.',
      };
    }
    return 'Não foi possível acessar a conta. Tente novamente.';
  }
}
