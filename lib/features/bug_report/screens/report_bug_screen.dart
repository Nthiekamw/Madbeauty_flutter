import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_strings.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import '../../../features/profile/providers/app_version_provider.dart';
import '../../../services/supabase/bug_report/bug_report_providers.dart';
import '../../../services/supabase/bug_report/bug_report_service.dart';
import '../../../services/supabase/storage/storage_providers.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_constrained_body.dart';
import '../../../shared/widgets/discovery/discovery_feature_header.dart';
import '../logic/bug_report_validators.dart';

class ReportBugScreen extends ConsumerStatefulWidget {
  const ReportBugScreen({super.key});

  @override
  ConsumerState<ReportBugScreen> createState() => _ReportBugScreenState();
}

class _ReportBugScreenState extends ConsumerState<ReportBugScreen> {
  static const _categories = <(BugReportCategory, String)>[
    (BugReportCategory.auth, DiscBug.categoryAuth),
    (BugReportCategory.booking, DiscBug.categoryBooking),
    (BugReportCategory.payment, DiscBug.categoryPayment),
    (BugReportCategory.messaging, DiscBug.categoryMessaging),
    (BugReportCategory.profile, DiscBug.categoryProfile),
    (BugReportCategory.other, DiscBug.categoryOther),
  ];

  BugReportCategory _category = BugReportCategory.other;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stepsController = TextEditingController();
  String? _titleError;
  String? _descriptionError;
  bool _submitting = false;
  XFile? _screenshot;
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final titleErr = BugReportValidators.title(_titleController.text);
    final descErr = BugReportValidators.description(_descriptionController.text);
    setState(() {
      _titleError = titleErr;
      _descriptionError = descErr;
    });
    if (titleErr != null || descErr != null) return;

    final service = ref.read(bugReportServiceProvider);
    if (service == null) {
      AppSnackBar.error(context, DiscBug.submitErr);
      return;
    }

    final currentScreen = GoRouterState.of(context).uri.toString();
    setState(() => _submitting = true);
    try {
      final version = await ref.read(appVersionProvider.future);
      final platform = _platformLabel();
      final deviceInfo = _deviceInfoLabel();

      final reportId = await service.submit(
        category: _category,
        title: _titleController.text,
        description: _descriptionController.text,
        stepsToReproduce: _stepsController.text,
        appVersion: version,
        platform: platform,
        deviceInfo: deviceInfo,
        currentScreen: currentScreen,
      );

      if (_screenshot != null) {
        final userId = ref.read(authNotifierProvider).maybeWhen(
              data: (u) => u?.id,
              orElse: () => null,
            );
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
      ref.invalidate(myBugReportsProvider);
      AppSnackBar.success(context, DiscBug.submitSuccess);
      context.pop();
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

    return DiscoveryBrandScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const DiscoveryFeatureHeader(
            title: DiscBug.newReportTitle,
            subtitle: DiscBug.newReportSubtitle,
            icon: Icons.bug_report_outlined,
          ),
          Expanded(
            child: DiscoveryConstrainedBody(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  DropdownButtonFormField<BugReportCategory>(
                    value: _category,
                    decoration: const InputDecoration(
                      labelText: DiscBug.fieldCategory,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final (value, label) in _categories)
                        DropdownMenuItem(value: value, child: Text(label)),
                    ],
                    onChanged: _submitting
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _category = value);
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    enabled: !_submitting,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: DiscBug.fieldTitle,
                      hintText: DiscBug.fieldTitleHint,
                      errorText: _titleError,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      if (_titleError != null) {
                        setState(() => _titleError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    enabled: !_submitting,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: DiscBug.fieldDescription,
                      hintText: DiscBug.fieldDescriptionHint,
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
                  const SizedBox(height: 16),
                  if (!kIsWeb) ...[
                    Text(
                      DiscBug.fieldScreenshot,
                      style: theme.textTheme.labelLarge?.copyWith(
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _submitting
                              ? null
                              : () => setState(() => _screenshot = null),
                          icon: const Icon(Icons.close_rounded),
                          label: const Text(DiscBug.fieldScreenshotRemove),
                        ),
                      ),
                    ] else
                      OutlinedButton.icon(
                        onPressed: _submitting ? null : _pickScreenshot,
                        icon: const Icon(Icons.photo_outlined),
                        label: const Text(DiscBug.fieldScreenshotAdd),
                      ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _stepsController,
                    enabled: !_submitting,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: DiscBug.fieldSteps,
                      hintText: DiscBug.fieldStepsHint,
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(DiscBug.submit),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    DiscHelp.contactSupport,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
