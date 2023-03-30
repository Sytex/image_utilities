import 'package:image_utilities/src/image_utilities_format.dart';
import 'package:image_utilities/src/image_utilities_platform_interface.dart';

class ImageUtilities {
  Future<void> generateThumbnail({
    required String imagePath,
    required String targetPath,
    int maxSize = 128,
    ImageUtilitiesFormat format = ImageUtilitiesFormat.jpeg,
  }) {
    return ImageUtilitiesPlatform.instance.generateThumbnail(
      imagePath: imagePath,
      targetPath: targetPath,
      maxSize: maxSize,
      format: format,
    );
  }

  Future<void> rotate({
    required String imagePath,
    required String targetPath,
    int degrees = 0,
    ImageUtilitiesFormat format = ImageUtilitiesFormat.jpeg,
  }) {
    return ImageUtilitiesPlatform.instance.rotate(
      imagePath: imagePath,
      targetPath: targetPath,
      degrees: degrees,
      format: format,
    );
  }
}
