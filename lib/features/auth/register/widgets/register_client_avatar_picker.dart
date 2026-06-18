import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/default_avatar_urls.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_avatar.dart';
import '../../../../shared/widgets/app/app_network_image.dart';
import '../../widgets/auth_step_section.dart';
import '../logic/register_wizard_constants.dart';
import '../providers/register_wizard_form_controller.dart';

class RegisterClientAvatarPicker extends StatelessWidget {
  const RegisterClientAvatarPicker({
    super.key,
    required this.form,
    required this.formEnabled,
    required this.onPickPhoto,
  });

  final RegisterWizardFormController form;
  final bool formEnabled;
  final VoidCallback onPickPhoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = DiscoveryResponsive.of(context);
    final displayName = '${form.prenom.text.trim()} ${form.nom.text.trim()}'
        .trim();

    return AuthStepSection(
      compact: true,
      title: AuthStrings.registerSectionAvatar,
      subtitle: AuthStrings.registerSectionAvatarHint,
      icon: Icons.account_circle_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (r.useSideBySideFormRows)
            Row(
              children: [
                _AvatarPreview(
                  bytes: form.clientAvatarBytes,
                  imageUrl: form.clientDefaultAvatarUrl,
                  displayName: displayName,
                ),
                const SizedBox(width: 16),
                Expanded(child: _PickPhotoButton(enabled: formEnabled, onTap: onPickPhoto)),
              ],
            )
          else ...[
            Center(
              child: _AvatarPreview(
                bytes: form.clientAvatarBytes,
                imageUrl: form.clientDefaultAvatarUrl,
                displayName: displayName,
              ),
            ),
            const SizedBox(height: 12),
            _PickPhotoButton(enabled: formEnabled, onTap: onPickPhoto),
          ],
          const SizedBox(height: RegisterWizardConstants.sectionGap),
          Text(
            AuthStrings.registerDefaultAvatars,
            style: theme.textTheme.labelLarge?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: DefaultAvatarUrls.urls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final url = DefaultAvatarUrls.urls[index];
                final selected = form.clientDefaultAvatarUrl == url &&
                    form.clientAvatarBytes == null;
                return _DefaultAvatarChip(
                  imageUrl: url,
                  selected: selected,
                  onTap: formEnabled
                      ? () => form.selectClientDefaultAvatar(url)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({
    required this.bytes,
    required this.imageUrl,
    required this.displayName,
  });

  final Uint8List? bytes;
  final String? imageUrl;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    if (bytes != null) {
      return ClipOval(
        child: Image.memory(
          bytes!,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
        ),
      );
    }

    return AppAvatar(
      imageUrl: imageUrl,
      displayName: displayName.isEmpty ? '?' : displayName,
      radius: 36,
    );
  }
}

class _PickPhotoButton extends StatelessWidget {
  const _PickPhotoButton({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onTap : null,
      icon: const Icon(Icons.photo_library_outlined, size: 20),
      label: const Text(AuthStrings.registerAvatarPick),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

class _DefaultAvatarChip extends StatelessWidget {
  const _DefaultAvatarChip({
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  final String imageUrl;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 56,
          height: 56,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? primary
                  : theme.colorScheme.outline.withValues(alpha: 0.25),
              width: selected ? 2.5 : 1.2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: ClipOval(
            child: AppNetworkImage(
              url: imageUrl,
              fit: BoxFit.cover,
              error: ColoredBox(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.person_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
