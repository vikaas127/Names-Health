class ContentListModel {
  String message;
  bool success;
  Data data;
  ContentListModel({this.message, this.success, this.data});
  ContentListModel.fromMap(Map<String, dynamic> map) {
    message = map['message'];
    success = map['success'];
    if (map['data'] != null) {
      data = Data.fromMap(map['data']);
    }
  }
}

class Data {
  String aboutUs;
  String privacyPolicy;
  String termsAndConditions;
  Data.fromMap(Map<String, dynamic> map) {
    aboutUs = map['about_us'];
    privacyPolicy = map['privacy_policy'];
    termsAndConditions = map['terms_and_conditions'];
  }
}
