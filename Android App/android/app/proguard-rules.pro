# Keep Flutter classes
-keep class io.flutter.** { *; }

# WebView-related rules
-keep class android.webkit.** { *; }
-keep public class * extends android.webkit.WebViewClient
-keep public class * extends android.webkit.WebChromeClient
-keep class com.google.android.play.core.** { *; }

# Prevent obfuscation for dependencies (replace with your actual libraries)
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn com.google.android.play.core.**


# Prevent stripping of logging
-assumenosideeffects class android.util.Log {
    public static int d(...);
    public static int w(...);
    public static int e(...);
}
