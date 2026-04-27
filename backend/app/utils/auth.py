"""
JWT Authentication Utilities for Wasla Backend
"""
import jwt
from datetime import datetime, timedelta, timezone
from typing import Dict, Any, Optional
from flask import current_app
from functools import wraps
from flask import request, jsonify


def generate_access_token(user_id: str, email: str, role: str) -> str:
    """Generate JWT access token"""
    payload = {
        'sub': user_id,
        'email': email,
        'role': role,
        'exp': datetime.now(timezone.utc) + timedelta(minutes=15),
        'iat': datetime.now(timezone.utc),
        'type': 'access'
    }
    return jwt.encode(payload, current_app.config['SECRET_KEY'], algorithm='HS256')


def generate_refresh_token(user_id: str, email: str, role: str) -> tuple[str, datetime]:
    """Generate JWT refresh token"""
    expires = datetime.now(timezone.utc) + timedelta(days=7)
    payload = {
        'sub': user_id,
        'email': email,
        'role': role,
        'exp': expires,
        'iat': datetime.now(timezone.utc),
        'type': 'refresh'
    }
    return jwt.encode(payload, current_app.config['SECRET_KEY'], algorithm='HS256'), expires


def decode_token(token: str) -> Dict[str, Any]:
    """Decode and validate JWT token"""
    try:
        payload = jwt.decode(
            token,
            current_app.config['SECRET_KEY'],
            algorithms=['HS256']
        )
        return payload
    except jwt.ExpiredSignatureError:
        raise ValueError('Token has expired')
    except jwt.InvalidTokenError as e:
        raise ValueError(f'Invalid token: {str(e)}')


def validate_password(password: str) -> tuple[bool, str]:
    """
    Validate password strength
    Returns (is_valid, error_message)
    """
    if len(password) < 8:
        return False, 'Password must be at least 8 characters'
    
    has_upper = any(c.isupper() for c in password)
    has_lower = any(c.islower() for c in password)
    has_digit = any(c.isdigit() for c in password)
    has_special = any(c in '!@#$%^&*()_+-=[]{}|;:,.<>?' for c in password)
    
    if not (has_upper and has_lower and has_digit):
        return False, 'Password must contain uppercase, lowercase, and number'
    
    return True, ''


def require_role(*allowed_roles):
    """Decorator to check user role"""
    def decorator(f):
        @wraps(f)
        def wrapped(current_user, *args, **kwargs):
            if current_user.get('role') not in allowed_roles:
                return jsonify({
                    'error': 'ليس لديك صلاحية الوصول',
                    'code': 'UNAUTHORIZED'
                }), 403
            return f(current_user, *args, **kwargs)
        return wrapped
    return decorator


def require_active_status(f):
    """Decorator to check user is active"""
    @wraps(f)
    def wrapped(current_user, *args, **kwargs):
        if current_user.get('status') != 'ACTIVE':
            return jsonify({
                'error': 'حسابك غير مفعل',
                'code': 'ACCOUNT_INACTIVE'
            }), 403
        return f(current_user, *args, **kwargs)
    return wrapped