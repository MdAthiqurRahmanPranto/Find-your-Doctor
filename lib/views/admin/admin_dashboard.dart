import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/doctor_model.dart';
import '../../models/review_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive_layout.dart';
import '../widgets/ban_notification_banner.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUserModel;
    final isMobile = ResponsiveLayout.isMobile(context);

    // Strict Admin Access Guard
    if (currentUser == null || !currentUser.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text("Access Restricted"), backgroundColor: AppTheme.darkSurface),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              color: AppTheme.darkSurface,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined, color: AppTheme.dangerRed, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      "Administrator Access Required",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "This section is strictly restricted to accounts with administrator privileges.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondaryDark),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Return to Home"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.accentCyan, size: 24),
            ),
            const SizedBox(width: 12),
            const Text("Web Admin Dashboard"),
          ],
        ),
        backgroundColor: AppTheme.darkSurface,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentCyan,
          labelColor: AppTheme.accentCyan,
          unselectedLabelColor: AppTheme.textSecondaryDark,
          tabs: const [
            Tab(
              icon: Icon(Icons.people_alt_rounded),
              text: "User Management",
            ),
            Tab(
              icon: Icon(Icons.cleaning_services_rounded),
              text: "Content Moderation",
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const BanNotificationBanner(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _UserManagementTab(isMobile: isMobile),
                _ContentModerationTab(isMobile: isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// TAB 1: User Management with real-time Ban / Unban Toggle Switch
class _UserManagementTab extends StatelessWidget {
  final bool isMobile;

  const _UserManagementTab({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<UserModel>>(
      stream: firestoreService.streamAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(
            child: Text("No registered users found in database.", style: TextStyle(color: AppTheme.textSecondaryDark)),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Registered User Accounts",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            "Total Users: ${users.length}",
                            style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Users Table View
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: users.length,
                        separatorBuilder: (context, index) => const Divider(color: Color(0xFF334155)),
                        itemBuilder: (context, index) {
                          final u = users[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: u.isBanned
                                      ? AppTheme.dangerRed.withOpacity(0.2)
                                      : (u.isAdmin ? AppTheme.accentCyan.withOpacity(0.2) : AppTheme.primaryTeal.withOpacity(0.2)),
                                  child: Icon(
                                    u.isBanned ? Icons.block_rounded : (u.isAdmin ? Icons.shield_rounded : Icons.person_rounded),
                                    color: u.isBanned ? AppTheme.dangerRed : (u.isAdmin ? AppTheme.accentCyan : AppTheme.primaryTealLight),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // User Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            u.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: (u.isAdmin ? AppTheme.accentCyan : AppTheme.primaryTeal).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              u.role.toUpperCase(),
                                              style: TextStyle(
                                                color: u.isAdmin ? AppTheme.accentCyan : AppTheme.primaryTealLight,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${u.email} • Registered ${DateFormat.yMMMd().format(u.createdAt)}",
                                        style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),

                                // Real-Time Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: u.isBanned ? AppTheme.dangerRed.withOpacity(0.2) : AppTheme.successGreen.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: u.isBanned ? AppTheme.dangerRed : AppTheme.successGreen,
                                    ),
                                  ),
                                  child: Text(
                                    u.isBanned ? "RESTRICTED / BANNED" : "ACTIVE",
                                    style: TextStyle(
                                      color: u.isBanned ? AppTheme.dangerRed : AppTheme.successGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),

                                // Interactive Ban / Unban Toggle Switch
                                Column(
                                  children: [
                                    Switch(
                                      value: u.isBanned,
                                      activeColor: AppTheme.dangerRed,
                                      inactiveThumbColor: AppTheme.successGreen,
                                      inactiveTrackColor: AppTheme.successGreen.withOpacity(0.3),
                                      onChanged: (bool isBanned) async {
                                        await firestoreService.setUserBanStatus(u.uid, isBanned);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(isBanned
                                                  ? "Account restricted: ${u.email}"
                                                  : "Account restored: ${u.email}"),
                                              backgroundColor: isBanned ? AppTheme.dangerRed : AppTheme.successGreen,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    Text(
                                      u.isBanned ? "Banned" : "Active",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: u.isBanned ? AppTheme.dangerRed : AppTheme.textSecondaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// TAB 2: Content Moderation for deleting fake doctors & inappropriate reviews
class _ContentModerationTab extends StatelessWidget {
  final bool isMobile;

  const _ContentModerationTab({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Doctor Listings Moderation
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.local_hospital_rounded, color: AppTheme.primaryTealLight),
                          SizedBox(width: 10),
                          Text(
                            "Doctor Entries Moderation",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Delete fake or invalid doctor profiles submitted to the platform.",
                        style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
                      ),
                      const SizedBox(height: 16),

                      StreamBuilder<List<DoctorModel>>(
                        stream: firestoreService.streamDoctors(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final doctors = snapshot.data ?? [];
                          if (doctors.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text("No doctor profiles found.", style: TextStyle(color: AppTheme.textSecondaryDark)),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: doctors.length,
                            separatorBuilder: (context, index) => const Divider(color: Color(0xFF334155)),
                            itemBuilder: (context, index) {
                              final d = doctors[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primaryTeal.withOpacity(0.2),
                                  child: Text(d.name.isNotEmpty ? d.name.replaceFirst("Dr. ", "").substring(0, 1) : "D",
                                      style: const TextStyle(color: AppTheme.primaryTealLight, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(d.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                subtitle: Text("${d.specialty} • ${d.hospital}, ${d.district}",
                                    style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_forever_rounded, color: AppTheme.dangerRed),
                                  tooltip: "Delete Doctor Profile",
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor: AppTheme.darkSurface,
                                        title: const Text("Confirm Deletion", style: TextStyle(color: Colors.white)),
                                        content: Text("Are you sure you want to delete profile '${d.name}'?",
                                            style: const TextStyle(color: AppTheme.textSecondaryDark)),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await firestoreService.deleteDoctor(d.doctorId);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Deleted doctor profile: ${d.name}"), backgroundColor: AppTheme.dangerRed),
                                        );
                                      }
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Section 2: Patient Reviews Moderation
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.rate_review_rounded, color: AppTheme.warningAmber),
                          SizedBox(width: 10),
                          Text(
                            "Patient Reviews Moderation",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Remove inappropriate, offensive, or spam reviews from the system.",
                        style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
                      ),
                      const SizedBox(height: 16),

                      StreamBuilder<List<ReviewModel>>(
                        stream: firestoreService.streamAllReviews(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final reviews = snapshot.data ?? [];
                          if (reviews.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text("No patient reviews found.", style: TextStyle(color: AppTheme.textSecondaryDark)),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            separatorBuilder: (context, index) => const Divider(color: Color(0xFF334155)),
                            itemBuilder: (context, index) {
                              final r = reviews[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.warningAmber.withOpacity(0.2),
                                  child: Text("${r.rating.toInt()}★",
                                      style: const TextStyle(color: AppTheme.warningAmber, fontWeight: FontWeight.bold)),
                                ),
                                title: Text("${r.userName} • Rated ${r.rating} / 5.0",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text(r.comment,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.dangerRed),
                                  tooltip: "Remove Review",
                                  onPressed: () async {
                                    await firestoreService.deleteReview(r.reviewId);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Removed review entry."), backgroundColor: AppTheme.dangerRed),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
