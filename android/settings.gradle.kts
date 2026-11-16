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
    id("com.android.application") version "9.5.1" apply false
    // builtInKotlin 下不再 apply 该插件，此处仅用于把 KGP / Kotlin 编译器锁定到 2.4.21；
    // 删除后会回落到 AGP 内置的 KGP 版本（AGP 9.5.1 为 2.4.10），app 与所有插件模块都会受影响。
    id("org.jetbrains.kotlin.android") version "2.4.21" apply false
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
