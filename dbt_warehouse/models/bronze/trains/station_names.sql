SELECT
    stationUICCode::INT AS station_uic_code,
    stationName AS station_name,
    stationShortCode AS station_shortcode,
    countryCode AS countrycode
FROM read_json(
    '../data/lake/staging_data/stations.json',
    format='array'
)