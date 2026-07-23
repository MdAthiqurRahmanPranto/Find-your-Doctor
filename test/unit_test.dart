import 'package:flutter_test/flutter_test.dart';


List<String> filterDoctors(List<String> doctors, String query) {
  return doctors.where((doc) => doc.toLowerCase().contains(query.toLowerCase())).toList();
}

void main() {
  group('Doctor Search Unit Tests', () {
    final doctorList = ['Dr. Rahman (Cardiologist)', 'Dr. Ahmed (Neurologist)', 'Dr. Khan (Cardiologist)'];

    test('Should return matching doctors when valid query is provided', () {
      final result = filterDoctors(doctorList, 'Cardiologist');

      expect(result.length, 2);
      expect(result, contains('Dr. Rahman (Cardiologist)'));
    });

    test('Should return empty list when no doctor matches query', () {
      final result = filterDoctors(doctorList, 'Dermatologist');

      expect(result.isEmpty, isTrue);
    });
  });
}