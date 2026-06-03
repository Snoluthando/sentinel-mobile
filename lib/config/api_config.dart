/// Sentinel API base URL.
/// After cloud migration, set this to your new host (Fly.io, Render, etc.).
/// See Sentinel/files/MIGRATION.md. Local Android emulator: http://10.0.2.2:3001
const String kSentinelApiBaseUrl =
    'https://sentinel-production.up.railway.app';

/// Default map centre (Johannesburg) when GPS is unavailable.
const double kDefaultLat = -26.0274;
const double kDefaultLng = 28.0088;
