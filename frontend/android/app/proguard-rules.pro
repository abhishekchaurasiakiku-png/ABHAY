# ProGuard / R8 keep rules for SafeHer-AI Flutter Release build

# TensorFlow Lite keep rules
-dontwarn org.tensorflow.lite.**
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.gpu.**
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options

# Firebase & Plugins keep rules
-dontwarn com.google.firebase.**
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
