package io.github.loshine.flutternga.plugins.login

import android.Manifest
import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.text.TextUtils
import android.util.Log
import android.webkit.MimeTypeMap
import com.blankj.utilcode.util.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.File
import java.io.IOException
import java.io.OutputStream
import java.net.URL

class FlutterGallerySaverPlugin : MethodChannel.MethodCallHandler {

    private val job = Job()
    private val uiScope = CoroutineScope(Dispatchers.Main + job)

    companion object {
        const val CHANNEL = "io.github.loshine.flutternga.gallery_saver/plugin"

        fun registerWith(flutterEngine: FlutterEngine) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            val instance = FlutterGallerySaverPlugin()
            // setMethodCallHandler在此通道上接收方法调用的回调
            channel.setMethodCallHandler(instance)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // 通过 MethodCall 可以获取参数和方法名
        when (call.method) {
            "save" -> {
                val url = call.argument<String>("url") ?: return
                LogUtils.d(url)
                uiScope.launch {
                    val success = async(Dispatchers.IO) {
                        val fileUrl = URL(url)
                        val extension = MimeTypeMap.getFileExtensionFromUrl(url)
                        val mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
                        val byteArray = ConvertUtils.inputStream2Bytes(fileUrl.openStream())
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
        val safeDirName = if (TextUtils.isEmpty(dirName)) Utils.getApp().packageName else dirName!!
        val realSuffix = suffix ?: "JPG"
        val fileName = System.currentTimeMillis().toString() + "." + realSuffix
        return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            if (!PermissionUtils.isGranted(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                Log.e("ImageUtils", "save to album need storage permission")
                return null
            }
            val picDir = Utils.getApp().getExternalFilesDir(Environment.DIRECTORY_PICTURES)
            val destFile = File(picDir, "$safeDirName/$fileName")
            if (!FileIOUtils.writeFileFromBytesByChannel(destFile, src, true)) {
                return null
            }
            FileUtils.notifySystemToScan(destFile)
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
            val uri = Utils.getApp().contentResolver.insert(contentUri, contentValues)
                ?: return null
            var os: OutputStream? = null
            try {
                os = Utils.getApp().contentResolver.openOutputStream(uri)
                os?.write(src)
                contentValues.clear()
                contentValues.put(MediaStore.MediaColumns.IS_PENDING, 0)
                Utils.getApp().contentResolver.update(uri, contentValues, null, null)
                UriUtils.uri2File(uri)
            } catch (e: Exception) {
                Utils.getApp().contentResolver.delete(uri, null, null)
                e.printStackTrace()
                null
            } finally {
                try {
                    os?.close()
                } catch (e: IOException) {
                    e.printStackTrace()
                }
            }
        }
    }
}
