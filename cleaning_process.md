# Cyclistic Data Cleaning & Transformation Report

**By**: Roger Gomez  
**Date**: March 25, 2025
**Project Context**:
   
   This report details the process of cleaning and transfoming the Cyclistic bike-share dataset, wich includes ride data from February 2024 to February 2025. The main objective is clean the data for further analysis of rider behavior, focusing on identifiying patters between annual members and casual riders.


 
  
## Introduction
   
This dataset contains information on bike rides recorded over a one-year period. The primary objective of cleaning and transforming the data is to ensure its accuracy and reliability, which are crucial for conducting meaningful analysis and uncovering valuable insights. Once cleaned, the dataset will help identify trends and patterns in rider behavior, offering a clearer understanding of how customers engage with the company’s services. Proper data cleaning plays a vital role in this process, as it eliminates inconsistencies, corrects errors, and addresses missing values—ultimately leading to more trustworthy and actionable results.

## WORKING WITH DUPLICATE VALUES

Let's work with the ride_id. Since, ride_id is the best candidate for a "Primary Key", because it represents a unique identifier of the rides. Let's see if this columns has duplicates.

---
```sql
SELECT ride_id, COUNT(*) AS time_repeated
FROM cyclistic_data
GROUP BY ride_id
HAVING COUNT(*) > 1;

```
---
This query shows me if a row is repeated more than once in the column "ride_id".
**The input shows that there are 211 duplicated rows.**

Knowing this, my idea is remove the duplicates and covert the "ride_id" is the primary key.

---

For removing the duplicate let's run the next **WINDOWS FUNCTION and creating a CTE:**

---
``` sql

WITH Duplicates AS (
    SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY ride_id) AS rn
    FROM cyclistic_data
)
DELETE FROM Duplicates
WHERE rn > 1;

```
---

The windows function allows me to assing a unique number `"ROW_NUMBER"` and `"PARTITION"` BY `"ride_id"` group the rows.
Finally, with DELETE `WHERE rn > 1`, I am just keeping only the first occurrence of each cases (ride_id).


Before, to create the primary key, let's check if the columns "ride_id" has any NULLs value. Because If it has NULLs value, I could not use the "ride_id" column as a primary key. In the case, the "ride_id" columns contains NULLS values. I'll need to remove them. Then, create a primary key.

---

```sql

SELECT *
FROM cyclistic_data_cleaned
WHERE ride_id IS NULL;

```
---
GREAT! It appears the columns does not have any NULLs value. But, we need to explicitly change the column definition to NOT NULL, since SQL server is still allowing "ride_id" column to be nullable. If that happens I could not create the primary key.

To change the definition to "NOT NULL", let's run this query:

---

```sql

ALTER TABLE cyclistic_data_cleaned
ALTER COLUMN ride_id VARCHAR(50) NOT NULL;

``` 
---

Then, let's create the primary key:

---

```sql

ALTER TABLE cyclistic_data_clean
ADD CONSTRAINT pk_ride PRIMARY KEY (ride_id);

```

---

I used the ADD CONSTRAINT command to add new constrain to the table and "pk_ride" is the name of this constrain. 
"PRIMARY KEY" command that works as a constrain, it enforces uniqueness and prevent Nulls value in the "ride_id" column.

---

GREAT, we almost done with this part. The last step is to confirm that the "ride_id" column definitely does not have any duplicate values, let's run the very first query again:

---

```sql

SELECT ride_id, COUNT(*) AS time_repeated
FROM cyclistic_data
GROUP BY ride_id
HAVING COUNT(*) > 1;
```
---

Finally, let's see if SQL Server recognizes the "ride_id" column as a primary key:

---

```sql

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'cyclistic_data'
  AND CONSTRAINT_NAME = 'PK_ride';

```
The input show the "ride_id" in COLUMN_NAME.
Great news, the ride_id is primary key.


## WORKING WITH THE NULLS-VALUES FOR EACH COLUMNS 

First, I want to see which columns has NUlls values and how many nulls values it has. I figure out an efficient way to do that. Let's create a Dynamic SQL Query:

```sql

DECLARE @nulls NVARCHAR(MAX) = '';

```
**EXPLANATION:**

`"DECLARE  @nulls NVARCHAR(MAX)` = ' ';"  "DECLARE" commands for declaring our variable and type.
"NVARCHAR(MAX)" because this dynamic query could generate very long queries.

---
```sql

SELECT @nulls = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS column_name, COUNT(*) - COUNT(' + COLUMN_NAME + ') AS null_count FROM cyclistic_data', 
    ' UNION ALL ')  									
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'cyclistic_data'; 

```
---
**EXPLANATION:**

We use quotes so SQL treats column names as text values, not actual columns.

`"+ COLUMN_NAME +"`  Adds the column name dynamically.

`"STRING_AGG"` is essential in this case because we're dynamically generating multiple SELECT statements—one for each column in the "cyclistic_data" table.

`"FROM INFORMATION_SCHEMA.COLUMNS "` Lists all columns from all tables in our dataset (Cyclistic)

Filters it only for the People table

---

```sql

SET @nulls = 'SELECT * FROM (' + @nulls + ') AS subquery ORDER BY null_count DESC;';

EXEC sp_executesql @nulls;

```

---

**EXPLANATION:**

`"+ NULLS +"` we use it to concatenate the dynamically generated SQL query (stored in nulls) into a larger SQL string.
It's the same concept as a + COLUMN_NAME +.

We used this line as a trick to order the results in DESC. Becasue, in dynamic SQL, you can't directly add ORDER BY to STRING_AGG() because it works at the column level.

---

```sql

EXEC sp_executesql @nulls; 

```

---

**EXPLANATION: **

Execute the dynamically generated query

---

Great, the input shows that we have Nulls value for the next columns:

end_station_id, end_station_name, start_station_name, start_station_id, end_lng and end_lat.


After analyze the context of the columns I decided to keep the Nulls value to preserves the integrity of the data. I don't want to make wrong assumptions on my analysis.

---


## **WORKING WITH INCORRECT OR INACCURATE DATA***

Let's work with: `Start_ lat`, `start_lng`, `end_lat` and `end_lng` columns, since our company operates in Chicago, we need to be sure that these columns are not out of range.

've looked for the approximately boundaries of Chicago:

`start_lat` and `end_lat` are within 41.6° and 42.1° (the latitude range for Chicago).

 `start_lng` and `end_lng` are within -88.0° and -87.5° (the longitude range for Chicago).

So, if I've got values beyond of that specific boundaries that means this data is out of the range of Chicago.

According to me, the best approach is remove these rows. Doing that I protect the integrity of my data.

---
```sql

DELETE FROM cyclistic_data
WHERE end_lat < 41.6 OR end_lat > 42.1
   OR end_lng < -88.0 OR end_lng > -87.5
   OR start_lat < 41.6 OR start_lat > 42.1
   OR start_lng < -88.0 OR start_lng > -87.5;
```
---

**129 rows were affected.** That confirms that I had 129 inaccurate rows. Doing this I can be sure that my values are inside of Chicago.

---

Another important thing to do is make sure that the `rideable_type` and `member_casual` columns have only the correct categories.

The `rideable_type` column only has three categories: classic_bike, electric_scooter, electric_bike

and `member_casual` column has two categories: casual and member

Let's run this query to make sure there's not  more categories than there should are

---

```sql

SELECT 
	DISTINCT(rideable_type)
	
FROM cyclistic_data ;

```


```sql

SELECT 
	DISTINCT(member_casual)
	
FROM cyclistic_data ;

```

Great! Everything looks great!

---

Finally, let's work with `started_at` and `ended_at` columns 


Let's validate the Date Format for these columns, let's run this simple query:

---

```sql


SELECT TOP 10 started_at, ended_at
FROM cyclistic_data;

```

---

According to the input, the format looks great, let's continue.


Let's check if there's a case where the `ended_at` is before than the `started_at`. It's suppose that a ride should not end before it starts.


Let's run this query:

---

```sql

SELECT 
started_at, ended_at 
FROM cyclistic_data
WHERE ended_at < started_at

```
---
I've got 207 where this scenario is happening in my dataset. So, I should to remove this rows.

---
Let's run:

---

```sql

DELETE FROM cyclistic_data
WHERE ended_at < started_at ;	

```
---
Great. Now, let's run this query to confirme that I've already eliminated this rows

---

```sql
SELECT 
	COUNT(*)
FROM cyclistic_data
WHERE ended_at < started_at

```
---

Great! the input shows 0 rows.

---

Also, I want to remove those case that the rides are extremely long or short. 

A ride that only was less than a minute is not useful for my analysis and a ride more than 24 hours is unrealistic.
So, let's run this query:

---

```sql

DELETE FROM cyclistic_data
WHERE DATEDIFF(MINUTE, started_at, ended_at) < 1
   OR DATEDIFF(HOUR, started_at, ended_at) > 24;

```
---

Great! Our table is cleand and ready to go ! 

---




















```python

```
