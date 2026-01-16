---
title: Train station usage
---

On this page, you can see 
- the busiest stations on a chosen date 
- select a station to see the timeline of train stops at that station on that date.

## Select date to see the busiest stations

<DateInput 
    name=selected_date 
    data={station_usage_base} 
    dates=usage_date 
    title="Select date" 
/>


```sql station_usage_base
select
    station_name,
    bucket_timestamp::date as usage_date,
    sum(stop_count) as total_stops
from warehouse.station_usage
group by station_name, usage_date
```

```sql filtered_station_usage
select
    station_name,
    total_stops
from ${station_usage_base}
where usage_date = '${inputs.selected_date.value}'
order by total_stops desc
limit 10
```

<BarChart 
    data={filtered_station_usage} 
    x=station_name 
    y=total_stops 
    xAxisTitle="Station" 
    yAxisTitle="Number of stops" 
/>

## Select station to see train stops by time

```sql station_list
select distinct
    station_name
from warehouse.station_usage
where bucket_timestamp::date = '${inputs.selected_date.value}'
order by station_name
```


<Dropdown 
    data={station_list} 
    name=selected_station 
    value=station_name
    title="Select station"
/>

### Train stops (10 minute buckets)

```sql station_usage_timeline
select
    bucket_timestamp,
    stop_count
from warehouse.station_usage
where
    station_name = '${inputs.selected_station.value}'
    and bucket_timestamp::date = '${inputs.selected_date.value}'
order by bucket_timestamp
```

<BarChart
    data={station_usage_timeline}
    x=bucket_timestamp
    y=stop_count
    xAxisTitle="Time"
    yAxisTitle="Number of stops"
/>

### Train stops (1 hour buckets)

```sql station_usage_hourly
select
    station_name,
    date_trunc('hour', bucket_timestamp) as hour_bucket,
    sum(stop_count) as stop_count
from warehouse.station_usage
where
    station_name = '${inputs.selected_station.value}'
    and bucket_timestamp::date = '${inputs.selected_date.value}'
group by station_name, hour_bucket
order by hour_bucket
```

<BarChart
    data={station_usage_hourly}
    x=hour_bucket
    y=stop_count
    xAxisTitle="Hour"
    yAxisTitle="Number of stops"
/>

### Train stops per weekday

```sql station_usage_weekday
select
    weekday,
    sum(stop_count) as total_stops
from warehouse.station_usage
where station_name = '${inputs.selected_station.value}'
group by weekday
order by weekday
```

<BarChart
    data={station_usage_weekday}
    x=weekday
    y=total_stops
    xAxisTitle="Weekday (1=Monday, 7=Sunday)"
    yAxisTitle="Number of stops"
/>