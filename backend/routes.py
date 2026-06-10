import logging

from flask import jsonify, request
from sqlalchemy import func, text
from sqlalchemy.exc import IntegrityError, SQLAlchemyError

from .extensions import db, socketio
from .http import json_no_cache, require_json_fields
from .models import Country, Favorite, Results, Song, Vote
from .serializers import final_result_payload, song_payload


def register_routes(app):
    @app.errorhandler(SQLAlchemyError)
    def handle_database_error(exc):
        db.session.rollback()
        logging.error("Database request failed: %s", exc)
        return jsonify({"error": "Database unavailable"}), 503

    @app.route("/health", methods=["GET"])
    def health():
        try:
            db.session.execute(text("SELECT 1"))
        except SQLAlchemyError as exc:
            logging.error("Database health check failed: %s", exc)
            return jsonify({"status": "error", "database": "unreachable", "error": str(exc)}), 503

        return jsonify({"status": "ok", "database": "reachable"})

    @app.route("/songs", methods=["GET"])
    def get_songs():
        songs = (
            db.session.query(Song, Country.country_code)
            .outerjoin(Country, Song.country == Country.country_name)
            .order_by(Song.country)
            .all()
        )
        return json_no_cache([song_payload(song, country_code) for song, country_code in songs])

    @app.route("/final_results", methods=["GET"])
    def get_final_results():
        user_name = request.args.get("user_name")
        votes_by_song = {}
        if user_name:
            votes_by_song = {
                vote.song_id: vote.score
                for vote in Vote.query.filter_by(user_name=user_name).all()
            }

        results = (
            db.session.query(Results, Song)
            .outerjoin(Song, Results.song_id == Song.song_id)
            .order_by(Results.place)
            .all()
        )

        return json_no_cache(
            [
                final_result_payload(
                    result,
                    song,
                    votes_by_song.get(result.song_id, "Not Voted"),
                )
                for result, song in results
            ]
        )

    @app.route("/votepost", methods=["POST"])
    def vote():
        data = request.get_json(silent=True) or {}
        error = require_json_fields(data, ["user_name", "song_id", "score"])
        if error:
            return jsonify({"error": error}), 400

        song = db.session.get(Song, data["song_id"])
        if not song:
            return jsonify({"error": "Song not found"}), 404

        x_skip = data.get("x_skip", False)
        existing_vote = Vote.query.filter_by(
            user_name=data["user_name"],
            song_id=data["song_id"],
        ).first()

        if existing_vote:
            existing_vote.score = data["score"]
            existing_vote.x_skip = x_skip
        else:
            db.session.add(
                Vote(
                    user_name=data["user_name"],
                    score=data["score"],
                    song_id=data["song_id"],
                    x_skip=x_skip,
                )
            )

        db.session.commit()

        socketio.emit(
            "x_count_update",
            {"song_id": data["song_id"], "x_count": song.x_count},
        )

        return jsonify({"message": "Vote recorded"})

    @app.route("/voteget", methods=["GET"])
    def get_votes():
        user_name = request.args.get("user_name")
        if not user_name:
            return json_no_cache([])

        votes = Vote.query.filter_by(user_name=user_name).all()
        return json_no_cache(
            [{"song_id": vote.song_id, "user_score": vote.score} for vote in votes]
        )

    @app.route("/add_favorite", methods=["POST"])
    def add_favorite():
        data = request.get_json(silent=True) or {}
        error = require_json_fields(data, ["user_name", "song_id"])
        if error:
            return jsonify({"error": error}), 400
        user_name = data["user_name"].strip()
        if not user_name:
            return jsonify({"error": "user_name is required"}), 400

        try:
            db.session.add(Favorite(user_name=user_name, song_id=data["song_id"]))
            db.session.commit()
        except IntegrityError:
            db.session.rollback()

        return jsonify({"message": "Favorite added successfully"}), 200

    @app.route("/remove_favorite", methods=["POST"])
    def remove_favorite():
        data = request.get_json(silent=True) or {}
        error = require_json_fields(data, ["user_name", "song_id"])
        if error:
            return jsonify({"error": error}), 400
        user_name = data["user_name"].strip()
        if not user_name:
            return jsonify({"error": "user_name is required"}), 400

        favorite = Favorite.query.filter(
            func.trim(Favorite.user_name) == user_name,
            Favorite.song_id == data["song_id"],
        ).first()
        if not favorite:
            return jsonify({"message": "Favorite not found"}), 404

        db.session.delete(favorite)
        db.session.commit()
        return jsonify({"message": "Favorite removed successfully"}), 200

    @app.route("/get_favorites/<user_name>", methods=["GET"])
    def get_favorites(user_name):
        user_name = user_name.strip()
        if not user_name:
            return json_no_cache([])

        favorite_song_ids = [
            song_id
            for (song_id,) in db.session.query(Favorite.song_id)
            .filter(func.trim(Favorite.user_name) == user_name)
            .all()
        ]

        if not favorite_song_ids:
            return json_no_cache([])

        favorite_songs = (
            db.session.query(Song, Country.country_code)
            .outerjoin(Country, Song.country == Country.country_name)
            .filter(Song.song_id.in_(favorite_song_ids))
            .order_by(Song.country)
            .all()
        )

        return json_no_cache(
            [
                {
                    "song_id": song.song_id,
                    "country": song.country,
                    "song_name": song.song_name,
                    "artist": song.artist,
                    "country_code": country_code or "Unknown",
                }
                for song, country_code in favorite_songs
            ]
        )

    @app.route("/update_xcount", methods=["POST"])
    def update_xcount():
        data = request.get_json(silent=True) or {}
        error = require_json_fields(data, ["song_id", "new_x_count"])
        if error:
            return jsonify({"error": error}), 400

        song = db.session.get(Song, data["song_id"])
        if not song:
            return jsonify({"error": "Song not found"}), 404

        new_x_count = data["new_x_count"]
        if song.x_count == new_x_count:
            return jsonify(success=False, message="No update needed"), 200

        song.x_count = new_x_count
        db.session.commit()

        socketio.emit(
            "x_count_update",
            {"song_id": data["song_id"], "x_count": new_x_count},
        )
        return jsonify(success=True), 200

    @app.route("/get_xcount/<int:song_id>", methods=["GET"])
    def get_xcount(song_id):
        song = db.session.get(Song, song_id)
        if not song:
            return jsonify({"error": "Song not found"}), 404

        return jsonify({"x_count": song.x_count})
