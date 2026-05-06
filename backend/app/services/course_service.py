"""
Course Service for Wasla Backend
Business logic for courses
"""
from app.models import Course, Module, Lesson
from app.extensions import db
from app.utils.errors import NotFoundError, ValidationError
import uuid


class CourseService:
    """Course service"""
    
    @staticmethod
    def get_courses(provider_id: str = None, status: str = None) -> list:
        """Get courses for a provider"""
        query = Course.query
        
        if provider_id:
            query = query.filter_by(provider_id=provider_id)
        
        if status:
            query = query.filter_by(status=status)
        
        courses = query.order_by(Course.created_at.desc()).all()
        
        return [course.to_dict(include_counts=True) for course in courses]
    
    @staticmethod
    def get_course_by_id(course_id: str) -> dict:
        """Get course by ID"""
        course = Course.query.get(course_id)
        
        if not course:
            raise NotFoundError('الدورة غير موجودة')
        
        return course.to_dict(include_counts=True)
    
    @staticmethod
    def create_course(
        provider_id: str,
        title: str,
        description: str,
        price: float,
        level: str,
        category: str,
        image_url: str = None,
        **kwargs
    ) -> dict:
        """Create new course"""
        course = Course(
            id=str(uuid.uuid4()),
            title=title,
            description=description,
            price=price,
            level=level,
            category=category,
            image=image_url,
            provider_id=provider_id,
            **kwargs
        )
        
        db.session.add(course)
        db.session.commit()
        
        return course.to_dict(include_counts=True)
    
    @staticmethod
    def update_course(course_id: str, **kwargs) -> dict:
        """Update course"""
        course = Course.query.get(course_id)
        
        if not course:
            raise NotFoundError('الدورة غير موجودة')
        
        # Allowed fields
        allowed_fields = [
            'title', 'description', 'short_description', 'price', 'currency',
            'level', 'language', 'image', 'thumbnail', 'status', 'category',
            'tags', 'requirements', 'objectives', 'duration_minutes',
            'max_students', 'certificate_enabled'
        ]
        
        for key, value in kwargs.items():
            if key in allowed_fields and value is not None:
                setattr(course, key, value)
        
        db.session.commit()
        
        return course.to_dict(include_counts=True)
    
    @staticmethod
    def delete_course(course_id: str) -> None:
        """Delete course"""
        course = Course.query.get(course_id)
        
        if not course:
            raise NotFoundError('الدورة غير موجودة')
        
        db.session.delete(course)
        db.session.commit()
    
    @staticmethod
    def publish_course(course_id: str, publish: bool = True) -> dict:
        """Publish or unpublish course"""
        course = Course.query.get(course_id)
        
        if not course:
            raise NotFoundError('الدورة غير موجودة')
        
        course.status = 'PUBLISHED' if publish else 'DRAFT'
        db.session.commit()
        
        return course.to_dict(include_counts=True)
    
    @staticmethod
    def get_modules_by_course(course_id: str) -> list:
        """Get modules for a course"""
        course = Course.query.get(course_id)
        
        if not course:
            raise NotFoundError('الدورة غير موجودة')
        
        modules = Module.query.filter_by(course_id=course_id)\
            .order_by(Module.order).all()
        
        return [module.to_dict(include_counts=True) for module in modules]
    
    @staticmethod
    def create_module(
        course_id: str,
        title: str,
        order: int = 0,
        description: str = None
    ) -> dict:
        """Create new module"""
        course = Course.query.get(course_id)
        
        if not course:
            raise NotFoundError('الدورة غير موجودة')
        
        module = Module(
            id=str(uuid.uuid4()),
            title=title,
            description=description,
            order=order,
            course_id=course_id
        )
        
        db.session.add(module)
        db.session.commit()
        
        return module.to_dict(include_counts=True)
    
    @staticmethod
    def update_module(module_id: str, **kwargs) -> dict:
        """Update module"""
        module = Module.query.get(module_id)
        
        if not module:
            raise NotFoundError('الوحدة غير موجودة')
        
        allowed_fields = ['title', 'description', 'order']
        
        for key, value in kwargs.items():
            if key in allowed_fields and value is not None:
                setattr(module, key, value)
        
        db.session.commit()
        
        return module.to_dict(include_counts=True)
    
    @staticmethod
    def delete_module(module_id: str) -> None:
        """Delete module"""
        module = Module.query.get(module_id)
        
        if not module:
            raise NotFoundError('الوحدة غير موجودة')
        
        db.session.delete(module)
        db.session.commit()
    
    @staticmethod
    def get_lessons_by_module(module_id: str) -> list:
        """Get lessons for a module"""
        module = Module.query.get(module_id)
        
        if not module:
            raise NotFoundError('الوحدة غير موجودة')
        
        lessons = Lesson.query.filter_by(module_id=module_id)\
            .order_by(Lesson.order).all()
        
        return [lesson.to_dict() for lesson in lessons]
    
    @staticmethod
    def create_lesson(
        module_id: str,
        title: str,
        type: str = 'TEXT',
        content: str = '',
        **kwargs
    ) -> dict:
        """Create new lesson"""
        module = Module.query.get(module_id)
        
        if not module:
            raise NotFoundError('الوحدة غير موجودة')
        
        lesson = Lesson(
            id=str(uuid.uuid4()),
            title=title,
            type=type,
            content=content,
            module_id=module_id,
            **kwargs
        )
        
        db.session.add(lesson)
        db.session.commit()
        
        return lesson.to_dict()
    
    @staticmethod
    def update_lesson(lesson_id: str, **kwargs) -> dict:
        """Update lesson"""
        lesson = Lesson.query.get(lesson_id)
        
        if not lesson:
            raise NotFoundError('الدرس غير موجود')
        
        allowed_fields = [
            'title', 'description', 'type', 'content', 'file_url',
            'file_name', 'file_size', 'duration', 'is_free', 'order'
        ]
        
        for key, value in kwargs.items():
            if key in allowed_fields and value is not None:
                setattr(lesson, key, value)
        
        db.session.commit()
        
        return lesson.to_dict()
    
    @staticmethod
    def delete_lesson(lesson_id: str) -> None:
        """Delete lesson"""
        lesson = Lesson.query.get(lesson_id)
        
        if not lesson:
            raise NotFoundError('الدرس غير موجود')
        
        db.session.delete(lesson)
        db.session.commit()