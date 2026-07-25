import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../services/supabase/admin/admin_push_service.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../logic/admin_push_templates.dart';
import '../models/admin_user_summary.dart';
import '../providers/admin_push_provider.dart';
import '../providers/admin_users_provider.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminPushScreen extends ConsumerStatefulWidget {
  const AdminPushScreen({super.key});

  @override
  ConsumerState<AdminPushScreen> createState() => _AdminPushScreenState();
}

class _AdminPushScreenState extends ConsumerState<AdminPushScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _userSearchController = TextEditingController();
  final _prestataireIdController = TextEditingController();
  final _serviceIdController = TextEditingController();

  AdminPushAudience _audience = AdminPushAudience.all;
  AdminPushNavTarget _navTarget = AdminPushNavTarget.none;
  AdminUserSummary? _selectedUser;
  String? _activeTemplateId;
  String _userQuery = '';
  int? _recipientPreview;
  bool _previewLoading = false;
  bool _sending = false;
  bool _excludeBanned = true;
  Timer? _userDebounce;

  @override
  void initState() {
    super.initState();
    _userSearchController.addListener(_onUserSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshPreview());
  }

  @override
  void dispose() {
    _userDebounce?.cancel();
    _userSearchController.removeListener(_onUserSearchChanged);
    _titleController.dispose();
    _bodyController.dispose();
    _userSearchController.dispose();
    _prestataireIdController.dispose();
    _serviceIdController.dispose();
    super.dispose();
  }

  void _onUserSearchChanged() {
    _userDebounce?.cancel();
    _userDebounce = Timer(const Duration(milliseconds: 350), () {
      final next = _userSearchController.text.trim();
      if (next == _userQuery) return;
      setState(() {
        _userQuery = next;
        _selectedUser = null;
      });
    });
  }

  void _applyTemplate(AdminPushTemplate template) {
    setState(() {
      _activeTemplateId = template.id;
      _audience = template.audience;
      _navTarget = template.nav;
      _titleController.text = template.title;
      _bodyController.text = template.body;
      _selectedUser = null;
    });
    _refreshPreview();
  }

  Future<void> _refreshPreview() async {
    final service = ref.read(adminPushServiceProvider);
    if (service == null) return;
    if (_audience == AdminPushAudience.user && _selectedUser == null) {
      setState(() => _recipientPreview = null);
      return;
    }

    setState(() => _previewLoading = true);
    try {
      final preview = await service.previewRecipients(
        audience: _audience,
        userId: _selectedUser?.userId,
        excludeBanned: _excludeBanned,
      );
      if (!mounted) return;
      setState(() => _recipientPreview = preview.recipients);
    } catch (e) {
      if (!mounted) return;
      setState(() => _recipientPreview = null);
      AppSnackBar.show(context, message: '$e', kind: AppSnackKind.error);
    } finally {
      if (mounted) setState(() => _previewLoading = false);
    }
  }

  Future<void> _confirmAndSend() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      AppSnackBar.show(
        context,
        message: DiscProfile.adminPushFieldsRequired,
        kind: AppSnackKind.error,
      );
      return;
    }
    if (_audience == AdminPushAudience.user && _selectedUser == null) {
      AppSnackBar.show(
        context,
        message: DiscProfile.adminPushUserRequired,
        kind: AppSnackKind.error,
      );
      return;
    }
    if (_navTarget == AdminPushNavTarget.booking &&
        _prestataireIdController.text.trim().isEmpty) {
      AppSnackBar.show(
        context,
        message: DiscProfile.adminPushBookingNavRequired,
        kind: AppSnackKind.error,
      );
      return;
    }

    final count = _recipientPreview ?? 0;
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(DiscProfile.adminPushConfirmTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(DiscProfile.adminPushConfirmBody(count)),
              const SizedBox(height: 14),
              _ConfirmRow(
                label: DiscProfile.adminPushConfirmAudience,
                value: _audienceLabel(_audience),
              ),
              _ConfirmRow(
                label: DiscProfile.adminPushConfirmOpen,
                value: _navLabel(_navTarget),
              ),
              _ConfirmRow(
                label: DiscProfile.adminPushTitleLabel,
                value: title,
              ),
              const SizedBox(height: 8),
              Text(
                DiscProfile.adminPushConfirmMessage,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(body, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(DiscProfile.adminUsersBanCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(DiscProfile.adminPushSendAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final service = ref.read(adminPushServiceProvider);
    if (service == null) return;

    setState(() => _sending = true);
    try {
      final result = await service.sendPush(
        title: title,
        body: body,
        audience: _audience,
        userId: _selectedUser?.userId,
        excludeBanned: _excludeBanned,
        nav: _navTarget,
        prestataireId: _prestataireIdController.text.trim(),
        serviceId: _serviceIdController.text.trim(),
      );
      if (!mounted) return;
      final summary = DiscProfile.adminPushSentSummary(
        result.sent,
        result.failed,
        result.recipients,
      );
      if (result.credentialError != null) {
        AppSnackBar.error(context, result.credentialError!);
      } else if (result.failed > 0 && result.sent == 0) {
        final detail = result.staleTokensCleared > 0
            ? DiscProfile.adminPushTokenUnregisteredHint
            : result.firstError;
        AppSnackBar.warning(
          context,
          detail != null ? '$summary\n$detail' : summary,
        );
      } else {
        AppSnackBar.show(
          context,
          message: summary,
          kind: AppSnackKind.success,
        );
      }
      _titleController.clear();
      _bodyController.clear();
      setState(() => _activeTemplateId = null);
      await _refreshPreview();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, message: '$e', kind: AppSnackKind.error);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usersAsync = _audience == AdminPushAudience.user
        ? ref.watch(adminUsersSearchProvider(_userQuery))
        : null;

    return AdminScreenScaffold(
      title: DiscProfile.actionAdminPush,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const AdminScreenIntroBanner(
            icon: Icons.notifications_active_outlined,
            title: DiscProfile.adminPushIntroTitle,
            body: DiscProfile.adminPushIntroBody,
          ),
          const SizedBox(height: 16),
          Text(
            DiscProfile.adminPushTemplatesLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DiscProfile.adminPushTemplatesHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AdminPushTemplates.all.map((template) {
              final selected = _activeTemplateId == template.id;
              return ChoiceChip(
                avatar: Icon(
                  template.icon,
                  size: 18,
                  color: selected
                      ? AppColors.adminAccentMid
                      : theme.colorScheme.onSurfaceVariant,
                ),
                label: Text(template.label),
                selected: selected,
                onSelected: (_) => _applyTemplate(template),
                selectedColor: AppColors.adminBg12,
                side: BorderSide(
                  color: selected
                      ? AppColors.adminAccentMid
                      : AppColors.adminBorder30,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            DiscProfile.adminPushAudienceLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AdminPushAudience.values.map((audience) {
              final selected = _audience == audience;
              return ChoiceChip(
                label: Text(_audienceLabel(audience)),
                selected: selected,
                onSelected: (value) {
                  if (!value) return;
                  setState(() {
                    _audience = audience;
                    _selectedUser = null;
                    _activeTemplateId = null;
                  });
                  _refreshPreview();
                },
                selectedColor: AppColors.adminBg12,
                side: BorderSide(
                  color: selected
                      ? AppColors.adminAccentMid
                      : AppColors.adminBorder30,
                ),
              );
            }).toList(),
          ),
          if (_audience == AdminPushAudience.user) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _userSearchController,
              decoration: const InputDecoration(
                hintText: DiscProfile.adminUsersSearchHint,
                prefixIcon: Icon(Icons.search),
              ),
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 8),
            usersAsync?.when(
                  data: (users) {
                    if (users.isEmpty) {
                      return Text(
                        DiscProfile.adminUsersEmpty,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    }
                    return Column(
                      children: users.take(8).map((user) {
                        final selected = _selectedUser?.userId == user.userId;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: theme.colorScheme.surface,
                            borderRadius: DiscoveryStyles.cardBorderRadius,
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: DiscoveryStyles.cardBorderRadius,
                                side: BorderSide(
                                  color: selected
                                      ? AppColors.adminAccentMid
                                      : AppColors.adminBorder30,
                                ),
                              ),
                              title: Text(user.displayName),
                              subtitle: Text(user.email),
                              trailing: selected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: AppColors.adminAccentMid,
                                    )
                                  : null,
                              onTap: () {
                                setState(() => _selectedUser = user);
                                _refreshPreview();
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const DiscoveryListSkeleton(
                    rowCount: 3,
                    rowHeight: 56,
                    padding: EdgeInsets.symmetric(vertical: 4),
                  ),
                  error: (e, _) => DiscoverySectionError(
                    message: DiscProfile.adminUsersSearchErr,
                    onRetry: () => ref.invalidate(
                      adminUsersSearchProvider(_userQuery),
                    ),
                  ),
                ) ??
                const SizedBox.shrink(),
          ],
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(DiscProfile.adminPushExcludeBannedLabel),
            subtitle: Text(
              DiscProfile.adminPushExcludeBannedHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            value: _excludeBanned,
            onChanged: (value) {
              setState(() => _excludeBanned = value);
              _refreshPreview();
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<AdminPushNavTarget>(
            // ignore: deprecated_member_use
            value: _navTarget,
            decoration: const InputDecoration(
              labelText: DiscProfile.adminPushNavLabel,
            ),
            items: AdminPushNavTarget.values
                .map(
                  (target) => DropdownMenuItem(
                    value: target,
                    child: Text(_navLabel(target)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _navTarget = value;
                _activeTemplateId = null;
              });
            },
          ),
          if (_navTarget == AdminPushNavTarget.booking) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _prestataireIdController,
              decoration: const InputDecoration(
                labelText: DiscProfile.adminPushPrestataireIdLabel,
                hintText: DiscProfile.adminPushPrestataireIdHint,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _serviceIdController,
              decoration: const InputDecoration(
                labelText: DiscProfile.adminPushServiceIdLabel,
                hintText: DiscProfile.adminPushServiceIdHint,
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: DiscProfile.adminPushTitleLabel,
              hintText: DiscProfile.adminPushTitleHint,
            ),
            maxLength: 120,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) {
              if (_activeTemplateId != null) {
                setState(() => _activeTemplateId = null);
              }
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bodyController,
            decoration: const InputDecoration(
              labelText: DiscProfile.adminPushBodyLabel,
              hintText: DiscProfile.adminPushBodyHint,
              alignLabelWithHint: true,
            ),
            maxLength: 500,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) {
              if (_activeTemplateId != null) {
                setState(() => _activeTemplateId = null);
              }
            },
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: DiscoveryStyles.cardBorderRadius,
              color: AppColors.adminBg12,
              border: Border.all(color: AppColors.adminBorder30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    Icons.devices_outlined,
                    color: AppColors.adminAccentMid,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _previewLoading
                        ? Text(
                            DiscProfile.adminPushPreviewLoading,
                            style: theme.textTheme.bodyMedium,
                          )
                        : Text(
                            DiscProfile.adminPushPreviewCount(
                              _recipientPreview ?? 0,
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  TextButton(
                    onPressed: _previewLoading ? null : _refreshPreview,
                    child: Text(DiscProfile.adminPushRefreshPreview),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _sending ? null : _confirmAndSend,
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(DiscProfile.adminPushSendAction),
          ),
        ],
      ),
    );
  }

  String _audienceLabel(AdminPushAudience audience) {
    return switch (audience) {
      AdminPushAudience.all => DiscProfile.adminPushAudienceAll,
      AdminPushAudience.client => DiscProfile.adminPushAudienceClients,
      AdminPushAudience.prestataire => DiscProfile.adminPushAudiencePrestataires,
      AdminPushAudience.prestataireIncomplete =>
        DiscProfile.adminPushAudiencePrestataireIncomplete,
      AdminPushAudience.user => DiscProfile.adminPushAudienceUser,
    };
  }

  String _navLabel(AdminPushNavTarget target) {
    return switch (target) {
      AdminPushNavTarget.none => DiscProfile.adminPushNavNone,
      AdminPushNavTarget.clientHome => DiscProfile.adminPushNavClientHome,
      AdminPushNavTarget.clientReservations =>
        DiscProfile.adminPushNavClientReservations,
      AdminPushNavTarget.clientSearch => DiscProfile.adminPushNavClientSearch,
      AdminPushNavTarget.clientMessages => DiscProfile.adminPushNavClientMessages,
      AdminPushNavTarget.prestataireDashboard =>
        DiscProfile.adminPushNavPrestataireDashboard,
      AdminPushNavTarget.prestataireSubscription =>
        DiscProfile.adminPushNavPrestataireSubscription,
      AdminPushNavTarget.prestataireProfileEdit =>
        DiscProfile.adminPushNavPrestataireProfileEdit,
      AdminPushNavTarget.booking => DiscProfile.adminPushNavBooking,
    };
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
