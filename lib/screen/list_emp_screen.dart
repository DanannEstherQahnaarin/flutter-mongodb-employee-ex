import 'package:flutter/material.dart';
import 'package:flutter_mongodb_employee_ex01/controller/list_emp_controller.dart';
import 'package:flutter_mongodb_employee_ex01/screen/add_emp_screen.dart';
import 'package:flutter_mongodb_employee_ex01/screen/edit_emp_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controller의 상태 구독 (data, loading, error)
    final asyncEmployees = ref.watch(employeeListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('직원 관리 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // 수동 새로고침
              ref.read(employeeListControllerProvider.notifier).refreshList();
            },
          ),
        ],
      ),
      // AsyncValue.when을 사용하여 3가지 상태 처리
      body: asyncEmployees.when(
        // 1. 로딩 중일 때
        loading: () => const Center(child: CircularProgressIndicator()),

        // 2. 에러 발생 시
        error: (err, stack) => Center(child: Text('에러 발생: $err')),

        // 3. 데이터 로드 성공 시
        data: (employees) {
          if (employees.isEmpty) {
            return const Center(child: Text('등록된 직원이 없습니다.'));
          }
          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(employee.name[0]), // 이름 첫 글자
                  ),
                  title: Text(
                    '${employee.name} (${employee.position})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${employee.department} | ${employee.email}'),
                  trailing: Text(
                    employee.status,
                    style: TextStyle(
                      color: employee.status == 'ACTIVE'
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // 클릭 시 상세/수정 화면으로 이동 (다음 단계 구현 예정)
                  onTap: () async {
                    // 1. 수정 화면으로 이동 (`edit_employee_screen.dart` import 필요)
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditEmployeeScreen(employee: employee),
                      ),
                    );
                    // 2. 돌아오면 목록 새로고침 (데이터가 수정되었을 수 있으므로)
                    ref
                        .read(employeeListControllerProvider.notifier)
                        .refreshList();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // 등록 화면으로 이동
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
          );
          // 등록 화면에서 돌아오면 목록 새로고침
          ref.read(employeeListControllerProvider.notifier).refreshList();
        },
      ),
    );
  }
}
