import 'package:flutter/material.dart';

import '../models/usuario.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({
    super.key,
    required this.usuario,
    required this.paginaAtual,
    required this.onSelecionar,
    required this.onSair,
  });

  final Usuario usuario;
  final int paginaAtual;
  final ValueChanged<int> onSelecionar;
  final VoidCallback? onSair;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    const titulos = [
      'Início',
      'Minhas tarefas',
      'Configurações',
      'Sobre o aplicativo',
    ];
    const icones = [
      Icons.home_outlined,
      Icons.checklist_rounded,
      Icons.settings_outlined,
      Icons.info_outline,
    ];
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: cores.primaryContainer),
            accountName: Text(
              usuario.nome,
              style: TextStyle(color: cores.onPrimaryContainer),
            ),
            accountEmail: Text(
              usuario.email,
              style: TextStyle(color: cores.onPrimaryContainer),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: cores.primary,
              child: Icon(
                Icons.person_outline,
                color: cores.onPrimary,
                size: 36,
              ),
            ),
          ),
          for (var i = 0; i < titulos.length; i++)
            ListTile(
              leading: Icon(icones[i]),
              title: Text(titulos[i]),
              selected: paginaAtual == i,
              onTap: () {
                Navigator.of(context).pop();
                onSelecionar(i);
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: onSair == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    onSair!();
                  },
          ),
        ],
      ),
    );
  }
}
