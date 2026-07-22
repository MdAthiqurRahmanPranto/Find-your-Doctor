import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/doctor_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive_layout.dart';
import '../admin/admin_dashboard.dart';
import '../auth/login_screen.dart';
import '../doctor/add_doctor_dialog.dart';
import '../doctor/doctor_card.dart';
import '../widgets/ban_notification_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _selectedSpecialty = 'All';
  String _selectedDistrict = 'All';

  final List<String> _specialties = [
    'All',
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Pediatrics',
    'Orthopedics',
    'Gynecology',
    'Ophthalmology',
    'General Medicine',
  ];

  final List<String> _districts = [
    'All',
    'Dhaka',
    'Chittagong',
    'Sylhet',
    'Rajshahi',
    'Khulna',
    'Barisal',
    'Rangpur',
    'Mymensingh',
  ];

  // Pre-populated default list for rich initial rendering in Bangladesh
  final List<DoctorModel> _defaultDoctors = [
    DoctorModel(
      doctorId: 'doc_1',
      name: 'Dr. Mahfuzur Rahman',
      specialty: 'Cardiology',
      hospital: 'Square Hospital, Panthapath',
      district: 'Dhaka',
      averageRating: 4.8,
      totalReviews: 24,
      createdBy: 'admin',
    ),
    DoctorModel(
      doctorId: 'doc_2',
      name: 'Dr. Nusrat Jahan',
      specialty: 'Pediatrics',
      hospital: 'Chittagong Medical College Hospital',
      district: 'Chittagong',
      averageRating: 4.9,
      totalReviews: 31,
      createdBy: 'admin',
    ),
    DoctorModel(
      doctorId: 'doc_3',
      name: 'Dr. Tanvir Ahmed',
      specialty: 'Neurology',
      hospital: 'LABAID Specialized Hospital',
      district: 'Dhaka',
      averageRating: 4.7,
      totalReviews: 18,
      createdBy: 'admin',
    ),
    DoctorModel(
      doctorId: 'doc_4',
      name: 'Dr. Farhana Chowdhury',
      specialty: 'Gynecology',
      hospital: 'Mount Adora Hospital, Akhalia',
      district: 'Sylhet',
      averageRating: 4.9,
      totalReviews: 42,
      createdBy: 'admin',
    ),
    DoctorModel(
      doctorId: 'doc_5',
      name: 'Dr. Rafiqul Islam',
      specialty: 'Orthopedics',
      hospital: 'Rajshahi Royal Hospital',
      district: 'Rajshahi',
      averageRating: 4.6,
      totalReviews: 15,
      createdBy: 'admin',
    ),
    DoctorModel(
      doctorId: 'doc_6',
      name: 'Dr. Anika Tabassum',
      specialty: 'Dermatology',
      hospital: 'Evercare Hospital, Bashundhara',
      district: 'Dhaka',
      averageRating: 4.8,
      totalReviews: 29,
      createdBy: 'admin',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddDoctorModal(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AddDoctorDialog(currentUserId: userId),
    );
  }

  List<DoctorModel> _filterDoctors(List<DoctorModel> list) {
    var result = list;

    if (_selectedSpecialty != 'All') {
      result = result.where((d) => d.specialty.toLowerCase() == _selectedSpecialty.toLowerCase()).toList();
    }

    if (_selectedDistrict != 'All') {
      result = result.where((d) => d.district.toLowerCase() == _selectedDistrict.toLowerCase()).toList();
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((d) =>
          d.name.toLowerCase().contains(query) ||
          d.specialty.toLowerCase().contains(query) ||
          d.hospital.toLowerCase().contains(query) ||
          d.district.toLowerCase().contains(query)).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUserModel;
    final firestoreService = FirestoreService();

    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      drawer: isMobile ? _buildMobileDrawer(context, authService, user) : null,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_hospital_rounded, color: AppTheme.primaryTealLight, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              "Find Your Doctor",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: isMobile
            ? null
            : [
                // Header button for logged-in users to '+ Add Doctor'
                if (user != null) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      if (user.isBanned) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Your account has been restricted by an administrator."),
                            backgroundColor: AppTheme.dangerRed,
                          ),
                        );
                      } else {
                        _openAddDoctorModal(context, user.uid);
                      }
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text("+ Add Doctor"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (user.isAdmin) ...[
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
                      },
                      icon: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.accentCyan, size: 20),
                      label: const Text("Admin Panel", style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Chip(
                    avatar: CircleAvatar(
                      backgroundColor: AppTheme.primaryTeal,
                      child: Text(user.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    label: Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    backgroundColor: AppTheme.darkSurface,
                    side: const BorderSide(color: Color(0xFF334155)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.dangerRed),
                    tooltip: "Sign Out",
                    onPressed: () async => await authService.signOut(),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: const Text("Sign In"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkSurface,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
                const SizedBox(width: 20),
              ],
      ),
      body: Column(
        children: [
          const BanNotificationBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64.0 : (isMobile ? 16.0 : 32.0),
                vertical: 24.0,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Prominent Hero Search Banner
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isMobile ? 24.0 : 40.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF334155)),
                          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 16)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryTeal.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.primaryTealLight.withOpacity(0.5)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified_rounded, color: AppTheme.primaryTealLight, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        "Bangladesh Doctor Directory",
                                        style: TextStyle(
                                          color: AppTheme.primaryTealLight,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              "Find Specialist Doctors in Bangladesh",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Search instantly by doctor name, specialty, hospital, or district (Dhaka, Chittagong, Sylhet & more).",
                              style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 15),
                            ),
                            const SizedBox(height: 24),

                            // Interactive Search Bar
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.primaryTealLight.withOpacity(0.6), width: 1.5),
                                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) => setState(() {}),
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: "Search by Doctor Name, Specialty, Hospital, or District...",
                                  hintStyle: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 15),
                                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryTealLight, size: 24),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded, color: AppTheme.textSecondaryDark),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Specialty & District Filters Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Specialty & Location Filters",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          // District Filter Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.darkSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: AppTheme.primaryTealLight),
                                const SizedBox(width: 8),
                                DropdownButton<String>(
                                  value: _selectedDistrict,
                                  dropdownColor: AppTheme.darkBackground,
                                  underline: const SizedBox.shrink(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                  items: _districts
                                      .map((d) => DropdownMenuItem(
                                            value: d,
                                            child: Text(d == 'All' ? "All Districts" : "District: $d"),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedDistrict = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Specialty Pills Horizontal Scroll
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _specialties.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final spec = _specialties[index];
                            final isSelected = _selectedSpecialty == spec;
                            return ChoiceChip(
                              label: Text(spec),
                              selected: isSelected,
                              selectedColor: AppTheme.primaryTeal,
                              backgroundColor: AppTheme.darkSurface,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textSecondaryDark,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (selected) {
                                if (selected) setState(() => _selectedSpecialty = spec);
                              },
                              side: BorderSide(
                                color: isSelected ? AppTheme.primaryTealLight : const Color(0xFF334155),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Section Title & '+ Add Doctor' button for logged-in users
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Available Doctors",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (user == null) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                              } else if (user.isBanned) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Your account has been restricted by an administrator."),
                                    backgroundColor: AppTheme.dangerRed,
                                  ),
                                );
                              } else {
                                _openAddDoctorModal(context, user.uid);
                              }
                            },
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text("+ Add Doctor"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryTeal,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Responsive Doctors Grid (Stream from Firestore with pre-populated fallback)
                      StreamBuilder<List<DoctorModel>>(
                        stream: firestoreService.streamDoctors(
                          searchQuery: _searchController.text,
                          selectedSpecialty: _selectedSpecialty,
                          selectedDistrict: _selectedDistrict,
                        ),
                        builder: (context, snapshot) {
                          List<DoctorModel> rawList = _defaultDoctors;
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            rawList = snapshot.data!;
                          }

                          final filteredList = _filterDoctors(rawList);

                          if (filteredList.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(48.0),
                              decoration: BoxDecoration(
                                color: AppTheme.darkSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF334155)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textSecondaryDark),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "No doctors match your criteria",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Try adjusting your search terms or district filter.",
                                    style: TextStyle(color: AppTheme.textSecondaryDark),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _selectedSpecialty = 'All';
                                        _selectedDistrict = 'All';
                                      });
                                    },
                                    child: const Text("Reset Search"),
                                  ),
                                ],
                              ),
                            );
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isDesktop ? 3 : (isMobile ? 1 : 2),
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: 1.45,
                            ),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              return DoctorCard(doctor: filteredList[index]);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context, AuthService authService, UserModel? user) {
    return Drawer(
      backgroundColor: AppTheme.darkBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.darkSurface,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_hospital_rounded, color: AppTheme.primaryTealLight, size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Find Your Doctor",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (user != null) ...[
                  Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(user.email, style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
                ] else ...[
                  const Text("Welcome Guest", style: TextStyle(color: AppTheme.textSecondaryDark)),
                ],
              ],
            ),
          ),
          if (user != null) ...[
            ListTile(
              leading: const Icon(Icons.add_rounded, color: AppTheme.primaryTealLight),
              title: const Text("+ Add Doctor Profile", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _openAddDoctorModal(context, user.uid);
              },
            ),
            if (user.isAdmin)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.accentCyan),
                title: const Text("Admin Dashboard", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppTheme.dangerRed),
              title: const Text("Sign Out", style: TextStyle(color: AppTheme.dangerRed)),
              onTap: () async {
                Navigator.pop(context);
                await authService.signOut();
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.login_rounded, color: AppTheme.primaryTealLight),
              title: const Text("Sign In / Register", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
            ),
          ]
        ],
      ),
    );
  }
}
