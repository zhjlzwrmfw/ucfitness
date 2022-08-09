import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class PopupMenuItemOverride<T> extends PopupMenuEntry<T> {
  const PopupMenuItemOverride({
    Key key,
    this.value,
    this.enabled = true,
    this.height = kMinInteractiveDimension,
    this.textStyle,
    @required this.child,
  }) : assert(enabled != null),
        assert(height != null),
        super(key: key);

  final T value;
  final bool enabled;
  @override
  final double height;
  final TextStyle textStyle;
  final Widget child;

  @override
  bool represents(T value) => value == this.value;

  @override
  PopupMenuItemOverrideState<T, PopupMenuItemOverride<T>> createState() => PopupMenuItemOverrideState<T, PopupMenuItemOverride<T>>();
}

class PopupMenuItemOverrideState<T, W extends PopupMenuItemOverride<T>> extends State<W> {
  @protected
  Widget buildChild() => widget.child;

  @protected
  void handleTap() {
    Navigator.pop<T>(context, widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    TextStyle style = widget.textStyle ?? popupMenuTheme.textStyle ?? theme.textTheme.subtitle1;

    if (!widget.enabled)
      style = style.copyWith(color: theme.disabledColor);

    Widget item = AnimatedDefaultTextStyle(
      style: style,
      duration: kThemeChangeDuration,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: AlignmentDirectional.centerStart,
        constraints: BoxConstraints(minHeight: widget.height),
        child: buildChild(),
      ),
    );

    if (!widget.enabled) {
      final bool isDark = theme.brightness == Brightness.dark;
      item = IconTheme.merge(
        data: IconThemeData(opacity: isDark ? 0.5 : 0.38),
        child: item,
      );
    }

    return InkWell(
      splashColor: Colors.transparent,
      onTap: widget.enabled ? handleTap : null,
      canRequestFocus: widget.enabled,
      child: item,
    );
  }
}