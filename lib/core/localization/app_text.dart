import 'package:flutter/material.dart' as material;

import 'app_localizations.dart';

/// A translated drop-in subtype of Flutter's [material.Text].
///
/// Keeping this as a subtype (instead of wrapping Text in a StatelessWidget)
/// means it can still be passed to Flutter APIs that explicitly require a
/// `Text`, such as map attribution widgets.
class Text extends material.Text {
  const Text(
    super.data, {
    super.key,
    super.style,
    super.strutStyle,
    super.textAlign,
    super.textDirection,
    super.locale,
    super.softWrap,
    super.overflow,
    super.textScaler,
    super.maxLines,
    super.semanticsLabel,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.selectionColor,
  });

  @override
  material.Widget build(material.BuildContext context) {
    final translated =
        AppLocalizations.maybeOf(context)?.translateLiteral(data ?? '') ??
            (data ?? '');

    return material.Text(
      translated,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
