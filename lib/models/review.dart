import 'user.dart';

class Review {
  Review({
    required this.id,
    required this.comment,
    required this.rating,
    required this.createdAt,
    this.user,
  });

  final String id;
  final String comment;
  final int rating;
  final String? createdAt;
  final User? user;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      comment: json['comment'] as String? ?? '',
      rating: json['rating'] as int? ?? 0,
      createdAt: json['createdAt'] as String?,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
