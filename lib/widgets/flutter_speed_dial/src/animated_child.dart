import 'package:flutter/material.dart';

class AnimatedChild extends AnimatedWidget {
  final int index;
  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;
  final double buttonSize;
  final Widget child;

  final String label;
  final TextStyle labelStyle;
  final Color labelBackgroundColor;
  final Widget labelWidget;

  final bool visible;
  final VoidCallback onTap;
  final VoidCallback toggleChildren;
  final ShapeBorder shape;
  final String heroTag;

  final double _paddingPercent = 0.125;

  AnimatedChild({
    Key key,
    Animation<double> animation,
    this.index,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 6.0,
    buttonSize,
    this.child,
    this.label,
    this.labelStyle,
    this.labelBackgroundColor,
    this.labelWidget,
    this.visible = false,
    this.onTap,
    this.toggleChildren,
    this.shape,
    this.heroTag,
  })  : this.buttonSize = buttonSize ?? 56.0,
        super(key: key, listenable: animation);

  Widget buildLabel() {
    final Animation<double> animation = listenable;

    if (!((label != null || labelWidget != null) &&
        visible &&
        animation.value == buttonSize)) {
      return Container();
    }

    if (labelWidget != null) return labelWidget;

    return GestureDetector(
      onTap: _performAction,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        margin: EdgeInsets.only(right: 18.0),
        decoration: BoxDecoration(
          color: labelBackgroundColor ?? Colors.grey[800],
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              offset: Offset(0.8, 0.8),
              blurRadius: 2.4,
            )
          ],
        ),
        child: Text(label, style: labelStyle),
      ),
    );
  }

  void _performAction() {
    if (onTap != null) onTap();
    toggleChildren();
  }

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;

    final Widget buttonChild = animation.value > 50.0
        ? Container(
            width: animation.value,
            height: animation.value,
            child: child ?? Container(),
          )
        : Container(
            width: 0.0,
            height: 0.0,
          );

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          buildLabel(),
          Container(
            width: buttonSize,
            height: animation.value,
            padding: EdgeInsets.only(bottom: buttonSize - animation.value),
            child: Container(
              height: buttonSize,
              width: animation.value,
              padding: EdgeInsets.only(
                left: _paddingPercent *
                    buttonSize, // This will give relative padding size
                right: _paddingPercent * buttonSize,
              ),
              child: FloatingActionButton(
                heroTag: heroTag,
                onPressed: _performAction,
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                elevation: elevation ?? 6.0,
                child: buttonChild,
              ),
            ),
          )
        ],
      ),
    );
  }
}
