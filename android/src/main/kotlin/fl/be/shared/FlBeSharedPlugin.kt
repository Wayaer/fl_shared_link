package fl.be.shared


import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.io.*


/** FlBeSharedPlugin */
class FlBeSharedPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var binding: ActivityPluginBinding? = null
    private var intent: Intent? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "fl_be_shared")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getIntent" -> {
                result.success(intent?.map);
            }
            "getReceiveData" -> {
                val type = intent?.type
                val action = intent?.action
                if (type == null || Intent.ACTION_VIEW != action && Intent.ACTION_SEND != action) {
                    result.success(null)
                } else {
                    result.success(intent?.map)
                }
            }
            "getRealFilePath" -> result.success(getRealFilePath(Uri.parse(call.arguments as String)))
            "getRealFilePathCompatibleWXQQ" -> result.success(
                getRealFilePathCompatibleWXQQ(
                    Uri.parse(
                        call.arguments as String
                    )
                )
            )
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        binding.addOnNewIntentListener(onNewIntent)
        binding.activity.intent?.let { handlerIntent(it) }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.binding = binding
        binding.addOnNewIntentListener(onNewIntent)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        binding!!.removeOnNewIntentListener(onNewIntent)
        binding = null
    }


    override fun onDetachedFromActivity() {
        binding!!.removeOnNewIntentListener(onNewIntent)
        binding = null
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    private fun handlerIntent(intent: Intent) {
        this.intent = intent
        channel.invokeMethod("onIntent", this.intent?.map)
        val type = intent.type
        val action = intent.action
        if (type == null || Intent.ACTION_VIEW != action && Intent.ACTION_SEND != action) {
            channel.invokeMethod("onReceiveShared", this.intent?.map)
        }
    }

    private var onNewIntent: PluginRegistry.NewIntentListener =
        PluginRegistry.NewIntentListener { intent ->
            handlerIntent(intent)
            true
        }

    private val Intent.map: Map<String, String?>
        get() = mapOf(
            "action" to action,
            "type" to type,
            "data" to data?.path,
            "dataString" to dataString,
            "scheme" to scheme,
            "extras" to extras?.map,
        ) as HashMap<String, String?>

    private val Bundle.map: HashMap<String, String?>
        get() {
            val keySet = keySet()
            val map = HashMap<String, String?>()
            for (key in keySet) {
                map[key] = get(key).toString()
            }
            return map
        }


    private fun getRealFilePath(uri: Uri?): String? {
        if (null == uri) return null
        val scheme = uri.scheme
        var data: String? = null
        if (scheme == null) data = uri.path else if (ContentResolver.SCHEME_FILE == scheme) {
            data = uri.path
        } else if (ContentResolver.SCHEME_CONTENT == scheme) {
            val cursor = context.contentResolver.query(
                uri, arrayOf(MediaStore.Images.ImageColumns.DATA), null, null, null
            )
            if (null != cursor) {
                if (cursor.moveToFirst()) {
                    val index = cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA)
                    if (index > -1) {
                        data = cursor.getString(index)
                    }
                }
                cursor.close()
            }
        }
        return data
    }

    private fun getRealFilePathCompatibleWXQQ(uri: Uri?): String? {
        return if (uri == null) {
            null
        } else when (uri.scheme) {
            ContentResolver.SCHEME_CONTENT -> //Android7.0之后的uri content:// URI
                getFilePathFromContentUri(uri)
            ContentResolver.SCHEME_FILE -> //Android7.0之前的uri file://
                uri.path?.let { File(it).absolutePath }
            else -> uri.path?.let { File(it).absolutePath }
        }
    }

    /**
     * 从uri获取path
     *
     * @param uri content://media/external/file/109009
     *
     * FileProvider适配
     * content://com.tencent.mobileqq.fileprovider/external_files/storage/emulated/0/Tencent/QQfile_recv/
     * content://com.tencent.mm.external.fileprovider/external/tencent/MicroMsg/Download/
     */
    private fun getFilePathFromContentUri(uri: Uri?): String? {
        if (null == uri) return null
        var data: String? = null
        val filePathColumn =
            arrayOf(MediaStore.MediaColumns.DATA, MediaStore.MediaColumns.DISPLAY_NAME)
        val cursor: Cursor? = context.contentResolver.query(uri, filePathColumn, null, null, null)
        if (null != cursor) {
            if (cursor.moveToFirst()) {
                val index: Int = cursor.getColumnIndex(MediaStore.MediaColumns.DATA)
                data = if (index > -1) {
                    cursor.getString(index)
                } else {
                    val nameIndex: Int = cursor.getColumnIndex(MediaStore.MediaColumns.DISPLAY_NAME)
                    val fileName: String = cursor.getString(nameIndex)
                    getPathFromInputStreamUri(uri, fileName)
                }
            }
            cursor.close()
        }
        return data
    }

    /**
     * 用流拷贝文件一份到自己APP私有目录下
     *
     * @param uri
     * @param fileName
     */
    private fun getPathFromInputStreamUri(uri: Uri, fileName: String): String? {
        var inputStream: InputStream? = null
        var filePath: String? = null
        if (uri.authority != null) {
            try {
                inputStream = context.contentResolver.openInputStream(uri)
                val file: File? = createTemporalFileFrom(inputStream, fileName)
                filePath = file?.path
            } catch (_: Exception) {
            } finally {
                inputStream?.close()
            }
        }
        return filePath
    }

    private fun createTemporalFileFrom(inputStream: InputStream?, fileName: String): File? {
        var targetFile: File? = null
        if (inputStream != null) {
            var read: Int
            val buffer = ByteArray(8 * 1024)
            targetFile = File(context.externalCacheDir, fileName)
            if (targetFile.exists()) {
                targetFile.delete()
            }
            val outputStream: OutputStream = FileOutputStream(targetFile)
            while (inputStream.read(buffer).also { read = it } != -1) {
                outputStream.write(buffer, 0, read)
            }
            outputStream.flush()
            try {
                outputStream.close()
            } catch (e: IOException) {
                e.printStackTrace()
            }
        }
        return targetFile
    }
}
