# Sleek 🎵🎬

A Flutter mobile app that downloads a YouTube video as **MP3** or **MP4**. The UI is a
dark "candlelit manuscript / library" design with three switchable *bindings*
(I · Codex, II · Folio, III · Illuminated), format/quality selection, a save-location
picker, and a live progress meter (percent, size, speed, ETA, elapsed time).

> **Personal use only.** Downloading from YouTube may breach YouTube's Terms of
> Service and copyright law. Only download content you own or have permission to
> download. Provided for educational purposes — see [docs/PRD.md](docs/PRD.md#8-legal--disclaimer).

## Status
- ✅ Full manuscript UI with three switchable bindings; link → metadata preview →
  format/quality/destination selection → live progress → done receipt.
- ✅ **MP4 download works** end-to-end with progress.
- ✅ **MP3 is real** — the best source audio is downloaded then re-encoded to a true
  `.mp3` at the chosen bitrate with ffmpeg (`ffmpeg_kit_flutter_new`).

## Requirements
- Flutter 3.41+ / Dart 3.11+
- Android SDK + a device or emulator (phone or tablet)

## Getting started
```bash
flutter pub get
flutter run            # on a connected device/emulator
```
Confirm a device is attached with `adb devices`. For a release build:
```bash
flutter build apk --release
```

## Project structure
```
lib/
├── main.dart                       # ProviderScope + runApp
├── app.dart                        # MaterialApp, theme, home
├── core/
│   ├── constants/app_constants.dart
│   ├── theme/                      # app_theme.dart, manuscript_theme.dart (3 bindings)
│   ├── responsive/responsive.dart  # phone vs tablet, width-capped content
│   ├── utils/                      # formatters.dart, validators.dart
│   └── errors/failures.dart
└── features/converter/
    ├── domain/entities/            # media_format.dart, conversion_request.dart
    ├── data/
    │   ├── models/                 # video_info.dart, download_task.dart
    │   ├── services/               # youtube, download, storage, conversion
    │   └── repositories/converter_repository.dart
    └── presentation/
        ├── providers/              # converter_controller.dart, conversion_state.dart
        ├── screens/                # home_screen.dart, settings_screen.dart
        └── widgets/                # url input, preview, selectors, progress

docs/                               # PRD.md, PHASE_TASKS.md, README.md
```

## Architecture
Feature-first clean architecture. The **presentation** layer (Riverpod
`ConverterController` + immutable `ConversionState`) drives the UI through stages
(idle → loading → ready → converting → done/error). It calls a **repository** that
orchestrates four single-responsibility **services**:

- `YoutubeService` — metadata + stream resolution + byte stream (`youtube_explode_dart`).
- `DownloadService` — streams bytes to disk, emits throttled progress.
- `StorageService` — default directory, permissions, safe output paths.
- `ConversionService` — MP3 re-encode (ffmpeg, Phase 3).

Services are exposed as Riverpod providers, so they're easy to override in tests.

## Tech stack
| Concern | Package |
|---------|---------|
| State | `flutter_riverpod` |
| YouTube extraction & download | `youtube_explode_dart` |
| Directory picker | `file_picker` |
| Default dirs | `path_provider` |
| Permissions | `permission_handler` |
| Fonts | `google_fonts` |
| MP3 re-encode (Phase 3) | `ffmpeg_kit_flutter_new` |

## Roadmap
See [docs/PHASE_TASKS.md](docs/PHASE_TASKS.md). Next up: wire ffmpeg for true MP3,
then UX polish (animations, settings, share sheet, app icon) and tests.
