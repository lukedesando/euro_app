from .extensions import db


class Results(db.Model):
    __tablename__ = "final_results"

    song_id = db.Column(db.Integer, db.ForeignKey("songs.song_id"), primary_key=True)
    country = db.Column(db.String(100), nullable=False)
    totalPoints = db.Column(db.Integer, nullable=False)
    juryPoints = db.Column(db.Integer, nullable=False)
    televotingPoints = db.Column(db.Integer, nullable=False)
    place = db.Column(db.Integer, nullable=False)


class Song(db.Model):
    __tablename__ = "songs"

    song_id = db.Column(db.Integer, primary_key=True)
    country = db.Column(db.String(100))
    song_name = db.Column(db.String(255))
    artist = db.Column(db.String(255))
    language = db.Column(db.String(255))
    average_score = db.Column(db.Float)
    x_count = db.Column(db.Integer, default=0)
    final_rank = db.Column(db.Integer, default=0)


class Country(db.Model):
    __tablename__ = "countries"

    country_code = db.Column(db.String(2), primary_key=True)
    country_name = db.Column(db.String(50))


class Vote(db.Model):
    __tablename__ = "votes"

    user_name = db.Column(db.String(50), primary_key=True)
    score = db.Column(db.Integer)
    song_id = db.Column(db.Integer, db.ForeignKey("songs.song_id"), primary_key=True)
    x_skip = db.Column(db.Boolean, default=False)


class Favorite(db.Model):
    __tablename__ = "favorites"

    user_name = db.Column(db.String(255), primary_key=True)
    song_id = db.Column(db.Integer, db.ForeignKey("songs.song_id"), primary_key=True)
