# Phase Tasks

Checklist for building YT Converter. ✅ = done in the current scaffold,
⬜ = remaining.

## Phase 0 — Scaffold & shell ✅
- [x] `flutter create` (project name `yt_to_mp3`, Android platform).
- [x] Add deps: flutter_riverpod, youtube_explode_dart, file_picker, path_provider,
      permission_handler, google_fonts.
- [x] Material 3 theme (light/dark) + Google Fonts.
- [x] Responsive helpers (tablet breakpoint, width-capped content container).
- [x] Core utils: formatters (size/duration/speed/ETA), validators (URL), failures.
- [x] App entry: `ProviderScope` + `MaterialApp` + `HomeScreen`.

## Phase 1 — Link input & preview ✅
- [x] URL field with paste + inline validation.
- [x] `YoutubeService.fetchInfo` → `VideoInfo` (title, author, duration, thumbnail,
      video qualities derived from muxed streams).
- [x] Video preview card (thumbnail, title, author, duration).
- [x] Riverpod controller drives idle → loading → ready stages.

## Phase 2 — MP4 download + progress + save location ✅
- [x] Format selector (MP3/MP4) and quality chips (resolution / bitrate tiers).
- [x] `StorageService` default directory + `file_picker` directory chooser.
- [x] `DownloadService` streams bytes to disk with throttled progress.
- [x] Progress card: bar, %, size, speed, ETA, elapsed.
- [x] Success card (size, time, path) + "Convert another".
- [ ] **Verify on a real device** that an MP4 downloads and plays.

## Phase 3 — True MP3 via ffmpeg ✅
- [x] Add `ffmpeg_kit_flutter_new` (the original `ffmpeg_kit_flutter` was retired in 2025).
- [x] Replace the passthrough in `conversion_service.dart` with an `FFmpegKit.execute`
      call: `-y -i <src> -vn -acodec libmp3lame -ac 2 -b:a <bitrate>k <out.mp3>`.
- [x] Delete the temp source file after a successful encode (and the partial output on failure).
- [x] Quality tiers 320 / 256 / 192 / 128 kbps selectable.
- [ ] Show a distinct "Converting…" sub-stage in the meter during the encode (currently the
      bar rests at 100% while ffmpeg runs).

## Phase 4 — UX polish & settings ⬜
- [ ] Entrance animations (flutter_animate) for cards.
- [ ] Empty/error illustrations and retry button on the error state.
- [ ] Settings: default format, theme mode override, default directory, "open file".
- [ ] Share / open-in sheet for the finished file.
- [ ] App icon + splash screen.

## Phase 5 — Testing & release ⬜
- [ ] Unit tests: validators, formatters, controller state transitions.
- [ ] Widget tests: format/quality selection, progress rendering.
- [ ] Release signing config (replace debug keys).
- [ ] `flutter build apk --release` / `appbundle` and on-device smoke test.

## Backlog / future
- iOS support, playlist download, background download queue, download history,
  in-app preview, dark/light manual toggle persisted to disk.
