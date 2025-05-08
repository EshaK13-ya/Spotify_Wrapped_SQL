-- 1️⃣ Total Listening Time
SELECT FLOOR(SUM(msPlayed / (1000 * 60))) AS Total_Mins
FROM history;

-- 2️⃣ Top 10 Artists by Listening Time
SELECT artistName, FLOOR(SUM(msPlayed / (1000 * 60))) AS total_mins
FROM history
GROUP BY artistName
ORDER BY total_mins DESC
LIMIT 10;

-- 3️⃣ Most Played Songs (by Duration)
SELECT trackName, FLOOR(SUM(msPlayed / (1000 * 60))) AS total_mins, artistName
FROM history
GROUP BY trackName, artistName
ORDER BY total_mins DESC
LIMIT 5;

-- 4️⃣ Artists You Played the Most (by Play Count)
SELECT artistName, COUNT(*) AS total_plays
FROM history
GROUP BY artistName
ORDER BY total_plays DESC
LIMIT 5;

-- 5️⃣ Skipped or Short Plays (< 30 Seconds)
SELECT COUNT(*) AS total_short_plays
FROM history
WHERE msPlayed < 30000;

-- 6️⃣ Unique Artists and Songs Discovered
SELECT 
  COUNT(DISTINCT artistName) AS unique_artists,
  COUNT(DISTINCT trackName) AS unique_songs
FROM history;

-- 7️⃣ Most Music-Filled Days
SELECT 
   DATE_FORMAT(endtime, '%y-%m-%d') AS day,
   FLOOR(SUM(msplayed) / (1000*60)) AS total_mins
FROM allhistory
GROUP BY day
ORDER BY total_mins DESC
LIMIT 1;

-- 8️⃣ Monthly Listening Time
SELECT 
  DATE_FORMAT(endTime, '%Y-%m') AS Month,
  ROUND(SUM(msPlayed) / (1000 * 60)) AS total_minutes
FROM history
GROUP BY Month
ORDER BY Month;

-- 9️⃣ How many times a song was played
SELECT trackname, artistname, COUNT(*) AS count
FROM allhistory
WHERE trackname = 'O Rangrez'
GROUP BY artistname, trackname;

-- 🔟 Top Artist Per Month
SELECT Month, artistName, play_count 
FROM (
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

-- 🔁 Songs I Keep Coming Back to
SELECT 
  trackName,
  artistName,
  COUNT(DISTINCT DATE_FORMAT(endTime, '%y-%m-%d')) AS day_count
FROM history
GROUP BY trackName, artistName
ORDER BY day_count DESC
LIMIT 5;

-- 🌦️ Favorite Song by Season
WITH seasonal_totals AS (
  SELECT 
    CASE
      WHEN MONTH(endTime) IN (12, 1, 2) THEN 'Winter'
      WHEN MONTH(endTime) IN (3, 4, 5) THEN 'Spring'
      WHEN MONTH(endTime) IN (6, 7, 8) THEN 'Summer'
      ELSE 'Fall'
    END AS season,
    trackName,
    FLOOR(SUM(msPlayed / 1000 / 60)) AS total_time
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
