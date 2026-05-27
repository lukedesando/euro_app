# euro_app

Flutter web app plus a Flask API for Eurovision voting.

## What It Does

- Shows the Eurovision song list.
- Lets each person submit scores and favorites.
- Tracks skip/X counts in near real time.
- Shows personal, group, and final result views.

## Configuration

Create a local `.env` file in this directory. It is ignored by Git.

```env
DB_ENGINE=mysql
DB_USER=your_database_user
DB_PASSWORD=your_database_password
DB_HOST=your_database_host
DB_NAME=eurovision_db

APP_HOST=0.0.0.0
APP_PORT=5000
API_HOST=your_lan_ip_or_hostname
API_PORT=5000
```

Notes:

- `APP_HOST` / `APP_PORT` control where Flask listens.
- `API_HOST` / `API_PORT` control what the Flutter app calls.
- If `API_HOST` is omitted, `generate_config.dart` falls back to `DB_HOST`.
- If `API_PORT` is omitted, `generate_config.dart` falls back to `APP_PORT`, then `DB_PORT`, then `5000`.
- `DATABASE_URL` can replace the `DB_*` settings later if the backend moves away from MariaDB.
- Runtime web config is written to `web/config.json` and copied into `build/web/config.json`.
- After building, you can edit `build/web/config.json` and refresh the browser to point the app at a different API host without rebuilding Flutter.

## Backend

```powershell
.\scripts\run_backend.ps1
```

Health check:

```powershell
.\scripts\health_check.ps1
```

Expected healthy response:

```json
{"database":"reachable","status":"ok"}
```

## Frontend

Generate Flutter config after changing `.env`:

```powershell
.\scripts\generate_config.ps1
```

This writes:

- `lib/config.dart` as the compile-time fallback.
- `web/config.json` as the runtime web config.

Build the web app:

```powershell
.\scripts\build_web.ps1
```

After enabling Windows Developer Mode, you can also allow Flutter to refresh dependencies during the build:

```powershell
.\scripts\build_web.ps1 -PubGet
```

Serve the built app:

```powershell
.\scripts\serve_web.ps1
```

If your computer gets a new LAN IP after building, edit this file:

```text
build\web\config.json
```

Then refresh the browser.

To use a different static site port:

```powershell
.\scripts\serve_web.ps1 -Port 8080
```

If your Flutter SDK lives somewhere else, set `FLUTTER_ROOT` before running the scripts:

```powershell
$env:FLUTTER_ROOT = "C:\path\to\flutter"
```

## Windows Developer Mode

Flutter plugins use symlinks on Windows. If `flutter pub get` says symlink support is required, enable Developer Mode:

```powershell
start ms-settings:developers
```

Then turn on **Developer Mode** in Windows Settings.
