# Contribution — MadBeauty

Guide court pour commits, branches et revue de code.

## Prérequis

- Flutter / Dart versions compatibles avec `pubspec.yaml`
- `dart run build_runner build` après modification de modèles **Freezed**
- Ne pas committer `.env`, clés API, artefacts `build/` ou `.dart_tool/` (sauf convention projet)

## Workflow Git

1. **Synchroniser** la branche de base (`main` ou `develop` selon l’équipe).
2. Créer une **branche descriptive** :
   - `feature/ma-fonctionnalite`
   - `fix/correctif-bug-x`
   - `chore/mise-a-jour-deps`
   - `docs/maj-architecture`
3. **Commits atomiques** : une intention par commit (facilite le revert et la review).
4. Ouvrir une **Pull Request** vers la branche cible avec description claire.
5. Faire valider la CI / tests locaux avant merge.

## Conventions de commit (Conventional Commits)

Format recommandé :

```
<type>(<scope optionnel>): <description courte>

[corps optionnel]
```

**Types courants**

| Type | Usage |
|------|--------|
| `feat` | Nouvelle fonctionnalité visible utilisateur |
| `fix` | Correction de bug |
| `refactor` | Refactor sans changement de comportement voulu |
| `test` | Ajout ou correction de tests |
| `docs` | Documentation uniquement |
| `chore` | Maintenance (deps, config, formatage) |
| `perf` | Amélioration mesurable des perfs |

**Exemples**

```
feat(auth): choix du rôle persisté côté Supabase
fix(router): redirection après inscription sans session active
docs: ajout DB_SCHEMA et ARCHITECTURE
test(domain): roundtrip SupabaseDomainCodec avec mocks
```

- Description en **français** ou **anglais** : rester **cohérent** avec le reste de l’historique du dépôt.
- Éviter les messages vagues (`update`, `fix bug`).

## Pull Requests

### Contenu de la PR

- **Titre** : même esprit que le commit principal ou résumé du lot.
- **Description** : contexte, choix techniques, captures si UI, référence issue si applicable.
- **Checklist** (recommandé) :
  - [ ] `flutter analyze` sans erreurs nouvelles
  - [ ] `flutter test` OK
  - [ ] `build_runner` à jour si modèles Freezed modifiés
  - [ ] Migrations Supabase testées en local (`supabase db reset`) si SQL modifié

### Revue

- Taille de PR **préférable < ~400 lignes** de diff utile (sinon découper).
- Ne pas mélanger refactor massif et feature sans nécessité.
- Respecter les conventions du projet : chaînes dans `lib/core/constants/` (`CoreStrings`, `AuthStrings`, `ShellStrings`, `DiscoveryStrings`), couches `features/` / `services/` / `core/`, pas de secrets dans le code.

### Après merge

- Supprimer la branche distante si applicable.
- Déployer / pousser les migrations Supabase selon le process équipe (`supabase db push`).

## Code

- **Une PR = un objectif principal** ; éviter les changements hors sujet.
- Alignement avec [ARCHITECTURE.md](./ARCHITECTURE.md) : pas de logique métier lourde dans les seuls widgets si évitable.
- Fichiers générés (`*.freezed.dart`, `*.g.dart`) : **commités** pour CI et clones simples.

## Questions

En cas de doute sur le périmètre MVP vs V2, se référer à [FEATURES.md](./FEATURES.md).
