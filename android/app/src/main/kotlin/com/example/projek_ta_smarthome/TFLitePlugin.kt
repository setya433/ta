package com.example.projek_ta_smarthome

import android.content.res.AssetFileDescriptor
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.flex.FlexDelegate
import java.io.FileInputStream
import java.io.IOException
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel

class TFLitePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var interpreter: Interpreter? = null
    private lateinit var context: android.content.Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "package com.example.projek_ta_smarthome/tflite")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "initInterpreter") {
            try {
                val options = Interpreter.Options()
                val flexDelegate = FlexDelegate()
                options.addDelegate(flexDelegate)
                val interpreter = Interpreter(loadModelFile(), options)
                this.interpreter = interpreter
                result.success("Interpreter initialized successfully")
            } catch (e: Exception) {
                result.error("INIT_FAILED", "Failed to initialize interpreter", e.message)
            }
        } else {
            result.notImplemented()
        }
    }

    @Throws(IOException::class)
    private fun loadModelFile(): MappedByteBuffer {
        val fileDescriptor: AssetFileDescriptor = context.assets.openFd("tes1.tflite")
        val inputStream = FileInputStream(fileDescriptor.fileDescriptor)
        val fileChannel: FileChannel = inputStream.channel
        val startOffset = fileDescriptor.startOffset
        val declaredLength = fileDescriptor.declaredLength
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
    }
}
