import 'package:flutter/material.dart';

/// Galerie horizontale de photos d'avis.
class ReviewPhotosRow extends StatelessWidget {
  const ReviewPhotosRow({super.key, required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final list = urls.where((u) => u.trim().isNotEmpty).toList();
    if (list.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              list[index],
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          );
        },
      ),
    );
  }
}
