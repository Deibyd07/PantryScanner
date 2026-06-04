# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Preserve stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep BroadcastReceivers (needed for RECEIVE_BOOT_COMPLETED + exact alarms)
-keep public class * extends android.content.BroadcastReceiver

# Keep enums (used by Firestore serialization)
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
