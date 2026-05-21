-- ============================================================
-- TELECOM CUSTOMER CHURN ANALYSIS
-- Dataset : Maven Analytics — Telecom Customer Churn
-- Tool    : MySQL via XAMPP / phpMyAdmin
-- Tables  : location, customers, services, status
-- ============================================================


-- ============================================================
-- SECTION 1 : CREATE DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS telecom_churn;
USE telecom_churn;


-- ============================================================
-- SECTION 2 : CREATE STAGING TABLE
-- (Load the raw CSV here first, then split into 4 tables)
-- ============================================================

CREATE TABLE staging_raw (
    customer_id                       VARCHAR(20),
    gender                            INT,
    age                               INT,
    married                           INT,
    number_of_dependents              INT,
    city                              VARCHAR(50),
    zip_code                          INT,
    latitude                          FLOAT,
    longitude                         FLOAT,
    number_of_referrals               INT,
    tenure_in_months                     INT,
    offer                             VARCHAR(20),
    phone_service                     INT,
    avg_monthly_long_distance_charges FLOAT,
    multiple_lines                    INT,
    internet_service                  INT,
    internet_type                     VARCHAR(20),
    avg_monthly_gb_download           FLOAT,
    online_security                   FLOAT,
    online_backup                     FLOAT,
    device_protection_plan            FLOAT,
    premium_tech_support              FLOAT,
    streaming_tv                      FLOAT,
    streaming_movies                  FLOAT,
    streaming_music                   FLOAT,
    unlimited_data                    FLOAT,
    contract                          VARCHAR(20),
    paperless_billing                 INT,
    payment_method                    VARCHAR(30),
    monthly_charge                    FLOAT,
    total_charges                     FLOAT,
    total_refunds                     FLOAT,
    total_extra_data_charges          INT,
    total_long_distance_charges       FLOAT,
    total_revenue                     FLOAT,
    customer_status                   VARCHAR(20),
    churn_category                    VARCHAR(50),
    churn_reason                      VARCHAR(50)
);


-- ============================================================
-- SECTION 3 : LOAD CSV INTO STAGING TABLE
-- Place your CSV file inside:
-- C:/xampp/mysql/data/telecom_churn/
-- before running this command
-- ============================================================

LOAD DATA INFILE 'C:/xampp/mysql/data/telecom_churn/telecom_customer_churn_cleaned.csv'
INTO TABLE staging_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Verify data loaded correctly — should return 7043
SELECT COUNT(*) FROM staging_raw;

-- Preview first 5 rows
SELECT * FROM staging_raw LIMIT 5;


-- ============================================================
-- SECTION 4 : CREATE 4 FINAL TABLES WITH CONSTRAINTS
-- Run in this exact order:
-- 1. location  → 2. customers  → 3. services  → 4. status
-- ============================================================

-- Table 1 : location
CREATE TABLE location (
    zip_code   VARCHAR(10)  NOT NULL,
    city       VARCHAR(100),
    latitude   FLOAT,
    longitude  FLOAT,

    CONSTRAINT pk_location PRIMARY KEY (zip_code)
);

-- Table 2 : customers
CREATE TABLE customers (
    customer_id          VARCHAR(20)  NOT NULL,
    gender               INT,
    age                  INT,
    married              INT,
    number_of_dependents INT,
    number_of_referrals  INT,
    city                 VARCHAR(100),
    zip_code             INT  NOT NULL,

    CONSTRAINT pk_customers          PRIMARY KEY (customer_id),
    CONSTRAINT fk_customers_location FOREIGN KEY (zip_code)
        REFERENCES location(zip_code)
);

-- Table 3 : services
CREATE TABLE services (
    customer_id                       VARCHAR(20)  NOT NULL,
    tenure_months                     INT,
    offer                             VARCHAR(20),
    phone_service                     INT,
    multiple_lines                    INT,
    avg_monthly_long_distance_charges FLOAT,
    internet_service                  INT,
    internet_type                     VARCHAR(20),
    avg_monthly_gb_download           FLOAT,
    online_security                   FLOAT,
    online_backup                     FLOAT,
    device_protection_plan            FLOAT,
    premium_tech_support              FLOAT,
    streaming_tv                      FLOAT,
    streaming_movies                  FLOAT,
    streaming_music                   FLOAT,
    unlimited_data                    FLOAT,
    contract                          VARCHAR(20),
    paperless_billing                 INT,
    payment_method                    VARCHAR(30),
    monthly_charge                    FLOAT,
    total_charges                     FLOAT,
    total_refunds                     FLOAT,
    total_extra_data_charges          FLOAT,
    total_long_distance_charges       FLOAT,
    total_revenue                     FLOAT,

    CONSTRAINT pk_services           PRIMARY KEY (customer_id),
    CONSTRAINT fk_services_customers FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

-- Table 4 : status
CREATE TABLE status (
    customer_id        VARCHAR(20)  NOT NULL,
    customer_status    VARCHAR(20),
    churn_category     VARCHAR(50),
    churn_reason       VARCHAR(100),

    CONSTRAINT pk_status           PRIMARY KEY (customer_id),
    CONSTRAINT fk_status_customers FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


-- ============================================================
-- SECTION 5 : POPULATE 4 TABLES FROM STAGING
-- Run INSERT statements in this exact order
-- ============================================================

-- Step 1 : Fill location (DISTINCT removes duplicate zip codes)
INSERT INTO location (zip_code, city, latitude, longitude)
SELECT DISTINCT
    zip_code,
    city,
    latitude,
    longitude
FROM staging_raw;

-- Step 2 : Fill customers
INSERT INTO customers (
    customer_id, gender, age, married,
    number_of_dependents, number_of_referrals, city, zip_code
)
SELECT
    customer_id, gender, age, married,
    number_of_dependents, number_of_referrals, city, zip_code
FROM staging_raw;

-- Step 3 : Fill services
INSERT INTO services (
    customer_id, tenure_months, offer, phone_service,
    multiple_lines, avg_monthly_long_distance_charges,
    internet_service, internet_type, avg_monthly_gb_download,
    online_security, online_backup, device_protection_plan,
    premium_tech_support, streaming_tv, streaming_movies,
    streaming_music, unlimited_data, contract, paperless_billing,
    payment_method, monthly_charge, total_charges, total_refunds,
    total_extra_data_charges, total_long_distance_charges, total_revenue
)
SELECT
    customer_id, tenure_months, offer, phone_service,
    multiple_lines, avg_monthly_long_distance_charges,
    internet_service, internet_type, avg_monthly_gb_download,
    online_security, online_backup, device_protection_plan,
    premium_tech_support, streaming_tv, streaming_movies,
    streaming_music, unlimited_data, contract, paperless_billing,
    payment_method, monthly_charge, total_charges, total_refunds,
    total_extra_data_charges, total_long_distance_charges, total_revenue
FROM Base;

-- Step 4 : Fill status
-- churn_value is auto-calculated: Churned = 1, else = 0
INSERT INTO status (
    customer_id, customer_status, churn_value,
    churn_category, churn_reason
)
SELECT
    customer_id,
    customer_status,
    CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END,
    churn_category,
    churn_reason
FROM Base;


-- ============================================================
-- SECTION 6 : VERIFY ALL TABLES
-- All 4 tables should show 7043 rows
-- ============================================================

SELECT 'staging_raw' AS table_name, COUNT(*) AS row_count FROM staging_raw
UNION ALL
SELECT 'location',                  COUNT(*) FROM location
UNION ALL
SELECT 'customers',                 COUNT(*) FROM customers
UNION ALL
SELECT 'services',                  COUNT(*) FROM services
UNION ALL
SELECT 'status',                    COUNT(*) FROM status;

-- Test JOIN across all 4 tables
SELECT
    c.customer_id,
    c.gender,
    c.age,
    s.contract,
    s.monthly_charge,
    s.tenure_months,
    st.churn_value,
    st.churn_reason,
    l.city
FROM customers c
JOIN services  s  ON c.customer_id = s.customer_id
JOIN status    st ON c.customer_id = st.customer_id
JOIN location  l  ON c.zip_code    = l.zip_code
LIMIT 10;


-- ============================================================
-- SECTION 7 : ANALYSIS QUERIES
-- ============================================================


-- ------------------------------------------------------------
-- Q1 : Find all churned customers
-- Shows Customer ID, City, and Contract type
-- ------------------------------------------------------------

SELECT
    customers.customer_id,
    customers.city,
    services.contract
FROM customers
JOIN services ON customers.customer_id = services.customer_id
JOIN status   ON customers.customer_id = status.customer_id
WHERE status.churn_value = 1;


-- ------------------------------------------------------------
-- Q2 : Customer count by contract type
-- ------------------------------------------------------------

SELECT
    contract,
    COUNT(*) AS total_customers
FROM services
GROUP BY contract
ORDER BY total_customers DESC;


-- ------------------------------------------------------------
-- Q3  : Average monthly charge — churned vs retained
-- ------------------------------------------------------------

SELECT
    status.customer_status,
    ROUND(AVG(services.monthly_charge), 2) AS avg_monthly_charge
FROM services
JOIN status ON services.customer_id = status.customer_id
GROUP BY status.customer_status;


-- ------------------------------------------------------------
-- Q4  : Top 10 customers by total revenue
-- ------------------------------------------------------------

SELECT
    customers.customer_id,
    customers.city,
    services.total_revenue
FROM customers
JOIN services ON customers.customer_id = services.customer_id
ORDER BY services.total_revenue DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q5 : Cities with more than 50 customers
-- ------------------------------------------------------------

SELECT
    city,
    COUNT(*) AS total_customers
FROM customers
GROUP BY city
HAVING COUNT(*) > 50
ORDER BY total_customers DESC;


-- ------------------------------------------------------------
-- Q6  : Churn rate % by contract type
-- ------------------------------------------------------------

SELECT
    services.contract,
    COUNT(*) AS total_customers,
    SUM(status.churn_value) AS churned,
    ROUND(100.0 * SUM(status.churn_value) / COUNT(*), 1) AS churn_rate_pct
FROM services
JOIN status ON services.customer_id = status.customer_id
GROUP BY services.contract
ORDER BY churn_rate_pct DESC;


-- ------------------------------------------------------------
-- Q7  : Top 5 churn reasons
-- ------------------------------------------------------------

SELECT
    churn_reason,
    COUNT(*) AS total
FROM status
WHERE churn_value = 1
  AND churn_reason IS NOT NULL
GROUP BY churn_reason
ORDER BY total DESC
LIMIT 5;


-- ------------------------------------------------------------
-- Q8  : Customer count by tenure group
-- New = 0-12 months | Mid = 13-36 months | Loyal = 37+ months
-- ------------------------------------------------------------

SELECT
    CASE
        WHEN tenure_months BETWEEN 0  AND 12 THEN 'New (0-12 months)'
        WHEN tenure_months BETWEEN 13 AND 36 THEN 'Mid (13-36 months)'
        ELSE 'Loyal (37+ months)'
    END AS tenure_group,
    COUNT(*) AS total_customers
FROM services
GROUP BY tenure_group
ORDER BY total_customers DESC;


-- ------------------------------------------------------------
-- Q9  : Monthly revenue at risk by internet type
-- ------------------------------------------------------------

SELECT
    services.internet_type,
    COUNT(*) AS churned_customers,
    ROUND(SUM(services.monthly_charge), 2) AS revenue_at_risk
FROM services
JOIN status ON services.customer_id = status.customer_id
WHERE status.churn_value = 1
GROUP BY services.internet_type
ORDER BY revenue_at_risk DESC;


-- ------------------------------------------------------------
-- Q10  : Customers with monthly charge above
--              the average monthly charge of churned customers
-- ------------------------------------------------------------

SELECT
    customers.customer_id,
    customers.city,
    services.contract,
    services.monthly_charge
FROM customers
JOIN services ON customers.customer_id = services.customer_id
JOIN status   ON customers.customer_id = status.customer_id
WHERE services.monthly_charge > (
    SELECT AVG(services2.monthly_charge)
    FROM services services2
    JOIN status status2 ON services2.customer_id = status2.customer_id
    WHERE status2.churn_value = 1
)
ORDER BY services.monthly_charge DESC;


-- ------------------------------------------------------------
-- Q11  : Churn rate and avg monthly charge per city
--              Only cities with at least 20 customers
-- ------------------------------------------------------------

SELECT
    customers.city,
    COUNT(*) AS total_customers,
    ROUND(100.0 * SUM(status.churn_value) / COUNT(*), 1) AS churn_rate_pct,
    ROUND(AVG(services.monthly_charge), 2) AS avg_monthly_charge
FROM customers
JOIN services ON customers.customer_id = services.customer_id
JOIN status   ON customers.customer_id = status.customer_id
GROUP BY customers.city
HAVING COUNT(*) >= 20
ORDER BY churn_rate_pct DESC;


-- ------------------------------------------------------------
-- Q12  : Customer segmentation by monthly charge
-- High Value > 80 | Mid Value 40-80 | Low Value < 40
-- Shows count, avg tenure, and churn rate per segment
-- ------------------------------------------------------------

SELECT
    CASE
        WHEN services.monthly_charge > 80  THEN 'High Value'
        WHEN services.monthly_charge >= 40 THEN 'Mid Value'
        ELSE 'Low Value'
    END AS customer_segment,
    COUNT(*) AS total_customers,
    ROUND(AVG(services.tenure_months), 1) AS avg_tenure_months,
    ROUND(100.0 * SUM(status.churn_value) / COUNT(*), 1) AS churn_rate_pct
FROM services
JOIN status ON services.customer_id = status.customer_id
GROUP BY customer_segment
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- END OF FILE
-- ============================================================
