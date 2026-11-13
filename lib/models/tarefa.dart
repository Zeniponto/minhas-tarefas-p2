class Tarefa {
  const Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.dataVencimento,
    required this.prioridade,
    required this.concluida,
  });

  static const prioridades = ['Baixa', 'Média', 'Alta'];

  final String? id;
  final String titulo;
  final String descricao;
  final DateTime dataVencimento;
  final String prioridade;
  final bool concluida;

  String get situacao => concluida ? 'Concluída' : 'Pendente';

  factory Tarefa.fromMap(String id, Map<Object?, Object?> dados) {
    return Tarefa(
      id: id,
      titulo: dados['titulo'] as String,
      descricao: dados['descricao'] as String,
      dataVencimento: DateTime.parse(dados['dataVencimento'] as String),
      prioridade: dados['prioridade'] as String,
      concluida: dados['concluida'] as bool,
    );
  }

  Map<String, Object> toMap() {
    final data = dataVencimento;
    return {
      'id': id!,
      'titulo': titulo,
      'descricao': descricao,
      'dataVencimento':
          '${data.year.toString().padLeft(4, '0')}-'
          '${data.month.toString().padLeft(2, '0')}-'
          '${data.day.toString().padLeft(2, '0')}',
      'prioridade': prioridade,
      'concluida': concluida,
    };
  }

  Tarefa copyWith({String? id, bool? concluida}) {
    return Tarefa(
      id: id ?? this.id,
      titulo: titulo,
      descricao: descricao,
      dataVencimento: dataVencimento,
      prioridade: prioridade,
      concluida: concluida ?? this.concluida,
    );
  }
}
