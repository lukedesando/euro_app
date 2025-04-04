from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_socketio import SocketIO, emit
import requests

from dotenv import load_dotenv
import os
import logging

#Comments for Hosting Test

app = Flask(__name__)
CORS(app)
socketio = SocketIO(app, cors_allowed_origins="*")

load_dotenv()
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")
DB_PORT = os.getenv("DB_PORT")

app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}'
db = SQLAlchemy(app)

def set_no_cache_headers(response):
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'  # No caching allowed
    response.headers['Pragma'] = 'no-cache'  # HTTP 1.0.
    response.headers['Expires'] = '0'  # Proxies.
    return response

class Results(db.Model):
    __tablename__ = 'final_results'

    song_id = db.Column(db.Integer, db.ForeignKey('songs.song_id'), primary_key=True)
    country = db.Column(db.String(100), nullable=False)
    totalPoints = db.Column(db.Integer, nullable=False)
    juryPoints = db.Column(db.Integer, nullable=False)
    televotingPoints = db.Column(db.Integer, nullable=False)
    place = db.Column(db.Integer, nullable=False)

    def to_dict(self):
        return {
            'song_id': self.song_id,
            'country': self.country,
            'totalPoints': self.totalPoints,
            'juryPoints': self.juryPoints,
            'televotingPoints': self.televotingPoints,
            'place': self.place
        }
    
@app.route('/final_results', methods=['GET'])
def get_final_results():
    results = db.session.query(
        Results,
        Song,
        Vote
    ).outerjoin(Song, Results.song_id == Song.song_id)\
     .outerjoin(Vote, Results.song_id == Vote.song_id).all()
    
    response = jsonify([
        {
            'song_id': result.Results.song_id,
            'country': result.Results.country,
            'total_points': result.Results.totalPoints,
            'jury_points': result.Results.juryPoints,
            'televoting_points': result.Results.televotingPoints,
            'place': result.Results.place,
            'song_name': result.Song.song_name,
            'artist': result.Song.artist,
            'average_score': result.Song.average_score,
            'user_score': result.Vote.score if result.Vote else 'Not Voted'
        } for result in results
    ])
    return set_no_cache_headers(response)

class Song(db.Model):
    __tablename__ = 'songs'
    song_id = db.Column(db.Integer, primary_key=True)
    country = db.Column(db.String(50))
    song_name = db.Column(db.String(50))
    artist = db.Column(db.String(50))
    language = db.Column(db.String(50))
    average_score = db.Column(db.Float)
    x_count = db.Column(db.Integer, default=0)

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
    response = jsonify([
        {
            'song_id': song[0].song_id,
            'country': song[0].country,
            'song_name': song[0].song_name,
            'artist': song[0].artist,
            'language': song[0].language,
            'average_score': song[0].average_score,
            'x_count': song[0].x_count,  # Include x_count in the response
            'country_code': song[1] if song[1] is not None else 'Unknown'
        } for song in songs
    ])
    return set_no_cache_headers(response)

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
    x_skip = db.Column(db.Boolean, default=False)

@app.route('/votepost', methods=['POST'])
def vote():
    data = request.json
    x_skip = data.get('x_skip', False)

    existing_vote = Vote.query.filter_by(user_name=data['user_name'], song_id=data['song_id']).first()
    if existing_vote:
        existing_vote.score = data['score']
        existing_vote.x_skip = x_skip
    else:
        new_vote = Vote(user_name=data['user_name'], score=data['score'], song_id=data['song_id'], x_skip=x_skip)
        db.session.add(new_vote)

    db.session.commit()

    # Fetch the updated x_count
    updated_x_count = Song.query.filter_by(song_id=data['song_id']).first().x_count
    print("Preparing to emit x_count_update with:", {'song_id': data['song_id'], 'x_count': updated_x_count})
    # Emit the updated x_count to all connected clients
    socketio.emit('x_count_update', {'song_id': data['song_id'], 'x_count': updated_x_count})

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
    response = jsonify([])
    return set_no_cache_headers(response)

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
    favorite_song_ids = db.session.query(Favorite.song_id).filter_by(user_name=user_name).all()
    favorite_song_ids = [song_id[0] for song_id in favorite_song_ids]

    if not favorite_song_ids:
        return jsonify([])  # No favorites for this user

    favorite_songs = db.session.query(Song, Country.country_code) \
        .outerjoin(Country, Song.country == Country.country_name) \
        .filter(Song.song_id.in_(favorite_song_ids)) \
        .all()

    response = jsonify([
        {
            'song_id': song[0].song_id,
            'country': song[0].country,
            'song_name': song[0].song_name,
            'artist': song[0].artist,
            'country_code': song[1] if song[1] is not None else 'Unknown'
        } for song in favorite_songs
    ])
    return set_no_cache_headers(response)

# SKIP COUNT

@app.route('/update_xcount', methods=['POST'])
def update_xcount():
    # Example of handling an update, you need to adapt this to your actual data handling
    data = request.get_json()
    song_id = data['song_id']
    new_x_count = data['new_x_count']
    
    # Update the database here
    song = Song.query.get(song_id)
    if song and song.x_count != new_x_count:
        song.x_count = new_x_count
        db.session.commit()
        
        # Emit the new x_count to all clients
        socketio.emit('x_count_update', {'song_id': song_id, 'x_count': new_x_count})
        return jsonify(success=True), 200
    else:
        db.session.rollback()
    return jsonify(success=False, message="No update needed (Server level)"), 200


@app.route('/get_xcount/<int:song_id>', methods=['GET'])
def get_xcount(song_id):
    song = Song.query.filter_by(song_id=song_id).first()
    if song:
        return jsonify({'x_count': song.x_count})
    else:
        return jsonify({'error': 'Song not found'}), 404
    


if __name__ == '__main__':
    socketio.run(app=app, host='0.0.0.0', port=DB_PORT, debug=True)
