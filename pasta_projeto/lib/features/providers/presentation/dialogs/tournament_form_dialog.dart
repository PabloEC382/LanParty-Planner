import 'package:flutter/material.dart';
import '../../infrastructure/dtos/tournament_dto.dart';

Future<TournamentDto?> showTournamentFormDialog(
  BuildContext context, {
  TournamentDto? initial,
}) {
  return showDialog<TournamentDto>(
    context: context,
    builder: (context) => _TournamentFormDialog(initial: initial),
  );
}

class _TournamentFormDialog extends StatefulWidget {
  final TournamentDto? initial;

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
  late String _format;
  late String _status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _descriptionController = TextEditingController(text: widget.initial?.description ?? '');
    _gameIdController = TextEditingController(text: widget.initial?.game_id ?? '');
    _maxParticipantsController = TextEditingController(text: widget.initial?.max_participants.toString() ?? '32');
    _prizePoolController = TextEditingController(text: widget.initial?.prize_pool.toString() ?? '0.0');
    _startDateController = TextEditingController(text: widget.initial?.start_date ?? DateTime.now().toIso8601String().split('T')[0]);
    _format = widget.initial?.format ?? 'single_elimination';
    _status = widget.initial?.status ?? 'draft';
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

    final dto = TournamentDto(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      game_id: _gameIdController.text,
      format: _format,
      status: _status,
      max_participants: maxParticipants,
      current_participants: widget.initial?.current_participants ?? 0,
      prize_pool: prizePool,
      start_date: _startDateController.text,
      end_date: widget.initial?.end_date,
      organizer_ids: widget.initial?.organizer_ids,
      rules: widget.initial?.rules,
      created_at: widget.initial?.created_at ?? DateTime.now().toIso8601String(),
      updated_at: DateTime.now().toIso8601String(),
    );

    Navigator.of(context).pop(dto);
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
            DropdownButtonFormField<String>(
              initialValue: _format,
              decoration: const InputDecoration(
                labelText: 'Formato',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'single_elimination', child: Text('Eliminação Simples')),
                DropdownMenuItem(value: 'double_elimination', child: Text('Eliminação Dupla')),
                DropdownMenuItem(value: 'round_robin', child: Text('Round Robin')),
                DropdownMenuItem(value: 'swiss', child: Text('Swiss')),
              ],
              onChanged: (value) {
                setState(() {
                  _format = value ?? 'single_elimination';
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'draft', child: Text('Rascunho')),
                DropdownMenuItem(value: 'registration', child: Text('Inscrição')),
                DropdownMenuItem(value: 'in_progress', child: Text('Em Andamento')),
                DropdownMenuItem(value: 'finished', child: Text('Finalizado')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelado')),
              ],
              onChanged: (value) {
                setState(() {
                  _status = value ?? 'draft';
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
