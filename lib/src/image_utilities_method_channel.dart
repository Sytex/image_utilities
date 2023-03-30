import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:image_utilities/src/image_utilities_format.dart';
import 'package:image_utilities/src/image_utilities_platform_interface.dart';

/// An implementation of [ImageUtilitiesPlatform] that uses method channels.
class MethodChannelImageUtilities extends ImageUtilitiesPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('image_utilities');

  @override
  Future<void> generateThumbnail({
    required String imagePath,
    required String targetPath,
    int maxSize = 128,
    ImageUtilitiesFormat format = ImageUtilitiesFormat.jpeg,
  }) {
    return methodChannel.invokeMethod('generateThumbnail', {
      'imagePath': imagePath,
      'targetPath': targetPath,
      'maxSize': maxSize,
      'format': format.index,
    });
  }

  @override
  Future<void> rotate({
    required String imagePath,
    required String targetPath,
    int degrees = 0,
    ImageUtilitiesFormat format = ImageUtilitiesFormat.jpeg,
  }) {
    return methodChannel.invokeMethod('rotate', {
      'imagePath': imagePath,
      'targetPath': targetPath,
      'degrees': degrees,
      'format': format.index,
    });
  }
}
