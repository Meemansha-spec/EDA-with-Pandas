# Telecom Customer Churn Analysis – EDA with Python

## Project Overview

This project focuses on performing **Exploratory Data Analysis (EDA)** on a telecom customer churn dataset using Python. The goal is to understand customer behavior, clean the dataset using business logic, identify churn patterns, and generate insights that can help a telecom company reduce customer churn and protect revenue.

Customer churn is one of the most important problems in subscription-based businesses. By analyzing customer demographics, services used, contract type, payment method, tenure, revenue, and churn reasons, this project aims to answer:

> Why are customers leaving, which customers are at risk, and what business actions can reduce churn?

---

## Business Problem

Telecom companies lose significant revenue when customers discontinue services. Instead of only looking at overall churn, this analysis focuses on understanding churn from multiple business angles:

- Which customer segments have the highest churn?
- Does contract type influence churn?
- Are high monthly charges linked to churn?
- Do customers with internet services churn more?
- Which churn reasons cause the highest revenue loss?
- Which customers should be targeted first for retention campaigns?

---

## Dataset Description

The dataset contains customer-level telecom information, including:

- Customer demographics
- Location details
- Tenure and referral information
- Phone service usage
- Internet service usage
- Contract and billing details
- Charges, refunds, and revenue
- Customer churn status
- Churn category and churn reason

### Target Column

The main target column is:

```python
customer_status
```

It contains customer status such as:

```text
Stayed
Churned
Joined
```

For churn analysis, a new binary column was created:

```python
churn_flag
```

Where:

```text
1 = Churned
0 = Not Churned
```

---

## Tools and Libraries Used

```python
pandas
numpy
matplotlib
seaborn
```

Optional libraries for advanced analysis:

```python
plotly
scikit-learn
```

---

## Project Workflow

## 1. Data Loading

The dataset was loaded using Pandas:

```python
import pandas as pd

df = pd.read_csv("telecom_customer_churn.csv")
```

Initial checks were performed:

```python
df.head()
df.shape
df.info()
df.describe()
df.columns
```

---

## 2. Column Name Cleaning

Column names were cleaned for easier analysis.

```python
df.columns = (
    df.columns
    .str.strip()
    .str.lower()
    .str.replace(" ", "_")
)
```

This makes the dataset easier to work with in Python.

Example:

```text
Customer Status → customer_status
Monthly Charge → monthly_charge
Internet Service → internet_service
```

---

## 3. Duplicate Check

Duplicate records were checked at both row level and customer ID level.

```python
df.duplicated().sum()
df["customer_id"].duplicated().sum()
```

Result:

```text
No duplicate rows were found.
No duplicate customer IDs were found.
```

---

## 4. Missing Value Analysis

Missing values were not removed blindly. Each missing value was understood from a business perspective.

```python
df.isna().sum().sort_values(ascending=False)
```

Some missing values were meaningful, not incorrect.

For example:

- `churn_reason` is missing for customers who did not churn.
- `churn_category` is missing for customers who did not churn.
- `internet_type` is missing for customers with no internet service.
- `multiple_lines` is missing for customers with no phone service.

---

## 5. Missing Value Treatment Using Business Logic

### Churn Category and Churn Reason

For customers who did not churn, missing churn category and churn reason were filled as:

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

Business logic:

A customer who has not churned cannot have a churn reason. Therefore, missing values here do not mean data error.

---

### Phone Service Related Missing Values

If a customer has no phone service, then phone-related fields are not applicable.

```python
no_phone = df["phone_service"].eq(0)

df.loc[no_phone, "multiple_lines"] = "No Phone Service"
df.loc[no_phone, "avg_monthly_long_distance_charges"] = 0
```

For customers with phone service, missing long distance charges were filled using the median of that group:

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

Business logic:

- If phone service is not available, long distance charge should be `0`.
- If phone service is available but the value is missing, median imputation is more appropriate than deleting the row.

---

### Internet Service Related Missing Values

If a customer has no internet service, then internet-related fields are not applicable.

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
    df.loc[no_internet & df[col].isna(), col] = "No Internet Service"

df.loc[
    no_internet & df["avg_monthly_gb_download"].isna(),
    "avg_monthly_gb_download"
] = 0
```

Business logic:

A customer with no internet service should not have internet type, online backup, streaming services, or monthly GB usage.

---

## 6. Data Type Correction

Numeric columns were converted to proper numeric format.

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

## 7. Feature Engineering

New business-friendly features were created.

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

## 8. Univariate Analysis

Univariate analysis was performed to understand individual columns.

Examples:

```python
df["customer_status"].value_counts()
df["contract"].value_counts()
df["internet_type"].value_counts()
df["payment_method"].value_counts()
```

Numeric summaries:

```python
df[numeric_cols].describe()
```

---

## 9. Bivariate Analysis With Churn

Churn rate was analyzed across important business dimensions.

### Churn by Contract

```python
contract_churn = (
    df.groupby("contract")["churn_flag"]
    .mean()
    .sort_values(ascending=False) * 100
)
```

### Churn by Tenure Group

```python
tenure_churn = df.groupby("tenure_group")["churn_flag"].mean() * 100
```

### Churn by Internet Type

```python
internet_churn = (
    df.groupby("internet_type")["churn_flag"]
    .mean()
    .sort_values(ascending=False) * 100
)
```

### Churn by Payment Method

```python
payment_churn = (
    df.groupby("payment_method")["churn_flag"]
    .mean()
    .sort_values(ascending=False) * 100
)
```

---

## 10. Revenue Analysis

Revenue impact of churn was analyzed.

```python
lost_revenue = df.loc[
    df["customer_status"] == "Churned",
    "total_revenue"
].sum()
```

Average revenue by customer status:

```python
df.groupby("customer_status")[[
    "monthly_charge",
    "total_charges",
    "total_revenue",
    "total_refunds"
]].mean()
```

---

## 11. Churn Reason Analysis

Top churn reasons were identified.

```python
df[df["customer_status"] == "Churned"]["churn_reason"].value_counts()
```

Revenue loss by churn reason:

```python
churn_reason_revenue = (
    df[df["customer_status"] == "Churned"]
    .groupby("churn_reason")["total_revenue"]
    .sum()
    .sort_values(ascending=False)
)
```

---

## Key Insights

### 1. Month-to-Month Customers Have Higher Churn

Customers on month-to-month contracts show higher churn compared to one-year and two-year contracts.

Business interpretation:

Month-to-month customers are easier to lose because they have lower commitment and can switch quickly when competitors provide better offers.

---

### 2. Low-Tenure Customers Are More Likely to Churn

Customers in early tenure groups have a higher churn rate.

Business interpretation:

The company should focus on onboarding experience and first 3–6 months customer engagement.

---

### 3. Fiber Optic Customers Show Higher Churn

Fiber optic users have higher churn compared to other internet types.

Business interpretation:

This may be due to higher monthly charges, service expectations, technical issues, or better competitor alternatives.

---

### 4. Payment Method Is Associated With Churn

Certain payment methods show higher churn rates.

Business interpretation:

Payment method may not directly cause churn, but it can be linked to customer segment, contract type, or billing experience.

---

### 5. Churn Reasons Are Often Competitor-Driven

Common churn reasons include competitor offers, better devices, more data, and better download speeds.

Business interpretation:

The company should monitor competitor pricing, device bundles, and data plans.

---

## Business Recommendations

### 1. Create a Retention Campaign for Month-to-Month Customers

Target customers who are:

- on month-to-month contracts
- have high monthly charges
- have low tenure
- use fiber optic internet
- do not use premium tech support

---

### 2. Improve Early Customer Experience

Since low-tenure customers churn more, the first few months should include:

- welcome calls
- plan education
- service quality checks
- onboarding offers
- proactive support

---

### 3. Launch Contract Upgrade Offers

Encourage month-to-month customers to move to one-year or two-year contracts through:

- loyalty discounts
- bundled services
- free device protection
- premium support trial

---

### 4. Investigate Fiber Optic Churn

Analyze whether fiber optic churn is caused by:

- high price
- service quality
- speed expectations
- competitor offers
- lack of support services

---

### 5. Prioritize High-Value At-Risk Customers

Retention budget should not be spent equally on all customers.

Priority should be given to customers who are:

- high revenue
- high churn risk
- active
- month-to-month
- low tenure
- using expensive plans

---

## Suggested Visualizations

The following charts can be created for storytelling:

- Churn rate by contract type
- Churn rate by tenure group
- Churn rate by internet type
- Churn rate by payment method
- Monthly charge distribution by churn status
- Revenue lost by churn reason
- Top churn categories
- Churn by city
- Churn by age group
- High-risk customer segment analysis

---

## Project Folder Structure

```text
telecom-customer-churn-eda/
│
├── data/
│   ├── telecom_customer_churn.csv
│   └── telecom_customer_churn_cleaned.csv
│
├── notebooks/
│   └── telecom_churn_eda.ipynb
│
├── scripts/
│   └── data_cleaning.py
│
├── outputs/
│   ├── charts/
│   └── summary_tables/
│
├── README.md
└── requirements.txt
```

---

## How to Run This Project

### 1. Clone the repository

```bash
git clone https://github.com/your-username/telecom-customer-churn-eda.git
```

### 2. Install required libraries

```bash
pip install -r requirements.txt
```

### 3. Run the notebook

Open:

```text
notebooks/telecom_churn_eda.ipynb
```

Or run the Python script:

```bash
python scripts/data_cleaning.py
```

---

## Requirements

```text
pandas
numpy
matplotlib
seaborn
```

---

## Final Output

The final cleaned dataset can be used for:

- EDA
- SQL analysis
- Power BI dashboard
- Machine learning churn prediction
- business case study
- portfolio project

Final cleaned file:

```text
telecom_customer_churn_cleaned.csv
```

---

## Future Scope

This project can be extended into:

1. SQL-based churn analysis
2. Power BI dashboard
3. Customer churn prediction model
4. Retention campaign strategy
5. Revenue-at-risk analysis
6. Customer segmentation using clustering

---

## Conclusion

This EDA project shows how raw customer data can be transformed into meaningful business insights. Instead of only creating charts, the analysis focuses on understanding the data, cleaning it with business logic, identifying churn drivers, and recommending actions that can reduce churn and protect revenue.

The project demonstrates skills in:

- Data cleaning
- Missing value treatment
- Feature engineering
- Exploratory data analysis
- Churn analytics
- Revenue analysis
- Business storytelling
- Customer retention strategy
