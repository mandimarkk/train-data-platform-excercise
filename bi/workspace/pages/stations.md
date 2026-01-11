---
title: Train station usage
---

```select_asterisk
select * from warehouse.station_usage
```



<BarChart 
    data={select_asterisk} 
    x=weekday 
    y=stop_count
    xAxisTitle="Time bucket"
    yAxisTitle="Train visits"
/>



