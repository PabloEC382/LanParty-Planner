import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';
import '../../../core/theme.dart';

Future<Event?> showEventFormDialog(
  BuildContext context, {
  Event? initial,
}) {
  return showDialog<Event>(
    context: context,
    builder: (_) => _EventFormDialog(initial: initial),
  );
}

class _EventFormDialog extends StatefulWidget {
  final Event? initial;

  const _EventFormDialog({this.initial});

  @override
  State<_EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<_EventFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _venueIdController;
  late TextEditingController _stateController;

  @override
  void initState() {
    super.initState();
    // Comentário: Converte valores da entidade para campos de texto
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _descriptionController = TextEditingController(text: initial?.description ?? '');
    
    // Safer date parsing - handle null and parse correctly
    final startDateStr = initial?.startDate != null 
      ? initial!.startDate.toString().split(' ')[0]
      : '';
    final endDateStr = initial?.endDate != null 
      ? initial!.endDate.toString().split(' ')[0]
      : '';
    
    _startDateController = TextEditingController(text: startDateStr);
    _endDateController = TextEditingController(text: endDateStr);
    _startTimeController = TextEditingController(text: initial?.startTime ?? '');
    _endTimeController = TextEditingController(text: initial?.endTime ?? '');
    _venueIdController = TextEditingController(text: initial?.venueId ?? '');
    _stateController = TextEditingController(text: initial?.state ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _venueIdController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T')[0];
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  bool _validateForm() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome do evento é obrigatório')),
      );
      return false;
    }
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descrição é obrigatória')),
      );
      return false;
    }
    if (_startDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data de início é obrigatória')),
      );
      return false;
    }
    if (_endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data de fim é obrigatória')),
      );
      return false;
    }
    if (_startTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horário de início é obrigatório')),
      );
      return false;
    }
    if (_endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horário de fim é obrigatório')),
      );
      return false;
    }
    return true;
  }

  void _submit() {
    if (!_validateForm()) return;

    final id = widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    // Comentário: Criamos a entidade de domínio, não o DTO
    // A conversão para DTO ocorre apenas na fronteira de persistência
    final event = Event(
      id: id,
      name: _nameController.text,
      startDate: DateTime.parse(_startDateController.text),
      endDate: DateTime.parse(_endDateController.text),
      description: _descriptionController.text,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      venueId: _venueIdController.text.isEmpty ? null : _venueIdController.text,
      state: _stateController.text.isEmpty ? null : _stateController.text,
      createdAt: widget.initial?.createdAt ?? now,
      updatedAt: now,
    );

    Navigator.pop(context, event);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.initial == null ? 'Novo Evento' : 'Editar Evento',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFFBBF24),
                  labelText: 'Nome do Evento',
                  labelStyle: const TextStyle(color: Color(0xFF78350F)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: purple),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFBBF24)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFFBBF24),
                  labelText: 'Descrição',
                  labelStyle: const TextStyle(color: Color(0xFF78350F)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: purple),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFBBF24)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startDateController,
                      readOnly: true,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFFBBF24),
                        labelText: 'Data Início',
                        labelStyle: const TextStyle(color: Color(0xFF78350F)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: purple),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFBBF24)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today, color: Color(0xFFFBBF24)),
                          onPressed: () => _selectDate(_startDateController),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _endDateController,
                      readOnly: true,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFFBBF24),
                        labelText: 'Data Fim',
                        labelStyle: const TextStyle(color: Color(0xFF78350F)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: purple),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFBBF24)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today, color: Color(0xFFFBBF24)),
                          onPressed: () => _selectDate(_endDateController),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startTimeController,
                      readOnly: true,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFFBBF24),
                        labelText: 'Horário Início',
                        labelStyle: const TextStyle(color: Color(0xFF78350F)),
                        hintText: 'HH:mm',
                        hintStyle: const TextStyle(color: Colors.white38),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: purple),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFBBF24)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.schedule, color: Color(0xFFFBBF24)),
                          onPressed: () => _selectTime(_startTimeController),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _endTimeController,
                      readOnly: true,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFFBBF24),
                        labelText: 'Horário Fim',
                        labelStyle: const TextStyle(color: Color(0xFF78350F)),
                        hintText: 'HH:mm',
                        hintStyle: const TextStyle(color: Colors.white38),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: purple),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFBBF24)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.schedule, color: Color(0xFFFBBF24)),
                          onPressed: () => _selectTime(_endTimeController),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _venueIdController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFFBBF24),
                  labelText: 'ID do Local (opcional)',
                  labelStyle: const TextStyle(color: Color(0xFF78350F)),
                  hintText: 'Deixe em branco se não tiver local definido',
                  hintStyle: const TextStyle(color: Colors.white38),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: purple),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFBBF24)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _stateController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFFBBF24),
                  labelText: 'Estado (opcional)',
                  labelStyle: const TextStyle(color: Color(0xFF78350F)),
                  hintText: 'Ex: SP, RJ, MG...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: purple),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFBBF24)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                    ),
                    onPressed: _submit,
                    child: const Text(
                      'Salvar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}