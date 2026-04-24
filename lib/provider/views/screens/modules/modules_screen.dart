import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/module_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/confirmation_dialog.dart';

class ModulesScreen extends StatefulWidget {
  final String courseId;

  const ModulesScreen({super.key, required this.courseId});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    await context.read<ModuleProvider>().loadModules(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'إدارة الوحدات'),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await context.push('/courses/${widget.courseId}/modules/new');
            _loadModules();
          },
          backgroundColor: AppTheme.primaryDarkBlue,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('إضافة وحدة', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Consumer<ModuleProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingWidget(message: 'جاري تحميل الوحدات...');
            }
            if (provider.modules.isEmpty) {
              return EmptyState(
                title: 'لا توجد وحدات',
                message: 'ابدأ بإضافة وحدات جديدة لتنظيم محتوى دورتك',
                icon: Icons.view_module_outlined,
                buttonText: 'إضافة وحدة جديدة',
                onButtonPressed: () async {
                  await context.push('/courses/${widget.courseId}/modules/new');
                  _loadModules();
                },
              );
            }
            return ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.modules.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = provider.modules.removeAt(oldIndex);
                  provider.modules.insert(newIndex, item);
                });
                provider.reorderModules();
              },
              proxyDecorator: (child, index, animation) {
                return Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final module = provider.modules[index];
                return Container(
                  key: ValueKey(module.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDarkBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDarkBlue,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      module.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryDarkBlue,
                      ),
                    ),
                    subtitle: Text(
                      '${module.lessonsCount ?? 0} درس',
                      style: const TextStyle(fontSize: 12, color: AppTheme.darkGrayText),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.article_outlined, size: 20, color: AppTheme.blueInfo),
                          onPressed: () => context.push(
                            '/courses/${widget.courseId}/modules/${module.id}/lessons',
                          ),
                          tooltip: 'الدروس',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primaryDarkBlue),
                          onPressed: () async {
                            await context.push(
                              '/courses/${widget.courseId}/modules/${module.id}/edit',
                            );
                            _loadModules();
                          },
                          tooltip: 'تعديل',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.redDanger),
                          onPressed: () async {
                            final confirm = await ConfirmationDialog.show(
                              context,
                              title: 'حذف الوحدة',
                              message: 'هل أنت متأكد من حذف هذه الوحدة؟ سيتم حذف جميع الدروس المرتبطة بها.',
                              isDanger: true,
                              confirmText: 'حذف',
                            );
                            if (confirm == true) {
                              await provider.deleteModule(module.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تم حذف الوحدة'), backgroundColor: AppTheme.greenSuccess),
                                );
                              }
                            }
                          },
                          tooltip: 'حذف',
                        ),
                        const Icon(Icons.drag_handle, color: AppTheme.darkGrayText),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
