"""
Auth Service for Wasla Backend
Business logic for authentication
"""
from datetime import datetime, timezone
from app.models import Profile, RefreshToken
from app.extensions import db
from app.utils.auth import (
    generate_access_token, 
    generate_refresh_token, 
    validate_password,
    decode_token
)
from app.utils.errors import AuthenticationError, ValidationError
import uuid


class AuthService:
    """Authentication service"""
    
    @staticmethod
    def sign_in(email: str, password: str, required_role: str = None) -> dict:
        """Sign in with email and password"""
        # Normalize email
        email = email.strip().lower()
        
        # Find user
        profile = Profile.query.filter_by(email=email).first()
        
        if not profile or not profile.check_password(password):
            raise AuthenticationError('فشل تسجيل الدخول', 'INVALID_CREDENTIALS')
        
        # Check role requirement
        if required_role and profile.role != required_role:
            raise AuthenticationError('ليس لديك صلاحية الوصول到这个 التطبيق', 'UNAUTHORIZED')
        
        # Check status
        if profile.status != 'ACTIVE':
            if profile.status == 'PENDING':
                raise AuthenticationError('حسابك ما زال بانتظار التفعيل', 'ACCOUNT_PENDING')
            raise AuthenticationError('حسابك غير مفعل. يرجى الاتصال بالدعم', 'ACCOUNT_INACTIVE')
        
        # Generate tokens
        access_token = generate_access_token(profile.id, profile.email, profile.role)
        refresh_token, expires = generate_refresh_token(profile.id, profile.email, profile.role)
        
        # Save refresh token
        token = RefreshToken(
            id=str(uuid.uuid4()),
            token=refresh_token,
            expires_at=expires,
            user_id=profile.id
        )
        db.session.add(token)
        db.session.commit()
        
        return {
            'access_token': access_token,
            'refresh_token': refresh_token,
            'user': {
                'id': profile.id,
                'email': profile.email,
            },
            'profile': profile.to_dict()
        }
    
    @staticmethod
    def sign_up(
        name: str, 
        email: str, 
        password: str, 
        role: str,
        phone: str = None,
        gender: str = None,
        institution_type: str = None,
        institution_name: str = None
    ) -> dict:
        """Sign up new user"""
        # Validate password
        is_valid, error = validate_password(password)
        if not is_valid:
            raise ValidationError(error, 'WEAK_PASSWORD')
        
        # Check role is valid
        if role not in ['STUDENT', 'PROVIDER']:
            raise ValidationError('دور غير صالح', 'INVALID_ROLE')
        
        # Normalize email
        email = email.strip().lower()
        
        # Check if email exists
        if Profile.query.filter_by(email=email).first():
            raise ValidationError('البريد الإلكتروني موجود already', 'EMAIL_EXISTS')
        
        # Create profile
        profile = Profile(
            id=str(uuid.uuid4()),
            name=name,
            email=email,
            phone=phone,
            gender=gender,
            role=role,
            institution_type=institution_type,
            institution_name=institution_name,
            status='PENDING'  # Requires approval
        )
        profile.set_password(password)
        
        db.session.add(profile)
        db.session.commit()
        
        return {
            'user': {
                'id': profile.id,
                'email': profile.email,
            },
            'profile': profile.to_dict(),
            'requires_confirmation': True
        }
    
    @staticmethod
    def sign_out(user_id: str, token: str = None) -> None:
        """Sign out user"""
        if token:
            # Delete refresh token
            refresh_token = RefreshToken.query.filter_by(token=token).first()
            if refresh_token:
                db.session.delete(refresh_token)
                db.session.commit()
    
    @staticmethod
    def refresh_access_token(refresh_token: str) -> dict:
        """Get new access token from refresh token"""
        # Find token
        token = RefreshToken.query.filter_by(token=refresh_token).first()
        
        if not token:
            raise AuthenticationError('Invalid refresh token', 'INVALID_TOKEN')
        
        if token.is_expired():
            db.session.delete(token)
            db.session.commit()
            raise AuthenticationError('Refresh token expired', 'TOKEN_EXPIRED')
        
        # Get user
        profile = Profile.query.get(token.user_id)
        
        if not profile or profile.status != 'ACTIVE':
            raise AuthenticationError('User not found or inactive', 'USER_INACTIVE')
        
        # Generate new access token
        access_token = generate_access_token(profile.id, profile.email, profile.role)
        
        return {
            'access_token': access_token,
            'user': {
                'id': profile.id,
                'email': profile.email,
            },
            'profile': profile.to_dict()
        }
    
    @staticmethod
    def get_current_user(user_id: str) -> dict:
        """Get current user by ID"""
        profile = Profile.query.get(user_id)
        
        if not profile:
            raise AuthenticationError('User not found', 'USER_NOT_FOUND')
        
        return {
            'user': {
                'id': profile.id,
                'email': profile.email,
            },
            'profile': profile.to_dict()
        }
    
    @staticmethod
    def reset_password(email: str) -> dict:
        """Request password reset"""
        profile = Profile.query.filter_by(email=email.strip().lower()).first()
        
        if not profile:
            # Don't reveal if email exists
            return {'message': 'success'}
        
        # TODO: Send reset email
        # For now, just return success
        return {'message': 'success'}
    
    @staticmethod
    def update_password(user_id: str, old_password: str, new_password: str) -> dict:
        """Update user password"""
        profile = Profile.query.get(user_id)
        
        if not profile:
            raise AuthenticationError('User not found', 'USER_NOT_FOUND')
        
        if not profile.check_password(old_password):
            raise AuthenticationError('Current password is incorrect', 'INVALID_PASSWORD')
        
        # Validate new password
        is_valid, error = validate_password(new_password)
        if not is_valid:
            raise ValidationError(error, 'WEAK_PASSWORD')
        
        profile.set_password(new_password)
        db.session.commit()
        
        return {'message': 'success'}
    
    @staticmethod
    def confirm_email(user_id: str) -> dict:
        """Confirm user email"""
        profile = Profile.query.get(user_id)
        
        if not profile:
            raise AuthenticationError('User not found', 'USER_NOT_FOUND')
        
        profile.email_verified_at = datetime.now(timezone.utc)
        db.session.commit()
        
        return {'message': 'success'}
    
    @staticmethod
    def update_profile(user_id: str, **kwargs) -> dict:
        """Update user profile"""
        profile = Profile.query.get(user_id)
        
        if not profile:
            raise AuthenticationError('User not found', 'USER_NOT_FOUND')
        
        # Allowed fields
        allowed_fields = [
            'name', 'phone', 'gender', 'bio', 'institution_name',
            'institution_type', 'address', 'city', 'country'
        ]
        
        for key, value in kwargs.items():
            if key in allowed_fields and value is not None:
                setattr(profile, key, value)
        
        db.session.commit()
        
        return profile.to_dict()