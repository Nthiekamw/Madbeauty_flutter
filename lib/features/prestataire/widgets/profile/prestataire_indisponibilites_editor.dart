import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/domain/availability/indisponibilite.dart';
import '../../../../services/supabase/disponibilite/disponibilite_service_providers.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../providers/current_prestataire_provider.dart';
import '../../providers/disponibilite_provider.dart';

class PrestataireIndisponibilitesEditor extends ConsumerStatefulWidget {
  const PrestataireIndisponibilitesEditor({super.key});

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
      initialDateRange: DateTimeRange(
        start: now,
        end: now,
      ),
      helpText: DiscPrestaHoraires.congesPickRange,
    );
    if (range == null || !mounted) return;

    final start = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    );
    final endExclusive = DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
    ).add(const Duration(days: 1));
    if (!endExclusive.isAfter(start)) {
      AppSnackBar.error(context, DiscPrestaHoraires.congesInvalidRange);
      return;
    }

    final service = ref.read(disponibiliteServiceProvider);
    final presta = await ref.read(currentPrestataireProvider.future);
    if (service == null || presta == null) {
      if (mounted) AppSnackBar.error(context, DiscPrestaHoraires.congesErr);
      return;
    }

    setState(() => _busy = true);
    try {
      await service.addIndisponibilite(presta.id, start, endExclusive);
      invalidateDisponibiliteProviders(ref);
      if (mounted) {
        AppSnackBar.success(context, DiscPrestaHoraires.congesAdded);
      }
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
    } catch (_) {
      if (mounted) AppSnackBar.error(context, DiscPrestaHoraires.congesErr);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemsAsync = ref.watch(prestataireIndisponibilitesProvider);

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
                  DiscoverySurfaceCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
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
                          tooltip: MaterialLocalizations.of(context)
                              .deleteButtonTooltip,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy ? null : _addPeriod,
          icon: const Icon(Icons.add_rounded),
          label: const Text(DiscPrestaHoraires.congesAdd),
        ),
      ],
    );
  }
}
