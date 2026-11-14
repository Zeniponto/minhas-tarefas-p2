import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';
import '../services/firebase_service.dart';
import '../widgets/mensagem.dart';

class CadastroTarefaScreen extends StatefulWidget {
  const CadastroTarefaScreen({
    super.key,
    required this.usuario,
    required this.firebase,
    this.tarefa,
  });

  final Usuario usuario;
  final FirebaseService firebase;
  final Tarefa? tarefa;

  @override
  State<CadastroTarefaScreen> createState() => _CadastroTarefaScreenState();
}

class _CadastroTarefaScreenState extends State<CadastroTarefaScreen> {
  final _form = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descricao = TextEditingController();
  final _dataTexto = TextEditingController();
  DateTime? _data;
  String _prioridade = 'Baixa';
  bool _concluida = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final tarefa = widget.tarefa;
    if (tarefa != null) {
      _titulo.text = tarefa.titulo;
      _descricao.text = tarefa.descricao;
      _data = tarefa.dataVencimento;
      _prioridade = tarefa.prioridade;
      _concluida = tarefa.concluida;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_data != null) {
      _dataTexto.text = MaterialLocalizations.of(
        context,
      ).formatMediumDate(_data!);
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    _dataTexto.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
      helpText: 'Data de vencimento',
    );
    if (escolhida != null && mounted) {
      setState(() {
        _data = escolhida;
        _dataTexto.text = MaterialLocalizations.of(
          context,
        ).formatMediumDate(escolhida);
      });
    }
  }

  Future<void> _salvar() async {
    if (_salvando || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _salvando = true);
    final tarefa = Tarefa(
      id: widget.tarefa?.id,
      titulo: _titulo.text.trim(),
      descricao: _descricao.text.trim(),
      dataVencimento: _data!,
      prioridade: _prioridade,
      concluida: _concluida,
    );
    try {
      await widget.firebase.salvar(widget.usuario, tarefa);
      if (mounted) Navigator.of(context).pop(true);
    } catch (erro) {
      if (mounted) mostrarMensagem(context, FirebaseService.mensagemErro(erro));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  String? _obrigatorio(String? valor) =>
      valor == null || valor.trim().isEmpty ? 'Preencha este campo.' : null;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_salvando,
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.tarefa == null ? 'Nova tarefa' : 'Editar tarefa'),
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _titulo,
                enabled: !_salvando,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: _obrigatorio,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricao,
                enabled: !_salvando,
                textCapitalization: TextCapitalization.sentences,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: _obrigatorio,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dataTexto,
                readOnly: true,
                enabled: !_salvando,
                onTap: _selecionarData,
                decoration: const InputDecoration(
                  labelText: 'Data de vencimento',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                validator: (_) =>
                    _data == null ? 'Selecione a data de vencimento.' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _prioridade,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                items: Tarefa.prioridades
                    .map(
                      (prioridade) => DropdownMenuItem(
                        value: prioridade,
                        child: Text(prioridade),
                      ),
                    )
                    .toList(),
                onChanged: _salvando
                    ? null
                    : (valor) => setState(() => _prioridade = valor!),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: const Text('Concluída'),
                  subtitle: Text(
                    _concluida ? 'Situação: Concluída' : 'Situação: Pendente',
                  ),
                  value: _concluida,
                  onChanged: _salvando
                      ? null
                      : (valor) => setState(() => _concluida = valor),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: const Icon(Icons.save_outlined),
                label: Text(_salvando ? 'Salvando...' : 'Salvar tarefa'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
