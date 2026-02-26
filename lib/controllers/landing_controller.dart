import 'package:flutter/foundation.dart';

import '../models/carousel_item.dart';

class LandingController extends ChangeNotifier {
  LandingController() {
    _initCarouselItems();
  }

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
