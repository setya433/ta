package com.example.projek_ta_smarthome

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.flex.FlexDelegate
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel
import android.content.res.AssetFileDescriptor
import java.io.FileInputStream
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.projek_ta_smarthome/tflite"
    private lateinit var interpreter: Interpreter

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "initInterpreter") {
                try {
                    val options = Interpreter.Options()
                    val flexDelegate = FlexDelegate()
                    options.addDelegate(flexDelegate)
                    interpreter = Interpreter(loadModelFile(), options)
                    result.success("Interpreter initialized successfully")
                } catch (e: Exception) {
                    result.error("INIT_FAILED", "Failed to initialize interpreter", e.message)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun loadModelFile(): MappedByteBuffer {
        val fileDescriptor: AssetFileDescriptor = assets.openFd("tes1.tflite")
        val inputStream = FileInputStream(fileDescriptor.fileDescriptor)
        val fileChannel: FileChannel = inputStream.channel
        val startOffset: Long = fileDescriptor.startOffset
        val declaredLength: Long = fileDescriptor.declaredLength
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
    }
}
