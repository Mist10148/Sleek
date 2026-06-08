# R8 strips io.flutter.plugins.GeneratedPluginRegistrant (and other Flutter
# embedding/plugin classes looked up via reflection or JNI at runtime), which
# breaks every platform channel in release builds — keep the whole tree.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# just_audio / on_audio_query_pluse load their platform implementations and
# query MediaStore via reflection — keep their classes intact.
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.lucasjosino.on_audio_query.** { *; }

# ffmpeg_kit_flutter_new's native libs (libffmpegkit_abidetect.so etc.) resolve
# Java classes in this package via JNI FindClass using hardcoded names at
# JNI_OnLoad time. If R8 renames/strips them, JNI_OnLoad can't find its Java
# side and returns an invalid version (0), throwing UnsatisfiedLinkError out of
# FFmpegKitConfig's static initializer — which aborts GeneratedPluginRegistrant
# mid-registration and breaks every plugin channel registered after it.
-keep class com.antonkarpenko.ffmpegkit.** { *; }

# Flutter's embedding references Play Core split-install APIs for deferred
# components (dynamic feature modules). This app doesn't use them, so the
# classes aren't on the classpath — silence R8's missing-class errors for them.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
