import 'package:flutter/material.dart';

import '../models/tarefa.dart';

IconData iconePrioridade(String prioridade) => switch (prioridade) {
  'Alta' => Icons.keyboard_double_arrow_up,
  'Média' => Icons.remove,
  _ => Icons.keyboard_double_arrow_down,
};

Color corPrioridade(BuildContext context, String prioridade) {
  final cores = Theme.of(context).colorScheme;
  return switch (prioridade) {
    'Alta' => cores.error,
    'Média' => cores.tertiary,
    _ => cores.primary,
  };
}

class TarefaCard extends StatelessWidget {
  const TarefaCard({
    super.key,
    required this.tarefa,
    required this.onAbrir,
    required this.onAlterarSituacao,
  });

  final Tarefa tarefa;
  final VoidCallback onAbrir;
  final ValueChanged<bool?>? onAlterarSituacao;

  @override
  Widget build(BuildContext context) {
    final data = MaterialLocalizations.of(
      context,
    ).formatMediumDate(tarefa.dataVencimento);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        leading: Checkbox(
          value: tarefa.concluida,
          onChanged: onAlterarSituacao,
          semanticLabel: tarefa.concluida
              ? 'Marcar como pendente'
              : 'Marcar como concluída',
        ),
        title: Text(
          tarefa.titulo,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vencimento: $data'),
              const SizedBox(height: 6),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  Icon(
                    iconePrioridade(tarefa.prioridade),
                    size: 20,
                    color: corPrioridade(context, tarefa.prioridade),
                  ),
                  Text('Prioridade ${tarefa.prioridade.toLowerCase()}'),
                  const Text('·'),
                  Text(tarefa.situacao),
                ],
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onAbrir,
      ),
    );
  }
}
