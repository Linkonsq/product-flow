import 'package:flutter/foundation.dart';

import '../models/carousel_item.dart';
import '../models/product.dart';
import '../services/http_service.dart';

class LandingController extends ChangeNotifier {
  LandingController({HttpService? httpService})
      : _httpService = httpService ?? HttpService() {
    _initCarouselItems();
    loadProducts();
  }

  final HttpService _httpService;

  final List<CarouselItem> _carouselItems = [];
  List<CarouselItem> get carouselItems => List.unmodifiable(_carouselItems);

  int _currentCarouselIndex = 0;
  int get currentCarouselIndex => _currentCarouselIndex;
  set currentCarouselIndex(int value) {
    if (_currentCarouselIndex == value) return;
    _currentCarouselIndex = value;
    notifyListeners();
  }

  /// Tab labels
  static const List<String> landingTabLabels = [
    'Ramadan Sale',
    'Free Delivery',
    'New Arrivals',
  ];

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;
  set selectedTabIndex(int value) {
    if (value < 0 || value >= landingTabLabels.length) return;
    if (_selectedTabIndex == value) return;
    _selectedTabIndex = value;
    notifyListeners();
  }

  // Products (first tab)
  final List<Product> _products = [];
  List<Product> get products => List.unmodifiable(_products);

  bool _productsLoading = true;
  bool get productsLoading => _productsLoading;

  String? _productsError;
  String? get productsError => _productsError;

  Future<void> loadProducts() async {
    _productsLoading = true;
    _productsError = null;
    notifyListeners();
    try {
      final list = await _httpService.getProducts();
      _products
        ..clear()
        ..addAll(list);
      _productsError = null;
    } catch (e, stack) {
      _productsError = e.toString();
      debugPrintStack(stackTrace: stack);
    } finally {
      _productsLoading = false;
      notifyListeners();
    }
  }

  void _initCarouselItems() {
    // Product image URLs from Fake Store API (current format: _t.png)
    _carouselItems.addAll([
      const CarouselItem(
        imageUrl: 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_t.png',
        caption: 'Bags & Backpacks',
      ),
      const CarouselItem(
        imageUrl:
            'https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_t.png',
        caption: 'Mens Casual',
      ),
      const CarouselItem(
        imageUrl: 'https://fakestoreapi.com/img/71li-ujtlUL._AC_UX679_t.png',
        caption: 'Mens Jacket',
      ),
      const CarouselItem(
        imageUrl: 'https://fakestoreapi.com/img/71YXzeOuslL._AC_UY879_t.png',
        caption: 'Mens Slim Fit',
      ),
      const CarouselItem(
        imageUrl:
            'https://fakestoreapi.com/img/71pWzhdJNwL._AC_UL640_QL65_ML3_t.png',
        caption: 'Womens Jewelry',
      ),
    ]);
  }
}
