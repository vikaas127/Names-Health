import 'package:flutter/material.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/DownloadProgressDialog.dart';
import 'package:names/model/ApiResponseModel.dart';
import 'package:names/model/CertificateModel.dart';
import 'package:open_file_safe/open_file_safe.dart';

class DocumentWidget extends StatefulWidget {
  final List<CertificateModel> docList;
  final String docName;
  const DocumentWidget(
      {Key key, @required this.docList, @required this.docName})
      : super(key: key);

  @override
  State<DocumentWidget> createState() => _DocumentWidgetState();
}

class _DocumentWidgetState extends State<DocumentWidget>
    with ApiCallBackListener {
  int selectedIndex;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: ListView.separated(
        itemCount: widget.docList.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, index) {
          return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                String filepath = widget.docList[index].file.path.toString();
                if (filepath != null && Uri.parse(filepath).isAbsolute) {
                  DownloadProgressDialog.show(context, filepath);
                } else {
                  OpenFile.open(widget.docList[index].file.path).then((value) {
                    if (value != null) {
                      OpenResult openResult = value;

                      if (openResult.type != ResultType.done) {
                        AppHelper.showToastMessage(
                            openResult.message.toString());
                      }
                    }
                  });
                }
              },
              child: Container(
                child: Column(
                  children: [
                    Container(
                      height: 95,
                      width: 85,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: AppColor.fileBoxColor,
                                borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.all(10),
                            height: 90,
                            width: 80,
                            margin: EdgeInsets.only(top: 5),
                            child: AppHelper.isImageExist(
                                    widget.docList[index].file.path)
                                ? Image.file(
                                    widget.docList[index].file,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.file_copy,
                                    size: 50,
                                  ),
                          ),
                          GestureDetector(
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: AppColor.blueColor),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.close,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onTap: () {
                              if (AppHelper.isFileExist(
                                  widget.docList[index].file)) {
                                setState(() {
                                  widget.docList.removeAt(index);
                                });
                              } else {
                                if (widget.docName == "Certificate") {
                                  removeCertificateAPI(index);
                                } else {
                                  removeDocumentAPI(index);
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.docName + " " + (index + 1).toString(),
                      style: TextStyle(fontSize: 12),
                    )
                  ],
                ),
              ));
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            width: 20,
          );
        },
      ),
    );
  }

  void removeCertificateAPI(int index) {
    selectedIndex = index;
    Map<String, String> body = Map();
    body["certificate_id"] = widget.docList[index].id.toString();

    ApiRequest(
      context: context,
      apiCallBackListener: this,
      httpType: HttpMethods.POST,
      url: Url.deleteCertificate,
      apiAction: ApiAction.deleteCertificate,
      body: body,
    );
  }

  void removeDocumentAPI(int index) {
    selectedIndex = index;
    Map<String, String> body = Map();
    body["document_id"] = widget.docList[index].id.toString();

    ApiRequest(
      context: context,
      apiCallBackListener: this,
      httpType: HttpMethods.POST,
      url: Url.deleteDocument,
      apiAction: ApiAction.deleteCertificate,
      body: body,
    );
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.deleteCertificate) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        setState(() {
          widget.docList.removeAt(selectedIndex);
        });
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    }
  }
}

Widget documentTile(String documentName, BuildContext context) {
  return Container(
    width: AppHelper.getDeviceWidth(context),
    height: 80,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1, color: AppColor.textGrayColor)),
    alignment: Alignment.center,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/icons/file.png",
          height: 50,
          width: 50,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          documentName,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16, color: Colors.black, fontFamily: "Lato_Bold"),
        ),
      ],
    ),
  );
}
