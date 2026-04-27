"""
Wasla Backend - Flask Application Factory
"""
import os
from flask import Flask
from flask_jwt_extended import JWTManager
from app.config import config


def create_app(config_name=None):
    """Create and configure Flask application"""
    
    if config_name is None:
        config_name = os.environ.get('FLASK_CONFIG', 'development')
    
    app = Flask(__name__)
    app.config.from_object(config[config_name])
    
    # Initialize JWT
    jwt = JWTManager(app)
    
    # Setup JWT token callbacks
    @jwt.token_in_blocklist_loader
    def check_if_token_revoked(jwt_header, jwt_payload):
        """Check if JWT token has been revoked"""
        from app.models import RefreshToken
        jti = jwt_payload['jti']
        token = RefreshToken.query.filter_by(token=jti).first()
        return token is None
    
    @jwt.expired_token_loader
    def expired_token_callback(jwt_header, jwt_payload):
        """Handle expired token"""
        return {
            'error': 'Token has expired',
            'code': 'TOKEN_EXPIRED'
        }, 401
    
    @jwt.invalid_token_loader
    def invalid_token_callback(error):
        """Handle invalid token"""
        return {
            'error': 'Invalid token',
            'code': 'INVALID_TOKEN'
        }, 401
    
    @jwt.unauthorized_loader
    def missing_token_callback(error):
        """Handle missing token"""
        return {
            'error': 'Authorization required',
            'code': 'AUTHORIZATION_REQUIRED'
        }, 401
    
    # Register blueprints
    from app.api.auth import auth_bp
    from app.api.courses import courses_bp
    
    app.register_blueprint(auth_bp)
    app.register_blueprint(courses_bp)
    
    # Register error handlers
    from app.utils.errors import register_error_handlers
    register_error_handlers(app)
    
    # Health check
    @app.route('/health')
    def health():
        return {'status': 'ok', 'service': 'wasla-api'}, 200
    
    @app.route('/')
    def index():
        return {
            'service': 'Wasla API',
            'version': '1.0.0',
            'status': 'running'
        }, 200
    
    return app


# Entry point for running
app = create_app()


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)