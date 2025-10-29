# Flutter R8/ProGuard rules for shared_preferences plugin
# Fixes the "Unable to establish connection on channel" error in release builds
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class dev.flutter.pigeon.shared_preferences_android.** { *; }