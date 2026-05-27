from flask import Flask
from flask_cors import CORS

from .config import build_database_uri
from .extensions import db, socketio
from .routes import register_routes


def create_app():
    app = Flask(__name__)
    CORS(app)
    app.config["SQLALCHEMY_DATABASE_URI"] = build_database_uri()
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    db.init_app(app)
    socketio.init_app(app)
    register_routes(app)
    return app
