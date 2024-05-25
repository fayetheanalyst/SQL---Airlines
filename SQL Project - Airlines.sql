SELECT * FROM airlines.airports LIMIT 0,5;
SELECT * FROM airlines.carriers LIMIT 0,5;
SELECT * FROM airlines.flights LIMIT 0,5;

-- check for null values in dataset
SELECT * FROM airlines.flights WHERE (carrier IS NULL) OR (origin IS NULL);

-- check the dataset datatypes 
SHOW INDEXES FROM airlines.flights;

SELECT 
    TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, DATA_TYPE
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    (table_name = 'flights')
        OR (table_name = 'carriers')
        OR (table_name = 'airports');

SELECT 
    a.carrier,
    c.name,
    year,
    COUNT(a.carrier) AS totalFlights,
    COUNT(DISTINCT origin) AS unique_origin_airports,
    COUNT(DISTINCT dest) AS unique_dest_airports
FROM
    airlines.flights a
        LEFT JOIN
    airlines.carriers c ON a.carrier = c.carrier
GROUP BY a.carrier , year
ORDER BY totalFlights DESC , year;

SELECT 
    carrier,
    COUNT(carrier) AS total_Flights,
    COUNT(DISTINCT (origin)) + COUNT(DISTINCT (dest)) AS sum_unique_origin_dest_airports,
    FORMAT((SUM(IF(cancelled = 1, 0, IF(diverted = 1, 0, IF(arr_delay <= 15, 1, 0)))) / COUNT(carrier)) * 100, 4) AS pct_onTimeFlight,
    FORMAT((SUM(IF(arr_delay BETWEEN 16 AND 120, 1, 0)) / COUNT(carrier)) * 100, 4) AS pct_short_DelayedFlights,
    FORMAT((SUM(IF(arr_delay > 120, 1, 0)) / COUNT(carrier)) * 100, 4) AS pct_long_DelayedFlights,
    ROUND(SUM(IF(arr_delay > 15, arr_delay, 0)) / SUM(IF(arr_delay > 15, 1, 0)), 0) AS avg_MinDelayed,
    FORMAT(((SUM(cancelled = 1) / COUNT(carrier)) + (SUM(diverted = 1) / COUNT(carrier))) * 100, 4) AS pct_diverted_canceled
FROM
    airlines.flights
GROUP BY carrier;
-- ORDER BY total_Flights DESC; 

/* based on tableau graph these are the top airlines - I took the top 2-3 airlines from each graph in the dashboard
 1. WN - Southwest airlines - Most flights, lowest percentage of canceled diverted and delayes
 2. DL - Delta Air Lines - Most flights,  number of unique airports, Percentage of timely departure, lowest percentage of canceled diverted and delayes,
 3. OO - SkyWest Airlines -number of unique airports, Percentage of timely departure, 
 4. US - US Airways - Percentage of timely departure,  lowest percentage of canceled diverted and delayes */


SELECT 
    carrier,
    origin,
    dest, year,
    COUNT(carrier) AS total_Flights,
	FORMAT((SUM(IF(cancelled = 1, 0, IF(diverted = 1, 0, IF(arr_delay <= 15, 1, 0)))) / COUNT(carrier)) * 100, 4) AS pct_onTimeFlight,
    FORMAT((SUM(IF(arr_delay > 15, 1, 0)) / COUNT(carrier)) * 100, 4) AS pct_DelayedFlights,
    FORMAT(SUM(IF(arr_delay > 15, arr_delay, 0)) / SUM(IF(arr_delay > 15, 1, 0)), 2) AS avg_MinDelayed,
    FORMAT(((SUM(cancelled = 1) / COUNT(carrier)) + (SUM(diverted = 1) / COUNT(carrier))) * 100, 4) AS pct_diverted_canceled
FROM
    airlines.flights
WHERE
    carrier IN ('WN', 'DL', 'OO', 'US')
GROUP BY carrier , origin , dest, year
LIMIT 0 , 15000;
 

SELECT 
    b.carrier, a.faa, a.name, 
    COUNT(carrier) AS total_Flights,
    a.lat, a.lon
FROM
    airlines.airports a
        INNER JOIN
    airlines.flights b ON a.faa = b.origin
WHERE
    b.carrier IN ('WN', 'DL', 'OO', 'US')
GROUP BY faa;

