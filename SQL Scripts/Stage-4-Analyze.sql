/*
===============================================================================
Project     : Cyclistic Rider Behavior Analysis
Framework   : APPASA
Stage       : Analyze
Script      : analyze_stage.sql

Description :
Analyzes the processed Cyclistic trip dataset to compare annual member and
casual rider behavior through descriptive, ride duration, temporal, bike
usage, and station-level analyses. Identifies key behavioral patterns and
business insights to support the primary business question and downstream
dashboard development (Share stage).

Author      : Saswat Seth
===============================================================================
*/

-------------------------------------------------------------
-- Set the project database as the active schema
-------------------------------------------------------------

USE cyclistic_tripdata;	

-------------------------------------------------------------
-- Analysis Environment and Dataset Overview
-------------------------------------------------------------

-- Purpose:
-- Establish the analytical dataset used throughout the
-- Analyze stage and review its structure and overall size.
--
-- This section provides an overview of the processed
-- analytical dataset before analysis begins.
-------------------------------------------------------------

-------------------------------------------------------------
-- Dataset Size
-------------------------------------------------------------

-- Review the total number of records available for analysis.

SELECT
    COUNT(*) AS total_records
FROM cyclistic_tripdata_2024_processed;

-------------------------------------------------------------
-- Dataset Structure
-------------------------------------------------------------

-- Review the schema of the processed analytical dataset.

DESCRIBE cyclistic_tripdata_2024_processed;

-------------------------------------------------------------
-- Dataset Sample
-------------------------------------------------------------

-- Inspect a sample of processed ride records.

SELECT *
FROM cyclistic_tripdata_2024_processed
LIMIT 10;

-------------------------------------------------------------
-- Descriptive Analysis
-------------------------------------------------------------

-- Purpose:
-- Summarize the processed dataset using descriptive
-- statistics to establish an overall understanding of rider
-- behavior before conducting detailed analyses.
-------------------------------------------------------------

-------------------------------------------------------------
-- Ride Duration Summary
-------------------------------------------------------------

-- Summarize ride duration across all processed rides.

SELECT

    COUNT(*) AS total_rides,

    MIN(ride_length_minutes) AS minimum_duration,

    MAX(ride_length_minutes) AS maximum_duration,

    ROUND(
        AVG(ride_length_minutes),
        2
    ) AS average_duration

FROM cyclistic_tripdata_2024_processed;

-------------------------------------------------------------
-- Rider Type Comparison
-------------------------------------------------------------

-- Purpose:
-- Compare ride volume and overall ride duration between
-- annual members and casual riders to establish the primary
-- behavioral differences before conducting detailed analyses.
-------------------------------------------------------------

-------------------------------------------------------------
-- Ride Volume
-------------------------------------------------------------

-- Summarize the total number of rides for each rider type.

SELECT
    member_casual,
    COUNT(*) AS total_rides
FROM cyclistic_tripdata_2024_processed
GROUP BY member_casual;

-------------------------------------------------------------
-- Ride Distribution
-------------------------------------------------------------

-- Calculate the percentage of total rides contributed by
-- each rider type.

SELECT
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(
        100.0 * COUNT(*) / (
            SELECT COUNT(*)
            FROM cyclistic_tripdata_2024_processed
        ),
        2
    ) AS ride_percentage
FROM cyclistic_tripdata_2024_processed
GROUP BY member_casual;

-------------------------------------------------------------
-- Average Ride Duration by Rider Type
-------------------------------------------------------------

-- Compare the average ride duration between annual
-- members and casual riders.

SELECT
    member_casual,
    ROUND(
        AVG(ride_length_minutes),
        2
    ) AS average_ride_duration
FROM cyclistic_tripdata_2024_processed
GROUP BY member_casual;

-------------------------------------------------------------
-- Ride Duration Analysis
-------------------------------------------------------------

-- Purpose:
-- Examine the distribution of ride durations to determine
-- whether average ride duration accurately represents
-- typical rider behavior and identify differences between
-- annual members and casual riders.
-------------------------------------------------------------

-------------------------------------------------------------
-- Ride Duration Distribution
-------------------------------------------------------------

-- Summarize ride frequency across duration intervals.

SELECT

    CASE

        WHEN ride_length_minutes < 5 THEN 'Under 5 min'
        WHEN ride_length_minutes < 10 THEN '5–10 min'
        WHEN ride_length_minutes < 20 THEN '10–20 min'
        WHEN ride_length_minutes < 30 THEN '20–30 min'
        WHEN ride_length_minutes < 60 THEN '30–60 min'
        ELSE '60+ min'

    END AS duration_bucket,

    COUNT(*) AS total_rides,

    ROUND(
        100.0 * COUNT(*) /
        (
            SELECT COUNT(*)
            FROM cyclistic_tripdata_2024_processed
        ),
        2
    ) AS ride_percentage

FROM cyclistic_tripdata_2024_processed

GROUP BY duration_bucket

ORDER BY
    MIN(ride_length_minutes);

-------------------------------------------------------------
-- Ride Duration Distribution by Rider Type
-------------------------------------------------------------

-- Compare ride duration distributions between annual
-- members and casual riders.

SELECT

    member_casual,

    CASE

        WHEN ride_length_minutes < 5 THEN 'Under 5 min'
        WHEN ride_length_minutes < 10 THEN '5–10 min'
        WHEN ride_length_minutes < 20 THEN '10–20 min'
        WHEN ride_length_minutes < 30 THEN '20–30 min'
        WHEN ride_length_minutes < 60 THEN '30–60 min'
        ELSE '60+ min'

    END AS duration_bucket,

    COUNT(*) AS total_rides,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (
            PARTITION BY member_casual
        ),
        2
    ) AS rider_type_percentage

FROM cyclistic_tripdata_2024_processed

GROUP BY

    member_casual,

    duration_bucket

ORDER BY

    member_casual,

    MIN(ride_length_minutes);
    
-------------------------------------------------------------
-- Monthly and Seasonal Analysis
-------------------------------------------------------------

-- Purpose:
-- Examine monthly and seasonal ride patterns to identify
-- how rider activity varies throughout the year and compare
-- usage trends between annual members and casual riders.
-------------------------------------------------------------

-------------------------------------------------------------
-- Monthly Ride Volume
-------------------------------------------------------------

-- Summarize ride volume for each month.

SELECT

    MONTH(started_at) AS month_number,

    MONTHNAME(started_at) AS month_name,

    COUNT(*) AS total_rides

FROM cyclistic_tripdata_2024_processed

GROUP BY

    MONTH(started_at),

    MONTHNAME(started_at)

ORDER BY

    month_number;
    
-------------------------------------------------------------
-- Monthly Rider Type Distribution
-------------------------------------------------------------

-- Summarize monthly ride counts and the proportion of rides
-- contributed by annual members and casual riders.

SELECT

    MONTH(started_at) AS month_number,

    MONTHNAME(started_at) AS month_name,

    member_casual,

    COUNT(*) AS total_rides,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (
            PARTITION BY MONTH(started_at)
        ),
        2
    ) AS monthly_ride_percentage

FROM cyclistic_tripdata_2024_processed

GROUP BY

    MONTH(started_at),

    MONTHNAME(started_at),

    member_casual

ORDER BY

    month_number,

    member_casual;
    
-------------------------------------------------------------
-- Seasonal Analysis View
-------------------------------------------------------------

-- Create a reusable analytical view that classifies each ride
-- into a season for downstream seasonal analysis.

CREATE OR REPLACE VIEW v_cyclistic_seasonal_analysis AS

SELECT

    *,

    CASE

        WHEN MONTH(started_at) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(started_at) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(started_at) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Autumn'

    END AS season

FROM cyclistic_tripdata_2024_processed;

-------------------------------------------------------------
-- Seasonal Ride Volume
-------------------------------------------------------------

-- Summarize ride volume for each season.

SELECT

    season,

    COUNT(*) AS total_rides

FROM v_cyclistic_seasonal_analysis

GROUP BY

    season

ORDER BY

    FIELD(
        season,
        'Winter',
        'Spring',
        'Summer',
        'Autumn'
    );

-------------------------------------------------------------
-- Seasonal Rider Type Distribution
-------------------------------------------------------------

-- Summarize seasonal ride counts and the proportion of rides
-- contributed by annual members and casual riders.

SELECT

    season,

    member_casual,

    COUNT(*) AS total_rides,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (
            PARTITION BY season
        ),
        2
    ) AS seasonal_ride_percentage

FROM v_cyclistic_seasonal_analysis

GROUP BY

    season,

    member_casual

ORDER BY

    FIELD(
        season,
        'Winter',
        'Spring',
        'Summer',
        'Autumn'
    ),

    member_casual;
    
-------------------------------------------------------------
-- Seasonal Ride Duration
-------------------------------------------------------------

-- Summarize average ride duration for each season and rider
-- type.

SELECT

    season,

    member_casual,

    ROUND(
        AVG(ride_length_minutes),
        2
    ) AS average_ride_duration

FROM v_cyclistic_seasonal_analysis

GROUP BY

    season,

    member_casual

ORDER BY

    FIELD(
        season,
        'Winter',
        'Spring',
        'Summer',
        'Autumn'
    ),

    member_casual;
    
-------------------------------------------------------------
-- Day-of-Week Analysis
-------------------------------------------------------------

-- Purpose:
-- Examine ride patterns across the days of the week to
-- identify how riding behavior varies throughout the week
-- and compare usage trends between annual members and
-- casual riders.
-------------------------------------------------------------

-------------------------------------------------------------
-- Day-of-Week Ride Volume
-------------------------------------------------------------

-- Summarize ride counts for each day of the week.

SELECT

    DAYOFWEEK(started_at) AS day_number,

    DAYNAME(started_at) AS day_name,

    COUNT(*) AS total_rides

FROM cyclistic_tripdata_2024_processed

GROUP BY

    DAYOFWEEK(started_at),

	DAYNAME(started_at)

ORDER BY

    day_number;
    
-------------------------------------------------------------
-- Day-of-Week Rider Distribution
-------------------------------------------------------------

-- Summarize daily ride counts and the proportion of rides
-- contributed by annual members and casual riders.

SELECT

    DAYOFWEEK(started_at) AS day_number,

    DAYNAME(started_at) AS day_name,

    member_casual,

    COUNT(*) AS total_rides,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (
            PARTITION BY DAYOFWEEK(started_at)
        ),
        2
    ) AS daily_ride_percentage

FROM cyclistic_tripdata_2024_processed

GROUP BY

    DAYOFWEEK(started_at),

    DAYNAME(started_at),

    member_casual

ORDER BY

    day_number;
    
-------------------------------------------------------------
-- Day-of-Week Ride Duration
-------------------------------------------------------------

-- Summarize average ride duration for each day of the week
-- by rider type.

SELECT

    DAYOFWEEK(started_at) AS day_number,

    DAYNAME(started_at) AS day_name,

    member_casual,

    ROUND(
        AVG(ride_length_minutes),
        2
    ) AS average_ride_duration

FROM cyclistic_tripdata_2024_processed

GROUP BY

    DAYOFWEEK(started_at),

    DAYNAME(started_at),

    member_casual

ORDER BY

    day_number;
    
-------------------------------------------------------------
-- Weekday vs. Weekend Rider Behavior Comparison
-------------------------------------------------------------

-- Compare ride volume, rider composition, and average ride
-- duration between weekdays and weekends.

SELECT

    CASE

        WHEN DAYOFWEEK(started_at) IN (1,7)
            THEN 'Weekend'

        ELSE 'Weekday'

    END AS day_type,

    member_casual,

    COUNT(*) AS total_rides,

    ROUND(
        AVG(ride_length_minutes),
        2
    ) AS average_ride_duration,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (
            PARTITION BY
                CASE
                    WHEN DAYOFWEEK(started_at) IN (1,7)
                        THEN 'Weekend'
                    ELSE 'Weekday'
                END
        ),
        2
    ) AS ride_percentage

FROM cyclistic_tripdata_2024_processed

GROUP BY

    day_type,

    member_casual

ORDER BY

    FIELD(
        day_type,
        'Weekday',
        'Weekend'
    ),

    member_casual;

-------------------------------------------------------------
-- Hour-of-Day Analysis
-------------------------------------------------------------

-- Purpose:
-- Examine ride patterns throughout the day to identify
-- peak usage hours and compare riding behavior between
-- annual members and casual riders.
-------------------------------------------------------------

-------------------------------------------------------------
-- Peak Riding Hours
-------------------------------------------------------------

-- Summarize overall ride volume for each hour of the day.

SELECT

    hour_of_day,

    COUNT(*) AS total_rides

FROM cyclistic_tripdata_2024_processed

GROUP BY

    hour_of_day

ORDER BY

    total_rides DESC;

-------------------------------------------------------------
-- Hour-of-Day Rider Distribution
-------------------------------------------------------------

-- Summarize hourly ride counts and the proportion of rides
-- contributed by annual members and casual riders.

SELECT

    hour_of_day,

    member_casual,

    COUNT(*) AS total_rides,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (
            PARTITION BY hour_of_day
        ),
        2
    ) AS hourly_ride_percentage

FROM cyclistic_tripdata_2024_processed

GROUP BY

    hour_of_day,

    member_casual

ORDER BY

    hour_of_day,

    member_casual;
    
-------------------------------------------------------------
-- Hour-of-Day Ride Duration
-------------------------------------------------------------

-- Summarize average ride duration for each hour of the day
-- by rider type.

SELECT

    hour_of_day,

    member_casual,

    ROUND(
        AVG(ride_length_minutes),
        2
    ) AS average_ride_duration

FROM cyclistic_tripdata_2024_processed

GROUP BY

    hour_of_day,

    member_casual

ORDER BY

    hour_of_day,

    member_casual;
    
-------------------------------------------------------------
-- Day and Hour Interaction Analysis
-------------------------------------------------------------

-- Purpose:
-- Examine how ride demand varies across both the day of the
-- week and hour of the day to identify temporal riding
-- patterns and compare usage between annual members and
-- casual riders.
-------------------------------------------------------------

-------------------------------------------------------------
-- Day-Hour Ride Volume
-------------------------------------------------------------

-- Summarize overall ride volume for each combination of
-- day of the week and hour of the day.

SELECT

    DAYNAME(ride_date) AS day_name,

    hour_of_day,

    COUNT(*) AS total_rides

FROM cyclistic_tripdata_2024_processed

GROUP BY

    WEEKDAY(ride_date),

    DAYNAME(ride_date),

    hour_of_day

ORDER BY

    WEEKDAY(ride_date),

    hour_of_day;
    
-------------------------------------------------------------
-- Day-Hour Rider Distribution
-------------------------------------------------------------

-- Summarize ride counts and the proportion of rides
-- contributed by annual members and casual riders for
-- each day-hour combination.

SELECT

    DAYNAME(ride_date) AS day_name,

    hour_of_day,

    member_casual,

    COUNT(*) AS total_rides,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (
            PARTITION BY
                WEEKDAY(ride_date),
                DAYNAME(ride_date),
                hour_of_day
        ),
        2
    ) AS ride_percentage

FROM cyclistic_tripdata_2024_processed

GROUP BY

    WEEKDAY(ride_date),

    DAYNAME(ride_date),

    hour_of_day,

    member_casual

ORDER BY

    WEEKDAY(ride_date),

    hour_of_day,

    member_casual;
    
-------------------------------------------------------------
-- Day-Hour Ride Duration
-------------------------------------------------------------

-- Summarize average ride duration for each day-hour
-- combination by rider type.

SELECT

    DAYNAME(ride_date) AS day_name,

    hour_of_day,

    member_casual,

    ROUND(
        AVG(ride_length_minutes),
        2
    ) AS average_ride_duration

FROM cyclistic_tripdata_2024_processed

GROUP BY

    WEEKDAY(ride_date),

    DAYNAME(ride_date),

    hour_of_day,

    member_casual

ORDER BY

    WEEKDAY(ride_date),

    hour_of_day,

    member_casual;
    
-------------------------------------------------------------
-- Bike Type Analysis
-------------------------------------------------------------

-- Purpose:
-- Examine bike type preferences among annual members and
-- casual riders and compare ride duration across different
-- bike types.
-------------------------------------------------------------
-------------------------------------------------------------
-- Bike Type Usage
-------------------------------------------------------------

-- Summarize overall ride volume for each bike type.

SELECT

    rideable_type,

    COUNT(*) AS total_rides

FROM cyclistic_tripdata_2024_processed

GROUP BY

    rideable_type

ORDER BY

    total_rides DESC;
    
-------------------------------------------------------------
-- Bike Type Rider Distribution
-------------------------------------------------------------

-- Summarize ride counts and the proportion of rides
-- contributed by annual members and casual riders for
-- each bike type.

SELECT

    rideable_type,

    member_casual,

    COUNT(*) AS total_rides,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (
            PARTITION BY rideable_type
        ),
        2
    ) AS ride_percentage

FROM cyclistic_tripdata_2024_processed

GROUP BY

    rideable_type,

    member_casual

ORDER BY

    rideable_type,

    member_casual;
    
-------------------------------------------------------------
-- Bike Type Ride Duration
-------------------------------------------------------------

-- Summarize average ride duration for each bike type
-- by rider type.

SELECT

    rideable_type,

    member_casual,

    ROUND(
        AVG(ride_length_minutes),
        2
    ) AS average_ride_duration

FROM cyclistic_tripdata_2024_processed

GROUP BY

    rideable_type,

    member_casual

ORDER BY

    rideable_type,

    member_casual;

-------------------------------------------------------------
-- Station and Location Analysis
-------------------------------------------------------------

-- Purpose:
-- Examine station usage patterns to identify the most
-- popular trip origins and destinations, compare station
-- preferences between annual members and casual riders,
-- and identify the most frequently traveled routes.
-------------------------------------------------------------

-------------------------------------------------------------
-- Most Popular Start Stations
-------------------------------------------------------------

-- Summarize ride volume for the most frequently used
-- start stations.

SELECT

    start_station_name,

    COUNT(*) AS total_rides

FROM cyclistic_tripdata_2024_processed

WHERE start_station_name IS NOT NULL

GROUP BY

    start_station_name

ORDER BY

    total_rides DESC

LIMIT 20;

-------------------------------------------------------------
-- Most Popular End Stations
-------------------------------------------------------------

-- Summarize ride volume for the most frequently used
-- end stations.

SELECT

    end_station_name,

    COUNT(*) AS total_rides

FROM cyclistic_tripdata_2024_processed

WHERE end_station_name IS NOT NULL

GROUP BY

    end_station_name

ORDER BY

    total_rides DESC

LIMIT 20;

-------------------------------------------------------------
-- Start Station Rider Distribution
-------------------------------------------------------------

-- Summarize ride counts and the proportion of rides
-- contributed by annual members and casual riders for
-- the 20 most frequently used start stations.

WITH top_start_stations AS (

    SELECT

        start_station_name,

        COUNT(*) AS total_station_rides

    FROM cyclistic_tripdata_2024_processed

    WHERE start_station_name IS NOT NULL

    GROUP BY

        start_station_name

    ORDER BY

        total_station_rides DESC

    LIMIT 20

)

SELECT

    t.start_station_name,

    p.member_casual,

    COUNT(*) AS total_rides,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (
            PARTITION BY t.start_station_name
        ),
        2
    ) AS ride_percentage

FROM top_start_stations t

JOIN cyclistic_tripdata_2024_processed p

    ON t.start_station_name = p.start_station_name

GROUP BY

    t.start_station_name,

    p.member_casual

ORDER BY

    MAX(t.total_station_rides) DESC,

    p.member_casual;
    
-------------------------------------------------------------
-- End Station Rider Distribution
-------------------------------------------------------------

-- Summarize ride counts and the proportion of rides
-- contributed by annual members and casual riders for
-- the 20 most frequently used end stations.

WITH top_end_stations AS (

    SELECT

        end_station_name,

        COUNT(*) AS total_station_rides

    FROM cyclistic_tripdata_2024_processed

    WHERE end_station_name IS NOT NULL

    GROUP BY

        end_station_name

    ORDER BY

        total_station_rides DESC

    LIMIT 20

)

SELECT

    t.end_station_name,

    p.member_casual,

    COUNT(*) AS total_rides,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (
            PARTITION BY t.end_station_name
        ),
        2
    ) AS ride_percentage

FROM top_end_stations t

JOIN cyclistic_tripdata_2024_processed p

    ON t.end_station_name = p.end_station_name

GROUP BY

    t.end_station_name,

    p.member_casual

ORDER BY

    MAX(t.total_station_rides) DESC,

    p.member_casual;
    
-------------------------------------------------------------
-- Most Popular Routes
-------------------------------------------------------------

-- Summarize ride volume for the most frequently traveled
-- routes between start and end stations.

SELECT

    start_station_name,

    end_station_name,

    COUNT(*) AS total_rides

FROM cyclistic_tripdata_2024_processed

WHERE

    start_station_name IS NOT NULL

    AND end_station_name IS NOT NULL

GROUP BY

    start_station_name,

    end_station_name

ORDER BY

    total_rides DESC,

    start_station_name,

    end_station_name

LIMIT 20;

-------------------------------------------------------------
-- Route Rider Distribution
-------------------------------------------------------------

-- Summarize ride counts and the proportion of rides
-- contributed by annual members and casual riders for
-- the 20 most frequently traveled routes.

WITH top_routes AS (

    SELECT

        start_station_name,

        end_station_name,

        COUNT(*) AS total_route_rides

    FROM cyclistic_tripdata_2024_processed

    WHERE

        start_station_name IS NOT NULL

        AND end_station_name IS NOT NULL

    GROUP BY

        start_station_name,

        end_station_name

    ORDER BY

        total_route_rides DESC

    LIMIT 20

)

SELECT

    t.start_station_name,

    t.end_station_name,

    p.member_casual,

    COUNT(*) AS total_rides,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (
            PARTITION BY
                t.start_station_name,
                t.end_station_name
        ),
        2
    ) AS ride_percentage

FROM top_routes t

JOIN cyclistic_tripdata_2024_processed p

    ON t.start_station_name = p.start_station_name

    AND t.end_station_name = p.end_station_name

GROUP BY

    t.start_station_name,

    t.end_station_name,

    p.member_casual

ORDER BY

    MAX(t.total_route_rides) DESC,

    t.start_station_name,

    t.end_station_name,

    p.member_casual;