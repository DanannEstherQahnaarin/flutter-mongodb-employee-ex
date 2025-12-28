import 'package:flutter_mongodb_employee_ex01/model/model_employee.dart';
import 'package:flutter_mongodb_employee_ex01/repositories/employee_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// 상태 관리용 Controller (상태: 로딩 중, 성공, 실패 등을 관리)
class AddEmployeeController extends StateNotifier<AsyncValue<void>> {
  final EmployeeRepository _repository;

  AddEmployeeController(this._repository) : super(const AsyncValue.data(null));

  Future<void> addEmployee({
    required String name,
    required String department,
    required String position,
    required String salary,
    required String email,
    required String phone,
  }) async {
    // 1. 로딩 상태로 변경
    state = const AsyncValue.loading();

    try {
      // 2. 비즈니스 로직: 입력받은 String 데이터를 가공하여 객체 생성
      final newEmployee = Employee(
        id: null,
        empNo: DateTime.now().millisecondsSinceEpoch, // 임시 사번 생성 로직
        name: name,
        department: department,
        position: position,
        salary: int.tryParse(salary) ?? 0, // 숫자 변환 로직
        email: email,
        phone: phone,
        hireDate: DateTime.now(),
        status: 'ACTIVE',
        createdAt: DateTime.now(),
      );

      // 3. Repository 호출
      await _repository.insertEmployee(newEmployee);

      // 4. 성공 상태로 변경
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      // 5. 실패 상태로 변경
      state = AsyncValue.error(e, stack);
    }
  }
}

// UI에서 접근할 Provider 정의
final addEmployeeControllerProvider =
    StateNotifierProvider<AddEmployeeController, AsyncValue<void>>((ref) {
      final repository = ref.watch(employeeRepositoryProvider);
      return AddEmployeeController(repository);
    });
