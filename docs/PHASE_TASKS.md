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

## Phase 3 — True MP3 via ffmpeg ⬜
- [ ] Add `ffmpeg_kit_flutter_new` (the original `ffmpeg_kit_flutter` was retired in 2025).
- [ ] Replace the passthrough in `conversion_service.dart` with an `FFmpegKit.execute`
      call: `-y -i <src> -vn -ac 2 -b:a <bitrate>k <out.mp3>`.
- [ ] Delete the temp source file after a successful encode.
- [ ] Show a separate "Converting…" sub-stage in the progress card during encode.
- [ ] Test 128 / 192 / 320 kbps outputs.

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
