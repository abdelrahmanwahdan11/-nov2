import 'dart:math' as math;

import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/catalog_repository.dart';

enum CatalogSortOption { popular, priceLowHigh, nearest, timeSoonest }

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
    CatalogSortOption sort = CatalogSortOption.popular,
  }) async {
    final items = await _ensureLoaded();
    final filtered = items.where((item) {
      final matchesType = type == null || item.type == type;
      final matchesLevel = level == null || level == 'all' || item.level == level;
      return matchesType && matchesLevel;
    }).toList();

    final sorted = _applySort(filtered, sort);

    final start = page * pageSize;
    if (start >= sorted.length) {
      return PaginatedResult(items: const [], hasMore: false);
    }
    final end = math.min(start + pageSize, sorted.length);
    final slice = sorted.sublist(start, end);
    final hasMore = end < sorted.length;
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
    CatalogSortOption sort = CatalogSortOption.popular,
  }) async {
    final items = await _ensureLoaded();
    if (query.trim().isEmpty) {
      final result = await loadPage(
        page: page,
        pageSize: pageSize,
        sort: sort,
      );
      return result;
    }

    final normalizedQuery = _normalize(query);
    final tokens = normalizedQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final scored = <CatalogItem>[];
    final Map<String, double> scores = {};

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
        scored.add(item);
        scores[item.id] = score;
      }
    }

    final sorted = _applySort(scored, sort, scores: scores);
    final start = page * pageSize;
    if (start >= sorted.length) {
      return const PaginatedResult(items: [], hasMore: false);
    }
    final end = math.min(start + pageSize, sorted.length);
    final slice = sorted.sublist(start, end);
    final hasMore = end < sorted.length;
    return PaginatedResult(items: slice, hasMore: hasMore);
  }

  String _normalize(String value) {
    final lower = value.toLowerCase();
    return lower
        .replaceAll(RegExp('[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  List<CatalogItem> _applySort(
    List<CatalogItem> items,
    CatalogSortOption sort, {
    Map<String, double>? scores,
  }) {
    final sorted = List<CatalogItem>.from(items);
    switch (sort) {
      case CatalogSortOption.popular:
        if (scores != null && scores.isNotEmpty) {
          sorted.sort((a, b) {
            final scoreB = scores[b.id] ?? 0;
            final scoreA = scores[a.id] ?? 0;
            final cmp = scoreB.compareTo(scoreA);
            if (cmp != 0) {
              return cmp;
            }
            return a.title.compareTo(b.title);
          });
        }
        break;
      case CatalogSortOption.priceLowHigh:
        sorted.sort((a, b) {
          final priceA = _priceValue(a);
          final priceB = _priceValue(b);
          final cmp = priceA.compareTo(priceB);
          if (cmp != 0) {
            return cmp;
          }
          return (scores?[b.id] ?? 0).compareTo(scores?[a.id] ?? 0);
        });
        break;
      case CatalogSortOption.nearest:
        sorted.sort((a, b) {
          final distanceA = _distanceForItem(a);
          final distanceB = _distanceForItem(b);
          final cmp = distanceA.compareTo(distanceB);
          if (cmp != 0) {
            return cmp;
          }
          return (scores?[b.id] ?? 0).compareTo(scores?[a.id] ?? 0);
        });
        break;
      case CatalogSortOption.timeSoonest:
        sorted.sort((a, b) {
          final timeA = _timeToMinutes(a.time);
          final timeB = _timeToMinutes(b.time);
          final cmp = timeA.compareTo(timeB);
          if (cmp != 0) {
            return cmp;
          }
          return (scores?[b.id] ?? 0).compareTo(scores?[a.id] ?? 0);
        });
        break;
    }
    return sorted;
  }

  double _priceValue(CatalogItem item) {
    final price = item.pricePerHour ?? item.fee;
    if (price == null) {
      return double.infinity;
    }
    return price;
  }

  double _distanceForItem(CatalogItem item) {
    if (item.distanceKm != null) {
      return item.distanceKm!;
    }
    if (item.lat == null || item.lon == null) {
      return double.infinity;
    }
    const baseLat = 31.95;
    const baseLon = 35.20;
    final dLat = _degToRad(item.lat! - baseLat);
    final dLon = _degToRad(item.lon! - baseLon);
    final originLat = _degToRad(baseLat);
    final itemLat = _degToRad(item.lat!);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(originLat) * math.cos(itemLat) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    const earthRadiusKm = 6371;
    return earthRadiusKm * c;
  }

  int _timeToMinutes(String? value) {
    if (value == null || value.isEmpty) {
      return 24 * 60;
    }
    final parts = value.split(':');
    if (parts.length < 2) {
      return 24 * 60;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return 24 * 60;
    }
    return hour * 60 + minute;
  }

  double _degToRad(double value) => value * math.pi / 180;
}
