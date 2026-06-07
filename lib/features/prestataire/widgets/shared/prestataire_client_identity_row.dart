import 'package:flutter/material.dart';

import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_avatar.dart';

/// Avatar client + nom + service (cartes agenda / dashboard / clients).
class PrestataireClientIdentityRow extends StatelessWidget {
  const PrestataireClientIdentityRow({
    super.key,
    required this.clientName,
    required this.serviceName,
    this.clientAvatarUrl,
    this.avatarRadius = 20,
    this.nameStyle,
    this.serviceStyle,
    this.spacing = 12,
    this.nameServiceGap = 2,
  });

  final String clientName;
  final String serviceName;
  final String? clientAvatarUrl;
  final double avatarRadius;
  final TextStyle? nameStyle;
  final TextStyle? serviceStyle;
  final double spacing;
  final double nameServiceGap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppAvatar(
          imageUrl: clientAvatarUrl,
          displayName: clientName,
          radius: avatarRadius,
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clientName,
                maxLines: 1,
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
