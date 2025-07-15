class Contact {
  final int id;
  final int userId;
  final String intro;
  final String contactValue;
  final String? location;
  final String? mbti;
  final String gender;

  Contact({
    required this.id,
    required this.userId,
    required this.intro,
    required this.contactValue,
    this.location,
    this.mbti,
    required this.gender,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      intro: json['intro'] as String,
      contactValue: json['contact_value'] as String,
      location: json['location'] as String?,
      mbti: json['mbti'] as String?,
      gender: json['gender'] as String? ?? '',
    );
  }
}
