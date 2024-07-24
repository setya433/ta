# Add your ProGuard rules here
# You can uncomment the following lines to keep the application class and fields/methods referenced in the manifest
# -keep class * extends android.app.Application {
#     <init>();
# }
# -keep public class * extends android.app.Activity
# -keep public class * extends android.app.Service
# -keep public class * extends android.content.BroadcastReceiver
# -keep public class * extends android.content.ContentProvider
# -keep public class com.example.projek_ta_smarthome.** { *; }

# TensorFlow Lite rules (example, may need adjustment)
-keep class org.tensorflow.** { *; }
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.**

# Additional rules for Flex Delegate
-keep class org.tensorflow.lite.flex.** { *; }
-dontwarn org.tensorflow.lite.flex.**
