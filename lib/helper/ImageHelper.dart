import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageHelper {
  Function(File file) imageCallBack;

  void showPhotoBottomDialog(
    BuildContext context,
    bool isIOS,
    Function(File file) imageCallBack, {
    bool allowFile: false,
    FileType fileType: FileType.image,
  }) {
    this.imageCallBack = imageCallBack;
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext modalContext) {
          return Container(
            decoration: BoxDecoration(
              color: AppColor.darkBlueColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0)),
            ),
            child: SafeArea(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Camera',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        imagePermissionCheck(context,Permission.camera,fileType,0);
                        // pickCameraPhoto(context, fileType: fileType);
                        if (Navigator.canPop(modalContext)) {
                          Navigator.pop(modalContext);
                        }
                      }),
                  ListTile(
                      leading: Icon(
                        Icons.photo,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Gallery',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () async{
                          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                            AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
                            if (androidInfo.version.sdkInt >= 30) {
                              imagePermissionCheck(context,
                                  isIOS ? Permission.photos : Permission.photos,
                                  fileType, 1);
                            }else{
                              imagePermissionCheck(context,
                                  isIOS ? Permission.photos : Permission.storage,
                                  fileType, 1);
                            }
                        // pickFile(fileType, context);
                        if (Navigator.canPop(modalContext)) {
                          Navigator.pop(modalContext);
                        }
                      }),
                  allowFile
                      ? ListTile(
                          leading: Icon(
                            Icons.file_copy,
                            color: Colors.white,
                          ),
                          title: Text(
                            'File',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            imagePermissionCheck(context, Permission.storage, fileType,2);
                            if (Navigator.canPop(modalContext)) {
                              Navigator.pop(modalContext);
                            }
                          })
                      : SizedBox(),
                  ListTile(
                      title: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        if (Navigator.canPop(modalContext)) {
                          Navigator.pop(modalContext);
                        }
                      }),
                ],
              ),
            ),
          );
        });
  }

  Future<File> pickCameraPhoto(BuildContext context,
      {FileType fileType}) async {
    try {
      ProgressDialog.show(context);
      PickedFile pickedFile;

      if (fileType != null && fileType == FileType.video) {
        pickedFile = await ImagePicker().getVideo(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear,
        );
      } else {
        pickedFile = await ImagePicker().getImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear,
        );
      }

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        if (imageCallBack != null) {
          imageCallBack(file);
        }
        ProgressDialog.hide();
        return file;
      } else {
        // User canceled the picker
      }
    } catch (ex) {
      ProgressDialog.hide();
    } finally {
      ProgressDialog.hide();
    }
  }

  Future<File> pickFile(FileType fileType, BuildContext context, {List<String> allowedExtensions}) async {
    ProgressDialog.show(context);
    ImagePicker picker = ImagePicker();
    //XFile image;
    try {
      XFile result =   fileType.name.toString() == "video"
          ? await picker.pickVideo(source: ImageSource.gallery)
      :await picker.pickImage(source: ImageSource.gallery);
      // await FilePicker.platform.pickFiles(
      //   type: fileType,
      //   allowCompression: true,
      //   allowedExtensions: allowedExtensions,
      // );
      if (result != null) {
        File file = File(result.path);
        if (imageCallBack != null) {
          imageCallBack(file);
        }
        ProgressDialog.hide();
        return file;
      } else {
        // User canceled the picker
      }
    } catch (ex) {
      ProgressDialog.hide();
    } finally {
      ProgressDialog.hide();
    }
  }

  Future<bool> imagePermissionCheck(BuildContext context, Permission permission, FileType fileType,int type) async {
    print('permission='+permission.toString());
    PermissionStatus permissionStatus = await permission.status;

    print('---------------------------permissioin ---------------------------');

    print(permissionStatus);


    if (permissionStatus == PermissionStatus.granted) {
      _callGrantFunction(context,fileType,type);
      return true;

    } else if (permissionStatus == PermissionStatus.denied) {

      print('------------permissionStatus');
// await [permission].request();
    //  cameraGranted();
      permissionStatus = await permission.request();
     // permissionStatus = await permission.status;
      print(permissionStatus.toString());
      if (permissionStatus == PermissionStatus.granted) {
        _callGrantFunction(context,fileType,type);
        return true;
      }

    }
    print("permissionStatus="+permissionStatus.toString());


    if (permissionStatus == PermissionStatus.permanentlyDenied ) {
      //cameraGranted();
      openSettingDialog(context,type, () => openAppSettings());

    }

    return permissionStatus == PermissionStatus.granted;

  }

  Future<bool> cameraGranted() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.storage, Permission.photos].request();
      PermissionStatus cameraPermission = await Permission.photos.status;
      if (cameraPermission.isGranted || cameraPermission.isLimited) {
        return true;
      } else {
        return false;
      }
    } else {
      PermissionStatus stoagePermission = await Permission.storage.status;
      PermissionStatus photoPermission = await Permission.photos.status;
      if (
          stoagePermission.isGranted ||
          stoagePermission.isLimited ||
          photoPermission.isGranted ||
          photoPermission.isLimited) {
        return true;
      } else {
        return false;
      }

      // if (defaultTargetPlatform == TargetPlatform.android) {
      //   granted = (statusCamera == PermissionStatus.granted ||
      //       statusStorage == PermissionStatus.granted ||
      //       statusPhotos == PermissionStatus.granted);
      // } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      //   granted = (statusCamera == PermissionStatus.granted ||
      //       statusStorage == PermissionStatus.granted ||
      //       statusPhotos == PermissionStatus.granted);
      // }
      // return granted;
    }
  }

  void openSettingDialog(BuildContext context,int type,Future<bool> Function() param1) {
    String strType="";
    if(type==2){
      strType="storage";
    }else if(type==1){
      strType="storage";
    }else{
      strType="camera";
    }

    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Wrap(
              children: [
                Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "We need permission",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.w700),
                            )
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: Image.asset(
                                "assets/icons/close.png",
                                height: 16,
                                width: 16,
                              ),
                              onTap: () {
                                Navigator.pop(ctx);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "We need to activate your "+ strType+" permissions for Names through your phone system setting.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      GestureDetector(
                        child: Container(
                          margin: EdgeInsets.only(top: 10),
                          // width: AppHelper.getDeviceWidth(context),
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color:  AppColor.lightSkyBlueColor),
                          alignment: Alignment.center,
                          child: Text(
                            "Open Setting",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          param1();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }

  void _callGrantFunction(BuildContext context,FileType fileType,int type) async{
    ImagePicker picker = ImagePicker();
    XFile image;
    if(type==2){
      pickFile(
        FileType.custom,
        context,
        allowedExtensions: [
          'jpg',
          'png',
          'pdf',
          'doc',
          'docx'
        ],
      );
    }else if(type==1) {
     // image =  await picker.pickImage(source: ImageSource.gallery);
      pickFile(fileType, context);
    }else{
      pickCameraPhoto(context, fileType: fileType);
    }
  }

}
