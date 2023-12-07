class SearchModel {
  String username;
  String photo;
  String department;
  bool isVerified;
  String lastMessage;
  bool isSelected;
  bool isCompany;
  String id;

  SearchModel(
      {this.username,
      this.photo,
      this.department,
      this.isVerified: false,
      this.lastMessage,
      this.isSelected: false,
      this.isCompany: false,
      this.id});
}
