# Wasla Platform - Supabase to Flask + MySQL Migration Guide

## Executive Summary

This document outlines the complete migration strategy from Supabase (PostgreSQL + Auth + Realtime) to a custom Flask + MySQL backend for the Wasla platform. The migration maintains full compatibility with existing Flutter frontend applications.

**Target Architecture:**
- Backend: Flask (Python) with SQLAlchemy
- Database: MySQL 8.0
- Authentication: JWT-based (replacing Supabase Auth)
- API Style: RESTful JSON API

---

## Phase 1: Supabase Reverse Engineering

### 1.1 Authentication System

**Current Implementation (Supabase Auth):**
- Email/Password authentication via `supabase_flutter` package
- User roles: STUDENT, PROVIDER, ADMIN
- Account statuses: PENDING, ACTIVE, SUSPENDED, REJECTED
- Email confirmation required
- Password reset via email link
- Session management with device tracking

**Methods Used:**
```dart
// Sign In
_client.auth.signInWithPassword(email: email, password: password)

// Sign Up
_client.auth.signUp(email: email, password: password, data: {...})

// Sign Out
_client.auth.signOut()

// Reset Password
_client.auth.resetPasswordForEmail(email, redirectTo: 'wasla://reset-password')

// Get Current User
_client.auth.currentUser
```

### 1.2 Database Tables

**Core Tables (from schema.sql):**
1. `profiles` - User profiles extending auth.users
2. `courses` - Course information
3. `modules` - Course modules (chapters)
4. `lessons` - Individual lessons
5. `exams` - Course exams
6. `questions` - Exam questions
7. `answers` - Question answers
8. `enrollments` - Student course enrollments
9. `lesson_progress` - Per-lesson progress tracking
10. `exam_attempts` - Exam attempt records
11. `certificates` - Issued certificates
12. `certificate_templates` - Certificate templates
13. `notifications` - User notifications
14. `payments` - Payment records
15. `user_sessions` - Active session tracking
16. `login_attempts` - Login security tracking
17. `security_logs` - Security event logging
18. `system_settings` - Configuration store

### 1.3 API Patterns Used

**Query Patterns:**
```dart
// Select with filters
.supabase.from('table').select('*, relations(count)').eq('field', value)

// Single record
.supabase.from('table').select().eq('id', id).single()

// Insert
.supabase.from('table').insert({...}).select().single()

// Update
.supabase.from('table').update({...}).eq('id', id).select().single()

// Delete
.supabase.from('table').delete().eq('id', id)
```

### 1.4 Storage (File Uploads)

- Supabase Storage for images and files
- Buckets: courses, certificates, avatars, payments
- Folder structure per provider

---

## Phase 2: Frontend Dependency Mapping

### 2.1 Complete API Contract

Based on analysis of `supabase_service.dart` (provider app), the following endpoints must be replicated:

#### Authentication Endpoints
| Operation | Supabase Method | Required REST Endpoint |
|-----------|---------------|---------------------|
| Sign In | `signInWithPassword` | POST `/api/auth/signin` |
| Sign Up | `signUp` | POST `/api/auth/signup` |
| Sign Out | `signOut` | POST `/api/auth/signout` |
| Get Current User | `currentUser` | GET `/api/auth/me` |
| Reset Password | `resetPasswordForEmail` | POST `/api/auth/reset-password` |
| Confirm Email | (auto) | GET `/api/auth/confirm/{token}` |

#### Courses Endpoints
| Operation | Supabase Method | Required REST Endpoint |
|-----------|---------------|---------------------|
| Get Courses | `getCourses` | GET `/api/courses` |
| Get Course by ID | `getCourseById` | GET `/api/courses/{id}` |
| Create Course | `createCourse` | POST `/api/courses` |
| Update Course | `updateCourse` | PUT `/api/courses/{id}` |
| Delete Course | `deleteCourse` | DELETE `/api/courses/{id}` |
| Publish Course | `publishCourse` | PUT `/api/courses/{id}/publish` |

#### Modules Endpoints
| Operation | Method | REST Endpoint |
|-----------|-------|----------------|
| Get Modules | `getModulesByCourse` | GET `/api/courses/{course_id}/modules` |
| Create Module | `createModule` | POST `/api/modules` |
| Update Module | `updateModule` | PUT `/api/modules/{id}` |
| Delete Module | `deleteModule` | DELETE `/api/modules/{id}` |

#### Lessons Endpoints
| Operation | Method | REST Endpoint |
|-----------|-------|----------------|
| Get Lessons | `getLessonsByModule` | GET `/api/modules/{module_id}/lessons` |
| Create Lesson | `createLesson` | POST `/api/lessons` |
| Update Lesson | `updateLesson` | PUT `/api/lessons/{id}` |
| Delete Lesson | `deleteLesson` | DELETE `/api/lessons/{id}` |

#### Exams Endpoints
| Operation | Method | REST Endpoint |
|-----------|-------|----------------|
| Get Exams | `getExamsByCourse` | GET `/api/courses/{course_id}/exams` |
| Create Exam | `createExam` | POST `/api/exams` |
| Update Exam | `updateExam` | PUT `/api/exams/{id}` |
| Delete Exam | `deleteExam` | DELETE `/api/exams/{id}` |

#### Questions & Answers Endpoints
| Operation | Method | REST Endpoint |
|-----------|-------|----------------|
| Get Questions | `getQuestionsByExam` | GET `/api/exams/{exam_id}/questions` |
| Create Question | `createQuestion` | POST `/api/questions` |
| Update Question | `updateQuestion` | PUT `/api/questions/{id}` |
| Delete Question | `deleteQuestion` | DELETE `/api/questions/{id}` |
| Get Answers | `getAnswersByQuestion` | GET `/api/questions/{question_id}/answers` |
| Create Answer | `createAnswer` | POST `/api/answers` |
| Update Answer | `updateAnswer` | PUT `/api/answers/{id}` |
| Delete Answer | `deleteAnswer` | DELETE `/api/answers/{id}` |

#### Enrollments Endpoints
| Operation | Method | REST Endpoint |
|-----------|-------|----------------|
| Get Enrollments | `getEnrollmentsByCourse` | GET `/api/courses/{course_id}/enrollments` |
| Get Student Enrollments | `getEnrollmentsByStudent` | GET `/api/student/enrollments` |
| Enroll | `enrollInCourse` | POST `/api/enrollments` |
| Update Progress | `updateProgress` | PUT `/api/enrollments/{id}/progress` |

#### Payments Endpoints
| Operation | Method | REST Endpoint |
|-----------|-------|----------------|
| Get Payments | `getPaymentsByProvider` | GET `/api/provider/payments` |
| Create Payment | `createPayment` | POST `/api/payments` |
| Upload Proof | `uploadPaymentProof` | POST `/api/payments/{id}/proof` |
| Approve Payment | `approvePayment` | PUT `/api/payments/{id}/approve` |

#### Certificates Endpoints
| Operation | Method | REST Endpoint |
|-----------|-------|----------------|
| Get Certificates | `getCertificatesByCourse` | GET `/api/courses/{course_id}/certificates` |
| Issue Certificate | `issueCertificate` | POST `/api/certificates` |
| Get Templates | `getCertificateTemplates` | GET `/api/provider/certificate-templates` |
| Create Template | `createCertificateTemplate` | POST `/api/certificate-templates` |
| Update Template | `updateCertificateTemplate` | PUT `/api/certificate-templates/{id}` |

#### Notifications Endpoints
| Operation | Method | REST Endpoint |
|-----------|-------|----------------|
| Get Notifications | `getMyNotifications` | GET `/api/notifications` |
| Mark as Read | `markNotificationAsRead` | PUT `/api/notifications/{id}/read` |
| Create Notification | `createNotification` | POST `/api/notifications` |

### 2.2 Data Models Reference

The following models must be supported with identical field names:

```dart
// CourseModel fields
- id, title, description, short_description
- price, currency, level, language
- image, thumbnail, status, category
- tags, requirements, objectives
- duration_minutes, max_students
- certificate_enabled, provider_id
- created_at, updated_at
- (computed: modulesCount, studentsCount)

// UserModel/Profile fields
- id, name, email, phone, avatar
- gender, bio, role, status
- institution_type, institution_name
- subscription_plan, subscription_start_date
- subscription_end_date, address, city, country

// Enrollment fields
- id, progress, enrolled_at, completed_at
- last_accessed_at, student_id, course_id

// Exam fields
- id, title, description, passing_score
- duration, max_attempts, shuffle_questions
- show_results, course_id, module_id
```

---

## Phase 3: Gap Analysis

### 3.1 Supabase Features to Replace

| Feature | Complexity | Replacement Strategy |
|---------|------------|----------------------|
| PostgreSQL Database | HIGH | MySQL 8.0 with converted schema |
| Supabase Auth | HIGH | Custom JWT implementation |
| Row Level Security (RLS) | MEDIUM | Flask middleware + role checks |
| Storage (files/images) | MEDIUM | Local filesystem or S3-compatible |
| Email Templates | LOW | Flask-Mail integration |
| Realtime subscriptions | LOW | WebSocket (optional, future) |

### 3.2 Features to Simplify

| Feature | Current | Proposed |
|--------|---------|----------|
| Session Management | Supabase sessions table | JWT access + refresh tokens |
| Password History | Full history table | Track last 5 passwords |
| Login Attempts | Tracking table | In-memory with expiration |
| Security Logs | Full audit trail | Optimized critical events only |

### 3.3 Must Remain Identical

For Flutter frontend compatibility:
1. **Response JSON structure** - Must match Supabase response format exactly
2. **Field names** - Use same camelCase identifiers
3. **Error messages** - Return Arabic text as currently used
4. **HTTP status codes** - Standard REST codes (200, 201, 400, 401, 404, 500)
5. **Authentication tokens** - JWT tokens in Authorization header

---

## Phase 4: Backend Redesign

### 4.1 Flask Project Structure

```
backend/
├── app/
│   ├── __init__.py          # Flask app factory
│   ├── config.py           # Configuration
│   ├── models/             # SQLAlchemy models
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── course.py
│   │   ├── module.py
│   │   ├── lesson.py
│   │   ├── exam.py
│   │   ├── question.py
│   │   ├── answer.py
│   │   ├── enrollment.py
│   │   ├── certificate.py
│   │   ├── payment.py
│   │   └── notification.py
│   ├── schemas/            # Marshmallow schemas
│   │   ├── __init__.py
│   │   └── ...
│   ├── services/           # Business logic
│   │   ├── __init__.py
│   │   ├── auth_service.py
│   │   ├── course_service.py
│   │   └── ...
│   ├── api/               # API routes
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── courses.py
│   │   ├── modules.py
│   │   └── ...
│   ├── utils/             # Utilities
│   │   ├── __init__.py
│   │   ├── auth.py        # JWT helpers
│   │   ├── errors.py     # Error handlers
│   │   └── validators.py
│   └── extensions.py      # Flask extensions
├── migrations/           # Database migrations
├── tests/              # Unit tests
├── requirements.txt
├── .env.example
└── run.py              # Entry point
```

### 4.2 Authentication Flow

```
┌─────────────┐     POST /api/auth/signin      ┌─────────────┐
│  Flutter    │ ───────────────────────────────→│   Flask    │
│   App      │ ←───────────────────────────── │  Backend  │
│            │   {access_token,             │           │
│            │    refresh_token,         │           │
│            │    user, profile}       │           │
└─────────────┘                          └─────────────┘

Token Storage (Flutter):
- Access Token: SharedPreferences (short-lived, 15 min)
- Refresh Token: SecureStorage (long-lived, 30 days)
```

### 4.3 API Response Format

**Success Response:**
```json
{
  "data": {...},
  "message": "success",
  "status": 200
}
```

**Error Response:**
```json
{
  "error": "错误消息",
  "message": "error",
  "code": "ERROR_CODE"
}
```

**Supabase-Compatible Format (optionally):**
```json
{
  "id": "uuid",
  "title": "Course Title",
  ...
}
```

---

## Phase 5: Database Migration

### 5.1 MySQL Schema Conversion

**Key Conversion Rules:**
1. UUID → CHAR(36) or VARCHAR(40)
2. ARRAY[] → TEXT (JSON serialized) or separate junction tables
3. ENUM → ENUM or VARCHAR with CHECK constraint
4. TIMESTAMPTZ → DATETIME with timezone handling
5. SERIAL → AUTO_INCREMENT
6. gen_random_uuid() → UUID() or application-generated

### 5.2 MySQL Schema (Core Tables)

```sql
-- ============================================================
-- WASLA PLATFORM - MySQL SCHEMA
-- Migration from PostgreSQL (Supabase) to MySQL
-- ============================================================

-- 1. PROFILES TABLE
CREATE TABLE profiles (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    avatar VARCHAR(500),
    gender ENUM('MALE', 'FEMALE') DEFAULT 'MALE',
    bio TEXT,
    role ENUM('STUDENT', 'PROVIDER', 'ADMIN') DEFAULT 'STUDENT',
    status ENUM('PENDING', 'ACTIVE', 'SUSPENDED', 'REJECTED') DEFAULT 'PENDING',
    institution_type ENUM('UNIVERSITY', 'TRAINING_CENTER', 'INDEPENDENT', 'SCHOOL', 'INSTITUTE'),
    institution_name VARCHAR(255),
    bank_account VARCHAR(100),
    bank_name VARCHAR(100),
    subscription_plan ENUM('FREE', 'BASIC', 'PREMIUM') DEFAULT 'FREE',
    subscription_start_date DATETIME,
    subscription_end_date DATETIME,
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Yemen',
    email_verified_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_profiles_role (role),
    INDEX idx_profiles_status (status),
    INDEX idx_profiles_email (email),
    INDEX idx_profiles_institution (institution_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. COURSES TABLE
CREATE TABLE courses (
    id CHAR(36) PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    price DECIMAL(10,2) DEFAULT 0,
    currency VARCHAR(10) DEFAULT 'YER',
    level ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED') DEFAULT 'BEGINNER',
    language VARCHAR(10) DEFAULT 'ar',
    image VARCHAR(500),
    thumbnail VARCHAR(500),
    status ENUM('DRAFT', 'PUBLISHED', 'ARCHIVED') DEFAULT 'DRAFT',
    category VARCHAR(100),
    tags JSON,
    requirements JSON,
    objectives JSON,
    duration_minutes INT DEFAULT 0,
    max_students INT,
    certificate_enabled BOOLEAN DEFAULT TRUE,
    provider_id CHAR(36) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES profiles(id) ON DELETE CASCADE,
    INDEX idx_courses_provider (provider_id),
    INDEX idx_courses_status (status),
    INDEX idx_courses_category (category),
    INDEX idx_courses_level (level),
    INDEX idx_courses_price (price)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. MODULES TABLE
CREATE TABLE modules (
    id CHAR(36) PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    sort_order INT DEFAULT 0,
    course_id CHAR(36) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    INDEX idx_modules_course (course_id),
    INDEX idx_modules_order (course_id, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. LESSONS TABLE
CREATE TABLE lessons (
    id CHAR(36) PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    type ENUM('VIDEO', 'PDF', 'TEXT', 'FILE', 'IMAGE', 'AUDIO') DEFAULT 'TEXT',
    content TEXT DEFAULT '',
    file_url VARCHAR(500),
    file_name VARCHAR(255),
    file_size BIGINT DEFAULT 0,
    duration INT DEFAULT 0,
    is_free BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    module_id CHAR(36) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE,
    INDEX idx_lessons_module (module_id),
    INDEX idx_lessons_order (module_id, sort_order),
    INDEX idx_lessons_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. EXAMS TABLE
CREATE TABLE exams (
    id CHAR(36) PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    passing_score INT DEFAULT 60,
    duration INT DEFAULT 30,
    max_attempts INT DEFAULT 3,
    shuffle_questions BOOLEAN DEFAULT FALSE,
    show_results BOOLEAN DEFAULT TRUE,
    course_id CHAR(36) NOT NULL,
    module_id CHAR(36),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE SET NULL,
    INDEX idx_exams_course (course_id),
    INDEX idx_exams_module (module_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. QUESTIONS TABLE
CREATE TABLE questions (
    id CHAR(36) PRIMARY KEY,
    text TEXT NOT NULL,
    type ENUM('MULTIPLE_CHOICE', 'TRUE_FALSE', 'TEXT') DEFAULT 'MULTIPLE_CHOICE',
    points INT DEFAULT 1,
    explanation TEXT,
    image_url VARCHAR(500),
    sort_order INT DEFAULT 0,
    exam_id CHAR(36) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE,
    INDEX idx_questions_exam (exam_id),
    INDEX idx_questions_order (exam_id, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. ANSWERS TABLE
CREATE TABLE answers (
    id CHAR(36) PRIMARY KEY,
    text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    question_id CHAR(36) NOT NULL,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    INDEX idx_answers_question (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. ENROLLMENTS TABLE
CREATE TABLE enrollments (
    id CHAR(36) PRIMARY KEY,
    progress INT DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
    enrolled_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    last_accessed_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    student_id CHAR(36) NOT NULL,
    course_id CHAR(36) NOT NULL,
    UNIQUE KEY uk_enrollment (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES profiles(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    INDEX idx_enrollments_student (student_id),
    INDEX idx_enrollments_course (course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. LESSON_PROGRESS TABLE
CREATE TABLE lesson_progress (
    id CHAR(36) PRIMARY KEY,
    completed BOOLEAN DEFAULT FALSE,
    completed_at DATETIME,
    watch_progress DECIMAL(5,2) DEFAULT 0 CHECK (watch_progress >= 0 AND watch_progress <= 100),
    student_id CHAR(36) NOT NULL,
    lesson_id CHAR(36) NOT NULL,
    UNIQUE KEY uk_lesson_progress (student_id, lesson_id),
    FOREIGN KEY (student_id) REFERENCES profiles(id) ON DELETE CASCADE,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE,
    INDEX idx_lesson_progress_student (student_id),
    INDEX idx_lesson_progress_lesson (lesson_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. EXAM_ATTEMPTS TABLE
CREATE TABLE exam_attempts (
    id CHAR(36) PRIMARY KEY,
    score INT DEFAULT 0,
    total_points INT DEFAULT 0,
    passed BOOLEAN DEFAULT FALSE,
    student_answers JSON DEFAULT '{}',
    time_spent INT DEFAULT 0,
    completed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    student_id CHAR(36) NOT NULL,
    exam_id CHAR(36) NOT NULL,
    FOREIGN KEY (student_id) REFERENCES profiles(id) ON DELETE CASCADE,
    FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE,
    INDEX idx_exam_attempts_student (student_id),
    INDEX idx_exam_attempts_exam (exam_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. CERTIFICATES TABLE
CREATE TABLE certificates (
    id CHAR(36) PRIMARY KEY,
    certificate_number VARCHAR(50) UNIQUE,
    certificate_url VARCHAR(500),
    student_name VARCHAR(255) NOT NULL,
    course_name VARCHAR(500) NOT NULL,
    provider_name VARCHAR(255) NOT NULL,
    score INT,
    issued_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    template_name VARCHAR(100),
    template_data JSON DEFAULT '{}',
    status ENUM('ISSUED', 'REVOKED') DEFAULT 'ISSUED',
    student_id CHAR(36) NOT NULL,
    course_id CHAR(36) NOT NULL,
    provider_id CHAR(36) NOT NULL,
    FOREIGN KEY (student_id) REFERENCES profiles(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES profiles(id) ON DELETE CASCADE,
    INDEX idx_certificates_student (student_id),
    INDEX idx_certificates_course (course_id),
    INDEX idx_certificates_provider (provider_id),
    INDEX idx_certificates_number (certificate_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. PAYMENTS TABLE
CREATE TABLE payments (
    id CHAR(36) PRIMARY KEY,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'YER',
    payment_method VARCHAR(50),
    transaction_id VARCHAR(100),
    proof_url VARCHAR(500),
    status ENUM('PENDING', 'APPROVED', 'REJECTED', 'REFUNDED') DEFAULT 'PENDING',
    notes TEXT,
    student_id CHAR(36) NOT NULL,
    course_id CHAR(36) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES profiles(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    INDEX idx_payments_student (student_id),
    INDEX idx_payments_course (course_id),
    INDEX idx_payments_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. NOTIFICATIONS TABLE
CREATE TABLE notifications (
    id CHAR(36) PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('INFO', 'WARNING', 'SUCCESS', 'ERROR', 'ANNOUNCEMENT') DEFAULT 'INFO',
    is_read BOOLEAN DEFAULT FALSE,
    read_at DATETIME,
    user_id CHAR(36) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE,
    INDEX idx_notifications_user (user_id),
    INDEX idx_notifications_read (user_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 14. REFRESH_TOKENS TABLE
CREATE TABLE refresh_tokens (
    id CHAR(36) PRIMARY KEY,
    token VARCHAR(500) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    user_id CHAR(36) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE,
    INDEX idx_refresh_tokens_user (user_id),
    INDEX idx_refresh_tokens_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## Phase 6: API Compatibility Layer

### 6.1 Flask API Blueprint Structure

```python
# app/api/auth.py
from flask import Blueprint, request, jsonify
from app.services.auth_service import AuthService
from app.utils.auth import token_required
from app.utils.errors import handle_exceptions

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')
auth_service = AuthService()

@auth_bp.route('/signin', methods=['POST'])
@handle_exceptions
def signin():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    
    result = auth_service.sign_in(email, password)
    return jsonify(result), 200

@auth_bp.route('/signup', methods=['POST'])
@handle_exceptions
def signup():
    data = request.get_json()
    # Required: name, email, password, role
    result = auth_service.sign_up(
        name=data['name'],
        email=data['email'],
        password=data['password'],
        role=data['role'],
        phone=data.get('phone'),
        gender=data.get('gender'),
        institution_type=data.get('institutionType'),
        institution_name=data.get('institutionName')
    )
    return jsonify(result), 201

@auth_bp.route('/signout', methods=['POST'])
@token_required
@handle_exceptions
def signout(current_user):
    auth_service.sign_out(current_user['id'])
    return jsonify({'message': 'success'}), 200

@auth_bp.route('/me', methods=['GET'])
@token_required
@handle_exceptions
def get_current_user(current_user):
    return jsonify({'user': current_user}), 200

@auth_bp.route('/reset-password', methods=['POST'])
@handle_exceptions
def reset_password():
    data = request.get_json()
    auth_service.reset_password(data['email'])
    return jsonify({'message': 'success'}), 200
```

### 6.2 JWT Implementation

```python
# app/utils/auth.py
import jwt
from datetime import datetime, timedelta
from functools import wraps
from flask import request, jsonify, current_app

def generate_tokens(user_id, email):
    """Generate access and refresh tokens"""
    access_token = jwt.encode(
        {
            'user_id': user_id,
            'email': email,
            'exp': datetime.utcnow() + timedelta(minutes=15),
            'type': 'access'
        },
        current_app.config['SECRET_KEY'],
        algorithm='HS256'
    )
    
    refresh_token = jwt.encode(
        {
            'user_id': user_id,
            'exp': datetime.utcnow() + timedelta(days=30),
            'type': 'refresh'
        },
        current_app.config['SECRET_KEY'],
        algorithm='HS256'
    )
    
    return access_token, refresh_token

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        auth_header = request.headers.get('Authorization')
        
        if auth_header and auth_header.startswith('Bearer '):
            token = auth_header.split(' ')[1]
        
        if not token:
            return jsonify({'error': 'Token is missing', 'code': 'TOKEN_MISSING'}), 401
        
        try:
            data = jwt.decode(
                token, 
                current_app.config['SECRET_KEY'],
                algorithms=['HS256']
            )
            # Store user data in request context
            request.current_user = data
            
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token has expired', 'code': 'TOKEN_EXPIRED'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Invalid token', 'code': 'INVALID_TOKEN'}), 401
        
        return f(data, *args, **kwargs)
    
    return decorated
```

---

## Phase 7: Backend Implementation

### 7.1 Requirements

```
# requirements.txt
Flask==3.0.0
Flask-SQLAlchemy==3.1.1
Flask-Migrate==4.0.5
Flask-Cors==4.0.0
Flask-JWT-Extended==4.6.0
Flask-Mail==0.9.1
python-dotenv==1.0.0
PyMySQL==1.1.0
cryptography==41.0.7
Werkzeug==3.0.1
marshmallow==3.20.1
marshmallow-sqlalchemy==0.29.0
gunicorn==21.2.0
redis==5.0.1
celery==5.3.4
Pillow==10.1.0
```

### 7.2 Configuration

```python
# app/config.py
import os
from datetime import timedelta

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')
    
    # Database
    MYSQL_HOST = os.environ.get('MYSQL_HOST', 'localhost')
    MYSQL_PORT = int(os.environ.get('MYSQL_PORT', 3306))
    MYSQL_USER = os.environ.get('MYSQL_USER', 'wasla')
    MYSQL_PASSWORD = os.environ.get('MYSQL_PASSWORD', '')
    MYSQL_DB = os.environ.get('MYSQL_DB', 'wasla')
    
    SQLALCHEMY_DATABASE_URI = f"mysql+pymysql://{MYSQL_USER}:{MYSQL_PASSWORD}@{MYSQL_HOST}:{MYSQL_PORT}/{MYSQL_DB}"
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_size': 10,
        'pool_recycle': 3600,
        'pool_pre_ping': True
    }
    
    # JWT
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY', SECRET_KEY)
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(minutes=15)
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=30)
    JWT_ALGORITHM = 'HS256'
    
    # File Upload
    UPLOAD_FOLDER = os.environ.get('UPLOAD_FOLDER', '/var/wasla/uploads')
    MAX_CONTENT_LENGTH = 100 * 1024 * 1024  # 100MB
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'pdf', 'mp4', 'webm'}
    
    # Mail
    MAIL_SERVER = os.environ.get('MAIL_SERVER', 'smtp.gmail.com')
    MAIL_PORT = int(os.environ.get('MAIL_PORT', 587))
    MAIL_USE_TLS = True
    MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
    MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')
    
    # CORS
    CORS_ORIGINS = os.environ.get('CORS_ORIGINS', '*').split(',')
```

### 7.3 Main Application Factory

```python
# app/__init__.py
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from flask_mail import Mail

db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()
mail = Mail()

def create_app(config_class='app.config.Config'):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    mail.init_app(app)
    CORS(app, resources={r"/api/*": {"origins": app.config['CORS_ORIGINS']}})
    
    # Register blueprints
    from app.api.auth import auth_bp
    from app.api.courses import courses_bp
    from app.api.enrollments import enrollments_bp
    # ... other blueprints
    
    app.register_blueprint(auth_bp)
    app.register_blueprint(courses_bp)
    app.register_blueprint(enrollments_bp)
    # ... other registrations
    
    # Error handlers
    from app.utils.errors import register_error_handlers
    register_error_handlers(app)
    
    return app
```

---

## Phase 8: Flutter Integration Strategy

### 8.1 Required Flutter Changes

The Flutter apps will need minimal changes to work with the new backend:

**1. Replace Supabase Package:**
```yaml
# pubspec.yaml - REMOVE
dependencies:
  - supabase_flutter: ^2.0.0

# pubspec.yaml - ADD
dependencies:
  - http: ^1.2.0
  - shared_preferences: ^2.2.2
  - flutter_secure_storage: ^9.0.0
```

**2. Create HTTP Service:**
```dart
// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://api.wasla-platform.com';
  final _storage = FlutterSecureStorage();
  
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }
  
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }
  
  // ... PUT, DELETE methods
  
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Handle token refresh or logout
      throw Exception('Unauthorized');
    }
    throw Exception('Request failed: ${response.statusCode}');
  }
  
  // Token management methods
  Future<void> setTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }
  
  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }
}
```

**3. Update Providers:**

Replace Supabase service calls with ApiService calls:

```dart
// Example: CourseProvider modification
class CourseProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  Future<List<CourseModel>> getCourses() async {
    try {
      final response = await _api.get('/api/courses');
      final List<dynamic> data = response['data'] ?? response;
      return data.map((json) => CourseModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
```

### 8.2 Minimal Migration Code Example

For maximum compatibility, create a Supabase-compatible wrapper:

```dart
// lib/services/api_adapter.dart
// This adapter makes the new API feel like Supabase to existing code

class ApiAdapter {
  // Course operations
  static Future<List<Map<String, dynamic>>> query(String table) async {
    final api = ApiService();
    final response = await api.get('/api/$table');
    return List<Map<String, dynamic>>.from(response['data'] ?? response);
  }
  
  // Filter operations
  static Future<List<Map<String, dynamic>>> select({
    required String table,
    String? eq,
    String? order,
  }) async {
    final api = ApiService();
    var endpoint = '/api/$table';
    if (eq != null) endpoint += '?eq=$eq';
    if (order != null) endpoint += '&order=$order';
    final response = await api.get(endpoint);
    return List<Map<String, dynamic>>.from(response['data'] ?? response);
  }
}
```

---

## Phase 9: Deployment Plan

### 9.1 Backend Deployment (VPS/Cloud)

**1. Server Setup:**
```bash
# OS: Ubuntu 22.04 LTS
# Minimum: 2 CPU, 4GB RAM, 50GB SSD

# Update system
sudo apt update && sudo apt upgrade -y

# Install Python and dependencies
sudo apt install -y python3.11 python3-pip python3-venv nginx certbot

# Install MySQL
sudo apt install -y mysql-server

# Configure MySQL
sudo mysql_secure_installation
```

**2. Application Setup:**
```bash
# Create project directory
sudo mkdir -p /var/wasla/backend
cd /var/wasla/backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Clone and install
git clone <repository> .
pip install -r requirements.txt

# Environment variables
cp .env.example .env
# Edit .env with production values
```

**3. Database Setup:**
```bash
# Create MySQL database
mysql -u root -p
CREATE DATABASE wasla CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'wasla'@'localhost' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON wasla.* TO 'wasla'@'localhost';
FLUSH PRIVILEGES;

# Run migrations
flask db upgrade
```

**4. Service Configuration:**
```bash
# Create systemd service
sudo nano /etc/systemd/system/wasla.service

[Unit]
Description=Wasla Flask API
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/wasla/backend
Environment="PATH=/var/wasla/backend/venv/bin"
ExecStart=/var/wasla/backend/venv/bin/gunicorn -w 4 -b 127.0.0.1:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target

# Enable service
sudo systemctl daemon-reload
sudo systemctl enable wasla
sudo systemctl start wasla
```

**5. Nginx Configuration:**
```nginx
# /etc/nginx/sites-available/wasla
server {
    listen 443 ssl http2;
    server_name api.wasla-platform.com;
    
    ssl_certificate /etc/letsencrypt/live/wasla-platform.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/wasla-platform.com/privkey.pem;
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

server {
    listen 80;
    server_name api.wasla-platform.com;
    return 301 https://$host$request_uri;
}
```

### 9.2 Environment Variables

```
# Backend (.env)
SECRET_KEY=your-production-secret-key-min-32-chars
JWT_SECRET_KEY=your-jwt-secret-key

MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=wasla
MYSQL_PASSWORD=strong_password
MYSQL_DB=wasla

# File storage
UPLOAD_FOLDER=/var/wasla/uploads

# Mail (optional)
MAIL_USERNAME=noreply@wasla-platform.com
MAIL_PASSWORD=mail_password
```

### 9.3 Security Best Practices

1. **HTTPS Only** - Force SSL/TLS
2. **Rate Limiting** - Prevent brute force attacks
3. **Input Validation** - Sanitize all user inputs
4. **CORS** - Restrict to known domains
5. **Token Expiry** - Short access tokens (15 min)
6. **Password Hashing** - Use bcrypt/argon2
7. **SQL Injection** - Use parameterized queries
8. **XSS Protection** - Escape output
9. **CSRF Tokens** - For state-changing operations

---

## Phase 10: Git Workflow

### 10.1 Branch Creation and Commit

After completing the migration implementation:

```bash
# Create new branch
git checkout -b backend-migration-flask-mysql

# Status
git status

# Add new files
git add backend/
git add migration/
git add MIGRATION_GUIDE.md

# Commit
git commit -m "Initial backend migration from Supabase to Flask + MySQL

- Added Flask backend with JWT authentication
- Created MySQL schema (converted from PostgreSQL)
- Implemented REST API endpoints matching Supabase responses
- Added API compatibility layer for Flutter frontend
- Included migration scripts and deployment guide"

# Push
git push -u origin backend-migration-flask-mysql
```

### 10.2 Files Summary

**New Files:**
- `backend/` - Complete Flask application
- `migration/` - Database migration scripts
- `MIGRATION_GUIDE.md` - This document

**Modified Files:**
- `.gitignore` - Add backend-specific ignores
- Potentially Flutter pubspec.yaml (optional adaptation)

---

## Summary

This migration replaces all Supabase functionality while maintaining frontend compatibility:

| Component | Current | New |
|-----------|---------|-----|
| Database | PostgreSQL (Supabase) | MySQL 8.0 |
| Auth | Supabase Auth | Custom JWT |
| Storage | Supabase Storage | Local/S3 |
| Real-time | Supabase Realtime | Optional WebSocket |
| API | Supabase Client | REST API |

**Key Success Factors:**
1. Keep response JSON format identical to Supabase
2. Use JWT tokens with same header format
3. Maintain error message Arabic text
4. Minimize Flutter app changes
5. Deploy with HTTPS and proper security

---

*Document Version: 1.0*
*Created: 2026-04-27*
*Platform: Wasla*