# Product Requirements Document — YT Converter

## 1. Overview
YT Converter is a mobile app that downloads a YouTube video as either an **MP4**
(video + audio) or **MP3** (audio) file. The user pastes a link, picks the format
and quality, chooses where to save, and watches a live progress bar while the file
downloads.

- **Platform (v1):** Android phones and tablets.
- **Framework:** Flutter (Dart), Riverpod for state.
- **Out of scope (v1):** iOS, desktop, playlists, account/sign-in, background queue,
  in-app playback, batch downloads.

## 2. Goals
1. Make downloading a single video fast and obvious — three taps from link to file.
2. Clean, modern Material 3 UI that adapts to phones and tablets.
3. Honest, detailed progress: percent, size, speed, ETA, elapsed time.
4. Let the user choose the output folder.

## 3. Target users
People who want to keep a personal copy of a video or its audio on their device —
e.g. music, lectures, podcasts they have the right to download.

## 4. Functional requirements
| # | Requirement |
|---|-------------|
| F1 | Validate a pasted YouTube URL (watch, youtu.be, shorts, embed, live). |
| F2 | Fetch and show video metadata: thumbnail, title, author, duration. |
| F3 | Choose output format: MP3 or MP4. |
| F4 | Choose quality: video resolutions (from available streams) or MP3 bitrate tiers (128/192/320 kbps). |
| F5 | Choose the save directory (system picker) with a sensible default. |
| F6 | Download with a live progress bar + %, transferred size, speed, ETA, elapsed time. |
| F7 | MP3 output is re-encoded to a true `.mp3` via ffmpeg (Phase 3). |
| F8 | Show a success screen with file size, time taken, and the saved path. |
| F9 | Clear error handling (invalid link, unavailable video, network, permissions). |

## 5. UX flow
1. **Idle** — hero header + URL field + "paste" + "fetch".
2. **Loading** — spinner on fetch.
3. **Ready** — preview card → Format → Quality → Destination → "Convert".
4. **Converting** — progress card with full stats.
5. **Done** — success card with size/time/path and "Convert another".
6. **Error** — SnackBar message; user stays on the current screen to retry.

## 6. Non-functional requirements
- Responsive: content is centered and width-capped on tablets/landscape.
- Resilient: partial files are cleaned up on failure; UI updates throttled (~15/s).
- Testable: pure helpers (formatters, validators) and a service layer behind
  Riverpod providers that can be overridden in tests.
- Light/dark theme follows the system setting.

## 7. Architecture
Feature-first clean architecture under `lib/`:
- `core/` — theme, responsive helpers, constants, utils, errors.
- `features/converter/domain` — entities (format, quality, request).
- `features/converter/data` — models, services (youtube/download/storage/conversion),
  repository.
- `features/converter/presentation` — Riverpod controller/state, screens, widgets.

Key packages: `youtube_explode_dart` (extraction + download), `flutter_riverpod`
(state), `file_picker` (directory chooser), `path_provider` (default dirs),
`permission_handler` (storage), `ffmpeg_kit_flutter_new` (MP3 re-encode, Phase 3).

## 8. Legal / disclaimer
For **personal use only**. Downloading from YouTube may violate YouTube's Terms of
Service, and redistributing copyrighted content is illegal in most jurisdictions.
Only download content you own or have explicit permission to download. This project
is provided for educational purposes.
