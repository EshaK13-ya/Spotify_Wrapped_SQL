# Spotify_Wrapped_SQL

Overview

This SQL-based data analysis project explores personal music listening history using Spotify data. The goal was to extract meaningful patterns from raw listening data using advanced SQL techniques like window functions, date formatting, grouping, and subqueries.

Tools Used

MySQL Workbench

Excel (for data cleaning)

GitHub (project showcase)

Dataset

The dataset contains streaming history with fields like:

endTime: Date and time when the track ended

artistName: Artist of the track

trackName: Name of the song

msPlayed: Duration played in milliseconds

Key SQL Concepts Practiced

Aggregations (SUM, COUNT, MAX)

Date formatting (DATE_FORMAT)

Window functions (RANK(), ROW_NUMBER(), DENSE_RANK())

Common Table Expressions (CTEs)

Filtering and grouping logic

📊 Project Highlights (Insights)

1. 🎧 Total Listening Time

SELECT FLOOR(SUM(msplayed / (1000 * 60))) AS Total_Mins FROM history;

2. 🔝 Top 10 Artists by Listening Time

SELECT artistName, FLOOR(SUM(msplayed / (1000 * 60))) AS total_ms
FROM history
GROUP BY artistName
ORDER BY total_ms DESC
LIMIT 10;

3. 🚫 Delete Specific Artist from Dataset

SET SQL_SAFE_UPDATES = 1;
DELETE FROM history
WHERE LOWER(artistName) = LOWER("girl in red");

4. 🎶 Most Played Songs (by Total Listening Time)

SELECT trackName, FLOOR(SUM(msplayed / (1000 * 60))) AS total_mins, artistName
FROM history
GROUP BY trackName, artistName
ORDER BY total_mins DESC
LIMIT 5;

5. 🔁 Total Times an Artist Was Played

SELECT artistName, COUNT(*) AS total_times
FROM history
GROUP BY artistName
ORDER BY total_times DESC
LIMIT 5;

6. ⏱️ Songs Played for Less Than 30 Seconds

SELECT COUNT(*) AS total_songs
FROM history
WHERE msplayed < 30000;

7. 🆔 Unique Artists and Songs Listened To

SELECT
  COUNT(DISTINCT artistName) AS unique_artist,
  COUNT(DISTINCT trackName) AS unique_songs
FROM history;

8. 🗓️ Top Listening Days

SELECT endTime, SUM(msplayed / 1000 * 60) AS total_mins
FROM history
GROUP BY endTime
ORDER BY total_mins DESC
LIMIT 10;

9. 📅 Monthly Listening Time

SELECT
  DATE_FORMAT(endTime, '%Y-%m') AS month,
  ROUND(SUM(msPlayed) / (1000 * 60)) AS total_minutes
FROM history
GROUP BY month
ORDER BY month;

10. 🏆 Most Music-Filled Day

SELECT
  DATE_FORMAT(endTime, '%y-%m-%d') AS day,
  FLOOR(SUM(msplayed) / (1000 * 60)) AS total_mins
FROM history
GROUP BY day
ORDER BY total_mins DESC
LIMIT 1;

11. 🌟 Top Artist Per Month

SELECT month, artistName, play_count FROM (
  SELECT
    DATE_FORMAT(endTime, '%y-%m') AS month,
    artistName,
    COUNT(*) AS play_count,
    RANK() OVER (
      PARTITION BY DATE_FORMAT(endTime, '%y-%m')
      ORDER BY COUNT(*) DESC
    ) AS rnk
  FROM history
  GROUP BY month, artistName
) x
WHERE rnk = 1;

12. 🎵 Top Song Per Month

SELECT month, trackName, play_count FROM (
  SELECT
    DATE_FORMAT(endTime, '%y-%m') AS month,
    trackName,
    COUNT(*) AS play_count,
    DENSE_RANK() OVER (
      PARTITION BY DATE_FORMAT(endTime, '%y-%m')
      ORDER BY COUNT(*) DESC
    ) AS rnk
  FROM history
  GROUP BY month, trackName
) x
WHERE rnk = 1;

13. 🔁 The Song I Keep Coming Back To

SELECT
  trackName,
  artistName,
  COUNT(DISTINCT DATE_FORMAT(endTime, '%y-%m-%d')) AS day_count
FROM history
GROUP BY trackName, artistName
ORDER BY day_count DESC;

14. ❄️ Seasonal Favorites

WITH seasonal_totals AS (
  SELECT
    CASE
      WHEN MONTH(endTime) IN (12, 1, 2) THEN 'Winter'
      WHEN MONTH(endTime) IN (3, 4, 5) THEN 'Spring'
      WHEN MONTH(endTime) IN (6, 7, 8) THEN 'Summer'
      ELSE 'Fall'
    END AS season,
    trackName,
    FLOOR(SUM(msplayed / 1000 / 60)) AS total_time
  FROM history
  GROUP BY season, trackName
),
ranked_tracks AS (
  SELECT *,
         RANK() OVER (PARTITION BY season ORDER BY total_time DESC) AS rnk
  FROM seasonal_totals
)
SELECT season, trackName, total_time
FROM ranked_tracks
WHERE rnk = 1
ORDER BY season;

💡 What I Learned

How to use WINDOW FUNCTIONS like RANK, ROW_NUMBER, DENSE_RANK

Filtering and grouping over time using DATE_FORMAT

Using subqueries and CTEs to isolate complex logic

How SQL can extract real, personalized insights from raw behavioral data

📁 Folder Structure

Spotify-SQL-Project/
├── README.md
├── queries.sql
├── screenshots/
│   ├── top_artist_per_month.png
│   ├── seasonal_favourites.png
│   └── ...
└── dataset.csv

🔗 Connect

Name: Esha Khot

GitHub: [your GitHub link here]

LinkedIn: [your LinkedIn link here]

Let music and data tell your story 🎶📊
