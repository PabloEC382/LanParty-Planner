import 'package:flutter/material.dart';
import '../../domain/entities/tournament.dart';

Future<Tournament?> showTournamentFormDialog(
  BuildContext context, {
  Tournament? initial,
}) {
  return showDialog<Tournament>(
    context: context,
    builder: (context) => _TournamentFormDialog(initial: initial),
  );
}

class _TournamentFormDialog extends StatefulWidget {
  final Tournament? initial;

  const _TournamentFormDialog({this.initial});

  @override
  State<_TournamentFormDialog> createState() => _TournamentFormDialogState();
}

class _TournamentFormDialogState extends State<_TournamentFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _gameIdController;
  late TextEditingController _maxParticipantsController;
  late TextEditingController _prizePoolController;
  late TextEditingController _startDateController;
  late TournamentFormat _format;
  late TournamentStatus _status;

  @override
  void initState() {
    super.initState();
    // Comentário: Converte valores da entidade para campos de texto
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _descriptionController = TextEditingController(text: widget.initial?.description ?? '');
    _gameIdController = TextEditingController(text: widget.initial?.gameId ?? '');
    _maxParticipantsController = TextEditingController(text: widget.initial?.maxParticipants.toString() ?? '32');
    _prizePoolController = TextEditingController(text: widget.initial?.prizePool.toString() ?? '0.0');
    
    // Safer date parsing
    final startDateStr = widget.initial?.startDate != null 
      ? widget.initial!.startDate.toString().split(' ')[0]
      : DateTime.now().toString().split(' ')[0];
    
    _startDateController = TextEditingController(text: startDateStr);
    _format = widget.initial?.format ?? TournamentFormat.singleElimination;
    _status = widget.initial?.status ?? TournamentStatus.draft;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _gameIdController.dispose();
    _maxParticipantsController.dispose();
    _prizePoolController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.isEmpty || _gameIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final maxParticipants = int.tryParse(_maxParticipantsController.text) ?? 32;
    final prizePool = double.tryParse(_prizePoolController.text) ?? 0.0;

    // Comentário: Criamos a entidade de domínio, não o DTO
    // A conversão para DTO ocorre apenas na fronteira de persistência
    final tournament = Tournament(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      gameId: _gameIdController.text,
      format: _format,
      status: _status,
      maxParticipants: maxParticipants,
      currentParticipants: widget.initial?.currentParticipants ?? 0,
      prizePool: prizePool,
      startDate: DateTime.parse(_startDateController.text),
      endDate: widget.initial?.endDate,
      organizerIds: widget.initial?.organizerIds,
      rules: widget.initial?.rules,
      createdAt: widget.initial?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(tournament);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial != null ? 'Editar Torneio' : 'Novo Torneio'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Torneio *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _gameIdController,
              decoration: const InputDecoration(
                labelText: 'ID do Jogo *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TournamentFormat>(
              initialValue: _format,
              decoration: const InputDecoration(
                labelText: 'Formato',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: TournamentFormat.singleElimination, child: Text('Eliminação Simples')),
                DropdownMenuItem(value: TournamentFormat.doubleElimination, child: Text('Eliminação Dupla')),
                DropdownMenuItem(value: TournamentFormat.roundRobin, child: Text('Round Robin')),
                DropdownMenuItem(value: TournamentFormat.swiss, child: Text('Swiss')),
              ],
              onChanged: (value) {
                setState(() {
                  _format = value ?? TournamentFormat.singleElimination;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TournamentStatus>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: TournamentStatus.draft, child: Text('Rascunho')),
                DropdownMenuItem(value: TournamentStatus.registration, child: Text('Inscrição')),
                DropdownMenuItem(value: TournamentStatus.inProgress, child: Text('Em Andamento')),
                DropdownMenuItem(value: TournamentStatus.finished, child: Text('Finalizado')),
                DropdownMenuItem(value: TournamentStatus.cancelled, child: Text('Cancelado')),
              ],
              onChanged: (value) {
                setState(() {
                  _status = value ?? TournamentStatus.draft;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _maxParticipantsController,
                    decoration: const InputDecoration(
                      labelText: 'Máx. Participantes',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _prizePoolController,
                    decoration: const InputDecoration(
                      labelText: 'Prêmio',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _startDateController,
              decoration: const InputDecoration(
                labelText: 'Data Inicial (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.initial != null ? 'Salvar' : 'Adicionar'),
        ),
      ],
    );
  }
}
