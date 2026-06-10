import 'package:flutter/material.dart';

import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_avatar.dart';

/// Avatar client + nom + service (cartes agenda / dashboard / clients).
class PrestataireClientIdentityRow extends StatelessWidget {
  const PrestataireClientIdentityRow({
    super.key,
    required this.clientName,
    required this.serviceName,
    this.clientPrenom,
    this.clientNom,
    this.clientAvatarUrl,
    this.avatarRadius = 20,
    this.nameStyle,
    this.serviceStyle,
    this.spacing = 12,
    this.nameServiceGap = 2,
  });

  final String clientName;
  final String serviceName;
  final String? clientPrenom;
  final String? clientNom;
  final String? clientAvatarUrl;
  final double avatarRadius;
  final TextStyle? nameStyle;
  final TextStyle? serviceStyle;
  final double spacing;
  final double nameServiceGap;

  String get _displayName {
    final parts = <String>[
      if (clientPrenom?.trim().isNotEmpty == true) clientPrenom!.trim(),
      if (clientNom?.trim().isNotEmpty == true) clientNom!.trim(),
    ];
    if (parts.isNotEmpty) return parts.join(' ');
    return clientName;
  }

  bool get _hasSplitName =>
      clientPrenom?.trim().isNotEmpty == true &&
      clientNom?.trim().isNotEmpty == true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = _displayName;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppAvatar(
          imageUrl: clientAvatarUrl,
          displayName: displayName,
          radius: avatarRadius,
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_hasSplitName) ...[
                Text(
                  clientPrenom!.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: nameStyle ??
                      theme.textTheme.titleMedium?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  clientNom!.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (nameStyle ??
                          theme.textTheme.titleMedium?.copyWith(
                            fontFamily: AppFonts.display,
                            fontWeight: FontWeight.w800,
                          ))
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ] else
                Text(
                  displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: nameStyle ??
                      theme.textTheme.titleMedium?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              SizedBox(height: nameServiceGap),
              Text(
                serviceName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: serviceStyle ??
                    theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
