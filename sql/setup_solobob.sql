USE ROLE ACCOUNTADMIN;

CREATE WAREHOUSE IF NOT EXISTS SOLOBOB_WH
  WITH WAREHOUSE_SIZE = XSMALL
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

CREATE DATABASE IF NOT EXISTS SOLOBOB_DB;
CREATE SCHEMA IF NOT EXISTS SOLOBOB_DB.SUPPLY_CHAIN;

USE WAREHOUSE SOLOBOB_WH;
USE DATABASE SOLOBOB_DB;
USE SCHEMA SUPPLY_CHAIN;

-- Core supply chain tables
CREATE OR REPLACE TABLE PRODUCTS (
    PRODUCT_ID STRING,
    PRODUCT_NAME STRING,
    CATEGORY STRING,
    UNIT_PRICE FLOAT,
    REORDER_POINT INT
);

CREATE OR REPLACE TABLE INVENTORY (
    PRODUCT_ID STRING,
    WAREHOUSE STRING,
    CURRENT_STOCK INT,
    SAFETY_STOCK INT,
    LAST_UPDATED DATE
);

CREATE OR REPLACE TABLE SALES (
    SALE_ID STRING,
    PRODUCT_ID STRING,
    SALE_DATE DATE,
    QUANTITY_SOLD INT,
    REGION STRING
);

CREATE OR REPLACE TABLE SUPPLIERS (
    SUPPLIER_ID STRING,
    SUPPLIER_NAME STRING,
    PRODUCT_ID STRING,
    AVERAGE_LEAD_TIME_DAYS INT,
    RELIABILITY_SCORE FLOAT
);

CREATE OR REPLACE TABLE DELIVERIES (
    DELIVERY_ID STRING,
    SUPPLIER_ID STRING,
    PRODUCT_ID STRING,
    EXPECTED_DELIVERY_DATE DATE,
    ACTUAL_DELIVERY_DATE DATE,
    DELIVERY_STATUS STRING
);

-- Sample data
INSERT INTO PRODUCTS VALUES
('P001', 'Wireless Headphones', 'Electronics', 79.90, 120),
('P002', 'Smart Watch', 'Electronics', 129.90, 80),
('P003', 'Laptop Stand', 'Accessories', 35.50, 150),
('P004', 'USB-C Hub', 'Accessories', 45.00, 100),
('P005', 'Bluetooth Speaker', 'Electronics', 59.90, 90);

INSERT INTO INVENTORY VALUES
('P001', 'Kuala Lumpur Warehouse', 95, 100, '2026-07-08'),
('P002', 'Kuala Lumpur Warehouse', 60, 70, '2026-07-08'),
('P003', 'Kuala Lumpur Warehouse', 220, 120, '2026-07-08'),
('P004', 'Kuala Lumpur Warehouse', 85, 90, '2026-07-08'),
('P005', 'Kuala Lumpur Warehouse', 40, 75, '2026-07-08');

INSERT INTO SALES VALUES
('S001', 'P001', '2026-06-01', 40, 'Malaysia'),
('S002', 'P001', '2026-06-08', 55, 'Malaysia'),
('S003', 'P001', '2026-06-15', 65, 'Malaysia'),
('S004', 'P001', '2026-06-22', 70, 'Malaysia'),
('S005', 'P002', '2026-06-01', 25, 'Malaysia'),
('S006', 'P002', '2026-06-08', 30, 'Malaysia'),
('S007', 'P002', '2026-06-15', 35, 'Malaysia'),
('S008', 'P002', '2026-06-22', 40, 'Malaysia'),
('S009', 'P003', '2026-06-01', 20, 'Malaysia'),
('S010', 'P003', '2026-06-08', 18, 'Malaysia'),
('S011', 'P004', '2026-06-15', 45, 'Malaysia'),
('S012', 'P004', '2026-06-22', 50, 'Malaysia'),
('S013', 'P005', '2026-06-01', 30, 'Malaysia'),
('S014', 'P005', '2026-06-08', 45, 'Malaysia'),
('S015', 'P005', '2026-06-15', 60, 'Malaysia'),
('S016', 'P005', '2026-06-22', 75, 'Malaysia');

INSERT INTO SUPPLIERS VALUES
('SUP001', 'AsiaTech Supplies', 'P001', 10, 0.85),
('SUP002', 'SmartLink Distribution', 'P002', 14, 0.78),
('SUP003', 'OfficeGear Manufacturing', 'P003', 7, 0.92),
('SUP004', 'CablePro Logistics', 'P004', 12, 0.80),
('SUP005', 'SoundWave Exporters', 'P005', 16, 0.65);

INSERT INTO DELIVERIES VALUES
('D001', 'SUP001', 'P001', '2026-07-05', '2026-07-07', 'Delayed'),
('D002', 'SUP002', 'P002', '2026-07-06', '2026-07-10', 'Delayed'),
('D003', 'SUP003', 'P003', '2026-07-04', '2026-07-04', 'On Time'),
('D004', 'SUP004', 'P004', '2026-07-06', '2026-07-08', 'Delayed'),
('D005', 'SUP005', 'P005', '2026-07-03', '2026-07-11', 'Delayed');

-- Risk analysis view
CREATE OR REPLACE VIEW INVENTORY_RISK_ANALYSIS AS
WITH SALES_SUMMARY AS (
    SELECT 
        PRODUCT_ID,
        SUM(QUANTITY_SOLD) AS TOTAL_SOLD_LAST_MONTH,
        AVG(QUANTITY_SOLD) AS AVG_WEEKLY_SALES
    FROM SALES
    GROUP BY PRODUCT_ID
),
DELIVERY_SUMMARY AS (
    SELECT
        PRODUCT_ID,
        COUNT_IF(DELIVERY_STATUS = 'Delayed') AS DELAYED_DELIVERIES,
        AVG(DATEDIFF('day', EXPECTED_DELIVERY_DATE, ACTUAL_DELIVERY_DATE)) AS AVG_DELAY_DAYS
    FROM DELIVERIES
    GROUP BY PRODUCT_ID
)
SELECT
    P.PRODUCT_ID,
    P.PRODUCT_NAME,
    P.CATEGORY,
    I.WAREHOUSE,
    I.CURRENT_STOCK,
    I.SAFETY_STOCK,
    P.REORDER_POINT,
    S.TOTAL_SOLD_LAST_MONTH,
    ROUND(S.AVG_WEEKLY_SALES, 2) AS AVG_WEEKLY_SALES,
    SUP.SUPPLIER_NAME,
    SUP.AVERAGE_LEAD_TIME_DAYS,
    SUP.RELIABILITY_SCORE,
    D.DELAYED_DELIVERIES,
    ROUND(D.AVG_DELAY_DAYS, 2) AS AVG_DELAY_DAYS,
    CASE
        WHEN I.CURRENT_STOCK < I.SAFETY_STOCK 
             AND D.DELAYED_DELIVERIES >= 1 
             AND S.AVG_WEEKLY_SALES >= 50
        THEN 'HIGH RISK'
        WHEN I.CURRENT_STOCK < P.REORDER_POINT 
             OR D.DELAYED_DELIVERIES >= 1
        THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END AS RISK_LEVEL,
    CASE
        WHEN I.CURRENT_STOCK < I.SAFETY_STOCK 
             AND D.DELAYED_DELIVERIES >= 1
        THEN 'Stock is below safety level and supplier delivery is delayed.'
        WHEN I.CURRENT_STOCK < P.REORDER_POINT
        THEN 'Stock has fallen below reorder point.'
        WHEN D.DELAYED_DELIVERIES >= 1
        THEN 'Supplier delivery delay detected.'
        ELSE 'Inventory level appears stable.'
    END AS RISK_REASON
FROM PRODUCTS P
JOIN INVENTORY I ON P.PRODUCT_ID = I.PRODUCT_ID
LEFT JOIN SALES_SUMMARY S ON P.PRODUCT_ID = S.PRODUCT_ID
LEFT JOIN SUPPLIERS SUP ON P.PRODUCT_ID = SUP.PRODUCT_ID
LEFT JOIN DELIVERY_SUMMARY D ON P.PRODUCT_ID = D.PRODUCT_ID;

-- Action recommendation view
CREATE OR REPLACE VIEW ACTION_RECOMMENDATIONS AS
SELECT
    PRODUCT_ID,
    PRODUCT_NAME,
    CATEGORY,
    WAREHOUSE,
    CURRENT_STOCK,
    SAFETY_STOCK,
    REORDER_POINT,
    TOTAL_SOLD_LAST_MONTH,
    AVG_WEEKLY_SALES,
    SUPPLIER_NAME,
    AVERAGE_LEAD_TIME_DAYS,
    RELIABILITY_SCORE,
    DELAYED_DELIVERIES,
    AVG_DELAY_DAYS,
    RISK_LEVEL,
    RISK_REASON,
    CASE
        WHEN RISK_LEVEL = 'HIGH RISK' THEN 'URGENT'
        WHEN RISK_LEVEL = 'MEDIUM RISK' THEN 'REVIEW SOON'
        ELSE 'MONITOR'
    END AS ACTION_PRIORITY,
    GREATEST(
        CEIL(REORDER_POINT + (COALESCE(AVG_WEEKLY_SALES, 0) * 2) - CURRENT_STOCK),
        0
    ) AS RECOMMENDED_ORDER_QTY,
    CASE
        WHEN RISK_LEVEL = 'HIGH RISK' THEN 'Place an urgent replenishment order and contact supplier immediately.'
        WHEN RISK_LEVEL = 'MEDIUM RISK' THEN 'Review inventory within 3 days and prepare a replenishment plan.'
        ELSE 'Continue monitoring. No immediate action required.'
    END AS RECOMMENDED_ACTION
FROM INVENTORY_RISK_ANALYSIS;

CREATE OR REPLACE TABLE COPILOT_ACTION_LOG (
    ACTION_ID STRING,
    PRODUCT_ID STRING,
    PRODUCT_NAME STRING,
    ACTION_PRIORITY STRING,
    RECOMMENDED_ORDER_QTY INT,
    RECOMMENDED_ACTION STRING,
    STATUS STRING,
    CREATED_AT TIMESTAMP_NTZ
);

CREATE OR REPLACE VIEW MANAGER_BRIEF AS
SELECT
    COUNT(*) AS TOTAL_PRODUCTS_MONITORED,
    COUNT_IF(RISK_LEVEL = 'HIGH RISK') AS HIGH_RISK_PRODUCTS,
    COUNT_IF(RISK_LEVEL = 'MEDIUM RISK') AS MEDIUM_RISK_PRODUCTS,
    COUNT_IF(RISK_LEVEL = 'LOW RISK') AS LOW_RISK_PRODUCTS,
    SUM(CASE WHEN ACTION_PRIORITY = 'URGENT' THEN RECOMMENDED_ORDER_QTY ELSE 0 END) AS TOTAL_URGENT_REORDER_QTY,
    LISTAGG(CASE WHEN ACTION_PRIORITY = 'URGENT' THEN PRODUCT_NAME END, ', ') AS URGENT_PRODUCTS,
    LISTAGG(CASE WHEN ACTION_PRIORITY = 'REVIEW SOON' THEN PRODUCT_NAME END, ', ') AS REVIEW_SOON_PRODUCTS
FROM ACTION_RECOMMENDATIONS;

CREATE OR REPLACE VIEW EXECUTIVE_SUMMARY AS
SELECT
    'SoloBob Supply Chain Copilot has monitored ' || TOTAL_PRODUCTS_MONITORED || 
    ' products. It detected ' || HIGH_RISK_PRODUCTS || 
    ' high-risk products and ' || MEDIUM_RISK_PRODUCTS || 
    ' medium-risk products. Urgent attention is required for: ' || COALESCE(URGENT_PRODUCTS, 'None') || 
    '. Products requiring review soon include: ' || COALESCE(REVIEW_SOON_PRODUCTS, 'None') || 
    '. The total urgent recommended reorder quantity is ' || TOTAL_URGENT_REORDER_QTY || ' units.' AS SUMMARY_TEXT
FROM MANAGER_BRIEF;

CREATE OR REPLACE VIEW COPILOT_DASHBOARD AS
SELECT
    PRODUCT_NAME,
    CATEGORY,
    WAREHOUSE,
    CURRENT_STOCK,
    SAFETY_STOCK,
    REORDER_POINT,
    TOTAL_SOLD_LAST_MONTH,
    AVG_WEEKLY_SALES,
    SUPPLIER_NAME,
    RELIABILITY_SCORE,
    DELAYED_DELIVERIES,
    AVG_DELAY_DAYS,
    RISK_LEVEL,
    RISK_REASON,
    ACTION_PRIORITY,
    RECOMMENDED_ORDER_QTY,
    RECOMMENDED_ACTION
FROM ACTION_RECOMMENDATIONS
ORDER BY
    CASE 
        WHEN ACTION_PRIORITY = 'URGENT' THEN 1
        WHEN ACTION_PRIORITY = 'REVIEW SOON' THEN 2
        ELSE 3
    END,
    RECOMMENDED_ORDER_QTY DESC;

CREATE OR REPLACE TABLE COPILOT_DEMO_QUESTIONS (
    QUESTION_ID INT,
    USER_QUESTION STRING,
    EXPECTED_COPILOT_ACTION STRING
);

INSERT INTO COPILOT_DEMO_QUESTIONS VALUES
(1, 'Which products are at highest inventory risk?', 'Analyze risk level and identify high-priority products.'),
(2, 'Why is Bluetooth Speaker considered high risk?', 'Explain risk reason using stock, sales, and supplier delay data.'),
(3, 'Which products should we reorder first?', 'Rank products by action priority and recommended order quantity.'),
(4, 'Give me a manager summary of current supply chain risks.', 'Generate an executive summary based on overall risk status.'),
(5, 'Which supplier is causing the most operational concern?', 'Analyze supplier reliability and delivery delay impact.');

CREATE OR REPLACE TABLE COPILOT_RUN_LOG (
    RUN_ID STRING,
    RUN_TIME TIMESTAMP_NTZ,
    TOTAL_PRODUCTS_MONITORED INT,
    HIGH_RISK_PRODUCTS INT,
    MEDIUM_RISK_PRODUCTS INT,
    LOW_RISK_PRODUCTS INT,
    URGENT_PRODUCTS STRING,
    REVIEW_SOON_PRODUCTS STRING,
    SUMMARY_TEXT STRING
);

CREATE OR REPLACE TABLE COPILOT_ALERTS (
    ALERT_ID STRING,
    RUN_ID STRING,
    PRODUCT_ID STRING,
    PRODUCT_NAME STRING,
    ALERT_TYPE STRING,
    SEVERITY STRING,
    ALERT_MESSAGE STRING,
    CREATED_AT TIMESTAMP_NTZ
);

CREATE OR REPLACE PROCEDURE RUN_SOLOBOB_COPILOT()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    V_RUN_ID STRING DEFAULT UUID_STRING();
BEGIN
    TRUNCATE TABLE COPILOT_ACTION_LOG;

    INSERT INTO COPILOT_ACTION_LOG
    SELECT
        UUID_STRING() AS ACTION_ID,
        PRODUCT_ID,
        PRODUCT_NAME,
        ACTION_PRIORITY,
        RECOMMENDED_ORDER_QTY,
        RECOMMENDED_ACTION,
        'PENDING' AS STATUS,
        CURRENT_TIMESTAMP() AS CREATED_AT
    FROM ACTION_RECOMMENDATIONS
    WHERE ACTION_PRIORITY IN ('URGENT', 'REVIEW SOON');

    INSERT INTO COPILOT_RUN_LOG
    SELECT
        :V_RUN_ID AS RUN_ID,
        CURRENT_TIMESTAMP() AS RUN_TIME,
        TOTAL_PRODUCTS_MONITORED,
        HIGH_RISK_PRODUCTS,
        MEDIUM_RISK_PRODUCTS,
        LOW_RISK_PRODUCTS,
        COALESCE(URGENT_PRODUCTS, 'None') AS URGENT_PRODUCTS,
        COALESCE(REVIEW_SOON_PRODUCTS, 'None') AS REVIEW_SOON_PRODUCTS,
        SUMMARY_TEXT
    FROM MANAGER_BRIEF
    CROSS JOIN EXECUTIVE_SUMMARY;

    INSERT INTO COPILOT_ALERTS
    SELECT
        UUID_STRING() AS ALERT_ID,
        :V_RUN_ID AS RUN_ID,
        PRODUCT_ID,
        PRODUCT_NAME,
        'INVENTORY_RISK' AS ALERT_TYPE,
        'CRITICAL' AS SEVERITY,
        PRODUCT_NAME || ' is flagged as ' || RISK_LEVEL || 
        '. Reason: ' || RISK_REASON || 
        ' Recommended action: ' || RECOMMENDED_ACTION AS ALERT_MESSAGE,
        CURRENT_TIMESTAMP() AS CREATED_AT
    FROM ACTION_RECOMMENDATIONS
    WHERE ACTION_PRIORITY = 'URGENT';

    RETURN 'SoloBob Copilot workflow completed successfully. Run ID: ' || V_RUN_ID;
END;
$$;

CREATE OR REPLACE TABLE COPILOT_AGENT_SKILLS (
    SKILL_ID INT,
    SKILL_NAME STRING,
    SKILL_ROLE STRING,
    INPUT_DATA STRING,
    CORE_LOGIC STRING,
    OUTPUT_RESULT STRING,
    BUSINESS_VALUE STRING
);

INSERT INTO COPILOT_AGENT_SKILLS VALUES
(1, 'Inventory Risk Analysis Skill', 'Detects products with shortage risk by comparing current stock, safety stock, reorder point, and sales velocity.', 'PRODUCTS, INVENTORY, SALES', 'Calculates monthly sales, average weekly sales, and compares inventory levels against safety and reorder thresholds.', 'Inventory risk level and risk reason for each product.', 'Helps managers identify which products may run out of stock before it affects customers.'),
(2, 'Supplier Delay Intelligence Skill', 'Evaluates supplier reliability and delivery delay patterns that may worsen stockout risks.', 'SUPPLIERS, DELIVERIES', 'Measures delayed deliveries, average delay days, and supplier reliability score.', 'Supplier concern signals and delay-related risk explanation.', 'Helps managers detect whether inventory risk is caused by supplier performance issues.'),
(3, 'Replenishment Recommendation Skill', 'Generates action priorities and recommended reorder quantities based on risk severity and expected demand.', 'INVENTORY_RISK_ANALYSIS, ACTION_RECOMMENDATIONS', 'Ranks products as URGENT, REVIEW SOON, or MONITOR and calculates recommended order quantity.', 'Manager-ready action plan with recommended reorder quantity and next step.', 'Turns data analysis into practical supply chain decisions.');

CREATE OR REPLACE TABLE COPILOT_WORKFLOW_STEPS (
    STEP_ID INT,
    STEP_NAME STRING,
    DESCRIPTION STRING,
    SNOWFLAKE_OBJECT_USED STRING,
    OUTPUT_CREATED STRING
);

INSERT INTO COPILOT_WORKFLOW_STEPS VALUES
(1, 'Enterprise Data Ingestion', 'Loads structured supply chain data including products, inventory, sales, suppliers, and deliveries.', 'PRODUCTS, INVENTORY, SALES, SUPPLIERS, DELIVERIES', 'Centralized supply chain dataset'),
(2, 'Risk Analysis', 'Analyzes stock level, sales velocity, supplier reliability, and delivery delay to classify product risk.', 'INVENTORY_RISK_ANALYSIS', 'Risk level and risk reason'),
(3, 'Action Recommendation', 'Generates action priority and recommended replenishment quantity.', 'ACTION_RECOMMENDATIONS', 'Recommended manager actions'),
(4, 'Alert Generation', 'Creates critical alerts for urgent inventory risks.', 'COPILOT_ALERTS', 'Critical inventory alerts'),
(5, 'Workflow Logging', 'Stores each copilot run with summary statistics and manager brief.', 'COPILOT_RUN_LOG', 'Auditable workflow history'),
(6, 'Manager Decision Interface', 'Displays KPIs, risk dashboard, recommendations, alerts, supplier concerns, and workflow logs in Streamlit.', 'Streamlit App + COPILOT_DASHBOARD', 'Interactive decision-support application');

CALL RUN_SOLOBOB_COPILOT();
