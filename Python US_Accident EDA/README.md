Top learning Outcomes
High missing data columns can distort analysis if not handled.

Accidents cluster around certain cities/states—possibly due to population or infrastructure.

Temporal patterns show peak accidents during morning/evening rush hours.

Weekend vs. weekday timing patterns differ, highlighting behavioral impacts.

Dataset Overview
The dataset contains accident records from across the United States.

Initial inspection (df.info()) reveals:

Several columns have missing values.

Date-time fields are stored as strings and were converted to datetime.

It includes geographical (City, State, Start_Lat, Start_Lng), time-based (Start_Time, End_Time), and environmental (Weather_Condition, Visibility, etc.) variables.

Missing Values Analysis
Significant missing data was found in these columns:

Wind_Chill(F) - >50% missing

Precipitation(in) - >50% missing

End_Lat and End_Lng - highly incomplete

Finding: These columns could be dropped or imputed, depending on their relevance to downstream tasks.

Actionable Insight: For modeling or reporting, consider excluding these columns or replacing them with defaults or flags.

Accident Distribution by City
Top 20 cities show a heavily skewed distribution, indicating that:

Accidents are highly concentrated in certain urban areas (e.g., Los Angeles, Houston).

Many cities reported only 1–5 accidents.

Finding: This long-tail distribution suggests potential underreporting in smaller areas or a true difference in urban vs rural accident density.

Visualization: Bar chart of top 20 cities and histogram of accident counts across all cities (log-scaled).

State-Level Accident Summary
Grouping accidents by both City and State, then aggregating by State shows:

Top 5 states with the most accidents include California, Texas, Florida, North Carolina, and New York.

Finding: These are high-population and high-traffic states. Good candidates for targeted road safety initiatives.

Temporal Patterns in Accidents
Morning (7–9 AM) and Evening (4–6 PM) peaks are visible.

These correlate strongly with commute times.

Finding: Time-of-day is a critical factor in accident probability.

Day of Week
Weekdays (Mon–Fri) have significantly higher accident counts than weekends.

Finding: Weekday traffic density contributes to a higher accident rate.

Weekday vs Weekend Patterns
Separate filtering shows different distributions for:

Weekend accidents: More spread out throughout the day.

Weekday accidents: Clustered during peak hours.

nsight: Weekday driving is more predictable, while weekend driving is more erratic (e.g., leisure trips, late-night driving).

Single-Accident Cities
Over 1,000 cities reported only one accident.