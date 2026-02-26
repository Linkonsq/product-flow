import 'dart:async';
import 'package:flutter/material.dart';

import '../models/carousel_item.dart';

const Duration _kAutoAdvanceDuration = Duration(seconds: 4);

class HeaderCarousel extends StatefulWidget {
  const HeaderCarousel({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onPageChanged,
    this.height = 200,
    this.autoAdvance = true,
  });

  final List<CarouselItem> items;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final double height;
  final bool autoAdvance;

  @override
  State<HeaderCarousel> createState() => _HeaderCarouselState();
}

class _HeaderCarouselState extends State<HeaderCarousel> {
  late PageController _pageController;
  Timer? _autoAdvanceTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentIndex);
    if (widget.autoAdvance && widget.items.length > 1) {
      _startAutoAdvance();
    }
  }

  @override
  void didUpdateWidget(HeaderCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _pageController.page?.round()) {
      _pageController.animateToPage(
        widget.currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(_kAutoAdvanceDuration, (_) {
      if (!mounted || widget.items.length <= 1) return;
      final current = _pageController.page?.round() ?? widget.currentIndex;
      final next = (current + 1) % widget.items.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Text('No images')),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: widget.onPageChanged,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return _CarouselSlide(
                  imageUrl: item.imageUrl,
                  caption: item.caption,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _PageIndicator(
            count: widget.items.length,
            currentIndex: widget.currentIndex,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _CarouselSlide extends StatelessWidget {
  const _CarouselSlide({required this.imageUrl, this.caption});

  final String imageUrl;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.broken_image_outlined, size: 48),
                ),
              ),
            ),
            if (caption != null && caption!.isNotEmpty)
              Positioned(
                left: 16,
                bottom: 16,
                child: Text(
                  caption!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentIndex == index
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
