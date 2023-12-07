class NewsFeedModel {
  String userProfile;
  String userName;
  String time;
  String location;
  String file;
  String title;
  String description;
  String likeCount;
  String type;

  NewsFeedModel.name(this.userProfile, this.userName, this.time, this.location,
      this.file, this.title, this.description, this.likeCount, this.type);

  NewsFeedModel(
      {this.userProfile,
      this.userName,
      this.time,
      this.location,
      this.file,
      this.title,
      this.description,
      this.likeCount,
      this.type});
}
