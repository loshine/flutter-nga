pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")

// flutter_inappwebview_android 1.1.3 uses a default ProGuard file removed in AGP 9.
// Build a patched copy without changing the shared pub cache or plugin sources.
// Remove this workaround once the stable plugin includes upstream fix #2765.
findProject(":flutter_inappwebview_android")?.let { plugin ->
    val original = plugin.projectDir.resolve(plugin.buildFileName).readText()
    val patched = original.replace("proguard-android.txt", "proguard-android-optimize.txt")
    if (patched != original) {
        val patchedDir = file("../build/gradle-compat/flutter_inappwebview_android")
        plugin.projectDir.copyRecursively(patchedDir, overwrite = true)
        val buildFile = patchedDir.resolve(plugin.buildFileName)
        buildFile.writeText(patched)
        plugin.projectDir = patchedDir
    }
}
