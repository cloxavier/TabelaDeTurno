# Regras de Proteção Ultra-Garantidas para o Tabela de Turno

# Manter a MainActivity e classes do projeto para garantir o Full Screen Intent
-keep class br.com.xavier.tabela_de_turno.** { *; }

# Flutter Embedding - Essencial para comunicação nativa
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class br.com.xavier.tabela_de_turno.MainActivity { *; }

# Ignorar avisos da Play Store Core (destrava a build R8)
-dontwarn com.google.android.play.core.**

# Flutter Local Notifications - PROTEÇÃO TOTAL para alarmes no modo Release
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
-keep class com.dexterous.flutterlocalnotifications.NotificationService { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver { *; }

# GSON - Crucial para que o Android não "esqueça" os botões e detalhes do alarme
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
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
