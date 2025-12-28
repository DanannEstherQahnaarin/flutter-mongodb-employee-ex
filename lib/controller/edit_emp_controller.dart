import 'package:flutter_mongodb_employee_ex01/model/model_employee.dart';
import 'package:flutter_mongodb_employee_ex01/repositories/employee_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mongo_dart/mongo_dart.dart';

class EditEmployeeController extends StateNotifier<AsyncValue<void>> {
  final EmployeeRepository _repository;

  EditEmployeeController(this._repository) : super(const AsyncValue.data(null));

  Future<void> updateEmployee({
    required Employee originalEmployee, // 수정 전 원본 데이터 (ID 유지용)
    required String name,
    required String department,
    required String position,
    required String salary,
    required String email,
    required String phone,
    required String status,
  }) async {
    state = const AsyncValue.loading();

    try {
      // 1. 기존 데이터 + 수정된 데이터로 새 객체 생성
      final updatedEmployee = Employee(
        id: originalEmployee.id, // ID는 절대 변경 불가 (Primary Key)
        empNo: originalEmployee.empNo, // 사번 유지
        name: name,
        department: department,
        position: position,
        salary: int.tryParse(salary) ?? originalEmployee.salary,
        email: email,
        phone: phone,
        hireDate: originalEmployee.hireDate, // 입사일 유지
        status: status,
        createdAt: originalEmployee.createdAt, // 생성일 유지
        updatedAt: DateTime.now(), // 수정일 업데이트
      );

      // 2. Repository 호출
      await _repository.updateEmployee(updatedEmployee);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteEmployee(ObjectId id) async {
    state = const AsyncValue.loading();
    try {
      // Repository를 통해 삭제 요청
      await _repository.deleteEmployee(id);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final editEmployeeControllerProvider =
    StateNotifierProvider<EditEmployeeController, AsyncValue<void>>((ref) {
      return EditEmployeeController(ref.watch(employeeRepositoryProvider));
    });
