# Regras de Proteção para o Tabela de Turno

# Manter a MainActivity e classes do projeto para garantir o Full Screen Intent
-keep class br.com.xavier.tabela_de_turno.** { *; }

# Flutter Embedding - Essencial para comunicação nativa
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class br.com.xavier.tabela_de_turno.MainActivity { *; }

# Ignorar avisos da Play Store Core (destrava a build R8)
-dontwarn com.google.android.play.core.**

# Flutter Local Notifications - Essencial para que o alarme toque no modo Release
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }

# Receive Sharing Intent - Essencial para a importação direta via WhatsApp
-keep class com.wish.receive_sharing_intent.** { *; }

# GSON - Essencial para a serialização dos alarmes em modo Release
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.TypeToken
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Manter classes nativas do Android que podem ser chamadas via reflexão
-keep class android.app.Service { *; }
-keep class android.content.BroadcastReceiver { *; }
-keep class android.content.Context { *; }

# Evitar que o R8 remova metadados necessários para o Flutter
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
