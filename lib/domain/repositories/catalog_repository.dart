import '../entities/catalog_item.dart';

abstract class CatalogRepository {
  Future<List<CatalogItem>> loadCatalog();
  Future<CatalogItem?> findById(String id);
}
