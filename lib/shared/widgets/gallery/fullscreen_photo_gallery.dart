import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_strings.dart';
import '../../theme/app_colors.dart';

/// Galerie plein écran avec défilement horizontal entre les photos.
class FullscreenPhotoGallery extends StatefulWidget {
  const FullscreenPhotoGallery({
    super.key,
    required this.urls,
    this.initialIndex = 0,
    this.captions,
  });

  final List<String> urls;
  final int initialIndex;
  final List<String?>? captions;

  static Future<void> open(
    BuildContext context, {
    required List<String> urls,
    int initialIndex = 0,
    List<String?>? captions,
  }) {
    final list = urls.map((u) => u.trim()).where((u) => u.isNotEmpty).toList();
    if (list.isEmpty) return Future.value();

    final index = initialIndex.clamp(0, list.length - 1);
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => FullscreenPhotoGallery(
          urls: list,
          initialIndex: index,
          captions: captions,
        ),
      ),
    );
  }

  @override
  State<FullscreenPhotoGallery> createState() => _FullscreenPhotoGalleryState();
}

class _FullscreenPhotoGalleryState extends State<FullscreenPhotoGallery> {
  late final PageController _pageController;
  late int _pageIndex;

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    super.dispose();
  }

  String? _captionAt(int index) {
    final captions = widget.captions;
    if (captions == null || index < 0 || index >= captions.length) {
      return null;
    }
    final text = captions[index]?.trim();
    return text != null && text.isNotEmpty ? text : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = _captionAt(_pageIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.scrimDark38,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          tooltip: DiscPrestaDetail.galleryCloseTooltip,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: widget.urls.length > 1
            ? Text(
                DiscPrestaDetail.galleryPhotoCounter(
                  _pageIndex + 1,
                  widget.urls.length,
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _pageIndex = index),
            itemCount: widget.urls.length,
            itemBuilder: (context, index) {
              return _GalleryPhotoPage(url: widget.urls[index]);
            },
          ),
          if (caption != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.paddingOf(context).bottom,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.scrimDark38,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GalleryPhotoPage extends StatelessWidget {
  const _GalleryPhotoPage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight;

    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(top: topInset, bottom: 24),
          child: Image.network(
            url,
            fit: BoxFit.contain,
            width: double.infinity,
            errorBuilder: (_, __, ___) => Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white70,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
