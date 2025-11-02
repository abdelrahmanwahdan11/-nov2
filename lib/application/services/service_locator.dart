import '../stores/app_store.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'catalog_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  late final CatalogRepository _catalogRepository;
  late final CatalogService catalogService;

  Future<void> init() async {
    await AppStore.instance.init();
    _catalogRepository = CatalogRepositoryImpl();
    catalogService = CatalogService(_catalogRepository);
    await catalogService.loadAll();
  }
}
