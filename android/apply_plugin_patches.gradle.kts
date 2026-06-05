// Patches image_picker_android dans le cache pub (après flutter pub get / cache repair).
val localAppData = System.getenv("LOCALAPPDATA")
    ?: "${System.getProperty("user.home")}/AppData/Local"
val pubPluginsDir = file("$localAppData/Pub/Cache/hosted/pub.dev")

// 1) Corrige le crash isSystemPickerAvailable$activity_release (versions < 0.8.13+7).
val badPickerCheck =
    "ActivityResultContracts.PickVisualMedia.isSystemPickerAvailable\$activity_release()"
pubPluginsDir.listFiles()?.asSequence()
    ?.filter { it.isDirectory && it.name.startsWith("image_picker_android-") }
    ?.forEach { pluginDir ->
        val utilsFile = pluginDir.resolve(
            "android/src/main/java/io/flutter/plugins/imagepicker/ImagePickerUtils.java",
        )
        if (!utilsFile.exists()) return@forEach
        var text = utilsFile.readText()
        if (!text.contains(badPickerCheck)) return@forEach
        if (!text.contains("android.os.ext.SdkExtensions")) {
            text = text.replace(
                "import android.os.Build;",
                "import android.os.Build;\nimport android.os.ext.SdkExtensions;",
            )
        }
        text = text.replace(
            "    if ($badPickerCheck) {",
            """    if (Build.VERSION.SDK_INT >= 33
        || (Build.VERSION.SDK_INT >= 30
            && SdkExtensions.getExtensionVersion(Build.VERSION_CODES.R) >= 2)) {""",
        )
        if (!text.contains(badPickerCheck)) {
            utilsFile.writeText(text)
            logger.lifecycle("Patched ImagePickerUtils.java in ${pluginDir.name}")
        }
    }

// 2) Corrige image_picker_android 0.8.13+19 : plugin Kotlin manquant (si utilisé avec Dart 3.12+).
val kotlinPatchTarget = file(
    "$localAppData/Pub/Cache/hosted/pub.dev/image_picker_android-0.8.13+19/android/build.gradle.kts",
)
if (kotlinPatchTarget.exists()) {
    val original = kotlinPatchTarget.readText()
    val marker = "org.jetbrains.kotlin.android"
    if (!original.contains(marker)) {
        val patched = original.replace(
            "plugins {\n    id(\"com.android.library\")\n}",
            """
            plugins {
                id("com.android.library")
                id("org.jetbrains.kotlin.android")
            }
            """.trimIndent(),
        )
        if (patched != original) {
            kotlinPatchTarget.writeText(patched)
            logger.lifecycle("Patched image_picker_android 0.8.13+19 build.gradle.kts (Kotlin plugin)")
        }
    }
}
