import 'package:flutter/material.dart';

class CampoSenha extends StatefulWidget {
  const CampoSenha({
    super.key,
    required this.controller,
    this.cadastro = false,
    this.onSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final bool cadastro;
  final VoidCallback? onSubmitted;
  final bool enabled;

  @override
  State<CampoSenha> createState() => _CampoSenhaState();
}

class _CampoSenhaState extends State<CampoSenha> {
  bool _ocultar = true;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    enabled: widget.enabled,
    obscureText: _ocultar,
    autocorrect: false,
    enableSuggestions: false,
    autofillHints: [
      widget.cadastro ? AutofillHints.newPassword : AutofillHints.password,
    ],
    textInputAction: TextInputAction.done,
    onFieldSubmitted: (_) => widget.onSubmitted?.call(),
    decoration: InputDecoration(
      labelText: 'Senha',
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        tooltip: _ocultar ? 'Mostrar senha' : 'Ocultar senha',
        onPressed: () => setState(() => _ocultar = !_ocultar),
        icon: Icon(
          _ocultar ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
      ),
    ),
    validator: (valor) {
      if (valor == null || valor.isEmpty) return 'Informe a senha.';
      if (widget.cadastro && valor.length < 6) {
        return 'Use pelo menos 6 caracteres.';
      }
      return null;
    },
  );
}
