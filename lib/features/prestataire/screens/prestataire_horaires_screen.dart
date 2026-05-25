import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/availability/horaire_plage.dart';
import '../providers/current_prestataire_provider.dart';
import '../providers/disponibilite_provider.dart';
import '../../../services/supabase/disponibilite/disponibilite_service_providers.dart';
import '../../../shared/widgets/app_snack_bar.dart';

class PrestataireHorairesScreen extends ConsumerStatefulWidget {
  const PrestataireHorairesScreen({super.key});

  @override
  ConsumerState<PrestataireHorairesScreen> createState() =>
      _PrestataireHorairesScreenState();
}

class _JourHoraireState {
  _JourHoraireState({
    required this.jourSemaine,
    required this.enabled,
    required this.debut,
    required this.fin,
  });

  final int jourSemaine;
  bool enabled;
  TimeOfDay debut;
  TimeOfDay fin;
}

class _PrestataireHorairesScreenState
    extends ConsumerState<PrestataireHorairesScreen> {
  List<_JourHoraireState>? _jours;
  bool _hydrated = false;
  bool _saving = false;
  String? _error;

  List<_JourHoraireState> _defaultWeek() {
    return [
      for (final pg in DiscPrestaHoraires.joursSemainePg)
        _JourHoraireState(
          jourSemaine: pg,
          enabled: pg >= DateTime.monday && pg <= DateTime.friday,
          debut: const TimeOfDay(hour: 9, minute: 0),
          fin: const TimeOfDay(hour: 18, minute: 0),
        ),
    ];
  }

  void _applyHoraires(List<HorairePlage> horaires) {
    final byJour = {for (final h in horaires) h.jourSemaine: h};
    _jours = _defaultWeek().map((template) {
      final existing = byJour[template.jourSemaine];
      if (existing == null) {
        return _JourHoraireState(
          jourSemaine: template.jourSemaine,
          enabled: false,
          debut: template.debut,
          fin: template.fin,
        );
      }
      return _JourHoraireState(
        jourSemaine: template.jourSemaine,
        enabled: true,
        debut: existing.heureDebut,
        fin: existing.heureFin,
      );
    }).toList();
  }

  Future<void> _pickTime(_JourHoraireState jour, bool isStart) async {
    final initial = isStart ? jour.debut : jour.fin;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        jour.debut = picked;
      } else {
        jour.fin = picked;
      }
    });
  }

  Future<void> _save() async {
    final jours = _jours;
    if (jours == null) return;

    final service = ref.read(disponibiliteServiceProvider);
    final presta = await ref.read(currentPrestataireProvider.future);
    if (service == null || presta == null) {
      setState(() => _error = DiscPrestaHoraires.saveErr);
      return;
    }

    final plages = <HorairePlage>[];
    for (final jour in jours) {
      if (!jour.enabled) continue;
      final startMin = jour.debut.hour * 60 + jour.debut.minute;
      final endMin = jour.fin.hour * 60 + jour.fin.minute;
      if (endMin <= startMin) {
        setState(() => _error = DiscPrestaHoraires.invalidPlage);
        return;
      }
      plages.add(
        HorairePlage(
          jourSemaine: jour.jourSemaine,
          heureDebut: jour.debut,
          heureFin: jour.fin,
        ),
      );
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await service.setHoraires(presta.id, plages);
      invalidateDisponibiliteProviders(ref);
      if (mounted) {
        AppSnackBar.success(context, DiscPrestaHoraires.saveOk);
      }
    } catch (_) {
      if (mounted) setState(() => _error = DiscPrestaHoraires.saveErr);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final horairesAsync = ref.watch(prestataireHorairesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(DiscPrestaHoraires.title)),
      body: horairesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            DiscPrestaHoraires.loadErr,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
        data: (horaires) {
          if (!_hydrated) {
            _applyHoraires(horaires);
            _hydrated = true;
          }
          final jours = _jours!;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Text(
                DiscPrestaHoraires.intro,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              for (var i = 0; i < jours.length; i++) ...[
                _JourHoraireCard(
                  label: DiscPrestaHoraires.jours[i],
                  jour: jours[i],
                  onToggle: (v) => setState(() => jours[i].enabled = v),
                  onPickStart: () => _pickTime(jours[i], true),
                  onPickEnd: () => _pickTime(jours[i], false),
                ),
                const SizedBox(height: 10),
              ],
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(DiscPrestaHoraires.save),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _JourHoraireCard extends StatelessWidget {
  const _JourHoraireCard({
    required this.label,
    required this.jour,
    required this.onToggle,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final String label;
  final _JourHoraireState jour;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  String _format(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Switch(value: jour.enabled, onChanged: onToggle),
              ],
            ),
            if (jour.enabled) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onPickStart,
                      child: Text(
                        '${DiscPrestaHoraires.heureDebut} ${_format(jour.debut)}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onPickEnd,
                      child: Text(
                        '${DiscPrestaHoraires.heureFin} ${_format(jour.fin)}',
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              Text(
                DiscPrestaHoraires.dayOff,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
