# 🎵 Spotify Wrapped SQL Analysis  

## 📋 Project Overview  

Ever wondered what your Spotify Wrapped *didn't* tell you?  

This project is a **SQL-powered deep dive** into my 2024 Spotify streaming habits — based on over **20,000 rows** of listening data from March 2024 to May 2025.  

Unlike the official Spotify Wrapped, which offers a polished summary, this analysis goes **under the hood** using raw data and SQL queries to uncover:

- 🔁 My **most repeated songs** (even across distinct days)  
- 🎤 Artists I came back to **month after month**  
- ☀️ **Seasonal favorites** — what I listened to most in summer vs. winter  
- ⏱️ Total time spent listening 
- 📅 Most music-filled days of the year  
- ⏭️ How often I skipped tracks (played < 30 seconds)

By transforming JSON data into a relational table and running custom SQL queries, I was able to build my own version of Wrapped — with way more flexibility and **personalized insights Spotify never shows you**.

Whether you’re into analytics, music, or both — this project shows what’s possible when you combine raw listening data with the power of SQL.

---

## Get Your Personal Data from Spotify

### I exported my **Spotify streaming history** and loaded it into a MySQL database to perform SQL-based analytics.  
The dataset includes the following key fields:

- `endTime`: When the track finished playing  
- `artistName`: Artist’s name  
- `trackName`: Track name  
- `msPlayed`: Duration played in milliseconds  

---

## 🛠️ Data Preparation  

### ✅ Cleaning  
- Converted JSON to a table named `history`  
- Removed unnecessary columns and rows with missing values  
- Standardized time to minutes (`msPlayed / 60000`) for analysis  

### 🧮 SQL Setup
```sql
USE newwrapped;
SHOW TABLES;

-- Preview and validate
SELECT COUNT(*) FROM history;
SELECT * FROM history LIMIT 5;
```

---

## 📊 Analysis and Insights  

---

### 1️⃣ Total Listening Time
```sql
SELECT FLOOR(SUM(msPlayed / (1000 * 60))) AS Total_Mins
FROM history;
```
| Total_Mins |
|-----------------------------|
| 25783                       |


**🎧 Total Minutes Listened**: `25,783  mins`

---

### 2️⃣ Top 10 Artists by Listening Time
```sql
SELECT artistName, FLOOR(SUM(msPlayed / (1000 * 60))) AS total_mins
FROM history
GROUP BY artistName
ORDER BY total_mins DESC
LIMIT 10;
```
| artistname       | total_mins |
| ---------------- | -------- |
| Shawn Mendes     | 725      |
| Pritam           | 648      |
| Lana Del Rey     | 581      |
| Hozier           | 545      |
| Taylor Swift     | 520      |
| James Arthur     | 468      |
| Sam Smith        | 438      |
| A.R. Rahman      | 436      |
| Chappell Roan    | 432      |
| Ed Sheeran       | 383      |

---

### 3️⃣ Most Played Songs (by Duration)
```sql
SELECT trackName, FLOOR(SUM(msPlayed / (1000 * 60))) AS total_mins, artistName
FROM history
GROUP BY trackName, artistName
ORDER BY total_mins DESC
LIMIT 5;
```
| trackname                         | total_mins | artistname    |
| --------------------------------- | ---------- | ------------- |
| Take Me To Church                 | 218        | Hozier        |
| Coming In Hot                     | 212        | Andy Mineo    |
| Too Sweet                         | 184        | Hozier        |
| Tum Tak (From "Raanjhanaa")       | 183        | A.R. Rahman   |
| The Night We Met                  | 174        | Lord Huron    |

---

### 4️⃣ Artists You Played the Most (by Play Count)
```sql
SELECT artistName, COUNT(*) AS total_plays
FROM history
GROUP BY artistName
ORDER BY total_plays DESC
LIMIT 5;
```
| artistName    | total_plays |
| ------------- | ----------- |
| Shawn Mendes  | 272         |
| Taylor Swift  | 253         |
| Pritam        | 209         |
| James Arthur  | 187         |
| Sam Smith     | 148         |

---

### 5️⃣ Skipped or Short Plays (< 30 Seconds)
```sql
SELECT COUNT(*) AS total_short_plays
FROM history
WHERE msPlayed < 30000;
```
| Total_short_plays |
|-------------|
| 8062        |

---

### 6️⃣ Unique Artists and Songs Discovered
```sql
SELECT 
  COUNT(DISTINCT artistName) AS unique_artists,
  COUNT(DISTINCT trackName) AS unique_songs
FROM history;
```
| unique_artist | unique_songs |
| ------------- | ------------ |
| 846           | 1865         |

---

### 7️⃣ Most Music-Filled Days
```sql
SELECT 
   DATE_FORMAT(endtime, '%y-%m-%d')as day,
   FLOOR(SUM(msplayed) / (1000*60)) AS total_mins
FROM allhistory
GROUP BY day
ORDER BY total_mins desc
limit 1;
```
| day        | total_minutes|
| ---------- | ---------- |
| 2025-01-5 | 261        |

---

### 8️⃣ Monthly Listening Time
```sql
SELECT 
  DATE_FORMAT(endTime, '%Y-%m') AS Month,
  ROUND(SUM(msPlayed) / (1000 * 60)) AS total_minutes
FROM history
GROUP BY Month
ORDER BY Month;
```
| Month   | Total_minutes |
|---------|------------|
| 2024-03 | 1738       |
| 2024-04 | 1469       |
| 2024-05 | 2320       |
| 2024-06 | 1753       |
| 2024-07 | 1535       |
| 2024-08 | 1557       |
| 2024-09 | 1430       |
| 2024-10 | 1601       |
| 2024-11 | 1719       |
| 2024-12 | 2331       |
| 2025-01 | 1136       |
| 2025-02 | 1517       |
| 2025-03 | 2142       |
| 2025-04 | 2875       |
| 2025-05 | 367        |
---

### 9️⃣ How many times a song was played 
```sql
select trackname,artistname, count(*) as count
from allhistory
where trackname = 'O Rangrez'
group by artistname,trackname;
```
| Trackname    | Artistname             | Count |
|--------------|------------------------|-------|
| O Rangrez    | Shankar-Ehsaan-Loy     | 22    |

---

### 🔟 Top Artist Per Month (Window Function)
```sql
SELECT Month, ArtistName, Play_count 
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
```
| Month   | Artistname              | Play_count |
|---------|-------------------------|------------|
| 24-Mar  | Pritam                  | 33         |
| 24-Apr  | Shawn Mendes            | 20         |
| 24-May  | James Arthur            | 66         |
| 24-Jun  | Shawn Mendes            | 90         |
| 24-Jul  | Taylor Swift            | 37         |
| 24-Aug  | Taylor Swift            | 28         |
| 24-Sep  | Pritam                  | 36         |
| 24-Oct  | Taylor Swift            | 44         |
| 24-Nov  | Taylor Swift            | 39         |
| 24-Dec  | Cigarettes After Sex    | 40         |
| 25-Jan  | Sam Smith               | 36         |
| 25-Feb  | Lana Del Rey            | 46         |
| 25-Mar  | Chappell Roan           | 113        |
| 25-Apr  | Lana Del Rey            | 38         |
| 25-May  | Chappell Roan           | 7          |
---

### 🔁 Songs I Keep Coming Back to
```sql
SELECT 
  trackName,
  artistName,
  COUNT(DISTINCT DATE_FORMAT(endTime, '%y-%m-%d')) AS Day_count
FROM history
GROUP BY trackName, artistName
ORDER BY day_count DESC
limit 5;
```
| Trackname               | Artistname         | Day_count |
|-------------------------|--------------------|-----------|
| The Night We Met        | Lord Huron         | 96        |
| Coming In Hot           | Andy Mineo         | 95        |
| I Wanna Be Yours        | Arctic Monkeys     | 75        |
| Atlantis                | Seafret            | 72        |
| Teenage Dream           | Stephen Dawes      | 66        |
---

### 🌦️ Favorite Song by Season
```sql
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
```
| Season | Trackname                   | Total_time |
|--------|-----------------------------|------------|
| Fall   | Kun Faya Kun                | 79         |
| Spring | Coming In Hot               | 98         |
| Summer | Too Sweet                   | 67         |
| Winter | Can't Take My Eyes off You  | 90         |
---

## 📈 Learnings & Highlights  
Through this project, I gained deeper insight into both my **listening habits** and the power of SQL for storytelling with data. Here are some standout takeaways:

- Mastered SQL aggregation, grouping, and date formatting  
- Used **window functions**: `ROW_NUMBER`, `RANK`, `DENSE_RANK`  
- Learned to clean real-world data for analytical storytelling  
- Identified unique musical habits using only SQL — no dashboards or Python needed!

---

## 🧰 Tools Used  

- Spotify History Data
- **MySQL** Workbench   

---
 
### 💡 SQL Skills Used  

- `WINDOW FUNCTIONS`: `RANK()`, `ROW_NUMBER()`, `DENSE_RANK()`  
- `AGGREGATIONS`: `COUNT()`, `SUM()`, `FLOOR()`  
- `DATE FUNCTIONS`: `MONTH()`, `DATE_FORMAT()`, `YEAR()`  
- `SUBQUERIES`, `CTEs`, and `PARTITION BY`


---

## 📎 Credits

- **Dataset**: Personal Spotify streaming history 
 
