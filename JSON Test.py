import requests

TestNum = 5

url = "http://localhost:5000/vote"
payload = {
    "user_name": "TestyMcTesterson",
    "score": TestNum,
    "song_id": TestNum
}

response = requests.post(url, json=payload)

print(f"Status Code: {response.status_code}")
print(f"Response: {response.text}")
