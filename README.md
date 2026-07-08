# SoloBob Supply Chain Copilot

**SoloBob Supply Chain Copilot** is a domain-specific AI decision-support system built on Snowflake for the Snowflake CoCo CLI Hackathon 2026. It helps supply chain managers detect inventory risks, understand operational causes, generate replenishment recommendations, and track actions through an end-to-end workflow.

## Track

**Problem Statement 04: Domain-Specific AI Copilot**

The solution is tailored to supply chain and inventory operations. It combines structured enterprise data, risk analysis logic, agent-style modular skills, Snowflake workflows, and a Streamlit interface.

## Problem

Supply chain managers often need to make urgent inventory decisions using fragmented data across sales, inventory, supplier reliability, and delivery performance. Manual analysis can delay replenishment decisions, causing stockouts and customer dissatisfaction.

## Solution

SoloBob Supply Chain Copilot analyzes supply chain data inside Snowflake and provides:

- Product-level inventory risk classification
- Supplier delay and reliability analysis
- Recommended reorder quantities
- Manager-ready action recommendations
- Critical alerts for urgent stockout risks
- Workflow run logs for traceability
- Natural language demo questions for Snowflake CoCo / Cortex Code
- Streamlit in Snowflake UI for interactive decision support

## Key Features

1. **Inventory Risk Detection**  
   Compares current stock, safety stock, reorder point, and sales velocity.

2. **Supplier Delay Intelligence**  
   Detects delayed deliveries and low-reliability suppliers.

3. **Replenishment Recommendation**  
   Calculates recommended order quantity and action priority.

4. **One-Click Workflow Execution**  
   `CALL RUN_SOLOBOB_COPILOT();` refreshes action logs, generates alerts, and stores run summaries.

5. **Manager Brief**  
   Produces an executive-level summary of current supply chain risks.

6. **Streamlit App**  
   Displays KPIs, charts, risk dashboard, recommended actions, alerts, supplier concerns, workflow logs, and agent skills.

7. **Agent Skills Design**  
   Uses modular skill definitions: Inventory Risk Analysis, Supplier Delay Intelligence, and Replenishment Recommendation.

## Architecture

```text
Structured Enterprise Data
PRODUCTS / INVENTORY / SALES / SUPPLIERS / DELIVERIES
        ↓
Inventory Risk Analysis View
        ↓
Action Recommendation View
        ↓
Workflow Procedure
RUN_SOLOBOB_COPILOT()
        ↓
Action Log + Critical Alerts + Run Log
        ↓
Manager Brief + Streamlit Decision Interface
        ↓
Snowflake CoCo / Cortex Code natural language interaction
```

## Snowflake Objects

- Warehouse: `SOLOBOB_WH`
- Database: `SOLOBOB_DB`
- Schema: `SUPPLY_CHAIN`
- Tables:
  - `PRODUCTS`
  - `INVENTORY`
  - `SALES`
  - `SUPPLIERS`
  - `DELIVERIES`
  - `COPILOT_ACTION_LOG`
  - `COPILOT_ALERTS`
  - `COPILOT_RUN_LOG`
  - `COPILOT_AGENT_SKILLS`
  - `COPILOT_WORKFLOW_STEPS`
  - `COPILOT_DEMO_QUESTIONS`
- Views:
  - `INVENTORY_RISK_ANALYSIS`
  - `ACTION_RECOMMENDATIONS`
  - `MANAGER_BRIEF`
  - `EXECUTIVE_SUMMARY`
  - `COPILOT_DASHBOARD`
- Procedure:
  - `RUN_SOLOBOB_COPILOT()`

## Agent Skills

### 1. Inventory Risk Analysis Skill
Detects products with shortage risk by comparing current stock, safety stock, reorder point, and sales velocity.

### 2. Supplier Delay Intelligence Skill
Evaluates supplier reliability and delivery delay patterns that may worsen stockout risks.

### 3. Replenishment Recommendation Skill
Generates action priorities and recommended reorder quantities based on risk severity and expected demand.

## Tech Stack

- Snowflake AI Data Cloud
- Snowflake SQL
- Snowflake Cortex Code / CoCo natural language interaction
- Streamlit in Snowflake
- Python
- Snowpark session connection

## Setup Instructions

1. Open Snowflake Snowsight.
2. Create or open a SQL Worksheet.
3. Run the setup script:

```sql
-- Run everything in sql/setup_solobob.sql
```

4. Create a Streamlit app in Snowflake.
5. Paste the code from:

```text
app/streamlit_app.py
```

6. Run the app.
7. Click **Run SoloBob Copilot** to execute the workflow.

## CoCo / Cortex Code Demo Prompts

Use these prompts during the demo:

1. Which products are at highest inventory risk?
2. Why is Bluetooth Speaker considered high risk?
3. Which products should we reorder first?
4. Give me a manager summary of current supply chain risks.
5. Which supplier is causing the most operational concern?

## Demo Flow

1. Introduce the business problem: supply chain teams need faster inventory risk decisions.
2. Show the Streamlit dashboard KPIs.
3. Click **Run SoloBob Copilot**.
4. Show the workflow result, action log, and critical alerts.
5. Open Supplier Concerns to explain the weakest supplier.
6. Use Snowflake CoCo / Cortex Code to ask natural language questions about the data.
7. Explain the modular Agent Skills and end-to-end workflow.

## Why It Matters

SoloBob Supply Chain Copilot turns raw enterprise data into actionable decisions. It reduces manual analysis time, highlights urgent stockout risks, and provides manager-ready recommendations within a single Snowflake-powered workflow.
