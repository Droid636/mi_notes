
-keepattributes Signature


-keep class com.dexterous.flutterlocalnotifications.** { *; }


-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }


-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }


-keep class com.example.mi_notes.models.** { *; }


-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
 
-dontwarn com.google.gson.**
-dontwarn com.dexterous.flutterlocalnotifications.**
-dontwarn com.google.firebase.**
