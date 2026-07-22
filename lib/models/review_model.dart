import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String doctorId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime timestamp;

  ReviewModel({
    required this.reviewId,
    required this.doctorId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'doctorId': doctorId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate = DateTime.now();
    if (map['timestamp'] is Timestamp) {
      parsedDate = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is String) {
      parsedDate = DateTime.tryParse(map['timestamp']) ?? DateTime.now();
    }

    return ReviewModel(
      reviewId: id.isNotEmpty ? id : (map['reviewId'] ?? ''),
      doctorId: map['doctorId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 5.0,
      comment: map['comment'] ?? '',
      timestamp: parsedDate,
    );
  }
}
