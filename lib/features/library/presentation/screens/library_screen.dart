import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;

import '../../../../core/theme/manuscript_theme.dart';
import '../../../../core/theme/mss_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../converter/presentation/providers/theme_provider.dart';
import '../../../converter/presentation/widgets/manuscript/mss_icons.dart';
import '../../../converter/presentation/widgets/manuscript/primitives.dart';
import '../../domain/entities/track.dart';
import '../providers/device_library_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/library_provider.dart';
import '../providers/player_controller.dart';
import '../widgets/album_art.dart';

/// "Your Shelf" — ported from `Player.jsx`'s `LibraryScreen`: a segmented
/// All Tracks / Favourites list of `mss-track` rows, each showing procedural
/// (or real, for device tracks) art, title/channel, format chip, a live
/// equalizer while playing, duration, and a favourite toggle.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _favoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final ManuscriptBinding binding = ref.watch(bindingProvider);
    final MssPalette p = paletteOf(context);
    final List<Track> library = ref.watch(libraryProvider);
    final Set<String> favorites = ref.watch(favoritesProvider);
    final PlaybackState playback = ref.watch(playerControllerProvider);
    final DeviceLibraryState device = ref.watch(deviceLibraryProvider);

    final List<Track> tracks =
        _favoritesOnly ? library.where((Track t) => favorites.contains(t.id)).toList() : library;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MssLabel('The Library', gold: binding.gold),
          const SizedBox(height: 6),
          Text('Your Shelf',
              style: binding.display0(TextStyle(fontSize: 25, letterSpacing: 0.6, color: p.display))),
          const SizedBox(height: 3),
          Text(
            '${library.length} ${library.length == 1 ? 'recording' : 'recordings'} transcribed & bound.',
            style: p.serif(TextStyle(fontSize: 12.5, color: p.muted)),
          ),
          const SizedBox(height: 16),
          _LibraryTabs(
            binding: binding,
            palette: p,
            favoritesOnly: _favoritesOnly,
            onChanged: (bool fav) => setState(() => _favoritesOnly = fav),
          ),
          const SizedBox(height: 8),
          if (device.status == DeviceLibraryStatus.denied ||
              device.status == DeviceLibraryStatus.permanentlyDenied)
            _DevicePermissionCard(binding: binding, palette: p, status: device.status),
          if (tracks.isEmpty)
            _EmptyState(palette: p, favoritesOnly: _favoritesOnly)
          else
            for (final Track track in tracks)
              _TrackRow(
                track: track,
                binding: binding,
                palette: p,
                isCurrent: track.id == playback.currentId,
                playing: playback.playing,
                isFavorite: favorites.contains(track.id),
                onTap: () {
                  ref.read(playerControllerProvider.notifier).playTrack(track.id);
                  ref.read(playerControllerProvider.notifier).openNowPlaying();
                },
                onToggleFav: () => ref.read(favoritesProvider.notifier).toggle(track.id),
              ),
        ],
      ),
    );
  }
}

class _LibraryTabs extends StatelessWidget {
  const _LibraryTabs({
    required this.binding,
    required this.palette,
    required this.favoritesOnly,
    required this.onChanged,
  });

  final ManuscriptBinding binding;
  final MssPalette palette;
  final bool favoritesOnly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final MssPalette p = palette;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.overlay50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.rule(0.2)),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final double w = (c.maxWidth - 8) / 2;
          return Stack(
            children: <Widget>[
              AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: favoritesOnly ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: w,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[binding.accent, binding.accentDeep],
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  _opt('All Tracks', !favoritesOnly, () => onChanged(false)),
                  _opt('Favourites', favoritesOnly, () => onChanged(true)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _opt(String label, bool on, VoidCallback onTap) {
    final Color c = on ? palette.ink : palette.muted;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: SizedBox(
          height: 38,
          child: Center(
            child: Text(label,
                style: GoogleFonts.spectral(
                    textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c))),
          ),
        ),
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.track,
    required this.binding,
    required this.palette,
    required this.isCurrent,
    required this.playing,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFav,
  });

  final Track track;
  final ManuscriptBinding binding;
  final MssPalette palette;
  final bool isCurrent;
  final bool playing;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFav;

  @override
  Widget build(BuildContext context) {
    final MssPalette p = palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 48,
              height: 48,
              child: AlbumArt(track: track, size: 48, radius: 5, gold: binding.gold),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: p.serif(TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isCurrent ? binding.accent : p.text)),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: p.serif(TextStyle(fontSize: 12, color: p.muted)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: p.rule(0.3)),
              ),
              child: Text(
                track.format.name.toUpperCase(),
                style: p.mono(TextStyle(fontSize: 8.5, letterSpacing: 0.5, color: binding.gold)),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 36,
              child: isCurrent && playing
                  ? Align(alignment: Alignment.centerLeft, child: Eq(color: binding.accent))
                  : Text(
                      Formatters.duration(track.duration),
                      style: p.mono(TextStyle(fontSize: 11, color: p.faint)),
                    ),
            ),
            SizedBox(
              width: 30,
              height: 30,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onToggleFav();
                },
                icon: MssIcon(isFavorite ? 'heartFill' : 'heart',
                    size: 17, color: isFavorite ? binding.accent : p.faint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.palette, required this.favoritesOnly});

  final MssPalette palette;
  final bool favoritesOnly;

  @override
  Widget build(BuildContext context) {
    final MssPalette p = palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Column(
        children: <Widget>[
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: p.rule(0.3)),
            ),
            child: Center(
              child: MssIcon(favoritesOnly ? 'heart' : 'libraryTab', size: 24, color: p.faint),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            favoritesOnly ? 'No favourites yet' : 'The shelf stands empty',
            textAlign: TextAlign.center,
            style: p.serif(TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: p.display)),
          ),
          const SizedBox(height: 6),
          Text(
            favoritesOnly
                ? "Tap the heart on any recording to keep it close at hand."
                : 'Transcribe something, or grant access to the music already on your device.',
            textAlign: TextAlign.center,
            style: p.serif(TextStyle(fontSize: 13, color: p.muted, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

/// Manuscript-styled prompt asking for the on-device music permission — shown
/// in the empty/denied state, matching the `mss-empty` cards' restraint.
class _DevicePermissionCard extends ConsumerWidget {
  const _DevicePermissionCard({required this.binding, required this.palette, required this.status});

  final ManuscriptBinding binding;
  final MssPalette palette;
  final DeviceLibraryStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MssPalette p = palette;
    final bool permanentlyDenied = status == DeviceLibraryStatus.permanentlyDenied;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.rule(0.24)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: binding.accentSoft,
              border: Border.all(color: p.rule(0.3)),
            ),
            child: Center(child: MssIcon('music', size: 17, color: binding.accent)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Music on this device',
                    style: p.serif(TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: p.display))),
                const SizedBox(height: 3),
                Text(
                  permanentlyDenied
                      ? 'Access was denied. Grant it from system settings to see it here.'
                      : 'Grant access to fold what’s already on your phone into the shelf.',
                  style: p.serif(TextStyle(fontSize: 11.5, color: p.muted, height: 1.35)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: MssGhostButton(
              label: permanentlyDenied ? 'Settings' : 'Grant',
              palette: p,
              dense: true,
              onPressed: () {
                HapticFeedback.lightImpact();
                if (permanentlyDenied) {
                  openAppSettings();
                } else {
                  ref.read(deviceLibraryProvider.notifier).requestAccess();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
