class ProfessionModel {
  int id;
  String professionName;
  String specialist;
  String symbol;
  String status;
  String createdAt;
  String updatedAt;

  ProfessionModel(
      {this.id,
      this.professionName,
      this.specialist,
      this.symbol,
      this.status,
      this.createdAt,
      this.updatedAt});

  ProfessionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    professionName = json['profession_name'];
    specialist = json['specialist'];
    symbol = json['symbol'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> ProfessionModel = new Map<String, dynamic>();
    ProfessionModel['id'] = this.id;
    ProfessionModel['profession_name'] = this.professionName;
    ProfessionModel['specialist'] = this.specialist;
    ProfessionModel['symbol'] = this.symbol;
    ProfessionModel['status'] = this.status;
    ProfessionModel['created_at'] = this.createdAt;
    ProfessionModel['updated_at'] = this.updatedAt;
    return ProfessionModel;
  }
}
