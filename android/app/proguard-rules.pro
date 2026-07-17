# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Razorpay
-keepattributes *Annotation*
-dontwarn proguard.**
-keep class com.razorpay.** { *; }
-keep public class * extends android.app.Activity
-optimizations !method/inlining/*

# Firebase / FCM
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Kotlin coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembers class kotlinx.coroutines.** { volatile <fields>; }

# Hive
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }
-keep class hive.** { *; }

# Webview / KYC
-keep class android.webkit.** { *; }
-keep class com.digio.** { *; }

# Keep R8 from stripping data classes used in JSON
-keepclassmembers class * { @com.google.gson.annotations.SerializedName <fields>; }
