-- Spotify Advanced SQL Project --

CREATE TABLE spotify (
    artist VARCHAR(300),
    track VARCHAR(300),
    album VARCHAR(300),
    album_type VARCHAR(100),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(300),
    channel VARCHAR(300),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(100)
);

-- Some Exploratory Data Analysis --

SELECT * FROM spotify

SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;

SELECT COUNT(DISTINCT album) FROM spotify;

SELECT DISTINCT album_type FROM spotify;

SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify;

SELECT * FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0;

SELECT * FROM spotify
WHERE duration_min = 0;

SELECT DISTINCT channel FROM spotify;

----- Business Problem -----

-- 1. Retrieve the names of all tracks that have more than 1 billion streams.
SELECT * FROM spotify
WHERE stream > 1000000000;

-- 2. List all albums along with their respective artists.
SELECT 
   DISTINCT album, artist
FROM spotify
ORDER BY 1;

-- 3. Get the total number of comments for tracks where `licensed = TRUE`.
SELECT SUM(comments) AS total_comments
   FROM spotify
WHERE licensed = TRUE;

-- 4. Find all tracks that belong to the album type `single`.
SELECT * FROM spotify
WHERE album_type = 'single';

-- 5. Count the total number of tracks by each artist.
SELECT artist, COUNT(*) AS total_tracks
   FROM spotify
GROUP BY artist
ORDER BY total_tracks DESC;

-- 6. Calculate the average danceability of tracks in each album.
SELECT album, AVG(danceability) AS average_danceability
   FROM spotify
GROUP BY album
ORDER BY average_danceability DESC;

-- 7. Find the top 5 tracks with the highest energy values.
SELECT track, energy
   FROM spotify
ORDER BY energy DESC
LIMIT 5;

--8. List all tracks along with their views and likes where `official_video = TRUE`.
SELECT track,
       SUM(views) AS total_views,
       SUM(likes) AS total_likes
FROM spotify
WHERE official_video = TRUE
GROUP BY track
ORDER BY total_views DESC
LIMIT 5;

-- 9. For each album, calculate the total views of all associated tracks.
SELECT album, track, SUM(views) AS total_views
FROM spotify
GROUP BY album, track
ORDER BY total_views DESC;

-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM
(SELECT track,
   COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) AS streamed_on_youtube,
   COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) AS streamed_on_spotify
FROM spotify
GROUP BY 1
) AS t1
WHERE 
   streamed_on_spotify > streamed_on_youtube
   AND
   streamed_on_youtube <> 0;

--11. Find the top 3 most-viewed tracks for each artist using window functions.
WITH ranking_artist
AS
(SELECT artist, track,
        SUM(views) as total_view,
		DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) as rank
FROM spotify
GROUP BY 1,2
ORDER BY 1, 3 DESC
)
SELECT * FROM ranking_artist
WHERE rank <=3;

-- 12. Write a query to find tracks where the liveness score is above the average.
SELECT track, artist, liveness
   FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

-- 13. Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH energy_stats AS (
    SELECT 
        album,
        MAX(energy) AS max_energy,
        MIN(energy) AS min_energy
    FROM spotify
    GROUP BY album
)
SELECT 
    album,
    max_energy,
    min_energy,
    (max_energy - min_energy) AS energy_difference
FROM energy_stats
ORDER BY energy_difference DESC;

-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT track, energy, liveness, (energy / liveness) AS energy_to_liveness_ratio
   FROM spotify
WHERE (energy / liveness) > 1.2;

--15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
SELECT track,
       SUM(likes) OVER (ORDER BY views DESC) AS cumulative_sum
FROM spotify
ORDER BY cumulative_sum DESC;
