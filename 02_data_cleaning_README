# Telecom Customer Churn Analysis — Data Cleaning

## Project Phase

This document explains the second phase of the Telecom Customer Churn Analytics project: **Data Cleaning**.

The purpose of this phase is to convert the raw telecom customer churn dataset into a clean, structured, and business-ready dataset that can be used for Python EDA, MySQL analysis, DAX measures, and Power BI dashboard development.

This phase follows a professional analytics workflow where cleaning decisions are based on business logic instead of random deletion or blind imputation.

---

## Business Context

Customer churn is a critical business problem for telecom companies because it directly affects recurring revenue, customer lifetime value, retention cost, and future growth.

Before analyzing churn patterns or building dashboards, the dataset must be cleaned properly. Incorrect cleaning can lead to misleading churn rates, wrong revenue calculations, and poor business recommendations.

For example, missing values in internet-related columns may not mean data entry errors. They may mean that the customer does not use internet service. Similarly, missing churn reasons for active customers do not indicate a problem; they simply mean the customer has not churned.

Therefore, this cleaning phase focuses on preserving business meaning while preparing the dataset for analysis.

---

## Objective of Data Cleaning

The main objectives of this phase are:

- Standardize column names for easier use in Python, SQL, and Power BI.
- Remove duplicate records if present.
- Handle missing values using business logic.
- Correct data types for identifiers, categorical variables, and numerical fields.
- Create business-friendly flags for churn, service usage, offers, and customer status.
- Create customer segments for tenure, age, monthly charge, and revenue value.
- Validate revenue-related fields.
- Export a clean CSV file for the next stages of the project.

---

## Dataset Used

The raw dataset used in this phase is:

```text
telecom_customer_churn.csv
```

The cleaned output file generated from this phase is:

```text
telecom_customer_churn_cleaned.csv
```

---

## Tools Used

- Python
- Pandas
- NumPy
- Regex
- Pathlib
- Jupyter Notebook

---

## Notebook File

```text
02_data_cleaning.ipynb
```

This notebook focuses only on cleaning and preparing the dataset. Deep EDA, SQL analysis, DAX modeling, and Power BI dashboarding are handled in later phases.

---

## Cleaning Workflow

### 1. Importing Required Libraries

The notebook begins by importing libraries required for data loading, cleaning, transformation, and file handling.

Libraries used:

- `pandas` for data manipulation
- `numpy` for numerical operations
- `re` for column name standardization
- `pathlib` for file path handling

---

### 2. Loading the Raw Dataset

The raw CSV file is loaded into a Pandas DataFrame.

A separate raw copy is created using:

```python
df_raw = df.copy()
```

This ensures that the original dataset remains unchanged and can be referenced later if needed.

---

### 3. Missing Value Audit Before Cleaning

Before applying any cleaning, the notebook checks:

- Which columns contain missing values
- Missing value count by column
- Missing value percentage by column

This step is important because missing values must be interpreted before they are filled or removed.

---

### 4. Column Name Standardization

Original column names may contain spaces, capital letters, or special characters.

For example:

```text
Customer ID
Monthly Charge
Customer Status
```

These are converted into clean `snake_case` names:

```text
customer_id
monthly_charge
customer_status
```

This makes the dataset easier to use across Python, SQL, and Power BI.

---

### 5. Text Cleaning

Leading and trailing spaces are removed from all text columns.

This prevents category duplication caused by hidden spaces.

For example:

```text
"Yes"
" Yes"
"Yes "
```

All should be treated as the same value.

---

### 6. Duplicate Row Check

The notebook checks for fully duplicated rows.

If duplicate rows exist, they are removed because they can inflate:

- Customer count
- Churn rate
- Revenue values
- Segment-level analysis

---

### 7. Duplicate Customer ID Check

Because this is a customer-level dataset, each customer should appear only once.

The notebook checks duplicate values in:

```text
customer_id
```

If duplicate customer IDs are found, only the first valid record is kept.

---

## Missing Value Treatment

The missing values are handled based on business logic.

---

### 8. Offer Column Cleaning

Missing values in the offer column are filled with:

```text
No Offer
```

### Business Reason

A missing offer value likely means the customer did not receive any offer. Filling it as `No Offer` makes the column more useful for offer-performance analysis.

---

### 9. Phone-Service-Related Cleaning

If a customer does not have phone service, phone-related missing values are not data errors.

For customers where:

```text
phone_service = No
```

The following cleaning is applied:

| Column | Fill Value |
|---|---|
| multiple_lines | No Phone Service |
| avg_monthly_long_distance_charges | 0 |

### Business Reason

A customer without phone service cannot have multiple lines or long-distance phone charges.

For customers with phone service but missing long-distance charges, the median charge of phone-service users is used as a safe fallback.

---

### 10. Internet-Service-Related Cleaning

If a customer does not have internet service, internet-related missing values are not errors.

For customers where:

```text
internet_service = No
```

The following internet-related columns are filled with:

```text
No Internet Service
```

Affected columns include:

- internet_type
- online_security
- online_backup
- device_protection_plan
- premium_tech_support
- streaming_tv
- streaming_movies
- streaming_music
- unlimited_data

The numeric column below is filled with `0`:

```text
avg_monthly_gb_download
```

### Business Reason

A customer without internet service cannot have internet type, online security, streaming service, online backup, or data usage.

For customers with internet service but missing internet-related values, categorical columns are marked as `Unknown`, and missing GB download values are filled using the median of internet-service users.

---

### 11. Churn Category and Churn Reason Cleaning

For customers who did not churn, missing churn category and churn reason values are filled with:

```text
Not Churned
```

### Business Reason

A customer who stayed or recently joined the company should not have a churn reason.

For churned customers with missing churn category or reason, the values are filled with:

```text
Unknown Churn Category
Unknown Churn Reason
```

This avoids deleting churned customers while still preserving data quality transparency.

---

## Data Type Correction

### 12. Identifier Columns

The following columns are converted to string:

```text
customer_id
zip_code
```

### Business Reason

These columns are identifiers, not mathematical values. They should not be used for numerical calculations.

---

### 13. Integer Columns

The following columns are converted to integer type:

- age
- number_of_dependents
- number_of_referrals
- tenure_in_months
- total_extra_data_charges

---

### 14. Float Columns

The following columns are converted to float type:

- latitude
- longitude
- avg_monthly_long_distance_charges
- avg_monthly_gb_download
- monthly_charge
- total_charges
- total_refunds
- total_long_distance_charges
- total_revenue

---

## Data Quality Checks

### 15. Negative Value Check

The notebook checks all numerical columns for negative values.

If negative values appear in billing-related columns such as `monthly_charge`, they are not automatically removed.

### Business Reason

Negative billing values may represent:

- Refunds
- Credits
- Billing corrections
- Discounts
- Adjustments

Instead of deleting them, a flag column is created.

---

## Feature Creation for Business Analysis

New columns are created to make the dataset easier to analyze in SQL, Power BI, and DAX.

---

### 16. Customer Status Flags

| New Column | Meaning |
|---|---|
| is_churned | 1 if customer churned, else 0 |
| is_stayed | 1 if customer stayed, else 0 |
| is_joined | 1 if customer recently joined, else 0 |
| is_existing_customer | 1 if customer is not newly joined |

These flags make churn rate, retention rate, and customer status calculations easier.

---

### 17. Service and Offer Flags

| New Column | Meaning |
|---|---|
| has_phone_service | 1 if customer has phone service |
| has_internet_service | 1 if customer has internet service |
| has_offer | 1 if customer received an offer |
| is_month_to_month | 1 if customer has month-to-month contract |
| monthly_charge_is_negative | 1 if monthly charge is negative |

These flags are useful for segmentation, filtering, and dashboard KPIs.

---

### 18. Customer Segmentation Columns

The notebook creates business-friendly grouping columns.

#### Tenure Group

Customers are grouped into tenure bands:

- 0-6 Months
- 7-12 Months
- 13-24 Months
- 25-36 Months
- 37-48 Months
- 49-60 Months
- 61-72 Months

### Business Use

This helps identify whether churn is higher among new, mid-tenure, or long-tenure customers.

---

#### Age Group

Customers are grouped into age bands:

- 19-25
- 26-35
- 36-45
- 46-55
- 56-65
- 66-80

### Business Use

This helps compare churn behavior across age groups.

---

#### Monthly Charge Group

Customers are grouped by monthly billing amount:

- <=25
- 26-50
- 51-75
- 76-100
- 100+

### Business Use

This helps identify whether high-paying customers are more likely to churn.

---

#### Revenue Value Segment

Customers are divided into four revenue-value segments:

- Low Value
- Medium Value
- High Value
- Very High Value

### Business Use

This allows the business to prioritize retention efforts for high-value customers.

---

## Business Logic Validation

After cleaning, the notebook validates important business rules.

### Phone Service Validation

Checks whether customers without phone service are correctly marked as:

```text
No Phone Service
```

### Internet Service Validation

Checks whether customers without internet service are correctly marked as:

```text
No Internet Service
```

### Churn Reason Validation

Checks whether non-churned customers are correctly marked as:

```text
Not Churned
```

---

## Revenue Formula Validation

The notebook validates the total revenue field using the formula:

```text
Total Revenue = Total Charges + Total Long Distance Charges + Total Extra Data Charges - Total Refunds
```

This step checks whether the revenue columns are internally consistent.

Temporary validation columns are removed after the check.

---

## Final Output

After cleaning, the final dataset should contain:

| Metric | Expected Result |
|---|---:|
| Rows | 7,043 |
| Missing Values | 0 |
| Duplicate Rows | 0 |
| Duplicate Customer IDs | 0 |
| Cleaned Output File | telecom_customer_churn_cleaned.csv |

The number of columns increases because new business flags and segmentation columns are added.

---

## Cleaning Summary

A cleaning summary table is created and saved as:

```text
data_cleaning_summary.csv
```

This summary documents:

- Cleaning step
- Business reason behind each step

This file is useful for GitHub documentation and interview explanation.

---

## Key Cleaning Decisions

| Data Issue | Cleaning Decision | Business Reason |
|---|---|---|
| Missing offer | Filled with `No Offer` | Customer likely did not receive an offer |
| Missing phone-related fields | Filled based on phone service status | No phone service means no phone-related usage |
| Missing internet-related fields | Filled based on internet service status | No internet service means internet fields are not applicable |
| Missing churn reason for active customers | Filled with `Not Churned` | Active customers do not have churn reasons |
| Missing churn reason for churned customers | Filled with `Unknown Churn Reason` | Preserve churned customers without losing information |
| Customer ID / Zip Code as numbers | Converted to string | These are identifiers, not numerical variables |
| Negative monthly charge | Flagged, not deleted | May represent credit, refund, or adjustment |
| Tenure, age, charge, revenue | Converted into groups | Supports business segmentation and dashboards |

---

## Skills Demonstrated

This phase demonstrates the following skills:

- Data quality assessment
- Business-rule-based missing value handling
- Duplicate detection
- Data type correction
- Feature engineering for BI analysis
- Customer segmentation
- Revenue validation
- SQL and Power BI readiness
- Clean documentation for GitHub
- Professional analytics workflow

---

## Interview Explanation

A strong way to explain this cleaning phase in an interview:

> I did not blindly drop missing values. I first studied the business meaning behind them. For example, missing internet-related fields were mostly linked to customers without internet service, so I filled those values as `No Internet Service` instead of treating them as errors. Similarly, missing churn reasons for stayed or joined customers were filled as `Not Churned`. I also created churn flags, service flags, tenure groups, age groups, monthly charge groups, and revenue value segments to make the dataset ready for SQL, DAX, and Power BI analysis.

---

## Next Phase

The next phase of the project is:

```text
03_eda_business_analysis.ipynb
```

This phase will focus on deep business EDA, including:

- Churn overview
- Revenue leakage analysis
- Contract-level churn analysis
- Internet service churn analysis
- Fiber optic customer churn
- Tenure-based churn risk
- High-value customer churn
- Churn reason deep dive
- Offer effectiveness analysis
- Customer segmentation
- Business recommendations

---

## Project Positioning

This data cleaning phase is part of a job-focused analytics project designed for roles such as:

- Data Analyst
- Business Intelligence Analyst
- Product Analyst
- Customer Insights Analyst
- Revenue Analyst
- Analytics Engineer Associate

The project is designed to show that the analyst can not only write Python code but also understand the business meaning behind data quality issues and prepare data for decision-making.
