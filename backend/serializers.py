def song_payload(song, country_code):
    return {
        "song_id": song.song_id,
        "country": song.country,
        "song_name": song.song_name,
        "artist": song.artist,
        "language": song.language,
        "average_score": song.average_score,
        "x_count": song.x_count,
        "country_code": country_code or "Unknown",
    }


def final_result_payload(result, song, user_score="Not Voted"):
    return {
        "song_id": result.song_id,
        "country": result.country,
        "total_points": result.totalPoints,
        "jury_points": result.juryPoints,
        "televoting_points": result.televotingPoints,
        "place": result.place,
        "song_name": song.song_name if song else None,
        "artist": song.artist if song else None,
        "average_score": song.average_score if song else None,
        "user_score": user_score,
    }
