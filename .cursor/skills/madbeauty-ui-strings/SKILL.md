---
name: madbeauty-ui-strings
description: >-
  Conventions des chaînes UI MadBeauty. Utiliser quand on ajoute, modifie ou
  traduit du texte affiché (labels, titres, erreurs, snackbars, tooltips) dans
  l'app Flutter — jamais de texte en dur dans les widgets.
---

# Chaînes UI MadBeauty

## Règle absolue

**Aucun texte utilisateur en dur** dans `features/` ou `shared/widgets/`. Toujours une constante dans `lib/core/constants/strings/`.

## Où placer une chaîne

| Cas | Fichier |
|-----|---------|
| Marque, actions transverses, erreur générique | `core_strings.dart` → `CoreStrings` |
| Auth (login, register, reset…) | `auth_strings.dart` → `AuthStrings` |
| Shell / navigation bottom | `shell_strings.dart` → `ShellStrings` |
| Écran ou domaine « discovery » | `discovery/disc_<domaine>.dart` → classe `Disc*` |

## Pattern de classe

```dart
/// Accueil client.
abstract final class DiscHome {
  DiscHome._();

  static const feedAllTitle = 'À découvrir';
  static String feedSearchTitle(String query) => 'Salons pour « $query »';
}
```

- `abstract final class` + constructeur privé `._()`
- Noms en **camelCase** descriptifs (`actionSearch`, `feedEmptyTitle`)
- Texte en **français**, ton **tu/vous** cohérent avec le fichier existant (ex. `DiscHome` mélange tutoiement client)

## Nouveau fichier discovery

1. Créer `lib/core/constants/strings/discovery/disc_<feature>.dart`
2. **Exporter** dans `discovery_strings.dart` (`export 'discovery/disc_….dart';`)
3. Importer via `package:madbeauty/core/constants/strings/discovery_strings.dart` ou le barrel approprié

## Erreurs

- Message métier spécifique → classe du domaine concerné
- Erreur inconnue / fallback → `CoreStrings.errorUnexpected`
- Erreurs auth Supabase mappées → `AuthStrings` / `supabase_error_handler.dart`

## Nommage des constantes

Préfixes courants : `action*`, `field*`, `validation*`, `error*`, `empty*Title`, `empty*Body`, `*Sub`, `*Hint`, `*Tooltip`
