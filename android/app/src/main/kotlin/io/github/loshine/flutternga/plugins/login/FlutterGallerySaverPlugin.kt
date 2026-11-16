package io.github.loshine.flutternga.plugins.login

import android.Manifest
import android.content.ContentResolver
import android.content.ContentValues
import android.content.Context
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import android.webkit.MimeTypeMap
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.File
import java.net.URL

class FlutterGallerySaverPlugin(private val context: Context) :
    MethodChannel.MethodCallHandler {

    private val job = Job()
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
                val url = call.argument<String>("url") ?: return
                Log.d("GallerySaver", url)
                uiScope.launch {
                    val success = async(Dispatchers.IO) {
                        val fileUrl = URL(url)
                        val extension = MimeTypeMap.getFileExtensionFromUrl(url)
                        val mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
                        val byteArray = fileUrl.openStream().use { it.readBytes() }
                        val file = save2Album(
                            byteArray,
                            "NationalGayAlliance",
                            extension,
                            mime
                        )
                        file != null
                    }
                    result.success(success.await())
                }
            }
            else -> result.notImplemented()
        }
    }

    /**
     * @param src     The source of bitmap.
     * @param dirName The name of directory.
     * small size, 100 meaning compress for max quality. Some
     * formats, like PNG which is lossless, will ignore the
     * quality setting
     * @param suffix The file suffix
     * @param mime The file mime
     * @return the file if save success, otherwise return null.
     */
    private fun save2Album(
        src: ByteArray,
        dirName: String?,
        suffix: String?,
        mime: String?
    ): File? {
        val safeDirName = if (dirName.isNullOrEmpty()) context.packageName else dirName
        val realSuffix = suffix ?: "JPG"
        val fileName = System.currentTimeMillis().toString() + "." + realSuffix
        return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            if (context.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED
            ) {
                Log.e("ImageUtils", "save to album need storage permission")
                return null
            }
            val picDir = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES)
                ?: return null
            val destFile = File(picDir, "$safeDirName/$fileName")
            try {
                destFile.parentFile?.mkdirs()
                destFile.writeBytes(src)
            } catch (e: Exception) {
                return null
            }
            MediaScannerConnection.scanFile(
                context, arrayOf(destFile.absolutePath), null, null
            )
            destFile
        } else {
            val contentValues = ContentValues()
            contentValues.put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
            contentValues.put(MediaStore.Images.Media.MIME_TYPE, mime ?: "image/*")
            val contentUri: Uri =
                if (Environment.getExternalStorageState() == Environment.MEDIA_MOUNTED) {
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI
                } else {
                    MediaStore.Images.Media.INTERNAL_CONTENT_URI
                }
            contentValues.put(
                MediaStore.Images.Media.RELATIVE_PATH,
                Environment.DIRECTORY_PICTURES + "/" + safeDirName
            )
            contentValues.put(MediaStore.MediaColumns.IS_PENDING, 1)
            val uri = context.contentResolver.insert(contentUri, contentValues)
                ?: return null
            try {
                context.contentResolver.openOutputStream(uri)?.use { it.write(src) }
                contentValues.clear()
                contentValues.put(MediaStore.MediaColumns.IS_PENDING, 0)
                context.contentResolver.update(uri, contentValues, null, null)
                uri2File(uri)
            } catch (e: Exception) {
                context.contentResolver.delete(uri, null, null)
                e.printStackTrace()
                null
            }
        }
    }

    private fun uri2File(uri: Uri): File? {
        if (ContentResolver.SCHEME_FILE == uri.scheme) {
            return uri.path?.let(::File)
        }
        if (ContentResolver.SCHEME_CONTENT != uri.scheme) {
            return null
        }
        return try {
            context.contentResolver.query(
                uri, arrayOf(MediaStore.MediaColumns.DATA), null, null, null
            )?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val index = cursor.getColumnIndex(MediaStore.MediaColumns.DATA)
                    if (index >= 0) cursor.getString(index)?.let(::File) else null
                } else {
                    null
                }
            }
        } catch (e: Exception) {
            null
        }
    }
}
