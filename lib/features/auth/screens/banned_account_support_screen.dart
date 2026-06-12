import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../bug_report/logic/bug_report_validators.dart';
import '../../../core/constants/app_strings.dart';
import '../../profile/providers/app_version_provider.dart';
import '../logic/account_ban_handler.dart';
import '../providers/auth_notifier.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/bug_report/bug_report_providers.dart';
import '../../../services/supabase/bug_report/bug_report_service.dart';
import '../../../services/supabase/storage/storage_providers.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_constrained_body.dart';
import '../../../shared/widgets/discovery/discovery_feature_header.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';

/// Formulaire support in-app après suspension de compte (signalement + chat).
class BannedAccountSupportScreen extends ConsumerStatefulWidget {
  const BannedAccountSupportScreen({
    super.key,
    this.banReason,
    this.banAppealFlow = false,
  });

  final String? banReason;
  final bool banAppealFlow;

  @override
  ConsumerState<BannedAccountSupportScreen> createState() =>
      _BannedAccountSupportScreenState();
}

class _BannedAccountSupportScreenState
    extends ConsumerState<BannedAccountSupportScreen> {
  final _descriptionController = TextEditingController();
  String? _descriptionError;
  bool _submitting = false;
  XFile? _screenshot;
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  String? _currentUserId() {
    return ref.read(authServiceProvider).currentSession?.user.id ??
        ref.read(authNotifierProvider).value?.id;
  }

  Future<void> _finishBanAppealFlowIfNeeded() async {
    if (!widget.banAppealFlow || !mounted) return;
    final container = ProviderScope.containerOf(context);
    await AccountBanHandler.finishBannedFlow(container);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final descErr = BugReportValidators.description(_descriptionController.text);
    setState(() => _descriptionError = descErr);
    if (descErr != null) return;

    if (_currentUserId() == null) {
      AppSnackBar.error(context, AuthStrings.bannedSupportSessionExpired);
      return;
    }

    final service = ref.read(bugReportServiceProvider);
    if (service == null) {
      AppSnackBar.error(context, DiscBug.submitErr);
      return;
    }

    final banReason = widget.banReason?.trim();
    final description = _descriptionController.text.trim();
    final fullDescription = banReason != null && banReason.isNotEmpty
        ? 'Motif indiqué par l’équipe : $banReason\n\n$description'
        : description;

    setState(() => _submitting = true);
    try {
      final version = await ref.read(appVersionProvider.future);
      final reportId = await service.submit(
        category: BugReportCategory.auth,
        title: AuthStrings.bannedSupportDefaultTitle,
        description: fullDescription,
        appVersion: version,
        platform: _platformLabel(),
        deviceInfo: _deviceInfoLabel(),
        currentScreen: GoRouterState.of(context).uri.toString(),
      );

      if (_screenshot != null) {
        final userId = _currentUserId();
        final storage = ref.read(storageServiceProvider);
        if (userId != null && storage != null) {
          final uploadFile = await StorageUploadFile.fromXFile(_screenshot!);
          StorageService.validateImageFile(uploadFile);
          final url = await storage.uploadBugReportScreenshot(
            userId: userId,
            reportId: reportId,
            file: uploadFile,
          );
          await service.setScreenshotUrl(
            reportId: reportId,
            screenshotUrl: url,
          );
        }
      }

      if (!mounted) return;
      AppSnackBar.success(context, AuthStrings.bannedSupportSuccess);
      context.pushBugReportChat(reportId);
    } catch (_) {
      if (mounted) AppSnackBar.error(context, DiscBug.submitErr);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _platformLabel() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return Platform.operatingSystem;
  }

  String? _deviceInfoLabel() {
    if (kIsWeb) return 'web';
    return '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
  }

  Future<void> _pickScreenshot() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    setState(() => _screenshot = file);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final banReason = widget.banReason?.trim();

    return PopScope(
      canPop: !_submitting,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && widget.banAppealFlow) {
          unawaited(_finishBanAppealFlowIfNeeded());
        }
      },
      child: DiscoveryBrandScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: _submitting
                  ? null
                  : () async {
                      final router = GoRouter.of(context);
                      if (router.canPop()) {
                        router.pop();
                      } else if (widget.banAppealFlow) {
                        await _finishBanAppealFlowIfNeeded();
                      }
                    },
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const DiscoveryFeatureHeader(
            title: AuthStrings.bannedSupportTitle,
            subtitle: AuthStrings.bannedSupportSubtitle,
            icon: Icons.support_agent_rounded,
          ),
          Expanded(
            child: DiscoveryConstrainedBody(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  if (banReason != null && banReason.isNotEmpty)
                    DiscoverySurfaceCard(
                      includeHorizontalMargin: false,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: theme.colorScheme.error,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AuthStrings.accountBannedReason(banReason),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (banReason != null && banReason.isNotEmpty)
                    const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    enabled: !_submitting,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: AuthStrings.bannedSupportDescriptionLabel,
                      hintText: AuthStrings.bannedSupportDescriptionHint,
                      errorText: _descriptionError,
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      if (_descriptionError != null) {
                        setState(() => _descriptionError = null);
                      }
                    },
                  ),
                  if (!kIsWeb) ...[
                    const SizedBox(height: 16),
                    Text(
                      DiscBug.fieldScreenshot,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_screenshot != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_screenshot!.path),
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _submitting
                            ? null
                            : () => setState(() => _screenshot = null),
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text(DiscBug.fieldScreenshotRemove),
                      ),
                    ] else
                      OutlinedButton.icon(
                        onPressed: _submitting ? null : _pickScreenshot,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text(DiscBug.fieldScreenshotAdd),
                      ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(AuthStrings.bannedSupportSubmit),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
