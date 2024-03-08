import requests

url = "http://localhost:5000/vote"
payload = {
    "user_name": "Casey's Butt",
    "song_id": 6,
    "score": 4
}

response = requests.post(url, json=payload)

print(f"Status Code: {response.status_code}")
print(f"Response: {response.text}")
