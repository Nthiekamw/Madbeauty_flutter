import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Avatar rond : image réseau optionnelle, sinon initiales dérivées du nom ou de l'e-mail.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.radius = 28,
    this.displayName,
    this.email,
  });

  final String? imageUrl;
  final double radius;
  final String? displayName;
  final String? email;

  static String initialsFor({
    String? displayName,
    String? email,
  }) {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      if (parts.length >= 2 &&
          parts.first.isNotEmpty &&
          parts.last.isNotEmpty) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      final single = parts.first;
      if (single.length >= 2) {
        return single.substring(0, 2).toUpperCase();
      }
      return single[0].toUpperCase();
    }
    final mail = email?.trim();
    if (mail != null && mail.isNotEmpty) {
      return mail[0].toUpperCase();
    }
    return '?';
  }

  Widget _initialsAvatar(BuildContext context, ColorScheme colorScheme) {
    final initials = initialsFor(displayName: displayName, email: email);
    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimaryContainer,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final url = imageUrl?.trim();
    final size = radius * 2;

    if (url == null || url.isEmpty) {
      return _initialsAvatar(context, colorScheme);
    }

    final memCacheSize =
        (size * MediaQuery.devicePixelRatioOf(context)).round();

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          width: size,
          height: size,
          memCacheWidth: memCacheSize,
          memCacheHeight: memCacheSize,
          placeholder: (_, __) => ColoredBox(
            color: colorScheme.surfaceContainerHighest,
          ),
          errorWidget: (_, __, ___) =>
              _initialsAvatar(context, colorScheme),
        ),
      ),
    );
  }
}
