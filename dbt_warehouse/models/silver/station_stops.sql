WITH arrivals AS (
    SELECT *
    FROM {{ ref('trains_timetable') }}
    WHERE event_type = 'ARRIVAL'
),

departures AS (
    SELECT *
    FROM {{ ref('trains_timetable') }}
    WHERE event_type = 'DEPARTURE'
)

SELECT
    -- Surrogate key
    {{ dbt_utils.generate_surrogate_key(
        ['a.train_number', 'a.departure_date', 'a.operator_uic_code', 'a.station_uic_code', 'a.scheduled_time']
    ) }} AS sk_station_stop,

    a.train_number,
    a.departure_date,
    a.operator_uic_code,
    a.operator_shortcode,
    a.train_type,
    a.train_category,

    a.station_uic_code,

    -- Arrival
    a.scheduled_time AS arrival_scheduled_time,
    a.actual_time AS arrival_actual_time,
    a.difference_in_minutes AS arrival_delay_min,

    -- Departure
    d.scheduled_time AS departure_scheduled_time,
    d.actual_time AS departure_actual_time,
    d.difference_in_minutes AS departure_delay_min,

    -- Dwell time
    CASE 
        WHEN a.actual_time IS NOT NULL AND d.actual_time IS NOT NULL
        THEN EXTRACT(EPOCH FROM d.actual_time - a.actual_time) / 60.0
        ELSE NULL
    END AS dwell_time_minutes

FROM arrivals a
LEFT JOIN departures d
    ON a.train_number = d.train_number
   AND a.departure_date = d.departure_date
   AND a.operator_uic_code = d.operator_uic_code
   AND a.station_uic_code = d.station_uic_code
   AND d.scheduled_time >= a.scheduled_time