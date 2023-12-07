class SpecialistResponse {
  bool success;
  List<Data> data;
  String message;

  SpecialistResponse({this.success, this.data, this.message});

  SpecialistResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  int id;
  String professionName;
  String specialist;
  String symbol;
  String status;
  String createdAt;
  String updatedAt;

  Data(
      {this.id,
      this.professionName,
      this.specialist,
      this.symbol,
      this.status,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    professionName = json['profession_name'];
    specialist = json['specialist'];
    symbol = json['symbol'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['profession_name'] = this.professionName;
    data['specialist'] = this.specialist;
    data['symbol'] = this.symbol;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
