import 'package:flutter/material.dart';
import '../../domain/entities/game.dart';

Future<Game?> showGameFormDialog(
  BuildContext context, {
  Game? initial,
}) {
  return showDialog<Game>(
    context: context,
    builder: (context) => _GameFormDialog(initial: initial),
  );
}

class _GameFormDialog extends StatefulWidget {
  final Game? initial;

  const _GameFormDialog({this.initial});

  @override
  State<_GameFormDialog> createState() => _GameFormDialogState();
}

class _GameFormDialogState extends State<_GameFormDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _genreController;
  late TextEditingController _minPlayersController;
  late TextEditingController _maxPlayersController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    // Comentário: Convertem valores da entidade para campos de texto
    _titleController = TextEditingController(text: widget.initial?.title ?? '');
    _descriptionController = TextEditingController(text: widget.initial?.description ?? '');
    _genreController = TextEditingController(text: widget.initial?.genre ?? '');
    _minPlayersController = TextEditingController(text: widget.initial?.minPlayers.toString() ?? '1');
    _maxPlayersController = TextEditingController(text: widget.initial?.maxPlayers.toString() ?? '2');
    _imageUrlController = TextEditingController(text: widget.initial?.coverImageUri?.toString() ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _genreController.dispose();
    _minPlayersController.dispose();
    _maxPlayersController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.isEmpty || _genreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final minPlayers = int.tryParse(_minPlayersController.text) ?? 1;
    final maxPlayers = int.tryParse(_maxPlayersController.text) ?? 2;

    if (minPlayers > maxPlayers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mín. de jogadores não pode ser maior que máx.')),
      );
      return;
    }

    // Comentário: Criamos a entidade de domínio, não o DTO
    // A conversão para DTO ocorre apenas na fronteira de persistência
    final game = Game(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      coverImageUri: _imageUrlController.text.isEmpty ? null : Uri.tryParse(_imageUrlController.text),
      genre: _genreController.text,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
      platforms: widget.initial?.platforms ?? {},
      averageRating: widget.initial?.averageRating ?? 0.0,
      totalMatches: widget.initial?.totalMatches ?? 0,
      createdAt: widget.initial?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(game);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial != null ? 'Editar Jogo' : 'Novo Jogo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _genreController,
              decoration: const InputDecoration(
                labelText: 'Gênero *',
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPlayersController,
                    decoration: const InputDecoration(
                      labelText: 'Mín. Jogadores',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxPlayersController,
                    decoration: const InputDecoration(
                      labelText: 'Máx. Jogadores',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL da Imagem',
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
