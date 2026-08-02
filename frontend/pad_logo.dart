import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('assets/ABHAY.png');
  if (!file.existsSync()) {
    print('Logo file not found');
    return;
  }

  // Decode the image
  final originalImage = img.decodeImage(file.readAsBytesSync());
  if (originalImage == null) return;

  // Adaptive icons require the actual icon to fit within a ~66% safe zone of the total canvas.
  // We'll create a new canvas 30% larger than the original image to act as padding.
  
  final int newWidth = (originalImage.width * 1.5).round();
  final int newHeight = (originalImage.height * 1.5).round();
  
  // Create a new image filled with the cream background color (#EAE7E1 -> R:234, G:231, B:225)
  final paddedImage = img.Image(width: newWidth, height: newHeight);
  
  // Fill background
  // image package uses format: ColorFloat16, ColorUint8 etc. But fill() just takes a Color.
  // For older/newer versions of `image` package, it's safer to just set pixels or use fill.
  // In `image` 4.x, clear() or fill() uses a Color.
  img.fill(paddedImage, color: img.ColorRgb8(234, 231, 225));

  // Draw the original image in the center
  final int dstX = (newWidth - originalImage.width) ~/ 2;
  final int dstY = (newHeight - originalImage.height) ~/ 2;

  img.compositeImage(
    paddedImage, 
    originalImage, 
    dstX: dstX, 
    dstY: dstY
  );

  // Save it
  final paddedBytes = img.encodePng(paddedImage);
  file.writeAsBytesSync(paddedBytes);
  print('Successfully padded the logo.');
}
