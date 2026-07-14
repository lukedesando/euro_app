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
DB_PORT=3306
DB_NAME=eurovision_db
DB_CONNECT_TIMEOUT=5

APP_HOST=0.0.0.0
APP_PORT=5000
API_HOST=your_lan_ip_or_hostname
API_PORT=5000

# Optional: full public API URLs, useful for Cloudflare Tunnel.
API_BASE_HTTP=https://api.desando.org
API_BASE_WS=wss://api.desando.org
```

Notes:

- `APP_HOST` / `APP_PORT` control where Flask listens.
- `API_HOST` / `API_PORT` control what the Flutter app calls.
- `API_BASE_HTTP` / `API_BASE_WS` override the generated host/port URLs. Use these for HTTPS/WSS public hosting such as Cloudflare Tunnel.
- `DB_CONNECT_TIMEOUT` controls how long backend database requests wait before returning a 503.
- If `API_HOST` is omitted, `generate_config.dart` falls back to `DB_HOST`.
- If `API_PORT` is omitted, `generate_config.dart` falls back to `APP_PORT`, then `DB_PORT`, then `5000`.
- If `API_BASE_HTTP` / `API_BASE_WS` are omitted, `generate_config.dart` builds them from `API_HOST` / `API_PORT`.
- `DATABASE_URL` can replace the `DB_*` settings later if the backend moves away from MariaDB.
- Runtime web config is written to `web/config.json` and copied into `build/web/config.json`.
- After building, you can edit `build/web/config.json` and refresh the browser to point the app at a different API URL without rebuilding Flutter.

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

## Location Setup

When the server IP changes, update the backend database host and frontend API URLs together:

```powershell
.\scripts\configure_location.ps1 -ServerHost 192.168.4.102
```

For event night, replace `192.168.4.102` with the event network IP address of the machine running Flask. If MariaDB is on the same machine as Flask and only listens locally, use:

```powershell
.\scripts\configure_location.ps1 -ServerHost 192.168.x.x -DbHost localhost
```

This updates `.env`, `web/config.json`, and `build/web/config.json` when the build output exists. After running it, restart the backend and refresh the web app.

For a public HTTPS API behind Cloudflare Tunnel or another reverse proxy, set the exact public URLs:

```powershell
.\scripts\configure_location.ps1 -ServerHost 192.168.x.x -DbHost localhost -ApiHost api.desando.org -ApiPort 443 -ApiBaseHttp https://api.desando.org -ApiBaseWs wss://api.desando.org
```

This keeps the backend on the local machine while telling the web app to call the public API origin instead of a private LAN IP.

## Updating Songs

Pick a Eurovision year and scrape the participant song table plus the final split results from Wikipedia:

```powershell
.\scripts\update_songs.ps1 -Year 2024 -DryRun
```

When the preview looks right, overwrite MariaDB:

```powershell
.\scripts\update_songs.ps1 -Year 2024
```

The updater replaces `songs`, reloads `final_results`, and clears `votes` and `favorites` so old contest data cannot point at the new song IDs. Add `-Yes` to skip the confirmation prompt.

## Frontend

One-command event-day workflow:

```powershell
.\scripts\publish_public.ps1
```

This command:

- Detects the current machine LAN IP automatically.
- Sets `.env`, `web/config.json`, and `build/web/config.json` to use the public API URLs.
- Rebuilds the Flutter web app.
- Starts the backend on port `5000` if it is not already running.
- Starts the local static web server on port `8000` if it is not already running.
- Runs a local API health check.

Useful options:

- `-RestartBackend` restarts Flask after backend code changes.
- `-RestartWeb` restarts the static web server if needed.
- `-PubGet` allows Flutter to refresh dependencies before building.
- `-SkipBuild` is useful when you only need to relaunch the local services.

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
