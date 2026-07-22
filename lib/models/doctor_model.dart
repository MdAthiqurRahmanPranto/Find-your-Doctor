class DoctorModel {
  final String doctorId;
  final String name;
  final String specialty;
  final String hospital;
  final String district;
  final double averageRating;
  final int totalReviews;
  final String createdBy;

  DoctorModel({
    required this.doctorId,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.district,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'name': name,
      'specialty': specialty,
      'hospital': hospital,
      'district': district,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'createdBy': createdBy,
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map, String id) {
    return DoctorModel(
      doctorId: id.isNotEmpty ? id : (map['doctorId'] ?? ''),
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
      hospital: map['hospital'] ?? '',
      district: map['district'] ?? '',
      averageRating: (map['averageRating'] is num) ? (map['averageRating'] as num).toDouble() : 0.0,
      totalReviews: (map['totalReviews'] is num) ? (map['totalReviews'] as num).toInt() : 0,
      createdBy: map['createdBy'] ?? '',
    );
  }

  DoctorModel copyWith({
    String? doctorId,
    String? name,
    String? specialty,
    String? hospital,
    String? district,
    double? averageRating,
    int? totalReviews,
    String? createdBy,
  }) {
    return DoctorModel(
      doctorId: doctorId ?? this.doctorId,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      hospital: hospital ?? this.hospital,
      district: district ?? this.district,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
