import 'package:flutter/material.dart';

class TelaAutenticacao extends StatelessWidget {
  const TelaAutenticacao({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.formulario,
    this.voltar = false,
  });

  final String titulo;
  final String subtitulo;
  final Widget formulario;
  final bool voltar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: voltar ? AppBar() : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tema.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.checklist_rounded,
                        size: 40,
                        color: tema.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(titulo, style: tema.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(subtitulo, style: tema.textTheme.bodyLarge),
                  const SizedBox(height: 32),
                  formulario,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
