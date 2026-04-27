"""
Complete API Routes - All Wasla Backend Endpoints
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.services.wasla_service import WaslaService
from app.services.auth_service import AuthService
from app.utils.errors import handle_exceptions, APIError

api = Blueprint('api', __name__, url_prefix='/api')


# ==================== AUTH ROUTES ====================

@api.route('/auth/signin', methods=['POST'])
@handle_exceptions
def signin():
    data = request.get_json()
    result = AuthService.sign_in(
        data.get('email'),
        data.get('password'),
        data.get('requiredRole')
    )
    return jsonify(result), 200


@api.route('/auth/signup', methods=['POST'])
@handle_exceptions
def signup():
    data = request.get_json()
    result = AuthService.sign_up(
        name=data.get('name'),
        email=data.get('email'),
        password=data.get('password'),
        role=data.get('role', 'STUDENT'),
        phone=data.get('phone'),
        gender=data.get('gender'),
        institution_type=data.get('institutionType'),
        institution_name=data.get('institutionName')
    )
    return jsonify(result), 201


@api.route('/auth/signout', methods=['POST'])
@jwt_required()
@handle_exceptions
def signout():
    user_id = get_jwt_identity()
    AuthService.sign_out(user_id)
    return jsonify({'message': 'success'}), 200


@api.route('/auth/me', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_current_user():
    user_id = get_jwt_identity()
    result = AuthService.get_current_user(user_id)
    return jsonify(result), 200


@api.route('/auth/refresh', methods=['POST'])
@jwt_required(refresh=True)
@handle_exceptions
def refresh_token():
    user_id = get_jwt_identity()
    result = AuthService.refresh_access_token(user_id)
    return jsonify(result), 200


@api.route('/auth/reset-password', methods=['POST'])
@handle_exceptions
def reset_password():
    data = request.get_json()
    result = AuthService.reset_password(data.get('email'))
    return jsonify(result), 200


@api.route('/auth/update-password', methods=['PUT'])
@jwt_required()
@handle_exceptions
def update_password():
    data = request.get_json()
    user_id = get_jwt_identity()
    result = AuthService.update_password(user_id, data.get('oldPassword'), data.get('newPassword'))
    return jsonify(result), 200


@api.route('/auth/profile', methods=['PUT'])
@jwt_required()
@handle_exceptions
def update_profile():
    data = request.get_json()
    user_id = get_jwt_identity()
    result = AuthService.update_profile(user_id, **data)
    return jsonify(result), 200


# ==================== COURSE ROUTES ====================

@api.route('/courses', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_courses():
    provider_id = request.args.get('providerId')
    status = request.args.get('status')
    category = request.args.get('category')
    
    if provider_id:
        courses = WaslaService.get_courses(provider_id, status)
    else:
        courses = WaslaService.get_published_courses(category)
    
    return jsonify(courses), 200


@api.route('/courses/<course_id>', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_course(course_id):
    course = WaslaService.get_course_by_id(course_id)
    return jsonify(course), 200


@api.route('/courses', methods=['POST'])
@jwt_required()
@handle_exceptions
def create_course():
    data = request.get_json()
    user_id = get_jwt_identity()
    course = WaslaService.create_course(user_id, **data)
    return jsonify(course), 201


@api.route('/courses/<course_id>', methods=['PUT'])
@jwt_required()
@handle_exceptions
def update_course(course_id):
    data = request.get_json()
    course = WaslaService.update_course(course_id, **data)
    return jsonify(course), 200


@api.route('/courses/<course_id>', methods=['DELETE'])
@jwt_required()
@handle_exceptions
def delete_course(course_id):
    WaslaService.delete_course(course_id)
    return jsonify({'message': 'success'}), 200


@api.route('/courses/<course_id>/publish', methods=['PUT'])
@jwt_required()
@handle_exceptions
def publish_course(course_id):
    data = request.get_json()
    course = WaslaService.publish_course(course_id, data.get('publish', True))
    return jsonify(course), 200


# ==================== MODULE ROUTES ====================

@api.route('/courses/<course_id>/modules', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_modules(course_id):
    modules = WaslaService.get_modules_by_course(course_id)
    return jsonify(modules), 200


@api.route('/modules', methods=['POST'])
@jwt_required()
@handle_exceptions
def create_module():
    data = request.get_json()
    module = WaslaService.create_module(
        data.get('courseId'),
        data.get('title'),
        data.get('order', 0),
        data.get('description')
    )
    return jsonify(module), 201


@api.route('/modules/<module_id>', methods=['PUT'])
@jwt_required()
@handle_exceptions
def update_module(module_id):
    data = request.get_json()
    module = WaslaService.update_module(module_id, **data)
    return jsonify(module), 200


@api.route('/modules/<module_id>', methods=['DELETE'])
@jwt_required()
@handle_exceptions
def delete_module(module_id):
    WaslaService.delete_module(module_id)
    return jsonify({'message': 'success'}), 200


@api.route('/modules/reorder', methods=['PUT'])
@jwt_required()
@handle_exceptions
def reorder_modules():
    data = request.get_json()
    WaslaService.reorder_modules(data.get('orders', []))
    return jsonify({'message': 'success'}), 200


# ==================== LESSON ROUTES ====================

@api.route('/modules/<module_id>/lessons', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_lessons(module_id):
    lessons = WaslaService.get_lessons_by_module(module_id)
    return jsonify(lessons), 200


@api.route('/lessons/<lesson_id>', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_lesson(lesson_id):
    lesson = WaslaService.get_lesson_by_id(lesson_id)
    return jsonify(lesson), 200


@api.route('/lessons', methods=['POST'])
@jwt_required()
@handle_exceptions
def create_lesson():
    data = request.get_json()
    lesson = WaslaService.create_lesson(data.get('moduleId'), **data)
    return jsonify(lesson), 201


@api.route('/lessons/<lesson_id>', methods=['PUT'])
@jwt_required()
@handle_exceptions
def update_lesson(lesson_id):
    data = request.get_json()
    lesson = WaslaService.update_lesson(lesson_id, **data)
    return jsonify(lesson), 200


@api.route('/lessons/<lesson_id>', methods=['DELETE'])
@jwt_required()
@handle_exceptions
def delete_lesson(lesson_id):
    WaslaService.delete_lesson(lesson_id)
    return jsonify({'message': 'success'}), 200


@api.route('/lessons/reorder', methods=['PUT'])
@jwt_required()
@handle_exceptions
def reorder_lessons():
    data = request.get_json()
    WaslaService.reorder_lessons(data.get('orders', []))
    return jsonify({'message': 'success'}), 200


@api.route('/lessons/<lesson_id>/complete', methods=['POST'])
@jwt_required()
@handle_exceptions
def mark_lesson_complete(lesson_id):
    user_id = get_jwt_identity()
    result = WaslaService.mark_lesson_complete(user_id, lesson_id)
    return jsonify(result), 200


@api.route('/lessons/<lesson_id>/progress', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_lesson_progress(lesson_id):
    user_id = get_jwt_identity()
    result = WaslaService.get_lesson_progress(user_id, lesson_id)
    return jsonify(result or {}), 200


# ==================== EXAM ROUTES ====================

@api.route('/courses/<course_id>/exams', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_exams(course_id):
    exams = WaslaService.get_exams_by_course(course_id)
    return jsonify(exams), 200


@api.route('/exams/<exam_id>', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_exam(exam_id):
    exam = WaslaService.get_exam_by_id(exam_id)
    return jsonify(exam), 200


@api.route('/exams', methods=['POST'])
@jwt_required()
@handle_exceptions
def create_exam():
    data = request.get_json()
    exam = WaslaService.create_exam(data.get('courseId'), **data)
    return jsonify(exam), 201


@api.route('/exams/<exam_id>', methods=['PUT'])
@jwt_required()
@handle_exceptions
def update_exam(exam_id):
    data = request.get_json()
    exam = WaslaService.update_exam(exam_id, **data)
    return jsonify(exam), 200


@api.route('/exams/<exam_id>', methods=['DELETE'])
@jwt_required()
@handle_exceptions
def delete_exam(exam_id):
    WaslaService.delete_exam(exam_id)
    return jsonify({'message': 'success'}), 200


# ==================== QUESTION ROUTES ====================

@api.route('/exams/<exam_id>/questions', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_questions(exam_id):
    questions = WaslaService.get_questions_by_exam(exam_id)
    return jsonify(questions), 200


@api.route('/questions', methods=['POST'])
@jwt_required()
@handle_exceptions
def create_question():
    data = request.get_json()
    question = WaslaService.create_question(data.get('examId'), **data)
    return jsonify(question), 201


@api.route('/questions/<question_id>', methods=['PUT'])
@jwt_required()
@handle_exceptions
def update_question(question_id):
    data = request.get_json()
    question = WaslaService.update_question(question_id, **data)
    return jsonify(question), 200


@api.route('/questions/<question_id>', methods=['DELETE'])
@jwt_required()
@handle_exceptions
def delete_question(question_id):
    WaslaService.delete_question(question_id)
    return jsonify({'message': 'success'}), 200


# ==================== ANSWER ROUTES ====================

@api.route('/questions/<question_id>/answers', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_answers(question_id):
    answers = WaslaService.get_answers_by_question(question_id)
    return jsonify(answers), 200


@api.route('/answers', methods=['POST'])
@jwt_required()
@handle_exceptions
def create_answer():
    data = request.get_json()
    answer = WaslaService.create_answer(data.get('questionId'), **data)
    return jsonify(answer), 201


@api.route('/answers/<answer_id>', methods=['PUT'])
@jwt_required()
@handle_exceptions
def update_answer(answer_id):
    data = request.get_json()
    answer = WaslaService.update_answer(answer_id, **data)
    return jsonify(answer), 200


@api.route('/answers/<answer_id>', methods=['DELETE'])
@jwt_required()
@handle_exceptions
def delete_answer(answer_id):
    WaslaService.delete_answer(answer_id)
    return jsonify({'message': 'success'}), 200


# ==================== ENROLLMENT ROUTES ====================

@api.route('/enrollments', methods=['POST'])
@jwt_required()
@handle_exceptions
def enroll_in_course():
    data = request.get_json()
    user_id = get_jwt_identity()
    result = WaslaService.enroll_in_course(user_id, data.get('courseId'))
    return jsonify(result), 201


@api.route('/student/enrollments', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_my_enrollments():
    user_id = get_jwt_identity()
    enrollments = WaslaService.get_enrollments_by_student(user_id)
    return jsonify(enrollments), 200


@api.route('/courses/<course_id>/enrollments', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_course_enrollments(course_id):
    enrollments = WaslaService.get_enrollments_by_course(course_id)
    return jsonify(enrollments), 200


@api.route('/enrollments/<enrollment_id>/progress', methods=['PUT'])
@jwt_required()
@handle_exceptions
def update_enrollment_progress(enrollment_id):
    data = request.get_json()
    result = WaslaService.update_progress(enrollment_id, data.get('progress'))
    return jsonify(result), 200


@api.route('/courses/<course_id>/progress', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_course_progress(course_id):
    user_id = get_jwt_identity()
    progress = WaslaService.get_course_progress(user_id, course_id)
    return jsonify({'progress': progress}), 200


# ==================== EXAM ATTEMPT ROUTES ====================

@api.route('/exams/<exam_id>/attempt', methods=['POST'])
@jwt_required()
@handle_exceptions
def submit_exam_attempt(exam_id):
    data = request.get_json()
    user_id = get_jwt_identity()
    result = WaslaService.submit_exam_attempt(
        user_id,
        exam_id,
        data.get('answers', []),
        data.get('timeSpent', 0)
    )
    return jsonify(result), 201


@api.route('/exams/<exam_id>/attempts/count', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_exam_attempts_count(exam_id):
    user_id = get_jwt_identity()
    count = WaslaService.get_exam_attempts_count(user_id, exam_id)
    return jsonify({'count': count}), 200


@api.route('/attempts/<attempt_id>', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_attempt(attempt_id):
    attempt = WaslaService.get_exam_attempt(attempt_id)
    return jsonify(attempt), 200


# ==================== CERTIFICATE ROUTES ====================

@api.route('/provider/certificates', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_provider_certificates():
    user_id = get_jwt_identity()
    certs = WaslaService.get_certificates_by_provider(user_id)
    return jsonify(certs), 200


@api.route('/courses/<course_id>/certificates', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_course_certificates(course_id):
    certs = WaslaService.get_certificates_by_course(course_id)
    return jsonify(certs), 200


@api.route('/student/certificates', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_my_certificates():
    user_id = get_jwt_identity()
    certs = WaslaService.get_my_certificates(user_id)
    return jsonify(certs), 200


@api.route('/certificates/<cert_id>', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_certificate(cert_id):
    cert = WaslaService.get_certificate_by_id(cert_id)
    return jsonify(cert), 200


@api.route('/certificates', methods=['POST'])
@jwt_required()
@handle_exceptions
def issue_certificate():
    data = request.get_json()
    user_id = get_jwt_identity()
    cert = WaslaService.issue_certificate(
        data.get('studentId'),
        data.get('courseId'),
        user_id,
        **data
    )
    return jsonify(cert), 201


# ==================== CERTIFICATE TEMPLATE ROUTES ====================

@api.route('/provider/certificate-templates', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_certificate_templates():
    user_id = get_jwt_identity()
    templates = WaslaService.get_certificate_templates(user_id)
    return jsonify(templates), 200


@api.route('/certificate-templates', methods=['POST'])
@jwt_required()
@handle_exceptions
def create_certificate_template():
    data = request.get_json()
    user_id = get_jwt_identity()
    template = WaslaService.create_certificate_template(user_id, **data)
    return jsonify(template), 201


@api.route('/certificate-templates/<template_id>', methods=['PUT'])
@jwt_required()
@handle_exceptions
def update_certificate_template(template_id):
    data = request.get_json()
    template = WaslaService.update_certificate_template(template_id, **data)
    return jsonify(template), 200


@api.route('/certificate-templates/<template_id>', methods=['DELETE'])
@jwt_required()
@handle_exceptions
def delete_certificate_template(template_id):
    WaslaService.delete_certificate_template(template_id)
    return jsonify({'message': 'success'}), 200


# ==================== PAYMENT ROUTES ====================

@api.route('/provider/payments', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_provider_payments():
    user_id = get_jwt_identity()
    payments = WaslaService.get_payments_by_provider(user_id)
    return jsonify(payments), 200


@api.route('/payments', methods=['POST'])
@jwt_required()
@handle_exceptions
def create_payment():
    data = request.get_json()
    user_id = get_jwt_identity()
    payment = WaslaService.create_payment(user_id, data.get('courseId'), **data)
    return jsonify(payment), 201


@api.route('/payments/<payment_id>/proof', methods=['POST'])
@jwt_required()
@handle_exceptions
def upload_payment_proof(payment_id):
    data = request.get_json()
    payment = WaslaService.upload_payment_proof(payment_id, data.get('proofUrl'))
    return jsonify(payment), 200


@api.route('/payments/<payment_id>/approve', methods=['PUT'])
@jwt_required()
@handle_exceptions
def approve_payment(payment_id):
    data = request.get_json()
    payment = WaslaService.approve_payment(
        payment_id,
        data.get('approve', True),
        data.get('notes')
    )
    return jsonify(payment), 200


# ==================== NOTIFICATION ROUTES ====================

@api.route('/notifications', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_notifications():
    user_id = get_jwt_identity()
    notifs = WaslaService.get_my_notifications(user_id)
    return jsonify(notifs), 200


@api.route('/notifications', methods=['POST'])
@jwt_required()
@handle_exceptions
def create_notification():
    data = request.get_json()
    user_id = get_jwt_identity()
    notif = WaslaService.create_notification(user_id, **data)
    return jsonify(notif), 201


@api.route('/notifications/<notif_id>/read', methods=['PUT'])
@jwt_required()
@handle_exceptions
def mark_notification_read(notif_id):
    notif = WaslaService.mark_notification_read(notif_id)
    return jsonify(notif), 200


@api.route('/notifications/read-all', methods=['PUT'])
@jwt_required()
@handle_exceptions
def mark_all_notifications_read():
    user_id = get_jwt_identity()
    WaslaService.mark_all_notifications_read(user_id)
    return jsonify({'message': 'success'}), 200


@api.route('/notifications/unread-count', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_unread_count():
    user_id = get_jwt_identity()
    count = WaslaService.get_unread_count(user_id)
    return jsonify({'count': count}), 200


# ==================== RATING ROUTES ====================

@api.route('/courses/<course_id>/ratings', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_course_ratings(course_id):
    ratings = WaslaService.get_course_ratings(course_id)
    return jsonify(ratings), 200


@api.route('/courses/<course_id>/my-rating', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_my_rating(course_id):
    user_id = get_jwt_identity()
    rating = WaslaService.get_my_rating(user_id, course_id)
    return jsonify(rating or {}), 200


@api.route('/ratings', methods=['POST'])
@jwt_required()
@handle_exceptions
def submit_rating():
    data = request.get_json()
    user_id = get_jwt_identity()
    rating = WaslaService.submit_rating(
        user_id,
        data.get('courseId'),
        data.get('rating'),
        data.get('review')
    )
    return jsonify(rating), 201


# ==================== DASHBOARD ROUTES ====================

@api.route('/provider/dashboard', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_provider_dashboard():
    user_id = get_jwt_identity()
    stats = WaslaService.get_dashboard_stats(user_id)
    return jsonify(stats), 200


@api.route('/student/dashboard', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_student_dashboard():
    user_id = get_jwt_identity()
    stats = WaslaService.get_student_stats(user_id)
    return jsonify(stats), 200


# ==================== STUDENT ROUTES ====================

@api.route('/courses/<course_id>/students', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_course_students(course_id):
    students = WaslaService.get_students_by_course(course_id)
    return jsonify(students), 200


# ==================== SUPPORT ROUTES ====================

@api.route('/support/tickets', methods=['POST'])
@jwt_required()
@handle_exceptions
def create_support_ticket():
    data = request.get_json()
    user_id = get_jwt_identity()
    ticket = WaslaService.create_support_ticket(
        user_id,
        data.get('subject'),
        data.get('description'),
        data.get('category', 'general'),
        data.get('priority', 'medium')
    )
    return jsonify(ticket), 201


@api.route('/support/tickets/<ticket_id>/replies', methods=['POST'])
@jwt_required()
@handle_exceptions
def add_ticket_reply(ticket_id):
    data = request.get_json()
    user_id = get_jwt_identity()
    reply = WaslaService.add_ticket_reply(
        ticket_id,
        user_id,
        data.get('message'),
        data.get('isAdmin', False)
    )
    return jsonify(reply), 201


# ==================== ANNOUNCEMENT ROUTES ====================

@api.route('/announcements', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_announcements():
    announcs = WaslaService.get_active_announcements()
    return jsonify(announcs), 200


# ==================== CATEGORY ROUTES ====================

@api.route('/categories', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_categories():
    categories = WaslaService.get_categories()
    return jsonify(categories), 200


# ==================== FILE UPLOAD ROUTES ====================

@api.route('/upload', methods=['POST'])
@jwt_required()
@handle_exceptions
def upload_file():
    if 'file' not in request.files:
        raise APIError('الملف مطلوب', 'NO_FILE')
    
    file = request.files['file']
    folder = request.form.get('folder', 'general')
    url = WaslaService.upload_file(file, folder)
    return jsonify({'url': url}), 200


# ==================== HEALTH CHECK ====================

@api.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'ok'}), 200