# Cyclistic Analysis Report
**By:** Roger Gomez

**Date:** April 4, 2025

**Project Context:**
This report analyze the data from Cyclistic dataset to get insights about the difference between **casual** and **member** customer.

## Introduction
This report analyzes the period time from 2024-Feb to 2025-Feb data from Bike-Share Company operating in Chicago. The primary objective of the analysis is to identify and understand the differences in riding behaviors between two distinct user groups: **members** and **casuals** riders.By examining key metrics such as total number of rides and bike type usage across both groups, this report aims to uncover patterns that can inform Cyclistic's marketing strategy. Understranding how each rider type intereacts with the service —such as their most-used bike types—can help Cyclistic make data-driven decision to increase annual memberships and improve user experience for both existing and potential customers.

## Analysis Process
Great! Let's begin with our analysing process. I've got a Cyclistic dataset from 2024-FEB to 2025-FEB.

### Trips Over The Time
Let's start to see the total trips that have been made by riders along that time.

---

```sql
      SELECT 
        COUNT(*) AS total_rides
      FROM Cyclistic_data ;
```
---
| Total Trips | 
|:-------------|
| 5,916,546 | 

---
In total, It have been done **5,916,546.** trips. Now, let's how many trips have been done per each category of customers.

---
```sql
    SELECT 
    member_casual,
    COUNT(ride_id) AS Trips
    FROM Cyclistic_data
    GROUP BY member_casual;
```
---
| Member_casual |Trips|
|:------------- |-----|
| member| 3,783,918|
|casual | 2,132,628|



```python

```
