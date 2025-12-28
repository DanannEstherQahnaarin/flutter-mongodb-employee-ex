import 'dart:async';
import 'package:flutter_mongodb_employee_ex01/model/model_employee.dart';
import 'package:flutter_mongodb_employee_ex01/repositories/employee_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// AsyncNotifier: 비동기 리스트 데이터를 관리하는 최신 Riverpod 패턴
class EmployeeListController extends AsyncNotifier<List<Employee>> {
  // 1. 초기화 (build): 컨트롤러가 생성될 때 실행됨
  @override
  FutureOr<List<Employee>> build() async {
    // Repository에서 데이터 가져오기
    return _fetchEmployees();
  }

  // 2. 데이터 가져오기 내부 함수
  Future<List<Employee>> _fetchEmployees() async {
    final repository = ref.read(employeeRepositoryProvider);
    return await repository.getAllEmployees();
  }

  // 3. 목록 새로고침 기능 (외부에서 호출 가능)
  Future<void> refreshList() async {
    // 상태를 로딩 중으로 변경 후 다시 데이터 fetch
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchEmployees());
  }
}

// UI에서 접근할 Provider
final employeeListControllerProvider =
    AsyncNotifierProvider<EmployeeListController, List<Employee>>(
      () => EmployeeListController(),
    );
