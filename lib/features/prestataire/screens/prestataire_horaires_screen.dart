import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/availability/horaire_plage.dart';
import '../models/weekly_jour_horaire.dart';
import '../providers/disponibilite_provider.dart';
import '../providers/resolve_prestataire_id.dart';
import '../../../services/supabase/disponibilite/disponibilite_service_providers.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../widgets/profile/schedule/prestataire_indisponibilites_editor.dart';
import '../widgets/profile/schedule/prestataire_weekly_horaires_editor.dart';
import '../widgets/workspace/prestataire_brand_scaffold.dart';

class PrestataireHorairesScreen extends ConsumerStatefulWidget {
  const PrestataireHorairesScreen({super.key});

  @override
  ConsumerState<PrestataireHorairesScreen> createState() =>
      _PrestataireHorairesScreenState();
}

class _PrestataireHorairesScreenState
    extends ConsumerState<PrestataireHorairesScreen> {
  List<WeeklyJourHoraire>? _jours;
  bool _hydrated = false;
  bool _saving = false;
  String? _error;

  void _applyHoraires(List<HorairePlage> horaires) {
    _jours = WeeklyJourHoraire.fromPlages(horaires);
  }

  Future<void> _pickTime(int index, bool isStart) async {
    final jours = _jours;
    if (jours == null) return;
    final jour = jours[index];
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
    if (jours == null) {
      if (mounted) {
        AppSnackBar.error(context, DiscPrestaHoraires.loadErr);
      }
      return;
    }

    if (jours.hasAnyOpenDay && !jours.validatePlages()) {
      setState(() => _error = DiscPrestaHoraires.invalidPlage);
      if (mounted) {
        AppSnackBar.error(context, DiscPrestaHoraires.invalidPlage);
      }
      return;
    }

    final service = ref.read(disponibiliteServiceProvider);
    final prestaId = await resolveConnectedPrestataireId(ref.container);
    if (service == null || prestaId == null) {
      setState(() => _error = DiscPrestaHoraires.congesProfileErr);
      if (mounted) {
        AppSnackBar.error(context, DiscPrestaHoraires.congesProfileErr);
      }
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await service.setHoraires(prestaId, jours.toPlages());
      invalidateDisponibiliteProviders(ref);
      if (mounted) {
        AppSnackBar.success(context, DiscPrestaHoraires.saveOk);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = DiscPrestaHoraires.saveErr);
        AppSnackBar.error(context, DiscPrestaHoraires.saveErr);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final horairesAsync = ref.watch(prestataireHorairesProvider);
    final theme = Theme.of(context);

    return PrestataireBrandScaffold(
      appBar: prestataireBrandAppBar(
        context: context,
        title: const Text(DiscPrestaHoraires.title),
      ),
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _hydrated) return;
              setState(() {
                _applyHoraires(horaires);
                _hydrated = true;
              });
            });
            return const Center(child: CircularProgressIndicator());
          }
          final jours = _jours;
          if (jours == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              PrestataireWeeklyHorairesEditor(
                jours: jours,
                errorText: _error,
                showIntro: true,
                onToggleDay: (i, v) => setState(() => jours[i].enabled = v),
                onPickStart: (i) => _pickTime(i, true),
                onPickEnd: (i) => _pickTime(i, false),
                onCapaciteChanged: (i, capacite) => setState(
                  () => jours[i].capaciteSimultanee = capacite,
                ),
              ),
              const SizedBox(height: 28),
              const PrestataireIndisponibilitesEditor(),
              const SizedBox(height: 24),
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

