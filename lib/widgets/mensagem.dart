import 'package:flutter/material.dart';

void mostrarMensagem(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));
}

String? validarEmail(String? valor) {
  if (valor == null || valor.trim().isEmpty) return 'Informe o e-mail.';
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(valor.trim())) {
    return 'Informe um e-mail válido.';
  }
  return null;
}
