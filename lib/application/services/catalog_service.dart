import 'dart:math' as math;

import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/catalog_repository.dart';

class PaginatedResult<T> {
  const PaginatedResult({required this.items, required this.hasMore});

  final List<T> items;
  final bool hasMore;
}

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

  Future<PaginatedResult<CatalogItem>> loadPage({
    required int page,
    required int pageSize,
    CatalogType? type,
    String? level,
  }) async {
    final items = await _ensureLoaded();
    final filtered = items.where((item) {
      final matchesType = type == null || item.type == type;
      final matchesLevel = level == null || level == 'all' || item.level == level;
      return matchesType && matchesLevel;
    }).toList();

    final start = page * pageSize;
    if (start >= filtered.length) {
      return PaginatedResult(items: const [], hasMore: false);
    }
    final end = math.min(start + pageSize, filtered.length);
    final slice = filtered.sublist(start, end);
    final hasMore = end < filtered.length;
    return PaginatedResult(items: slice, hasMore: hasMore);
  }

  Future<CatalogItem?> findById(String id) {
    return _repository.findById(id);
  }

  Future<List<CatalogItem>> getByType(CatalogType type) async {
    final items = await _ensureLoaded();
    return items.where((element) => element.type == type).toList();
  }

  Future<PaginatedResult<CatalogItem>> searchPaged(
    String query, {
    required int page,
    required int pageSize,
  }) async {
    final items = await _ensureLoaded();
    if (query.trim().isEmpty) {
      final result = await loadPage(page: page, pageSize: pageSize);
      return result;
    }

    final normalizedQuery = _normalize(query);
    final tokens = normalizedQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final scored = <(_Score, CatalogItem)>[];

    for (final item in items) {
      final title = _normalize(item.title);
      final city = _normalize(item.city ?? '');
      final sport = _normalize(item.sport ?? '');

      double score = 0;
      for (final token in tokens) {
        if (token.isEmpty) continue;
        if (title.contains(token)) {
          score += 3;
        }
        if (sport.contains(token)) {
          score += 2;
        }
        if (city.contains(token)) {
          score += 1;
        }
      }

      if (score > 0) {
        scored.add((_Score(score), item));
      }
    }

    scored.sort((a, b) => b.$1.value.compareTo(a.$1.value));
    final start = page * pageSize;
    if (start >= scored.length) {
      return const PaginatedResult(items: [], hasMore: false);
    }
    final end = math.min(start + pageSize, scored.length);
    final slice = scored.sublist(start, end).map((pair) => pair.$2).toList();
    final hasMore = end < scored.length;
    return PaginatedResult(items: slice, hasMore: hasMore);
  }

  String _normalize(String value) {
    final lower = value.toLowerCase();
    return lower
        .replaceAll(RegExp('[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }
}

class _Score {
  const _Score(this.value);
  final double value;
}
