import 'package:flutter/material.dart';
import 'package:flutter_mongodb_employee_ex01/controller/add_emp_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEmployeeScreen extends ConsumerStatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  ConsumerState<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends ConsumerState<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  // UI 로직: 텍스트 컨트롤러 관리
  final _nameController = TextEditingController();
  final _deptController = TextEditingController();
  final _posController = TextEditingController();
  final _salaryController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _deptController.dispose();
    _posController.dispose();
    _salaryController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      // Controller에게 요청만 보냄 (비즈니스 로직 위임)
      ref
          .read(addEmployeeControllerProvider.notifier)
          .addEmployee(
            name: _nameController.text,
            department: _deptController.text,
            position: _posController.text,
            salary: _salaryController.text,
            email: _emailController.text,
            phone: _phoneController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Controller의 상태 구독 (로딩 중인지 체크용)
    final state = ref.watch(addEmployeeControllerProvider);

    // 상태 변화 감지 (성공 시 화면 닫기, 에러 시 스낵바)
    ref.listen<AsyncValue<void>>(addEmployeeControllerProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('직원이 성공적으로 등록되었습니다!')));
          Navigator.pop(context); // 성공 시 뒤로 가기
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('에러 발생: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
        loading: () {}, // 로딩 중에는 별도 액션 없음 (UI에서 처리)
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('직원 등록')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(controller: _nameController, label: '이름 (Name)'),
              _buildTextField(
                controller: _deptController,
                label: '부서 (Department)',
              ),
              _buildTextField(
                controller: _posController,
                label: '직급 (Position)',
              ),
              _buildTextField(
                controller: _salaryController,
                label: '급여 (Salary)',
                isNumber: true,
              ),
              _buildTextField(
                controller: _emailController,
                label: '이메일 (Email)',
              ),
              _buildTextField(
                controller: _phoneController,
                label: '연락처 (Phone)',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                // 로딩 중이면 버튼 비활성화
                onPressed: state.isLoading ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('저장하기', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) =>
            (value == null || value.isEmpty) ? '입력해주세요' : null,
      ),
    );
  }
}
