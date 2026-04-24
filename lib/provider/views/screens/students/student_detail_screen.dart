import 'package:flutter/material.dart';
import '../../../widgets/custom_app_bar.dart';

class StudentDetailScreen extends StatelessWidget {
  const StudentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(title: 'تفاصيل الطالب'),
        body: Center(
          child: Text('تفاصيل الطالب'),
        ),
      ),
    );
  }
}
