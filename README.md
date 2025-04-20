This project presents a data-driven case study conducted for **BrightTV**, aimed at providing insights to support the company's strategic goal: **growing its subscription base** in the current financial year. The study was commissioned by the CEO and is intended to support the **Customer Value Management (CVM)** team by uncovering **usage trends, consumption drivers, and content opportunities**.

Project Objective:

To help BrightTV grow its subscription base by:
- Understanding **user demographics and viewing behavior**
- Identifying **factors that influence consumption**
- Recommending **content strategies** for low-consumption periods
- Proposing **initiatives** to attract and retain users

---

Tools & Technologies:
- **SQL (Snowflake)** for data cleaning, transformation, and analysis
- Excel for analysis
- Timezone Conversion: `CONVERT_TIMEZONE`, `TO_TIMESTAMP`
- Conditional Logic: `CASE` statements
- Aggregation: `GROUP BY`, `COUNT`, `SUM`, `DATE_PART`
- Time Buckets, Age Groups, Date Extraction

---

Datasets Used:
-'user_profiles'
-'viewership'

Data cleaning and preparation:

Steps performed:
- Replaced null or invalid values (e.g., gender = 'None') with `'other'`
- Joined user profile data with viewership data via `user_id`
- Converted timestamps from **UTC** to **South African Standard Time (SAST)**
- Extracted **Time** and **Date** components from timestamps
- Identified and removed duplicate records
- Created derived fields:
  - `age_group` (Kids, Teenagers, Early/Mid/Mature Adults, Seniors)
  - `time_bucket` (Late Night, Morning, Afternoon, Evening)
    
I have attached document with my methodoly
