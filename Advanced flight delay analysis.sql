-- SQL Script for Advanced Flight Delay Analysis
-- Database: flight_data

--VIEW DATA BEFORE ANALYSIS

Select * from large_data;


--  DATA CLEANING & STANDARDIZATION
-- Convert column names to lowercase and ensure proper data types

Do $$
Declare
    col record; -- Declare col as a record variable
Begin
    -- Loop through each column in the table
    For col in
        Select column_name
        From information_schema.columns
        Where table_name = 'airline_data'
    Loop
        -- Rename each column to its lowercase version
        Execute format(
            'ALTER TABLE airline_data RENAME COLUMN %I TO %I',
            col.column_name,
            lower(col.column_name)
        );
    End Loop;
End $$;


Do $$
Declare
    col_exists boolean;
    new_col_exists boolean;
    col jsonb;
    -- Define the JSON array for old and new column names
    old_new_columns jsonb := '[
        {"old": "fl_date", "new": "flight_date"},
        {"old": "op_unique_carrier", "new": "airline"},
        {"old": "origin_airport_id", "new": "origin_airport"},
        {"old": "dest_airport_id", "new": "dest_airport"}
    ]';
Begin
    -- Loop through each column mapping
    For col in select * from jsonb_array_elements(old_new_columns) loop
        -- Check if the old column name exists
        Select exists (
            Select 1
            From information_schema.columns
            Where table_name = 'large_data' and column_name = col->>'old'
        ) into col_exists;

        -- Check if the new column name already exists
        select exists (
            Select 1
            From information_schema.columns
            Where table_name = 'large_data' and column_name = col->>'new'
        ) into new_col_exists;

        -- If the old column exists but the new column name does not, rename
        If col_exists and not new_col_exists then
            Execute format(
                'Aalter table large_data rename column %I to %I',
                col->>'old',
                col->>'new'
            );
        End if;
    End loop;
End $$;


--ADVANCED ANALYSIS QUERIES

-- Totaal flights per month 
Select date_trunc('month', flight_date) as month, count(*) as total_flight_per_month
From large_data
Group by 1
Order by 1;

-- Average departure delay by airline
Select airline, round(avg(dep_delay)::numeric,2) as avg_dep_delay
From large_data
Where dep_delay is not null
Group by airline
Order by avg_dep_delay desc;

-- Busiest airports(Top 10 by departures)
Select origin_airport, count(*) as total_departure_by_airport
From large_data
Group by origin_airport
Order by total_departure_by_airport desc;


-- Create an index on dep_delay for faster filtering
CREATE INDEX IF NOT EXISTS idx_dep_delay ON large_data (dep_delay);

-- Flights Delayed More Than 15 Minutes with Index
SELECT 
    COUNT(*) AS delayed_flights, 
    round(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM large_data)) || '%'AS delay_percentage
FROM large_data
WHERE dep_delay > 15;

--Create materialized view for weekly flight performance 
Drop materialized view if exists weekly_flight_performance;
Create materialized view weekly_flight_performance as
Select 
    Case extract(DOW From flight_date)
        When 0 Then 'Sunday'
        When 1 Then 'Monday'
        When 2 Then 'Tuesday'
        When 3 Then 'Wednesday'
        When 4 Then 'Thursday'
        When 5 Then 'Friday'
        When 6 Then 'Saturday'
    End as day_of_week,
    Count(*) as total_flights,
    round(avg(dep_delay)) as avg_departure_delay,
    round(avg(arr_delay)) as avg_arrival_delay
From large_data
Group by extract(DOW from flight_date)
ORDER BY total_flights desc;
--View the weekly flight performance table
Select * from weekly_flight_performance;

-- Create a materialized view for top delayed airline
Drop materialized view if exists top_delayed_airlines;
Create materialized view top_delayed_airlines as
Select 
    airline,
	count(*) as total_flights,
	round(avg(dep_delay)) as avg_dep_delay
From large_data
where dep_delay is not null
Group by airline
Order by avg_dep_delay desc;
-- view the top delayed airline table
Select * From top_delayed_airlines;

-- function to get delay percentage and total number of flight for an airline
Drop function if exists get_airline_delay_percentage(text);
Create or replace function get_airline_delay_percentage(airline_code text) returns text as $$
Declare
    delay_percentage int;
	total_flights int;
Begin
   -- Get total flights for the airline
   Select count(*)
   Into total_flights
   From large_data
   Where airline = airline_code;


   --Get delay percentage (for flights delayed > 15 minutes)
   Select round(count(*)*100.0/total_flights)
   Into delay_percentage
   From large_data
   Where airline = airline_code and dep_delay > 15;

   --Return formatted result with total flights and percentage
   Return 'Airline:' ||airline_code || '| Total flights:' ||total_flights ||
           '| Delay percentage (>15 min):' || delay_percentage || '%';

End;  
$$ language plpgsql;
--get the delay percentage using the get delay percenatge function
Select get_airline_delay_percentage('AA');


-- Stored procedure to refresh materialized views
Create or replace procedure refresh_materialized_views() as $$
Begin
  Refresh materialized view top_delayed_airlines;
End;
$$ Language plpgsql

--THE END











