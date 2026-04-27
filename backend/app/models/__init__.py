"""
Wasla Backend - SQLAlchemy Models
Database models matching the PostgreSQL schema from Supabase
"""
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from app.extensions import db
import uuid


def generate_uuid():
    """Generate UUID-like string"""
    return str(uuid.uuid4())


class Profile(db.Model):
    """User profiles table"""
    __tablename__ = 'profiles'
    
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid)
    name = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(255), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    phone = db.Column(db.String(50))
    avatar = db.Column(db.String(500))
    gender = db.Column(db.Enum('MALE', 'FEMALE', name='gender_type'), default='MALE')
    bio = db.Column(db.Text)
    role = db.Column(db.Enum('STUDENT', 'PROVIDER', 'ADMIN', name='user_role'), default='STUDENT')
    status = db.Column(db.Enum('PENDING', 'ACTIVE', 'SUSPENDED', 'REJECTED', name='user_status'), default='PENDING')
    institution_type = db.Column(db.Enum('UNIVERSITY', 'TRAINING_CENTER', 'INDEPENDENT', 'SCHOOL', 'INSTITUTE', name='institution_type'))
    institution_name = db.Column(db.String(255))
    bank_account = db.Column(db.String(100))
    bank_name = db.Column(db.String(100))
    subscription_plan = db.Column(db.Enum('FREE', 'BASIC', 'PREMIUM', name='subscription_plan'), default='FREE')
    subscription_start_date = db.Column(db.DateTime)
    subscription_end_date = db.Column(db.DateTime)
    address = db.Column(db.Text)
    city = db.Column(db.String(100))
    country = db.Column(db.String(100), default='Yemen')
    email_verified_at = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    courses = db.relationship('Course', backref='provider', lazy='dynamic', foreign_keys='Course.provider_id')
    enrollments = db.relationship('Enrollment', backref='student', lazy='dynamic')
    notifications = db.relationship('Notification', backref='user', lazy='dynamic')
    
    def set_password(self, password):
        """Set hashed password"""
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        """Verify password"""
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self):
        """Convert to dictionary (matches Supabase response)"""
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'phone': self.phone,
            'avatar': self.avatar,
            'gender': self.gender,
            'bio': self.bio,
            'role': self.role,
            'status': self.status,
            'institution_type': self.institution_type,
            'institution_name': self.institution_name,
            'subscription_plan': self.subscription_plan,
            'subscription_start_date': self.subscription_start_date.iso8601_string() if self.subscription_start_date else None,
            'subscription_end_date': self.subscription_end_date.iso8601_string() if self.subscription_end_date else None,
            'address': self.address,
            'city': self.city,
            'country': self.country,
            'created_at': self.created_at.iso8601_string() if self.created_at else None,
            'updated_at': self.updated_at.iso8601_string() if self.updated_at else None
        }


class RefreshToken(db.Model):
    """Refresh tokens for JWT"""
    __tablename__ = 'refresh_tokens'
    
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid
    token = db.Column(db.String(500), unique=True, nullable=False)
    expires_at = db.Column(db.DateTime, nullable=False)
    user_id = db.Column(db.String(36), db.ForeignKey('profiles.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    user = db.relationship('Profile', backref='refresh_tokens')
    
    def is_expired(self):
        """Check if token is expired"""
        return datetime.utcnow() > self.expires_at
    
    def to_dict(self):
        return {
            'id': self.id,
            'token': self.token,
            'expires_at': self.expires_at.iso8601_string(),
            'user_id': self.user_id,
            'created_at': self.created_at.iso8601_string() if self.created_at else None
        }


class Course(db.Model):
    """Courses table"""
    __tablename__ = 'courses'
    
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid
    title = db.Column(db.String(500), nullable=False)
    description = db.Column(db.Text)
    short_description = db.Column(db.String(500))
    price = db.Column(db.Numeric(10, 2), default=0)
    currency = db.Column(db.String(10), default='YER')
    level = db.Column(db.Enum('BEGINNER', 'INTERMEDIATE', 'ADVANCED', name='course_level'), default='BEGINNER')
    language = db.Column(db.String(10), default='ar')
    image = db.Column(db.String(500))
    thumbnail = db.Column(db.String(500))
    status = db.Column(db.Enum('DRAFT', 'PUBLISHED', 'ARCHIVED', name='course_status'), default='DRAFT')
    category = db.Column(db.String(100))
    tags = db.Column(db.JSON)  # JSON array stored as text
    requirements = db.Column(db.JSON)
    objectives = db.Column(db.JSON)
    duration_minutes = db.Column(db.Integer, default=0)
    max_students = db.Column(db.Integer)
    certificate_enabled = db.Column(db.Boolean, default=True)
    provider_id = db.Column(db.String(36), db.ForeignKey('profiles.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    modules = db.relationship('Module', backref='course', lazy='dynamic', cascade='all, delete-orphan')
    enrollments = db.relationship('Enrollment', backref='course', lazy='dynamic', cascade='all, delete-orphan')
    exams = db.relationship('Exam', backref='course', lazy='dynamic', cascade='all, delete-orphan')
    payments = db.relationship('Payment', backref='course', lazy='dynamic')
    certificates = db.relationship('Certificate', backref='course', lazy='dynamic')
    
    def to_dict(self, include_counts=False):
        """Convert to dictionary"""
        data = {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'short_description': self.short_description,
            'price': float(self.price) if self.price else 0,
            'currency': self.currency,
            'level': self.level,
            'language': self.language,
            'image': self.image,
            'thumbnail': self.thumbnail,
            'status': self.status,
            'category': self.category,
            'tags': self.tags,
            'requirements': self.requirements,
            'objectives': self.objectives,
            'duration_minutes': self.duration_minutes,
            'max_students': self.max_students,
            'certificate_enabled': self.certificate_enabled,
            'provider_id': self.provider_id,
            'created_at': self.created_at.iso8601_string() if self.created_at else None,
            'updated_at': self.updated_at.iso8601_string() if self.updated_at else None
        }
        
        if include_counts:
            data['modulesCount'] = self.modules.count()
            data['studentsCount'] = self.enrollments.count()
        
        return data


class Module(db.Model):
    """Course modules (chapters) table"""
    __tablename__ = 'modules'
    
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid
    title = db.Column(db.String(500), nullable=False)
    description = db.Column(db.Text)
    order = db.Column(db.Integer, default=0)
    course_id = db.Column(db.String(36), db.ForeignKey('courses.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    lessons = db.relationship('Lesson', backref='module', lazy='dynamic', cascade='all, delete-orphan')
    exams = db.relationship('Exam', backref='module', lazy='dynamic')
    
    def to_dict(self, include_counts=False):
        """Convert to dictionary"""
        data = {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'order': self.order,
            'course_id': self.course_id,
            'created_at': self.created_at.iso8601_string() if self.created_at else None,
            'updated_at': self.updated_at.iso8601_string() if self.updated_at else None
        }
        
        if include_counts:
            data['lessonsCount'] = self.lessons.count()
        
        return data


class Lesson(db.Model):
    """Lessons table"""
    __tablename__ = 'lessons'
    
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid
    title = db.Column(db.String(500), nullable=False)
    description = db.Column(db.Text)
    type = db.Column(db.Enum('VIDEO', 'PDF', 'TEXT', 'FILE', 'IMAGE', 'AUDIO', name='lesson_type'), default='TEXT')
    content = db.Column(db.Text, default='')
    file_url = db.Column(db.String(500))
    file_name = db.Column(db.String(255))
    file_size = db.Column(db.BigInteger, default=0)
    duration = db.Column(db.Integer, default=0)
    is_free = db.Column(db.Boolean, default=False)
    order = db.Column(db.Integer, default=0)
    module_id = db.Column(db.String(36), db.ForeignKey('modules.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    progress = db.relationship('LessonProgress', backref='lesson', lazy='dynamic')
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'type': self.type,
            'content': self.content,
            'file_url': self.file_url,
            'file_name': self.file_name,
            'file_size': self.file_size,
            'duration': self.duration,
            'is_free': self.is_free,
            'order': self.order,
            'module_id': self.module_id,
            'created_at': self.created_at.iso8601_string() if self.created_at else None,
            'updated_at': self.updated_at.iso8601_string() if self.updated_at else None
        }


class Exam(db.Model):
    """Exams table"""
    __tablename__ = 'exams'
    
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid
    title = db.Column(db.String(500), nullable=False)
    description = db.Column(db.Text)
    passing_score = db.Column(db.Integer, default=60)
    duration = db.Column(db.Integer, default=30)
    max_attempts = db.Column(db.Integer, default=3)
    shuffle_questions = db.Column(db.Boolean, default=False)
    show_results = db.Column(db.Boolean, default=True)
    course_id = db.Column(db.String(36), db.ForeignKey('courses.id'), nullable=False)
    module_id = db.Column(db.String(36), db.ForeignKey('modules.id'))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    questions = db.relationship('Question', backref='exam', lazy='dynamic', cascade='all, delete-orphan')
    attempts = db.relationship('ExamAttempt', backref='exam', lazy='dynamic', cascade='all, delete-orphan')
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'passing_score': self.passing_score,
            'duration': self.duration,
            'max_attempts': self.max_attempts,
            'shuffle_questions': self.shuffle_questions,
            'show_results': self.show_results,
            'course_id': self.course_id,
            'module_id': self.module_id,
            'created_at': self.created_at.iso8601_string() if self.created_at else None,
            'updated_at': self.updated_at.iso8601_string() if self.updated_at else None
        }


class Question(db.Model):
    """Questions table"""
    __tablename__ = 'questions'
    
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid
    text = db.Column(db.Text, nullable=False)
    type = db.Column(db.Enum('MULTIPLE_CHOICE', 'TRUE_FALSE', 'TEXT', name='question_type'), default='MULTIPLE_CHOICE')
    points = db.Column(db.Integer, default=1)
    explanation = db.Column(db.Text)
    image_url = db.Column(db.String(500))
    order = db.Column(db.Integer, default=0)
    exam_id = db.Column(db.String(36), db.ForeignKey('exams.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    answers = db.relationship('Answer', backref='question', lazy='dynamic', cascade='all, delete-orphan')
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            'id': self.id,
            'text': self.text,
            'type': self.type,
            'points': self.points,
            'explanation': self.explanation,
            'image_url': self.image_url,
            'order': self.order,
            'exam_id': self.exam_id,
            'created_at': self.created_at.iso8601_string() if self.created_at else None
        }


class Answer(db.Model):
    """Answers table"""
    __tablename__ = 'answers'
    
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid
    text = db.Column(db.Text, nullable=False)
    is_correct = db.Column(db.Boolean, default=False)
    question_id = db.Column(db.String(36), db.ForeignKey('questions.id'), nullable=False)
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            'id': self.id,
            'text': self.text,
            'is_correct': self.is_correct,
            'question_id': self.question_id
        }


class Enrollment(db.Model):
    """Enrollments table"""
    __tablename__ = 'enrollments'
    
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid
    progress = db.Column(db.Integer, default=0)
    enrolled_at = db.Column(db.DateTime, default=datetime.utcnow)
    completed_at = db.Column(db.DateTime)
    last_accessed_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    student_id = db.Column(db.String(36), db.ForeignKey('profiles.id'), nullable=False)
    course_id = db.Column(db.String(36), db.ForeignKey('courses.id'), nullable=False)
    
    # Unique constraint handled in model
    __table_args__ = (
        db.UniqueConstraint('student_id', 'course_id', name='uq_enrollment_student_course'),
    )
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            'id': self.id,
            'progress': self.progress,
            'enrolled_at': self.enrolled_at.iso8601_string() if self.enrolled_at else None,
            'completed_at': self.completed_at.iso8601_string() if self.completed_at else None,
            'last_accessed_at': self.last_accessed_at.iso8601_string() if self.last_accessed_at else None,
            'student_id': self.student_id,
            'course_id': self.course_id
        }


class LessonProgress(db.Model):
    """Lesson progress tracking table"""
    __tablename__ = 'lesson_progress'
    
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid
    completed = db.Column(db.Boolean, default=False)
    completed_at = db.Column(db.DateTime)
    watch_progress = db.Column(db.Numeric(5, 2), default=0)
    student_id = db.Column(db.String(36), db.ForeignKey('profiles.id'), nullable=False)
    lesson_id = db.Column(db.String(36), db.ForeignKey('lessons.id'), nullable=False)
    
    __table_args__ = (
        db.UniqueConstraint('student_id', 'lesson_id', name='uq_lesson_progress_student_lesson'),
    )
    
    def to_dict(self):
        return {
            'id': self.id,
            'completed': self.completed,
            'completed_at': self.completed_at.iso8601_string() if self.completed_at else None,
            'watch_progress': float(self.watch_progress) if self.watch_progress else 0,
            'student_id': self.student_id,
            'lesson_id': self.lesson_id
        }


class ExamAttempt(db.Model):
    """Exam attempts table"""
    __tablename__ = 'exam_attempts'
    
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid
    score = db.Column(db.Integer, default=0)
    total_points = db.Column(db.Integer, default=0)
    passed = db.Column(db.Boolean, default=False)
    student_answers = db.Column(db.JSON, default={})
    time_spent = db.Column(db.Integer, default=0)
    completed_at = db.Column(db.DateTime, default=datetime.utcnow)
    student_id = db.Column(db.String(36), db.ForeignKey('profiles.id'), nullable=False)
    exam_id = db.Column(db.String(36), db.ForeignKey('exams.id'), nullable=False)
    
    def to_dict(self):
        return {
            'id': self.id,
            'score': self.score,
            'total_points': self.total_points,
            'passed': self.passed,
            'student_answers': self.student_answers,
            'time_spent': self.time_spent,
            'completed_at': self.completed_at.iso8601_string() if self.completed_at else None,
            'student_id': self.student_id,
            'exam_id': self.exam_id
        }


class Certificate(db.Model):
    """Certificates table"""
    __tablename__ = 'certificates'
    
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid
    certificate_number = db.Column(db.String(50), unique=True)
    certificate_url = db.Column(db.String(500))
    student_name = db.Column(db.String(255), nullable=False)
    course_name = db.Column(db.String(500), nullable=False)
    provider_name = db.Column(db.String(255), nullable=False)
    score = db.Column(db.Integer)
    issued_at = db.Column(db.DateTime, default=datetime.utcnow)
    template_name = db.Column(db.String(100))
    template_data = db.Column(db.JSON, default={})
    status = db.Column(db.Enum('ISSUED', 'REVOKED', name='certificate_status'), default='ISSUED')
    student_id = db.Column(db.String(36), db.ForeignKey('profiles.id'), nullable=False)
    course_id = db.Column(db.String(36), db.ForeignKey('courses.id'), nullable=False)
    provider_id = db.Column(db.String(36), db.ForeignKey('profiles.id'), nullable=False)
    
    def to_dict(self):
        return {
            'id': self.id,
            'certificate_number': self.certificate_number,
            'certificate_url': self.certificate_url,
            'student_name': self.student_name,
            'course_name': self.course_name,
            'provider_name': self.provider_name,
            'score': self.score,
            'issued_at': self.issued_at.iso8601_string() if self.issued_at else None,
            'template_name': self.template_name,
            'template_data': self.template_data,
            'status': self.status,
            'student_id': self.student_id,
            'course_id': self.course_id,
            'provider_id': self.provider_id
        }


class Payment(db.Model):
    """Payments table"""
    __tablename__ = 'payments'
    
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid
    amount = db.Column(db.Numeric(10, 2), nullable=False)
    currency = db.Column(db.String(10), default='YER')
    payment_method = db.Column(db.String(50))
    transaction_id = db.Column(db.String(100))
    proof_url = db.Column(db.String(500))
    status = db.Column(db.Enum('PENDING', 'APPROVED', 'REJECTED', 'REFUNDED', name='payment_status'), default='PENDING')
    notes = db.Column(db.Text)
    student_id = db.Column(db.String(36), db.ForeignKey('profiles.id'), nullable=False)
    course_id = db.Column(db.String(36), db.ForeignKey('courses.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'amount': float(self.amount),
            'currency': self.currency,
            'payment_method': self.payment_method,
            'transaction_id': self.transaction_id,
            'proof_url': self.proof_url,
            'status': self.status,
            'notes': self.notes,
            'student_id': self.student_id,
            'course_id': self.course_id,
            'created_at': self.created_at.iso8601_string() if self.created_at else None,
            'updated_at': self.updated_at.iso8601_string() if self.updated_at else None
        }


class Notification(db.Model):
    """Notifications table"""
    __tablename__ = 'notifications'
    
    id = db.Column(db.String(36), primary_key=True, default=generate_uuid
    title = db.Column(db.String(500), nullable=False)
    message = db.Column(db.Text, nullable=False)
    type = db.Column(db.Enum('INFO', 'WARNING', 'SUCCESS', 'ERROR', 'ANNOUNCEMENT', name='notification_type'), default='INFO')
    is_read = db.Column(db.Boolean, default=False)
    read_at = db.Column(db.DateTime)
    user_id = db.Column(db.String(36), db.ForeignKey('profiles.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'message': self.message,
            'type': self.type,
            'is_read': self.is_read,
            'read_at': self.read_at.iso8601_string() if self.read_at else None,
            'user_id': self.user_id,
            'created_at': self.created_at.iso8601_string() if self.created_at else None
        }