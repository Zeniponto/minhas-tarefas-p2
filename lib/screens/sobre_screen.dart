import 'package:flutter/material.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Icon(
        Icons.checklist_rounded,
        size: 64,
        color: Theme.of(context).colorScheme.primary,
      ),
      const SizedBox(height: 24),
      Text('Minhas Tarefas', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 12),
      const Text(
        'Aplicativo para cadastrar, consultar e organizar tarefas pessoais.',
      ),
      const SizedBox(height: 20),
      const Text('Programação Mobile - P2'),
      const SizedBox(height: 8),
      const Text(
        'Desenvolvido em Flutter, com autenticação e armazenamento no Firebase.',
      ),
    ],
  );
}
