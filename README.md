# Telecom Customer Churn Dataset – Data Cleaning with Python

## Project Overview

This project focuses on cleaning a telecom customer churn dataset using Python. The objective is to prepare a clean, consistent, and analysis-ready dataset for further Exploratory Data Analysis (EDA), SQL analysis, Power BI dashboards, and machine learning.

The main focus of this project is not only to remove missing values, but to understand **why values are missing** and clean them using correct business logic.

---

## Business Context

Telecom customer churn data often contains missing values that are meaningful. For example, a customer who has not churned will naturally not have a churn reason. Similarly, a customer with no internet service will not have internet-related service details.

Therefore, instead of deleting rows blindly, this project uses rule-based data cleaning based on telecom business logic.

---

## Dataset Description

The dataset contains customer-level telecom information such as:

- Customer demographics
- Location details
- Phone service information
- Internet service information
- Contract and billing details
- Revenue and charges
- Customer churn status
- Churn category and churn reason

---

## Tools Used

```python
pandas
numpy
```

---

## Data Cleaning Workflow

## 1. Import Required Libraries

```python
import pandas as pd
import numpy as np
```

---

## 2. Load the Dataset

```python
df = pd.read_csv("telecom_customer_churn.csv")
```

Basic inspection:

```python
df.head()
df.shape
df.info()
df.describe()
```

---

## 3. Clean Column Names

Column names were cleaned to make them easier to use in Python.

```python
df.columns = (
    df.columns
    .str.strip()
    .str.lower()
    .str.replace(" ", "_")
)
```

Example:

```text
Customer Status → customer_status
Phone Service → phone_service
Avg Monthly Long Distance Charges → avg_monthly_long_distance_charges
```

---

## 4. Check Duplicate Records

Duplicate rows and duplicate customer IDs were checked.

```python
df.duplicated().sum()
df["customer_id"].duplicated().sum()
```

If duplicates are found, they can be removed using:

```python
df = df.drop_duplicates()
```

---

## 5. Check Missing Values

Missing values were checked using:

```python
df.isna().sum().sort_values(ascending=False)
```

This step helped identify which columns required cleaning.

---

## 6. Handle Churn-Related Missing Values

Columns such as `churn_category` and `churn_reason` are missing for customers who did not churn.

This is not a data error. A customer who stayed or joined does not have a churn reason.

```python
df.loc[
    df["customer_status"].ne("Churned") & df["churn_category"].isna(),
    "churn_category"
] = "Not Churned"

df.loc[
    df["customer_status"].ne("Churned") & df["churn_reason"].isna(),
    "churn_reason"
] = "Not Churned"
```

### Business Logic

If the customer did not churn, then churn reason and churn category are not applicable. Therefore, these missing values are filled with:

```text
Not Churned
```

---

## 7. Handle Phone Service Related Missing Values

Phone-related columns depend on whether the customer has phone service.

Relevant columns:

```text
multiple_lines
avg_monthly_long_distance_charges
```

If `phone_service = 0`, it means the customer does not have phone service.

Therefore:

- `multiple_lines` should be filled as `No Phone Service`
- `avg_monthly_long_distance_charges` should be filled as `0`

```python
df.loc[
    df["phone_service"] == 0,
    "multiple_lines"
] = "No Phone Service"
```

For long distance charges:

```python
df["avg_monthly_long_distance_charges"] = pd.to_numeric(
    df["avg_monthly_long_distance_charges"],
    errors="coerce"
)

df["avg_monthly_long_distance_charges"] = (
    df.groupby("phone_service")["avg_monthly_long_distance_charges"]
      .transform(lambda x: x.fillna(0) if x.name == 0 else x.fillna(x.median()))
)
```

### Business Logic

- If the customer has no phone service, long distance charge is not applicable, so it is filled with `0`.
- If the customer has phone service but the value is missing, it is filled with the median value of customers who have phone service.

---

## 8. Handle Internet Service Related Missing Values

Internet-related columns depend on whether the customer has internet service.

Relevant columns:

```text
internet_type
avg_monthly_gb_download
online_security
online_backup
device_protection_plan
premium_tech_support
streaming_tv
streaming_movies
streaming_music
unlimited_data
```

If a customer has no internet service, then these internet-related services are not applicable.

```python
internet_categorical_cols = [
    "internet_type",
    "online_security",
    "online_backup",
    "device_protection_plan",
    "premium_tech_support",
    "streaming_tv",
    "streaming_movies",
    "streaming_music",
    "unlimited_data"
]

no_internet = df["internet_service"].eq("No")

for col in internet_categorical_cols:
    df.loc[
        no_internet & df[col].isna(),
        col
    ] = "No Internet Service"

df.loc[
    no_internet & df["avg_monthly_gb_download"].isna(),
    "avg_monthly_gb_download"
] = 0
```

### Business Logic

If the customer has no internet service:

- Internet type is not applicable.
- Online services are not applicable.
- Streaming services are not applicable.
- Monthly GB download should be `0`.

---

## 9. Handle Offer Missing Values

If the `offer` column is missing, it means no offer was assigned to that customer.

```python
df["offer"] = df["offer"].fillna("No Offer")
```

### Business Logic

Missing offer values are not treated as unknown. They are treated as customers who did not receive any offer.

---

## 10. Convert Numeric Columns

Important numeric columns were converted to numeric data types.

```python
numeric_cols = [
    "age",
    "number_of_dependents",
    "number_of_referrals",
    "tenure_in_months",
    "avg_monthly_long_distance_charges",
    "avg_monthly_gb_download",
    "monthly_charge",
    "total_charges",
    "total_refunds",
    "total_extra_data_charges",
    "total_long_distance_charges",
    "total_revenue"
]

for col in numeric_cols:
    df[col] = pd.to_numeric(df[col], errors="coerce")
```

---

## 11. Final Missing Value Check

After applying the cleaning rules, missing values were checked again.

```python
df.isna().sum().sort_values(ascending=False)
```

The goal is to make sure all important missing values are handled properly.

---

## 12. Create Useful Cleaned Features

### Churn Flag

```python
df["churn_flag"] = df["customer_status"].apply(
    lambda x: 1 if x == "Churned" else 0
)
```

### Tenure Group

```python
def tenure_group(months):
    if months <= 6:
        return "0-6 months"
    elif months <= 12:
        return "7-12 months"
    elif months <= 24:
        return "13-24 months"
    elif months <= 48:
        return "25-48 months"
    else:
        return "49+ months"

df["tenure_group"] = df["tenure_in_months"].apply(tenure_group)
```

### Monthly Charge Band

```python
def charge_band(charge):
    if charge < 30:
        return "<30"
    elif charge < 60:
        return "30-60"
    elif charge < 90:
        return "60-90"
    else:
        return "90+"

df["monthly_charge_band"] = df["monthly_charge"].apply(charge_band)
```

### Senior Customer Flag

```python
df["is_senior_customer"] = df["age"].apply(
    lambda x: 1 if x >= 60 else 0
)
```

---

## 13. Save the Cleaned Dataset

The cleaned dataset was saved as a CSV file.

```python
df.to_csv("telecom_customer_churn_cleaned.csv", index=False)
```

---

## Key Data Cleaning Decisions

| Column/Area | Problem | Cleaning Action |
|---|---|---|
| `churn_category` | Missing for non-churned customers | Filled with `Not Churned` |
| `churn_reason` | Missing for non-churned customers | Filled with `Not Churned` |
| `multiple_lines` | Missing when no phone service | Filled with `No Phone Service` |
| `avg_monthly_long_distance_charges` | Missing when no phone service | Filled with `0` |
| `avg_monthly_long_distance_charges` | Missing when phone service exists | Filled with group median |
| Internet service columns | Missing when no internet service | Filled with `No Internet Service` |
| `avg_monthly_gb_download` | Missing when no internet service | Filled with `0` |
| `offer` | Missing when no offer was given | Filled with `No Offer` |

---

## Final Output

The final cleaned dataset is saved as:

```text
telecom_customer_churn_cleaned.csv
```

This cleaned file can be used for:

- Exploratory Data Analysis
- SQL practice
- Power BI dashboard creation
- Machine learning model building
- Business analytics case study

---

## Project Folder Structure

```text
telecom-customer-churn-data-cleaning/
│
├── data/
│   ├── telecom_customer_churn.csv
│   └── telecom_customer_churn_cleaned.csv
│
├── scripts/
│   └── data_cleaning.py
│
├── notebooks/
│   └── data_cleaning.ipynb
│
├── README.md
└── requirements.txt
```

---

## How to Run

### 1. Install dependencies

```bash
pip install pandas numpy
```

### 2. Run the cleaning script

```bash
python scripts/data_cleaning.py
```

---

## Conclusion

This project demonstrates how to clean a real-world telecom churn dataset using Python and business logic.

The main learning from this cleaning process is that missing values should not always be removed. Some missing values are meaningful and must be interpreted based on the context of the business.

This project shows skills in:

- Data understanding
- Missing value analysis
- Business-rule-based cleaning
- Data type correction
- Feature engineering
- Preparing clean data for analytics and machine learning
