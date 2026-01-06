WITH unnested AS (
  SELECT 
    train_date_operator,
    trainNumber as train_number,
    departureDate as departure_date,
    operatorUICCode as operator_uic_code,
    operatorShortCode as operator_shortcode,
    trainType as train_type,
    trainCategory as train_category,
    commuterLineID as commuter_line_id,
    --runningCurrently,
    cancelled,
    --version,
    timetableType as timetable_type,
    timetableAcceptanceDate as timetable_acceptance,
    unnest(timeTableRows) as timetable_row
  FROM {{ ref('rautatieliikenne_api') }}
),

defined AS (
  SELECT
  * EXCLUDE (timetable_row),

  -- String fields
  json_extract_string(timetable_row, '$.stationShortCode') as station_shortcode,
  json_extract_string(timetable_row, '$.countryCode') as countrycode,
  json_extract_string(timetable_row, '$.type') as event_type,
  json_extract_string(timetable_row, '$.commercialTrack') as track_id,

  -- Typed fields
  json_extract(timetable_row, '$.stationUICCode')::INT as station_uic_code,
  json_extract(timetable_row, '$.differenceInMinutes')::INT as difference_in_minutes,
  json_extract(timetable_row, '$.trainStopping')::BOOLEAN as train_stopping,
  json_extract(timetable_row, '$.scheduledTime')::DATETIME as scheduled_time,
  json_extract(timetable_row, '$.actualTime')::DATETIME as actual_time,

  -- Nested fields
  json_extract(timetable_row, '$.causes')::JSON[] as causes
  
  FROM unnested
)

SELECT 
    {{ dbt_utils.generate_surrogate_key(
        ['train_date_operator', 'station_uic_code', 'event_type', 'scheduled_time']
    ) }} as sk_train_timetable,
  * EXCLUDE (train_date_operator)
FROM defined