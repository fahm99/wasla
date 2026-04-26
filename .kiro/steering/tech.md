# Tech Stack

## Platform
- **Flutter** SDK `>=3.0.0 <4.0.0` (Dart 3+)
- Targets: Android, iOS, Web (Flutter web via dartpad)

## Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| `supabase_flutter` | ^2.5.0 | Backend, auth, storage, realtime |
| `provider` | ^6.1.1 | State management |
| `go_router` | ^13.1.0 | Navigation & routing |
| `flutter_dotenv` | ^5.1.0 | Environment config from `.env` |
| `flutter_localizations` | sdk | i18n (Arabic RTL) |
| `cached_network_image` | ^3.3.1 | Image caching |
| `image_picker` / `file_picker` | ^1.0.7 / ^6.1.1 | File uploads |
| `video_player` + `chewie` | ^2.8.2 / 1.7.5 | Video playback |
| `syncfusion_flutter_pdfviewer` | ^24.2.8 | PDF viewing |
| `fl_chart` | ^0.66.0 | Charts/analytics |
| `google_fonts` | ^6.1.0 | Typography |
| `flutter_animate` | ^4.3.0 | Animations |
| `gotrue` | ^2.20.0 | Auth types |

## Backend: Supabase

- **Auth**: Email/password with role-based access (`ADMIN`, `PROVIDER`, `STUDENT`)
- **Database tables**: `profiles`, `courses`, `enrollments`, `payments`, `notifications`, `settings`
- **Storage buckets**: `course-images`, `course-videos`, `course-files`, `course-audio`, `avatars`, `certificates`, `payment-proofs`
- **RPC functions**: `get_admin_stats`, `get_monthly_stats`

## Environment Configuration

Uses `flutter_dotenv`. The `.env` file is listed as a Flutter asset and loaded at startup via `EnvConfig.load()`.

Required variables (see `.env.example`):
```
SUPABASE_URL=
SUPABASE_ANON_KEY=
APP_NAME=Wasla
APP_VERSION=1.0.0
ENVIRONMENT=development   # development | staging | production
```

`EnvConfig.validate()` is called at startup and throws if required vars are missing. Access env vars only through `lib/shared/config/env_config.dart`.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run a specific app entry point
flutter run -t lib/provider/main.dart
flutter run -t lib/student/lib/main.dart
flutter run -t lib/admin/lib/main.dart

# Build
flutter build apk
flutter build ios

# Run tests
flutter test
```
