# Project Structure

The repo is a single Flutter project (`pubspec.yaml` at root) containing three independent sub-apps under `lib/`, plus a shared module.

```
lib/
├── admin/lib/          # Admin dashboard app
├── provider/           # Provider (course creator) app
├── student/lib/        # Student app
└── shared/             # Cross-app shared code
    ├── config/
    │   └── env_config.dart       # Single source for env vars
    └── services/
        └── unified_auth_service.dart
```

## Per-App Structure

Each sub-app follows the same internal layout:

```
<app>/
├── main.dart           # Entry point — initializes Supabase, registers providers
├── config/
│   ├── app_theme.dart  # MaterialTheme definition
│   ├── supabase_config.dart  # Table/bucket name constants
│   └── routes.dart     # GoRouter configuration
├── models/             # Plain Dart data classes
├── providers/          # ChangeNotifier state classes
├── services/           # Supabase/storage interaction layer
├── views/
│   └── screens/        # Feature-grouped screen widgets
└── widgets/            # Reusable UI components
```

## Conventions

### Models
- Plain Dart classes with `fromJson(Map<String, dynamic>)` factory, `toJson()`, and `copyWith()`.
- Nullable fields use `?`; required fields are non-nullable.
- JSON keys match Supabase column names (snake_case). Dart fields use camelCase.

### State Management
- `provider` package with `ChangeNotifier`.
- Each feature has its own `XxxProvider` (e.g., `CoursesProvider`, `PaymentsProvider`).
- Providers expose: `isLoading`, `error`, and domain data getters.
- All providers registered in `MultiProvider` in `main.dart`.

### Services
- `SupabaseService` handles all DB queries for a given app.
- `AuthService` handles auth operations and profile fetching.
- `StorageService` handles file uploads to Supabase Storage.
- Services are injected into providers via constructor or accessed via `Supabase.instance.client`.

### Routing
- All navigation uses `go_router` (`GoRouter` / `GoRoute`).
- Route paths are defined in `config/routes.dart` (provider app uses `AppRoutes`, admin uses inline `_router`).
- Auth redirect logic lives in the router's `redirect` callback.
- Path parameters use `:id` pattern (e.g., `/courses/:id`).

### Theming & Localization
- Theme defined in `config/app_theme.dart` per app; access via `AppTheme.lightTheme`.
- App locale is `ar_SA` with RTL enforced via `Directionality(textDirection: TextDirection.rtl, ...)`.
- UI strings are in Arabic. Error messages are in Arabic (sometimes bilingual in comments).

### Constants
- Supabase table/bucket names live in `config/supabase_config.dart` per app — never hardcode table names inline.
- Domain constants (roles, statuses, categories, file size limits) live in `config/constants.dart` (provider app).

### Assets
```
assets/
├── images/
└── icons/
```
The `.env` file is also declared as a Flutter asset.
