from flask import Flask, request, jsonify
import mysql.connector

app = Flask(__name__)

# Database connection
db = mysql.connector.connect(

)

@app.route('/songs', methods=['GET'])
def get_songs():
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM songs")
    songs = cursor.fetchall()
    cursor.close()
    return jsonify(songs)

@app.route('/vote', methods=['POST'])
def vote():
    data = request.json
    cursor = db.cursor()
    cursor.execute("INSERT INTO votes (user_name, song_id, score) VALUES (%s, %s, %s)",
                   (data['user_name'], data['song_id'], data['score']))
    db.commit()
    cursor.close()
    return jsonify({"message": "Vote recorded"})

if __name__ == '__main__':
    app.run(debug=True)
