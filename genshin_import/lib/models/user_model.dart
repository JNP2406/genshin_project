class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final double mora;
  final String? profilePicture;
  final String? coverPhoto;
  final String? bio;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.mora,
    this.profilePicture,
    this.coverPhoto,
    this.bio,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      mora: double.parse(json['mora'].toString()),
      profilePicture: json['profile_picture'],
      coverPhoto: json['cover_photo'],
      bio: json['bio'],
      token: json['token'],
    );
  }
}