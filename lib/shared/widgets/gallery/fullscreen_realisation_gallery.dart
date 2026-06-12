import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../core/models/domain/catalog/realisation_media_type.dart';
import '../../theme/app_colors.dart';
import '../app/app_network_image.dart';
import '../prestataire/network_video_preview.dart';

/// Galerie plein écran mixte photos + vidéos de réalisations.
class FullscreenRealisationGallery extends StatefulWidget {
  const FullscreenRealisationGallery({
    super.key,
    required this.items,
    this.initialIndex = 0,
  });

  final List<PhotoRealisation> items;
  final int initialIndex;

  static Future<void> open(
    BuildContext context, {
    required List<PhotoRealisation> items,
    int initialIndex = 0,
  }) {
    if (items.isEmpty) return Future.value();
    final index = initialIndex.clamp(0, items.length - 1);
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => FullscreenRealisationGallery(
          items: items,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  State<FullscreenRealisationGallery> createState() =>
      _FullscreenRealisationGalleryState();
}

class _FullscreenRealisationGalleryState
    extends State<FullscreenRealisationGallery> {
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
    if (index < 0 || index >= widget.items.length) return null;
    final text = widget.items[index].caption?.trim();
    return text != null && text.isNotEmpty ? text : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = _captionAt(_pageIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.55),
        foregroundColor: AppColors.white,
        title: Text('${_pageIndex + 1} / ${widget.items.length}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _pageIndex = i),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return _FullscreenMediaPage(
                  key: ValueKey(item.id),
                  item: item,
                  active: index == _pageIndex,
                );
              },
            ),
          ),
          if (caption != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Text(
                caption,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.92),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FullscreenMediaPage extends StatelessWidget {
  const _FullscreenMediaPage({
    super.key,
    required this.item,
    required this.active,
  });

  final PhotoRealisation item;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (item.mediaType == RealisationMediaType.video) {
      return Center(
        child: active
            ? NetworkVideoPreview(
                url: item.url,
                autoPlay: true,
                muted: false,
                loop: true,
                fit: BoxFit.contain,
                showControls: true,
                placeholderIconSize: 48,
              )
            : const SizedBox.shrink(),
      );
    }

    return InteractiveViewer(
      minScale: 0.9,
      maxScale: 3,
      child: Center(
        child: AppNetworkImage(
          url: item.url,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
