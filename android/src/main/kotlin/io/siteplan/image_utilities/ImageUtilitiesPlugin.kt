package io.siteplan.image_utilities

import androidx.annotation.NonNull

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ThumbnailUtils
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.FileOutputStream
import java.io.FileNotFoundException
import java.io.IOException

/** ImageUtilitiesPlugin */
class ImageUtilitiesPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "image_utilities")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "generateThumbnail" -> generateThumbnail(call, result)
      "rotate" -> rotate(call, result)
      else -> result.notImplemented()
    }
  }

  /** 
    * Generates a thumbnail for an image, centered, with a given maximum size.
    *
    * @param call The method call
    * @param result The method result
    *
    * @return void
  */
  private fun generateThumbnail(call: MethodCall, result: Result) {
    // Get arguments
    val args = call.arguments as Map<String, Any>
    val imagePath = args["imagePath"] as String
    val targetPath = args["targetPath"] as String
    val maxSize = args["maxSize"] as Int
    val format = args["format"] as Int

    // Decode image
    val bitmap = BitmapFactory.decodeFile(imagePath)
    val width = bitmap.width
    val height = bitmap.height

    // Calculate new dimensions
    var newWidth = width
    var newHeight = height

    val shouldResize = width > maxSize || height > maxSize

    if (shouldResize) {
      val ratio = width.toFloat() / height.toFloat()
      newWidth = if (ratio > 1) maxSize else (maxSize * ratio).toInt()
      newHeight = if (ratio > 1) (maxSize / ratio).toInt() else maxSize
    }

    // Generate the thumbnail
    val thumbnail = ThumbnailUtils.extractThumbnail(bitmap, newWidth, newHeight)
    
    try {
      // Create a file to write the thumbnail to
      val resizedImage = File(targetPath)

      // Compress the thumbnail to the target format and save it
      val outputFile = FileOutputStream(resizedImage)
      when (format) {
          0 -> thumbnail.compress(Bitmap.CompressFormat.JPEG, 100, outputFile)
          1 -> thumbnail.compress(Bitmap.CompressFormat.PNG, 100, outputFile)
      }
      outputFile.close()
    } catch (error: FileNotFoundException) {
      result.error("FileNotFoundException", "File creating file", error.message)
    } catch (error: IOException) {
      result.error("IOException", "Error writing file", error.message)
    }

    result.success(null)
  }

  /** 
    * Rotates an image by a given number of degrees.
    *
    * @param call The method call
    * @param result The method result
    *
    * @return void
  */
  private fun rotate(call: MethodCall, result: Result) {
    // Get arguments
    val args = call.arguments as Map<String, Any>
    val imagePath = args["imagePath"] as String
    val targetPath = args["targetPath"] as String
    val degrees = args["degrees"] as Int
    val format = args["format"] as Int

    // Decode image
    val bitmap = BitmapFactory.decodeFile(imagePath)
    val width = bitmap.width
    val height = bitmap.height

    // Rotate the image
    val matrix = Matrix()
    matrix.postRotate(degrees.toFloat())
    val rotatedBitmap = Bitmap.createBitmap(bitmap, 0, 0, width, height, matrix, true)

    try {
      // Create a file to write the rotated image to
      val rotatedImage = File(targetPath)

      // Compress the thumbnail to the target format and save it
      val outputFile = FileOutputStream(rotatedImage)
      when (format) {
        0 -> rotatedBitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputFile)
        1 -> rotatedBitmap.compress(Bitmap.CompressFormat.PNG, 100, outputFile)
      }
      outputFile.close()
    } catch (error: FileNotFoundException) {
      result.error("FileNotFoundException", "File creating file", error.message)
    } catch (error: IOException) {
      result.error("IOException", "Error writing file", error.message)
    }

    result.success(null)
  }
}
