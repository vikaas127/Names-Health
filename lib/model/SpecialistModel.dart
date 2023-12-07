class SpecialistModel {
  int id;
  String professionName;
  String specialist;
  String symbol;
  String status;
  String createdAt;
  String updatedAt;

  SpecialistModel(
      {this.id,
      this.professionName,
      this.specialist,
      this.symbol,
      this.status,
      this.createdAt,
      this.updatedAt});

  SpecialistModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    professionName = json['profession_name'];
    specialist = json['specialist'];
    symbol = json['symbol'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> SpecialistModel = new Map<String, dynamic>();
    SpecialistModel['id'] = this.id;
    SpecialistModel['profession_name'] = this.professionName;
    SpecialistModel['specialist'] = this.specialist;
    SpecialistModel['symbol'] = this.symbol;
    SpecialistModel['status'] = this.status;
    SpecialistModel['created_at'] = this.createdAt;
    SpecialistModel['updated_at'] = this.updatedAt;
    return SpecialistModel;
  }
}
