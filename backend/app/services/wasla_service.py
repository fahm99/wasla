"""
Complete Service - All Wasla Backend Services
Matches all Supabase service methods from Flutter apps
"""
from datetime import datetime, timedelta
from app.models import (
    Course, Module, Lesson, Exam, Question, Answer, Enrollment,
    LessonProgress, ExamAttempt, Certificate, CertificateTemplate,
    Payment, Notification, Rating, Announcement, SupportTicket,
    TicketReply, SystemSetting, LoginAttempt, UserSession, SecurityLog, PasswordHistory,
    Profile, RefreshToken
)
from app.extensions import db
from app.utils.errors import NotFoundError, ValidationError, AuthenticationError
import uuid
import secrets
import os


class WaslaService:
    """Main service containing all Wasla platform operations"""
    
    # ==================== USER SERVICES ====================
    
    @staticmethod
    def get_user(user_id):
        """Get user by ID"""
        user = Profile.query.get(user_id)
        if not user:
            raise NotFoundError('المستخدم غير موجود')
        return user.to_dict()
    
    @staticmethod
    def update_user_profile(user_id, **kwargs):
        """Update user profile"""
        user = Profile.query.get(user_id)
        if not user:
            raise NotFoundError('المستخدم غير موجود')
        
        allowed = ['name', 'phone', 'gender', 'bio', 'institution_name', 
                  'institution_type', 'address', 'city', 'country', 'avatar']
        for key, value in kwargs.items():
            if key in allowed and value is not None:
                setattr(user, key, value)
        
        db.session.commit()
        return user.to_dict()
    
    # ==================== COURSE SERVICES ====================
    
    @staticmethod
    def get_courses(provider_id=None, status=None, category=None):
        """Get courses"""
        query = Course.query
        if provider_id:
            query = query.filter_by(provider_id=provider_id)
        if status:
            query = query.filter_by(status=status)
        if category:
            query = query.filter_by(category=category)
        
        courses = query.order_by(Course.created_at.desc()).all()
        return [c.to_dict(include_counts=True) for c incourses]
    
    @staticmethod
    def get_published_courses(category=None, search=None):
        """Get published courses for students"""
        query = Course.query.filter_by(status='PUBLISHED')
        if category:
            query = query.filter_by(category=category)
        if search:
            query = query.filter(Course.title.contains(search))
        
        courses = query.order_by(Course.created_at.desc()).all()
        return [c.to_dict(include_counts=True) for c in courses]
    
    @staticmethod
    def get_course_by_id(course_id):
        """Get course by ID"""
        course = Course.query.get(course_id)
        if not course:
            raise NotFoundError('الدورة غير موجودة')
        return course.to_dict(include_counts=True)
    
    @staticmethod
    def create_course(provider_id, **data):
        """Create new course"""
        course = Course(
            id=str(uuid.uuid4()),
            provider_id=provider_id,
            title=data.get('title'),
            description=data.get('description'),
            short_description=data.get('shortDescription'),
            price=data.get('price', 0),
            currency=data.get('currency', 'YER'),
            level=data.get('level', 'BEGINNER'),
            language=data.get('language', 'ar'),
            image=data.get('image'),
            thumbnail=data.get('thumbnail'),
            status=data.get('status', 'DRAFT'),
            category=data.get('category'),
            tags=data.get('tags'),
            requirements=data.get('requirements'),
            objectives=data.get('objectives'),
            duration_minutes=data.get('durationMinutes', 0),
            max_students=data.get('maxStudents'),
            certificate_enabled=data.get('certificateEnabled', True)
        )
        db.session.add(course)
        db.session.commit()
        return course.to_dict(include_counts=True)
    
    @staticmethod
    def update_course(course_id, **data):
        """Update course"""
        course = Course.query.get(course_id)
        if not course:
            raise NotFoundError('الدورة غير موجودة')
        
        allowed = ['title', 'description', 'short_description', 'price', 'currency', 'level',
                 'language', 'image', 'thumbnail', 'status', 'category', 'tags',
                 'requirements', 'objectives', 'duration_minutes', 'max_students', 
                 'certificate_enabled']
        for key, value in data.items():
            if key in allowed and value is not None:
                setattr(course, key, value)
        
        db.session.commit()
        return course.to_dict(include_counts=True)
    
    @staticmethod
    def delete_course(course_id):
        """Delete course"""
        course = Course.query.get(course_id)
        if not course:
            raise NotFoundError('الدورة غير موجودة')
        db.session.delete(course)
        db.session.commit()
    
    @staticmethod
    def publish_course(course_id, publish=True):
        """Publish or unpublish course"""
        course = Course.query.get(course_id)
        if not course:
            raise NotFoundError('الدورة غير موجودة')
        course.status = 'PUBLISHED' if publish else 'DRAFT'
        db.session.commit()
        return course.to_dict(include_counts=True)
    
    # ==================== MODULE SERVICES ====================
    
    @staticmethod
    def get_modules_by_course(course_id):
        """Get modules by course"""
        modules = Module.query.filter_by(course_id=course_id).order_by(Module.sort_order).all()
        return [m.to_dict(include_counts=True) for m in modules]
    
    @staticmethod
    def create_module(course_id, title, sort_order=0, description=None):
        """Create new module"""
        course = Course.query.get(course_id)
        if not course:
            raise NotFoundError('الدورة غير موجودة')
        
        module = Module(
            id=str(uuid.uuid4()),
            course_id=course_id,
            title=title,
            description=description,
            sort_order=sort_order
        )
        db.session.add(module)
        db.session.commit()
        return module.to_dict(include_counts=True)
    
    @staticmethod
    def update_module(module_id, **data):
        """Update module"""
        module = Module.query.get(module_id)
        if not module:
            raise NotFoundError('الوحدة غير موجودة')
        
        for key, value in data.items():
            if key in ['title', 'description', 'sort_order'] and value is not None:
                setattr(module, key, value)
        
        db.session.commit()
        return module.to_dict(include_counts=True)
    
    @staticmethod
    def delete_module(module_id):
        """Delete module"""
        module = Module.query.get(module_id)
        if not module:
            raise NotFoundError('الوحدة غير موجودة')
        db.session.delete(module)
        db.session.commit()
    
    @staticmethod
    def reorder_modules(module_orders):
        """Reorder modules"""
        for order_data in module_orders:
            module = Module.query.get(order_data.get('id'))
            if module:
                module.sort_order = order_data.get('order')
        db.session.commit()
    
    # ==================== LESSON SERVICES ====================
    
    @staticmethod
    def get_lessons_by_module(module_id):
        """Get lessons by module"""
        lessons = Lesson.query.filter_by(module_id=module_id).order_by(Lesson.sort_order).all()
        return [l.to_dict() for l in lessons]
    
    @staticmethod
    def get_lesson_by_id(lesson_id):
        """Get lesson by ID"""
        lesson = Lesson.query.get(lesson_id)
        if not lesson:
            raise NotFoundError('الدرس غير موجود')
        return lesson.to_dict()
    
    @staticmethod
    def create_lesson(module_id, **data):
        """Create new lesson"""
        module = Module.query.get(module_id)
        if not module:
            raise NotFoundError('الوحدة غير موجودة')
        
        lesson = Lesson(
            id=str(uuid.uuid4()),
            module_id=module_id,
            title=data.get('title'),
            description=data.get('description'),
            type=data.get('type', 'TEXT'),
            content=data.get('content', ''),
            file_url=data.get('fileUrl'),
            file_name=data.get('fileName'),
            file_size=data.get('fileSize', 0),
            duration=data.get('duration', 0),
            is_free=data.get('isFree', False),
            sort_order=data.get('sort_order', 0)
        )
        db.session.add(lesson)
        db.session.commit()
        return lesson.to_dict()
    
    @staticmethod
    def update_lesson(lesson_id, **data):
        """Update lesson"""
        lesson = Lesson.query.get(lesson_id)
        if not lesson:
            raise NotFoundError('الدرس غير موجود')
        
        allowed = ['title', 'description', 'type', 'content', 'file_url', 
                 'file_name', 'file_size', 'duration', 'is_free', 'sort_order']
        for key, value in data.items():
            if key in allowed and value is not None:
                setattr(lesson, key, value)
        
        db.session.commit()
        return lesson.to_dict()
    
    @staticmethod
    def delete_lesson(lesson_id):
        """Delete lesson"""
        lesson = Lesson.query.get(lesson_id)
        if not lesson:
            raise NotFoundError('الدرس غير موجود')
        db.session.delete(lesson)
        db.session.commit()
    
    @staticmethod
    def reorder_lessons(lesson_orders):
        """Reorder lessons"""
        for order_data in lesson_orders:
            lesson = Lesson.query.get(order_data.get('id'))
            if lesson:
                lesson.sort_order = order_data.get('order')
        db.session.commit()
    
    # ==================== EXAM SERVICES ====================
    
    @staticmethod
    def get_exams_by_course(course_id):
        """Get exams by course"""
        exams = Exam.query.filter_by(course_id=course_id).order_by(Exam.created_at).all()
        return [e.to_dict() for e in exams]
    
    @staticmethod
    def get_exam_by_id(exam_id):
        """Get exam by ID"""
        exam = Exam.query.get(exam_id)
        if not exam:
            raise NotFoundError('الاختبار غير موجود')
        return exam.to_dict()
    
    @staticmethod
    def create_exam(course_id, **data):
        """Create exam"""
        course = Course.query.get(course_id)
        if not course:
            raise NotFoundError('الدورة غير موجودة')
        
        exam = Exam(
            id=str(uuid.uuid4()),
            course_id=course_id,
            title=data.get('title'),
            description=data.get('description'),
            passing_score=data.get('passingScore', 60),
            duration=data.get('duration', 30),
            max_attempts=data.get('maxAttempts', 3),
            shuffle_questions=data.get('shuffleQuestions', False),
            show_results=data.get('showResults', True),
            module_id=data.get('moduleId')
        )
        db.session.add(exam)
        db.session.commit()
        return exam.to_dict()
    
    @staticmethod
    def update_exam(exam_id, **data):
        """Update exam"""
        exam = Exam.query.get(exam_id)
        if not exam:
            raise NotFoundError('الاختبار غير موجود')
        
        allowed = ['title', 'description', 'passing_score', 'duration', 
                  'max_attempts', 'shuffle_questions', 'show_results']
        for key, value in data.items():
            if key in allowed and value is not None:
                setattr(exam, key, value)
        
        db.session.commit()
        return exam.to_dict()
    
    @staticmethod
    def delete_exam(exam_id):
        """Delete exam"""
        exam = Exam.query.get(exam_id)
        if not exam:
            raise NotFoundError('الاختبار غير موجود')
        db.session.delete(exam)
        db.session.commit()
    
    # ==================== QUESTION SERVICES ====================
    
    @staticmethod
    def get_questions_by_exam(exam_id):
        """Get questions by exam"""
        questions = Question.query.filter_by(exam_id=exam_id).order_by(Question.sort_order).all()
        return [q.to_dict() for q in questions]
    
    @staticmethod
    def create_question(exam_id, **data):
        """Create question"""
        exam = Exam.query.get(exam_id)
        if not exam:
            raise NotFoundError('الاختبار غير موجود')
        
        question = Question(
            id=str(uuid.uuid4()),
            exam_id=exam_id,
            text=data.get('text'),
            type=data.get('type', 'MULTIPLE_CHOICE'),
            points=data.get('points', 1),
            explanation=data.get('explanation'),
            image_url=data.get('imageUrl'),
            sort_order=data.get('sort_order', 0)
        )
        db.session.add(question)
        db.session.commit()
        return question.to_dict()
    
    @staticmethod
    def update_question(question_id, **data):
        """Update question"""
        question = Question.query.get(question_id)
        if not question:
            raise NotFoundError('السؤال غير موجود')
        
        for key, value in data.items():
            if key in ['text', 'type', 'points', 'explanation', 'image_url', 'sort_order'] and value is not None:
                setattr(question, key, value)
        
        db.session.commit()
        return question.to_dict()
    
    @staticmethod
    def delete_question(question_id):
        """Delete question"""
        question = Question.query.get(question_id)
        if not question:
            raise NotFoundError('السؤال غير موجود')
        db.session.delete(question)
        db.session.commit()
    
    # ==================== ANSWER SERVICES ====================
    
    @staticmethod
    def get_answers_by_question(question_id):
        """Get answers by question"""
        answers = Answer.query.filter_by(question_id=question_id).all()
        return [a.to_dict() for a in answers]
    
    @staticmethod
    def create_answer(question_id, **data):
        """Create answer"""
        question = Question.query.get(question_id)
        if not question:
            raise NotFoundError('السؤال غير موجود')
        
        answer = Answer(
            id=str(uuid.uuid4()),
            question_id=question_id,
            text=data.get('text'),
            is_correct=data.get('isCorrect', False)
        )
        db.session.add(answer)
        db.session.commit()
        return answer.to_dict()
    
    @staticmethod
    def update_answer(answer_id, **data):
        """Update answer"""
        answer = Answer.query.get(answer_id)
        if not answer:
            raise NotFoundError('الإجابة غير موجودة')
        
        for key, value in data.items():
            if key in ['text', 'is_correct'] and value is not None:
                setattr(answer, key, value)
        
        db.session.commit()
        return answer.to_dict()
    
    @staticmethod
    def delete_answer(answer_id):
        """Delete answer"""
        answer = Answer.query.get(answer_id)
        if not answer:
            raise NotFoundError('الإجابة غير موجودة')
        db.session.delete(answer)
        db.session.commit()
    
    # ==================== ENROLLMENT SERVICES ====================
    
    @staticmethod
    def enroll_in_course(student_id, course_id):
        """Enroll student in course"""
        course = Course.query.get(course_id)
        if not course:
            raise NotFoundError('الدورة غير موجودة')
        
        # Check existing enrollment
        existing = Enrollment.query.filter_by(student_id=student_id, course_id=course_id).first()
        if existing:
            return existing.to_dict()
        
        # Check if course is free or paid
        if float(course.price) > 0:
            # Need payment - but allow enrollment for now
            pass
        
        enrollment = Enrollment(
            id=str(uuid.uuid4()),
            student_id=student_id,
            course_id=course_id,
            progress=0
        )
        db.session.add(enrollment)
        
        # Create notification
        notification = Notification(
            id=str(uuid.uuid4()),
            title='تم التسجيل في الدورة',
            message=f'تم التسجيل في دورة {course.title} بنجاح',
            user_id=student_id
        )
        db.session.add(notification)
        db.session.commit()
        
        return enrollment.to_dict()
    
    @staticmethod
    def get_enrollments_by_student(student_id):
        """Get student enrollments"""
        enrollments = Enrollment.query.filter_by(student_id=student_id).all()
        return [e.to_dict() for e in enrollments]
    
    @staticmethod
    def get_enrollments_by_course(course_id):
        """Get course enrollments"""
        enrollments = Enrollment.query.filter_by(course_id=course_id).all()
        return [e.to_dict() for e in enrollments]
    
    @staticmethod
    def get_enrollment(student_id, course_id):
        """Get enrollment"""
        enrollment = Enrollment.query.filter_by(student_id=student_id, course_id=course_id).first()
        if not enrollment:
            return None
        return enrollment.to_dict()
    
    @staticmethod
    def update_progress(enrollment_id, progress):
        """Update enrollment progress"""
        enrollment = Enrollment.query.get(enrollment_id)
        if not enrollment:
            raise NotFoundError('التسجيل غير موجود')
        
        enrollment.progress = progress
        if progress >= 100:
            enrollment.completed_at = datetime.utcnow()
        
        db.session.commit()
        return enrollment.to_dict()
    
    @staticmethod
    def get_course_progress(student_id, course_id):
        """Calculate course progress"""
        enrollment = Enrollment.query.filter_by(student_id=student_id, course_id=course_id).first()
        if not enrollment:
            return 0.0
        return float(enrollment.progress)
    
    # ==================== LESSON PROGRESS SERVICES ====================
    
    @staticmethod
    def mark_lesson_complete(student_id, lesson_id):
        """Mark lesson as complete"""
        lesson = Lesson.query.get(lesson_id)
        if not lesson:
            raise NotFoundError('الدرس غير موجود')
        
        progress = LessonProgress.query.filter_by(student_id=student_id, lesson_id=lesson_id).first()
        if progress:
            progress.completed = True
            progress.completed_at = datetime.utcnow()
            progress.watch_progress = 100
        else:
            progress = LessonProgress(
                id=str(uuid.uuid4()),
                student_id=student_id,
                lesson_id=lesson_id,
                completed=True,
                completed_at=datetime.utcnow(),
                watch_progress=100
            )
            db.session.add(progress)
        
        db.session.commit()
        
        # Update enrollment progress
        module = lesson.module
        if module:
            course = module.course
            if course:
                WaslaService._update_enrollment_progress(student_id, course.id)
        
        return progress.to_dict() if progress else None
    
    @staticmethod
    def get_lesson_progress(student_id, lesson_id):
        """Get lesson progress"""
        progress = LessonProgress.query.filter_by(student_id=student_id, lesson_id=lesson_id).first()
        return progress.to_dict() if progress else None
    
    @staticmethod
    def _update_enrollment_progress(student_id, course_id):
        """Update enrollment progress based on completed lessons"""
        enrollment = Enrollment.query.filter_by(student_id=student_id, course_id=course_id).first()
        if not enrollment:
            return
        
        # Get all lessons
        course = Course.query.get(course_id)
        if not course:
            return
        
        total_lessons = 0
        completed_lessons = 0
        
        for module in course.modules:
            for lesson in module.lessons:
                total_lessons += 1
                progress = LessonProgress.query.filter_by(
                    student_id=student_id, 
                    lesson_id=lesson.id,
                    completed=True
                ).first()
                if progress:
                    completed_lessons += 1
        
        if total_lessons > 0:
            enrollment.progress = int((completed_lessons / total_lessons) * 100)
        
        if enrollment.progress >= 100:
            enrollment.completed_at = datetime.utcnow()
        
        db.session.commit()
    
    # ==================== EXAM ATTEMPT SERVICES ====================
    
    @staticmethod
    def submit_exam_attempt(student_id, exam_id, answers, time_spent):
        """Submit exam attempt"""
        exam = Exam.query.get(exam_id)
        if not exam:
            raise NotFoundError('الاختبار غير موجود')
        
        # Calculate score
        score = 0
        total_points = 0
        passed = False
        
        for ans in answers:
            question = Question.query.get(ans.get('questionId'))
            if question:
                total_points += question.points
                answer = Answer.query.get(ans.get('answerId'))
                if answer and answer.is_correct:
                    score += question.points
        
        if total_points > 0:
            score_percent = (score / total_points) * 100
            passed = score_percent >= exam.passing_score
        
        attempt = ExamAttempt(
            id=str(uuid.uuid4()),
            student_id=student_id,
            exam_id=exam_id,
            score=score,
            total_points=total_points,
            passed=passed,
            student_answers=answers,
            time_spent=time_spent,
            completed_at=datetime.utcnow()
        )
        db.session.add(attempt)
        db.session.commit()
        
        return {'id': attempt.id, 'score': score, 'passed': passed}
    
    @staticmethod
    def get_exam_attempts_count(student_id, exam_id):
        """Get exam attempts count"""
        return ExamAttempt.query.filter_by(student_id=student_id, exam_id=exam_id).count()
    
    @staticmethod
    def get_exam_attempt(attempt_id):
        """Get exam attempt"""
        attempt = ExamAttempt.query.get(attempt_id)
        if not attempt:
            raise NotFoundError('محاولة الاختبار غير موجودة')
        return attempt.to_dict()
    
    # ==================== CERTIFICATE SERVICES ====================
    
    @staticmethod
    def get_certificates_by_provider(provider_id):
        """Get certificates by provider"""
        certs = Certificate.query.filter_by(provider_id=provider_id).order_by(Certificate.issued_at.desc()).all()
        return [c.to_dict() for c in certs]
    
    @staticmethod
    def get_certificates_by_course(course_id):
        """Get certificates by course"""
        certs = Certificate.query.filter_by(course_id=course_id).order_by(Certificate.issued_at.desc()).all()
        return [c.to_dict() for c in certs]
    
    @staticmethod
    def get_my_certificates(student_id):
        """Get student certificates"""
        certs = Certificate.query.filter_by(student_id=student_id, status='ISSUED').order_by(Certificate.issued_at.desc()).all()
        return [c.to_dict() for c in certs]
    
    @staticmethod
    def get_certificate_by_id(cert_id):
        """Get certificate by ID"""
        cert = Certificate.query.get(cert_id)
        if not cert:
            raise NotFoundError('الشهادة غير موجودة')
        return cert.to_dict()
    
    @staticmethod
    def issue_certificate(student_id, course_id, provider_id, **data):
        """Issue certificate"""
        cert_number = f'CERT-{datetime.utcnow().strftime("%Y%m%d%H%M%S")}'
        
        certificate = Certificate(
            id=str(uuid.uuid4()),
            certificate_number=cert_number,
            student_id=student_id,
            course_id=course_id,
            provider_id=provider_id,
            student_name=data.get('studentName'),
            course_name=data.get('courseName'),
            provider_name=data.get('providerName'),
            score=data.get('score')
        )
        db.session.add(certificate)
        db.session.commit()
        
        return certificate.to_dict()
    
    # ==================== CERTIFICATE TEMPLATE SERVICES ====================
    
    @staticmethod
    def get_certificate_templates(provider_id):
        """Get certificate templates"""
        templates = CertificateTemplate.query.filter_by(provider_id=provider_id).all()
        return [t.to_dict() for t in templates]
    
    @staticmethod
    def create_certificate_template(provider_id, **data):
        """Create certificate template"""
        template = CertificateTemplate(
            id=str(uuid.uuid4()),
            provider_id=provider_id,
            name=data.get('name'),
            description=data.get('description'),
            background_color=data.get('backgroundColor', '#ffffff'),
            text_color=data.get('textColor', '#000000'),
            accent_color=data.get('accentColor', '#0c1445'),
            logo_url=data.get('logoUrl'),
            signature_url=data.get('signatureUrl'),
            signature_name=data.get('signatureName'),
            signature_title=data.get('signatureTitle'),
            is_default=data.get('isDefault', False)
        )
        db.session.add(template)
        db.session.commit()
        return template.to_dict()
    
    @staticmethod
    def update_certificate_template(template_id, **data):
        """Update certificate template"""
        template = CertificateTemplate.query.get(template_id)
        if not template:
            raise NotFoundError('القالب غير موجود')
        
        for key, value in data.items():
            if value is not None:
                setattr(template, key, value)
        
        db.session.commit()
        return template.to_dict()
    
    @staticmethod
    def delete_certificate_template(template_id):
        """Delete certificate template"""
        template = CertificateTemplate.query.get(template_id)
        if not template:
            raise NotFoundError('القالب غير موجود')
        db.session.delete(template)
        db.session.commit()
    
    # ==================== PAYMENT SERVICES ====================
    
    @staticmethod
    def get_payments_by_provider(provider_id):
        """Get payments by provider"""
        # Get provider's courses
        course_ids = [c.id for c in Course.query.filter_by(provider_id=provider_id).all()]
        
        payments = Payment.query.filter(Payment.course_id.in_(course_ids)).order_by(Payment.created_at.desc()).all()
        return [p.to_dict() for p in payments]
    
    @staticmethod
    def create_payment(student_id, course_id, **data):
        """Create payment"""
        course = Course.query.get(course_id)
        if not course:
            raise NotFoundError('الدورة غير موجودة')
        
        payment = Payment(
            id=str(uuid.uuid4()),
            student_id=student_id,
            course_id=course_id,
            amount=course.price,
            currency=course.currency,
            payment_method=data.get('paymentMethod'),
            status='PENDING'
        )
        db.session.add(payment)
        db.session.commit()
        return payment.to_dict()
    
    @staticmethod
    def upload_payment_proof(payment_id, proof_url):
        """Upload payment proof"""
        payment = Payment.query.get(payment_id)
        if not payment:
            raise NotFoundError('الدفع غير موجود')
        
        payment.proof_url = proof_url
        db.session.commit()
        return payment.to_dict()
    
    @staticmethod
    def approve_payment(payment_id, approve=True, notes=None):
        """Approve/reject payment"""
        payment = Payment.query.get(payment_id)
        if not payment:
            raise NotFoundError('الدفع غير موجود')
        
        payment.status = 'APPROVED' if approve else 'REJECTED'
        if notes:
            payment.notes = notes
        
        if approve:
            # Auto-enroll student
            course = payment.course
            if course:
                WaslaService.enroll_in_course(payment.student_id, course.id)
        
        db.session.commit()
        return payment.to_dict()
    
    # ==================== NOTIFICATION SERVICES ====================
    
    @staticmethod
    def get_my_notifications(user_id):
        """Get user notifications"""
        notifs = Notification.query.filter_by(user_id=user_id).order_by(Notification.created_at.desc()).all()
        return [n.to_dict() for n in notifs]
    
    @staticmethod
    def create_notification(user_id, **data):
        """Create notification"""
        notification = Notification(
            id=str(uuid.uuid4()),
            user_id=user_id,
            title=data.get('title'),
            message=data.get('message'),
            type=data.get('type', 'INFO')
        )
        db.session.add(notification)
        db.session.commit()
        return notification.to_dict()
    
    @staticmethod
    def mark_notification_read(notification_id):
        """Mark notification as read"""
        notif = Notification.query.get(notification_id)
        if not notif:
            raise NotFoundError('الإشعار غير موجود')
        
        notif.is_read = True
        notif.read_at = datetime.utcnow()
        db.session.commit()
        return notif.to_dict()
    
    @staticmethod
    def mark_all_notifications_read(user_id):
        """Mark all notifications as read"""
        Notification.query.filter_by(user_id=user_id, is_read=False).update({
            'is_read': True,
            'read_at': datetime.utcnow()
        })
        db.session.commit()
    
    @staticmethod
    def get_unread_count(user_id):
        """Get unread notification count"""
        return Notification.query.filter_by(user_id=user_id, is_read=False).count()
    
    # ==================== RATING SERVICES ====================
    
    @staticmethod
    def get_course_ratings(course_id):
        """Get course ratings"""
        ratings = Rating.query.filter_by(course_id=course_id).all()
        return [r.to_dict() for r in ratings]
    
    @staticmethod
    def get_my_rating(student_id, course_id):
        """Get my rating for course"""
        rating = Rating.query.filter_by(student_id=student_id, course_id=course_id).first()
        return rating.to_dict() if rating else None
    
    @staticmethod
    def submit_rating(student_id, course_id, rating, review=None):
        """Submit rating"""
        existing = Rating.query.filter_by(student_id=student_id, course_id=course_id).first()
        
        if existing:
            existing.rating = rating
            existing.review = review
        else:
            rating_obj = Rating(
                id=str(uuid.uuid4()),
                student_id=student_id,
                course_id=course_id,
                rating=rating,
                review=review
            )
            db.session.add(rating_obj)
        
        db.session.commit()
        return existing.to_dict() if existing else rating_obj.to_dict()
    
    # ==================== DASHBOARD SERVICES ====================
    
    @staticmethod
    def get_dashboard_stats(provider_id):
        """Get provider dashboard stats"""
        courses = Course.query.filter_by(provider_id=provider_id).all()
        
        total_courses = len(courses)
        total_students = 0
        total_revenue = 0
        
        for course in courses:
            total_students += course.enrollments.count()
            
            # Revenue from approved payments
            payments = Payment.query.filter_by(
                course_id=course.id, 
                status='APPROVED'
            ).all()
            for p in payments:
                total_revenue += float(p.amount)
        
        return {
            'totalCourses': total_courses,
            'totalStudents': total_students,
            'totalRevenue': total_revenue
        }
    
    @staticmethod
    def get_student_stats(student_id):
        """Get student stats"""
        enrollments = Enrollment.query.filter_by(student_id=student_id).all()
        
        total_enrolled = len(enrollments)
        completed = sum(1 for e in enrollments if e.completed_at)
        certificates = Certificate.query.filter_by(student_id=student_id, status='ISSUED').count()
        
        return {
            'totalEnrolled': total_enrolled,
            'completed': completed,
            'certificates': certificates
        }
    
    # ==================== FILE UPLOAD SERVICES ====================
    
    @staticmethod
    def upload_file(file, folder='general'):
        """Upload file"""
        import hashlib
        import time
        
        # Generate filename
        ext = os.path.splitext(file.filename)[1] if file else '.bin'
        filename = f"{int(time.time())}_{hashlib.md5(str(time.time()).encode()).hexdigest()[:8]}{ext}"
        
        # In production, save to S3 or local storage
        # For now, just return a placeholder URL
        return f"/uploads/{folder}/{filename}"
    
    # ==================== ANNOUNCEMENT SERVICES ====================
    
    @staticmethod
    def get_active_announcements():
        """Get active announcements"""
        now = datetime.utcnow()
        announcs = Announcement.query.filter(
            Announcement.is_active == True,
            Announcement.start_date <= now,
            Announcement.end_date >= now
        ).all()
        return [a.to_dict() for a in announcs]
    
    # ==================== SUPPORT TICKET SERVICES ====================
    
    @staticmethod
    def create_support_ticket(user_id, subject, description, category='general', priority='medium'):
        """Create support ticket"""
        ticket = SupportTicket(
            id=str(uuid.uuid4()),
            user_id=user_id,
            subject=subject,
            description=description,
            category=category,
            priority=priority,
            status='open'
        )
        db.session.add(ticket)
        db.session.commit()
        return ticket.to_dict()
    
    @staticmethod
    def add_ticket_reply(ticket_id, user_id, message, is_admin=False):
        """Add ticket reply"""
        reply = TicketReply(
            id=str(uuid.uuid4()),
            ticket_id=ticket_id,
            user_id=user_id,
            message=message,
            is_admin_reply=is_admin
        )
        db.session.add(reply)
        
        # Update ticket status
        ticket = SupportTicket.query.get(ticket_id)
        if ticket:
            ticket.status = 'in_progress'
        
        db.session.commit()
        return reply.to_dict()
    
    # ==================== CATEGORY SERVICES ====================
    
    @staticmethod
    def get_categories():
        """Get all course categories"""
        courses = Course.query.filter_by(status='PUBLISHED').with_entities(Course.category).distinct().all()
        return [c.category for c in courses if c.category]
    
    # ==================== STUDENT SERVICES ====================
    
    @staticmethod
    def get_students_by_course(course_id):
        """Get students enrolled in course"""
        enrollments = Enrollment.query.filter_by(course_id=course_id).all()
        students = []
        for e in enrollments:
            student = Profile.query.get(e.student_id)
            if student:
                students.append(student.to_dict())
        return students