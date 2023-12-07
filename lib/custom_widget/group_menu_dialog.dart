import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/route/routes.dart';
import 'package:popup_menu/triangle_painter.dart';

/* Created by Bholendra Singh  */
class GroupMenuDialog {
  Rect _showRect;
  var arrowHeight = 10.0;
  var itemWidth = 70.0;
  var itemHeight = 35.0;

  Size _screenSize;

  OverlayEntry _entry;
  Offset _offset;

  bool _isShow = false;

  bool _isDown = false;
  bool isShowing = false;
  BuildContext context;
  GlobalKey globalKey;

  Function(dynamic menuValue) clickCallback;

  void show(BuildContext context, GlobalKey globalKey,
      Function(dynamic menuValue) clickCallback) {
    this.context = context;
    this.globalKey = globalKey;
    this.clickCallback = clickCallback;
    _showRect = getWidgetGlobalRect(globalKey);
    _screenSize = window.physicalSize / window.devicePixelRatio;
    _offset = _calculateOffset(context);

    _entry = OverlayEntry(builder: (context) {
      return buildPopupMenuLayout(_offset);
    });
    Overlay.of(context).insert(_entry);
    _isShow = true;
  }

  getCircularProgressIndicator({double height, double width}) {
    if (height == null) {
      height = 40.0;
    }
    if (width == null) {
      width = 40.0;
    }
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(AppColor.darkBlueColor),
        ),
        height: height,
        width: width,
      ),
    );
  }

  getErrorWidget() {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        child: Text("Oops! Something went wrong."),
      ),
    );
  }

  Offset _calculateOffset(BuildContext context) {
    double dx = _showRect.left + _showRect.width / 2.0 - menuWidth() / 2.0;
    if (dx < 10.0) {
      dx = 10.0;
    }

    if (dx + menuWidth() > _screenSize.width && dx > 10.0) {
      double tempDx = _screenSize.width - menuWidth() - 10;
      if (tempDx > 10) dx = tempDx;
    }

    double dy = _showRect.top - menuHeight();
    if (dy <= MediaQuery.of(context).padding.top + 10) {
      // The have not enough space above, show menu under the widget.
      dy = arrowHeight + _showRect.height + _showRect.top;
    } else {
      dy -= arrowHeight;
    }

    return Offset(dx, dy);
  }

  double menuWidth() {
    return itemWidth * 2.6;
  }

  // This height exclude the arrow
  double menuHeight() {
    return itemHeight * 2;
  }

  Rect getWidgetGlobalRect(GlobalKey key) {
    RenderBox renderBox = key.currentContext.findRenderObject();
    var offset = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
        offset.dx, offset.dy, renderBox.size.width, renderBox.size.height);
  }

  LayoutBuilder buildPopupMenuLayout(Offset offset) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          dismiss();
        },
//        onTapDown: (TapDownDetails details) {
//          dismiss();
//        },
        // onPanStart: (DragStartDetails details) {
        //   dismiss();
        // },
        onVerticalDragStart: (DragStartDetails details) {
          dismiss();
        },
        onHorizontalDragStart: (DragStartDetails details) {
          dismiss();
        },
        child: Container(
          child: Stack(
            children: <Widget>[
              // triangle arrow
              Positioned(
                left: _showRect.left + _showRect.width / 2.0 - 7.5,
                top: _isDown
                    ? offset.dy + menuHeight()
                    : offset.dy - arrowHeight,
                child: CustomPaint(
                  size: Size(15.0, arrowHeight),
                  painter:
                      TrianglePainter(isDown: _isDown, color: Colors.white),
                ),
              ),
              // menu content
              Positioned(
                left: offset.dx,
                top: offset.dy,
                child: Container(
                  width: menuWidth(),
                  height: menuHeight(),
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            width: menuWidth(),
                            height: menuHeight(),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0)),
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Material(
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MenuItemWidget(
                                    item: Container(
                                      height: itemHeight,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/icons/new_message.png",
                                            height: 14,
                                            width: 14,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "New Message",
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                    menuValue: "message",
                                    clickCallback: (value) {
                                      print(value);
                                      dismiss();
                                      clickCallback(value);
                                    },
                                  ),
                                  MenuItemWidget(
                                    item: Container(
                                      height: itemHeight,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/images/group_icon.png",
                                            height: 14,
                                            width: 14,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "New Group Chat",
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                    menuValue: "group",
                                    clickCallback: (value) {
                                      print(value);
                                      dismiss();
                                      clickCallback(value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  void dismiss() {
    if (!_isShow) {
      // Remove method should only be called once
      return;
    }

    _entry.remove();
    _isShow = false;
    // if (dismissCallback != null) {
    //   dismissCallback();
    // }
  }

  void logout() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Routes.LoginScreen, (route) => false);
  }
}

class MenuItemWidget extends StatefulWidget {
  final Widget item;
  final dynamic menuValue;
  final Color backgroundColor;
  final Color highlightColor;

  final Function(dynamic menuValue) clickCallback;

  MenuItemWidget(
      {this.item,
      this.clickCallback,
      this.backgroundColor,
      this.highlightColor,
      this.menuValue});

  @override
  State<StatefulWidget> createState() {
    return _MenuItemWidgetState();
  }
}

class _MenuItemWidgetState extends State<MenuItemWidget> {
  var highlightColor = Color(0x55000000);
  var color = Color(0xff232323);

  @override
  void initState() {
    color = widget.backgroundColor;
    highlightColor = widget.highlightColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        color = highlightColor;
        setState(() {});
      },
      onTapUp: (details) {
        color = widget.backgroundColor;
        setState(() {});
      },
      onLongPressEnd: (details) {
        color = widget.backgroundColor;
        setState(() {});
      },
      onTap: () {
        if (widget.clickCallback != null) {
          widget.clickCallback(widget.menuValue);
        }
      },
      child: widget.item,
    );
  }
}
