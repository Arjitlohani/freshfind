class User {
  final int userId;
  final String username;
  final int? roleId; // Add this line

  User(
      {required this.userId,
      required this.username,
      required this.roleId}); // Update constructor

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      username: json['username'],
      roleId: json['roleId'],
    );
  }
}
