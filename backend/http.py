from flask import jsonify


def no_cache(response):
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
    return response


def json_no_cache(payload, status=200):
    return no_cache(jsonify(payload)), status


def require_json_fields(data, fields):
    missing = [field for field in fields if data.get(field) in (None, "")]
    if missing:
        return f"Missing required field(s): {', '.join(missing)}"
    return None
