# Security policy

## Supported versions

Until v1.0.0, only the `main` branch is supported.

| Version | Supported          |
|---------|--------------------|
| 0.x     | :white_check_mark: |

## Reporting a vulnerability

We take security seriously. If you discover a vulnerability in the
FanPitch mobile app:

1. **Do NOT open a public issue.**
2. Use one of these private channels:
   - **GitHub Security Advisory** (preferred):
     https://github.com/Jonlandu/fanpitch-app/security/advisories/new
   - **Email**: `Development@bmprimecapital.com` (subject:
     `[SECURITY] FanPitch app`)

Please include:
- Description of the vulnerability + proof-of-concept.
- Affected version / commit.
- Anticipated impact.
- How you'd like to be credited (or "anonymous").

**Our commitments**:
- Acknowledge within **72 hours**.
- Patch high/critical findings within **14 days**.
- Credit you in the release notes unless you prefer anonymity.

## Scope

- The Flutter mobile app source (`lib/`, `android/`, `ios/`).
- Brand assets and bundled resources (`assets/`).
- Build / CI scripts under `.github/`.

## Out of scope

- Vulnerabilities in third-party Dart packages — please report upstream.
  We track them via Dependabot.
- Issues that require physical access to a rooted / jailbroken device.
- Demo seed credentials (`admin/admin12345`, `kinshasa_kid/fanpitch1234`,
  etc.) — they are intentionally weak for the hackathon demo and must
  not be reused in production.

## Mobile-specific controls

| Layer | Control |
|---|---|
| Token storage | `flutter_secure_storage` (Keychain / Keystore — encrypted at rest, not in shared prefs). |
| JWT lifetime  | 30-minute access token + 14-day refresh, rotated on every refresh. |
| Refresh interceptor | dio interceptor auto-refreshes on 401 then retries; if refresh fails, all tokens cleared and the user is sent to `/login`. |
| Transport     | HTTPS in production; the AWS EC2 demo is HTTP-only (sandbox limitation) and not used outside of the contest demo. |
| Permissions   | Each permission has a French-language usage description in `Info.plist` and `AndroidManifest.xml`. We only ask for what the current screen needs. |
| Deep links    | Not enabled (yet). If we add them, we'll validate the URL host against an allow-list. |

## Known limitations

- HTTP (not HTTPS) traffic against the AWS sandbox demo URL.
  Production builds for the App Store will require HTTPS + certificate
  pinning.
- No certificate pinning yet — `dio` accepts the default trust store.
  Acceptable for the hackathon, must be added before public release.
