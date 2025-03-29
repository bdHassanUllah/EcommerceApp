import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
}

android {
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.e_commerce_app"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    val keystorePropertiesFile = rootProject.file("gradle.properties")
    val keystoreProperties = Properties()

    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties["KEYSTORE_FILE"] ?: "release-key.jks")
            storePassword = keystoreProperties["KEYSTORE_PASSWORD"] as String?
            keyAlias = keystoreProperties["KEY_ALIAS"] as String?
            keyPassword = keystoreProperties["KEY_PASSWORD"] as String?
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.10.1")
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.0")
}
