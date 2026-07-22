import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _doctorsRef => _firestore.collection('doctors');
  CollectionReference get _reviewsRef => _firestore.collection('reviews');
  CollectionReference get _usersRef => _firestore.collection('users');

  // Stream Doctors
  Stream<List<DoctorModel>> streamDoctors({
    String? searchQuery,
    String? selectedSpecialty,
    String? selectedDistrict,
  }) {
    Query query = _doctorsRef;

    return query.snapshots().map((snapshot) {
      List<DoctorModel> list = snapshot.docs.map((doc) {
        return DoctorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Client-side filtering for fast interactive web searching across multiple fields
      if (selectedSpecialty != null && selectedSpecialty.isNotEmpty && selectedSpecialty != 'All') {
        list = list.where((d) => d.specialty.toLowerCase() == selectedSpecialty.toLowerCase()).toList();
      }

      if (selectedDistrict != null && selectedDistrict.isNotEmpty && selectedDistrict != 'All') {
        list = list.where((d) => d.district.toLowerCase() == selectedDistrict.toLowerCase()).toList();
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        list = list.where((d) =>
            d.name.toLowerCase().contains(q) ||
            d.specialty.toLowerCase().contains(q) ||
            d.hospital.toLowerCase().contains(q) ||
            d.district.toLowerCase().contains(q)).toList();
      }

      // Sort by highest average rating
      list.sort((a, b) => b.averageRating.compareTo(a.averageRating));

      return list;
    });
  }

  // Add Doctor
  Future<void> addDoctor(DoctorModel doctor) async {
    final docRef = _doctorsRef.doc();
    final newDoctor = doctor.copyWith(doctorId: docRef.id);
    await docRef.set(newDoctor.toMap());
  }

  // Edit Doctor
  Future<void> updateDoctor(DoctorModel doctor) async {
    await _doctorsRef.doc(doctor.doctorId).update(doctor.toMap());
  }

  // Delete Doctor
  Future<void> deleteDoctor(String doctorId) async {
    await _doctorsRef.doc(doctorId).delete();
  }

  // Stream Reviews for Doctor
  Stream<List<ReviewModel>> streamReviews(String doctorId) {
    return _reviewsRef
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs.map((doc) {
        return ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return reviews;
    });
  }

  // Add Review with Transactional recalculation of Doctor averageRating and totalReviews
  Future<void> addReview({
    required String doctorId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    final reviewRef = _reviewsRef.doc();
    final doctorRef = _doctorsRef.doc(doctorId);

    await _firestore.runTransaction((transaction) async {
      final doctorDoc = await transaction.get(doctorRef);
      if (!doctorDoc.exists) {
        throw Exception("Doctor profile not found.");
      }

      final doctorData = doctorDoc.data() as Map<String, dynamic>;
      final currentAvg = (doctorData['averageRating'] is num) ? (doctorData['averageRating'] as num).toDouble() : 0.0;
      final currentTotal = (doctorData['totalReviews'] is num) ? (doctorData['totalReviews'] as num).toInt() : 0;

      final newTotal = currentTotal + 1;
      final newAvg = ((currentAvg * currentTotal) + rating) / newTotal;

      final newReview = ReviewModel(
        reviewId: reviewRef.id,
        doctorId: doctorId,
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        timestamp: DateTime.now(),
      );

      transaction.set(reviewRef, newReview.toMap());
      transaction.update(doctorRef, {
        'averageRating': double.parse(newAvg.toStringAsFixed(1)),
        'totalReviews': newTotal,
      });
    });
  }

  // Stream All Reviews (for Admin Content Moderation)
  Stream<List<ReviewModel>> streamAllReviews() {
    return _reviewsRef.snapshots().map((snapshot) {
      final reviews = snapshot.docs.map((doc) {
        return ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return reviews;
    });
  }

  // Delete Review (Admin action)
  Future<void> deleteReview(String reviewId) async {
    await _reviewsRef.doc(reviewId).delete();
  }

  // Stream All Users (for Admin Dashboard)
  Stream<List<UserModel>> streamAllUsers() {
    return _usersRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Toggle User Ban Status
  Future<void> setUserBanStatus(String uid, bool isBanned) async {
    await _usersRef.doc(uid).update({'isBanned': isBanned});
  }

  // Toggle User Role
  Future<void> setUserRole(String uid, String role) async {
    await _usersRef.doc(uid).update({'role': role});
  }
}
