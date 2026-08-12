import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/supabase_service_exception.dart';
import '../../../core/models/domain/catalog/pack_offre.dart';
import '../../../core/models/domain/catalog/produit_boutique.dart';
import '../../../core/models/domain/catalog/service_beaute.dart';
import '../../../services/storage/storage_service.dart';
import '../../../services/supabase/prestataire/boutique/boutique_providers.dart';
import '../../../services/supabase/prestataire/boutique/pack_offre_service.dart';
import '../../../services/supabase/prestataire/services/service_beaute_providers.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/app/app_network_image.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_detail_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../providers/boutique/boutique_providers.dart';
import '../providers/profile/current_prestataire_provider.dart';
import '../widgets/workspace/prestataire_flow_scaffold.dart';

/// Gestion des packs / offres (espace prestataire).
class PrestatairePacksScreen extends ConsumerWidget {
  const PrestatairePacksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ownPacksOffreProvider);

    return PrestataireSubpageScaffold(
      title: DiscBoutique.packsTitle,
      subtitle: DiscBoutique.packsSubtitle,
      icon: Icons.local_offer_outlined,
      body: async.when(
        loading: () => const DiscoveryDetailSkeleton(),
        error: (_, __) => DiscoveryEmptyState(
          icon: Icons.error_outline_rounded,
          title: DiscBoutique.packsLoadErr,
          body: CoreStrings.errorUnexpected,
          actionLabel: DiscList.retry,
          onAction: () => ref.invalidate(ownPacksOffreProvider),
        ),
        data: (packs) {
          return Stack(
            children: [
              if (packs.isEmpty)
                const DiscoveryEmptyState(
                  icon: Icons.local_offer_outlined,
                  title: DiscBoutique.packsEmptyTitle,
                  body: DiscBoutique.packsEmptyBody,
                )
              else
                ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                  itemCount: packs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final pack = packs[index];
                    return _PackTile(
                      pack: pack,
                      onEdit: () => _openEditor(context, ref, pack: pack),
                      onToggle: () => _toggleActif(context, ref, pack),
                      onDelete: () => _delete(context, ref, pack),
                    );
                  },
                ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.extended(
                  onPressed: () => _openEditor(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(DiscBoutique.packsAdd),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleActif(
    BuildContext context,
    WidgetRef ref,
    PackOffre pack,
  ) async {
    final presta = await ref.read(currentPrestataireProvider.future);
    final service = ref.read(packOffreServiceProvider);
    if (presta == null || service == null) return;
    try {
      await service.setActif(
        prestataireId: presta.id,
        id: pack.id,
        isActif: !pack.isActif,
      );
      ref.invalidate(ownPacksOffreProvider);
      ref.invalidate(ownBoutiqueSummaryProvider);
      if (context.mounted) {
        AppSnackBar.success(
          context,
          pack.isActif
              ? DiscBoutique.packsDeactivated
              : DiscBoutique.packsActivated,
        );
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.error(context, DiscBoutique.packsSaveErr);
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    PackOffre pack,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(DiscBoutique.packsDeleteConfirmTitle),
        content: const Text(DiscBoutique.packsDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(CoreStrings.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(DiscBoutique.packsActionDelete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final presta = await ref.read(currentPrestataireProvider.future);
    final service = ref.read(packOffreServiceProvider);
    if (presta == null || service == null) return;
    try {
      await service.delete(prestataireId: presta.id, id: pack.id);
      ref.invalidate(ownPacksOffreProvider);
      ref.invalidate(ownBoutiqueSummaryProvider);
      if (context.mounted) {
        AppSnackBar.success(context, DiscBoutique.packsDeleted);
      }
    } catch (e) {
      if (!context.mounted) return;
      final code = e is SupabaseServiceException ? e.code : null;
      final raw = (e is SupabaseServiceException ? e.message : e.toString())
          .toLowerCase();
      final inUse = code == '23503' ||
          raw.contains('foreign key') ||
          raw.contains('violates foreign key') ||
          raw.contains('still referenced');
      AppSnackBar.error(
        context,
        inUse ? DiscBoutique.packsDeleteInUseErr : DiscBoutique.packsDeleteErr,
      );
    }
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    PackOffre? pack,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PackEditorSheet(pack: pack),
    );
    if (saved == true) {
      ref.invalidate(ownPacksOffreProvider);
      ref.invalidate(ownBoutiqueSummaryProvider);
    }
  }
}

enum _PackTileAction { edit, toggle, delete }

class _PackTile extends StatelessWidget {
  const _PackTile({
    required this.pack,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final PackOffre pack;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = pack.imageUrl?.trim();
    final badge = pack.isActif
        ? DiscBoutique.badgeActif
        : DiscBoutique.badgeBrouillon;

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: image != null && image.isNotEmpty
                  ? AppNetworkImage(url: image, fit: BoxFit.cover)
                  : ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.local_offer_outlined,
                        color: theme.colorScheme.outline,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.titre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      CurrencyFormat.eur(pack.prixPack, decimals: true),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: pack.isActif
                            ? theme.colorScheme.primary.withValues(alpha: 0.12)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (pack.isOffreDuJour)
                      Text(
                        DiscBoutique.badgeOffreDuJour,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<_PackTileAction>(
            tooltip: DiscBoutique.packsActionEdit,
            onSelected: (action) {
              switch (action) {
                case _PackTileAction.edit:
                  onEdit();
                case _PackTileAction.toggle:
                  onToggle();
                case _PackTileAction.delete:
                  onDelete();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _PackTileAction.edit,
                child: Text(DiscBoutique.packsActionEdit),
              ),
              PopupMenuItem(
                value: _PackTileAction.toggle,
                child: Text(
                  pack.isActif
                      ? DiscBoutique.packsActionUnpublish
                      : DiscBoutique.packsActionPublish,
                ),
              ),
              PopupMenuItem(
                value: _PackTileAction.delete,
                child: Text(
                  DiscBoutique.packsActionDelete,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );
  }
}

class _PackEditorSheet extends ConsumerStatefulWidget {
  const _PackEditorSheet({this.pack});

  final PackOffre? pack;

  @override
  ConsumerState<_PackEditorSheet> createState() => _PackEditorSheetState();
}

class _PackEditorSheetState extends ConsumerState<_PackEditorSheet> {
  late final TextEditingController _titre;
  late final TextEditingController _description;
  late final TextEditingController _prix;
  bool _offreDuJour = false;
  bool _publier = true;
  bool _saving = false;
  bool _uploadingPhoto = false;
  String? _imageUrl;
  final Set<String> _selectedServiceIds = {};
  final Set<String> _selectedProduitIds = {};
  bool _hydratedItems = false;

  @override
  void initState() {
    super.initState();
    final p = widget.pack;
    _titre = TextEditingController(text: p?.titre ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _prix = TextEditingController(
      text: p == null ? '' : p.prixPack.toStringAsFixed(2),
    );
    _offreDuJour = p?.isOffreDuJour ?? false;
    _publier = p?.isActif ?? true;
    _imageUrl = p?.imageUrl;
  }

  @override
  void dispose() {
    _titre.dispose();
    _description.dispose();
    _prix.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final presta = await ref.read(currentPrestataireProvider.future);
    final service = ref.read(packOffreServiceProvider);
    if (!mounted) return;
    if (presta == null || service == null) {
      AppSnackBar.error(context, DiscBoutique.photoUploadErr);
      return;
    }

    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    try {
      final uploadFile = await StorageUploadFile.fromXFile(picked);
      StorageService.validateImageFile(uploadFile);
      final url = await service.uploadImage(
        prestataireId: presta.id,
        file: uploadFile,
      );
      if (!mounted) return;
      setState(() => _imageUrl = url);
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, DiscBoutique.photoUploadErr);
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _hydrateItemsIfNeeded() async {
    if (_hydratedItems || widget.pack == null) {
      _hydratedItems = true;
      return;
    }
    final service = ref.read(packOffreServiceProvider);
    if (service == null) return;
    final items = await service.listItems(widget.pack!.id);
    if (!mounted) return;
    setState(() {
      for (final item in items) {
        if (item.serviceId != null) _selectedServiceIds.add(item.serviceId!);
        if (item.produitId != null) _selectedProduitIds.add(item.produitId!);
      }
      _hydratedItems = true;
    });
  }

  Future<void> _save() async {
    final titre = _titre.text.trim();
    if (titre.isEmpty) {
      AppSnackBar.error(context, DiscBoutique.validationNom);
      return;
    }
    final prix = double.tryParse(_prix.text.trim().replaceAll(',', '.'));
    if (prix == null || prix < 0) {
      AppSnackBar.error(context, DiscBoutique.validationPrix);
      return;
    }
    if (_selectedServiceIds.length + _selectedProduitIds.length < 2) {
      AppSnackBar.error(context, DiscBoutique.packsMinItems);
      return;
    }

    final presta = await ref.read(currentPrestataireProvider.future);
    final service = ref.read(packOffreServiceProvider);
    if (!mounted) return;
    if (presta == null || service == null) {
      AppSnackBar.error(context, DiscBoutique.packsSaveErr);
      return;
    }

    final items = <PackItemDraft>[
      for (final id in _selectedServiceIds) PackItemDraft.service(refId: id),
      for (final id in _selectedProduitIds) PackItemDraft.produit(refId: id),
    ];

    setState(() => _saving = true);
    try {
      await service.upsert(
        PackOffreUpsertData(
          id: widget.pack?.id,
          prestataireId: presta.id,
          titre: titre,
          description: _description.text,
          prixPack: prix,
          isOffreDuJour: _offreDuJour,
          isActif: _publier,
          items: items,
          imageUrl: _imageUrl,
        ),
      );
      if (!mounted) return;
      AppSnackBar.success(context, DiscBoutique.packsSaved);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        final message = e is AppFailure ? e.message : DiscBoutique.packsSaveErr;
        AppSnackBar.error(context, message);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final isEdit = widget.pack != null;
    final prestaAsync = ref.watch(currentPrestataireProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      child: FutureBuilder<void>(
        future: _hydrateItemsIfNeeded(),
        builder: (context, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEdit ? DiscBoutique.packsEdit : DiscBoutique.packsAdd,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: (_imageUrl?.trim().isNotEmpty == true)
                            ? AppNetworkImage(
                                url: _imageUrl!,
                                fit: BoxFit.cover,
                              )
                            : ColoredBox(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            (_saving || _uploadingPhoto) ? null : _pickPhoto,
                        icon: _uploadingPhoto
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.photo_camera_outlined),
                        label: Text(
                          _imageUrl?.trim().isNotEmpty == true
                              ? DiscBoutique.actionChangePhoto
                              : DiscBoutique.actionPickPhoto,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titre,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: DiscBoutique.fieldPackTitre,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _description,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: DiscBoutique.fieldPackDescription,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _prix,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: DiscBoutique.fieldPackPrix,
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(DiscBoutique.fieldOffreDuJour),
                  value: _offreDuJour,
                  onChanged: (v) => setState(() => _offreDuJour = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(DiscBoutique.fieldPublier),
                  value: _publier,
                  onChanged: (v) => setState(() => _publier = v),
                ),
                const SizedBox(height: 8),
                Text(
                  DiscBoutique.sectionItems,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                prestaAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (presta) {
                    if (presta == null) return const SizedBox.shrink();
                    return _PackItemsPicker(
                      prestataireId: presta.id,
                      selectedServiceIds: _selectedServiceIds,
                      selectedProduitIds: _selectedProduitIds,
                      onChanged: () => setState(() {}),
                    );
                  },
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(DiscPrestaForm.save),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PackItemsPicker extends ConsumerWidget {
  const _PackItemsPicker({
    required this.prestataireId,
    required this.selectedServiceIds,
    required this.selectedProduitIds,
    required this.onChanged,
  });

  final String prestataireId;
  final Set<String> selectedServiceIds;
  final Set<String> selectedProduitIds;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceSvc = ref.watch(serviceBeauteServiceProvider);
    final produitSvc = ref.watch(produitBoutiqueServiceProvider);

    return FutureBuilder<
        ({List<ServiceBeaute> services, List<ProduitBoutique> produits})>(
      future: () async {
        final services = serviceSvc == null
            ? const <ServiceBeaute>[]
            : await serviceSvc.getByPrestataire(prestataireId);
        final produits = produitSvc == null
            ? const <ProduitBoutique>[]
            : await produitSvc.getByPrestataire(prestataireId);
        return (services: services, produits: produits);
      }(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final services = snap.data!.services;
        final produits = snap.data!.produits;
        final theme = Theme.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(DiscBoutique.sectionServices, style: theme.textTheme.labelLarge),
            if (services.isEmpty)
              Text(
                DiscBoutique.noServicesHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              )
            else
              ...services.map(
                (s) => CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: selectedServiceIds.contains(s.id),
                  title: Text(s.nom),
                  subtitle: Text(CurrencyFormat.eur(s.prix, decimals: true)),
                  onChanged: (v) {
                    if (v == true) {
                      selectedServiceIds.add(s.id);
                    } else {
                      selectedServiceIds.remove(s.id);
                    }
                    onChanged();
                  },
                ),
              ),
            const SizedBox(height: 8),
            Text(DiscBoutique.sectionProduits, style: theme.textTheme.labelLarge),
            if (produits.isEmpty)
              Text(
                DiscBoutique.noProduitsHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              )
            else
              ...produits.map(
                (p) => CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: selectedProduitIds.contains(p.id),
                  title: Text(p.nom),
                  subtitle: Text(CurrencyFormat.eur(p.prix, decimals: true)),
                  onChanged: (v) {
                    if (v == true) {
                      selectedProduitIds.add(p.id);
                    } else {
                      selectedProduitIds.remove(p.id);
                    }
                    onChanged();
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
