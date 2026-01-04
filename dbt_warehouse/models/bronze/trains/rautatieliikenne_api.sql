WITH trains AS (

SELECT *
FROM read_json(
  '../data/lake/staging_data/*.json',
  format="array",
  columns={
    trainNumber: 'BIGINT NULL',
    departureDate: 'DATE NULL',
    operatorUICCode: 'BIGINT NULL',
    operatorShortCode: 'VARCHAR NULL',
    trainType: 'VARCHAR NULL',
    trainCategory: 'VARCHAR NULL',
    commuterLineID: 'VARCHAR NULL',
    runningCurrently: 'BOOLEAN NULL',
    cancelled: 'BOOLEAN NULL',
    version: 'BIGINT NULL',
    timetableType: 'VARCHAR NULL',
    timetableAcceptanceDate: 'VARCHAR NULL',
    timeTableRows: 'JSON[] NULL'
  })
),

surrogate_key_added AS (
  SELECT 
    concat_ws('|',
    coalesce(CAST(trainNumber AS VARCHAR), 'missing'),
    coalesce(CAST(departureDate AS VARCHAR), 'missing'),
    coalesce(CAST(operatorUICCode AS VARCHAR), 'missing')
    ) AS train_date_operator,
    *
  FROM trains
)


SELECT *
FROM surrogate_key_added