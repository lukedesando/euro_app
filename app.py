from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy

from dotenv import load_dotenv
import os

#Comments for Hosting Test

app = Flask(__name__)
CORS(app)

load_dotenv()
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")

app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}'
db = SQLAlchemy(app)

class Song(db.Model):
    __tablename__ = 'songs'
    song_id = db.Column(db.Integer, primary_key=True)
    country = db.Column(db.String(50))
    song_name = db.Column(db.String(50))
    artist = db.Column(db.String(50))
    language = db.Column(db.String(50))

    def to_dict(self):
        return {
            'song_id': self.song_id,
            'country': self.country,
            'song_name': self.song_name,
            'artist': self.artist,
            'language': self.language
        }

class Country(db.Model):
    __tablename__ = 'countries'
    country_code = db.Column(db.String(2), primary_key=True)
    country_name = db.Column(db.String(50))

    def to_dict(self):
        return {
            'country_name': self.country_name,
            'country_code': self.country_code
        }

class Vote(db.Model):
    __tablename__ = 'votes'
    user_name = db.Column(db.String(50), primary_key=True)
    score = db.Column(db.Integer)
    song_id = db.Column(db.Integer, db.ForeignKey('songs.song_id'), primary_key=True)

@app.route('/songs', methods=['GET'])
def get_songs():
    songs = db.session.query(Song, Country.country_code).outerjoin(Country, Song.country == Country.country_name).all()
    return jsonify([
        {
            'song_id': song[0].song_id,
            'country': song[0].country,
            'song_name': song[0].song_name,
            'artist': song[0].artist,
            'language': song[0].language,
            'country_code': song[1] if song[1] is not None else 'Unknown'
        } for song in songs
    ])

@app.route('/vote', methods=['POST'])
def vote():
    data = request.json
    existing_vote = Vote.query.filter_by(user_name=data['user_name'], song_id=data['song_id']).first()
    if existing_vote:
        existing_vote.score = data['score']
    else:
        new_vote = Vote(user_name=data['user_name'], score=data['score'], song_id=data['song_id'])
        db.session.add(new_vote)
    db.session.commit()
    return jsonify({"message": "Vote recorded"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
