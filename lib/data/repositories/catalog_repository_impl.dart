import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl({this.assetPath = 'assets/seed/catalog.json'});

  final String assetPath;
  List<CatalogItem>? _cache;

  @override
  Future<List<CatalogItem>> loadCatalog() async {
    if (_cache != null) {
      return _cache!;
    }
    final raw = await rootBundle.loadString(assetPath);
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
    _cache = data
        .map((e) => CatalogItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return _cache!;
  }

  @override
  Future<CatalogItem?> findById(String id) async {
    final items = await loadCatalog();
    try {
      return items.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }
}
