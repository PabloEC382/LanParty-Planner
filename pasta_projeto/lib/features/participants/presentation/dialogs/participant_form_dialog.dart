import 'package:flutter/material.dart';
import '../../domain/entities/participant.dart';

Future<Participant?> showParticipantFormDialog(
  BuildContext context, {
  Participant? initial,
}) {
  return showDialog<Participant>(
    context: context,
    builder: (context) => _ParticipantFormDialog(initial: initial),
  );
}

class _ParticipantFormDialog extends StatefulWidget {
  final Participant? initial;

  const _ParticipantFormDialog({this.initial});

  @override
  State<_ParticipantFormDialog> createState() => _ParticipantFormDialogState();
}

class _ParticipantFormDialogState extends State<_ParticipantFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _nicknameController;
  late TextEditingController _skillLevelController;
  late TextEditingController _avatarUrlController;
  late bool _isPremium;

  @override
  void initState() {
    super.initState();
    // Comentário: Converte valores da entidade para campos de texto
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _emailController = TextEditingController(text: widget.initial?.email ?? '');
    _nicknameController = TextEditingController(text: widget.initial?.nickname ?? '');
    _skillLevelController = TextEditingController(text: widget.initial?.skillLevel.toString() ?? '1');
    _avatarUrlController = TextEditingController(text: widget.initial?.avatarUri?.toString() ?? '');
    _isPremium = widget.initial?.isPremium ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nicknameController.dispose();
    _skillLevelController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _nicknameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final skillLevel = int.tryParse(_skillLevelController.text) ?? 1;

    if (skillLevel < 1 || skillLevel > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nível de habilidade deve estar entre 1 e 10')),
      );
      return;
    }

    // Comentário: Criamos a entidade de domínio, não o DTO
    // A conversão para DTO ocorre apenas na fronteira de persistência
    final participant = Participant(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      email: _emailController.text,
      nickname: _nicknameController.text,
      skillLevel: skillLevel,
      avatarUri: _avatarUrlController.text.isEmpty ? null : Uri.tryParse(_avatarUrlController.text),
      isPremium: _isPremium,
      preferredGames: widget.initial?.preferredGames ?? {},
      registeredAt: widget.initial?.registeredAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(participant);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial != null ? 'Editar Participante' : 'Novo Participante'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: 'Nickname *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _skillLevelController,
              decoration: const InputDecoration(
                labelText: 'Nível de Habilidade (1-10)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _avatarUrlController,
              decoration: const InputDecoration(
                labelText: 'URL do Avatar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Participante Premium'),
              value: _isPremium,
              onChanged: (value) {
                setState(() {
                  _isPremium = value ?? false;
                });
              },
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
