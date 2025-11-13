# ===============================
# Flutter + Firebase + Local Notifications
# ===============================

# Mantener atributos de firma para genéricos
-keepattributes Signature

# ===============================
# flutter_local_notifications
# ===============================
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# ===============================
# Gson / JSON parsing
# ===============================
-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }

# ===============================
# Firebase
# ===============================
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# ===============================
# Tus modelos (si usas serialización con JSON)
# ===============================
-keep class com.example.mi_notes.models.** { *; }

# ===============================
# Evitar eliminar clases y métodos usados por reflection
# ===============================
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ===============================
# Opcional: evita warnings
# ===============================
-dontwarn com.google.gson.**
-dontwarn com.dexterous.flutterlocalnotifications.**
-dontwarn com.google.firebase.**
