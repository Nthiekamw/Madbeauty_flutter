import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/errors/supabase_service_exception.dart';
import '../../../../../core/models/domain/availability/indisponibilite.dart';
import '../../../../../services/supabase/disponibilite/disponibilite_service_providers.dart';
import '../../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../providers/agenda/disponibilite_provider.dart';
import '../../../providers/resolve_prestataire_id.dart';
import '../hub/prestataire_hub_layout.dart';

class PrestataireIndisponibilitesEditor extends ConsumerStatefulWidget {
  const PrestataireIndisponibilitesEditor({
    super.key,
    this.embeddedInHub = false,
  });

  final bool embeddedInHub;

  @override
  ConsumerState<PrestataireIndisponibilitesEditor> createState() =>
      _PrestataireIndisponibilitesEditorState();
}

class _PrestataireIndisponibilitesEditorState
    extends ConsumerState<PrestataireIndisponibilitesEditor> {
  bool _busy = false;

  Future<void> _addPeriod() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: now, end: now),
      helpText: DiscPrestaHoraires.congesPickRange,
    );
    if (range == null || !mounted) return;

    final start = DateTime.utc(
      range.start.year,
      range.start.month,
      range.start.day,
    );
    final endExclusive = DateTime.utc(
      range.end.year,
      range.end.month,
      range.end.day,
    ).add(const Duration(days: 1));
    if (!endExclusive.isAfter(start)) {
      AppSnackBar.error(context, DiscPrestaHoraires.congesInvalidRange);
      return;
    }

    final service = ref.read(disponibiliteServiceProvider);
    final prestaId = await resolveConnectedPrestataireId(ref.container);
    if (service == null || prestaId == null) {
      if (mounted) AppSnackBar.error(context, DiscPrestaHoraires.congesProfileErr);
      return;
    }

    setState(() => _busy = true);
    try {
      await service.addIndisponibilite(prestaId, start, endExclusive);
      invalidateDisponibiliteProviders(ref);
      if (mounted) {
        AppSnackBar.success(context, DiscPrestaHoraires.congesAdded);
      }
    } on SupabaseServiceException catch (e) {
      if (!mounted) return;
      final profileIssue = e.code == '42501' ||
          e.code == '23503' ||
          e.code == '23502';
      AppSnackBar.error(
        context,
        profileIssue
            ? DiscPrestaHoraires.congesProfileErr
            : DiscPrestaHoraires.congesErr,
      );
    } catch (_) {
      if (mounted) AppSnackBar.error(context, DiscPrestaHoraires.congesErr);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(Indisponibilite item) async {
    final service = ref.read(disponibiliteServiceProvider);
    if (service == null) return;

    setState(() => _busy = true);
    try {
      await service.removeIndisponibilite(item.id);
      invalidateDisponibiliteProviders(ref);
      if (mounted) {
        AppSnackBar.success(context, DiscPrestaHoraires.congesRemoved);
      }
    } on SupabaseServiceException catch (e) {
      if (!mounted) return;
      final profileIssue = e.code == '42501' || e.code == '23503';
      AppSnackBar.error(
        context,
        profileIssue
            ? DiscPrestaHoraires.congesProfileErr
            : DiscPrestaHoraires.congesErr,
      );
    } catch (_) {
      if (mounted) AppSnackBar.error(context, DiscPrestaHoraires.congesErr);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _periodCard({
    required ThemeData theme,
    required Indisponibilite item,
  }) {
    final row = Row(
      children: [
        Icon(
          Icons.event_busy_outlined,
          color: theme.colorScheme.error.withValues(alpha: 0.85),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            DiscPrestaHoraires.congesRangeLabel(
              item.dateDebut,
              item.dateFin.subtract(const Duration(days: 1)),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: _busy ? null : () => _remove(item),
          icon: const Icon(Icons.delete_outline_rounded),
          tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
        ),
      ],
    );

    if (widget.embeddedInHub) {
      return PrestataireHubSurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: row,
      );
    }

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: row,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemsAsync = ref.watch(prestataireIndisponibilitesProvider);
    final hub = widget.embeddedInHub;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        itemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Text(
            DiscPrestaHoraires.congesErr,
            style: TextStyle(color: theme.colorScheme.error),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Text(
                DiscPrestaHoraires.congesEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            }
            return Column(
              children: [
                for (final item in items) ...[
                  _periodCard(theme: theme, item: item),
                  SizedBox(height: hub ? 8 : 8),
                ],
              ],
            );
          },
        ),
        SizedBox(height: hub ? 10 : 8),
        OutlinedButton.icon(
          onPressed: _busy ? null : _addPeriod,
          icon: const Icon(Icons.add_rounded),
          label: const Text(DiscPrestaHoraires.congesAdd),
          style: hub
              ? OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                )
              : null,
        ),
      ],
    );

    if (hub) {
      return PrestataireHubFormSection(
        icon: Icons.beach_access_outlined,
        title: DiscPrestaHoraires.congesTitle,
        subtitle: DiscPrestaHoraires.congesIntro,
        child: content,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DiscPrestaHoraires.congesTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          DiscPrestaHoraires.congesIntro,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }
}
