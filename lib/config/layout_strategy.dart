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

  /// A0 Paper Dimensions
  const LayoutStrategy.a0() : this._paper(841, 1189);

  /// A1 Paper Dimensions
  const LayoutStrategy.a1() : this._paper(594, 841);

  /// A2 Paper Dimensions
  const LayoutStrategy.a2() : this._paper(420, 594);

  /// A3 Paper Dimensions
  const LayoutStrategy.a3() : this._paper(297, 420);

  /// A4 Paper Dimensions
  const LayoutStrategy.a4() : this._paper(210, 297);

  /// A5 Paper Dimensions
  const LayoutStrategy.a5() : this._paper(148, 210);

  /// A6 Paper Dimensions
  const LayoutStrategy.a6() : this._paper(105, 148);

  /// A7 Paper Dimensions
  const LayoutStrategy.a7() : this._paper(74, 105);

  /// A8 Paper Dimensions
  const LayoutStrategy.a8() : this._paper(52, 74);

  /// A9 Paper Dimensions
  const LayoutStrategy.a9() : this._paper(37, 52);

  /// A10 Paper Dimensions
  const LayoutStrategy.a10() : this._paper(26, 37);

  /// 80mm Thermal paper dimensions
  const LayoutStrategy.t80() : this._paper(80, null);

  /// 76mm Thermal paper dimensions
  const LayoutStrategy.t76() : this._paper(76, null);

  /// 57mm Thermal paper dimensions
  const LayoutStrategy.t57() : this._paper(57, null);

  Map<String, dynamic> toMap() {
    return {
      'width': width,
      'height': height,
      'mm': mm,
    };
  }
}
