import 'package:flutter/material.dart';

import '../../controllers/landing_controller.dart';
import '../../widgets/header_carousel.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  final LandingController _controller = LandingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return HeaderCarousel(
                  items: _controller.carouselItems,
                  currentIndex: _controller.currentCarouselIndex,
                  onPageChanged: (index) {
                    _controller.currentCarouselIndex = index;
                  },
                  height: 200,
                );
              },
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Welcome to Product Flow',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
