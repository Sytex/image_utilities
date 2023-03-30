import Flutter
import UIKit

public class ImageUtilitiesPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "image_utilities", binaryMessenger: registrar.messenger())
    let instance = ImageUtilitiesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Switch on call to check which method is being called
    switch call.method {
      case "generateThumbnail":
        generateThumbnail(call, result: result)
      case "rotate":
        rotate(call, result: result)
      default:
        result(FlutterMethodNotImplemented)
    }
  }

  /// Generates a thumbnail for an image, centered, with a given maximum size.
  private func generateThumbnail(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Get the arguments from the call
    let args = call.arguments as! [String: Any]
    let imagePath = args["imagePath"] as! String
    let targetPath = args["targetPath"] as! String
    let maxSize = args["maxSize"] as! CGFloat
    let format = args["format"] as! Int
    
    // Load the image from the path
    let image = UIImage(contentsOfFile: imagePath)

    // If the image does not exist, return an error
    if (image == nil) {
      result(
        FlutterError(
          code: "Image not found", 
          message: "The image at the specified path (\(imagePath)) could not be found.", 
          details: nil
        )
      )
      return
    }

    let width = image!.size.width
    let height = image!.size.height

    // Calculate the new size
    var newWidth = width
    var newHeight = height

    let shouldResize = width > maxSize || height > maxSize

    if (shouldResize) {
      let ratio = width / height
      newWidth = ratio > 1.0 ? maxSize : (maxSize * ratio).rounded(.up)
      newHeight = ratio > 1.0 ?  (maxSize / ratio).rounded(.up) : maxSize
    }

    // Create a new image context
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))

    // Draw the image in the new context
    image!.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

    // Get the new image from the context
    let newImage = UIGraphicsGetImageFromCurrentImageContext()

    // If new image is nil, return an error
    if (newImage == nil) {
      result(
        FlutterError(
          code: "Image context not found", 
          message: "The image context could not be found.",
          details: nil
        )
      )
      return
    }

    // End the context
    UIGraphicsEndImageContext()

    // Save the image to the target path, using the specified format (0 is JPEG and 1 is PNG)
    let data = format == 0 ? newImage!.jpegData(compressionQuality: 1.0) : newImage!.pngData()
    try! data!.write(to: URL(fileURLWithPath: targetPath))

    result(nil)
  }

  /// Rotates an image by a given number of degrees.
  private func rotate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Get the arguments from the call
    let args = call.arguments as! [String: Any]
    let imagePath = args["imagePath"] as! String
    let targetPath = args["targetPath"] as! String
    let degrees = args["degrees"] as! Int
    let format = args["format"] as! Int

    // Load the image from the path
    let image = UIImage(contentsOfFile: imagePath)

    // If the image does not exist, return an error
    if (image == nil) {
      result(
        FlutterError(
          code: "Image not found", 
          message: "The image at the specified path (\(imagePath)) could not be found.", 
          details: nil
        )
      )
      return
    }

    // Calculate the new size
    let radians = CGFloat(degrees) * CGFloat.pi / 180.0
    let rotatedSize = CGRect(origin: .zero, size: image!.size).applying(
      CGAffineTransform(rotationAngle: radians)).size

    // Create a new image context
    UIGraphicsBeginImageContext(rotatedSize)

    // Draw the image in the new context
    let context = UIGraphicsGetCurrentContext()!
    context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
    context.rotate(by: radians)
    let rect = CGRect(
      x: -image!.size.width / 2, 
      y: -image!.size.height / 2, 
      width: image!.size.width, 
      height: image!.size.height
    )
    image!.draw(in: rect)

    // Get the new image from the context
    let newImage = UIGraphicsGetImageFromCurrentImageContext()

    // If new image is nil, return an error
    if (newImage == nil) {
      result(
        FlutterError(
          code: "Image context not found", 
          message: "The image context could not be found.",
          details: nil
        )
      )
      return
    }

    // End the context
    UIGraphicsEndImageContext()

    // Save the image to the target path, using the specified format (0 is JPEG and 1 is PNG)
    let data = format == 0 ? newImage!.jpegData(compressionQuality: 1.0) : newImage!.pngData()
    try! data!.write(to: URL(fileURLWithPath: targetPath))

    result(nil)
  }
}
