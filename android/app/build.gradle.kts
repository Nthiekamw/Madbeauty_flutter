plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.madbeauty.madbeauty"
    // API 31+ requise pour les attributs splash (values-v31). Évite l’erreur
    // « postSplashScreenTheme not found » si flutter.compileSdkVersion est trop bas.
    // stripe_android 12.x exige compileSdk 36.
    compileSdk = maxOf(36, flutter.compileSdkVersion)
    // Doit être installée via SDK Manager (NDK side by side). Alignée avec les plugins Flutter Android courants.
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.madbeauty.madbeauty"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // stripe_android 12.x exige minSdk 23.
        minSdk = maxOf(23, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                val storePassword = keystoreProperties.getProperty("storePassword")?.trim()
                val keyPassword = keystoreProperties.getProperty("keyPassword")?.trim()
                val keyAlias = keystoreProperties.getProperty("keyAlias")?.trim()
                val storeFileName = keystoreProperties.getProperty("storeFile")?.trim()
                require(!storePassword.isNullOrEmpty()) { "storePassword manquant dans key.properties" }
                require(!keyPassword.isNullOrEmpty()) { "keyPassword manquant dans key.properties" }
                require(!keyAlias.isNullOrEmpty()) { "keyAlias manquant dans key.properties" }
                require(!storeFileName.isNullOrEmpty()) { "storeFile manquant dans key.properties" }
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
                storeFile = file(storeFileName)
                this.storePassword = storePassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // image_picker + Stripe CustomerSheet (BackHandler / activity-compose).
    val activityVersion = "1.12.4"
    implementation("androidx.activity:activity:$activityVersion")
    implementation("androidx.activity:activity-ktx:$activityVersion")
    implementation("androidx.activity:activity-compose:$activityVersion")
}
