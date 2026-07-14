from __future__ import annotations

import argparse
import os
import re
import sys
import unicodedata
from dataclasses import dataclass
from urllib.parse import quote

import pymysql
import requests
import urllib3
from bs4 import BeautifulSoup
from dotenv import load_dotenv

try:
    import certifi
except ImportError:
    certifi = None


WIKIPEDIA_URL = "https://en.wikipedia.org/wiki/Eurovision_Song_Contest_{year}"
RELATED_TABLES = ("votes", "favorites", "final_results")
SONG_COLUMN_DEFINITIONS = (
    "MODIFY country VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci",
    "MODIFY song_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci",
    "MODIFY artist VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci",
    "MODIFY language VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci",
    "MODIFY final_rank INT NOT NULL DEFAULT 0",
)
FINAL_RESULTS_COLUMN_DEFINITIONS = (
    "MODIFY country VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci",
)


@dataclass(frozen=True)
class SongEntry:
    country: str
    song_name: str
    artist: str
    language: str | None


@dataclass(frozen=True)
class FinalResultEntry:
    country: str
    total_points: int
    jury_points: int
    televoting_points: int
    place: int


def clean_cell_text(cell):
    for element in cell.find_all(["sup", "style"]):
        element.decompose()

    text = cell.get_text(" ", strip=True)
    text = text.replace("\u201c", "").replace("\u201d", "")
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def contains_non_latin_script(text):
    for char in text:
        if char.isalpha() and "LATIN" not in unicodedata.name(char, ""):
            return True
    return False


def clean_song_title(cell):
    title = clean_cell_text(cell).replace('"', "").replace("\u201c", "").replace("\u201d", "")
    title = re.sub(
        r"\s*\(([^)]*)\)",
        lambda match: "" if contains_non_latin_script(match.group(1)) else match.group(0),
        title,
    )
    return re.sub(r"\s+", " ", title).strip()


def normalize_header(header):
    header = clean_cell_text(header).lower()
    header = re.sub(r"\[[^\]]+\]", "", header)
    header = re.sub(r"\(.*?\)", "", header)
    return re.sub(r"[^a-z0-9]+", " ", header).strip()


def header_matches(header, expected):
    words = normalize_header(header).split()
    return expected in words


def find_column(headers, expected, required=True):
    for index, header in enumerate(headers):
        if header_matches(header, expected):
            return index

    if required:
        joined_headers = ", ".join(clean_cell_text(header) for header in headers)
        raise ValueError(f"Could not find a '{expected}' column. Found: {joined_headers}")

    return None


def country_from_cell(cell):
    img = cell.find("img", alt=True)
    if img and img["alt"]:
        alt = img["alt"].strip()
        if alt and not alt.lower().endswith(".svg"):
            return alt

    links = [
        link.get_text(" ", strip=True)
        for link in cell.find_all("a")
        if link.get_text(" ", strip=True)
    ]
    if links:
        return links[-1]

    return clean_cell_text(cell)


def parse_int(text):
    match = re.search(r"\d+", text.replace(",", ""))
    if not match:
        raise ValueError(f"Could not parse an integer from '{text}'")
    return int(match.group(0))


def get_wikipedia_html(year, insecure=False):
    url = WIKIPEDIA_URL.format(year=quote(str(year)))
    verify = False if insecure else certifi.where() if certifi else True
    if insecure:
        urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    response = requests.get(
        url,
        headers={"User-Agent": "EuroVisionSongUpdater/1.0"},
        timeout=30,
        verify=verify,
    )
    response.raise_for_status()
    return response.text, url


def table_caption_matches(caption, year):
    text = clean_cell_text(caption).lower()
    return (
        "participants of the eurovision song contest" in text
        and str(year) in text
    )


def find_participants_table(soup, year):
    for caption in soup.find_all("caption"):
        if table_caption_matches(caption, year):
            return caption.find_parent("table")

    for table in soup.select("table.wikitable"):
        headers = [normalize_header(th) for th in table.find_all("th")]
        has_expected_columns = all(
            any(expected in header.split() for header in headers)
            for expected in ("country", "artist", "song")
        )
        if has_expected_columns:
            return table

    return None


def find_final_split_table(soup):
    for caption in soup.find_all("caption"):
        text = clean_cell_text(caption).lower()
        if "split results" not in text or "semi" in text:
            continue

        table = caption.find_parent("table")
        if "final" in text or table_is_under_final_heading(table):
            return table

    return None


def table_is_under_final_heading(table):
    heading = table.find_previous(["h2", "h3", "h4"])
    if not heading:
        return False

    text = clean_cell_text(heading).lower()
    return "final" in text and "semi" not in text


def parse_songs_from_html(html, year):
    soup = BeautifulSoup(html, "html.parser")
    table = find_participants_table(soup, year)
    if not table:
        raise ValueError(f"Could not find the participants table for {year}.")

    header_row = next(
        (
            row
            for row in table.find_all("tr")
            if row.find_all("th", scope="col")
        ),
        None,
    )
    if not header_row:
        raise ValueError("Could not find the participants table header row.")

    headers = header_row.find_all(["th", "td"])
    country_idx = find_column(headers, "country")
    artist_idx = find_column(headers, "artist")
    song_idx = find_column(headers, "song")
    language_idx = find_column(headers, "language", required=False)

    songs = []
    for row in table.find_all("tr"):
        if row is header_row:
            continue

        cells = row.find_all(["th", "td"])
        if len(cells) <= max(country_idx, artist_idx, song_idx):
            continue

        country = country_from_cell(cells[country_idx])
        artist = clean_cell_text(cells[artist_idx])
        song_name = clean_song_title(cells[song_idx])
        language = (
            clean_cell_text(cells[language_idx])
            if language_idx is not None and len(cells) > language_idx
            else None
        )

        if country and artist and song_name:
            songs.append(
                SongEntry(
                    country=country,
                    song_name=song_name,
                    artist=artist,
                    language=language or None,
                )
            )

    if not songs:
        raise ValueError("Found the participants table, but no songs could be parsed.")

    return songs


def parse_final_results_from_html(html):
    soup = BeautifulSoup(html, "html.parser")
    table = find_final_split_table(soup)
    if not table:
        raise ValueError("Could not find the final split results table.")

    combined_results = {}
    jury_points = {}
    televoting_points = {}

    for row in table.find_all("tr"):
        cells = row.find_all(["th", "td"])
        values = [clean_cell_text(cell) for cell in cells]
        if len(values) < 7 or not values[0] or not values[0][0].isdigit():
            continue

        place = parse_int(values[0])
        combined_country = values[1]
        total_points = parse_int(values[2])
        jury_country = values[3]
        jury_score = parse_int(values[4])
        televoting_country = values[5]
        televoting_score = parse_int(values[6])

        combined_results[combined_country] = {
            "place": place,
            "total_points": total_points,
        }
        jury_points[jury_country] = jury_score
        televoting_points[televoting_country] = televoting_score

    final_results = []
    for country, result in combined_results.items():
        if country not in jury_points or country not in televoting_points:
            raise ValueError(f"Split results are incomplete for {country}.")

        final_results.append(
            FinalResultEntry(
                country=country,
                total_points=result["total_points"],
                jury_points=jury_points[country],
                televoting_points=televoting_points[country],
                place=result["place"],
            )
        )

    if not final_results:
        raise ValueError("Found the final split results table, but no results could be parsed.")

    return sorted(final_results, key=lambda result: result.place)


def database_config():
    load_dotenv()
    required_names = ("DB_USER", "DB_PASSWORD", "DB_HOST", "DB_NAME")
    missing = [name for name in required_names if not os.getenv(name)]
    if missing:
        raise RuntimeError(f"Missing required environment variables: {', '.join(missing)}")

    return {
        "host": os.getenv("DB_HOST"),
        "user": os.getenv("DB_USER"),
        "password": os.getenv("DB_PASSWORD"),
        "database": os.getenv("DB_NAME"),
        "port": int(os.getenv("DB_PORT", os.getenv("DATABASE_PORT", "3306"))),
        "charset": "utf8mb4",
        "autocommit": False,
    }


def overwrite_songs(songs, final_results):
    connection = pymysql.connect(**database_config())
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "ALTER TABLE songs CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
            )
            cursor.execute(
                "ALTER TABLE final_results CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
            )
            for definition in SONG_COLUMN_DEFINITIONS:
                cursor.execute(f"ALTER TABLE songs {definition}")
            for definition in FINAL_RESULTS_COLUMN_DEFINITIONS:
                cursor.execute(f"ALTER TABLE final_results {definition}")

            for table in RELATED_TABLES:
                cursor.execute(f"DELETE FROM {table}")

            cursor.execute("DELETE FROM songs")
            cursor.execute("ALTER TABLE songs AUTO_INCREMENT = 1")
            cursor.executemany(
                """
                INSERT INTO songs (
                    country,
                    song_name,
                    artist,
                    language,
                    average_score,
                    x_count,
                    final_rank
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                """,
                [
                    (
                        song.country,
                        song.song_name,
                        song.artist,
                        song.language,
                        None,
                        0,
                        0,
                    )
                    for song in songs
                ],
            )

            song_ids_by_country = fetch_song_ids_by_country(cursor)
            missing_result_countries = [
                result.country
                for result in final_results
                if result.country not in song_ids_by_country
            ]
            if missing_result_countries:
                raise ValueError(
                    "Could not match final results to songs for: "
                    + ", ".join(missing_result_countries)
                )

            cursor.executemany(
                """
                INSERT INTO final_results (
                    song_id,
                    country,
                    TotalPoints,
                    juryPoints,
                    televotingPoints,
                    place
                )
                VALUES (%s, %s, %s, %s, %s, %s)
                """,
                [
                    (
                        song_ids_by_country[result.country],
                        result.country,
                        result.total_points,
                        result.jury_points,
                        result.televoting_points,
                        result.place,
                    )
                    for result in final_results
                ],
            )
            cursor.executemany(
                "UPDATE songs SET final_rank = %s WHERE song_id = %s",
                [
                    (result.place, song_ids_by_country[result.country])
                    for result in final_results
                ],
            )
        connection.commit()
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()


def fetch_song_ids_by_country(cursor):
    cursor.execute("SELECT song_id, country FROM songs")
    return {country: song_id for song_id, country in cursor.fetchall()}


def print_preview(songs):
    for song in songs:
        language = f" [{song.language}]" if song.language else ""
        print(f"{song.country}: {song.artist} - {song.song_name}{language}")


def print_final_results_preview(final_results):
    for result in final_results:
        print(
            f"{result.place}. {result.country}: "
            f"{result.total_points} total, "
            f"{result.jury_points} jury, "
            f"{result.televoting_points} televote"
        )


def positive_year(value):
    try:
        year = int(value)
    except ValueError as exc:
        raise argparse.ArgumentTypeError("year must be a number") from exc

    if year < 1956:
        raise argparse.ArgumentTypeError("Eurovision started in 1956")

    return year


def parse_args():
    parser = argparse.ArgumentParser(
        description="Scrape Eurovision songs from Wikipedia and overwrite MariaDB songs."
    )
    parser.add_argument("year", type=positive_year, help="Eurovision contest year to load")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print scraped songs without updating MariaDB",
    )
    parser.add_argument(
        "--yes",
        action="store_true",
        help="Skip the overwrite confirmation prompt",
    )
    parser.add_argument(
        "--insecure",
        action="store_true",
        help="Disable HTTPS certificate verification for the Wikipedia request",
    )
    return parser.parse_args()


def main():
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    args = parse_args()

    html, url = get_wikipedia_html(args.year, insecure=args.insecure)
    songs = parse_songs_from_html(html, args.year)
    final_results = parse_final_results_from_html(html)

    print(f"Scraped {len(songs)} songs from {url}")
    print_preview(songs)
    print(f"\nScraped {len(final_results)} final split results")
    print_final_results_preview(final_results)

    if args.dry_run:
        print("\nDry run only. MariaDB was not updated.")
        return 0

    if not args.yes:
        answer = input(
            "\nOverwrite songs and clear votes, favorites, and final_results? Type YES: "
        )
        if answer != "YES":
            print("Cancelled. MariaDB was not updated.")
            return 1

    overwrite_songs(songs, final_results)
    print(
        f"\nUpdated MariaDB with {len(songs)} songs and "
        f"{len(final_results)} final results for {args.year}."
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        raise SystemExit(1)
