class WorkSiteModel {
  bool success;
  String message;
  List<String> data = [];
  WorkSiteModel.fromMap(Map<String, dynamic> map) {
    success = map['success'];
    message = map['message'];
    if (map['data'] != null && map['data'] != []) {
      for (var element in map['data']) {
        data.add(element['name']);
      }
    }
  }
}
