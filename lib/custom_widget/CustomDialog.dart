import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:names/constants/app_color.dart';

class CustomDialog {
  static void openSettingDialog(
      BuildContext context, String text, Function() function) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(
                horizontal: 15.0,
              ),
              content: Container(
                height: 270,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      color: Colors.white),
                  margin: EdgeInsets.only(top: 35),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 60, bottom: 20.0, left: 10, right: 10),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('We need permission',
                              style: TextStyle(
                                color: AppColor.blueColor,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              )),
                          Text(text,
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              )),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.32,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          border: Border.all(
                                              color: HexColor('BCBCBC')),
                                        ),
                                        child: Center(
                                          child: Text('Cancel',
                                              style: TextStyle(
                                                color: HexColor('797979'),
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500,
                                              )),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      function();
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.32,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                          color: AppColor.blueColor,
                                          borderRadius:
                                              BorderRadius.circular(100.0)),
                                      child: Center(
                                        child: Text(
                                          'Activate',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
        });
  }
}
