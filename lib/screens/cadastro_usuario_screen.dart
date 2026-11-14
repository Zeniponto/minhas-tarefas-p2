import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/campo_senha.dart';
import '../widgets/mensagem.dart';
import '../widgets/tela_autenticacao.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key, required this.auth});
  final AuthService auth;

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _salvando = false;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_salvando || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _salvando = true);
    try {
      await widget.auth.cadastrar(_nome.text, _email.text, _senha.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (erro) {
      if (mounted) mostrarMensagem(context, AuthService.mensagemErro(erro));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_salvando,
    child: TelaAutenticacao(
      titulo: 'Criar conta',
      subtitulo: 'Informe seus dados para começar.',
      voltar: true,
      formulario: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nome,
              enabled: !_salvando,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (valor) => valor == null || valor.trim().isEmpty
                  ? 'Informe seu nome.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              enabled: !_salvando,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: validarEmail,
            ),
            const SizedBox(height: 16),
            CampoSenha(
              controller: _senha,
              cadastro: true,
              enabled: !_salvando,
              onSubmitted: _salvar,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _salvando ? null : _salvar,
              child: Text(_salvando ? 'Cadastrando...' : 'Cadastrar'),
            ),
          ],
        ),
      ),
    ),
  );
}
