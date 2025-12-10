import 'package:flutter/material.dart';
import '../../domain/entities/venue.dart';

Future<Venue?> showVenueFormDialog(
  BuildContext context, {
  Venue? initial,
}) {
  return showDialog<Venue>(
    context: context,
    builder: (context) => _VenueFormDialog(initial: initial),
  );
}

class _VenueFormDialog extends StatefulWidget {
  final Venue? initial;

  const _VenueFormDialog({this.initial});

  @override
  State<_VenueFormDialog> createState() => _VenueFormDialogState();
}

class _VenueFormDialogState extends State<_VenueFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _capacityController;

  @override
  void initState() {
    super.initState();
    // Comentário: Converte valores da entidade para campos de texto
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _addressController = TextEditingController(text: widget.initial?.address ?? '');
    _cityController = TextEditingController(text: widget.initial?.city ?? '');
    _stateController = TextEditingController(text: widget.initial?.state ?? '');
    _capacityController = TextEditingController(text: widget.initial?.capacity.toString() ?? '100');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.isEmpty || _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final capacity = int.tryParse(_capacityController.text) ?? 100;

    // Comentário: Criamos a entidade de domínio, não o DTO
    // A conversão para DTO ocorre apenas na fronteira de persistência
    final venue = Venue(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      capacity: capacity,
      facilities: widget.initial?.facilities ?? {},
      rating: widget.initial?.rating ?? 0.0,
      totalReviews: widget.initial?.totalReviews ?? 0,
      createdAt: widget.initial?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(venue);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial != null ? 'Editar Local' : 'Novo Local'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Local *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Endereço',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Cidade *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacidade',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
