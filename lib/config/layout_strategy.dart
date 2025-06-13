/// Utility class that defines how to layout the webview
class LayoutStrategy {
  /// Width of the webview
  final int? width;

  /// Height of the webview
  final int? height;

  /// Determines if the provided dimensions is in millimeters
  final bool mm;

  /// Uses device width and height as the webview layout dimensions
  const LayoutStrategy.deviceDefault()
      : width = null,
        height = null,
        mm = false;

  /// Uses the provided `width` and `height` as the webview layout dimensions
  ///
  /// Omitting any will fallback to device default width and height
  const LayoutStrategy.withDimensions({
    this.width,
    this.height,
  }) : mm = false;

  const LayoutStrategy._paper(this.width, this.height) : mm = true;

  /// A0 Paper Dimensions: 2384 × 3370 pixels
  const LayoutStrategy.a0() : this._paper(2384, 3370);

  /// A1 Paper Dimensions: 1684 × 2384 pixels
  const LayoutStrategy.a1() : this._paper(1684, 2384);

  /// A2 Paper Dimensions: 1191 × 1684 pixels
  const LayoutStrategy.a2() : this._paper(1191, 1684);

  /// A3 Paper Dimensions: 842 × 1191 pixels
  const LayoutStrategy.a3() : this._paper(842, 1191);

  /// A4 Paper Dimensions: 595 × 842 pixels
  const LayoutStrategy.a4() : this._paper(595, 842);

  /// A5 Paper Dimensions: 420 × 595 pixels
  const LayoutStrategy.a5() : this._paper(420, 595);

  /// A6 Paper Dimensions: 298 × 420 pixels
  const LayoutStrategy.a6() : this._paper(298, 420);

  /// A7 Paper Dimensions: 210 × 298 pixels
  const LayoutStrategy.a7() : this._paper(210, 298);

  /// A8 Paper Dimensions: 147 × 210 pixels
  const LayoutStrategy.a8() : this._paper(147, 210);

  /// A9 Paper Dimensions: 105 × 147 pixels
  const LayoutStrategy.a9() : this._paper(105, 147);

  /// A10 Paper Dimensions: 74 × 105 pixels
  const LayoutStrategy.a10() : this._paper(74, 105);

  /// 80mm Thermal paper dimensions: 227 × variable pixels
  const LayoutStrategy.t80() : this._paper(227, null);

  /// 76mm Thermal paper dimensions: 215 × variable pixels
  const LayoutStrategy.t76() : this._paper(215, null);

  /// 57mm Thermal paper dimensions: 162 × variable pixels
  const LayoutStrategy.t57() : this._paper(162, null);

  Map<String, dynamic> toMap() {
    return {
      'width': width,
      'height': height,
      'mm': mm,
    };
  }
}
