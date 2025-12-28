import 'package:mongo_dart/mongo_dart.dart';

class Employee {
  final ObjectId? id; // MongoDB의 고유 ID (_id)
  final int empNo; // 사번
  final String name; // 이름
  final String department; // 부서
  final String position; // 직급
  final num salary; // 급여 (int, double 모두 호환되도록 num 사용)
  final DateTime hireDate; // 입사일
  final String email; // 이메일
  final String phone; // 연락처
  final String status; // ACTIVE, INACTIVE 등 상태
  final DateTime createdAt; // 생성일
  final DateTime? updatedAt; // 수정일 (초기엔 없을 수 있음)

  Employee({
    this.id,
    required this.empNo,
    required this.name,
    required this.department,
    required this.position,
    required this.salary,
    required this.hireDate,
    required this.email,
    required this.phone,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  // 1. JSON(Map) -> Dart 객체로 변환 (Read 할 때 사용)
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'] as ObjectId?,

      // [수정됨] as int 대신 .toInt()를 사용하여 Int64 타입 대응
      empNo: (json['empNo'] as dynamic).toInt(),

      name: json['name'] as String,
      department: json['department'] as String,
      position: json['position'] as String,

      // [수정됨] 급여도 안전하게 num으로 변환되도록 수정
      salary: (json['salary'] as dynamic) is int
          ? (json['salary'] as dynamic).toInt()
          : (json['salary'] as num),

      // MongoDB는 날짜를 UTC로 저장하므로 로컬 시간으로 변환
      hireDate: (json['hireDate'] as DateTime).toLocal(),
      email: json['email'] as String,
      phone: json['phone'] as String,
      status: json['status'] as String,
      createdAt: (json['createdAt'] as DateTime).toLocal(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as DateTime).toLocal()
          : null,
    );
  }

  // 2. Dart 객체 -> JSON(Map)으로 변환 (Create/Update 할 때 사용)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id, // id가 있을 때만 포함 (신규 생성 시엔 몽고DB가 자동 생성)
      'empNo': empNo,
      'name': name,
      'department': department,
      'position': position,
      'salary': salary,
      'hireDate': hireDate,
      'email': email,
      'phone': phone,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
