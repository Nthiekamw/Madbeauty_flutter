import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../theme/app_colors.dart';

/// Aperçu vidéo réseau ou fichier local (galerie hub / fiche prestataire).
class NetworkVideoPreview extends StatefulWidget {
  const NetworkVideoPreview({
    super.key,
    this.url,
    this.localPath,
    this.autoPlay = false,
    this.muted = true,
    this.loop = true,
    this.fit = BoxFit.cover,
    this.showControls = false,
    this.placeholderIconSize = 36,
  }) : assert(url != null || localPath != null);

  final String? url;
  final String? localPath;
  final bool autoPlay;
  final bool muted;
  final bool loop;
  final BoxFit fit;
  final bool showControls;
  final double placeholderIconSize;

  @override
  State<NetworkVideoPreview> createState() => _NetworkVideoPreviewState();
}

class _NetworkVideoPreviewState extends State<NetworkVideoPreview> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant NetworkVideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.localPath != widget.localPath) {
      _disposeController();
      _ready = false;
      _failed = false;
      _initController();
    }
  }

  Future<void> _initController() async {
    final local = widget.localPath?.trim();
    final remote = widget.url?.trim();
    VideoPlayerController controller;
    if (local != null && local.isNotEmpty && File(local).existsSync()) {
      controller = VideoPlayerController.file(File(local));
    } else if (remote != null && remote.isNotEmpty) {
      controller = VideoPlayerController.networkUrl(Uri.parse(remote));
    } else {
      setState(() => _failed = true);
      return;
    }

    _controller = controller;
    try {
      await controller.initialize();
      await controller.setVolume(widget.muted ? 0 : 1);
      controller.setLooping(widget.loop);
      if (widget.autoPlay) {
        await controller.play();
      }
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null || !_ready) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return _VideoPlaceholder(iconSize: widget.placeholderIconSize);
    }

    final controller = _controller;
    if (!_ready || controller == null || !controller.value.isInitialized) {
      return _VideoPlaceholder(iconSize: widget.placeholderIconSize);
    }

    final video = LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite ? constraints.maxWidth : null;
        final maxH =
            constraints.maxHeight.isFinite ? constraints.maxHeight : null;
        return FittedBox(
          fit: widget.fit,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: maxW ?? controller.value.size.width,
            height: maxH ?? controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        );
      },
    );

    if (!widget.showControls) {
      return video;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        video,
        Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: _togglePlayback,
            child: AnimatedOpacity(
              opacity: controller.value.isPlaying ? 0 : 0.92,
              duration: const Duration(milliseconds: 180),
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      controller.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: AppColors.white,
                      size: widget.placeholderIconSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.72),
      child: Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          color: AppColors.white.withValues(alpha: 0.92),
          size: iconSize,
        ),
      ),
    );
  }
}
