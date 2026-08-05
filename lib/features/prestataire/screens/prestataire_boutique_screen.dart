import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/produit_boutique.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/app/app_network_image.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_detail_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../services/supabase/prestataire/boutique/boutique_providers.dart';
import '../../../services/supabase/prestataire/boutique/produit_boutique_service.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../providers/boutique/boutique_providers.dart';
import '../providers/profile/current_prestataire_provider.dart';
import '../widgets/workspace/prestataire_flow_scaffold.dart';

/// Gestion des produits boutique (espace prestataire).
class PrestataireBoutiqueScreen extends ConsumerWidget {
  const PrestataireBoutiqueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ownProduitsBoutiqueProvider);

    return PrestataireSubpageScaffold(
      title: DiscBoutique.boutiqueTitle,
      subtitle: DiscBoutique.boutiqueSubtitle,
      icon: Icons.storefront_outlined,
      body: async.when(
        loading: () => const DiscoveryDetailSkeleton(),
        error: (_, __) => DiscoveryEmptyState(
          icon: Icons.error_outline_rounded,
          title: DiscBoutique.boutiqueLoadErr,
          body: CoreStrings.errorUnexpected,
          actionLabel: DiscList.retry,
          onAction: () => ref.invalidate(ownProduitsBoutiqueProvider),
        ),
        data: (produits) {
          final actifs = produits.where((p) => p.isActif).toList();
          return Stack(
            children: [
              if (actifs.isEmpty)
                DiscoveryEmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: DiscBoutique.boutiqueEmptyTitle,
                  body: DiscBoutique.boutiqueEmptyBody,
                )
              else
                ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                  itemCount: actifs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final p = actifs[index];
                    return _ProduitTile(
                      produit: p,
                      onEdit: () => _openEditor(context, ref, produit: p),
                      onDeactivate: () => _deactivate(context, ref, p),
                    );
                  },
                ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.extended(
                  onPressed: () => _openEditor(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(DiscBoutique.boutiqueAdd),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deactivate(
    BuildContext context,
    WidgetRef ref,
    ProduitBoutique produit,
  ) async {
    final presta = await ref.read(currentPrestataireProvider.future);
    final service = ref.read(produitBoutiqueServiceProvider);
    if (presta == null || service == null) return;
    try {
      await service.deactivate(prestataireId: presta.id, id: produit.id);
      ref.invalidate(ownProduitsBoutiqueProvider);
      ref.invalidate(ownBoutiqueSummaryProvider);
      if (context.mounted) {
        AppSnackBar.success(context, DiscBoutique.boutiqueDeactivated);
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.error(context, DiscBoutique.boutiqueSaveErr);
      }
    }
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    ProduitBoutique? produit,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ProduitEditorSheet(produit: produit),
    );
    if (saved == true) {
      ref.invalidate(ownProduitsBoutiqueProvider);
      ref.invalidate(ownBoutiqueSummaryProvider);
    }
  }
}

class _ProduitTile extends StatelessWidget {
  const _ProduitTile({
    required this.produit,
    required this.onEdit,
    required this.onDeactivate,
  });

  final ProduitBoutique produit;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = produit.imageUrl?.trim();

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
                        Icons.shopping_bag_outlined,
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
                  produit.nom,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                if (produit.conditionnement?.trim().isNotEmpty == true)
                  Text(
                    produit.conditionnement!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
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
                      CurrencyFormat.eur(produit.prix, decimals: true),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _StockBadge(produit: produit),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<_ProduitTileAction>(
            tooltip: DiscBoutique.boutiqueEdit,
            onSelected: (action) {
              switch (action) {
                case _ProduitTileAction.edit:
                  onEdit();
                case _ProduitTileAction.deactivate:
                  onDeactivate();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _ProduitTileAction.edit,
                child: Text(DiscBoutique.boutiqueEdit),
              ),
              const PopupMenuItem(
                value: _ProduitTileAction.deactivate,
                child: Text(DiscBoutique.actionRetirer),
              ),
            ],
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );
  }
}

enum _ProduitTileAction { edit, deactivate }

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.produit});

  final ProduitBoutique produit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color bg;
    final Color fg;
    final String label;
    if (produit.stockIllimite) {
      label = DiscBoutique.stockBadgeUnlimited;
      bg = theme.colorScheme.surfaceContainerHighest;
      fg = theme.colorScheme.onSurfaceVariant;
    } else if (produit.isOutOfStock) {
      label = DiscBoutique.stockBadgeOut;
      bg = theme.colorScheme.errorContainer;
      fg = theme.colorScheme.onErrorContainer;
    } else {
      label = DiscBoutique.stockBadgeQty(produit.stockQty);
      bg = produit.isLowStock
          ? theme.colorScheme.tertiaryContainer
          : theme.colorScheme.primary.withValues(alpha: 0.12);
      fg = produit.isLowStock
          ? theme.colorScheme.onTertiaryContainer
          : theme.colorScheme.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProduitEditorSheet extends ConsumerStatefulWidget {
  const _ProduitEditorSheet({this.produit});

  final ProduitBoutique? produit;

  @override
  ConsumerState<_ProduitEditorSheet> createState() =>
      _ProduitEditorSheetState();
}

class _ProduitEditorSheetState extends ConsumerState<_ProduitEditorSheet> {
  late final TextEditingController _nom;
  late final TextEditingController _description;
  late final TextEditingController _conditionnement;
  late final TextEditingController _prix;
  late final TextEditingController _stockQty;
  late ProduitBoutiqueCategorie _categorie;
  String? _imageUrl;
  bool _stockIllimite = false;
  bool _saving = false;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    final p = widget.produit;
    _nom = TextEditingController(text: p?.nom ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _conditionnement = TextEditingController(text: p?.conditionnement ?? '');
    _prix = TextEditingController(
      text: p == null ? '' : p.prix.toStringAsFixed(2),
    );
    _stockIllimite = p?.stockIllimite ?? false;
    _stockQty = TextEditingController(
      text: p == null ? '0' : '${p.stockQty}',
    );
    _categorie = p?.categorie ?? ProduitBoutiqueCategorie.autre;
    _imageUrl = p?.imageUrl;
  }

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    _conditionnement.dispose();
    _prix.dispose();
    _stockQty.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final presta = await ref.read(currentPrestataireProvider.future);
    final service = ref.read(produitBoutiqueServiceProvider);
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

  Future<void> _save() async {
    final nom = _nom.text.trim();
    if (nom.isEmpty) {
      AppSnackBar.error(context, DiscBoutique.validationNom);
      return;
    }
    final prix = double.tryParse(_prix.text.trim().replaceAll(',', '.'));
    if (prix == null || prix < 0) {
      AppSnackBar.error(context, DiscBoutique.validationPrix);
      return;
    }
    final stockQty = int.tryParse(_stockQty.text.trim());
    if (!_stockIllimite && (stockQty == null || stockQty < 0)) {
      AppSnackBar.error(context, DiscBoutique.validationStock);
      return;
    }

    final presta = await ref.read(currentPrestataireProvider.future);
    final service = ref.read(produitBoutiqueServiceProvider);
    if (!mounted) return;
    if (presta == null || service == null) {
      AppSnackBar.error(context, DiscBoutique.boutiqueSaveErr);
      return;
    }

    setState(() => _saving = true);
    try {
      await service.upsert(
        ProduitBoutiqueUpsertData(
          id: widget.produit?.id,
          prestataireId: presta.id,
          nom: nom,
          description: _description.text,
          conditionnement: _conditionnement.text,
          categorie: _categorie,
          prix: prix,
          imageUrl: _imageUrl,
          isActif: true,
          stockIllimite: _stockIllimite,
          stockQty: _stockIllimite ? 0 : (stockQty ?? 0),
        ),
      );
      if (!mounted) return;
      AppSnackBar.success(context, DiscBoutique.boutiqueSaved);
      Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, DiscBoutique.boutiqueSaveErr);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final isEdit = widget.produit != null;
    final theme = Theme.of(context);
    final image = _imageUrl?.trim();

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEdit ? DiscBoutique.boutiqueEdit : DiscBoutique.boutiqueAdd,
              style: theme.textTheme.titleLarge?.copyWith(
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
                    child: image != null && image.isNotEmpty
                        ? AppNetworkImage(url: image, fit: BoxFit.cover)
                        : ColoredBox(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.image_outlined,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (_saving || _uploadingPhoto) ? null : _pickPhoto,
                    icon: _uploadingPhoto
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo_camera_outlined),
                    label: Text(
                      image != null && image.isNotEmpty
                          ? DiscBoutique.actionChangePhoto
                          : DiscBoutique.actionPickPhoto,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nom,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: DiscBoutique.fieldNom,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _conditionnement,
              decoration: const InputDecoration(
                labelText: DiscBoutique.fieldConditionnement,
                hintText: DiscBoutique.fieldConditionnementHint,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: DiscBoutique.fieldDescription,
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
                labelText: DiscBoutique.fieldPrix,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(DiscBoutique.fieldStockIllimite),
              value: _stockIllimite,
              onChanged: (v) => setState(() => _stockIllimite = v),
            ),
            if (!_stockIllimite)
              TextField(
                controller: _stockQty,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: DiscBoutique.fieldStockQty,
                ),
              ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ProduitBoutiqueCategorie>(
              value: _categorie,
              decoration: const InputDecoration(
                labelText: DiscBoutique.fieldCategorie,
              ),
              items: [
                for (final c in ProduitBoutiqueCategorie.values)
                  DropdownMenuItem(
                    value: c,
                    child: Text(_categorieLabel(c)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _categorie = v);
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: (_saving || _uploadingPhoto) ? null : _save,
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
      ),
    );
  }

  String _categorieLabel(ProduitBoutiqueCategorie c) => switch (c) {
        ProduitBoutiqueCategorie.cheveux => DiscBoutique.catCheveux,
        ProduitBoutiqueCategorie.visage => DiscBoutique.catVisage,
        ProduitBoutiqueCategorie.corps => DiscBoutique.catCorps,
        ProduitBoutiqueCategorie.accessoires => DiscBoutique.catAccessoires,
        ProduitBoutiqueCategorie.autre => DiscBoutique.catAutre,
      };
}
