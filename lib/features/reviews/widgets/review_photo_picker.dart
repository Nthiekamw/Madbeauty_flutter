import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_colors.dart';

/// Sélection locale de photos pour un avis (max 3).
class ReviewPhotoPicker extends StatefulWidget {
  const ReviewPhotoPicker({
    super.key,
    this.initialUrls = const [],
    this.initialBytes = const [],
    required this.onChanged,
  });

  final List<String> initialUrls;
  final List<Uint8List> initialBytes;
  final void Function(List<Uint8List> bytes, List<String> existingUrls) onChanged;

  static const maxPhotos = 3;

  @override
  State<ReviewPhotoPicker> createState() => _ReviewPhotoPickerState();
}

class _ReviewPhotoPickerState extends State<ReviewPhotoPicker> {
  final _picker = ImagePicker();
  late List<String> _urls;
  final List<Uint8List> _bytes = [];

  @override
  void initState() {
    super.initState();
    _urls = List<String>.from(widget.initialUrls);
    _bytes.addAll(widget.initialBytes);
  }

  int get _total => _urls.length + _bytes.length;

  void _notify() => widget.onChanged(_bytes, _urls);

  Future<void> _pick() async {
    if (_total >= ReviewPhotoPicker.maxPhotos) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(DiscReview.photosMax)),
        );
      }
      return;
    }
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return;
    final data = await file.readAsBytes();
    setState(() => _bytes.add(data));
    _notify();
  }

  void _removeUrl(int index) {
    setState(() => _urls.removeAt(index));
    _notify();
  }

  void _removeBytes(int index) {
    setState(() => _bytes.removeAt(index));
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DiscReview.photosTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DiscReview.photosHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _urls.length; i++)
              _Thumb(
                child: Image.network(_urls[i], fit: BoxFit.cover),
                onRemove: () => _removeUrl(i),
              ),
            for (var i = 0; i < _bytes.length; i++)
              _Thumb(
                child: Image.memory(_bytes[i], fit: BoxFit.cover),
                onRemove: () => _removeBytes(i),
              ),
            if (_total < ReviewPhotoPicker.maxPhotos)
              InkWell(
                onTap: _pick,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DiscReview.photosAdd,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.child, required this.onRemove});

  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 88, height: 88, child: child),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: AppColors.scrimDark54,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 16, color: AppColors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

