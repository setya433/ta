package com.example.projek_ta_smarthome;

import android.content.res.AssetFileDescriptor;
import android.content.Context;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import org.tensorflow.lite.Interpreter;
import org.tensorflow.lite.flex.FlexDelegate;

import java.io.FileInputStream;
import java.io.IOException;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import android.util.Log;

public class MyTFLitePlugin implements FlutterPlugin, MethodCallHandler {
    private static final String TAG = "MyTFLitePlugin";
    private MethodChannel channel;
    private Interpreter interpreter;
    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.example.projek_ta_smarthome/tflite");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("initInterpreter")) {
        try {
            Interpreter.Options options = new Interpreter.Options();
            FlexDelegate flexDelegate = new FlexDelegate();
            options.addDelegate(flexDelegate);
            interpreter = new Interpreter(loadModelFile(), options);
            result.success("Interpreter initialized successfully");
            Log.d(TAG, "Interpreter initialized successfully");
        } catch (Exception e) {
            Log.e(TAG, "Failed to initialize interpreter: " + e.getMessage(), e);
            result.error("INIT_FAILED", "Failed to initialize interpreter", e.getMessage());
        }
    }else {
        result.notImplemented();
    }
}



    private MappedByteBuffer loadModelFile() throws IOException {
        Log.d(TAG, "Loading model file");
        AssetFileDescriptor fileDescriptor = context.getAssets().openFd("tes1.tflite");
        FileInputStream inputStream = new FileInputStream(fileDescriptor.getFileDescriptor());
        FileChannel fileChannel = inputStream.getChannel();
        long startOffset = fileDescriptor.getStartOffset();
        long declaredLength = fileDescriptor.getDeclaredLength();
        MappedByteBuffer mappedByteBuffer = fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength);
        Log.d(TAG, "Model file loaded successfully");
        return mappedByteBuffer;
    }
}
