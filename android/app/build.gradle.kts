plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties

val keyProperties = Properties().apply {
    val propertiesFile = rootProject.file("key.properties")
    if (propertiesFile.isFile) {
        propertiesFile.inputStream().use { load(it) }
    }
}
val releaseStorePath = keyProperties.getProperty("storeFile")
    ?.trim()?.takeIf { it.isNotEmpty() }

android {
    namespace = "io.github.loshine.flutternga"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "io.github.loshine.flutternga"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseStorePath != null) {
            create("release") {
                fun signingProperty(name: String): String =
                    keyProperties.getProperty(name)?.takeIf { it.isNotEmpty() }
                        ?: throw GradleException("请在 android/key.properties 中填写 $name")

                storeFile = rootProject.file(releaseStorePath).also {
                    require(it.isFile) { "storeFile 指定的 keystore 文件不存在" }
                }
                storePassword = signingProperty("storePassword")
                keyAlias = signingProperty("keyAlias")
                keyPassword = signingProperty("keyPassword")
            }
        }
    }

    buildTypes {
        // minify / shrinkResources / proguard-android-optimize.txt 由 Flutter Gradle 插件在 release 下自动开启，
        // 插件与 AndroidX 依赖各自携带 consumer rules，无需额外的 proguard-rules.pro。
        release {
            signingConfig = signingConfigs.findByName("release")
                ?: signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
