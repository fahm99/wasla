-- ============================================================
-- WASLA DATABASE MIGRATION - PostgreSQL to MySQL
-- ============================================================
-- Run on MySQL 8.0+
-- Migration ID: 001
-- ============================================================

USE wasla;

-- ============================================================
-- 1. Profiles Table
-- ============================================================

CREATE TABLE IF NOT EXISTS profiles (
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
    INDEX idx_profiles_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. Courses Table
-- ============================================================

CREATE TABLE IF NOT EXISTS courses (
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
    INDEX idx_courses_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. Modules Table
-- ============================================================

CREATE TABLE IF NOT EXISTS modules (
    id CHAR(36) PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    sort_order INT DEFAULT 0,
    course_id CHAR(36) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    INDEX idx_modules_course (course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. Lessons Table
-- ============================================================

CREATE TABLE IF NOT EXISTS lessons (
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
    INDEX idx_lessons_module (module_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. Exams Table
-- ============================================================

CREATE TABLE IF NOT EXISTS exams (
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
    INDEX idx_exams_course (course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. Questions Table
-- ============================================================

CREATE TABLE IF NOT EXISTS questions (
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
    INDEX idx_questions_exam (exam_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. Answers Table
-- ============================================================

CREATE TABLE IF NOT EXISTS answers (
    id CHAR(36) PRIMARY KEY,
    text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    question_id CHAR(36) NOT NULL,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    INDEX idx_answers_question (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 8. Enrollments Table
-- ============================================================

CREATE TABLE IF NOT EXISTS enrollments (
    id CHAR(36) PRIMARY KEY,
    progress INT DEFAULT 0,
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

-- ============================================================
-- 9. Lesson Progress Table
-- ============================================================

CREATE TABLE IF NOT EXISTS lesson_progress (
    id CHAR(36) PRIMARY KEY,
    completed BOOLEAN DEFAULT FALSE,
    completed_at DATETIME,
    watch_progress DECIMAL(5,2) DEFAULT 0,
    student_id CHAR(36) NOT NULL,
    lesson_id CHAR(36) NOT NULL,
    UNIQUE KEY uk_lesson_progress (student_id, lesson_id),
    FOREIGN KEY (student_id) REFERENCES profiles(id) ON DELETE CASCADE,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE,
    INDEX idx_lesson_progress_student (student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 10. Exam Attempts Table
-- ============================================================

CREATE TABLE IF NOT EXISTS exam_attempts (
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

-- ============================================================
-- 11. Certificates Table
-- ============================================================

CREATE TABLE IF NOT EXISTS certificates (
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
    INDEX idx_certificates_course (course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 12. Payments Table
-- ============================================================

CREATE TABLE IF NOT EXISTS payments (
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
    INDEX idx_payments_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 13. Notifications Table
-- ============================================================

CREATE TABLE IF NOT EXISTS notifications (
    id CHAR(36) PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('INFO', 'WARNING', 'SUCCESS', 'ERROR', 'ANNOUNCEMENT') DEFAULT 'INFO',
    is_read BOOLEAN DEFAULT FALSE,
    read_at DATETIME,
    user_id CHAR(36) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE,
    INDEX idx_notifications_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 14. Refresh Tokens Table
-- ============================================================

CREATE TABLE IF NOT EXISTS refresh_tokens (
    id CHAR(36) PRIMARY KEY,
    token VARCHAR(500) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    user_id CHAR(36) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE,
    INDEX idx_refresh_tokens_user (user_id),
    INDEX idx_refresh_tokens_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;