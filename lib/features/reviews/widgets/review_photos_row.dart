import 'package:flutter/material.dart';

import '../../../shared/widgets/app/app_network_image.dart';

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
          return AppNetworkImage(
            url: list[index],
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(10),
          );
        },
      ),
    );
  }
}
