import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Doctor Search Input and Button Render Test', (WidgetTester tester) async {
    
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TextField(
                key: Key('search_field'),
                decoration: InputDecoration(hintText: 'Search Doctor...'),
              ),
              ElevatedButton(
                onPressed: null,
                child: Text('Book Appointment'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('search_field')), findsOneWidget);
    expect(find.text('Search Doctor...'), findsOneWidget);
    expect(find.text('Book Appointment'), findsOneWidget);

   
    await tester.enterText(find.byKey(const Key('search_field')), 'Dr. Smith');
    await tester.pump(); // Frame update rebuild

    expect(find.text('Dr. Smith'), findsOneWidget);
  });
}