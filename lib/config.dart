/// Represents the margins for an output image.
class ImageMargins {
  final int top;
  final int right;
  final int bottom;
  final int left;

  const ImageMargins({
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    this.left = 0,
  }) : assert(top >= 0 && right >= 0 && bottom >= 0 && left >= 0);
}
