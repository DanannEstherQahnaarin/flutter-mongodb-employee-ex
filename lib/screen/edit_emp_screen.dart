import 'package:flutter/material.dart';
import 'package:flutter_mongodb_employee_ex01/controller/edit_emp_controller.dart';
import 'package:flutter_mongodb_employee_ex01/model/model_employee.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditEmployeeScreen extends ConsumerStatefulWidget {
  final Employee employee; // 수정할 대상 데이터

  const EditEmployeeScreen({super.key, required this.employee});

  @override
  ConsumerState<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends ConsumerState<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _deptController;
  late TextEditingController _posController;
  late TextEditingController _salaryController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // 상태 선택용 변수
  late String _selectedStatus;
  final List<String> _statusOptions = ['ACTIVE', 'INACTIVE', 'LEAVE'];

  @override
  void initState() {
    super.initState();
    // 기존 데이터로 초기화
    _nameController = TextEditingController(text: widget.employee.name);
    _deptController = TextEditingController(text: widget.employee.department);
    _posController = TextEditingController(text: widget.employee.position);
    _salaryController = TextEditingController(
      text: widget.employee.salary.toString(),
    );
    _emailController = TextEditingController(text: widget.employee.email);
    _phoneController = TextEditingController(text: widget.employee.phone);
    _selectedStatus = widget.employee.status;
  }

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

  void _onUpdate() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(editEmployeeControllerProvider.notifier)
          .updateEmployee(
            originalEmployee: widget.employee,
            name: _nameController.text,
            department: _deptController.text,
            position: _posController.text,
            salary: _salaryController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            status: _selectedStatus,
          );
    }
  }

  Future<void> _onDelete() async {
    // 1. 확인 다이얼로그 띄우기
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text('${widget.employee.name} 직원을 정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // 취소
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // 확인
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // 2. 사용자가 '삭제'를 눌렀다면 Controller 호출
    if (confirm == true) {
      // widget.employee.id! : 모델에서 id는 nullable이지만 DB에서 가져온 데이터는 무조건 id가 있음
      ref
          .read(editEmployeeControllerProvider.notifier)
          .deleteEmployee(widget.employee.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editEmployeeControllerProvider);

    ref.listen<AsyncValue<void>>(editEmployeeControllerProvider, (prev, next) {
      next.when(
        data: (_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('수정 완료!')));
          Navigator.pop(context); // 목록으로 복귀
        },
        error: (err, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('에러: $err'), backgroundColor: Colors.red),
          );
        },
        loading: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.employee.name} 정보 수정'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: state.isLoading ? null : _onDelete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 상태 변경 드롭다운 추가
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: '상태 (Status)',
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: 12),

              _buildTextField(_nameController, '이름'),
              _buildTextField(_deptController, '부서'),
              _buildTextField(_posController, '직급'),
              _buildTextField(_salaryController, '급여', isNumber: true),
              _buildTextField(_emailController, '이메일'),
              _buildTextField(_phoneController, '연락처'),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: state.isLoading ? null : _onUpdate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: state.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('수정 완료', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
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
        validator: (val) => val!.isEmpty ? '입력해주세요' : null,
      ),
    );
  }
}
