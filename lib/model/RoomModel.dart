class RoomModel {
  final String name;
  final bool isLoading;
  final bool isSubmitted;
  final String token;

  RoomModel({
    this.name,
    this.isLoading = false,
    this.isSubmitted = false,
    this.token,
  });

  RoomModel copyWith({
    String name,
    bool isLoading,
    bool isSubmitted,
    String token,
  }) {
    return RoomModel(
      name: name ?? this.name,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}
