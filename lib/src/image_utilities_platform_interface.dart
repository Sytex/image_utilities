import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:image_utilities/src/image_utilities_format.dart';
import 'package:image_utilities/src/image_utilities_method_channel.dart';

abstract class ImageUtilitiesPlatform extends PlatformInterface {
  /// Constructs a ImageUtilitiesPlatform.
  ImageUtilitiesPlatform() : super(token: _token);

  static final Object _token = Object();

  static ImageUtilitiesPlatform _instance = MethodChannelImageUtilities();

  /// The default instance of [ImageUtilitiesPlatform] to use.
  ///
  /// Defaults to [MethodChannelImageUtilities].
  static ImageUtilitiesPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ImageUtilitiesPlatform] when
  /// they register themselves.
  static set instance(ImageUtilitiesPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> generateThumbnail({
    required String imagePath,
    required String targetPath,
    int maxSize = 128,
    ImageUtilitiesFormat format = ImageUtilitiesFormat.jpeg,
  }) {
    throw UnimplementedError('generateThumbnail() has not been implemented.');
  }

  Future<void> rotate({
    required String imagePath,
    required String targetPath,
    int degrees = 0,
    ImageUtilitiesFormat format = ImageUtilitiesFormat.jpeg,
  }) {
    throw UnimplementedError('rotate() has not been implemented.');
  }
}
