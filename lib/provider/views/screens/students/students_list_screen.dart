import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';

class StudentsListScreen extends StatefulWidget {
  final String courseId;

  const StudentsListScreen({super.key, required this.courseId});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final users = await _supabaseService.getStudentsByCourse(widget.courseId);
      setState(() {
        _students = users.map((u) => {
          'id': u.id,
          'name': u.name,
          'email': u.email,
          'phone': u.phone ?? '',
          'avatar': u.avatar ?? '',
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'فشل في جلب قائمة الطلاب';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'قائمة الطلاب'),
        body: _isLoading
            ? const LoadingWidget(message: 'جاري تحميل الطلاب...')
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: AppTheme.redDanger),
                        const SizedBox(height: 16),
                        Text(_error!, style: const TextStyle(color: AppTheme.redDanger)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadStudents, child: const Text('إعادة المحاولة')),
                      ],
                    ),
                  )
                : _students.isEmpty
                    ? const EmptyState(
                        title: 'لا يوجد طلاب',
                        message: 'لم يسجل أي طالب في هذه الدورة بعد',
                        icon: Icons.people_outline,
                      )
                    : RefreshIndicator(
                        color: AppTheme.primaryDarkBlue,
                        onRefresh: _loadStudents,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            return _buildStudentItem(student, index + 1);
                          },
                        ),
                      ),
      ),
    );
  }

  Widget _buildStudentItem(Map<String, dynamic> student, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryDarkBlue.withOpacity(0.1),
            backgroundImage: student['avatar'].isNotEmpty ? NetworkImage(student['avatar']) : null,
            child: student['avatar'].isEmpty
                ? Text(
                    student['name'].toString().isNotEmpty ? student['name'][0] : '#',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'] ?? '',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryDarkBlue),
                ),
                const SizedBox(height: 4),
                Text(
                  student['email'] ?? '',
                  style: const TextStyle(fontSize: 12, color: AppTheme.darkGrayText),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryDarkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
