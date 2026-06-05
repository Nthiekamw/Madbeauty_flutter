import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/auth_form_styles.dart';

/// Bloc repliable pour les champs non obligatoires (moins de scroll initial).
class RegisterOptionalPanel extends StatelessWidget {
  const RegisterOptionalPanel({
    super.key,
    required this.children,
    this.title = AuthStrings.registerSectionOptionalExpand,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.35 : 0.55,
      ),
      borderRadius: BorderRadius.circular(AuthFormStyles.fieldRadius),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: theme.colorScheme.onSurfaceVariant,
        children: children,
      ),
    );
  }
}

