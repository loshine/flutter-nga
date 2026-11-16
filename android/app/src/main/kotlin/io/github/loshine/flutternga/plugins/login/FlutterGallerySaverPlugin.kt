package io.github.loshine.flutternga.plugins.login

import android.content.ContentValues
import android.content.Context
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import android.webkit.MimeTypeMap
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.net.URL

class FlutterGallerySaverPlugin(private val context: Context) :
    MethodChannel.MethodCallHandler {

    private val job = SupervisorJob()
    private val uiScope = CoroutineScope(Dispatchers.Main + job)

    companion object {
        const val CHANNEL = "io.github.loshine.flutternga.gallery_saver/plugin"

        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            val instance = FlutterGallerySaverPlugin(context)
            // setMethodCallHandler在此通道上接收方法调用的回调
            channel.setMethodCallHandler(instance)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // 通过 MethodCall 可以获取参数和方法名
        when (call.method) {
            "save" -> {
                val url = call.argument<String>("url")
                if (url.isNullOrBlank()) {
                    result.error("INVALID_ARGUMENT", "url is required", null)
                    return
                }
                Log.d("GallerySaver", url)
                uiScope.launch {
                    val success = withContext(Dispatchers.IO) {
                        try {
                            val fileUrl = URL(url)
                            val extension = MimeTypeMap.getFileExtensionFromUrl(url)
                                .takeIf { it.isNotBlank() }
                            val mime = extension?.let {
                                MimeTypeMap.getSingleton().getMimeTypeFromExtension(it)
                            }
                            val byteArray = fileUrl.openStream().use { it.readBytes() }
                            save2Album(
                                byteArray,
                                "NationalGayAlliance",
                                extension,
                                mime
                            )
                        } catch (e: Exception) {
                            Log.e("GallerySaver", "Failed to download or save image", e)
                            false
                        }
                    }
                    result.success(success)
                }
            }
            else -> result.notImplemented()
        }
    }

    /**
     * @param src     Image bytes.
     * @param dirName Target subdirectory name under Pictures.
     * @param suffix  File extension without dot.
     * @param mime    MIME type.
     * @return true if saved successfully, false otherwise.
     */
    private fun save2Album(
        src: ByteArray,
        dirName: String?,
        suffix: String?,
        mime: String?
    ): Boolean {
        val safeDirName = if (dirName.isNullOrEmpty()) context.packageName else dirName
        val realSuffix = suffix?.takeIf { it.isNotBlank() } ?: "jpg"
        val fileName = "${System.currentTimeMillis()}.$realSuffix"
        return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            val picDir = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES)
                ?: return false
            val destFile = File(picDir, "$safeDirName/$fileName")
            try {
                destFile.parentFile?.mkdirs()
                destFile.writeBytes(src)
                MediaScannerConnection.scanFile(
                    context, arrayOf(destFile.absolutePath), null, null
                )
                true
            } catch (e: Exception) {
                Log.e("GallerySaver", "Failed to save image to file", e)
                false
            }
        } else {
            val contentValues = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
                put(MediaStore.Images.Media.MIME_TYPE, mime ?: "image/*")
                put(
                    MediaStore.Images.Media.RELATIVE_PATH,
                    "${Environment.DIRECTORY_PICTURES}/$safeDirName"
                )
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val contentUri =
                if (Environment.getExternalStorageState() == Environment.MEDIA_MOUNTED) {
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI
                } else {
                    MediaStore.Images.Media.INTERNAL_CONTENT_URI
                }
            val uri = context.contentResolver.insert(contentUri, contentValues)
                ?: return false
            try {
                val outputStream = context.contentResolver.openOutputStream(uri)
                if (outputStream == null) {
                    context.contentResolver.delete(uri, null, null)
                    return false
                }
                outputStream.use { it.write(src) }
                contentValues.clear()
                contentValues.put(MediaStore.MediaColumns.IS_PENDING, 0)
                context.contentResolver.update(uri, contentValues, null, null)
                true
            } catch (e: Exception) {
                context.contentResolver.delete(uri, null, null)
                Log.e("GallerySaver", "Failed to save image to MediaStore", e)
                false
            }
        }
    }
}
