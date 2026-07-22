import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/doctor_model.dart';
import '../../models/review_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive_layout.dart';
import '../auth/login_screen.dart';
import '../widgets/ban_notification_banner.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String doctorId;

  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  final _commentController = TextEditingController();
  double _userRating = 5.0;
  bool _isSubmittingReview = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview(DoctorModel doctor) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUserModel;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please sign in to post a review."),
          action: SnackBarAction(
            label: "Sign In",
            textColor: AppTheme.primaryTealLight,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ),
      );
      return;
    }

    if (currentUser.isBanned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your account has been restricted by an administrator."),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write a review comment.")),
      );
      return;
    }

    setState(() => _isSubmittingReview = true);
    final firestoreService = FirestoreService();

    try {
      // Execute Firestore Transaction recalculating averageRating and totalReviews
      await firestoreService.addReview(
        doctorId: doctor.doctorId,
        userId: currentUser.uid,
        userName: currentUser.name,
        rating: _userRating,
        comment: _commentController.text.trim(),
      );

      _commentController.clear();
      setState(() => _userRating = 5.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thank you! Your review has been published and rating re-calculated."),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit review: $e"), backgroundColor: AppTheme.dangerRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingReview = false);
    }
  }

  Widget _buildRatingDistributionBar(int star, int count, int total) {
    final pct = total > 0 ? (count / total) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text("$star ★", style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: const Color(0xFF0F172A),
                color: AppTheme.warningAmber,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text("$count", style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Profile & Reviews"),
        backgroundColor: AppTheme.darkSurface,
      ),
      body: Column(
        children: [
          const BanNotificationBanner(),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('doctors').doc(widget.doctorId).snapshots(),
              builder: (context, snapshot) {
                // Fallback doctor object if live document isn't loaded yet
                DoctorModel doctor = DoctorModel(
                  doctorId: widget.doctorId,
                  name: "Dr. Medical Specialist",
                  specialty: "General Medicine",
                  hospital: "Central Hospital",
                  district: "Dhaka",
                  averageRating: 4.8,
                  totalReviews: 12,
                  createdBy: "admin",
                );

                if (snapshot.hasData && snapshot.data!.exists && snapshot.data!.data() != null) {
                  doctor = DoctorModel.fromMap(
                    snapshot.data!.data() as Map<String, dynamic>,
                    snapshot.data!.id,
                  );
                }

                return StreamBuilder<List<ReviewModel>>(
                  stream: firestoreService.streamReviews(doctor.doctorId),
                  builder: (context, reviewSnap) {
                    final reviews = reviewSnap.data ?? [];

                    // Calculate distribution breakdown
                    final mapCount = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
                    for (var r in reviews) {
                      int rounded = r.rating.round();
                      if (rounded >= 1 && rounded <= 5) {
                        mapCount[rounded] = (mapCount[rounded] ?? 0) + 1;
                      }
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 64.0 : 20.0,
                        vertical: 24.0,
                      ),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Doctor Header Card
                              Card(
                                elevation: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(28.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 84,
                                        height: 84,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [AppTheme.primaryTeal, AppTheme.accentCyan],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: Text(
                                            doctor.name.isNotEmpty
                                                ? doctor.name.replaceFirst("Dr. ", "").substring(0, 1).toUpperCase()
                                                : "D",
                                            style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              doctor.name,
                                              style: const TextStyle(
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.primaryTeal.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    doctor.specialty,
                                                    style: const TextStyle(
                                                      color: AppTheme.primaryTealLight,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                const Icon(Icons.location_on_outlined, size: 18, color: AppTheme.textSecondaryDark),
                                                const SizedBox(width: 4),
                                                Text(
                                                  doctor.district,
                                                  style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const Icon(Icons.local_hospital_outlined, size: 18, color: AppTheme.textSecondaryDark),
                                                const SizedBox(width: 8),
                                                Text(
                                                  doctor.hospital,
                                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Star Rating Breakdown Card
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Row(
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            doctor.averageRating > 0 ? doctor.averageRating.toStringAsFixed(1) : "N/A",
                                            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white),
                                          ),
                                          RatingBarIndicator(
                                            rating: doctor.averageRating,
                                            itemBuilder: (context, index) => const Icon(Icons.star_rounded, color: AppTheme.warningAmber),
                                            itemCount: 5,
                                            itemSize: 20.0,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "${doctor.totalReviews} Total Reviews",
                                            style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 36),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            _buildRatingDistributionBar(5, mapCount[5]!, reviews.length),
                                            _buildRatingDistributionBar(4, mapCount[4]!, reviews.length),
                                            _buildRatingDistributionBar(3, mapCount[3]!, reviews.length),
                                            _buildRatingDistributionBar(2, mapCount[2]!, reviews.length),
                                            _buildRatingDistributionBar(1, mapCount[1]!, reviews.length),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Submit Review Card
                              Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Leave a Patient Star Rating & Review",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          const Text("Your Rating: ", style: TextStyle(color: AppTheme.textSecondaryDark)),
                                          const SizedBox(width: 12),
                                          RatingBar.builder(
                                            initialRating: _userRating,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemSize: 32,
                                            unratedColor: const Color(0xFF334155),
                                            itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                                            itemBuilder: (context, _) => const Icon(
                                              Icons.star_rounded,
                                              color: AppTheme.warningAmber,
                                            ),
                                            onRatingUpdate: (rating) {
                                              setState(() => _userRating = rating);
                                            },
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            "$_userRating / 5.0 Stars",
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.warningAmber),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _commentController,
                                        maxLines: 3,
                                        decoration: const InputDecoration(
                                          hintText: "Write your review comment (e.g. doctor's expertise, waiting time, staff behavior)...",
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton.icon(
                                          onPressed: _isSubmittingReview ? null : () => _submitReview(doctor),
                                          icon: _isSubmittingReview
                                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                              : const Icon(Icons.send_rounded, size: 18),
                                          label: const Text("Post Review"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Reviews Feed Section
                              const Text(
                                "Patient Reviews Feed",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 16),

                              if (reviews.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: AppTheme.darkSurface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFF334155)),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "No patient reviews yet. Be the first patient to rate and review this doctor!",
                                      style: TextStyle(color: AppTheme.textSecondaryDark),
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: reviews.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final r = reviews[index];
                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor: AppTheme.primaryTeal.withOpacity(0.2),
                                                      child: Text(
                                                        r.userName.isNotEmpty ? r.userName.substring(0, 1).toUpperCase() : "P",
                                                        style: const TextStyle(color: AppTheme.primaryTealLight, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          r.userName,
                                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                                        ),
                                                        Text(
                                                          DateFormat.yMMMd().format(r.timestamp),
                                                          style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.star_rounded, color: AppTheme.warningAmber, size: 18),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "${r.rating.toStringAsFixed(1)} / 5.0",
                                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              r.comment,
                                              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
