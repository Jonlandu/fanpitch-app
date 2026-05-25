# Contributing to FanPitch mobile

Thanks for helping ship FanPitch. This is the mobile companion app
(Flutter) to [`fanpitch-api`](https://github.com/Jonlandu/fanpitch-api).
For the architectural decisions and the backend contribution guide, see
[`ARCHITECTURE.md`](ARCHITECTURE.md) and the backend's `CONTRIBUTING.md`.

---

## Branch strategy

We use a lightweight **GitFlow** with three protected branches.

```
                       PR + ✓ checks
   feature/* ──────▶ dev ──────▶ staging ──────▶ main (= App Store / Play Store)
```

| Branch    | Purpose                              | Push direct? |
|-----------|--------------------------------------|--------------|
| `main`    | Release-ready. Tagged for builds.    | ❌ PR only   |
| `staging` | Pre-release. CI + manual QA pass.    | ❌ PR only   |
| `dev`     | Integration. Feature merges land here.| ❌ PR only  |
| `feature/<short-name>` | Single unit of work.         | ✅ Yes       |
| `fix/<short-name>`     | Bug fixes.                   | ✅ Yes       |
| `chore/<short-name>`   | Tooling / deps / config.     | ✅ Yes       |

## Commit messages — Conventional Commits

Same rules as the backend repo. Allowed types: `feat`, `fix`, `chore`,
`docs`, `refactor`, `perf`, `test`, `build`, `style`, `revert`. Enforced
by commitlint in CI on PR titles.

Examples:
```
feat(profile): clickable user profile screen
feat(post): download media to phone gallery
fix(splash): logo scale animation flicker on cold start
```

## Local setup

```bash
git clone https://github.com/Jonlandu/fanpitch-app.git
cd fanpitch-app
flutter pub get

# iOS simulator (against the LIVE AWS backend)
flutter run -d "iPhone 15" \
  --dart-define=API_BASE=http://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com \
  --dart-define=WS_BASE=ws://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com

# Or against a local backend
flutter run -d "iPhone 15"   # defaults wired in lib/utils/config.dart
```

Demo logins: `admin / admin12345`, `kinshasa_kid / fanpitch1234`,
`lisbon_lion / fanpitch1234`, etc. — seeded by the backend's
`python manage.py demo_setup`.

## Code style

- **Dart**: `flutter analyze` must pass with zero issues.
- **Imports**: `dart:` first, then `package:` (alphabetical), then
  relative imports. The Dart formatter handles this; run
  `dart format lib/`.
- **No `// ignore: ...`** without a comment explaining why.
- **No emojis** in code or comments unless explicitly part of UX (e.g.
  reaction emojis).
- Material 3 idioms only — no `Theme.of(context).primaryColor`
  legacy API; use `colorScheme.primary`.

## Theming

The brand palette (vert/orange/noir/blanc) is locked in
[`lib/theme.dart`](lib/theme.dart) via `FanPitchColors` constants and
the `FanPitchPalette` extension. To use brand colors or gradients in a
widget:

```dart
final fp = context.fp;          // FanPitchPalette
final brand = fp.brandGradient; // vert → orange
final liveColor = fp.liveIndicator;
```

Never hard-code colors outside `lib/theme.dart`.

## Pull request workflow

Same as the backend: branch off `dev`, open a (draft) PR early, fill the
template, get the CI green, request review, squash-merge.

Required checks on `main`:
- `flutter-analyze`
- `flutter-test`
- `commitlint`

## Adding a new dependency

1. Justify it in the PR description (size, maintenance, security record).
2. Run `flutter pub get` and commit both `pubspec.yaml` and
   `pubspec.lock`.
3. If the dep adds platform code (iOS / Android), document any new
   permissions in `ios/Runner/Info.plist` and the Android manifest.

## Reporting bugs / security issues

See [`SECURITY.md`](SECURITY.md). Never file a security issue publicly.
