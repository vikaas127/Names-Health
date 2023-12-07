import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class PlatformWidget extends StatelessWidget {
  Widget buildCupertinoWidget(BuildContext context);

  Widget buildMaterialWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isIOS) {
      return buildCupertinoWidget(context);
    }
    return buildMaterialWidget(context);
  }
}

class PlatformAlertDialog extends PlatformWidget {
  PlatformAlertDialog({
    this.title,
    this.content,
    this.defaultActionText,
    this.cancelActionText,
  });

  final String title;
  final String content;
  final String defaultActionText;
  final String cancelActionText;

  Future<bool> show(BuildContext context) async {
    return !kIsWeb && Platform.isIOS
        ? await showCupertinoDialog<bool>(
            context: context,
            builder: (BuildContext context) => this,
          )
        : await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => this,
          );
  }

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];
    if (cancelActionText != null) {
      actions.add(
        PlatformAlertDialogAction(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(cancelActionText),
        ),
      );
    }
    actions.add(
      PlatformAlertDialogAction(
        onPressed: () {
          Navigator.of(context).pop(true);
        },
        child: Text(defaultActionText),
      ),
    );
    return actions;
  }
}

class PlatformAlertDialogAction extends PlatformWidget {
  PlatformAlertDialogAction({
    this.child,
    this.onPressed,
  });

  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoDialogAction(
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
