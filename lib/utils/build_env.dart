/// Build environment marker injected at compile time via:
///   flutter build apk --dart-define=BUILD_ENV=prod
///
/// Use [BuildEnv.current] to branch behaviour or to render the small
/// [EnvBadge] overlay that signals which backend the app is hitting.
enum BuildEnv {
  local,    // localhost:8000 backend
  dev,      // dev branch deploy (typically aliases to local in sandbox)
  staging,  // staging branch deploy
  prod;     // production — the AWS EC2 hosted backend

  static final current = _resolve();

  static BuildEnv _resolve() {
    const raw = String.fromEnvironment('BUILD_ENV', defaultValue: 'local');
    return BuildEnv.values.firstWhere(
      (e) => e.name == raw.toLowerCase(),
      orElse: () => BuildEnv.local,
    );
  }

  /// True for any non-production build — used to render the env badge.
  bool get showBadge => this != BuildEnv.prod;

  /// User-facing label for the badge.
  String get label => switch (this) {
        BuildEnv.local   => 'LOCAL',
        BuildEnv.dev     => 'DEV',
        BuildEnv.staging => 'STAGING',
        BuildEnv.prod    => 'PROD',
      };
}
