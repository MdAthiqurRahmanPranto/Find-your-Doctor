import 'package:flutter/material.dart';
import '../../models/doctor_model.dart';
import '../../utils/app_theme.dart';
import 'doctor_detail_screen.dart';

class DoctorCard extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black38,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailScreen(doctorId: doctor.doctorId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryTeal, AppTheme.accentCyan],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            doctor.name.isNotEmpty ? doctor.name.replaceFirst("Dr. ", "").substring(0, 1).toUpperCase() : "D",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryTeal.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                doctor.specialty,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryTealLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Hospital & District Info
                  Row(
                    children: [
                      const Icon(Icons.local_hospital_outlined, size: 16, color: AppTheme.textSecondaryDark),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          doctor.hospital,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondaryDark),
                      const SizedBox(width: 6),
                      Text(
                        doctor.district,
                        style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Rating and Reviews Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppTheme.warningAmber, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          doctor.averageRating > 0
                              ? "⭐ ${doctor.averageRating.toStringAsFixed(1)} / 5.0"
                              : "⭐ New Doctor",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "from ${doctor.totalReviews} ${doctor.totalReviews == 1 ? 'review' : 'reviews'}",
                          style: const TextStyle(
                            color: AppTheme.textSecondaryDark,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppTheme.primaryTealLight),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
