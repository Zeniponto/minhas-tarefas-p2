import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/campo_senha.dart';
import '../widgets/mensagem.dart';
import '../widgets/tela_autenticacao.dart';
import 'cadastro_usuario_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth});
  final AuthService auth;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _entrando = false;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_entrando || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _entrando = true);
    try {
      await widget.auth.entrar(_email.text, _senha.text);
    } catch (erro) {
      if (mounted) mostrarMensagem(context, AuthService.mensagemErro(erro));
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  Future<void> _cadastrar() async {
    final cadastrado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CadastroUsuarioScreen(auth: widget.auth),
      ),
    );
    if (cadastrado == true && mounted) {
      mostrarMensagem(context, 'Conta criada. Entre com seu e-mail e senha.');
    }
  }

  @override
  Widget build(BuildContext context) => TelaAutenticacao(
    titulo: 'Minhas Tarefas',
    subtitulo: 'Entre para organizar suas tarefas.',
    formulario: Form(
      key: _form,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _email,
              enabled: !_entrando,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: validarEmail,
            ),
            const SizedBox(height: 16),
            CampoSenha(
              controller: _senha,
              enabled: !_entrando,
              onSubmitted: _entrar,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _entrando ? null : _entrar,
              child: Text(_entrando ? 'Entrando...' : 'Entrar'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _entrando ? null : _cadastrar,
              child: const Text('Cadastrar novo usuário'),
            ),
          ],
        ),
      ),
    ),
  );
}
