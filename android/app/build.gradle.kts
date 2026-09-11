plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.nirvana.study.nawaz"

    // Required by flutter_secure_storage 11.0.0
    compileSdk = 37

    ndkVersion = "28.2.13676358"

    defaultConfig {
        applicationId = "com.nirvana.study.nawaz"

        minSdk = flutter.minSdkVersion

        // You can also use 37 here
        targetSdk = 37

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}