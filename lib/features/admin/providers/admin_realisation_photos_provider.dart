import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/admin/admin_realisation_photo_summary.dart';
import '../../../services/supabase/admin/admin_realisation_photos_service.dart';

final adminRealisationPhotosServiceProvider =
    Provider<AdminRealisationPhotosService?>((ref) {
  return AdminRealisationPhotosService.fromEnv();
});

typedef AdminRealisationPhotosQuery = ({String? search, int offset});

final adminRealisationPhotosProvider = FutureProvider.autoDispose
    .family<List<AdminRealisationPhotoSummary>, AdminRealisationPhotosQuery>(
        (ref, query) async {
  final service = ref.watch(adminRealisationPhotosServiceProvider);
  if (service == null) return const [];
  return service.listPhotos(
    search: query.search,
    offset: query.offset,
  );
});
