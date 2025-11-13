import 'package:flutter/material.dart';
import '../../infrastructure/dtos/event_dto.dart';

Future<EventDto?> showEventFormDialog(
  BuildContext context, {
  EventDto? initial,
}) {
  return showDialog<EventDto>(
    context: context,
    builder: (context) => _EventFormDialog(initial: initial),
  );
}

class _EventFormDialog extends StatefulWidget {
  final EventDto? initial;

  const _EventFormDialog({this.initial});

  @override
  State<_EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<_EventFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _checklistController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _dateController = TextEditingController(
      text: widget.initial?.event_date ?? DateTime.now().toIso8601String().split('T')[0],
    );
    _checklistController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _checklistController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.isEmpty || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final dto = EventDto(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      event_date: _dateController.text,
      checklist: widget.initial?.checklist ?? <String, dynamic>{},
      attendees: widget.initial?.attendees ?? <String>[],
      updated_at: DateTime.now().toIso8601String(),
    );

    Navigator.of(context).pop(dto);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial != null ? 'Editar Evento' : 'Novo Evento'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Evento',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Data do Evento (YYYY-MM-DD)',
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
