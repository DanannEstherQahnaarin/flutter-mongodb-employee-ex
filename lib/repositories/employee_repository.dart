import 'package:flutter_mongodb_employee_ex01/model/model_employee.dart';
import 'package:flutter_mongodb_employee_ex01/services/mongo_database.dart';
import 'package:logger/logger.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// 1. 전역 Logger 인스턴스 (어디서든 쓰기 위해)
var logger = Logger(
  printer: PrettyPrinter(), // 로그를 컬러풀하게 출력
);

// 2. Repository 클래스
class EmployeeRepository {
  // DB 컬렉션 가져오기 (싱글톤 서비스 사용)
  DbCollection get _collection => MongoDatabase().employeeCollection;

  // [C] 직원 등록
  Future<void> insertEmployee(Employee employee) async {
    try {
      await _collection.insert(employee.toJson());
      logger.i("직원 등록 성공: ${employee.name}"); // Info 로그
    } catch (e) {
      logger.e("직원 등록 실패", error: e); // Error 로그
      rethrow;
    }
  }

  // [R] 전체 직원 목록 조회
  Future<List<Employee>> getAllEmployees() async {
    try {
      // 최신순(createdAt 내림차순) 정렬하여 가져오기
      final data = await _collection.find(
        where.sortBy('createdAt', descending: true)
      ).toList();
      
      logger.d("직원 목록 조회: ${data.length}명"); // Debug 로그
      
      // Map 리스트 -> Employee 객체 리스트 변환
      return data.map((e) => Employee.fromJson(e)).toList();
    } catch (e) {
      logger.e("데이터 조회 실패", error: e);
      return [];
    }
  }

  // [U] 직원 정보 수정
  Future<void> updateEmployee(Employee employee) async {
    try {
      // _id를 기준으로 데이터 교체 (Replace)
      await _collection.replaceOne(
        where.id(employee.id!), 
        employee.toJson()
      );
      logger.i("직원 수정 완료: ${employee.name} (${employee.id})");
    } catch (e) {
      logger.e("수정 실패", error: e);
      rethrow;
    }
  }

  // [D] 직원 삭제
  Future<void> deleteEmployee(ObjectId id) async {
    try {
      await _collection.deleteOne(where.id(id));
      logger.w("직원 삭제 완료: $id"); // Warning 로그 (삭제는 중요하므로)
    } catch (e) {
      logger.e("삭제 실패", error: e);
      rethrow;
    }
  }
}

// 3. Riverpod Provider 정의
// UI에서 이 Repository에 접근할 때 사용합니다.
final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository();
});