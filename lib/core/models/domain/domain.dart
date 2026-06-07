/// Modèles de données métier MadBeauty (schéma ER) – Freezed, JSON, Supabase.
///
/// Arborescence :
/// - [serialization] – convertisseurs JSON + codec lignes Supabase
/// - [user] – comptes & profils utilisateur
/// - [catalog] – catégories, services, spécialités, portfolio
/// - [booking] – réservations & favoris
/// - [reviews] – avis
/// - [messaging] – conversations & messages
library;

export 'booking/client_reservation_summary.dart';
export 'booking/favori.dart';
export 'booking/prestataire_reservation_item.dart';
export 'booking/reservation.dart';
export 'catalog/categorie_service.dart';
export 'catalog/photo_realisation.dart';
export 'catalog/prestataire_specialite.dart';
export 'catalog/service_beaute.dart';
export 'messaging/conversation.dart';
export 'messaging/conversation_inbox_item.dart';
export 'messaging/message.dart';
export 'prestataire/prestataire_dashboard_data.dart';
export 'reviews/avis.dart';
export 'reviews/review.dart';
export 'serialization/json_converters.dart';
export 'serialization/supabase_domain_codec.dart';
export 'user/app_user.dart';
export 'user/client_profile.dart';
export 'user/prestataire_profile.dart';
export 'user/user_profile.dart';

