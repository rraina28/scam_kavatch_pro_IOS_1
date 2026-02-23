import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {

    namespace = "com.cybrains.scamkavatchpro"

    // OK to use latest compile SDK
    compileSdk = 36

    defaultConfig {

        applicationId = "com.cybrains.scamkavatchpro"

        minSdk = flutter.minSdkVersion

        // MUST be 35 for Play Store approval
        targetSdk = 35

        // Increase versionCode after rejection
        versionCode = 63

        versionName = "1.0.56"

        multiDexEnabled = true
    }

    signingConfigs {

        create("release") {

            keyAlias = keystoreProperties["keyAlias"] as? String ?: ""

            keyPassword = keystoreProperties["keyPassword"] as? String ?: ""

            storeFile = keystoreProperties["storeFile"]?.let {
                file(it as String)
            }

            storePassword = keystoreProperties["storePassword"] as? String ?: ""
        }
    }

    buildTypes {

        release {

            // Required for Play Store optimization
            isMinifyEnabled = true

            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            signingConfig = signingConfigs.getByName("release")
        }

        debug {

            isMinifyEnabled = false
        }
    }

    // ✅ SAFE ADDITION (does not affect existing behavior)
    buildFeatures {
        buildConfig = true
    }

    compileOptions {

        sourceCompatibility = JavaVersion.VERSION_17

        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {

        jvmTarget = "17"
    }
}

flutter {

    source = "../.."
}

dependencies {

    implementation("androidx.multidex:multidex:2.0.1")

    // Recommended for edge-to-edge backward compatibility
    implementation("androidx.activity:activity-ktx:1.9.0")
}
