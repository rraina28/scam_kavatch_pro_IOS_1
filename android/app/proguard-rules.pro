# Suppress R8 errors for missing Play Core classes
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Keep Flutter internal classes from being stripped
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }