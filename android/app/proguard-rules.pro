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
-keep class io.intercom.android.sdk.api.** { *; }
-keep class io.intercom.android.sdk.conversation.** { *; }
-keep class io.intercom.android.sdk.overlay.** { *; }
-keep class io.intercom.android.sdk.push.** { *; }
-keep class io.intercom.android.sdk.store.** { *; }
-keep class io.intercom.android.sdk.twig.** { *; }
-keep class io.intercom.android.sdk.views.** { *; }
-keep class io.intercom.android.sdk.blocks.** { *; }
-keep class io.intercom.android.sdk.commons.** { *; }
-keep class io.intercom.android.sdk.compose.** { *; }
-keep class io.intercom.android.sdk.darkmode.** { *; }
-keep class io.intercom.android.sdk.experiments.** { *; }
-keep class io.intercom.android.sdk.featureflags.** { *; }
-keep class io.intercom.android.sdk.gallery.** { *; }
-keep class io.intercom.android.sdk.helpcenter.** { *; }
-keep class io.intercom.android.sdk.home.** { *; }
-keep class io.intercom.android.sdk.inbox.** { *; }
-keep class io.intercom.android.sdk.launcher.** { *; }
-keep class io.intercom.android.sdk.messenger.** { *; }
-keep class io.intercom.android.sdk.navigation.** { *; }
-keep class io.intercom.android.sdk.notifications.** { *; }
-keep class io.intercom.android.sdk.preview.** { *; }
-keep class io.intercom.android.sdk.realtime.** { *; }
-keep class io.intercom.android.sdk.surveys.** { *; }
-keep class io.intercom.android.sdk.tickets.** { *; }
-keep class io.intercom.android.sdk.upload.** { *; }
-keep class io.intercom.android.sdk.voip.** { *; }
-keep class io.intercom.android.sdk.widgets.** { *; }

# Keep Intercom native methods
-keepclassmembers class io.intercom.android.sdk.** {
    native <methods>;
}

# Keep Intercom annotations
-keep @interface io.intercom.android.sdk.** { *; }

# Keep Intercom serialization
-keepclassmembers class io.intercom.android.sdk.** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep Intercom Parcelable implementations
-keep class io.intercom.android.sdk.** implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}