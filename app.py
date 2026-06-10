from backend import create_app, socketio
from backend.config import env_value


app = create_app()


if __name__ == "__main__":
    app_host = env_value("APP_HOST", "0.0.0.0")
    app_port = int(env_value("APP_PORT", env_value("DB_PORT", "5000")))
    socketio.run(
        app=app,
        host=app_host,
        port=app_port,
        debug=False,
        use_reloader=False,
        allow_unsafe_werkzeug=True,
    )
