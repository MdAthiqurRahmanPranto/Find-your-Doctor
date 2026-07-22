import 'package:flutter/material.dart';
import '../../models/doctor_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';

class AddDoctorDialog extends StatefulWidget {
  final DoctorModel? existingDoctor;
  final String currentUserId;

  const AddDoctorDialog({
    super.key,
    this.existingDoctor,
    required this.currentUserId,
  });

  @override
  State<AddDoctorDialog> createState() => _AddDoctorDialogState();
}

class _AddDoctorDialogState extends State<AddDoctorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _specialtyController;
  late TextEditingController _hospitalController;
  late TextEditingController _districtController;

  bool _isSaving = false;

  final List<String> _commonSpecialties = [
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Pediatrics',
    'Orthopedics',
    'Gynecology',
    'Ophthalmology',
    'General Medicine',
  ];

  final List<String> _commonDistricts = [
    'Dhaka',
    'Chittagong',
    'Sylhet',
    'Rajshahi',
    'Khulna',
    'Barisal',
    'Rangpur',
    'Mymensingh',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingDoctor?.name ?? '');
    _specialtyController = TextEditingController(text: widget.existingDoctor?.specialty ?? 'General Medicine');
    _hospitalController = TextEditingController(text: widget.existingDoctor?.hospital ?? '');
    _districtController = TextEditingController(text: widget.existingDoctor?.district ?? 'Dhaka');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _hospitalController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _saveDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final firestoreService = FirestoreService();

    try {
      if (widget.existingDoctor == null) {
        final newDoctor = DoctorModel(
          doctorId: '',
          name: _nameController.text.trim(),
          specialty: _specialtyController.text.trim(),
          hospital: _hospitalController.text.trim(),
          district: _districtController.text.trim(),
          averageRating: 0.0,
          totalReviews: 0,
          createdBy: widget.currentUserId,
        );
        await firestoreService.addDoctor(newDoctor);
      } else {
        final updated = widget.existingDoctor!.copyWith(
          name: _nameController.text.trim(),
          specialty: _specialtyController.text.trim(),
          hospital: _hospitalController.text.trim(),
          district: _districtController.text.trim(),
        );
        await firestoreService.updateDoctor(updated);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving doctor: $e"), backgroundColor: AppTheme.dangerRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingDoctor != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.darkSurface,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(28.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? "Edit Doctor Profile" : "Add New Doctor",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondaryDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Doctor Name
              const Text("Doctor Name", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: "e.g. Dr. Alexander Fleming"),
                validator: (val) => val == null || val.trim().isEmpty ? "Doctor name is required" : null,
              ),
              const SizedBox(height: 16),

              // Specialty Dropdown / Text
              const Text("Specialty", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _commonSpecialties.contains(_specialtyController.text) ? _specialtyController.text : _commonSpecialties.first,
                dropdownColor: AppTheme.darkBackground,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(),
                items: _commonSpecialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _specialtyController.text = val);
                },
              ),
              const SizedBox(height: 16),

              // Hospital Name
              const Text("Hospital / Clinic Name", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _hospitalController,
                decoration: const InputDecoration(hintText: "e.g. City General Hospital"),
                validator: (val) => val == null || val.trim().isEmpty ? "Hospital name is required" : null,
              ),
              const SizedBox(height: 16),

              // District Dropdown
              const Text("District", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _commonDistricts.contains(_districtController.text) ? _districtController.text : _commonDistricts.first,
                dropdownColor: AppTheme.darkBackground,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(),
                items: _commonDistricts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _districtController.text = val);
                },
              ),
              const SizedBox(height: 28),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: AppTheme.textSecondaryDark)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveDoctor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(isEdit ? "Save Changes" : "Add Doctor"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
