import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// FullScreenImageViewer
/// An interactive, high-resolution full-screen photo viewer and lightbox
/// supporting touch pinch-to-zoom, pan, swipe carousel, desktop chevron navigation,
/// keyboard shortcuts (Left/Right/Esc), and thumbnail strip navigation.
class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String? title;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.title,
  });

  /// Opens the full-screen photo lightbox modal
  static Future<void> show(
    BuildContext context, {
    required List<String> images,
    int initialIndex = 0,
    String? title,
  }) {
    if (images.isEmpty) return Future.value();
    final clampedIndex = initialIndex.clamp(0, images.length - 1);

    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.95),
        pageBuilder: (context, anim, secAnim) {
          return FullScreenImageViewer(
            images: images,
            initialIndex: clampedIndex,
            title: title,
          );
        },
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  final Map<int, TransformationController> _transformControllers = {};
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  TransformationController _getControllerForIndex(int index) {
    return _transformControllers.putIfAbsent(index, () => TransformationController());
  }

  void _resetZoom(int index) {
    if (_transformControllers.containsKey(index)) {
      _transformControllers[index]!.value = Matrix4.identity();
    }
  }

  void _handleDoubleTap(int index, TapDownDetails details) {
    final controller = _getControllerForIndex(index);
    if (controller.value != Matrix4.identity()) {
      controller.value = Matrix4.identity();
    } else {
      final position = details.localPosition;
      final m = Matrix4.identity();
      m.setEntry(0, 0, 2.5);
      m.setEntry(1, 1, 2.5);
      m.setEntry(0, 3, -position.dx * 1.5);
      m.setEntry(1, 3, -position.dy * 1.5);
      controller.value = m;
    }
    setState(() {});
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _resetZoom(_currentIndex);
      _pageController.animateToPage(
        _currentIndex - 1,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.images.length - 1) {
      _resetZoom(_currentIndex);
      _pageController.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _goToPrevious();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _goToNext();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _transformControllers.values) {
      c.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.images.length > 1;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: const Color(0xFF040711),
        body: SafeArea(
          child: Stack(
            children: [
              // 1. Photo PageView with InteractiveViewer
              PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.images.length,
                onPageChanged: (idx) {
                  _resetZoom(_currentIndex);
                  setState(() => _currentIndex = idx);
                },
                itemBuilder: (context, index) {
                  final url = widget.images[index];
                  final controller = _getControllerForIndex(index);
                  TapDownDetails? doubleTapDetails;

                  return GestureDetector(
                    onDoubleTapDown: (d) => doubleTapDetails = d,
                    onDoubleTap: () {
                      if (doubleTapDetails != null) {
                        _handleDoubleTap(index, doubleTapDetails!);
                      }
                    },
                    child: Center(
                      child: InteractiveViewer(
                        transformationController: controller,
                        minScale: 1.0,
                        maxScale: 4.5,
                        clipBehavior: Clip.none,
                        child: Image.network(
                          url,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            final expected = progress.expectedTotalBytes;
                            final loaded = progress.cumulativeBytesLoaded;
                            final value = expected != null && expected > 0
                                ? loaded / expected
                                : null;
                            return Center(
                              child: SizedBox(
                                width: 44,
                                height: 44,
                                child: CircularProgressIndicator(
                                  value: value,
                                  color: const Color(0xFFFFD700),
                                  strokeWidth: 3,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.broken_image_rounded,
                                    size: 64,
                                    color: Colors.redAccent,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Failed to load full photo',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () => setState(() {}),
                                    icon: const Icon(Icons.refresh, color: Color(0xFFFFD700), size: 18),
                                    label: const Text(
                                      'Retry (ફરી પ્રયાસ કરો)',
                                      style: TextStyle(color: Color(0xFFFFD700)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 2. Desktop Navigation Chevrons
              if (hasMultiple) ...[
                if (_currentIndex > 0)
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _goToPrevious,
                          hoverColor: const Color(0xFFFFD700).withValues(alpha: 0.2),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Color(0xFFFFD700),
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_currentIndex < widget.images.length - 1)
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _goToNext,
                          hoverColor: const Color(0xFFFFD700).withValues(alpha: 0.2),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Color(0xFFFFD700),
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],

              // 3. Top Header Bar
              Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    // Back / Close Button
                    Material(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title & Counter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.title != null && widget.title!.isNotEmpty)
                            Text(
                              widget.title!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            hasMultiple
                                ? 'Photo ${_currentIndex + 1} of ${widget.images.length} (ફોટો ${_currentIndex + 1} / ${widget.images.length})'
                                : 'Full Photo View (મોટો ફોટો)',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Reset Zoom Button
                    Material(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _resetZoom(_currentIndex),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.zoom_out_map_rounded, color: Color(0xFFFFD700), size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Reset',
                                style: TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Bottom Thumbnail Strip (if multiple photos)
              if (hasMultiple)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(widget.images.length, (idx) {
                            final isSelected = idx == _currentIndex;
                            return GestureDetector(
                              onTap: () {
                                _resetZoom(_currentIndex);
                                _pageController.animateToPage(
                                  idx,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: isSelected ? 48 : 40,
                                height: isSelected ? 48 : 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFFFD700)
                                        : Colors.white38,
                                    width: isSelected ? 2.5 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    widget.images[idx],
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Container(
                                      color: const Color(0xFF1E293B),
                                      child: const Icon(
                                        Icons.image_not_supported_rounded,
                                        size: 16,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
