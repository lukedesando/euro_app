import requests
from bs4 import BeautifulSoup
import pymysql

# URL of the Wikipedia page
url = 'https://en.wikipedia.org/wiki/Eurovision_Song_Contest_2024'

# Send a GET request to the URL
response = requests.get(url)

# Parse the HTML content
soup = BeautifulSoup(response.content, 'html.parser')

# Find the table containing the songs based on caption text
table = None
for caption in soup.find_all('caption'):
    if 'Participants of the Eurovision Song Contest 2024' in caption.get_text():
        table = caption.find_parent('table')
        break

if table:
    # Connect to the MariaDB database
    connection = pymysql.connect(
        host='localhost',
        user='root',
        password='FuckYou123',
        database='eurovision_db'
    )

    # Create a cursor object
    cursor = connection.cursor()

    # Clean the existing data from the songs table
    cursor.execute("TRUNCATE TABLE songs")
    connection.commit()

    # Find the header row to determine column indices
    header_row = table.find('tr')
    headers = [th.text.strip() for th in header_row.find_all('th', scope='col')]

    # Determine the column indices for Country, Song, Artist, and Language
    country_idx = headers.index('Country')
    song_idx = headers.index('Song')
    artist_idx = headers.index('Artist')
    language_idx = headers.index('Language') if 'Language' in headers else None

    # Iterate over the rows of the table and insert each song into the songs table
    for row in table.find_all('tr')[1:]:  # Skip the header row
        cells = row.find_all('td')
        if len(cells) >= max(country_idx, song_idx, artist_idx, language_idx):
            country = cells[country_idx].find('img')['alt'] if cells[country_idx].find('img') else cells[country_idx].text.strip()
            artist = cells[artist_idx - 1].text.strip()
            song = cells[song_idx - 1].text.strip()
            language = cells[language_idx - 1].text.strip() if language_idx is not None else None
            try:
                cursor.execute("INSERT INTO songs (country, song_name, artist, language) VALUES (%s, %s, %s, %s)", (country, song, artist, language))
                connection.commit()
                print(f"Inserted: {country} - {artist} - {song} - {language}")
            except Exception as e:
                print(f"Error inserting {country} - {artist} - {song} - {language}: {e}")

    # Close the cursor and connection
    cursor.close()
    connection.close()
else:
    print("Table not found")
