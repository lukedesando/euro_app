import os

from dotenv import load_dotenv


load_dotenv()


def env_value(name, default=None, required=False):
    value = os.getenv(name, default)
    if required and not value:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value


def build_database_uri():
    database_url = env_value("DATABASE_URL")
    if database_url:
        return database_url

    engine = env_value("DB_ENGINE", "mysql")
    user = env_value("DB_USER", required=True)
    password = env_value("DB_PASSWORD", required=True)
    host = env_value("DB_HOST", required=True)
    name = env_value("DB_NAME", required=True)
    db_port = env_value("DATABASE_PORT")
    port_segment = f":{db_port}" if db_port else ""
    return f"{engine}://{user}:{password}@{host}{port_segment}/{name}"
