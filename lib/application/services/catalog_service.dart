import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/catalog_repository.dart';

class CatalogService {
  CatalogService(this._repository);

  final CatalogRepository _repository;
  List<CatalogItem>? _cache;

  Future<List<CatalogItem>> _ensureLoaded() async {
    _cache ??= await _repository.loadCatalog();
    return _cache!;
  }

  Future<List<CatalogItem>> loadAll() async {
    return _ensureLoaded();
  }

  Future<CatalogItem?> findById(String id) {
    return _repository.findById(id);
  }

  Future<List<CatalogItem>> getByType(CatalogType type) async {
    final items = await _ensureLoaded();
    return items.where((element) => element.type == type).toList();
  }

  Future<List<CatalogItem>> search(String query) async {
    final items = await _ensureLoaded();
    if (query.trim().isEmpty) {
      return items;
    }
    final normalized = query.toLowerCase();
    final scored = <(_Score, CatalogItem)>[];
    for (final item in items) {
      final title = item.title.toLowerCase();
      final city = (item.city ?? '').toLowerCase();
      double score = 0;
      if (title.contains(normalized)) {
        score += 3;
      }
      if (city.contains(normalized)) {
        score += 1;
      }
      if (score > 0) {
        scored.add((_Score(score), item));
      }
    }
    scored.sort((a, b) => b.$1.value.compareTo(a.$1.value));
    return scored.map((pair) => pair.$2).toList();
  }
}

class _Score {
  const _Score(this.value);
  final double value;
}
