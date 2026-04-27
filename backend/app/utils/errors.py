"""
Error Handlers for Wasla Backend
"""
from flask import jsonify
from werkzeug.exceptions import HTTPException
from functools import wraps
import logging

logger = logging.getLogger(__name__)


class APIError(Exception):
    """Base API Error"""
    def __init__(self, message: str, code: str = 'ERROR', status_code: int = 400):
        super().__init__(message)
        self.message = message
        self.code = code
        self.status_code = status_code


class AuthenticationError(APIError):
    """Authentication Error"""
    def __init__(self, message: str, code: str = 'AUTH_ERROR'):
        super().__init__(message, code, 401)


class AuthorizationError(APIError):
    """Authorization Error"""
    def __init__(self, message: str = 'ليس لديك صلاحية الوصول', code: str = 'UNAUTHORIZED'):
        super().__init__(message, code, 403)


class NotFoundError(APIError):
    """Resource Not Found Error"""
    def __init__(self, message: str = 'المورد غير موجود', code: str = 'NOT_FOUND'):
        super().__init__(message, code, 404)


class ValidationError(APIError):
    """Validation Error"""
    def __init__(self, message: str, code: str = 'VALIDATION_ERROR'):
        super().__init__(message, code, 400)


class DatabaseError(APIError):
    """Database Error"""
    def __init__(self, message: str = 'خطأ في قاعدة البيانات', code: str = 'DATABASE_ERROR'):
        super().__init__(message, code, 500)


def handle_exceptions(f):
    """Decorator to handle exceptions in routes"""
    @wraps(f)
    def wrapped(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except APIError as e:
            return jsonify({
                'error': e.message,
                'code': e.code,
                'message': 'error'
            }), e.status_code
        except HTTPException as e:
            return jsonify({
                'error': e.description,
                'code': e.name,
                'message': 'error'
            }), e.code
        except Exception as e:
            logger.exception('Unexpected error')
            return jsonify({
                'error': 'حدث خطأ غير متوقع',
                'code': 'INTERNAL_ERROR',
                'message': 'error'
            }), 500
    
    return wrapped


def register_error_handlers(app):
    """Register error handlers with Flask app"""
    
    @app.errorhandler(APIError)
    def handle_api_error(error):
        return jsonify({
            'error': error.message,
            'code': error.code,
            'message': 'error'
        }), error.status_code
    
    @app.errorhandler(404)
    def handle_not_found(error):
        return jsonify({
            'error': 'المسار غير موجود',
            'code': 'NOT_FOUND',
            'message': 'error'
        }), 404
    
    @app.errorhandler(500)
    def handle_server_error(error):
        return jsonify({
            'error': 'خطأ في الخادم',
            'code': 'SERVER_ERROR',
            'message': 'error'
        }), 500
    
    @app.errorhandler(400)
    def handle_bad_request(error):
        return jsonify({
            'error': 'طلب غير صالح',
            'code': 'BAD_REQUEST',
            'message': 'error'
        }), 400
    
    return app