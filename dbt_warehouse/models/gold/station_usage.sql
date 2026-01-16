WITH stops_bucketed AS (
    SELECT
        ss.station_uic_code,
        sn.station_name,
        timestamp 'epoch' + 600 * floor(extract(epoch from ss.arrival_actual_time) / 600) * interval '1 second'
            AS bucket_timestamp,
        ss.dwell_time_minutes,
        ss.arrival_actual_time
    FROM {{ ref('station_stops') }} AS ss
    LEFT JOIN {{ ref('station_names') }} AS sn
        ON ss.station_uic_code = sn.station_uic_code
    WHERE ss.arrival_actual_time IS NOT NULL
)

SELECT
    station_uic_code,
    station_name,
    bucket_timestamp,
    COUNT(*) AS stop_count,
    AVG(dwell_time_minutes) AS avg_dwell_minutes,
    EXTRACT(isodow FROM MIN(arrival_actual_time)) AS weekday
FROM stops_bucketed
GROUP BY station_uic_code, station_name, bucket_timestamp
ORDER BY station_uic_code, bucket_timestamp