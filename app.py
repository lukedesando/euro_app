from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)
CORS(app)

# Database connection
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="FuckYou123",
    database="eurovision_db"
)

@app.route('/songs', methods=['GET'])
def get_songs():
    cursor = db.cursor()
    cursor.execute("SELECT song_name FROM songs")
    songs = cursor.fetchall()
    # cursor.close()
    # db.close()
    return jsonify([song[0] for song in songs])

@app.route('/vote', methods=['POST'])
def vote():
    data = request.json
    cursor = db.cursor()
    cursor.execute("INSERT INTO votes (user_name, song_id, score) VALUES (%s, %s, %s)",
                   (data['user_name'], data['song_id'], data['score']))
    db.commit()
    # cursor.close()
    return jsonify({"message": "Vote recorded"})

if __name__ == '__main__':
    app.run(debug=True)
