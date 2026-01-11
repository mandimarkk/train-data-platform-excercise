WITH stops_bucketed AS (
    SELECT
        station_uic_code,
        timestamp 'epoch' + 600 * floor(extract(epoch from arrival_actual_time) / 600) * interval '1 second'
            as bucket_timestamp,
        dwell_time_minutes,
        arrival_actual_time
    FROM {{ ref('station_stops') }}
    WHERE arrival_actual_time is not null
)
SELECT
    station_uic_code,
    bucket_timestamp,
    count(*) as stop_count,
    avg(dwell_time_minutes) as avg_dwell_minutes,
    extract(isodow from min(arrival_actual_time)) as weekday,  -- min() käytetään, koska sama bucket
FROM stops_bucketed
GROUP BY station_uic_code, bucket_timestamp
ORDER BY station_uic_code, bucket_timestamp