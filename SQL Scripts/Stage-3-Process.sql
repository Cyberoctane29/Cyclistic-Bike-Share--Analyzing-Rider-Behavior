/*
===============================================================================
Project     : Cyclistic Rider Behavior Analysis
Framework   : APPASA
Stage       : Process
Script      : process_stage.sql

Description :
Imports the twelve monthly Divvy trip datasets for 2024 into MySQL, consolidates
them into a single dataset, performs data validation, data cleaning, post-data 
cleaning data quality verification, feature engineering, and post-feature engineering 
data quality verification, and prepares the final processed dataset for downstream 
analysis (analyze stage) and dashboard development (share stage).

Author      : Saswat Seth
===============================================================================
*/

-------------------------------------------------------------
-- Project Setup
-------------------------------------------------------------

-- Purpose:
-- Initialize the project environment by creating the
-- database and raw table used throughout the ELT process.
-------------------------------------------------------------

------------------------------------------------------
-- Create the project database
------------------------------------------------------

CREATE DATABASE IF NOT EXISTS cyclistic_tripdata;

------------------------------------------------------
-- Set the project database as the active schema
------------------------------------------------------

USE cyclistic_tripdata;

------------------------------------------------------------
-- Create the raw data table for the 2024 trip dataset
------------------------------------------------------------

CREATE TABLE cyclistic_tripdata_2024_raw (

    ride_id VARCHAR(255),

    rideable_type VARCHAR(50),

    started_at DATETIME,

    ended_at DATETIME,

    start_station_name VARCHAR(255),

    start_station_id VARCHAR(50),

    end_station_name VARCHAR(255),

    end_station_id VARCHAR(50),

    start_lat DOUBLE,

    start_lng DOUBLE,

    end_lat DOUBLE,

    end_lng DOUBLE,

    member_casual VARCHAR(20)

);

-------------------------------------------------------------
-- Data Ingestion
-------------------------------------------------------------

-- Purpose:
-- Import the twelve monthly Divvy trip datasets for 2024
-- into the raw table while preserving the source data
-- exactly as received.
--
-- This section loads the raw CSV files.
-------------------------------------------------------------

-------------------------------------------------------------
-- January 2024
-------------------------------------------------------------

LOAD DATA LOCAL INFILE
'C:/Users/saswa/Desktop/DA projects/Python Projects/Cyclistic Rider Behavior Analysis Project/Project Data/Raw Data/202401-divvy-tripdata.csv'
INTO TABLE cyclistic_tripdata_2024_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-------------------------------------------------------------
-- February 2024
-------------------------------------------------------------

LOAD DATA LOCAL INFILE
'C:/Users/saswa/Desktop/DA projects/Python Projects/Cyclistic Rider Behavior Analysis Project/Project Data/Raw Data/202402-divvy-tripdata.csv'
INTO TABLE cyclistic_tripdata_2024_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-------------------------------------------------------------
-- March 2024
-------------------------------------------------------------

LOAD DATA LOCAL INFILE
'C:/Users/saswa/Desktop/DA projects/Python Projects/Cyclistic Rider Behavior Analysis Project/Project Data/Raw Data/202403-divvy-tripdata.csv'
INTO TABLE cyclistic_tripdata_2024_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-------------------------------------------------------------
-- April 2024
-------------------------------------------------------------

LOAD DATA LOCAL INFILE
'C:/Users/saswa/Desktop/DA projects/Python Projects/Cyclistic Rider Behavior Analysis Project/Project Data/Raw Data/202404-divvy-tripdata.csv'
INTO TABLE cyclistic_tripdata_2024_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-------------------------------------------------------------
-- May 2024
-------------------------------------------------------------

LOAD DATA LOCAL INFILE
'C:/Users/saswa/Desktop/DA projects/Python Projects/Cyclistic Rider Behavior Analysis Project/Project Data/Raw Data/202405-divvy-tripdata.csv'
INTO TABLE cyclistic_tripdata_2024_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-------------------------------------------------------------
-- June 2024
-------------------------------------------------------------

LOAD DATA LOCAL INFILE
'C:/Users/saswa/Desktop/DA projects/Python Projects/Cyclistic Rider Behavior Analysis Project/Project Data/Raw Data/202406-divvy-tripdata.csv'
INTO TABLE cyclistic_tripdata_2024_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-------------------------------------------------------------
-- July 2024
-------------------------------------------------------------

LOAD DATA LOCAL INFILE
'C:/Users/saswa/Desktop/DA projects/Python Projects/Cyclistic Rider Behavior Analysis Project/Project Data/Raw Data/202407-divvy-tripdata.csv'
INTO TABLE cyclistic_tripdata_2024_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-------------------------------------------------------------
-- August 2024
-------------------------------------------------------------

LOAD DATA LOCAL INFILE
'C:/Users/saswa/Desktop/DA projects/Python Projects/Cyclistic Rider Behavior Analysis Project/Project Data/Raw Data/202408-divvy-tripdata.csv'
INTO TABLE cyclistic_tripdata_2024_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-------------------------------------------------------------
-- September 2024
-------------------------------------------------------------

LOAD DATA LOCAL INFILE
'C:/Users/saswa/Desktop/DA projects/Python Projects/Cyclistic Rider Behavior Analysis Project/Project Data/Raw Data/202409-divvy-tripdata.csv'
INTO TABLE cyclistic_tripdata_2024_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-------------------------------------------------------------
-- October 2024
-------------------------------------------------------------

LOAD DATA LOCAL INFILE
'C:/Users/saswa/Desktop/DA projects/Python Projects/Cyclistic Rider Behavior Analysis Project/Project Data/Raw Data/202410-divvy-tripdata.csv'
INTO TABLE cyclistic_tripdata_2024_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-------------------------------------------------------------
-- November 2024
-------------------------------------------------------------

LOAD DATA LOCAL INFILE
'C:/Users/saswa/Desktop/DA projects/Python Projects/Cyclistic Rider Behavior Analysis Project/Project Data/Raw Data/202411-divvy-tripdata.csv'
INTO TABLE cyclistic_tripdata_2024_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-------------------------------------------------------------
-- December 2024
-------------------------------------------------------------

LOAD DATA LOCAL INFILE
'C:/Users/saswa/Desktop/DA projects/Python Projects/Cyclistic Rider Behavior Analysis Project/Project Data/Raw Data/202412-divvy-tripdata.csv'
INTO TABLE cyclistic_tripdata_2024_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-------------------------------------------------------------
-- Data Validation
---------------------------------------------------------------

-- Purpose:
-- Assess the integrity, completeness, and consistency of the
-- raw dataset before cleaning, feature engineering, and
-- creating the processed analytical table.
-------------------------------------------------------------
-------------------------------------------------------------
-- Validation Index
-------------------------------------------------------------

-- Index Optimization

-- Create a non-unique index on ride_id to improve the
-- performance of validation queries.
--
-- The index does not enforce uniqueness and therefore
-- preserves the ability to detect duplicate ride IDs.

CREATE INDEX idx_ride_id
ON cyclistic_tripdata_2024_raw (ride_id);

-- Verify that the ride_id index was created successfully

SHOW INDEXES
FROM cyclistic_tripdata_2024_raw;

-------------------------------------------------------------
-- Dataset Structure
-------------------------------------------------------------

-- Validate the total number of imported records

SELECT
    COUNT(*) AS total_rows
FROM cyclistic_tripdata_2024_raw;

-- Verify the raw table schema

DESCRIBE cyclistic_tripdata_2024_raw;

-------------------------------------------------------------
-- Uniqueness
-------------------------------------------------------------

-- Check for NULL ride IDs

SELECT
    COUNT(*) AS null_ride_ids
FROM cyclistic_tripdata_2024_raw
WHERE ride_id IS NULL;

-- Check for blank ride IDs

SELECT
    COUNT(*) AS blank_ride_ids
FROM cyclistic_tripdata_2024_raw
WHERE TRIM(ride_id) = '';

-- Count the number of duplicate ride IDs

SELECT
    COUNT(*) AS duplicate_ride_ids
FROM (
    SELECT
        ride_id
    FROM cyclistic_tripdata_2024_raw
    GROUP BY ride_id
    HAVING COUNT(*) > 1
) AS duplicates;

-- Check for duplicate ride IDs

SELECT
    ride_id,
    COUNT(*) AS duplicate_count
FROM cyclistic_tripdata_2024_raw
GROUP BY ride_id
HAVING COUNT(*) > 1;

-- Inspect records for a duplicate ride ID

-- Timestamp-Variant Duplicate Pattern

-- Inspect duplicate records with a one-second difference in
-- the ended_at timestamp.

SELECT *
FROM cyclistic_tripdata_2024_raw
WHERE ride_id = '011C8EF97AB0F30D';

-- Exact Duplicate Pattern

-- Inspect records that are exact duplicates across all
-- dataset columns.

SELECT *
FROM cyclistic_tripdata_2024_raw
WHERE ride_id = '0354FD0756337B59';

-------------------------------------------------------------
-- Missing Values
-------------------------------------------------------------

-- Count blank station names and station IDs

SELECT
    SUM(TRIM(start_station_name) = '') AS blank_start_station_names,
    SUM(TRIM(start_station_id) = '') AS blank_start_station_ids,
    SUM(TRIM(end_station_name) = '') AS blank_end_station_names,
    SUM(TRIM(end_station_id) = '') AS blank_end_station_ids
FROM cyclistic_tripdata_2024_raw;

-- Count records with zero-valued coordinates

SELECT
    SUM(start_lat = 0) AS zero_start_lat,
    SUM(start_lng = 0) AS zero_start_lng,
    SUM(end_lat = 0) AS zero_end_lat,
    SUM(end_lng = 0) AS zero_end_lng
FROM cyclistic_tripdata_2024_raw;

-------------------------------------------------------------
-- Categorical Consistency
-------------------------------------------------------------

-- Inspect rideable_type values

SELECT
    rideable_type,
    COUNT(*) AS record_count
FROM cyclistic_tripdata_2024_raw
GROUP BY rideable_type
ORDER BY record_count DESC;

-- Inspect member_casual values

SELECT
    member_casual,
    COUNT(*) AS record_count
FROM cyclistic_tripdata_2024_raw
GROUP BY member_casual
ORDER BY record_count DESC;

-------------------------------------------------------------
-- Temporal Consistency
-------------------------------------------------------------

-- Identify records with missing timestamps

SELECT
    SUM(started_at IS NULL) AS null_started_at,
    SUM(ended_at IS NULL) AS null_ended_at
FROM cyclistic_tripdata_2024_raw;

-- Identify trips that end before they start

SELECT
    COUNT(*) AS trips_ending_before_start
FROM cyclistic_tripdata_2024_raw
WHERE ended_at < started_at;

-- Inspect records with invalid timestamp order

SELECT *
FROM cyclistic_tripdata_2024_raw
WHERE ended_at < started_at
LIMIT 10;

-- Summarize the range of negative ride durations

SELECT
    MIN(TIMESTAMPDIFF(SECOND, started_at, ended_at)) AS minimum_duration_seconds,
    MAX(TIMESTAMPDIFF(SECOND, started_at, ended_at)) AS maximum_duration_seconds
FROM cyclistic_tripdata_2024_raw
WHERE ended_at < started_at;

-------------------------------------------------------------
-- Ride Duration
-------------------------------------------------------------

-- Count trips with zero ride duration

SELECT
    COUNT(*) AS zero_duration_trips
FROM cyclistic_tripdata_2024_raw
WHERE TIMESTAMPDIFF(SECOND, started_at, ended_at) = 0;

-- Count trips longer than 24 hours

SELECT
    COUNT(*) AS rides_over_24_hours
FROM cyclistic_tripdata_2024_raw
WHERE TIMESTAMPDIFF(
    SECOND,
    started_at,
    ended_at
) > 86400;

-- Inspect unusually long rides

SELECT *
FROM cyclistic_tripdata_2024_raw
WHERE TIMESTAMPDIFF(
    SECOND,
    started_at,
    ended_at
) > 86400
LIMIT 10;

-------------------------------------------------------------
-- Geographic Values
-------------------------------------------------------------

-- Identify records with invalid latitude values

SELECT
    SUM(start_lat NOT BETWEEN -90 AND 90) AS invalid_start_lat,
    SUM(end_lat NOT BETWEEN -90 AND 90) AS invalid_end_lat
FROM cyclistic_tripdata_2024_raw;

-- Identify records with invalid longitude values

SELECT
    SUM(start_lng NOT BETWEEN -180 AND 180) AS invalid_start_lng,
    SUM(end_lng NOT BETWEEN -180 AND 180) AS invalid_end_lng
FROM cyclistic_tripdata_2024_raw;

-- Assess overlap between zero-valued destination coordinates
-- and rides exceeding 24 hours

SELECT
    COUNT(*) AS zero_coordinate_records,
    SUM(
        TIMESTAMPDIFF(
            SECOND,
            started_at,
            ended_at
        ) > 86400
    ) AS also_over_24_hours
FROM cyclistic_tripdata_2024_raw
WHERE end_lat = 0
  AND end_lng = 0;
  
-------------------------------------------------------------
-- Data Cleaning
-------------------------------------------------------------

-- Purpose:
-- Clean the validated raw dataset by correcting,
-- standardizing, and filtering records that do not meet
-- analytical quality requirements.
--
-- The raw staging table remains unchanged throughout this
-- process.
-------------------------------------------------------------

------------------------------------------------------------
-- Create the processed data table for the 2024 trip dataset
------------------------------------------------------------

CREATE TABLE cyclistic_tripdata_2024_processed (

    ride_id VARCHAR(255),

    rideable_type VARCHAR(50),

    started_at DATETIME,

    ended_at DATETIME,

    start_station_name VARCHAR(255),

    start_station_id VARCHAR(50),

    end_station_name VARCHAR(255),

    end_station_id VARCHAR(50),

    start_lat DOUBLE,

    start_lng DOUBLE,

    end_lat DOUBLE,

    end_lng DOUBLE,

    member_casual VARCHAR(20)

);

-------------------------------------------------------------
-- Populate Processed Table
-------------------------------------------------------------

-- Apply all data cleaning rules while loading records from
-- the raw staging table into the processed table

INSERT INTO cyclistic_tripdata_2024_processed (

    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual

)

WITH

-- -------------------------------------------------------------
-- Duplicate Records
-- -------------------------------------------------------------

-- Retain one record for each ride_id

deduplicated_rides AS (

    SELECT

        *,
        ROW_NUMBER() OVER (
            PARTITION BY ride_id
            ORDER BY ended_at DESC
        ) AS rn

    FROM cyclistic_tripdata_2024_raw

),

-- -------------------------------------------------------------
-- Missing Values
-- -------------------------------------------------------------

-- Standardize blank station fields and zero-valued
-- destination coordinates

cleaned_rides AS (

    SELECT

        ride_id,
        rideable_type,
        started_at,
        ended_at,

        NULLIF(UPPER(TRIM(start_station_name)), '') AS start_station_name,

		NULLIF(UPPER(TRIM(start_station_id)), '') AS start_station_id,

		NULLIF(UPPER(TRIM(end_station_name)), '') AS end_station_name,

		NULLIF(UPPER(TRIM(end_station_id)), '') AS end_station_id,

        start_lat,
        start_lng,

        NULLIF(end_lat, 0) AS end_lat,

        NULLIF(end_lng, 0) AS end_lng,

        member_casual,
        rn

    FROM deduplicated_rides

)

-- -------------------------------------------------------------
-- Temporal Cleaning
-- -------------------------------------------------------------

SELECT

    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual

FROM cleaned_rides

WHERE rn = 1

    AND ended_at > started_at

    AND TIMESTAMPDIFF(
        SECOND,
        started_at,
        ended_at
    ) <= 86400;

-------------------------------------------------------------
-- Data Quality Verification
-------------------------------------------------------------

-- Purpose:
-- Verify that the data cleaning rules applied to the
-- processed dataset successfully resolved the data quality
-- issues identified during validation.
-------------------------------------------------------------

-------------------------------------------------------------
-- Part A: Post-Cleaning Verification
-------------------------------------------------------------

-------------------------------------------------------------
-- Dataset Reconciliation
-------------------------------------------------------------

-- Compare raw and processed row counts

SELECT

    (SELECT COUNT(*)
     FROM cyclistic_tripdata_2024_raw) AS raw_record_count,

    (SELECT COUNT(*)
     FROM cyclistic_tripdata_2024_processed) AS processed_record_count;

-- Calculate the total number of records excluded during data cleaning

SELECT

    (SELECT COUNT(*)
     FROM cyclistic_tripdata_2024_raw)
    -
    (SELECT COUNT(*)
     FROM cyclistic_tripdata_2024_processed)

    AS excluded_record_count;
    
-------------------------------------------------------------
-- Uniqueness
-------------------------------------------------------------

-- Verify that no duplicate ride_id values remain

SELECT
    ride_id,
    COUNT(*) AS record_count
FROM cyclistic_tripdata_2024_processed
GROUP BY ride_id
HAVING COUNT(*) > 1;

-- Enforce ride_id uniqueness with a primary key constraint

ALTER TABLE cyclistic_tripdata_2024_processed
ADD PRIMARY KEY (ride_id);

-------------------------------------------------------------
-- Missing Value Standardization
-------------------------------------------------------------

-- Verify that no blank station names and station IDs remain

SELECT
    SUM(TRIM(start_station_name) = '') AS blank_start_station_names,
    SUM(TRIM(start_station_id) = '') AS blank_start_station_ids,
    SUM(TRIM(end_station_name) = '') AS blank_end_station_names,
    SUM(TRIM(end_station_id) = '') AS blank_end_station_ids
FROM cyclistic_tripdata_2024_processed;

-- Count station names and station IDs standardized as NULL

SELECT
    SUM(start_station_name IS NULL) AS null_start_station_names,
    SUM(start_station_id IS NULL) AS null_start_station_ids,
    SUM(end_station_name IS NULL) AS null_end_station_names,
    SUM(end_station_id IS NULL) AS null_end_station_ids
FROM cyclistic_tripdata_2024_processed;

-------------------------------------------------------------
-- Spatial Standardization
-------------------------------------------------------------

-- Verify that no zero-valued destination coordinates remain

SELECT
    SUM(end_lat = 0) AS zero_end_lat,
    SUM(end_lng = 0) AS zero_end_lng
FROM cyclistic_tripdata_2024_processed;

-- Count destination coordinates standardized as NULL

SELECT
    SUM(end_lat IS NULL) AS null_end_lat,
    SUM(end_lng IS NULL) AS null_end_lng
FROM cyclistic_tripdata_2024_processed;

-------------------------------------------------------------
-- Temporal Integrity
-------------------------------------------------------------

-- Verify that no negative or zero-duration rides remain

SELECT
    SUM(ended_at < started_at) AS negative_duration_rides,
    SUM(ended_at = started_at) AS zero_duration_rides
FROM cyclistic_tripdata_2024_processed;

-- Verify that no rides exceeding 24 hours remain

SELECT
    COUNT(*) AS rides_over_24_hours
FROM cyclistic_tripdata_2024_processed
WHERE TIMESTAMPDIFF(
    SECOND,
    started_at,
    ended_at
) > 86400;

-------------------------------------------------------------
-- Feature Engineering
-------------------------------------------------------------

-- Purpose:
-- Create reusable ride-level analytical features from the
-- cleaned processed dataset to support downstream analysis
-- and business intelligence.
--
-- Dashboard-specific classifications and aggregations are
-- handled separately in Power BI.
-------------------------------------------------------------

-------------------------------------------------------------
-- Ride Duration
-------------------------------------------------------------

-- Add the ride_length_minutes column to the processed table

ALTER TABLE cyclistic_tripdata_2024_processed
ADD COLUMN ride_length_minutes DECIMAL(10, 2);

-- Temporarily disable safe update mode for the full-table update

SET SQL_SAFE_UPDATES = 0;

-- Calculate ride_length_minutes from the exact duration between started_at and ended_at

UPDATE cyclistic_tripdata_2024_processed
SET ride_length_minutes =
    ROUND(
        TIMESTAMPDIFF(
            SECOND,
            started_at,
            ended_at
        ) / 60.0,
        2
    );

-------------------------------------------------------------
-- Ride Date
-------------------------------------------------------------

-- Add a column to store the calendar date on which each ride started

ALTER TABLE cyclistic_tripdata_2024_processed
ADD COLUMN ride_date DATE;

-- Derive ride_date from the date component of started_at

UPDATE cyclistic_tripdata_2024_processed
SET ride_date = DATE(started_at);

-------------------------------------------------------------
-- Ride Start Hour
-------------------------------------------------------------

-- Add a column to store the hour of the day at which each ride started

ALTER TABLE cyclistic_tripdata_2024_processed
ADD COLUMN hour_of_day TINYINT;

-- Derive hour_of_day from the hour component of started_at

UPDATE cyclistic_tripdata_2024_processed
SET hour_of_day = HOUR(started_at);

-- Re-enable safe update mode after the full-table update

SET SQL_SAFE_UPDATES = 1;

-------------------------------------------------------------
-- Data Quality Verification
-------------------------------------------------------------

-- Purpose:
-- Verify that the engineered analytical features were
-- successfully created and contain valid values derived
-- from the cleaned processed dataset.
-------------------------------------------------------------

-------------------------------------------------------------
-- Part B: Post-Feature Engineering Verification
-------------------------------------------------------------

-------------------------------------------------------------
-- Ride Duration
-------------------------------------------------------------

-- Verify that ride_length_minutes was populated for all
-- records

SELECT
    COUNT(*) AS total_records,
    SUM(ride_length_minutes IS NULL) AS null_ride_lengths
FROM cyclistic_tripdata_2024_processed;

-- Verify that ride_length_minutes remains within the
-- validated temporal boundaries

SELECT
    MIN(ride_length_minutes) AS minimum_ride_length,
    MAX(ride_length_minutes) AS maximum_ride_length
FROM cyclistic_tripdata_2024_processed;

-------------------------------------------------------------
-- Ride Date
-------------------------------------------------------------

-- Verify that ride_date was populated for all records

SELECT
    COUNT(*) AS total_records,
    SUM(ride_date IS NULL) AS null_ride_dates
FROM cyclistic_tripdata_2024_processed;

-- Verify that ride_date matches the date component of
-- started_at

SELECT
    COUNT(*) AS mismatched_ride_dates
FROM cyclistic_tripdata_2024_processed
WHERE ride_date <> DATE(started_at);

-------------------------------------------------------------
-- Ride Start Hour
-------------------------------------------------------------

-- Verify that hour_of_day was populated for all records

SELECT
    COUNT(*) AS total_records,
    SUM(hour_of_day IS NULL) AS null_hour_values
FROM cyclistic_tripdata_2024_processed;

-- Verify that hour_of_day matches the hour component of
-- started_at

SELECT
    COUNT(*) AS mismatched_hour_values
FROM cyclistic_tripdata_2024_processed
WHERE hour_of_day <> HOUR(started_at);

-------------------------------------------------------------
-- Process Stage Complete
-------------------------------------------------------------

-- The verified processed dataset is ready for downstream
-- analysis and dashboard development in the Analyze and
-- Share stages.