plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.tkbk"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion // Use Flutter's NDK version
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.thatea.tkbk"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file("upload-keystore.jks") // Ensure this matches the filename you just created
            storePassword = "Thatea_Roing2025" // Replace with the password you just set
            keyAlias = "upload"                     // This should be "upload"
            keyPassword = "Thatea_Roing2025" // Replace with the same password (or your key password if different)
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true // It's good practice to enable minification for release
            isShrinkResources = true // Recommended if minifyEnabled is true
        }
    }
}

flutter {
    source = "../.."
}