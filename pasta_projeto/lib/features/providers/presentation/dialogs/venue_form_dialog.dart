import 'package:flutter/material.dart';
import '../../infrastructure/dtos/venue_dto.dart';

Future<VenueDto?> showVenueFormDialog(
  BuildContext context, {
  VenueDto? initial,
}) {
  return showDialog<VenueDto>(
    context: context,
    builder: (context) => _VenueFormDialog(initial: initial),
  );
}

class _VenueFormDialog extends StatefulWidget {
  final VenueDto? initial;

  const _VenueFormDialog({this.initial});

  @override
  State<_VenueFormDialog> createState() => _VenueFormDialogState();
}

class _VenueFormDialogState extends State<_VenueFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _capacityController;
  late TextEditingController _pricePerHourController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late bool _isVerified;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _addressController = TextEditingController(text: widget.initial?.address ?? '');
    _cityController = TextEditingController(text: widget.initial?.city ?? '');
    _stateController = TextEditingController(text: widget.initial?.state ?? '');
    _zipCodeController = TextEditingController(text: widget.initial?.zip_code ?? '');
    _latitudeController = TextEditingController(text: widget.initial?.latitude.toString() ?? '0.0');
    _longitudeController = TextEditingController(text: widget.initial?.longitude.toString() ?? '0.0');
    _capacityController = TextEditingController(text: widget.initial?.capacity.toString() ?? '100');
    _pricePerHourController = TextEditingController(text: widget.initial?.price_per_hour.toString() ?? '0.0');
    _phoneController = TextEditingController(text: widget.initial?.phone_number ?? '');
    _websiteController = TextEditingController(text: widget.initial?.website_url ?? '');
    _isVerified = widget.initial?.is_verified ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _capacityController.dispose();
    _pricePerHourController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.isEmpty || _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final latitude = double.tryParse(_latitudeController.text) ?? 0.0;
    final longitude = double.tryParse(_longitudeController.text) ?? 0.0;
    final capacity = int.tryParse(_capacityController.text) ?? 100;
    final pricePerHour = double.tryParse(_pricePerHourController.text) ?? 0.0;

    final dto = VenueDto(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      zip_code: _zipCodeController.text,
      latitude: latitude,
      longitude: longitude,
      capacity: capacity,
      price_per_hour: pricePerHour,
      facilities: widget.initial?.facilities ?? [],
      rating: widget.initial?.rating ?? 0.0,
      total_reviews: widget.initial?.total_reviews ?? 0,
      is_verified: _isVerified,
      website_url: _websiteController.text.isEmpty ? null : _websiteController.text,
      phone_number: _phoneController.text.isEmpty ? null : _phoneController.text,
      created_at: widget.initial?.created_at ?? DateTime.now().toIso8601String(),
      updated_at: DateTime.now().toIso8601String(),
    );

    Navigator.of(context).pop(dto);
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
              controller: _zipCodeController,
              decoration: const InputDecoration(
                labelText: 'CEP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacidade',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _pricePerHourController,
                    decoration: const InputDecoration(
                      labelText: 'Preço/Hora',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Verificado'),
              value: _isVerified,
              onChanged: (value) {
                setState(() {
                  _isVerified = value ?? false;
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
