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

  const ImageMargins.symmetric({
    int horizontal = 0,
    int vertical = 0,
  })  : assert(horizontal >= 0 && vertical >= 0),
        left = horizontal,
        right = horizontal,
        top = vertical,
        bottom = vertical;

  const ImageMargins.all(int value)
      : assert(value >= 0),
        left = value,
        right = value,
        top = value,
        bottom = value;
}
