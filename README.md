# Flutter MongoDB Employee Management System

Flutter와 MongoDB를 활용한 모바일 직원 관리 시스템으로, 크로스 플랫폼 환경에서 직원 정보의 CRUD 기능을 제공합니다.

## 📋 프로젝트 소개

기존의 단순한 로컬 저장 방식이나 관계형 데이터베이스에 의존하지 않고, **NoSQL 데이터베이스인 MongoDB와 Flutter를 결합**하여 유연하고 확장 가능한 직원 관리 시스템을 구축하고자 합니다. 

이 프로젝트는 **실무 수준의 아키텍처 패턴**을 적용하여 유지보수성과 테스트 용이성을 고려했으며, Flutter의 반응형 상태 관리와 MongoDB의 스키마 유연성을 결합해 실시간 데이터 동기화와 효율적인 데이터 관리를 제공합니다.

## ✨ 주요 기능

### 기능 목록
- ✅ **직원 목록 조회**: 등록된 모든 직원 정보를 최신순으로 조회
- ✅ **직원 등록**: 이름, 부서, 직급, 급여, 이메일, 연락처 등 직원 정보 입력 및 저장
- ✅ **직원 수정**: 기존 직원 정보 수정 및 업데이트
- ✅ **직원 삭제**: 직원 정보 삭제
- ✅ **실시간 상태 표시**: ACTIVE/INACTIVE 상태 관리

### 서비스 흐름
```
[직원 목록 화면]
    ↓
[+ 버튼 클릭] → [직원 등록 화면] → 입력 완료 → MongoDB 저장 → 목록 자동 새로고침
    ↓
[직원 카드 클릭] → [직원 수정 화면] → 수정 완료 → MongoDB 업데이트 → 목록 자동 새로고침
    ↓
[직원 삭제] → MongoDB 삭제 → 목록 자동 새로고침
```

## 🛠 기술 스택

### 프론트엔드
- **Flutter** 3.10.4+ (크로스 플랫폼 UI 프레임워크)
- **Dart** (프로그래밍 언어)

### 상태 관리
- **Flutter Riverpod** 3.1.0 (반응형 상태 관리)

### 데이터베이스
- **MongoDB** (NoSQL 문서형 데이터베이스)
- **mongo_dart** 0.10.5 (MongoDB Dart 드라이버)
- **mongo_dart_query** 5.0.2 (MongoDB 쿼리 빌더)

### 인프라
- **Docker Compose** (MongoDB 컨테이너 오케스트레이션)

### 유틸리티
- **flutter_dotenv** 6.0.0 (환경 변수 관리)
- **logger** 2.6.2 (로깅 시스템)

## 🏗 아키텍처

이 프로젝트는 **Clean Architecture** 패턴을 기반으로 레이어를 분리하여 관심사의 분리(Separation of Concerns)를 구현했습니다.

```
lib/
├── model/              # 도메인 모델 (데이터 구조 정의)
│   └── model_employee.dart
│
├── repositories/       # 데이터 액세스 계층 (CRUD 로직 캡슐화)
│   └── employee_repository.dart
│
├── services/          # 인프라스트럭처 계층 (DB 연결 관리)
│   └── mongo_database.dart (싱글톤 패턴)
│
├── controller/        # 비즈니스 로직 계층 (상태 관리)
│   ├── list_emp_controller.dart   (AsyncNotifier)
│   ├── add_emp_controller.dart    (StateNotifier)
│   └── edit_emp_controller.dart   (StateNotifier)
│
└── screen/           # 프레젠테이션 계층 (UI)
    ├── list_emp_screen.dart
    ├── add_emp_screen.dart
    └── edit_emp_screen.dart
```

### 아키텍처 특징
- **레이어 분리**: Model → Repository → Controller → Screen 순으로 의존성 흐름
- **의존성 주입**: Riverpod Provider를 통한 의존성 관리
- **싱글톤 패턴**: `MongoDatabase` 클래스로 DB 연결 관리
- **비동기 처리**: `AsyncValue`와 `AsyncNotifier`를 활용한 비동기 상태 관리
- **에러 처리**: 각 레이어에서 적절한 에러 핸들링 및 로깅

## 🚀 실행 방법

### 사전 요구사항
- Flutter SDK 3.10.4 이상
- Docker 및 Docker Compose
- Android Studio / Xcode (모바일 에뮬레이터/시뮬레이터용)

### 1. MongoDB 컨테이너 실행

```bash
docker-compose up -d
```

MongoDB가 `localhost:27017` 포트에서 실행됩니다.

### 2. 환경 변수 설정

프로젝트 루트에 `.env` 파일을 생성하고 다음 내용을 추가하세요:

```env
MONGO_CONN_URL=mongodb://admin:password1234@127.0.0.1:27017/employee_db?authSource=admin
```

### 3. Flutter 의존성 설치

```bash
flutter pub get
```

### 4. 애플리케이션 실행

#### Android 에뮬레이터
```bash
flutter run
```

> **참고**: Android 에뮬레이터에서는 MongoDB 주소가 자동으로 `10.0.2.2`로 변환됩니다.

#### iOS 시뮬레이터
```bash
flutter run
```

#### 웹 브라우저
```bash
flutter run -d chrome
```

### 5. (선택) MongoDB 데이터 확인

MongoDB 컨테이너에 접속하여 데이터를 확인할 수 있습니다:

```bash
docker exec -it local_mongo mongosh -u admin -p password1234 --authenticationDatabase admin

# 데이터베이스 선택
use employee_db

# 직원 컬렉션 조회
db.employees.find().pretty()
```

## 📝 참고사항

- MongoDB 컨테이너 중지: `docker-compose down`
- MongoDB 데이터 영구 저장: `./mongo_data` 디렉토리에 볼륨 마운트됨
- 로그 확인: 애플리케이션 실행 시 콘솔에서 Logger 출력 확인 가능
