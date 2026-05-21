[README_telecom_churn.md](https://github.com/user-attachments/files/28095761/README_telecom_churn.md)
# Telecom Customer Churn Analysis

## Project Overview
This project covers the complete data analysis workflow for a telecom customer churn dataset — from raw data cleaning to business dashboard visualization. The goal is to help a telecom business understand why customers leave, when they leave, and what predicts churn.

---

## Repository Structure

| File | Description |
|---|---|
| `Churn_cleaning.ipynb` | Data cleaning notebook — prepares raw data for analysis |
| `Churn_dashboard.ipynb` | Dashboard notebook — 6 business visualizations |
| `telecom_customer_churn.csv` | Raw input dataset |
| `telecom_customer_churn_cleaned.csv` | Cleaned dataset exported from cleaning notebook |

---

## Tools and Libraries

```python
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
```

Designed to run in Google Colab, Jupyter Notebook, or VS Code with Jupyter extension.

---

## Part 1 — Data Cleaning

### Goal
Clean and standardize the raw telecom dataset so it is ready for analysis, SQL querying, and machine learning.

### Cleaning Steps

**1. Load and inspect data**
Loaded raw CSV and inspected structure using head(), dtypes, describe() and isna().sum()

**2. Standardize column names**
Converted all column names to lowercase and replaced spaces with underscores.

```text
Phone Service → phone_service
Customer Status → customer_status
```

**3. Encode binary columns**
Converted Yes/No columns to 1 and 0. Columns include phone_service, married, multiple_lines, internet_service, online_security, online_backup, device_protection_plan, premium_tech_support, streaming_tv, streaming_music, streaming_movies, unlimited_data, paperless_billing.

**4. Encode gender**
Female → 0, Male → 1

**5. Handle missing values using business logic**

| Column | Logic |
|---|---|
| offer | Filled missing with No Offer |
| Internet add-on services | Filled with 0 where internet_service = 0 |
| churn_category, churn_reason | Filled with Not Churned for non-churned customers |
| multiple_lines | Set to 0 where phone_service = 0; mode used for remaining missing |
| avg_monthly_long_distance_charges | Filled with 0 where phone_service = 0; median otherwise |
| avg_monthly_gb_download | Filled with 0 where internet_service = 0; median otherwise |
| internet_type | Filled missing with No Internet Service |

**6. Export cleaned dataset**

```python
churn_data.to_csv("telecom_customer_churn_cleaned.csv", index=False)
```

---

## Part 2 — Business Dashboard

### Goal
Analyze the cleaned dataset and answer six key business questions through visualizations.

### Data Preprocessing for Dashboard
- Filtered to include only Stayed and Churned customers
- Created binary churned column: 1 for Churned, 0 for Stayed
- Created tenure_group by binning tenure_in_months: 0-12, 13-24, 25-36, 37-48, 48+

---

### Plot 1 — Contract Type vs Churn Rate
**Business question:** Which contract type should we push customers toward?

Calculated churn rate per contract type using groupby and mean. Sorted by churn rate descending.

Key finding: Month-to-Month customers have the highest churn rate. Two Year contract customers have the lowest.

Business recommendation: Incentivize customers to move to annual or two year contracts through discounts or loyalty rewards.

---

### Plot 2 — When Do Customers Leave?
**Business question:** When should we intervene to save a customer?

Calculated churn rate per tenure group using groupby and mean.

Key finding: First 12 months is the most critical window. After 48 months churn drops significantly.

Business recommendation: Invest in onboarding experience. Retention efforts should be strongest in the first year.

---

### Plot 3 — Why Did Customers Leave?
**Business question:** Is churn a product problem or a people problem?

Used value_counts on churn_category to get count per category.

Key finding: Competitor is the biggest category but Attitude is alarming. Internal people problems are just as dangerous as external competition.

Business recommendation: Customer service training is non negotiable alongside competitive pricing strategy.

---

### Plot 4 — Top 10 Specific Churn Reasons
**Business question:** What exactly needs fixing?

Used value_counts on churn_reason and selected top 10.

Key finding: Competitor had better devices and competitor made better offer are top reasons. Attitude of support person appears in top three.

Business recommendation: Monitor competitor offers actively and address staff behavior through training.

---

### Plot 5 — Referral Churn Rate
**Business question:** Does a referral program reduce churn?

Calculated churn rate per number_of_referrals using groupby and mean.

Key finding: Customers with 0 referrals churn at 36%. Customers with 10+ referrals show 0% churn.

Business recommendation: Launch a referral rewards program. Customers who recommend others almost never leave.

---

### Plot 6 — Early Warning Signals
**Business question:** What signals tell us a customer is about to leave?

Calculated Pearson correlation of key features with churned column.

Key finding:
- Reduces churn: tenure_in_months, number_of_referrals, married, number_of_dependents, online_security, premium_tech_support
- Increases churn: paperless_billing, internet_service, unlimited_data, monthly_charge

Important note: Correlation does not imply causation. Further investigation is needed to confirm direct causes.

Business recommendation: Flag new customers with low tenure, zero referrals and month-to-month contracts as high risk.

---

## Key Business Summary

| Finding | Recommendation |
|---|---|
| Month-to-Month customers churn most | Push customers toward annual contracts |
| 60% of churners leave in first 12 months | Fix onboarding experience |
| 841 customers left for competitor offers | Monitor competitor pricing actively |
| 314 customers left due to staff attitude | Invest in customer service training |
| 0 referral customers churn at 36% | Launch referral rewards program |
| Tenure and referrals predict loyalty | Flag new low-referral customers as high risk |

---

## How to Run

**Step 1 — Data Cleaning**
1. Place telecom_customer_churn.csv in your working directory
2. Open Churn_cleaning.ipynb in Google Colab or Jupyter
3. Run all cells top to bottom
4. Cleaned file telecom_customer_churn_cleaned.csv will be generated

**Step 2 — Dashboard**
1. Upload telecom_customer_churn_cleaned.csv to your environment
2. Open Churn_dashboard.ipynb
3. Run all cells top to bottom
4. Each plot displays after its cell is executed

---

## Possible Business Questions This Project Answers

- What is the overall churn rate?
- Which contract type has the highest churn?
- When in the customer lifecycle does churn peak?
- What are the most common churn reasons?
- Do customers with premium support churn less?
- How do referrals predict customer loyalty?
- Which features are early warning signals for churn?
