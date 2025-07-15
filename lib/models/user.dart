class User {
  final int id;
  final String username;
  final String name;
  final String? phoneOrInsta;
  final String gender;
  final String? location;
  final String? mbti;

  User({
    required this.id,
    required this.username,
    required this.name,
    this.phoneOrInsta,
    required this.gender,
    this.location,
    this.mbti,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      name: json['name'] as String,
      phoneOrInsta: json['phone_or_insta'] as String?,
      gender: json['gender'] as String,
      location: json['location'] as String?,
      mbti: json['mbti'] as String?,
    );
  }
}
