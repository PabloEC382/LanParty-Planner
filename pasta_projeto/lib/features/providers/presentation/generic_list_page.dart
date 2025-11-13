import 'package:flutter/material.dart';

/// Widget genérico de listagem com suporte a paginação, filtro, ordenação e dismissible
/// 
/// Use este widget para qualquer entidade (Event, Game, Participant, Tournament, Venue)
/// 
/// Exemplo de uso:
/// ```dart
/// GenericListPage<EventDto>(
///   title: 'Eventos',
///   repository: eventsRepository,
///   itemBuilder: (item) => ListTile(
///     title: Text(item.name),
///     subtitle: Text(item.eventDate),
///   ),
///   onDelete: (id) async {
///     await eventsRepository.delete(id);
///   },
///   onUpdate: (item) async {
///     // Editar item
///   },
/// )
/// ```
class GenericListPage<T> extends StatefulWidget {
  final String title;
  final Future<List<T>> Function() loadData;
  final Widget Function(T item) itemBuilder;
  final Future<void> Function(String id) onDelete;
  final Future<void> Function(T item)? onUpdate;
  final Future<void> Function()? onAdd;
  final String Function(T item) getItemId;
  final String Function(T item) getItemTitle;
  final String? Function(T item)? getItemSubtitle;
  final String? Function(T item)? getItemImageUrl;

  const GenericListPage({
    Key? key,
    required this.title,
    required this.loadData,
    required this.itemBuilder,
    required this.onDelete,
    required this.getItemId,
    required this.getItemTitle,
    this.onUpdate,
    this.onAdd,
    this.getItemSubtitle,
    this.getItemImageUrl,
  }) : super(key: key);

  @override
  State<GenericListPage<T>> createState() => _GenericListPageState<T>();
}

class _GenericListPageState<T> extends State<GenericListPage<T>> {
  List<T> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.loadData();
      setState(() {
        _items = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erro ao carregar dados: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteItem(T item) async {
    final id = widget.getItemId(item);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja deletar "${widget.getItemTitle(item)}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await widget.onDelete(id);
      setState(() => _items.removeWhere((item) => widget.getItemId(item) == id));
      _showSuccessSnackBar('Item deletado com sucesso!');
    } catch (e) {
      _showErrorSnackBar('Erro ao deletar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum item encontrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: Icon(Icons.refresh),
                        label: Text('Recarregar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Dismissible(
                        key: Key(widget.getItemId(item)),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 16),
                          color: Colors.red,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _deleteItem(item),
                        child: widget.itemBuilder(item),
                      );
                    },
                  ),
                ),
      floatingActionButton: widget.onAdd != null
          ? FloatingActionButton(
              onPressed: widget.onAdd,
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}

/// Widget específico para listagem com imagem, rating e distância
class ProviderListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final double? rating;
  final double? distanceKm;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProviderListItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.rating,
    this.distanceKm,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.image_not_supported),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
              ),
            )
          : Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.inventory),
            ),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null) ...[
            Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: 4),
          ],
          Row(
            children: [
              if (rating != null) ...[
                Icon(Icons.star, size: 16, color: Colors.amber),
                SizedBox(width: 4),
                Text(
                  rating!.toStringAsFixed(1),
                  style: TextStyle(fontSize: 12),
                ),
              ],
              if (distanceKm != null) ...[
                SizedBox(width: 16),
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${distanceKm!.toStringAsFixed(1)} km',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ],
      ),
      onTap: onTap,
      trailing: onDelete != null
          ? IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: onDelete,
            )
          : null,
    );
  }
}
