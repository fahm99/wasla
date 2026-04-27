"""
Courses API Routes for Wasla Backend
REST endpoints matching Supabase patterns
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.services.course_service import CourseService
from app.utils.errors import handle_exceptions, APIError

courses_bp = Blueprint('courses', __name__, url_prefix='/api')


@courses_bp.route('/courses', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_courses():
    """
    Get courses
    GET /api/courses?provider_id=xxx&status=PUBLISHED
    """
    provider_id = request.args.get('providerId')
    status = request.args.get('status')
    
    courses = CourseService.get_courses(provider_id, status)
    
    return jsonify(courses), 200


@courses_bp.route('/courses/<course_id>', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_course(course_id):
    """Get course by ID"""
    course = CourseService.get_course_by_id(course_id)
    return jsonify(course), 200


@courses_bp.route('/courses', methods=['POST'])
@jwt_required()
@handle_exceptions
def create_course():
    """Create new course"""
    data = request.get_json()
    user_id = get_jwt_identity()
    
    title = data.get('title')
    description = data.get('description')
    price = data.get('price', 0)
    level = data.get('level', 'BEGINNER')
    category = data.get('category')
    
    if not title:
        raise APIError('العنوان مطلوب', 'MISSING_TITLE')
    
    course = CourseService.create_course(
        provider_id=user_id,
        title=title,
        description=description,
        price=price,
        level=level,
        category=category,
        image_url=data.get('image'),
        short_description=data.get('shortDescription'),
        currency=data.get('currency', 'YER'),
        language=data.get('language', 'ar'),
        tags=data.get('tags'),
        requirements=data.get('requirements'),
        objectives=data.get('objectives'),
        duration_minutes=data.get('durationMinutes'),
        max_students=data.get('maxStudents'),
        certificate_enabled=data.get('certificateEnabled', True)
    )
    
    return jsonify(course), 201


@courses_bp.route('/courses/<course_id>', methods=['PUT'])
@jwt_required()
@handle_exceptions
def update_course(course_id):
    """Update course"""
    data = request.get_json()
    
    course = CourseService.update_course(
        course_id,
        title=data.get('title'),
        description=data.get('description'),
        short_description=data.get('shortDescription'),
        price=data.get('price'),
        currency=data.get('currency'),
        level=data.get('level'),
        language=data.get('language'),
        image=data.get('image'),
        thumbnail=data.get('thumbnail'),
        category=data.get('category'),
        tags=data.get('tags'),
        requirements=data.get('requirements'),
        objectives=data.get('objectives'),
        duration_minutes=data.get('durationMinutes'),
        max_students=data.get('maxStudents'),
        certificate_enabled=data.get('certificateEnabled')
    )
    
    return jsonify(course), 200


@courses_bp.route('/courses/<course_id>', methods=['DELETE'])
@jwt_required()
@handle_exceptions
def delete_course(course_id):
    """Delete course"""
    CourseService.delete_course(course_id)
    return jsonify({'message': 'success'}), 200


@courses_bp.route('/courses/<course_id>/publish', methods=['PUT'])
@jwt_required()
@handle_exceptions
def publish_course(course_id):
    """Publish/unpublish course"""
    data = request.get_json()
    publish = data.get('publish', True)
    
    course = CourseService.publish_course(course_id, publish)
    
    return jsonify(course), 200


# Module endpoints
@courses_bp.route('/courses/<course_id>/modules', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_modules(course_id):
    """Get modules by course"""
    modules = CourseService.get_modules_by_course(course_id)
    return jsonify(modules), 200


@courses_bp.route('/modules', methods=['POST'])
@jwt_required()
@handle_exceptions
def create_module():
    """Create new module"""
    data = request.get_json()
    
    course_id = data.get('courseId')
    title = data.get('title')
    order = data.get('order', 0)
    description = data.get('description')
    
    if not course_id or not title:
        raise APIError('معرف الدورة والعنوان مطلوبان')
    
    module = CourseService.create_module(
        course_id=course_id,
        title=title,
        order=order,
        description=description
    )
    
    return jsonify(module), 201


@courses_bp.route('/modules/<module_id>', methods=['PUT'])
@jwt_required()
@handle_exceptions
def update_module(module_id):
    """Update module"""
    data = request.get_json()
    
    module = CourseService.update_module(
        module_id,
        title=data.get('title'),
        description=data.get('description'),
        order=data.get('order')
    )
    
    return jsonify(module), 200


@courses_bp.route('/modules/<module_id>', methods=['DELETE'])
@jwt_required()
@handle_exceptions
def delete_module(module_id):
    """Delete module"""
    CourseService.delete_module(module_id)
    return jsonify({'message': 'success'}), 200


# Lesson endpoints
@courses_bp.route('/modules/<module_id>/lessons', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_lessons(module_id):
    """Get lessons by module"""
    lessons = CourseService.get_lessons_by_module(module_id)
    return jsonify(lessons), 200


@courses_bp.route('/lessons', methods=['POST'])
@jwt_required()
@handle_exceptions
def create_lesson():
    """Create new lesson"""
    data = request.get_json()
    
    module_id = data.get('moduleId')
    title = data.get('title')
    type = data.get('type', 'TEXT')
    content = data.get('content', '')
    
    if not module_id or not title:
        raise APIError('معرف الوحدة والعنوان مطلوبان')
    
    lesson = CourseService.create_lesson(
        module_id=module_id,
        title=title,
        type=type,
        content=content,
        description=data.get('description'),
        file_url=data.get('fileUrl'),
        file_name=data.get('fileName'),
        file_size=data.get('fileSize'),
        duration=data.get('duration'),
        is_free=data.get('isFree', False),
        order=data.get('order', 0)
    )
    
    return jsonify(lesson), 201


@courses_bp.route('/lessons/<lesson_id>', methods=['PUT'])
@jwt_required()
@handle_exceptions
def update_lesson(lesson_id):
    """Update lesson"""
    data = request.get_json()
    
    lesson = CourseService.update_lesson(
        lesson_id,
        title=data.get('title'),
        description=data.get('description'),
        type=data.get('type'),
        content=data.get('content'),
        file_url=data.get('fileUrl'),
        file_name=data.get('fileName'),
        file_size=data.get('fileSize'),
        duration=data.get('duration'),
        is_free=data.get('isFree'),
        order=data.get('order')
    )
    
    return jsonify(lesson), 200


@courses_bp.route('/lessons/<lesson_id>', methods=['DELETE'])
@jwt_required()
@handle_exceptions
def delete_lesson(lesson_id):
    """Delete lesson"""
    CourseService.delete_lesson(lesson_id)
    return jsonify({'message': 'success'}), 200