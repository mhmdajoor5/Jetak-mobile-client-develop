 ## Flutter 
 -keep class io.flutter.app.** { *; }
 -keep class io.flutter.plugin.** { *; }
 -keep class io.flutter.util.** { *; }
 -keep class io.flutter.view.** { *; }
 -keep class io.flutter.** { *; }
 -keep class io.flutter.plugins.** { *; }
 -keep class com.google.firebase.** { *; }
 -dontwarn io.flutter.embedding.**
 -ignorewarnings

# Retrofit
-keepattributes Signature
-keepattributes Exceptions

# OkHTTP
-dontwarn okhttp3.**
-keep class okhttp3.**{ *; }
-keep interface okhttp3.**{ *; }

# Other
-keepattributes *Annotation*
-keepattributes SourceFile, LineNumberTable

# Logging 
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
    public static *** wtf(...);
}

-assumenosideeffects class io.flutter.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** w(...);
    public static *** e(...);
}

-assumenosideeffects class java.util.logging.Level {
    public static *** w(...);
    public static *** d(...);
    public static *** v(...);
}

-assumenosideeffects class java.util.logging.Logger {
    public static *** w(...);
    public static *** d(...);
    public static *** v(...);
}

# Removes third parties logging
-assumenosideeffects class org.slf4j.Logger {
    public *** trace(...);
    public *** debug(...);
    public *** info(...);
    public *** warn(...);
    public *** error(...);
}

# Intercom ProGuard rules
-keep class io.intercom.android.sdk.** { *; }
-keep class io.intercom.android.sdk.identity.** { *; }
-keep class io.intercom.android.sdk.metrics.** { *; }
-keep class io.intercom.android.sdk.models.** { *; }
-keep class io.intercom.android.sdk.utilities.** { *; }