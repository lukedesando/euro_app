from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy

from dotenv import load_dotenv
import os
import logging

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
    average_score = db.Column(db.Float)

    def to_dict(self):
        return {
            'song_id': self.song_id,
            'country': self.country,
            'song_name': self.song_name,
            'artist': self.artist,
            'language': self.language,
            'average_score': self.average_score
        }
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
            'average_score': song[0].average_score,
            'country_code': song[1] if song[1] is not None else 'Unknown'
        } for song in songs
    ])

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


@app.route('/votepost', methods=['POST'])
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

@app.route('/voteget', methods=['GET'])
def get_votes():
    user_name = request.args.get('user_name')
    if user_name:
        votes = Vote.query.filter_by(user_name=user_name).all()
        return jsonify([
            {
                'song_id': vote.song_id,
                'user_score': vote.score
            } for vote in votes
        ])
    return jsonify([])

class Favorite(db.Model):
    __tablename__ = 'favorites'
    user_name = db.Column(db.String(255), primary_key=True)
    song_id = db.Column(db.Integer, db.ForeignKey('songs.song_id'), primary_key=True)

    def __repr__(self):
        return f'<Favorite {self.user_name} {self.song_id}>'
    
@app.route('/add_favorite', methods=['POST'])
def add_favorite():
    try:
        data = request.json
        new_favorite = Favorite(user_name=data['user_name'], song_id=data['song_id'])
        db.session.add(new_favorite)
        db.session.commit()
        return jsonify({'message': 'Favorite added successfully'}), 200
    except Exception as e:
        logging.exception("Error adding favorite")  # Log the exception
        return jsonify({'error': str(e)}), 500

@app.route('/remove_favorite', methods=['POST'])
def remove_favorite():
    data = request.json
    favorite = Favorite.query.filter_by(user_name=data['user_name'], song_id=data['song_id']).first()
    if favorite:
        db.session.delete(favorite)
        db.session.commit()
        return jsonify({'message': 'Favorite removed successfully'}), 200
    else:
        return jsonify({'message': 'Favorite not found'}), 404

@app.route('/get_favorites/<user_name>', methods=['GET'])
def get_favorites(user_name):
    favorites = Favorite.query.filter_by(user_name=user_name).all()
    favorite_songs = [{'song_id': fav.song_id} for fav in favorites]
    return jsonify(favorite_songs), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
