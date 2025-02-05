# **Advanced Flight Delay Analysis**
## **Project Overview**
This project involves advanced SQL analysis on flight delay data to extract key insights into airline performance, airport congestion, and delay patterns. Using PostgreSQL, the analysis covers data cleaning, standardization, performance optimization, and advanced queries to derive meaningful business insights.

## 📂 Dataset
- **Source:**[ U.S. Department of Transportation's On-Time Performance Data](https://transtats.bts.gov/Tables.asp?QO_VQ=EFD&QO_anzr=Nv4yv0r%FDb0-gvzr%FDcr4s14zn0pr%FDQn6n&QO_fu146_anzr=b0-gvzr)
- **Key Features:**
- `Airline Codes`: Unique identifiers for airlines operating the flights.
- `Flight Dates`: The scheduled date of each flight.
- `Departure Delays`: The delay (in minutes) recorded at the time of departure. A positive value indicates a delay, while a negative or zero value means an on-time or early departure.
- `Arrival Delays`: The delay (in minutes) recorded upon arrival at the destination airport.
- `Airport Identifiers`: Unique codes representing the origin and destination airports.
  For a full description of all columns, visit the dataset source [here](https://transtats.bts.gov/Tables.asp?QO_VQ=EFD&QO_anzr=Nv4yv0r%FDb0-gvzr%FDcr4s14zn0pr%FDQn6n&QO_fu146_anzr=b0-gvzr)

## **🛠️ Data Cleaning & Standardization**
- Converted column names to lowercase for consistency.
- Ensured correct data types for date and numerical fields.
- Indexed key columns to improve query performance.

## **🔍 Analysis & Key Insights**
### 1. Monthly Flight Volume
**Query:** Extracted the total number of flights per month using the date_trunc() function.

**Key Finding:** The analysis reveals seasonal fluctuations in flight volume, with peaks in March, July, and May 2024, likely due to increased travel demand. A general upward trend is observed from November 2023 to October 2024, with February showing a dip, possibly due to seasonal factors. These insights help in capacity planning, demand forecasting, and optimizing airline operations. 🚀

### 2. Average Departure Delay by Airline
**Query:** Calculated the average departure delay for each airline.

**Key Finding:**
**AA** and **F9** have the highest average departure delays **(~19 mins)**, while **YX** has the lowest **(~3 mins)**. Low-cost carriers tend to experience higher delays, while legacy airlines show moderate performance. These insights help benchmark airline efficiency and improve scheduling strategies. 🚀

### 3. Busiest Airports(Top 10 by Departure)
**Query:** Identified the airports with the highest number of departures.

**Key Finding:** Origin airport ID **10397** experiences the highest departure volume with **340,381** flights, while ID **14098** has the lowest with just **2** departures, highlighting significant variations in airport traffic.

### 4. Percentage of Flights Delayed More Than 15 Minutes
**Query:**  Counted the total number of flights delayed more than 15 minutes and calculated their percentage.

**Key Finding:**  **1,360,180** flights **(19%)** experienced delays exceeding **15 minutes**, indicating a notable impact on overall punctuality and potential areas for operational improvement.

### 5.Weekly Flight Performance
**Query:**   Created a materialized view aggregating weekly flight performance, including total flights, average departure delay, and average arrival delay per airline.

**Key Finding:**
Flights peak on **Thursday (1.05M)** and dip on **Saturday (906K)**. **Friday** and **Sunday** have the longest departure delays **(14 min)**, while **Tuesday** and **Wednesday** are the most punctual **(10 min)**. Arrival delays follow a similar trend, with **Sunday highest (9 min) and midweek lowest (4 min)**. Weekdays show better on-time performance than weekends.















  


