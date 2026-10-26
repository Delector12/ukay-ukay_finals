plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
}

android {
    namespace "com.example.ecommerce_app"
    compileSdk 34

    defaultConfig {
        applicationId "com.example.ecommerce_app"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0"

        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'),
                          'proguard-rules.pro'
        }
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:1.9.0"
    implementation 'com.google.firebase:firebase-auth:22.3.0'
    implementation 'com.google.firebase:firebase-firestore:25.0.0'
    implementation 'com.google.firebase:firebase-analytics:22.0.0'

    // Flutter dependencies auto‑generated
}
