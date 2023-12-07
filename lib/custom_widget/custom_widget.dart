import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:names/helper/ProgressDialog.dart';

import '../constants/app_color.dart';

class CustomWidget {
  static Widget imageView(String url,
      {double height,
      double width,
      BoxFit fit,
      Color backgroundColor,
      bool circle,
      bool isLocal,
      bool forProfileImage,
      bool forCoverImage,
      bool paddingProgressBar,
      bool forGroupImage,
      bool fullImage}) {
    if (isLocal == null) {
      isLocal = false;
    }
    if (forProfileImage == null) {
      forProfileImage = false;
    }
    if (forCoverImage == null) {
      forCoverImage = false;
    }
    if (forGroupImage == null) {
      forGroupImage = false;
    }
    if (paddingProgressBar == null) {
      paddingProgressBar = false;
    }
    if (fullImage == null) {
      fullImage = false;
    }
    Widget placeHolderWidget(bool isErrorWidget) {
      if (isErrorWidget) {
        return Center(
          child: Icon(Icons.error),
        );
      }

      return Center(
        child: Image.asset(forProfileImage
            ? "assets/images/doctor_def_circle.png"
            : forGroupImage
                ? "assets/images/medical-team.png"
                : forCoverImage
                    ? "assets/images/feed_image.png"
                    : "assets/images/placeholder.jpeg"),
      );
    }

    return Builder(builder: (ctx) {
      if (url == null || url.isEmpty) {
        if (circle != null && circle) {
          return ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(100)),
              child: Container(
                color: backgroundColor != null
                    ? backgroundColor
                    : forProfileImage
                        ? AppColor.profileBackColor
                        : Colors.transparent,
                child: Center(
                  child: Image.asset(forProfileImage
                      ? "assets/images/doctor_def_circle.png"
                      : forGroupImage
                          ? "assets/images/medical-team.png"
                          : "assets/images/placeholder.jpeg"),
                ),
              ));
        }
        return Container(
          color: backgroundColor != null ? backgroundColor : Colors.transparent,
          child: Center(
            child: Image.asset(forProfileImage
                ? "assets/images/doctor_def_circle.png"
                : forGroupImage
                    ? "assets/images/medical-team.png"
                    : forCoverImage
                        ? "assets/images/feed_image.png"
                        : "assets/images/placeholder.jpeg"),
          ),
        );
      } else {
        if (circle != null && circle) {
          return ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(100)),
              child: isLocal
                  ? Image.asset(
                      url,
                      width: width,
                      height: height,
                      fit: fit,
                    )
                  : ExtendedImage.network(
                      url,
                      width: width,
                      height: height,
                      fit: fit,
                      cache: true,
                      enableMemoryCache: true,
                      retries: 3,
                      timeRetry: Duration(seconds: 2),
                      cacheHeight: 300,
                      clearMemoryCacheWhenDispose: true,
                      loadStateChanged:
                          (ExtendedImageState extendedImageState) {
                        switch (extendedImageState.extendedImageLoadState) {
                          case LoadState.loading:
                            return Container(
                              color: backgroundColor != null
                                  ? backgroundColor
                                  : Colors.transparent,
                              child:
                                  ProgressDialog.getCircularProgressIndicator(),
                            );

                            break;
                          case LoadState.completed:
                            return extendedImageState.completedWidget;
                            break;
                          case LoadState.failed:
                            if (!forCoverImage &&
                                !forGroupImage &&
                                !forProfileImage) {
                              return placeHolderWidget(true);
                            } else {
                              return placeHolderWidget(false);
                            }
                            break;
                          default:
                            {
                              if (!forCoverImage &&
                                  !forGroupImage &&
                                  !forProfileImage) {
                                return placeHolderWidget(true);
                              } else {
                                return placeHolderWidget(false);
                              }
                            }
                        }
                      },
                      mode: ExtendedImageMode.none,
                      handleLoadingProgress: true,
                      clearMemoryCacheIfFailed: true,
                      enableLoadState: true,
                    ));
        }
        return isLocal
            ? Image.asset(
                url,
                width: width,
                height: height,
                fit: fit,
              )
            : fullImage
                ? ExtendedImage.network(
                    url,
                    width: width,
                    height: height,
                    fit: fit,
                    cache: true,
                    enableMemoryCache: true,
                    retries: 3,
                    timeRetry: Duration(seconds: 2),
                    clearMemoryCacheWhenDispose: true,
                    loadStateChanged: (ExtendedImageState extendedImageState) {
                      switch (extendedImageState.extendedImageLoadState) {
                        case LoadState.loading:
                          if (forCoverImage || paddingProgressBar) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 90, vertical: 70),
                              child:
                                  ProgressDialog.getCircularProgressIndicator(),
                            );
                          }
                          return ProgressDialog.getCircularProgressIndicator();
                          break;
                        case LoadState.completed:
                          return extendedImageState.completedWidget;
                          break;
                        case LoadState.failed:
                          if (!forCoverImage &&
                              !forGroupImage &&
                              !forProfileImage) {
                            return placeHolderWidget(true);
                          } else {
                            return placeHolderWidget(false);
                          }
                          break;
                        default:
                          {
                            if (!forCoverImage &&
                                !forGroupImage &&
                                !forProfileImage) {
                              return placeHolderWidget(true);
                            } else {
                              return placeHolderWidget(false);
                            }
                          }
                      }
                    },
                    mode: ExtendedImageMode.none,
                    handleLoadingProgress: true,
                    clearMemoryCacheIfFailed: true,
                    enableLoadState: true,
                  )
                : ExtendedImage.network(
                    url,
                    width: width,
                    height: height,
                    fit: fit,
                    cache: true,
                    enableMemoryCache: true,
                    retries: 3,
                    cacheHeight: 500,
                    timeRetry: Duration(seconds: 2),
                    clearMemoryCacheWhenDispose: true,
                    loadStateChanged: (ExtendedImageState extendedImageState) {
                      switch (extendedImageState.extendedImageLoadState) {
                        case LoadState.loading:
                          if (forCoverImage || paddingProgressBar) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 90, vertical: 70),
                              child:
                                  ProgressDialog.getCircularProgressIndicator(),
                            );
                          }
                          return ProgressDialog.getCircularProgressIndicator();
                          break;
                        case LoadState.completed:
                          return extendedImageState.completedWidget;
                          break;
                        case LoadState.failed:
                          if (!forCoverImage &&
                              !forGroupImage &&
                              !forProfileImage) {
                            return placeHolderWidget(true);
                          } else {
                            return placeHolderWidget(false);
                          }
                          break;
                        default:
                          {
                            if (!forCoverImage &&
                                !forGroupImage &&
                                !forProfileImage) {
                              return placeHolderWidget(true);
                            } else {
                              return placeHolderWidget(false);
                            }
                          }
                      }
                    },
                    mode: ExtendedImageMode.none,
                    handleLoadingProgress: true,
                    clearMemoryCacheIfFailed: true,
                    enableLoadState: true,
                  );
      }
    });
  }
}
