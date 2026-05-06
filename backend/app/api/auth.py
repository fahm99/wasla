"""
Auth API Routes for Wasla Backend
REST endpoints matching Supabase auth patterns
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import (
    create_access_token, 
    create_refresh_token,
    jwt_required, 
    get_jwt_identity,
    get_jwt
)
from app.services.auth_service import AuthService
from app.utils.errors import handle_exceptions, APIError, AuthenticationError
from app.models import Profile
from app.extensions import db

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')


@auth_bp.route('/signin', methods=['POST'])
@handle_exceptions
def signin():
    """
    Sign in user
    POST /api/auth/signin
    """
    data = request.get_json()
    
    email = data.get('email')
    password = data.get('password')
    required_role = data.get('requiredRole')
    
    if not email or not password:
        raise APIError('البريد الإلكتروني وكلمة المرور مطلوبان', 'MISSING_CREDENTIALS')
    
    result = AuthService.sign_in(email, password, required_role)
    
    return jsonify(result), 200


@auth_bp.route('/signup', methods=['POST'])
@handle_exceptions
def signup():
    """
    Sign up new user
    POST /api/auth/signup
    """
    data = request.get_json()
    
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    role = data.get('role', 'STUDENT')
    
    if not name or not email or not password:
        raise APIError('الاسم والبريد الإلكتروني وكلمة المرور مطلوبة', 'MISSING_FIELDS')
    
    result = AuthService.sign_up(
        name=name,
        email=email,
        password=password,
        role=role,
        phone=data.get('phone'),
        gender=data.get('gender'),
        institution_type=data.get('institutionType'),
        institution_name=data.get('institutionName')
    )
    
    return jsonify(result), 201


@auth_bp.route('/signout', methods=['POST'])
@jwt_required(refresh=True)
@handle_exceptions
def signout():
    """
    Sign out user
    POST /api/auth/signout
    """
    user_id = get_jwt_identity()
    
    # Get refresh token from header
    auth_header = request.headers.get('Authorization', '')
    refresh_token = auth_header.replace('Bearer ', '') if auth_header else None
    
    AuthService.sign_out(user_id, refresh_token)
    
    return jsonify({'message': 'success'}), 200


@auth_bp.route('/me', methods=['GET'])
@jwt_required()
@handle_exceptions
def get_current_user():
    """
    Get current user
    GET /api/auth/me
    """
    user_id = get_jwt_identity()
    result = AuthService.get_current_user(user_id)
    
    return jsonify(result), 200


@auth_bp.route('/refresh', methods=['POST'])
@jwt_required(refresh=True)
@handle_exceptions
def refresh_token():
    """
    Refresh access token
    POST /api/auth/refresh
    """
    user_id = get_jwt_identity()
    
    # Get user profile
    profile = Profile.query.get(user_id)
    
    if not profile:
        raise AuthenticationError('User not found', 'USER_NOT_FOUND')
    
    # Create new access token
    access_token = create_access_token(
        identity={'id': profile.id, 'email': profile.email, 'role': profile.role}
    )
    
    return jsonify({
        'access_token': access_token,
        'user': {'id': profile.id, 'email': profile.email},
        'profile': profile.to_dict()
    }), 200


@auth_bp.route('/reset-password', methods=['POST'])
@handle_exceptions
def reset_password():
    """
    Request password reset
    POST /api/auth/reset-password
    """
    data = request.get_json()
    email = data.get('email')
    
    if not email:
        raise APIError('البريد الإلكتروني مطلوب', 'MISSING_EMAIL')
    
    # Check if email exists (don't reveal)
    profile = Profile.query.filter_by(email=email.strip().lower()).first()
    if profile:
        # TODO: Send reset email
        pass
    
    # Always return success to prevent email enumeration
    return jsonify({'message': 'success'}), 200


@auth_bp.route('/update-password', methods=['PUT'])
@jwt_required()
@handle_exceptions
def update_password():
    """
    Update password
    PUT /api/auth/update-password
    """
    data = request.get_json()
    user_id = get_jwt_identity()
    
    old_password = data.get('oldPassword')
    new_password = data.get('newPassword')
    
    if not old_password or not new_password:
        raise APIError('كلمات المرور مطلوبة', 'MISSING_PASSWORDS')
    
    result = AuthService.update_password(user_id, old_password, new_password)
    
    return jsonify(result), 200


@auth_bp.route('/profile', methods=['PUT'])
@jwt_required()
@handle_exceptions
def update_profile():
    """
    Update profile
    PUT /api/auth/profile
    """
    data = request.get_json()
    user_id = get_jwt_identity()
    
    result = AuthService.update_profile(
        user_id,
        name=data.get('name'),
        phone=data.get('phone'),
        gender=data.get('gender'),
        bio=data.get('bio'),
        institution_name=data.get('institutionName'),
        institution_type=data.get('institutionType'),
        address=data.get('address'),
        city=data.get('city'),
        country=data.get('country')
    )
    
    return jsonify(result), 200


# Health check endpoint
@auth_bp.route('/health', methods=['GET'])
def health_check():
    """Health check"""
    return jsonify({'status': 'ok', 'message': 'auth service running'}), 200