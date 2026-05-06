"""
Flask Extensions for Wasla Backend
"""
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_mail import Mail
from flask_limiter import Limiter
from flask_limiter.storage import RedisStorage
import os

# Initialize extensions
db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()
cors = CORS()
mail = Mail()
limiter = Limiter(
    key_func=get_remote_address,
    storage=RedisStorage.from_url(os.environ.get('REDIS_URL', 'redis://localhost:6379')),
    default_limits=["100 per hour"]
)

def get_remote_address():
    """Get client IP for rate limiting"""
    from flask import request
    return request.environ.get('HTTP_X_REAL_IP', request.remote_addr)


def init_extensions(app):
    """Initialize all Flask extensions with app"""
    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    mail.init_app(app)
    cors.init_app(app, resources={r"/api/*": {"origins": app.config['CORS_ORIGINS']}})
    
    # Setup JWT claims
    @jwt.user_identity_loader
    def user_identity_lookup(user):
        return user['id']
    
    @jwt.user_lookup_loader
    def user_lookup_callback(_jwt_header, jwt_data):
        return {'id': jwt_data['sub']}
    
    return {
        'db': db,
        'migrate': migrate,
        'jwt': jwt,
        'cors': cors,
        'mail': mail,
        'limiter': limiter
    }