import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../supabase_service.dart';
import 'categorie_suggestion_service.dart';

final categorieSuggestionServiceProvider =
    Provider<CategorieSuggestionService?>((ref) {
      if (!AppConfig.hasSupabase) return null;
      return CategorieSuggestionService(SupabaseService.client);
    });
