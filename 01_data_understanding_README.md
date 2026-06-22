# Telecom Customer Churn Analysis — Data Understanding

## Project Overview

This project analyzes a telecom customer churn dataset to understand customer behavior, churn patterns, revenue impact, and business risks before moving into data cleaning, exploratory data analysis, SQL analysis, DAX modeling, and Power BI dashboard development.

The purpose of this first phase is to understand the raw dataset deeply before making any cleaning or transformation decisions. Instead of directly filling missing values or dropping columns, this notebook focuses on identifying what the data represents, how the columns are structured, where missing values exist, and what early business signals can be observed.

This approach reflects a professional analytics workflow where data understanding comes before data cleaning.

---

## Business Problem

Customer churn is one of the most important problems for subscription-based businesses such as telecom companies. When customers leave, the company loses recurring revenue, customer lifetime value, and future upsell opportunities.

The business goal of this project is to answer:

* How many customers are leaving?
* Which customer segments show higher churn?
* How much revenue is associated with churned customers?
* Which contract types, internet services, payment methods, and offers are linked with churn?
* What early signals can help the business design better retention strategies?

---

## Dataset Description

The dataset contains customer-level information for a telecom company. Each row represents one customer and includes demographic details, service subscriptions, contract information, billing details, revenue metrics, and churn-related information.

### Dataset Size

| Metric             |           Value |
| ------------------ | --------------: |
| Total Rows         |           7,043 |
| Total Columns      |              38 |
| Main Target Column | Customer Status |
| Churned Customers  |           1,869 |
| Stayed Customers   |           4,720 |
| Joined Customers   |             454 |

---

## Tools Used

* Python
* Pandas
* NumPy
* Matplotlib
* Jupyter Notebook

---

## Notebook File

```text
Churn_data_Understanding.ipynb
```

This notebook focuses only on understanding the raw dataset. No permanent cleaning, transformation, or feature engineering is performed in this phase.

---

## Data Understanding Workflow

The notebook covers the following steps:

### 1. Importing Required Libraries

The notebook begins by importing core Python libraries required for data inspection and basic visualization.

Libraries used:

* `pandas` for data manipulation
* `numpy` for numerical operations
* `matplotlib` for basic visualization
* `pathlib` for file path handling

---

### 2. Loading the Dataset

The dataset is loaded from a CSV file using `pandas.read_csv()`.

A copy of the original dataset is created to preserve the raw version for reference.

```python
df_raw = df.copy()
```

This ensures that future cleaning or transformation steps do not accidentally overwrite the original data.

---

### 3. Basic Dataset Inspection

The notebook checks:

* Number of rows
* Number of columns
* First few rows
* Last few rows
* Random sample records
* Complete column list

This gives an initial view of how the dataset is structured and what type of information it contains.

---

### 4. Column and Schema Understanding

A schema summary is created to inspect each column based on:

* Column name
* Data type
* Non-null count
* Null count
* Null percentage
* Number of unique values

This helps identify:

* Which columns are numerical
* Which columns are categorical
* Which columns may need cleaning
* Which columns may contain high-cardinality values
* Which columns require business interpretation before handling missing values

---

### 5. Duplicate Check

The notebook checks for:

* Fully duplicated rows
* Duplicate customer IDs

This is important because customer-level datasets should ideally have one unique row per customer.

Duplicate checks help prevent inflated customer counts, incorrect churn rates, and misleading revenue calculations.

---

### 6. Missing Value Analysis

Missing values are analyzed using both tabular and visual methods.

The notebook calculates:

* Missing value count
* Missing value percentage
* Columns affected by missing values

A bar chart is also created to visualize missing percentage by column.

At this stage, missing values are not filled or removed. They are only studied.

This is important because some missing values may have business meaning. For example, missing internet service-related values may indicate that a customer does not use internet service.

---

### 7. Numerical and Categorical Feature Separation

The dataset is divided into:

* Numerical columns
* Categorical columns

This helps plan future cleaning, EDA, SQL analysis, and Power BI modeling.

Numerical columns are useful for revenue, tenure, charges, and quantitative customer behavior analysis.

Categorical columns are useful for churn segmentation, contract analysis, service analysis, payment method analysis, and customer profiling.

---

### 8. Target Variable Understanding

The main target column is:

```text
Customer Status
```

It contains three customer categories:

* Churned
* Stayed
* Joined

This column is used to understand the current customer lifecycle status.

---

## Initial KPI Snapshot

The first-level business KPIs identified from the raw dataset are:

| KPI                                            |       Value |
| ---------------------------------------------- | ----------: |
| Total Customers                                |       7,043 |
| Churned Customers                              |       1,869 |
| Stayed Customers                               |       4,720 |
| Joined Customers                               |         454 |
| Overall Churn Rate                             |      26.54% |
| Adjusted Churn Rate Excluding Joined Customers |      28.37% |
| Total Revenue Represented                      |     $21.37M |
| Revenue from Churned Customers                 |      $3.68M |
| Monthly Revenue from Churned Customers         | $137,086.65 |

---

## Early Business Observations

### 1. Churn is a major business problem

The overall churn rate is approximately 26.54%. This means more than one-fourth of the customer base has churned.

When newly joined customers are excluded, the adjusted churn rate increases to approximately 28.37%, which gives a clearer picture of churn among existing customers.

---

### 2. Churned customers have higher monthly charges

Average monthly charge by customer status shows that churned customers pay more per month than stayed customers.

| Customer Type     | Average Monthly Charge |
| ----------------- | ---------------------: |
| Churned Customers |                 $73.35 |
| Stayed Customers  |                 $61.74 |

This indicates that the company is not only losing customers but also losing customers with relatively higher monthly billing value.

---

### 3. Churned customers have lower average tenure

Average tenure shows that churned customers stayed with the company for a shorter period compared to retained customers.

| Customer Type     | Average Tenure |
| ----------------- | -------------: |
| Churned Customers |      18 months |
| Stayed Customers  |      41 months |

This suggests that early-stage customer retention may be an important area for business improvement.

---

### 4. Month-to-month contracts show high churn risk

Contract type appears to be one of the strongest early churn indicators.

| Contract Type  | Customers | Churned Customers | Churn Rate |
| -------------- | --------: | ----------------: | ---------: |
| Month-to-Month |     3,610 |             1,655 |     45.84% |
| One Year       |     1,550 |               166 |     10.71% |
| Two Year       |     1,883 |                48 |      2.55% |

Customers on month-to-month contracts are significantly more likely to churn compared to customers on longer-term contracts.

---

### 5. Fiber optic customers show high churn

Internet service type also shows important churn variation.

| Internet Type | Customers | Churned Customers | Churn Rate |
| ------------- | --------: | ----------------: | ---------: |
| Fiber Optic   |     3,035 |             1,236 |     40.72% |
| Cable         |       830 |               213 |     25.66% |
| DSL           |     1,652 |               307 |     18.58% |
| No Internet   |     1,526 |               113 |      7.40% |

Fiber optic customers have a high churn rate despite likely being a high-value customer segment. This may indicate issues related to pricing, service quality, competition, or customer expectations.

---

### 6. Competitor-related churn is the biggest category

Among churned customers, competitor-related reasons represent the largest churn category.

| Churn Category  | Churned Customers | Share of Churn |
| --------------- | ----------------: | -------------: |
| Competitor      |               841 |         45.00% |
| Dissatisfaction |               321 |         17.17% |
| Attitude        |               314 |         16.80% |
| Price           |               211 |         11.29% |
| Other           |               182 |          9.74% |

This suggests that the business problem is not only about pricing. Competitor offerings, service quality, and customer experience may be major churn drivers.

---

## Data Quality Observations

During the data understanding phase, several important data quality areas were identified:

### Missing Values

Missing values exist in columns related to:

* Internet service
* Phone service
* Offers
* Churn category
* Churn reason

These missing values should not be handled blindly. Some of them may represent valid business conditions, such as:

* Customer has no internet service
* Customer has no phone service
* Customer did not receive any offer
* Customer did not churn

These findings will guide the data cleaning phase.

---

### High-Cardinality Columns

Some columns contain many unique values, such as:

* Customer ID
* City
* Zip Code
* Latitude
* Longitude

These columns may be useful for customer-level tracking and geographic analysis but may not be directly useful for every type of aggregation.

---

### Numerical Columns

Numerical columns include:

* Age
* Tenure in Months
* Number of Referrals
* Monthly Charge
* Total Charges
* Total Refunds
* Total Revenue
* Avg Monthly GB Download
* Avg Monthly Long Distance Charges

These columns will be useful for revenue analysis, customer value analysis, tenure-based analysis, and churn behavior analysis.

---

### Categorical Columns

Categorical columns include:

* Gender
* Married
* Offer
* Phone Service
* Multiple Lines
* Internet Service
* Internet Type
* Contract
* Payment Method
* Customer Status
* Churn Category
* Churn Reason

These columns will be useful for segmentation and churn driver analysis.

---

## Why This Phase Matters

This phase is important because cleaning data without understanding it can lead to wrong assumptions.

For example:

* Missing internet-related values should not automatically be treated as errors.
* Missing churn reasons may simply mean the customer did not churn.
* New customers should be treated carefully when calculating churn rate.
* Revenue impact should be studied along with churn count.
* Contract and service type should be analyzed before building retention strategies.

This step ensures that future cleaning and analysis decisions are based on business logic, not only technical assumptions.

---

## Key Skills Demonstrated

This notebook demonstrates the following data analytics skills:

* Dataset inspection
* Schema analysis
* Missing value analysis
* Duplicate checking
* Numerical and categorical feature separation
* Target variable understanding
* Churn rate calculation
* Revenue-level business understanding
* Customer segmentation basics
* Early KPI development
* Business-focused data interpretation

---

## Next Step

The next phase of the project is:

```text
02_data_cleaning.ipynb
```

In the next phase, the dataset will be cleaned using the insights from this data understanding stage.

Planned cleaning tasks include:

* Handling missing values using business logic
* Correcting data types
* Creating clean service-related fields
* Preparing churn-related columns
* Creating a cleaned dataset for SQL and Power BI
* Exporting the final cleaned CSV file

---

