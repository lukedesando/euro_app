from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
CORS(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://root:FuckYou123@localhost/eurovision_db'
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

class Vote(db.Model):
    __tablename__ = 'votes'
    user_name = db.Column(db.String(50), primary_key=True)
    score = db.Column(db.Integer)
    song_id = db.Column(db.Integer, db.ForeignKey('songs.song_id'), primary_key=True)

@app.route('/songs', methods=['GET'])
def get_songs():
    songs = Song.query.all()
    return jsonify([song.to_dict() for song in songs])

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
    app.run(debug=True)
